require 'drb/drb'
require 'rbconfig'

# This is based off of spec_server.rb from rspec-rails (David Chelimsky), which was based on Florian Weber's TDDMate
class Spork::SpecServer
  DRB_PORT = 8989
  def self.restart_test_server
    puts "restarting"
    config       = ::Config::CONFIG
    ruby         = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
    command_line = [ruby, $0, ARGV].flatten.join(' ')
    exec(command_line)
  end

  def self.daemonize(pid_file = nil)
    return yield if $DEBUG
    pid = Process.fork{
      Process.setsid
      trap("SIGINT"){ exit! 0 }
      trap("SIGTERM"){ exit! 0 }
      trap("SIGHUP"){ restart_test_server }
      File.open("/dev/null"){|f|
        STDERR.reopen f
        STDIN.reopen  f
        STDOUT.reopen f
      }
      run
    }
    puts "spec_server launched (PID: %d)" % pid
    File.open(pid_file,"w"){|f| f.puts pid } if pid_file
    exit! 0
  end
  
  def self.run
    trap("USR2") { ::Spork::SpecServer.restart_test_server } if Signal.list.has_key?("USR2")
    DRb.start_service("druby://127.0.0.1:#{DRB_PORT}", ::Spork::SpecServer.new)
    puts "Spork is ready and listening on #{DRB_PORT}!"
    DRb.thread.join
  end
  
  def run(argv, stderr, stdout)
    $stdout = stdout
    $stderr = stderr
    child_pid = Kernel.fork do
      Spork.running!
      load ::Spork::SPEC_HELPER_FILE
    
      ::Spec::Runner::CommandLine.run(
        ::Spec::Runner::OptionParser.parse(
          argv,
          $stderr,
          $stdout
        )
      )
    end
    Process.wait(child_pid)
  end
end
