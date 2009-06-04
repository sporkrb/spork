$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
module Spork
  class << self
    def already_ran
      @already_ran ||= []
    end
    
    def each_run_procs
      @each_run_procs ||= []
    end
    
    def prefork(&block)
      return if already_ran?(caller.first)
      yield
    end
    
    def each_run(&block)
      return if already_ran?(caller.first)
      if @state == :using_spork
        each_run_procs << block
      else
        yield
      end
    end
    
    def already_ran?(caller_script_and_line)
      return true if already_ran.include?(expanded_caller(caller_script_and_line))
      already_ran << expanded_caller(caller_script_and_line)
      false
    end
    
    def using_spork!
      @state = :using_spork
    end
    
    def state
      @state ||= :not_using_spork
    end
    
    def exec_prefork(&block)
      using_spork!
      yield
    end
    
    def exec_each_run(&block)
      each_run_procs.each { |p| p.call }
      each_run_procs.clear
      yield if block_given?
    end
    
    def expanded_caller(caller_line)
      file, line = caller_line.split(":")
      line.gsub(/:.+/, '')
      File.expand_path(Dir.pwd, file) + ":" + line
    end
    
    def trap_method(klass, method_name)
      klass.class_eval <<-EOF, __FILE__, __LINE__ + 1
        alias :#{method_name}_without_spork :#{method_name} unless method_defined?(:#{method_name}_without_spork) 
        def #{method_name}(*args)
          Spork.each_run_procs << lambda do
            #{method_name}_without_spork(*args)
          end
        end
      EOF
    end
    
    def trap_class_method(klass, method_name)
      klass.class_eval <<-EOF, __FILE__, __LINE__ + 1
        class << self
          alias :#{method_name}_without_spork :#{method_name} unless method_defined?(:#{method_name}_without_spork)
          def #{method_name}(*args)
            Spork.each_run_procs << lambda do
              #{method_name}_without_spork(*args)
            end
          end
        end
      EOF
    end
  end
end
