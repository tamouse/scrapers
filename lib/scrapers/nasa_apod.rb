=begin rdoc

nasa_apod.rb -- oneline desc

Time-stamp: <2013-07-31 01:20:07 tamara>
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
  
  class NasaApod

    attr_accessor :url

    def initialize(url)
      @url = url
    end



    def scrape()
      return Hash.new if @url.nil?
    end

  end
  
end
