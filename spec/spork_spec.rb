require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Spork.class_eval do
  def self.reset!
    @state = nil
    @already_run = nil
    @already_preforked = nil
  end
end

describe Spork do
  before(:each) do
    Spork.reset!
  end
  
  def spec_helper_simulator
    ran = []
    Spork.prefork do
      ran << :prefork
    end
    
    Spork.each_run do
      ran << :each_run
    end
    ran
  end
  
  it "only runs the preload block when preforking" do
    ran = []
    Spork.preforking!
    spec_helper_simulator.should == [:prefork]
  end
  
  it "only runs the each_run block when running" do
    Spork.preforking!
    spec_helper_simulator
    Spork.running!
    spec_helper_simulator.should == [:each_run]
  end
  
  it "runs both blocks when Spork not activated" do
    spec_helper_simulator.should == [:prefork, :each_run]
  end
  
  it "prevents blocks from being ran twice" do
    spec_helper_simulator.should == [:prefork, :each_run]
    spec_helper_simulator.should == []
  end
  
  it "runs multiple prefork and each_run blocks at different locations" do
    Spork.prefork { }
    Spork.each_run { }
    spec_helper_simulator.should == [:prefork, :each_run]
  end
end
