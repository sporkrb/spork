require File.dirname(__FILE__) + '/../../spec_helper'

describe Spork::Server::RSpec do
  before(:each) do
    @adapter = Spork::Adapter::RSpec.new
  end
  
  it "uses the RSPEC_PORT for it's port" do
    @adapter.port.should == Spork::Adapter::RSpec::RSPEC_PORT
  end
end
