require File.dirname(__FILE__) + '/../spec_helper'

class FakeServer < Spork::Server
  attr_accessor :wait_time
  def self.helper_file
    SPEC_TMP_DIR + "/fake/test_helper.rb"
  end
  
  def self.port
    1000
  end
  
  def self.puts(string)
    $test_stdout.puts(string)
  end
  
  def puts(string)
    $test_stdout.puts(string)
  end
  
  def run_tests(argv, input, output)
    sleep(@wait_time || 0.5)
  end
end

describe Spork::Server do
  describe ".available_servers" do
    before(:each) do
      Spork::Server.defined_servers.each { |s| s.stub!(:available?).and_return(false) }
    end
    
    it "returns a list of all available servers" do
      Spork::Server.available_servers.should == []
      Spork::Server::RSpec.stub!(:available?).and_return(true)
      Spork::Server.available_servers.should == [Spork::Server::RSpec]
    end
    
    it "returns rspec before cucumber when both are available" do
      Spork::Server::RSpec.stub!(:available?).and_return(true)
      Spork::Server::Cucumber.stub!(:available?).and_return(true)
      Spork::Server.available_servers.should == [Spork::Server::RSpec, Spork::Server::Cucumber]
    end
  end
  
  describe ".defined_servers" do
    it "returns all defined servers" do
      Spork::Server.defined_servers.should include(Spork::Server::RSpec)
      Spork::Server.defined_servers.should include(Spork::Server::Cucumber)
    end
    
    it "returns a list of servers matching a case-insensitive prefix" do
      Spork::Server.defined_servers("rspec").should == [Spork::Server::RSpec]
      Spork::Server.defined_servers("rs").should == [Spork::Server::RSpec]
      Spork::Server.defined_servers("cuc").should == [Spork::Server::Cucumber]
    end
  end
  
  describe "a fake server" do
    def create_helper_file
      FileUtils.mkdir_p(File.dirname(FakeServer.helper_file))
      FileUtils.touch(FakeServer.helper_file)
    end
  
    before(:each) do
      @fake = FakeServer.new
    end
  
    it "should be available when the helper_file exists" do
      FakeServer.available?.should == false
      create_helper_file
      FakeServer.available?.should == true
    end
  
    it "has a name" do
      FakeServer.server_name.should == "FakeServer"
    end
  
    it "tells if it's testing framework is being used" do
      Spork::Server.available_servers.should_not include(FakeServer)
      create_helper_file
      Spork::Server.available_servers.should include(FakeServer)
    end
  
    it "recognizes if the helper_file has been bootstrapped" do
      bootstrap_contents = File.read(FakeServer::BOOTSTRAP_FILE)
      File.stub!(:read).with(FakeServer.helper_file).and_return("")
      FakeServer.bootstrapped?.should == false
      File.stub!(:read).with(FakeServer.helper_file).and_return(bootstrap_contents)
      FakeServer.bootstrapped?.should == true
    end
  
    it "bootstraps a file" do
      create_helper_file
      FakeServer.bootstrap
    
      $test_stdout.string.should include("Bootstrapping")
      $test_stdout.string.should include("Edit")
      $test_stdout.string.should include("favorite text editor")
    
      File.read(FakeServer.helper_file).should include(File.read(FakeServer::BOOTSTRAP_FILE))
    end
  
    it "prevents you from running specs twice in parallel" do
      create_helper_file
      @fake.wait_time = 0.25
      first_run = Thread.new { @fake.run("test", STDOUT, STDIN).should == true }
      sleep(0.05)
      @fake.run("test", STDOUT, STDIN).should == false
    
      # wait for the first to finish
      first_run.join
    end
  
    it "can abort the current run" do
      create_helper_file
      @fake.wait_time = 5
      started_at = Time.now
      first_run = Thread.new { @fake.run("test", STDOUT, STDIN).should == true }
      sleep(0.05)
      @fake.send(:abort)
      sleep(0.01) while @fake.running?
    
      (Time.now - started_at).should < @fake.wait_time
    end
  end
end
