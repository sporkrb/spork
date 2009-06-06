class Spork::AppFramework::Rails < Spork::AppFramework
  
  # TODO - subclass this out to handle different versions of rails
  class NinjaPatcher
    def self.run
      ::Rails::Initializer.class_eval do
        alias :load_environment_without_spork :load_environment unless method_defined?(:load_environment_without_spork)
        def load_environment
          result = load_environment_without_spork
          Spork::AppFramework[:Rails].ninja_patcher.install_hooks
          result
        end
      end
    end
    
    def self.install_hooks
      auto_reestablish_db_connection
      delay_observer_loading
      delay_app_preload
      delay_application_controller_loading
    end
    
    def self.delay_observer_loading
      if ::Rails::Initializer.instance_methods.include?('load_observers')
        Spork.trap_method(::Rails::Initializer, :load_observers)
      end
      if Object.const_defined?(:ActionController)
        require "action_controller/dispatcher.rb"
        Spork.trap_class_method(::ActionController::Dispatcher, :define_dispatcher_callbacks) if ActionController::Dispatcher.respond_to?(:define_dispatcher_callbacks)
      end
    end
    
    def self.delay_app_preload
      if ::Rails::Initializer.instance_methods.include?('load_application_classes')
        Spork.trap_method(::Rails::Initializer, :load_application_classes)
      end
    end
    
    def self.delay_application_controller_loading
      if application_controller_source = ["#{Dir.pwd}/app/controllers/application.rb", "#{Dir.pwd}/app/controllers/application_controller.rb"].find { |f| File.exist?(f) }
        application_helper_source = "#{Dir.pwd}/app/helpers/application_helper.rb"
        load_paths = (::ActiveSupport.const_defined?(:Dependencies) ? ::ActiveSupport::Dependencies : ::Dependencies).load_paths
        load_paths.unshift(File.expand_path('rails_stub_files', File.dirname(__FILE__)))
        Spork.each_run do
          require application_controller_source
          require application_helper_source if File.exist?(application_helper_source)
        end
      end
    end
    
    def self.auto_reestablish_db_connection
      if Object.const_defined?(:ActiveRecord)
        Spork.each_run do
          ActiveRecord::Base.establish_connection
        end
      end
    end
  end
  
  def bootstrap_required?
    false
  end
  
  def preload(&block)
    STDERR.puts "Preloading Rails environment"
    STDERR.flush
    ENV["RAILS_ENV"] ||= 'test'
    preload_rails
    require environment_file
    yield
  end
  
  def environment_file
    @environment_file ||= File.expand_path("config/environment.rb", Dir.pwd)
  end
  
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
  
  def ninja_patcher
    ::Spork::AppFramework::Rails::NinjaPatcher
  end
  
  def preload_rails
    Object.const_set(:RAILS_GEM_VERSION, version) if version
    require boot_file
    ninja_patcher.run
  end
  
end