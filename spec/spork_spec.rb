require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Spork.class_eval do
  def self.reset!
    @state = nil
    @already_ran = nil
  end
end

describe Spork do
  before(:each) do
    Spork.reset!
  end
  
  def spec_helper_simulator
    @ran ||= []
    Spork.prefork do
      @ran << :prefork
    end
    
    Spork.each_run do
      @ran << :each_run
    end
    @ran
  end
  
  it "only runs the preload block when preforking" do
    Spork.exec_prefork { spec_helper_simulator }
    @ran.should == [:prefork]
  end
  
  it "only runs the each_run block when running" do
    Spork.exec_prefork { spec_helper_simulator }
    @ran.should == [:prefork]
    
    Spork.exec_each_run
    @ran.should == [:prefork, :each_run]
  end
  
  it "runs both blocks when Spork not activated" do
    spec_helper_simulator.should == [:prefork, :each_run]
  end
  
  it "prevents blocks from being ran twice" do
    Spork.exec_prefork { spec_helper_simulator }
    Spork.exec_each_run
    @ran.clear
    Spork.exec_prefork { spec_helper_simulator }
    Spork.exec_each_run
    @ran.should == []
  end
  
  it "runs multiple prefork and each_run blocks at different locations" do
    Spork.prefork { }
    Spork.each_run { }
    spec_helper_simulator.should == [:prefork, :each_run]
  end
end
