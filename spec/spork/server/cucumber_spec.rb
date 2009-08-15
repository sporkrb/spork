require File.dirname(__FILE__) + '/../../spec_helper'

describe Spork::Server::Cucumber do
  before(:each) do
    @server = Spork::Server::Cucumber.new
  end
  
  it "uses the CUCUMBER_PORT for it's default port" do
    @server.port.should == Spork::Server::Cucumber::CUCUMBER_PORT
  end

  it "uses ENV['CUCUMBER_DRB'] as port if present" do
    orig = ENV['CUCUMBER_DRB']
    begin
      ENV['CUCUMBER_DRB'] = "9000"
      @server.port.should == 9000
    ensure
      ENV['CUCUMBER_DRB'] = orig
    end
  end
  
  it "uses the CUCUMBER_HELPER_FILE for it's helper_file" do
    @server.helper_file.should == Spork::Server::Cucumber::CUCUMBER_HELPER_FILE
  end
end
