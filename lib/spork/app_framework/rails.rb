class Spork::AppFramework::Rails < Spork::AppFramework

  # TODO - subclass this out to handle different versions of rails
  # Also... this is the nastiest duck punch ever.  Clean this up.
  module NinjaPatcher
    def self.included(klass)
      klass.class_eval do
        unless method_defined?(:load_environment_without_spork)
          alias :load_environment_without_spork :load_environment
          alias :load_environment :load_environment_with_spork
        end

        def self.run_with_spork(*args, &block) # it's all fun and games until someone gets an eye poked out
          if ENV['RAILS_ENV']
            Object.send(:remove_const, :RAILS_ENV)
            Object.const_set(:RAILS_ENV, ENV['RAILS_ENV'].dup)
          end
          run_without_spork(*args, &block)
        end

        class << self
          unless method_defined?(:run_without_spork)
            alias :run_without_spork :run
            alias :run :run_with_spork
          end
        end
      end
    end

    def load_environment_with_spork
      result = load_environment_without_spork
      install_hooks
      result
    end

    def install_hooks
      auto_reestablish_db_connection
      delay_observer_loading
      delay_app_preload
      delay_application_controller_loading
      delay_route_loading
      delay_eager_view_loading
    end

    def reset_rails_env
      return unless ENV['RAILS_ENV']
      Object.send(:remove_const, :RAILS_ENV)
      Object.const_set(:RAILS_ENV, ENV['RAILS_ENV'].dup)
    end

    def delay_observer_loading
      if ::Rails::Initializer.instance_methods.map(&:to_sym).include?(:load_observers)
        Spork.trap_method(::Rails::Initializer, :load_observers)
      end
      if Object.const_defined?(:ActionController)
        require "action_controller/dispatcher.rb"
        Spork.trap_class_method(::ActionController::Dispatcher, :define_dispatcher_callbacks) if ActionController::Dispatcher.respond_to?(:define_dispatcher_callbacks)
      end
    end

    def delay_app_preload
      if ::Rails::Initializer.instance_methods.map(&:to_sym).include?(:load_application_classes)
        Spork.trap_method(::Rails::Initializer, :load_application_classes)
      end
    end

    def delay_application_controller_loading
      if application_controller_source = ["#{Dir.pwd}/app/controllers/application.rb", "#{Dir.pwd}/app/controllers/application_controller.rb"].find { |f| File.exist?(f) }
        application_helper_source = "#{Dir.pwd}/app/helpers/application_helper.rb"
        load_paths = (::ActiveSupport.const_defined?(:Dependencies) ? ::ActiveSupport::Dependencies : ::Dependencies).load_paths
        load_paths.unshift(File.expand_path('rails_stub_files', File.dirname(__FILE__)))
        Spork.each_run do
          require application_controller_source
          require application_helper_source if File.exist?(application_helper_source)
          # update the rails magic to refresh the module
          ApplicationController.send(:helper, ApplicationHelper)
        end
      end
    end

    def auto_reestablish_db_connection
      if Object.const_defined?(:ActiveRecord)
        Spork.each_run do
          # rails lib/test_help.rb is very aggressive about overriding RAILS_ENV and will switch it back to test after the cucumber env was loaded
          reset_rails_env
          ActiveRecord::Base.establish_connection
        end
      end
    end

    def delay_route_loading
      if ::Rails::Initializer.instance_methods.map(&:to_sym).include?(:initialize_routing)
        Spork.trap_method(::Rails::Initializer, :initialize_routing)
      end
    end

    def delay_eager_view_loading
      # So, in testing mode it seems it would be optimal to not eager load
      # views (as your may only run a test that uses one or two views).
      # However, I decided to delay eager loading rather than force it to
      # disable because you may wish to eager load your views (I.E. you're
      # testing concurrency)

      # Rails 2.3.x +
      if defined?(::ActionView::Template::EagerPath)
        Spork.trap_method(::ActionView::Template::EagerPath, :load!)
      end
      # Rails 2.2.x
      if defined?(::ActionView::PathSet::Path)
        Spork.trap_method(::ActionView::PathSet::Path, :load)
      end
      # Rails 2.0.5 - 2.1.x don't appear to eager cache views.
    end
  end

  def preload(&block)
    STDERR.puts "Preloading Rails environment"
    STDERR.flush
    ENV["RAILS_ENV"] ||= 'test'
    preload_rails
    yield
  end

  def entry_point
    @entry_point ||= File.expand_path("config/environment.rb", Dir.pwd)
  end

  alias :environment_file :entry_point

  def boot_file
    @boot_file ||= File.join(File.dirname(environment_file), 'boot')
  end

  def environment_contents
    @environment_contents ||= File.read(environment_file)
  end

  def vendor
    @vendor ||= File.expand_path("vendor/rails", Dir.pwd)
  end

  def version
    @version ||= (
      if /^[^#]*RAILS_GEM_VERSION\s*=\s*["']([!~<>=]*\s*[\d.]+)["']/.match(environment_contents)
        $1
      else
        nil
      end
    )
  end

  def preload_rails
    Object.const_set(:RAILS_GEM_VERSION, version) if version
    require boot_file
    ::Rails::Initializer.send(:include, Spork::AppFramework::Rails::NinjaPatcher)
  end

end
