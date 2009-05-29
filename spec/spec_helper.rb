require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your specs to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




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
