require "active_record"
require "active_support/concern"
require "rails"
require "activerecord_translatable/extension"

module ActiveRecordTranslatable

  class Railtie < Rails::Railtie
    initializer "activerecord_translatable.load_into_active_record" do
      ActiveSupport.on_load :active_record do
        ActiveRecordTranslatable::Railtie.load
      end
    end
  end

  class Railtie
    class << self
      def load
        if defined?(ActiveRecord)
          ActiveRecord::Base.send(:include, ActiveRecordTranslatable)
        end
      end
    end
  end

end
