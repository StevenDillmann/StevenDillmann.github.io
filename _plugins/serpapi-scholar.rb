require 'open-uri'
require 'json'

# Google Scholar via SerpApi (https://serpapi.com/google-scholar-author-api).
# Scholar blocks most GitHub servers, so when SERPAPI_KEY is set (a GitHub secret in
# update-scholar.yml) the Scholar plugins fetch through SerpApi and only fall back to
# reading Scholar directly if it fails. Without the key they read Scholar directly.
module SerpApiScholar
  BASE_URL = "https://serpapi.com/search.json"
  PAGE_SIZE = 100

  module_function

  def enabled?
    !api_key.empty?
  end

  def api_key
    ENV['SERPAPI_KEY'].to_s.strip
  end

  # One page of the author profile (stats, per-year graph, articles). Cached per build so
  # the metrics and publications plugins share the first request.
  def author_page(scholar_id, start = 0)
    @pages ||= {}
    @pages[[scholar_id, start]] ||= request(
      engine: 'google_scholar_author', author_id: scholar_id, hl: 'en',
      sort: 'pubdate', num: PAGE_SIZE, start: start
    )
  end

  # Full details for one paper (complete author list, publisher link).
  def citation(citation_id)
    request(engine: 'google_scholar_author', view_op: 'view_citation', citation_id: citation_id, hl: 'en')&.dig('citation')
  end

  def request(params)
    url = "#{BASE_URL}?#{URI.encode_www_form(params.merge(api_key: api_key))}"
    data = JSON.parse(URI.open(url, read_timeout: 60).read)
    if data['error']
      puts "SerpApi error: #{data['error']}"
      return nil
    end
    data
  rescue => e
    # Avoid printing the URL: it contains the API key
    puts "SerpApi request failed: #{e.class}"
    nil
  end
end
