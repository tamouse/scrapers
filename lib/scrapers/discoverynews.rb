=begin rdoc

= DISCOVERYNEWS.RB

*Author*::      Tamara Temple <tamouse@gmail.com>
*Since*::       2013-06-15
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
Scraper for disco news pictures of the week

=end

require 'mechanize'
 
module Scrapers

  module DiscoNews

    def self.disco_downloads(url)
      @url = url.clone
      @agent = Mechanize.new
      @page = @agent.get(url)
      images = @page.images_with(:class => "media-hero").map(&:src)
    end

  end
  
end
