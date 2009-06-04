require File.dirname(__FILE__) + '/../spec_helper'

describe Spork::Runner do
  before(:each) do
    @out, @err = StringIO.new, StringIO.new
  end
  
  it "finds a matching server with a prefix" do
    Spork::Runner.new(["rs"], @out, @err).find_server.should == Spork::Server::RSpec
  end
  
  it "shows an error message if no matching server was found" do
    Spork::Runner.new(["argle_bargle"], @out, @err).run.should == false
    @err.string.should include(%("argle_bargle" didn't match a supported test framework))
  end
  
  it "defaults to use rspec over cucumber" do
    Spork::Server::RSpec.stub!(:available?).and_return(true)
    Spork::Server::Cucumber.stub!(:available?).and_return(true)
    Spork::Runner.new([], @out, @err).find_server.should == Spork::Server::RSpec
  end
  
  it "defaults to use cucumber when rspec not available" do
    Spork::Server::RSpec.stub!(:available?).and_return(false)
    Spork::Server::Cucumber.stub!(:available?).and_return(true)
    Spork::Runner.new([], @out, @err).find_server.should == Spork::Server::Cucumber
  end
  
  it "bootstraps a server when -b is passed in" do
    Spork::Server::RSpec.stub!(:available?).and_return(true)
    Spork::Server::RSpec.should_receive(:bootstrap).and_return(true)
    Spork::Runner.new(['rspec', '-b'], @out, @err).run
  end
  
  it "aborts if it can't preload" do
    Spork::Server::RSpec.stub!(:available?).and_return(true)
    Spork::Server::RSpec.should_receive(:preload).and_return(false)
    Spork::Server::RSpec.should_not_receive(:run)
    Spork::Runner.new(['rspec'], @out, @err).run
  end
  
  it "runs the server if all is well" do
    Spork::Server::RSpec.stub!(:available?).and_return(true)
    Spork::Server::RSpec.should_receive(:preload).and_return(true)
    Spork::Server::RSpec.should_receive(:run).and_return(true)
    Spork::Runner.new(['rspec'], @out, @err).run
    @err.string.should include("Using RSpec")
  end
  
  it "outputs a list of supported servers, along with supported asterisk" do
    Spork::Server.stub!(:supported_servers).and_return([Spork::Server::RSpec, Spork::Server::Cucumber])
    Spork::Server::RSpec.stub!(:available?).and_return(true)
    Spork::Server::Cucumber.stub!(:available?).and_return(false)
    
    Spork::Runner.new(['rspec'], @out, @err).supported_servers_text.should == <<-EOF
Supported test frameworks:
( ) Cucumber
(*) RSpec

Legend: ( ) - not detected in project   (*) - detected
    EOF
  end
end
