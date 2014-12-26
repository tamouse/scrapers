require 'spec_helper'
require 'support/dir_helpers'
require 'scrapers/rubytapas/episode'
require 'scrapers/rubytapas/downloader'

describe Scrapers::RubyTapas::Downloader do

  describe "#new" do
    let(:episode) {double('dummy episode').as_null_object}
    let(:destination) { "." }
    let(:options) { {} }
    let(:downloader) { Scrapers::RubyTapas::Downloader.new(episode, destination, options)}

    it "has the episode" do
      expect(downloader.episode).to eq(episode)
    end
    it "has the destination" do
      expect(downloader.destination).to eq(destination)
    end
    it "has the options" do
      expect(downloader.options).to eq(options)
    end
  end

  describe "#make_directory" do
    let(:test_slug) { "an-episode-directory" }
    let(:test_real_path) { "/a/real/path" }
    let(:test_dir) { File.join(test_real_path, test_slug) }
    let(:episode) {double('dummy episode').as_null_object}
    let(:destination) { "." }
    let(:downloader) { Scrapers::RubyTapas::Downloader.new(episode, destination)}

    it "builds a directory" do
      expect(episode).to receive(:slug).and_return(test_slug)
      expect(File).to receive(:realpath).with(destination).and_return(test_real_path)
      expect(FileUtils).to receive(:mkdir).with(test_dir).and_return(Array(test_dir))
      expect(downloader.make_directory).to eq(test_dir)
    end
  end

  describe "#download!" do
    
    let(:number) { 1 }
    let(:title)  { "001 Binary Literals" }
    let(:slug)   { "001-binary-literals" }
    let(:file_list) do
      [
        Scrapers::RubyTapas::Episode::FileLink.new("RubyTapas001.mp4",
          "https://rubytapas.dpdcart.com/subscriber/download?file_id=25"),
        Scrapers::RubyTapas::Episode::FileLink.new("001-binary-literals.html",
          "https://rubytapas.dpdcart.com/subscriber/download?file_id=26"),
        Scrapers::RubyTapas::Episode::FileLink.new("001-binary-literals.rb",
          "https://rubytapas.dpdcart.com/subscriber/download?file_id=27")
      ]
    end
    let(:filename_list) do
      file_list.map(&:filename)
    end
    let(:episode) do
      double('test-episode',
        number: number,
        title: title,
        slug: slug,
        file_list: file_list
      )
    end
    let(:destination) { "." }
    let(:agent) {double('remote-client').as_null_object}
    let(:file)  {double('remote-file').as_null_object}
    let(:downloader) { Scrapers::RubyTapas::Downloader.new(episode, destination)}
    let(:output) { double('standard out').as_null_object}

    before do
      allow(downloader).to receive(:with_remote_client).and_yield(agent)
    end

    it "download the list of files from each episode" do
      run_in_tmpdir do |d|
        expect(downloader).to receive(:download_file).exactly(file_list.size).times.and_call_original
        expect(agent).to receive(:get).exactly(file_list.size).times.and_return(file)
        expect(file).to receive(:filename=).exactly(file_list.size).times
        expect(file).to receive(:filename).exactly(file_list.size).times.and_return(*filename_list)
        expect(file).to receive(:save!).exactly(file_list.size).times

        expect(output).to receive(:puts).with(%r{\ADownloading #{title} to .*/#{slug}\z})
        file_list.each do |file_item|
          expect(output).to receive(:puts).with(%r{\ASaving #{file_item.filename}\z}).once
        end

        save_stdout = $stdout
        $stdout = output
        downloader.download!
        $stdout = save_stdout
      end
    end

  end
end
