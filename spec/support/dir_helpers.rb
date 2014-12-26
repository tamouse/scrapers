require 'tempfile'
require 'tmpdir'

def run_under_tmpdir(&block)
  raise "no block given" unless block_given?
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do |dir|
      yield dir
    end
  end
end

alias :run_in_tmpdir :run_under_tmpdir
