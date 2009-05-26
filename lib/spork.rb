$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
module Spork
  SPEC_HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")
  
  def self.prefork(&block)
    return if @already_preforked
    @already_preforked = true
    yield
  end
  
  def self.each_run(&block)
    return if @state == :preforking || (@state != :not_using_spork && @already_run)
    @already_run = true
    yield
  end
  
  def self.preforking!
    @state = :preforking
  end
  
  def self.running!
    @state = :running
  end
  
  def self.state
    @state ||= :not_using_spork
  end
  
  def self.using_rails?
    File.exist?("config/environment.rb")
  end
  
  def self.using_prefork?
    File.read(SPEC_HELPER_FILE).include?("Spork.prefork")
  end
  
  def self.bootstrap
    puts "Bootstrapping #{SPEC_HELPER_FILE}"
    contents = File.read(SPEC_HELPER_FILE)
    bootstrap_code = File.read(File.dirname(__FILE__) + "/../assets/bootstrap.rb")
    File.open(SPEC_HELPER_FILE, "wb") do |f|
      f.puts bootstrap_code
      f.puts contents
    end
    
    puts "Done. Edit #{SPEC_HELPER_FILE} now with your favorite text editor and follow the instructions."
    true
  end
  
  def self.preload
    if using_prefork?
      puts "Loading Spork.prefork block..."
      Spork.preforking!
      load SPEC_HELPER_FILE
    else
      puts "spec_helper.rb is has not been sporked.  Run spork --bootstrap to do so."
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
end
