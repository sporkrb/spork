require 'drb/drb'
require 'rbconfig'
require 'spork/forker.rb'
require 'spork/custom_io_streams.rb'
require 'spork/app_framework.rb'

# An abstract class that is implemented to create a server
#
# (This was originally based off of spec_server.rb from rspec-rails (David Chelimsky), which was based on Florian Weber's TDDMate)
class Spork::Server
  @@supported_servers = []
  
  LOAD_PREFERENCE = ['RSpec', 'Cucumber']
  BOOTSTRAP_FILE = File.dirname(__FILE__) + "/../../assets/bootstrap.rb"
  
  include Spork::CustomIOStreams
  
  # Abstract method: returns the servers port.  Override this to return the port that should be used by the test framework.
  def self.port
    raise NotImplemented
  end
  
  # Abstract method: returns the entry file that loads the testing environment, such as spec/spec_helper.rb.
  def self.helper_file
    raise NotImplemented
  end
  
  # Convenience method that turns the class name without the namespace
  def self.server_name
    self.name.gsub('Spork::Server::', '')
  end
  
  # Returns a list of all testing servers that have detected their testing framework being used in the project.
  def self.available_servers
    supported_servers.select { |s| s.available? }
  end
  
  # Returns a list of all servers that have been implemented (it keeps track of them automatically via Class.inherited)
  def self.supported_servers(starting_with = nil)
    @@supported_servers.sort! { |a,b| a.load_preference_index <=> b.load_preference_index }
    return @@supported_servers if starting_with.nil?
    @@supported_servers.select do |s|
      s.server_name.match(/^#{Regexp.escape(starting_with)}/i)
    end
  end
  
  # Returns true if the testing frameworks helper file exists.  Override if this is not sufficient to detect your testing framework.
  def self.available?
    File.exist?(helper_file)
  end
  
  # Used to specify
  def self.load_preference_index
    LOAD_PREFERENCE.index(server_name) || LOAD_PREFERENCE.length
  end
  
  # Detects if the test helper has been bootstrapped.
  def self.bootstrapped?
    File.read(helper_file).include?("Spork.prefork")
  end
  
  # Bootstraps the current test helper file by prepending a Spork.prefork and Spork.each_run block at the beginning.
  def self.bootstrap
    if bootstrapped?
      stderr.puts "Already bootstrapped!"
      return
    end
    stderr.puts "Bootstrapping #{helper_file}."
    contents = File.read(helper_file)
    bootstrap_code = File.read(BOOTSTRAP_FILE)
    File.open(helper_file, "wb") do |f|
      f.puts bootstrap_code
      f.puts contents
    end
    
    stderr.puts "Done. Edit #{helper_file} now with your favorite text editor and follow the instructions."
    true
  end
  
  def self.run
    return unless available?
    new.listen
  end
  
  # Sets up signals and starts the DRb service. If it's successful, it doesn't return. Not ever.  You don't need to override this.
  def listen
    trap("SIGINT") { sig_int_received }
    trap("SIGTERM") { abort; exit!(0) }
    trap("USR2") { abort; restart } if Signal.list.has_key?("USR2")
    DRb.start_service("druby://127.0.0.1:#{port}", self)
    stderr.puts "Spork is ready and listening on #{port}!"
    stderr.flush
    DRb.thread.join
  end
  
  def port
    self.class.instance_variable_get("@port") || self.class.port
  end

  def self.port= p
    @port = p
  end
  
  def helper_file
    self.class.helper_file
  end
  
  # This is the public facing method that is served up by DRb.  To use it from the client side (in a testing framework):
  # 
  #   DRb.start_service("druby://localhost:0") # this allows Ruby to do some magical stuff so you can pass an output stream over DRb.
  #                                            # see http://redmine.ruby-lang.org/issues/show/496 to see why localhost:0 is used.
  #   spec_server = DRbObject.new_with_uri("druby://127.0.0.1:8989")
  #   spec_server.run(options.argv, $stderr, $stdout)
  #
  # When implementing a test server, don't override this method: override run_tests instead.
  def run(argv, stderr, stdout)
    abort if running?
    
    @child = ::Spork::Forker.new do
      $stdout, $stderr = stdout, stderr
      Spork.exec_each_run { load helper_file }
      run_tests(argv, stderr, stdout)
    end
    @child.result
  end
  
  # returns whether or not the child (a test run) is running right now.
  def running?
    @child && @child.running?
  end
  
  protected
    # Abstract method: here is where the server runs the tests.
    def run_tests(argv, input, output)
      raise NotImplemented
    end
  
  private
    def self.inherited(subclass)
      @@supported_servers << subclass
    end
    
    def self.framework
      @framework ||= Spork::AppFramework.detect_framework
    end
    
    def self.entry_point
      bootstrapped? ? helper_file : framework.entry_point
    end

    def self.preload
      Spork.exec_prefork do
        unless bootstrapped?
          stderr.puts "#{helper_file} has not been bootstrapped.  Run spork --bootstrap to do so."
          stderr.flush
        
          if framework.bootstrap_required?
            stderr.puts "I can't do anything for you by default for the framework your using: #{framework.short_name}.\nYou must bootstrap #{helper_file} to continue."
            stderr.flush
            return false
          else
            load(framework.entry_point)
          end
        end
      
        framework.preload do
          if bootstrapped?
            stderr.puts "Loading Spork.prefork block..."
            stderr.flush
            load(helper_file)
          end
        end  
      end
      true
    end
    
    def restart
      stderr.puts "restarting"
      stderr.flush
      config       = ::Config::CONFIG
      ruby         = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
      command_line = [ruby, $0, ARGV].flatten.join(' ')
      exec(command_line)
    end
    
    def abort
      @child && @child.abort
    end
    
    def sig_int_received
      if running?
        abort
        stderr.puts "Running tests stopped.  Press CTRL-C again to stop the server."
        stderr.flush
      else
        exit!(0)
      end
    end
end

Dir[File.dirname(__FILE__) + "/server/*.rb"].each { |file| require file }
