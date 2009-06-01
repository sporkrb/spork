require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
SPEC_TMP_DIR = File.dirname(__FILE__) + "/tmp"
require 'spork'
require 'spork/runner.rb'
require 'spork/server.rb'
require 'stringio'

Spec::Runner.configure do |config|
  config.before(:each) do
    $test_stdout = StringIO.new
  end
  
  config.after(:each) do
    FileUtils.rm_rf(SPEC_TMP_DIR)
  end
end
