class Spork::Server::RSpec < Spork::Server
  RSPEC_PORT = 8989
  RSPEC_HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")
  
  def self.port
    RSPEC_PORT
  end
  
  def self.helper_file
    RSPEC_HELPER_FILE
  end
  
  def run_tests(argv, stderr, stdout)
    ::Spec::Runner::CommandLine.run(
      ::Spec::Runner::OptionParser.parse(
        argv,
        stderr,
        stdout
      )
    )
  end
end
