require 'drb/drb'
require 'rbconfig'

# This is based off of spec_server.rb from rspec-rails (David Chelimsky), which was based on Florian Weber's TDDMate
class Spork::Server
  @@supported_servers = []
  
  LOAD_PREFERENCE = ['RSpec', 'Cucumber']
  BOOTSTRAP_FILE = File.dirname(__FILE__) + "/../../assets/bootstrap.rb"
  
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
  
  def self.using_rails?
    File.exist?("config/environment.rb")
  end
  
  def self.bootstrapped?
    File.read(helper_file).include?("Spork.prefork")
  end
  
  def self.bootstrap
    if bootstrapped?
      puts "Already bootstrapped!"
      return
    end
    puts "Bootstrapping #{helper_file}."
    contents = File.read(helper_file)
    bootstrap_code = File.read(BOOTSTRAP_FILE)
    File.open(helper_file, "wb") do |f|
      f.puts bootstrap_code
      f.puts contents
    end
    
    puts "Done. Edit #{helper_file} now with your favorite text editor and follow the instructions."
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
    puts "Spork is ready and listening on #{port}!"
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
    $stdout, $stderr = stdout, stderr
    
    child_io, server_io = UNIXSocket::socketpair
    @child_pid = Kernel.fork do
      server_io.close
      Spork.exec_each_run(helper_file)
      child_io << Marshal.dump(run_tests(argv, stderr, stdout))
    end
    child_io.close
    Process.wait(@child_pid)
    @child_pid = nil
    Marshal.load(server_io.read)
  end
  
  def running?
    !! @child_pid
  end
  
  private
    def self.preload
      if bootstrapped?
        puts "Loading Spork.prefork block..."
        Spork.exec_prefork(helper_file)
      else
        puts "#{helper_file} has not been sporked.  Run spork --bootstrap to do so."
        # are we in a rails app?
        if using_rails?
          puts "Preloading Rails environment"
          require "config/environment.rb"
        else
          puts "There's nothing I can really do for you.  Bailing."
          return false
        end
      end
      true
    end
    
    def run_tests(argv, input, output)
      raise NotImplemented
    end
    
    def restart
      puts "restarting"
      config       = ::Config::CONFIG
      ruby         = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
      command_line = [ruby, $0, ARGV].flatten.join(' ')
      exec(command_line)
    end
    
    def abort
      if running?
        Process.kill(Signal.list['TERM'], @child_pid)
        true
      end
    end
    
    def sig_int_received
      if running?
        abort
        puts "Running specs stopped.  Press CTRL-C again to stop the server."
      else
        exit!(0)
      end
    end
end

Dir[File.dirname(__FILE__) + "/server/*.rb"].each { |file| require file }