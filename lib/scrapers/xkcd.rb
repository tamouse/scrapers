require 'open-uri'
require 'nokogiri'

module Scrapers
  module Xkcd
    XKCD_URL = "http://xkcd.com"
    def self.scrape(comic=nil)
      results = Hash.new

      url = URI.parse XKCD_URL
      url.path = "/#{comic}/" unless comic.nil?
      results[:url] = url.to_s
      doc = Nokogiri::HTML(open(url.to_s))
      comic = doc.at_css("#comic img")
      results[:img_src] = comic.attr("src")
      results[:hover_text] = comic.attr("title")
      results[:title] = comic.attr("alt")

      results
    end
    
  end
end
