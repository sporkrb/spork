require 'spec_helper'

describe MagazineSlave do
  it '#run returns test result' do
    fake_framework = FakeFramework.new
    create_helper_file(fake_framework)
    fake_framework.stub!(:run_tests).and_return(true)
    slave = MagazineSlave.new(1, fake_framework.short_name)
    slave.run('test', StringIO.new, StringIO.new).should be true
  end
end
