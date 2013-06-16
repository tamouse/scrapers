=begin rdoc

= DOWNLOAD_SPEC.RB

*Author*::      Tamara Temple <tamara@tamaratemple.com>
*Since*::       2013-05-27
*Copyright*::   (c) 2013 Tamara Temple Web Development
*License*::     MIT
  
=end

require 'spec_helper'

module Scrapers

  describe Download do
    let(:download_dir) {"tmp"}
    before do
      FileUtils.mkdir_p(download_dir) unless File.exists?(download_dir)
    end
    let(:url) {"http://imgur.com/download/v70StgA/%2Asnrrrrrrrrrrrf%21%2A"}
    it { Scrapers::Download.should respond_to(:download)}
    it "saves the file" do
      file = Scrapers::Download.download(url, download_dir)
      file.should =~ /#{download_dir}\/.*snrrrrrrrrrrrf.*Imgur\.jpg/
      File.exist?(file).should be_true
      File.unlink(file) if File.exist?(file)
    end
  end

end
