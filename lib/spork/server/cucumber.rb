class Spork::Server::Cucumber < Spork::Server
  CUCUMBER_PORT = 8990
  CUCUMBER_HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")
  
  def self.port
    CUCUMBER_PORT
  end
  
  def self.helper_file
    CUCUMBER_HELPER_FILE
  end
  
  def self.step_mother=(value)
    @step_mother = value
  end
  
  def run_tests(argv, stderr, stdout)
    require 'cucumber/cli/main'
    ::Cucumber::Cli::Main.step_mother = @step_mother
    ::Cucumber::Cli::Main.new(argv, stderr, stdout).execute!(@step_mother)
  end
end

Spork::Server::Cucumber.step_mother = self