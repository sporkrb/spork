require 'spec_helper'

describe Spork::Forker do
  describe ".new" do
    it "runs a block in a fork" do
      $var = "hello world"
      Spork::Forker.new { $var = "booyah" }.result
      expect($var).to eq "hello world"
    end
  end
  
  describe "#result" do
    it "returns the result" do
      expect(Spork::Forker.new { "results" }.result).to eq "results"
    end
  end
  
  describe "#running?" do
    it "reports when the fork is running" do
      forker = Spork::Forker.new { sleep 0.1 }
      expect(forker.running?).to eq true
      forker.result
      sleep 0.1
      expect(forker.running?).to eq false
    end
  end
  
  describe "#abort" do
    it "aborts a fork and returns nil for the result" do
      started_at = Time.now
      ended_at = nil
      forker = Spork::Forker.new do
        begin
          sleep 5
        rescue SignalException
        end
      end
      Thread.new do
        expect(forker.result).to eq nil
        ended_at = Time.now
      end
      sleep 0.5
      forker.abort
      sleep 0.1
      expect((ended_at - started_at)).to be_within(0.1).of(0.5)
      expect(forker.running?).to eq false
    end
  end
end unless windows?
