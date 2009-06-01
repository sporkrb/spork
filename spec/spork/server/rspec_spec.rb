require File.dirname(__FILE__) + '/../../spec_helper'

describe Spork::Server::RSpec do
  before(:each) do
    @server = Spork::Server::RSpec.new
  end
  
  it "uses the RSPEC_PORT for it's port" do
    @server.port.should == Spork::Server::RSpec::RSPEC_PORT
  end
  
  it "uses the RSPEC_HELPER_FILE for it's helper_file" do
    @server.helper_file.should == Spork::Server::RSpec::RSPEC_HELPER_FILE
  end
end
