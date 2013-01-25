class Noarraything < ActiveRecord::Base
  serialize :locales
  translate :name
end
