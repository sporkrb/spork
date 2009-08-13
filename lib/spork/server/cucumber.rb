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

    # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
    attr_accessor :step_mother
  end

  # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
  def step_mother
    self.class.step_mother
  end

  def run_tests(argv, stderr, stdout)
    begin
      require 'cucumber/cli/main'
      ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(::Cucumber::StepMother.new)
    rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
      ::Cucumber::Cli::Main.step_mother = step_mother
      ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(step_mother)
    end
  end
end

Spork::Server::Cucumber.step_mother = self # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED