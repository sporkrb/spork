Feature: Rails Integration
  To get a developer up and running quickly
  Spork automatically integrates with rails
  Providing default hooks and behaviors

  Background: Rails App with RSpec and Spork

    Given I am in a fresh rails project named "test_rails_project"
    And a file named "spec/spec_helper.rb" with:
      """
      require 'rubygems'
      require 'spork'
      require 'spec'

      Spork.prefork do
        $run_phase = :prefork
        require File.dirname(__FILE__) + '/../config/environment.rb'
      end

      Spork.each_run do
        $run_phase = :each_run
        puts "I'm loading the stuff just for this run..."
      end
      
      class ActiveRecord::Base
        class << self
          def establish_connection
            ($loaded_stuff ||= []) << 'establish_connection'
            puts "Database connection was automatically re-established!"
          end
        end
      end
      """
    And a file named "app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        ($loaded_stuff ||= []) << 'User'
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        ($loaded_stuff ||= []) << 'ApplicationHelper'
      end
      """
    And a file named "app/models/user_observer.rb" with:
      """
      class UserObserver < ActiveRecord::Observer
        ($loaded_stuff ||= []) << 'UserObserver'
      end
      """
    And the following code appears in "config/environment.rb" after /Rails::Initializer.run/:
      """
        config.active_record.observers = :user_observer
      """
    And a file named "spec/models/user_spec.rb" with:
      """
      describe User do
        it "does absoluately nothing" do
          Spork.state.should == :using_spork
          $loaded_stuff.should include('establish_connection')
          $loaded_stuff.should include('User')
          $loaded_stuff.should include('UserObserver')
          $loaded_stuff.should include('ApplicationHelper')
          puts "Specs successfully run within spork, and all initialization files were loaded"
        end
      end
      """
  Scenario: Analyzing files were preloaded
    When I run spork --diagnose
    Then the output should not contain "user_observer.rb"
    Then the output should not contain "user.rb"
    Then the output should not contain "app/controllers/application.rb"
    Then the output should not contain "app/controllers/application_controller.rb"
    Then the output should not contain "app/controllers/application_helper.rb"
  
  Scenario: Running spork with a rails app and observers
  
    When I fire up a spork instance with "spork rspec"
    And I run spec --drb spec/models/user_spec.rb 
    Then the output should contain "Specs successfully run within spork, and all initialization files were loaded"
