require 'open-uri'
require 'json'
require 'fileutils'
require 'nokogiri'

module Jekyll
  # Generator that fetches the publication list from the Google Scholar profile
  # and exposes it as site.data.scholar_publications
  class GoogleScholarPublicationsGenerator < Generator
    safe true
    priority :low

    CACHE_TTL_SECONDS = 3 * 24 * 60 * 60 # 3 days
    PAGE_SIZE = 100
    DETAIL_DELAY_SECONDS = 2 # pause between per-paper requests to avoid Scholar rate limits

    def generate(site)
      scholar_id = (site.data['socials'] || {})['scholar_userid']&.to_s
      return if scholar_id.nil? || scholar_id.empty?

      cache_file = File.join(site.source, "_cache", "scholar_pubs_#{scholar_id}.json")
      FileUtils.mkdir_p(File.dirname(cache_file))

      pubs = read_cache(cache_file, fresh_only: true)
      unless pubs
        fetched = fetch_publications(scholar_id)
        if fetched && !fetched.empty?
          add_details(fetched, read_cache(cache_file, fresh_only: false) || [])
          File.write(cache_file, JSON.pretty_generate(fetched))
          pubs = fetched
        else
          # If fetch failed, use stale cache as fallback
          pubs = read_cache(cache_file, fresh_only: false)
          puts "Warning: Failed to fetch Scholar publications, using stale cache" if pubs
        end
      end

      pubs ||= []
      assign_topics(pubs, site.data['pub_topics'] || {})
      site.data['scholar_publications'] = pubs
    end

    private

    # Tag each paper with every topic whose keywords appear in its title or venue,
    # plus any manual overrides from _data/pub_topics.yml. Not cached: rules can change anytime.
    def assign_topics(pubs, config)
      topics = config['topics'] || []
      overrides = (config['overrides'] || {}).transform_keys { |t| t.to_s.downcase.strip }
      pubs.each do |pub|
        text = "#{pub['title']} #{pub['venue']}".downcase
        tags = topics.select { |t| Array(t['match']).any? { |kw| text.include?(kw.to_s.downcase) } }.map { |t| t['name'] }
        tags |= Array(overrides[pub['title'].to_s.downcase.strip])
        # Derived topics: `also_when` lists topic combinations that imply this topic
        topics.each do |t|
          next if tags.include?(t['name'])
          tags << t['name'] if Array(t['also_when']).any? { |combo| (Array(combo) - tags).empty? }
        end
        pub['topics'] = topics.map { |t| t['name'] } & tags # keep the configured topic order
      end
    end

    def read_cache(cache_file, fresh_only:)
      return nil unless File.exist?(cache_file)
      return nil if fresh_only && (Time.now - File.mtime(cache_file)) >= CACHE_TTL_SECONDS
      data = JSON.parse(File.read(cache_file))
      data.is_a?(Array) && !data.empty? ? data : nil
    rescue
      nil
    end

    def fetch_publications(scholar_id)
      pubs = []
      cstart = 0
      loop do
        url = "https://scholar.google.com/citations?user=#{scholar_id}&hl=en" \
              "&sortby=pubdate&cstart=#{cstart}&pagesize=#{PAGE_SIZE}"
        html = URI.open(url, headers_for_request).read
        return nil if html.include?("recaptcha")

        rows = Nokogiri::HTML(html).css('tr.gsc_a_tr')
        rows.each { |row| pubs << parse_row(row) }
        break if rows.length < PAGE_SIZE
        cstart += PAGE_SIZE
      end
      pubs.compact
    rescue => e
      puts "Error fetching Google Scholar publications: #{e.class} - #{e.message}"
      nil
    end

    def parse_row(row)
      title_link = row.at_css('a.gsc_a_at')
      return nil unless title_link

      gray = row.css('div.gs_gray')
      year = row.at_css('.gsc_a_y span')&.text.to_s.strip
      venue = gray[1]&.text.to_s.strip
      # Scholar appends ", <year>" to the venue; the year is shown separately
      venue = venue.sub(/,\s*#{Regexp.escape(year)}\z/, '') unless year.empty?

      {
        'id' => title_link['href'][/citation_for_view=([^&]+)/, 1],
        'title' => title_link.text.strip,
        'url' => "https://scholar.google.com#{title_link['href']}",
        'authors' => gray[0]&.text.to_s.strip,
        'venue' => venue,
        'year' => year,
        'citations' => row.at_css('a.gsc_a_ac')&.text.to_s.strip.gsub(',', '').to_i
      }
    end

    # The profile list truncates author lists, so fetch each paper's own Scholar page
    # for the full authors and the publisher link. Papers already in the cache are reused.
    def add_details(pubs, cached)
      known = cached.select { |p| p['details_fetched'] }.to_h { |p| [p['id'], p] }
      pubs.each do |pub|
        if (old = known[pub['id']])
          pub.merge!(old.slice('authors', 'link', 'details_fetched'))
          next
        end

        sleep DETAIL_DELAY_SECONDS
        details = fetch_details(pub['url'])
        pub.merge!(details) if details
      end
    end

    def fetch_details(url)
      html = URI.open(url, headers_for_request).read
      return nil if html.include?("recaptcha")

      doc = Nokogiri::HTML(html)
      fields = doc.css('.gs_scl').to_h do |row|
        [row.at_css('.gsc_oci_field')&.text.to_s.strip, row.at_css('.gsc_oci_value')&.text.to_s.strip]
      end
      authors = fields['Authors'] || fields['Inventors']
      return nil if authors.nil? || authors.empty?

      { 'authors' => authors, 'link' => doc.at_css('#gsc_oci_title a')&.[]('href'), 'details_fetched' => true }
    rescue => e
      puts "Error fetching Scholar details for #{url}: #{e.class} - #{e.message}"
      nil
    end

    def headers_for_request
      {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122 Safari/537.36",
        "Accept-Language" => "en-US,en;q=0.9",
        "Referer" => "https://scholar.google.com/"
      }
    end
  end
end
