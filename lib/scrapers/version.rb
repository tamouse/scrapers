module Scrapers
  module Version

    MAJOR = 1
    MINOR = 5
    BUILD = 4

  end
  
  VERSION = [Version::MAJOR,Version::MINOR,Version::BUILD].map(&:to_s).join(".")

  DESCRIPTION = "A library of web site scrapers utilizing mechanize and other goodies. Helpful in gathering images, moving things, saving things, etc."
  SUMMARY = "Web site scrapers"
  LICENSE = "MIT"
  WEBSITE = "http://github.com/tamouse/scrapers"
end
