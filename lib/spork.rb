$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
module Spork
  BINARY = File.expand_path(File.dirname(__FILE__) + '/../bin/spork')
  LIBDIR = File.expand_path("..", File.dirname(__FILE__))

  class << self
    # Run a block, during prefork mode.  By default, if prefork is called twice in the same file and line number, the supplied block will only be ran once.
    #
    # == Parameters
    #
    # * +prevent_double_run+ - Pass false to disable double run prevention
    def prefork(prevent_double_run = true, &block)
      return if prevent_double_run && already_ran?(caller.first)
      yield
    end
    
    # Run a block AFTER the fork occurs.  By default, if prefork is called twice in the same file and line number, the supplied block will only be ran once.
    #
    # == Parameters
    #
    # * +prevent_double_run+ - Pass false to disable double run prevention
    def each_run(prevent_double_run = true, &block)
      return if prevent_double_run && already_ran?(caller.first)
      if @state == :using_spork
        each_run_procs << block
      else
        yield
      end
    end
    
    # Used by the server. Sets the state to activate spork. Otherwise, prefork and each_run are run in passive mode, allowing specs without a Spork server.
    def using_spork!
      @state = :using_spork
    end
    
    def using_spork?
      @state == :using_spork
    end

    # Used by the server.  Returns the current state of Spork.
    def state
      @state ||= :not_using_spork
    end
    
    # Used by the server.  Called when loading the prefork blocks of the code.
    def exec_prefork(&block)
      using_spork!
      yield
    end
    
    # Used by the server.  Called to run all of the prefork blocks.
    def exec_each_run(&block)
      each_run_procs.each { |p| p.call }
      each_run_procs.clear
      yield if block_given?
    end
    
    # Traps an instance method of a class (or module) so any calls to it don't actually run until Spork.exec_each_run
    def trap_method(klass, method_name)
      method_name_without_spork, method_name_with_spork = alias_method_names(method_name, :spork)
      
      klass.class_eval <<-EOF, __FILE__, __LINE__ + 1
        alias :#{method_name_without_spork} :#{method_name} unless method_defined?(:#{method_name_without_spork}) 
        def #{method_name}(*args)
          Spork.each_run(false) do
            #{method_name_without_spork}(*args)
          end
        end
      EOF
    end
    
    # Same as trap_method, but for class methods instead
    def trap_class_method(klass, method_name)
      trap_method((class << klass; self; end), method_name)
    end
    
    def detect_and_require(subfolder)
      ([LIBDIR] + Gem.latest_load_paths.grep(/spork/)).uniq.each do |gem_path|
        Dir.glob(File.join(gem_path, subfolder)).each { |file| require file }
      end
    end

    private
      def alias_method_names(method_name, feature)
        /^(.+?)([\?\!]{0,1})$/.match(method_name.to_s)
        ["#{$1}_without_spork#{$2}", "#{$1}_with_spork#{$2}"]
      end
      
      def already_ran
        @already_ran ||= []
      end
      
      def expanded_caller(caller_line)
        file, line = caller_line.split(":")
        line.gsub(/:.+/, '')
        File.expand_path(file, Dir.pwd) + ":" + line
      end
      
      def already_ran?(caller_script_and_line)
        return true if already_ran.include?(expanded_caller(caller_script_and_line))
        already_ran << expanded_caller(caller_script_and_line)
        false
      end
      
      def each_run_procs
        @each_run_procs ||= []
      end
  end
end
