require 'cucumber'

class Spork::Server::Cucumber < Spork::Server
  CUCUMBER_PORT = 8990
  CUCUMBER_HELPER_FILE = File.join(Dir.pwd, "features/support/env.rb")

  class << self
    def port
      (ENV['CUCUMBER_DRB'] || CUCUMBER_PORT).to_i
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
      ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(::Cucumber::StepMother.new)
    rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
      ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!(step_mother)
    end
  end
end

begin
  step_mother = ::Cucumber::StepMother.new
  step_mother.load_rb_language
  Spork::Server::Cucumber.step_mother = step_mother
rescue NoMethodError => pre_cucumber_0_4 # REMOVE WHEN SUPPORT FOR PRE-0.4 IS DROPPED
  Spork::Server::Cucumber.step_mother = self
end
