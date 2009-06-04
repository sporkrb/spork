class Spork::AppFramework
  SUPPORTED_FRAMEWORKS = {
    :Rails => lambda do
      File.exist?("config/environment.rb") && File.read("config/environment.rb").include?('RAILS_GEM_VERSION')
    end
  }
  
  def self.detect_framework_name
    SUPPORTED_FRAMEWORKS.each do |key, value|
      return key if value.call
    end
    :Unknown
  end
  
  def self.detect_framework
    name = detect_framework_name
    self[name]
  end
  
  def self.[](name)
    instances[name] ||= (
      require File.join(File.dirname(__FILE__), "app_framework", name.to_s.downcase)
      const_get(name).new
    )
  end
  
  def self.instances
    @instances ||= {}
  end
  
  def self.short_name
    name.gsub('Spork::AppFramework::', '')
  end
  
  def bootstrap_required?
    raise NotImplemented
  end
  
  def preload(&block)
    yield
  end
  
  def name
    self.class.short_name
  end
end