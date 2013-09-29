require 'mechanize'


module Scrapers

  module GoComics

    GOCOMIC_URL = "http://www.gocomics.com/"
    
    def self.scrape(comic)

      results = Hash.new

      url = URI.parse GOCOMIC_URL
      url.path = (comic[0,1] == ?/) ? comic : ?/ + comic # absolutize
      # the comic string

      Scrapers.agent.get(url).tap do |page|
        results[:url] = page.uri.to_s
        results[:title] = page.title.gsub(/[[:space:]]+/,' ').strip
        results[:pubdate] = scrape_pubdate(page)
        results[:img_src] = scrape_image_source(page)
      end

      results

    end

    def self.scrape_pubdate(page)
      Date.parse(page.
                 search("ul.feature-nav > li").first.
                 children.first.
                 text).to_s
    end

    def self.scrape_image_source(page)
      page.
        search("p.feature_item").
        search("img").first.
        attribute("src").value
    end

  end

end
