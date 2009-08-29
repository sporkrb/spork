require File.dirname(__FILE__) + '/../spec_helper'

describe Spork::Server do
  describe "a fake server" do
    before(:each) do
      @fake_framework = FakeFramework.new
      @server = Spork::Server.new(:test_framework => @fake_framework)
    end
  
    it "aborts the current running thread when another run is started" do
      create_helper_file
      @fake_framework.wait_time = 0.25
      first_run = Thread.new { @server.run("test", STDOUT, STDIN).should == nil }
      sleep(0.05)
      @server.run("test", STDOUT, STDIN).should == true
    
      # wait for the first to finish
      first_run.join
    end
  
    it "can abort the current run" do
      create_helper_file
      @fake_framework.wait_time = 5
      started_at = Time.now
      first_run = Thread.new { @server.run("test", STDOUT, STDIN).should == true }
      sleep(0.05)
      @server.send(:abort)
      sleep(0.01) while @server.running?
      
      (Time.now - started_at).should < @fake_framework.wait_time
    end
    
    it "returns the result of the run_tests method from the forked child" do
      create_helper_file
      @fake_framework.stub!(:run_tests).and_return("tests were ran")
      @server.run("test", STDOUT, STDIN).should == "tests were ran"
    end

    it "accepts a port" do
      create_helper_file
      @server.port = 12345
      @server.port.should == 12345
    end

    it "falls back to a default port" do
      create_helper_file
      @server.port = nil
      @server.port.should == FakeFramework.default_port
    end
  end
end
