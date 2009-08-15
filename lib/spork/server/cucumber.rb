require 'cucumber'

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

    # REMOVE WHEN SUPPORT FOR 0.3.95 AND EARLIER IS DROPPED
    attr_accessor :step_mother
  end

  # REMOVE WHEN SUPPORT FOR 0.3.95 AND EARLIER IS DROPPED
  def step_mother
    self.class.step_mother
  end

  def run_tests(argv, stderr, stdout)
    ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(step_mother)
  end
end

begin
  step_mother = ::Cucumber::StepMother.new
  Spork::Server::Cucumber.step_mother = step_mother
rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR 0.3.95 AND EARLIER IS DROPPED
  Spork::Server::Cucumber.step_mother = self
end