require 'optparse'
require 'spork/server'

module Spork
  # This is used by bin/spork. It's wrapped in a class because it's easier to test that way.
  class Runner
    attr_reader :server
    
    def self.run(args, output, error)
      self.new(args, output, error).run
    end
    
    def initialize(args, output, error)
      raise ArgumentError, "expected array of args" unless args.is_a?(Array)
      @output = output
      @error = error
      @options = {}
      opt = OptionParser.new
      opt.banner = "Usage: spork [test framework name] [options]\n\n"
      
      opt.separator "Options:"
      opt.on("-b", "--bootstrap")  {|ignore| @options[:bootstrap] = true }
      opt.on("-d", "--diagnose")  {|ignore| @options[:diagnose] = true }
      opt.on("-h", "--help")  {|ignore| @options[:help] = true }
      opt.on("-p", "--port [PORT]") {|port| @options[:port] = port }
      non_option_args = args.select { |arg| ! args[0].match(/^-/) }
      @options[:server_matcher] = non_option_args[0]
      opt.parse!(args)
      
      if @options[:help]
        @output.puts opt
        @output.puts
        @output.puts supported_servers_text
        exit(0)
      end
    end
    
    def supported_servers_text
      text = StringIO.new
      
      text.puts "Supported test frameworks:"
      text.puts Spork::Server.supported_servers.sort { |a,b| a.server_name <=> b.server_name }.map { |s| (s.available? ? '(*) ' : '( ) ') + s.server_name }
      text.puts "\nLegend: ( ) - not detected in project   (*) - detected\n"
      text.string
    end
    
    # Returns a server for the specified (or the detected default) testing framework.  Returns nil if none detected, or if the specified is not supported or available.
    def find_server
      if options[:server_matcher]
        @server = Spork::Server.supported_servers(options[:server_matcher]).first
        unless @server
          @error.puts <<-ERROR
#{options[:server_matcher].inspect} didn't match a supported test framework.

#{supported_servers_text}
          ERROR
          return
        end
        
        unless @server.available?
          @error.puts  <<-USEFUL_ERROR
I can't find the helper file #{@server.helper_file} for the #{@server.server_name} testing framework.
Are you running me from the project directory?
          USEFUL_ERROR
          return
        end
      else
        @server = Spork::Server.available_servers.first
        if @server.nil?
          @error.puts  <<-USEFUL_ERROR
I can't find any testing frameworks to use.
Are you running me from a project directory?
          USEFUL_ERROR
          return
        end
      end
      @server
    end
    
    def run
      return false unless find_server
      ENV["DRB"] = 'true'
      @error.puts "Using #{server.server_name}"
      @error.flush

      server.port = options[:port]

      case
      when options[:bootstrap]
        server.bootstrap
      when options[:diagnose]
        require 'spork/diagnoser'
        
        Spork::Diagnoser.install_hook!(server.entry_point)
        server.preload
        Spork::Diagnoser.output_results(@output)
        return true
      else
        return(false) unless server.preload
        server.run
        return true
      end
    end
    
    private
    attr_reader :options 

  end
end






