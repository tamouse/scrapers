require 'mechanize'

module Scrapers
  module Sinfest
    SINFEST_URL = "http://sinfest.net"
    
    def self.scrape
      results = Hash.new
      results[:comic] = 'Sinfest'
      results[:url] = SINFEST_URL
      Mechanize.start do |agent|
        agent.get SINFEST_URL
        agent.current_page.image(src: %r{comikaze/comics}).tap do |comic|
          results[:title] = comic.alt.to_s
          results[:img_src] = comic.src.to_s
          comicdate = Date.parse(File.basename(comic.src.to_s,'.gif'))
          pubdate = Time.utc(comicdate.year,comicdate.month,comicdate.day)
          results[:pubdate] = pubdate.to_s
        end
      end
      results.tap{|t| $stderr.puts "DEBUG: #{caller(0,1).first} results #{t.inspect}"}
    end
  end
end
