class Spork::Server::Cucumber < Spork::Server
  CUCUMBER_PORT = 8990
  CUCUMBER_HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")
  
  def self.port
    CUCUMBER_PORT
  end
  
  def self.helper_file
    CUCUMBER_HELPER_FILE
  end
  
  def run_tests(argv, stderr, stdout)
    require 'cucumber/cli/main'
    Cucumber::Cli::Main.new(argv, stderr, stdout).execute!(self)
  end
end
