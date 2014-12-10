require 'spec_helper'

describe Spork::TestFramework do

  before(:each) do
    @fake = FakeFramework.new
  end

  describe ".available_test_frameworks" do
    before(:each) do
      Spork::TestFramework.supported_test_frameworks.each { |s| s.stub!(:available?).and_return(false) }
    end

    it "returns a list of all available servers" do
      expect(Spork::TestFramework.available_test_frameworks).to eq []
      Spork::TestFramework::RSpec.stub!(:available?).and_return(true)
      expect(Spork::TestFramework.available_test_frameworks).to eq [Spork::TestFramework::RSpec]
    end

    it "returns rspec before cucumber when both are available" do
      Spork::TestFramework::RSpec.stub!(:available?).and_return(true)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      expect(Spork::TestFramework.available_test_frameworks).to eq [Spork::TestFramework::RSpec, Spork::TestFramework::Cucumber]
    end
  end

  describe ".supported_test_frameworks" do
    it "returns all defined servers" do
      expect(Spork::TestFramework.supported_test_frameworks).to include(Spork::TestFramework::RSpec)
      expect(Spork::TestFramework.supported_test_frameworks).to include(Spork::TestFramework::Cucumber)
    end

    it "returns a list of servers matching a case-insensitive prefix" do
      expect(Spork::TestFramework.supported_test_frameworks("rspec")).to eq [Spork::TestFramework::RSpec]
      expect(Spork::TestFramework.supported_test_frameworks("rs")).to eq [Spork::TestFramework::RSpec]
      expect(Spork::TestFramework.supported_test_frameworks("cuc")).to eq [Spork::TestFramework::Cucumber]
    end
  end

  describe ".short_name" do
    it "returns the name of the framework, without the namespace prefix" do
      expect(Spork::TestFramework::Cucumber.short_name).to eq "Cucumber"
    end
  end

  describe ".available?" do
    it "returns true when the helper_file exists" do
      expect(FakeFramework.available?).to eq false
      create_helper_file(FakeFramework)
      expect(FakeFramework.available?).to eq true
    end
  end

  describe ".bootstrapped?" do
    it "recognizes if the helper_file has been bootstrapped" do
      bootstrap_contents = File.read(FakeFramework::BOOTSTRAP_FILE)
      File.stub!(:read).with(@fake.helper_file).and_return("")
      expect(@fake.bootstrapped?).to eq false
      File.stub!(:read).with(@fake.helper_file).and_return(bootstrap_contents)
      expect(@fake.bootstrapped?).to eq true
    end
  end

  describe ".bootstrap" do
    it "bootstraps a file" do
      create_helper_file
      @fake.bootstrap

      expect(TestIOStreams.stderr.string).to include("Bootstrapping")
      expect(TestIOStreams.stderr.string).to include("Edit")
      expect(TestIOStreams.stderr.string).to include("favorite text editor")

      expect(File.read(@fake.helper_file)).to include(File.read(FakeFramework::BOOTSTRAP_FILE))
    end
  end

  describe ".factory" do
    it "defaults to use rspec over cucumber" do
      Spork::TestFramework::RSpec.stub!(:available?).and_return(true)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      expect(Spork::TestFramework.factory(STDOUT, STDERR).class).to eq Spork::TestFramework::RSpec
    end

    it "defaults to use cucumber when rspec not available" do
      Spork::TestFramework::RSpec.stub!(:available?).and_return(false)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      expect(Spork::TestFramework.factory(STDOUT, STDERR).class).to eq Spork::TestFramework::Cucumber
    end
  end
end
