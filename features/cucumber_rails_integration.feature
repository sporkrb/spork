Feature: Cucumber integration with rails
  As a developer using cucumber and rails
  I want to use Spork with Cucumber
  In order to eliminate the startup cost of my application each time I run them
  
  Background: Sporked env.rb
    Given I am in a fresh rails project named "test_rails_project"
    And the application has a model, observer, route, and application helper
    And a file named "features/support/env.rb" with:
      """
      require 'rubygems'
      require 'spork'

      Spork.prefork do
        # Sets up the Rails environment for Cucumber
        ENV['RAILS_ENV'] = "cucumber"
        require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

        require 'webrat'

        Webrat.configure do |config|
          config.mode = :rails
        end

        require 'webrat/core/matchers'
        require 'cucumber' # I needed to add this... We could move this require to Spork if we think it is better there...
        require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
        require 'spec/rails' # I needed to add this as well to avoid the #records error...
        require 'cucumber/rails/rspec'
        class ActiveRecord::Base
          class << self
            def establish_connection
              ($loaded_stuff ||= []) << 'establish_connection'
            end
          end
        end
      end

      Spork.each_run do
        # This code will be run each time you run your specs.
        require 'cucumber/rails/world'
        Cucumber::Rails.use_transactional_fixtures
        Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling
                                      # (e.g. rescue_action_in_public / rescue_responses / rescue_from)
      end
      """
    And a file named "features/cucumber_rails.feature" with:
      """
      Feature: cucumber rails
        Scenario: did it work
          Then it should work
      """
    And a file named "features/support/cucumber_rails_helper.rb" with:
      """
      ($loaded_stuff ||= []) << 'features/support/cucumber_rails_helper.rb'
      """
    And a file named "features/step_definitions/cucumber_rails_steps.rb" with:
      """
      Then "it should work" do
        Spork.state.should == :using_spork
        RAILS_ENV.should == 'cucumber'
        $loaded_stuff.should include('establish_connection')
        $loaded_stuff.should include('User')
        $loaded_stuff.should include('UserObserver')
        $loaded_stuff.should include('ApplicationHelper')
        $loaded_stuff.should include('config/routes.rb')
        $loaded_stuff.should include('features/support/cucumber_rails_helper.rb')
        puts "It worked!"
      end
      """
    And a file named "config/environments/cucumber.rb" with:
      """
      $cucumber_used = true
      """
    And a file named "config/database.yml" with:
      """
      cucumber:
        adapter: sqlite3
        database: db/cucumber.sqlite3
        timeout: 5000
      """
    Scenario: Analyzing files were preloaded
      When I run spork --diagnose
      Then the output should not contain "user_observer.rb"
      Then the output should not contain "user.rb"
      Then the output should not contain "app/controllers/application.rb"
      Then the output should not contain "app/controllers/application_controller.rb"
      Then the output should not contain "app/controllers/application_helper.rb"
      Then the output should not contain "config/routes.rb"
      Then the output should not contain "features/step_definitions/cucumber_rails_steps.rb"
      Then the output should not contain "features/support/cucumber_rails_helper.rb"
      
    Scenario: Running spork with a rails app and observers
      When I fire up a spork instance with "spork cucumber"
      And I run cucumber --drb features/cucumber_rails.feature
      Then the output should contain "It worked!"
