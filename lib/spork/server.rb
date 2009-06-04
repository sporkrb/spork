require 'drb/drb'
require 'rbconfig'
require 'spork/forker.rb'
require 'spork/custom_io_streams.rb'
require 'spork/app_framework.rb'

# This is based off of spec_server.rb from rspec-rails (David Chelimsky), which was based on Florian Weber's TDDMate
class Spork::Server
  @@supported_servers = []
  
  LOAD_PREFERENCE = ['RSpec', 'Cucumber']
  BOOTSTRAP_FILE = File.dirname(__FILE__) + "/../../assets/bootstrap.rb"
  
  include Spork::CustomIOStreams
  
  def self.port
    raise NotImplemented
  end
  
  def self.helper_file
    raise NotImplemented
  end
  
  def self.server_name
    self.name.gsub('Spork::Server::', '')
  end
  
  def self.inherited(subclass)
    @@supported_servers << subclass
  end
  
  def self.available_servers
    supported_servers.select { |s| s.available? }
  end
  
  def self.supported_servers(starting_with = nil)
    @@supported_servers.sort! { |a,b| a.load_preference_index <=> b.load_preference_index }
    return @@supported_servers if starting_with.nil?
    @@supported_servers.select do |s|
      s.server_name.match(/^#{Regexp.escape(starting_with)}/i)
    end
  end
  
  def self.available?
    File.exist?(helper_file)
  end
  
  def self.load_preference_index
    LOAD_PREFERENCE.index(server_name) || LOAD_PREFERENCE.length
  end
  
  def self.bootstrapped?
    File.read(helper_file).include?("Spork.prefork")
  end
  
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
    self.class.port
  end
  
  def helper_file
    self.class.helper_file
  end
  
  def run(argv, stderr, stdout)
    return false if running?
    
    @child = ::Spork::Forker.new do
      $stdout, $stderr = stdout, stderr
      Spork.exec_each_run { load helper_file }
      run_tests(argv, stderr, stdout)
    end
    @child.result
  end
  
  def running?
    @child && @child.running?
  end
  
  private
    def self.framework
      @framework ||= Spork::AppFramework.detect_framework
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
    
    def run_tests(argv, input, output)
      raise NotImplemented
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