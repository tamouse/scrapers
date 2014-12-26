require 'spec_helper'
require 'scrapers/rubytapas/episode'

describe Scrapers::RubyTapas::Episode do

  let(:number) { "001" }
  let(:title)  { "001 Binary Literals" }
  let(:slug)   { "001-binary-literals" }
  let(:link)   { "https://rubytapas.dpdcart.com/subscriber/post?id=18" }
  let(:description) {<<-DESC
<div class="blog-entry">
<div class="blog-content"><p>In this inaugural episode, a look at a handy syntax for writing out binary numbers.</p>
</div>
<h3>Attached Files</h3>
<ul>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=25">RubyTapas001.mp4</a></li>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=26">001-binary-literals.html</a></li>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=27">001-binary-literals.rb</a></li>
</ul></div>
DESC
  }
  let(:guid)  { "dpd-89e8004c8242e7ad548833bef1e18a5b575c92c1" }
  let(:pub_date) { DateTime.new(2012,9,24,9,0,0,'-4') }
  let(:file_list) do
    [
      Scrapers::RubyTapas::Episode::FileLink.new("RubyTapas001.mp4", "https://rubytapas.dpdcart.com/subscriber/download?file_id=25"),
      Scrapers::RubyTapas::Episode::FileLink.new("001-binary-literals.html", "https://rubytapas.dpdcart.com/subscriber/download?file_id=26"),
      Scrapers::RubyTapas::Episode::FileLink.new("001-binary-literals.rb", "https://rubytapas.dpdcart.com/subscriber/download?file_id=27")
    ]
  end

  let(:xml_string) do
    <<-ITEM
<item>
<title><![CDATA[001 Binary Literals]]></title>
<link>https://rubytapas.dpdcart.com/subscriber/post?id=18</link>
<description><![CDATA[<div class="blog-entry">
<div class="blog-content"><p>In this inaugural episode, a look at a handy syntax for writing out binary numbers.</p>
</div>
<h3>Attached Files</h3>
<ul>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=25">RubyTapas001.mp4</a></li>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=26">001-binary-literals.html</a></li>
<li><a href="https://rubytapas.dpdcart.com/subscriber/download?file_id=27">001-binary-literals.rb</a></li>
</ul></div>]]></description>
<guid isPermaLink="false">dpd-89e8004c8242e7ad548833bef1e18a5b575c92c1</guid>
<pubDate>Mon, 24 Sep 2012 09:00:00 -0400</pubDate>
<enclosure url="https://rubytapas.dpdcart.com/feed/download/25/RubyTapas001.mp4" length="12502397" type="video/mp4"/>
<itunes:image href="https://getdpd.com/uploads/ruby-tapas.png"/>
</item>
ITEM
  end

  let(:xml_item) do
    Nokogiri::XML.parse(xml_string) {|c| c.noblanks }.children.first
  end

  describe "#initialize" do

    shared_examples "initialize episode" do
      it "is episode number 001" do
        expect(episode.number).to eq(number)
      end

      it "is episode '001 Binary Literals'" do
        expect(episode.title).to eq(title)
      end

      it "has slug" do
        expect(episode.slug).to eq(slug)
      end

      it "has link" do
        expect(episode.link).to eq(link)
      end

      it "has guid" do
        expect(episode.guid).to eq(guid)
      end

      it "has publication date" do
        expect(episode.pub_date).to eq(pub_date)
      end

      it "has file list" do
        expect(episode.file_list).to match_array(file_list)
      end
      
    end

    context "when given an xml string" do
      include_examples "initialize episode" do
        let(:episode) {Scrapers::RubyTapas::Episode.new(xml_string)}
      end

    end

    context "when given a Nokogiri::XML::Element" do
      include_examples "initialize episode" do
        let(:episode) {Scrapers::RubyTapas::Episode.new(xml_item)}
      end
    end

    context "when given a Hash" do
      include_examples "initialize episode" do
        let(:episode) do
          Scrapers::RubyTapas::Episode.new(
            :number => number,
            :title => title,
            :slug => slug,
            :link => link,
            :description => description,
            :guid => guid,
            :pub_date => pub_date,
            :file_list => file_list
          )
        end
      end
    end

    context "when given a list of arguments" do
      include_examples "initialize episode" do
        let(:episode) do
          Scrapers::RubyTapas::Episode.new(
            number,
            title,
            slug,
            link,
            description,
            guid,
            pub_date,
            file_list
          )
        end
      end
    end

  end
end

