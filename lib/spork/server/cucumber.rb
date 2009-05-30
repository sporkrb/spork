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

    attr_accessor :step_mother
  end
  
  def step_mother
    self.class.step_mother
  end
  
  def run_tests(argv, stderr, stdout)
    require 'cucumber/cli/main'
    ::Cucumber::Cli::Main.step_mother = step_mother
    ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(step_mother)
  end
end

Spork::Server::Cucumber.step_mother = self
