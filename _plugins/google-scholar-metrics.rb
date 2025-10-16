require 'open-uri'
require 'json'
require 'fileutils'
require 'nokogiri'

module Jekyll
  # Generator that fetches Google Scholar profile metrics and stores them in site.data
  class GoogleScholarMetricsGenerator < Generator
    safe true
    priority :low

    CACHE_TTL_SECONDS = 3 * 24 * 60 * 60 # 3 days

    def generate(site)
      scholar_id = resolve_scholar_id(site)
      return if scholar_id.nil? || scholar_id.empty?

      cache_file = File.join(site.source, "_cache", "scholar_#{scholar_id}.json")
      ensure_cache_dir(cache_file)

      metrics = read_fresh_cache(cache_file)
      unless metrics
        # Try to fetch new data
        fetched = fetch_metrics_from_scholar(scholar_id)
        if fetched && metrics_valid?(fetched)
          fetched['fetched_at'] = Time.now.utc.iso8601
          write_cache(cache_file, fetched)
          metrics = fetched
        else
          # If fetch failed, try to use stale cache as fallback
          metrics = read_stale_cache(cache_file)
          puts "Warning: Failed to fetch fresh Scholar data, using stale cache" if metrics
        end
      end

      # Ensure fetched_at exists for fresh cache without timestamp
      if metrics && !metrics.key?('fetched_at')
        begin
          metrics['fetched_at'] = File.mtime(cache_file).utc.iso8601
        rescue
          metrics['fetched_at'] = Time.now.utc.iso8601
        end
      end

      # Expose to templates as site.data.scholar_metrics
      site.data['scholar_metrics'] = metrics || { 'citations' => 'N/A', 'h_index' => 'N/A', 'i10_index' => 'N/A', 'per_year' => [], 'fetched_at' => nil }
    end

    private

    def resolve_scholar_id(site)
      # Expect id at site.data.socials.scholar_userid
      socials = site.data['socials'] || {}
      socials['scholar_userid']&.to_s
    end

    def ensure_cache_dir(cache_file)
      dir = File.dirname(cache_file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def read_fresh_cache(cache_file)
      return nil unless File.exist?(cache_file)
      return nil if (Time.now - File.mtime(cache_file)) >= CACHE_TTL_SECONDS
      begin
        data = JSON.parse(File.read(cache_file))
        # Backfill fetched_at if missing
        data['fetched_at'] ||= File.mtime(cache_file).utc.iso8601
        data
      rescue
        nil
      end
    end

    def read_stale_cache(cache_file)
      # Read cache regardless of age, as fallback when fetch fails
      return nil unless File.exist?(cache_file)
      begin
        data = JSON.parse(File.read(cache_file))
        data['fetched_at'] ||= File.mtime(cache_file).utc.iso8601
        # Only return if data is valid
        metrics_valid?(data) ? data : nil
      rescue
        nil
      end
    end

    def write_cache(cache_file, metrics)
      File.write(cache_file, metrics.to_json)
    end

    def fetch_metrics_from_scholar(scholar_id)
      profile_url = "https://scholar.google.com/citations?user=#{scholar_id}&hl=en"
      html = URI.open(profile_url, headers_for_request).read

      # Bail if blocked/consent
      return nil if html.include?("consent") || html.include?("recaptcha")

      doc = Nokogiri::HTML(html)

      # Prefer parsing the stats table
      citations_all = nil
      h_index_all = nil
      i10_index_all = nil

      std_cells = doc.css('#gsc_rsb_st .gsc_rsb_std')
      if std_cells && std_cells.length >= 5
        citations_all = text_to_int(std_cells[0]&.text)
        h_index_all = text_to_int(std_cells[2]&.text)
        i10_index_all = text_to_int(std_cells[4]&.text)
      end

      # Fallbacks via regex if any missing
      citations_all ||= extract_citations(html)
      h_index_all ||= extract_simple_metric(html, /h-index\s*(\d+)/)&.to_i
      i10_index_all ||= extract_simple_metric(html, /i10-index\s*(\d+)/)&.to_i

      per_year = extract_per_year_citations(html)

      return nil unless citations_all && h_index_all && i10_index_all

      {
        'citations' => format_citations(citations_all),
        'h_index' => h_index_all.to_s,
        'i10_index' => i10_index_all.to_s,
        'per_year' => per_year
      }
    rescue => e
      puts "Error fetching Google Scholar metrics: #{e.class} - #{e.message}"
      nil
    end

    def extract_per_year_citations(html)
      doc = Nokogiri::HTML(html)
      years = doc.css('.gsc_g_t').map { |n| n.text.strip }.select { |t| t =~ /^\d{4}$/ }
      counts = doc.css('.gsc_g_al').map { |n| n.text.strip.gsub(',', '').to_i }
      # Zip to array of hashes; lengths may differ depending on page content
      per_year = []
      [years.length, counts.length].min.times do |i|
        per_year << { 'year' => years[i], 'citations' => counts[i] }
      end
      per_year
    rescue
      []
    end

    def headers_for_request
      {
        "User-Agent" => user_agent,
        "Accept-Language" => "en-US,en;q=0.9",
        "Referer" => "https://scholar.google.com/"
      }
    end

    def extract_citations(html)
      m = html.match(/Citations\s*(\d+[\d,]*)/)
      return nil unless m
      m[1].gsub(',', '').to_i
    end

    def extract_simple_metric(html, regex)
      m = html.match(regex)
      m ? m[1] : nil
    end

    def format_citations(num)
      return '0' unless num.is_a?(Integer)
      return '0' if num < 0
      return num.to_s if num < 1000
      # Show with one decimal for thousands, e.g., 1.2K
      ((num / 100).floor / 10.0).to_s.sub(/\.0$/, '') + 'K'
    end

    def user_agent
      "Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122 Safari/537.36"
    end
  
    def metrics_valid?(metrics)
      return false unless metrics.is_a?(Hash)
      c = metrics['citations']
      h = metrics['h_index']
      i = metrics['i10_index']
      return false if [c, h, i].any? { |v| v.nil? || v.to_s == '0' || v == 'N/A' }
      true
    end

    def text_to_int(text)
      return nil if text.nil?
      text.to_s.strip.gsub(',', '').to_i
    end
  end
end
