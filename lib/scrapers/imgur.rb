=begin rdoc

= IMGUR.RB

*Author*::      Tamara Temple <tamara@tamaratemple.com>
*Since*::       2013-05-27
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
=end

 
require 'mechanize'

module Scrapers

  IMGUR_TEMPLATE="http://imgur.com/path"
  
  class Imgur

    attr_accessor :agent, :url, :download, :page

    def initialize
      @agent = Mechanize.new
      @url = URI.parse(IMGUR_TEMPLATE)
      @download = URI.parse(IMGUR_TEMPLATE)
    end

    def download_link(code)
      make_url(code)
      retrieve_page()
      find_download()
      @download.to_s
    end

    def make_url(imgur_code)
      @url.path = "/#{imgur_code}"
    end

    def retrieve_page()
      @page = @agent.get(@url.to_s)
    end

    def find_download(link_text=/Download/)
      link = @page.link_with(:text => link_text)
      raise "#{link_text} not found on #{@page.uri.to_s}" if link.nil?
      @download.path = link.href
    end

  end

  module_function

  def imgur(url)
    code = File.basename(url).sub(/\.[^.]+$/,'')
    "http://imgur.com/download/#{code}/"
  end
  
end 
