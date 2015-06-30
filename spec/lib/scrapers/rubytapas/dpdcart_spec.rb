require 'spec_helper'
require 'support/use_vcr'
require 'scrapers/rubytapas/dpdcart'
require 'nokogiri'

describe Scrapers::RubyTapas::DpdCart do
  let(:gateway) { Scrapers::RubyTapas::DpdCart.new }

  describe "method signatures" do
    it { is_expected.to respond_to(:feed!) }
    it { is_expected.to respond_to(:login!)}
    it { is_expected.to respond_to(:download!)}
  end

  describe "#feed!" do
    it "returns an rss feed" do
      VCR.use_cassette('rubytapas_feed', record: :new_episodes,
                       match_requests_on: [:method, :host, :path]
                      ) do
        expect(Nokogiri::XML.parse(gateway.feed!)).to be_a(Nokogiri::XML::Document)
      end
    end
  end

  describe "#login!" do
    it "shows the subscriber content page" do
      VCR.use_cassette('rubytapas_login', record: :new_episodes,
                       match_requests_on: [:method, :host, :path]
                      ) do
        expect(gateway.login!.page.title).to eq("Subscription Content | RubyTapas")
      end
    end
  end


  describe "#download!" do
    let(:file) { "https://rubytapas.dpdcart.com/subscriber/download?file_id=26" }
    let(:name) { "001-binary-literals.html" }

    let(:file2){ "https://rubytapas.dpdcart.com/subscriber/download?file_id=27" }
    let(:name2) { "001-binary-literals.rb" }

    it "returns the downloaded file" do
      VCR.use_cassette('rubytapas_download', record: :new_episodes,
                       match_requests_on: [:method, :host, :path,
                                           :query]) do
        gateway.login!
        filename, body = gateway.download! file
        expect(filename).to eq(name)
        expect(body.size).to eq(5744)
      end
    end

    it "can download multiple files with a single login" do
      VCR.use_cassette('rubytapas_download_twice', record: :new_episodes,
                       match_requests_on: [:method, :host, :path,
                                           :query]) do
        gateway.login!
        filename, body = gateway.download! file
        expect(filename).to eq(name)
        filename, body = gateway.download! file2
        expect(filename).to eq(name2)
      end
    end

  end

end
