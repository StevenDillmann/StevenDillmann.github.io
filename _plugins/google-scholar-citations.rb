require "active_support/all"
require 'nokogiri'
require 'open-uri'
require 'json'
require 'fileutils'

module Helpers
  extend ActiveSupport::NumberHelper
end

module Jekyll
  class GoogleScholarCitationsTag < Liquid::Tag
    Citations = { }
    CACHE_TTL_SECONDS = 24 * 60 * 60  # 24 hours

    def initialize(tag_name, params, tokens)
      super
      splitted = params.split(" ").map(&:strip)
      @scholar_id = splitted[0]
      @article_id = splitted[1]

      if @scholar_id.nil? || @scholar_id.empty?
        puts "Invalid scholar_id provided"
      end

      if @article_id.nil? || @article_id.empty?
        puts "Invalid article_id provided"
      end
    end

    def render(context)
      article_id = context[@article_id.strip]
      scholar_id = context[@scholar_id.strip]
      article_url = "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=#{scholar_id}&citation_for_view=#{scholar_id}:#{article_id}"

      # Check persistent cache first
      cached_count = read_from_cache(article_id)
      if cached_count
        return cached_count
      end

      # Check in-memory cache
      if GoogleScholarCitationsTag::Citations[article_id]
        return GoogleScholarCitationsTag::Citations[article_id]
      end

      begin
          # Sleep for a random amount of time to avoid being blocked
          sleep(rand(1.5..3.5))

          # Fetch the article page
          doc = Nokogiri::HTML(URI.open(article_url, "User-Agent" => "Ruby/#{RUBY_VERSION}"))

          # Attempt to extract the "Cited by n" string from the meta tags
          citation_count = 0

          # Look for meta tags with "name" attribute set to "description"
          description_meta = doc.css('meta[name="description"]')
          og_description_meta = doc.css('meta[property="og:description"]')

          if !description_meta.empty?
            cited_by_text = description_meta[0]['content']
            matches = cited_by_text.match(/Cited by (\d+[,\d]*)/)

            if matches
              citation_count = matches[1].sub(",", "").to_i
            end

          elsif !og_description_meta.empty?
            cited_by_text = og_description_meta[0]['content']
            matches = cited_by_text.match(/Cited by (\d+[,\d]*)/)

            if matches
              citation_count = matches[1].sub(",", "").to_i
            end
          end

        citation_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })

      rescue Exception => e
        # Handle any errors that may occur during fetching
        citation_count = "N/A"

        # Print the error message including the exception class and message
        puts "Error fetching citation count for #{article_id} in #{article_url}: #{e.class} - #{e.message}"
      end

      # Store in both caches
      GoogleScholarCitationsTag::Citations[article_id] = citation_count
      write_to_cache(article_id, citation_count)
      
      return "#{citation_count}"
    end

    private

    def cache_file_path(article_id)
      File.join("_cache", "paper_citations_#{article_id}.json")
    end

    def read_from_cache(article_id)
      cache_file = cache_file_path(article_id)
      return nil unless File.exist?(cache_file)
      
      begin
        # Check if cache is still valid (within 24 hours)
        return nil if (Time.now - File.mtime(cache_file)) >= CACHE_TTL_SECONDS
        
        data = JSON.parse(File.read(cache_file))
        return data['citation_count']
      rescue
        nil
      end
    end

    def write_to_cache(article_id, citation_count)
      cache_file = cache_file_path(article_id)
      FileUtils.mkdir_p(File.dirname(cache_file))
      
      begin
        data = {
          'citation_count' => citation_count,
          'cached_at' => Time.now.utc.iso8601
        }
        File.write(cache_file, data.to_json)
      rescue => e
        puts "Error writing cache for #{article_id}: #{e.message}"
      end
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
