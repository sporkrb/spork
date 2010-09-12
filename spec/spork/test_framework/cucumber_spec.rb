require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + "/../test_framework_shared_examples"

describe Spork::TestFramework::Cucumber do
  before(:each) do
    @klass = Spork::TestFramework::Cucumber
    @server = @klass.new
  end

  it_should_behave_like "a TestFramework"
end
