$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
module Spork
  class << self
    def already_preforked
      @already_preforked ||= []
    end
    
    def already_run
      @already_run ||= []
    end
    
    def prefork(&block)
      return if already_preforked.include?(expanded_caller(caller.first))
      already_preforked << expanded_caller(caller.first)
      yield
    end
  
    def each_run(&block)
      return if @state == :preforking || (@state != :not_using_spork && already_run.include?(expanded_caller(caller.first)))
      already_run << expanded_caller(caller.first)
      yield
    end
  
    def preforking!
      @state = :preforking
    end
  
    def running!
      @state = :running
    end
  
    def state
      @state ||= :not_using_spork
    end
  
    def exec_prefork(helper_file)
      preforking!
      load(helper_file)
    end
  
    def exec_each_run(helper_file)
      running!
      load(helper_file)
    end
    
    def expanded_caller(caller_line)
      file, line = caller_line.split(":")
      line.gsub(/:.+/, '')
      File.expand_path(Dir.pwd, file) + ":" + line
    end
  end
end
