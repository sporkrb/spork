Given /^I am in a fresh rails project named "(.+)"$/ do |folder_name|
  @current_dir = SporkWorld::SANDBOX_DIR
  version_argument = ENV['RAILS_VERSION'] ? "_#{ENV['RAILS_VERSION']}_" : nil
  # run("#{SporkWorld::RUBY_BINARY} #{%x{which rails}.chomp} #{folder_name}")
  run([SporkWorld::RUBY_BINARY, %x{which rails}.chomp, version_argument, folder_name].compact * " ")
  @current_dir = File.join(File.join(SporkWorld::SANDBOX_DIR, folder_name))
end
