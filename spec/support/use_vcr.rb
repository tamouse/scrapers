# Only include this in tests that actally use VCR.
# Better for unit tests to read saved data or use mocks.

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
end
