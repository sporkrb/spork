require 'spec_helper'

describe Spork::AppFramework do
  describe ".detect_framework" do
    it "returns Unknown when no framework known detected" do
      expect(Spork::AppFramework.detect_framework.short_name).to eq "Unknown"
    end
  end
end
