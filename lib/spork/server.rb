require 'drb/drb'
require 'rbconfig'
require 'spork/forker.rb'
require 'spork/custom_io_streams.rb'
require 'spork/app_framework.rb'

# An abstract class that is implemented to create a server
#
# (This was originally based off of spec_server.rb from rspec-rails (David Chelimsky), which was based on Florian Weber's TDDMate)
class Spork::Server
  include Spork::CustomIOStreams
  
  def self.setup_observers
    Spork::EventDispatcher[:work].observe(:start_listening) do |options|
      @instance = new(options).listen
    end
  end

  def self.instance
    @instance
  end
  
  def initialize(options = {})
    @port = options[:port]
    Spork::EventDispatcher[:interrupt].observe(:quit) { |options| quit }
    Spork::EventDispatcher[:interrupt].observe(:restart) { |options| restart }
    if Signal.list.has_key?("USR2")
      trap("USR2") do
        Spork::EventDispatcher[:interrupt].trigger(:abort)
        Spork::EventDispatcher[:interrupt].trigger(:restart)
      end
    end

    trap("SIGTERM") do
      Spork::EventDispatcher[:interrupt].trigger(:abort)
      Spork::EventDispatcher[:interrupt].trigger(:quit)
    end
  end
  
  # Sets up signals and starts the DRb service. If it's successful, it doesn't return. Not ever.  You don't need to override this.
  def listen
    raise RuntimeError, "you must call Spork.using_spork! before starting the server" unless Spork.using_spork?
    @drb_service = DRb.start_service("druby://127.0.0.1:#{port}", self)
    Spork.each_run { @drb_service.stop_service }
    stderr.puts "Spork is ready and listening on #{port}!"
    stderr.flush
  end
  
  attr_accessor :port

  # This is the public facing method that is served up by DRb.  To use it from the client side (in a testing framework):
  # 
  #   DRb.start_service("druby://localhost:0") # this allows Ruby to do some magical stuff so you can pass an output stream over DRb.
  #                                            # see http://redmine.ruby-lang.org/issues/show/496 to see why localhost:0 is used.
  #   spec_server = DRbObject.new_with_uri("druby://127.0.0.1:8989")
  #   spec_server.run(options.argv, $stderr, $stdout)
  #
  # When implementing a test server, don't override this method: override run_tests instead.
  def run(argv, stderr, stdout)
    abort
    Spork::EventDispatcher[:work].trigger(:run, [argv, stderr, stdout], :synchronous => true)
  end
  
  def abort
    Spork::EventDispatcher[:interrupt].trigger(:abort, nil, :synchronous => true)
  end

  private
    def restart
      stderr.puts "restarting"
      stderr.flush
      config       = ::Config::CONFIG
      ruby         = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
      command_line = [ruby, $0, ARGV].flatten.join(' ')
      exec(command_line)
    end
    
    def quit
      exit!(0)
    end
end
