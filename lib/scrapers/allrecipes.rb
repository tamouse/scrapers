require 'mechanize'


module Scrapers

  module AllRecipes

    def self.scrape(url)

      results = Hash.new

      Scrapers.agent.get(url).tap do |page|
        results[:url] = page.uri.to_s
        results[:title] = page.title.strip
        results[:ingredients] = scrape_ingredients(page)
        results[:directions] = scrape_directions(page)
        results[:photo] = scrape_photo(page)
      end

      results

    end

    def self.scrape_ingredients(page)
      page.
        search("ul.ingredient-wrap").
        search(".//li").
        map do |i|
        i.text.gsub(/[[:space:]]+/,' ').sub(/^/,'*')
      end
    end

    def self.scrape_directions(page)
      page.
        search("div.directLeft").first.
        search("li").
        map do |i|
        i.text.gsub(/[[:space:]]+/,' ').sub(/^/,'# ')
      end
    end

    def self.scrape_photo(page)
      photo = page.search("img#imgPhoto").first
      Hash[photo.attributes.map{|k,v| [k,v.value]}]
    end

  end

end
