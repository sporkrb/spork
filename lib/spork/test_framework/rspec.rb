require 'rspec/core/version'

class Spork::TestFramework::RSpec < Spork::TestFramework
  DEFAULT_PORT = 8989
  if ::RSpec::Core::Version::STRING =~ /^3\./
    HELPER_FILE = File.join(Dir.pwd, "spec/rails_helper.rb")
  else
    HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")
  end

  def run_tests(argv, stderr, stdout)
    if rspec3? || rspec2_99?
      options = ::RSpec::Core::ConfigurationOptions.new(argv)
      ::RSpec::Core::Runner.new(options).run(stderr, stdout)
    else
      ::RSpec::Core::CommandLine.new(argv).run(stderr, stdout)
    end
  end

  def rspec3?
    return false if !defined?(::RSpec::Core::Version::STRING)
    ::RSpec::Core::Version::STRING =~ /^3\./
  end

  def rspec2_99?
    return false if !defined?(::RSpec::Core::Version::STRING)
    ::RSpec::Core::Version::STRING =~ /^2\.99\./
  end
end
