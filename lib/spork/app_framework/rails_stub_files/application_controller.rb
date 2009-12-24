# This is a stub used to help Spork delay the loading of the real ApplicationController
class ::ApplicationController < ActionController::Base
  @@preloading = true
  class << self
    def inherited(klass)
      (@_descendants ||= []) << klass if @@preloading
      super
    end

    def reapply_inheritance!
      @@preloading = false
      Array(@_descendants).each do |descendant|
        descendant.master_helper_module.send(:include, master_helper_module)
        descendant.send(:default_helper_module!)

        descendant.respond_to?(:reapply_inheritance!) && descendant.reapply_inheritance!
      end
    end
  end
end

Spork.each_run { ApplicationController.reapply_inheritance! }
