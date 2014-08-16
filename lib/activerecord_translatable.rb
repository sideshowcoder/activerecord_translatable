require "active_record"
require "active_support/concern"
require "activerecord_translatable/extension"

module ActiveRecordTranslatable
  begin
    require "rails"

    class Railtie < Rails::Railtie
      initializer "activerecord_translatable.load_into_active_record" do
        ActiveSupport.on_load :active_record do
          ActiveRecord::Base.send(:include, ActiveRecordTranslatable)
        end
      end
    end
  rescue LoadError
    ActiveRecord::Base.send(:include, ActiveRecordTranslatable) if defined?(ActiveRecord)
  end
end
