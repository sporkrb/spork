Given /^I am in a fresh rails project named "(.+)"$/ do |folder_name|
  @current_dir = SporkWorld::SANDBOX_DIR
  run("#{SporkWorld::RUBY_BINARY} #{%x{which rails}.chomp} #{folder_name}")
  @current_dir = File.join(File.join(SporkWorld::SANDBOX_DIR, folder_name))
end
