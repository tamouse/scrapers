require 'mechanize'

Dir[File.join(File.expand_path('../', __FILE__),'**','*.rb')].each {|file| require file}

module Scrapers
  def self.agent()
    @agent ||= Mechanize.new
  end
end
