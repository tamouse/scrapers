=begin rdoc

= DOWNLOAD.RB

*Author*::      Tamara Temple <tamara@tamaratemple.com>
*Since*::       2013-05-27
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
=end

require 'mechanize'

module Scrapers

  module_function

  def download(url,dir=".")
    @agent = Mechanize.new
    @agent.pluggable_parser.default = Mechanize::Download
    @dir = validate_directory(download_dir)
    dl = @agent.get(url)
    Dir.chdir(@dir) do |dir|
      dl.save()
    end
    File.join(@dir,dl.filename)
  end

  private

  def validate_directory(d)
    raise "#{d} is not a writable directory!" unless File.directory?(d) and File.writable?(d)
    d
  end

end
 
