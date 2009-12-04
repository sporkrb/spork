Feature: Rails Delayed Work arounds
  To allow a rails developer to update as many parts of his application as possible without needing to restart Spork
  Spork automatically tells rails to delay loading certain parts of the application until after the fork occurs
  Providing work arounds

  Background: Rails App with RSpec and Spork

    Given I am in a fresh rails project named "test_rails_project"
    And a file named "spec/spec_helper.rb" with:
      """
      require 'rubygems'
      require 'spork'

      Spork.prefork do
        require File.dirname(__FILE__) + '/../config/environment.rb'
        require 'spec'
        require 'spec/rails'
      end

      Spork.each_run do
      end
      """
    And the application has a model, observer, route, and application helper
    Given a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        include Reverseatron
      end
      """
    Given a file named "lib/reverseatron.rb" with:
      """
      module Reverseatron
        def reverse_text(txt)
          txt.reverse
        end
      end
      """
    Given a file named "app/controllers/users_controller.rb" with:
      """
      class UsersController < ApplicationController
        $loaded_stuff << 'UsersController'
        def index
          @users = []
        end
      end
      """
    Given a file named "app/helpers/misc_helper.rb" with:
      """
      module MiscHelper
        def misc_helper_method
          'hello miscellaneous'
        end
      end
      """
    Given a file named "app/helpers/users_helper.rb" with:
      """
      module UsersHelper
      end
      """
    Given a file named "app/views/users/index.html.erb" with:
      """
        Original View
      """
  Scenario: within a view rendered by a controller, calling helper methods from an included module in ApplicationHelper
    Given a file named "spec/controllers/users_controller_spec.rb" with:
      """
      describe UsersController do
        integrate_views
        it "renders a page, using a method inherited from ApplicationController" do
          get :index
          response.body.should_not include('Original View')
          puts "Views are not being cached when rendering from a controller"

          response.body.should include('listing users')
          puts "Controller stack is functioning when rendering from a controller"

          response.body.should include('hello miscellaneous')
          puts "All helper modules were included when rendering from a controller"
        end
      end
      """
    Given a file named "spec/views/index.html.erb_spec.rb" with:
      """
      describe "/users/index.html.erb" do

        it "renders the view" do
          render
          response.body.should_not include('Original View')
          puts "Views are not being cached when rendering directly"

          response.body.should include('listing users')
          puts "Controller stack is functioning when rendering directly"

          response.body.should include('hello miscellaneous')
          puts "All helper modules were included when rendering directly"
        end
      end
      """
    When I fire up a spork instance with "spork rspec"
    And the contents of "app/views/users/index.html.erb" are changed to:
      """
      <%= reverse_text('listing users'.reverse) %>
      <%= misc_helper_method rescue nil %>
      <p>Here is a list of users</p>
      """
      
    And I run spec --drb spec/controllers/users_controller_spec.rb
    Then the output should contain "Controller stack is functioning when rendering from a controller"
    Then the output should contain "Views are not being cached when rendering from a controller"
    Then the output should contain "All helper modules were included when rendering from a controller"

    And I run spec --drb spec/views/index.html.erb_spec.rb
    Then the output should contain "Controller stack is functioning when rendering directly"
    Then the output should contain "Views are not being cached when rendering directly"
    Then the output should contain "All helper modules were included when rendering directly"
