require 'spec_helper'

describe Spork::RunStrategy::Magazine do

  before { ENV["SPORK_SLAVES_COUNT"] = nil }
  after  { ENV["SPORK_SLAVES_COUNT"] = nil }

  it "uses 2 slaves by default" do
    Spork::RunStrategy::Magazine::Slave_Id_Range.should == (1..2)
  end

  it "allows to override max slaves count via environment variable" do
    ENV["SPORK_SLAVES_COUNT"] = "42"
    Spork::RunStrategy.send :remove_const, :Magazine
    load "spork/run_strategy/magazine.rb"
    Spork::RunStrategy::Magazine::Slave_Id_Range.should == (1..42)
  end
end
