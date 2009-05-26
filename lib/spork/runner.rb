require 'optparse'

module Spork
  class Runner

    def self.run(args, output, error)
      self.new(args, output, error).run
    end

    def initialize(args, output, error)
      @output = output
      @error = error
      @options = {}
      parser = OptionParser.new
      parser.on("-d", "--daemon")     {|ignore| @options[:daemon] = true }
      parser.on("-b", "--bootstrap")  {|ignore| @options[:bootstrap] = true }
      parser.on("-p", "--pid PIDFILE"){|pid|    @options[:pid]    = pid  }
      parser.parse!(args)
    end


    def run
      ENV["DRB"] = 'true'
      ENV["RAILS_ENV"] ||= 'test' if Spork.using_rails?

      unless File.exist?(Spork::SPEC_HELPER_FILE)
        @output.puts  <<-USEFUL_ERROR
        Bummer!

        I can't find the file spec/spec_helper.rb, which I need in order to run.

        Are you running me from a project directory that has rspec set up?
        USEFUL_ERROR
        return false
      end


      return Spork.bootstrap if options[:bootstrap]

      require 'spork/spec_server'
      return(false) unless Spork.preload

      if options[:daemon]
        ::Spork::SpecServer.daemonize(options[:pid])
      else
        ::Spork::SpecServer.run
      end
      return true
    end

    private
    attr_reader :options 

  end
end






