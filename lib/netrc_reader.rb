require 'netrc'

module Scrapers
  class NetrcReader
    attr_accessor :user, :pw

    def initialize(section)
      netrc = Netrc.read
      @user, @pw = netrc[section]
    rescue NoMethodError => e
      fail "Could not find credentials for #{section}"
    end
  end
end
