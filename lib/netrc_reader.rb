require 'netrc'

module Scrapers  
  class NetrcReader
    attr_accessor :user, :pw

    def initialize(section)
      netrc = Netrc.read
      @user, @pw = netrc[section]      
    end
  end
end
