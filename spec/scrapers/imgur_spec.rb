=begin rdoc

= IMGUR_SPEC.RB

*Author*::      Tamara Temple <tamara@tamaratemple.com>
*Since*::       2013-05-27
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
=end

require 'spec_helper'

module Scrapers

  describe "Scrapers" do
    it {Scrapers.should respond_to(:imgur)}
  end

  describe "Fetch the download link" do
    let(:url) {"http://imgur.com/v70StgA"}

    it "should return the download link from a given url" do
      Scrapers.imgur(url).should =~ %r{http://imgur.com/download/v70StgA/}
    end

  end
  


end
