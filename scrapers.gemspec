# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrapers/version'

Gem::Specification.new do |spec|
  spec.name          = "scrapers"
  spec.version       = Scrapers::VERSION
  spec.authors       = ["Tamara Temple"]
  spec.email         = ["tamouse@gmail.com"]
  spec.description   = Scrapers::DESCRIPTION
  spec.summary       = Scrapers::SUMMARY
  spec.homepage      = Scrapers::WEBSITE
  spec.license       = Scrapers::LICENSE

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize"
  spec.add_dependency "netrc"
  spec.add_dependency "thor"
  spec.add_dependency "activesupport"
  spec.add_dependency "highline"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  
end
