=begin rdoc

= DOWNLOAD_SPEC.RB

*Author*::      Tamara Temple <tamara@tamaratemple.com>
*Since*::       2013-05-27
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
=end

require 'spec_helper'
require 'tmpdir'

module Scrapers

  describe Download do
    it {Scrapers::Download.should respond_to :download}

    context "download" do
      let(:url) {"http://imgur.com/download/v70StgA/%2Asnrrrrrrrrrrrf%21%2A"}
      Dir.mktmpdir do |dir|
        let(:file) do
          VCR.use_cassette("#{example.description.gsub(/^[-[:alnum:]]+/,'')}.cassette") do
            file = Scrapers::Download.download(url)
          end
        end
        
        it "saves the file" do
          file.should =~ /.*snrrrrrrrrrrrf.*Imgur\.jpg/
          File.exist?(file).should be_true
        end
      end
    end
    
  end

end
