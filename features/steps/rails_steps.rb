Given /^I am in a fresh rails project named "(.+)"$/ do |folder_name|
  @current_dir = SporkWorld::SANDBOX_DIR
  version_argument = ENV['RAILS_VERSION'] ? "_#{ENV['RAILS_VERSION']}_" : nil
  # run("#{SporkWorld::RUBY_BINARY} #{%x{which rails}.chomp} #{folder_name}")
  run([SporkWorld::RUBY_BINARY, %x{which rails}.chomp, version_argument, folder_name].compact * " ")
  @current_dir = File.join(File.join(SporkWorld::SANDBOX_DIR, folder_name))
end


Given "the application has a model, observer, route, and application helper" do
  Given 'a file named "app/models/user.rb" with:',
    """
    class User < ActiveRecord::Base
      ($loaded_stuff ||= []) << 'User'
    end
    """

  Given 'a file named "app/helpers/application_helper.rb" with:',
    """
    module ApplicationHelper
      ($loaded_stuff ||= []) << 'ApplicationHelper'
    end
    """
  Given 'a file named "app/models/user_observer.rb" with:',
    """
    class UserObserver < ActiveRecord::Observer
      ($loaded_stuff ||= []) << 'UserObserver'
    end
    """
  Given 'the following code appears in "config/environment.rb" after /Rails::Initializer.run/:',
    """
      config.active_record.observers = :user_observer
    """
  Given 'the following code appears in "config/routes.rb" after /^end/:',
    """
      ($loaded_stuff ||= []) << 'config/routes.rb'
    """
end