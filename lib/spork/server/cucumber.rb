class Spork::Server::Cucumber < Spork::Server
  CUCUMBER_PORT = 8990
  CUCUMBER_HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")
  
  class << self
    def port
      CUCUMBER_PORT
    end
    
    def helper_file
      CUCUMBER_HELPER_FILE
    end
  end
  
  def run_tests(argv, stderr, stdout)
    require 'cucumber/cli/main'
    ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(::Cucumber::StepMother.new)
  end
end
