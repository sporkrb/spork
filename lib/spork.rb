$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
module Spork
  SPEC_HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")
  
  class << self
    def prefork(&block)
      return if @already_preforked
      @already_preforked = true
      yield
    end
  
    def each_run(&block)
      return if @state == :preforking || (@state != :not_using_spork && @already_run)
      @already_run = true
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
  end
end
