class Something < ActiveRecord::Base
  include ActiveRecordTranslatable

  translate :name
end
