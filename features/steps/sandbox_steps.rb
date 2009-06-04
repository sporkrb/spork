Given /^I am in the directory "(.*)"$/ do |sandbox_dir_relative_path|
  path = File.join(SporkWorld::SANDBOX_DIR, sandbox_dir_relative_path)
  FileUtils.mkdir_p(path)
  @current_dir = File.join(path)
end

Given /^a file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

When /^I run spork (.*)$/ do |spork_opts|
  run "#{SporkWorld::RUBY_BINARY} #{SporkWorld::BINARY} #{spork_opts}"
end

Then /^the output should contain$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should not contain$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should be$/ do |text|
  last_stdout.should == text
end
