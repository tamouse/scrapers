module Scrapers
  
  module Esod

    module_function

    def scrape(url=nil)
      esod = Hash.new
      Mechanize.start do |m|

        m.get url
        
        m.current_page.tap do |page|
          esod[:title] = page.title.strip
          esod[:link] = page.uri.to_s
          esod[:description] = page.search(".entry-body").first.text
          esod[:pubDate] = page.response['date'].to_s
          esod[:guid] = page.uri.to_s
          esod[:content_encoded] = page.search(".entry-body").first
          esod[:image] = page.image_with(:dom_class => %r{\basset\b}).src
        end

      end
      esod
    end

  end
  
end
