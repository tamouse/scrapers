require 'mechanize'
require 'uri'

module Scrapers
  def self.agent()
    @agent ||= Mechanize.new
  end

  def self.base_url(url)
    u = URI.parse(url)
    u.path=''
    u.to_s
  end
  alias_method :base, :base_url
end
