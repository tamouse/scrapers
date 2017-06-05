#!/usr/bin/env ruby

# fbs runs these single page at a time galleries, which are slow,
# annoying, and just to crank up the page views. There's often little
# value in then content.

# Pages were pre-grabbed with:

# output = "page-%02d.html"
# agent = "Mozilla 5.0"
# url_base = "...../ten-unmistakable-signs-of-a-cheap-employer/%d/"

# (1..11).each do |i|
#   cmd = "lynx -source -useragent='#{agent}' #{url_base % i} > #{output % i}"
#   puts "Sending cmd: #{cmd}"
#   system cmd
# end

require "nokogiri"
require "logger"
L = Logger.new(STDERR)

INPUT_DIR = File.expand_path('../../tmp/', __FILE__)
INPUT_FILE_GLOB_PATTERN = "page-*.html"
INPUT_FILES = Dir[File.join(INPUT_DIR, INPUT_FILE_GLOB_PATTERN)]

L.debug "Input files: #{INPUT_FILES.join(",")}"

TARGET_SELECTOR = '.articleContentText'

important_stuff = INPUT_FILES.map do |f|
  doc = Nokogiri::HTML.parse(File.read(f))
  article = doc.at_css(TARGET_SELECTOR)
  paragraphs = article.css('p')
  text = paragraphs.reject do |par|
    par.text.match(/Continue/) || par.text.empty?
  end.compact.join("\n").tap{|t| L.info t}
end.compact.join("\n\n")

puts important_stuff
