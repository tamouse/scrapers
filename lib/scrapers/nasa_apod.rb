=begin rdoc

nasa_apod.rb -- oneline desc

Time-stamp: <2013-07-31 11:00:00 tamara>
Copyright (C) 2013 Tamara Temple Web Development
Author:     Tamara Temple <tamouse@gmail.com>
License:    MIT

== Discussion

NASA's Astronomy Picture of the Day is a great source for nice astro
photos and various other information. But it isn't something I
remember to go see every day, so I'd like it to drop in my in-box or
an evernote notebook. But the feed does not include the image, for
some ungodly reason, so I'm adding a scraper to grab the nice info off
the page including the photo.

=end


module Scrapers
  
  module NasaApod

    module_function

    def scrape(url)
      apod = Hash.new
      unless url.nil?

        Mechanize.start do |m|

          m.get url
        
          # APOD has a funky entry page, but we want the actual page
          prev = m.current_page.link_with(:text => '<').href
          m.get prev
          canonical = m.current_page.link_with(:text => '>' ).href
          m.get canonical

          m.current_page.tap do |page|
            apod[:title] = page.title.strip
            apod[:link] = page.uri.to_s
            apod[:description] = (page/("body")).text
            apod[:pubDate] = page.response['date'].to_s
            apod[:guid] = page.uri.to_s
            apod[:content_encoded] = (page/("body")).to_html            
          end


        end

      end
      
      apod
    end

  end
  
end
