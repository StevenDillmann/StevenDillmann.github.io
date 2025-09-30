require 'open-uri'
require 'json'
require 'fileutils'
require 'nokogiri'

module Jekyll
  # Generator that fetches Google Scholar profile metrics and stores them in site.data
  class GoogleScholarMetricsGenerator < Generator
    safe true
    priority :low

    CACHE_TTL_SECONDS = 24 * 60 * 60

    def generate(site)
      scholar_id = resolve_scholar_id(site)
      return if scholar_id.nil? || scholar_id.empty?

      cache_file = File.join(site.source, "_cache", "scholar_#{scholar_id}.json")
      ensure_cache_dir(cache_file)

      metrics = read_fresh_cache(cache_file)
      unless metrics
        metrics = fetch_metrics_from_scholar(scholar_id)
        write_cache(cache_file, metrics) if metrics
      end

      # Expose to templates as site.data.scholar_metrics
      site.data['scholar_metrics'] = metrics || { 'citations' => 'N/A', 'h_index' => 'N/A', 'i10_index' => 'N/A' }
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
        JSON.parse(File.read(cache_file))
      rescue
        nil
      end
    end

    def write_cache(cache_file, metrics)
      File.write(cache_file, metrics.to_json)
    end

    def fetch_metrics_from_scholar(scholar_id)
      profile_url = "https://scholar.google.com/citations?user=#{scholar_id}&hl=en"
      html = URI.open(profile_url, "User-Agent" => user_agent).read

      # Try robust extractions
      citations = extract_citations(html)
      h_index = extract_simple_metric(html, /h-index\s*(\d+)/)
      i10_index = extract_simple_metric(html, /i10-index\s*(\d+)/)

      per_year = extract_per_year_citations(html)

      {
        'citations' => format_citations(citations),
        'h_index' => h_index || '0',
        'i10_index' => i10_index || '0',
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
  end
end


