require 'open-uri'
require 'nokogiri'

module Scrapers
  module Xkcd
    XKCD_URL = "http://xkcd.com"
    PUBDATE_FORMAT = "%F"

    # Get the current or numbered xkcd comic
    #
    # +comic+ = (string) the number of the xkcd comic to
    #retreive. Gets current comic if nil.
    #
    # returns hash containing comic info:
    #
    #      {:title => "comic' title",
    #       :url => "url to comic",
    #       :img_src => "source url to comic image",
    #       :hover_text => "the hover (mouse-over) text",
    #       :pubdate => "publication date",
    #      }
    #
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
      results[:pubdate] = get_pubdate(results[:img_src])

      results
    end

    # Get the http header of the image file which reveals the last_modified date.
    # We'll use this as the publication date.
    def self.get_pubdate(url)
      url = URI.parse(url.dup)
      head_req = Net::HTTP::Head.new url
      
      head = Net::HTTP.start(url.host, url.port) do |http|
        http.request head_req
      end
      return Time.now.strftime(PUBDATE_FORMAT) if head["Last-Modified"].nil?
      last_modified = Time.parse(head["Last-Modified"]) rescue nil
      return Time.now.strftime(PUBDATE_FORMAT) if last_modified.nil?
      last_modified.strftime(PUBDATE_FORMAT)
    end
    
  end
end
