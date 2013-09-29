require 'open-uri'
require 'nokogiri'


module Scrapers

  module GoComics

    GOCOMIC_URL = "http://www.gocomics.com/"
    
    def self.scrape(comic)

      results = Hash.new

      results[:comic] = comic

      url = URI.parse GOCOMIC_URL
      url.path = "/#{comic}"

      results[:url] = url.to_s

      page = Nokogiri::HTML(open(url.to_s))

      results[:title] = scrape_title(page)
      results[:pubdate] = scrape_pubdate(page)
      results[:img_src] = scrape_image_source(page)

      results

    end

    def self.scrape_title(page)
      page.at_css("title").content.strip.gsub(/[[:space:]]/,' ').squeeze(" ")
    end

    def self.scrape_pubdate(page)
      Date.parse(page.at_css("ul.feature-nav > li").content).to_s
    end

    def self.scrape_image_source(page)
      page.
        at_css("p.feature_item").
        at_css("img").
        attr("src")
    end

  end

end
