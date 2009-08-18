class Spork::TestFramework::Cucumber < Spork::TestFramework
  DEFAULT_PORT = 8990
  HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")

  class << self
    # REMOVE WHEN SUPPORT FOR 0.3.95 AND EARLIER IS DROPPED
    attr_accessor :mother_object
  end

  def preload
    require 'cucumber'
    begin
      @step_mother = ::Cucumber::StepMother.new
      @step_mother.load_programming_language('rb')
    rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
      @step_mother = Spork::Server::Cucumber.mother_object
    end
    super
  end

  def run_tests(argv, stderr, stdout)
    ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(@step_mother)
  end
end
