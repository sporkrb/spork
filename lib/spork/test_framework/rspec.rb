class Spork::TestFramework::RSpec < Spork::TestFramework
  DEFAULT_PORT = 8989
  HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")

  def run_tests(argv, stderr, stdout)
    case
    when rspec1?
      ::Spec::Runner::CommandLine.run(
        ::Spec::Runner::OptionParser.parse(argv, stderr, stdout)
      )
    when /^2/ =~ ::RSpec::Version::STRING
      ::RSpec::Core::CommandLine.new(argv).run(stderr, stdout)
    else
      options = ::RSpec::Core::ConfigurationOptions.new(argv)
      ::RSpec::Core::Runner.new(options).run(stderr, stdout)
    end
  end

  def rspec1?
    defined?(Spec) && !defined?(RSpec)
  end
end
