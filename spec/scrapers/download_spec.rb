require 'spec_helper'
require "scrapers/download"
require 'tmpdir'

def in_tmpdir
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do |dir|
      yield dir
    end
  end
end


module Scrapers

  describe Download do

    it {Scrapers::Download.should respond_to :download}

    it "should download and save the file" do
      in_tmpdir do |dir|
        @url="http://imgur.com/download/v70StgA/%2Asnrrrrrrrrrrrf%21%2A"
        VCR.use_cassette("download.cassette") do
          @file = Scrapers::Download.download(@url,dir)
        end
        @file.should =~ /.*snrrrrrrrrrrrf.*Imgur\.jpg/
        File.exist?(@file).should be true
      end
    end
    it "should overwrite file with second download" do
      in_tmpdir do |dir|
        @url="http://imgs.xkcd.com/comics/sandwich.png"
        VCR.use_cassette("download-overwrite") do
          @file1 = Scrapers::Download.download(@url,dir)
          @file2 = Scrapers::Download.download(@url,dir,true)
        end
        @file1.should eq @file2
        @file1.should eq File.join(dir,'sandwich.png')
        File.exist?(@file1).should be true
      end
    end
    it "should make a new file on second download" do
      in_tmpdir do |dir|
        @url="http://imgs.xkcd.com/comics/sandwich.png"
        VCR.use_cassette("download-newfile") do
          @file1 = Scrapers::Download.download(@url,dir)
          @file2 = Scrapers::Download.download(@url,dir)
        end

        # Filed issue against mechanise to make save return
        # the actual file name saved under. Until that's fixed
        # have to work around it.
        @file2 += '.1'

        @file1.should_not eq @file2
        @file1.should eq File.join(dir,'sandwich.png')
        File.exist?(@file1).should be true
        @file2.should eq File.join(dir,'sandwich.png.1')
        File.exist?(@file2).should be true
      end
    end
  end
end
