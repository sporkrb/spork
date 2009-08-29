require 'cucumber'

class Spork::TestFramework::Cucumber < Spork::TestFramework
  DEFAULT_PORT = 8990
  HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")

  class << self
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
  Spork::TestFramework::Cucumber.step_mother = ::Cucumber::StepMother.new
  Spork::TestFramework::Cucumber.step_mother.load_programming_language('rb') if defined?(Spork::TestFramework)
rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR 0.3.95 AND EARLIER IS DROPPED
  Spork::TestFramework::Cucumber.step_mother = self
end
