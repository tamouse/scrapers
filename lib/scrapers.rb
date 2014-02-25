require 'mechanize'
require 'uri'
Dir[File.join(File.expand_path('../', __FILE__),'**','*.rb')].each {|file| require file}

module Scrapers
  def self.agent()
    @agent ||= Mechanize.new
  end

  def self.base(url)
    u = URI.parse(url)
    u.path=''
    u.to_s
  end

end
