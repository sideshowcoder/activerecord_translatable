class Something < ActiveRecord::Base
  include Translatable

  translate :name
end
