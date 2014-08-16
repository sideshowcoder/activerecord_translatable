$:.unshift "#{File.dirname(__FILE__)}/lib"

require "sqlite3"
require "active_record"
require "activerecord_translatable"

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
