$:.push File.expand_path("../lib", __FILE__)

require "translatable"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "translatable"
  s.version     = Translatable::VERSION
  s.authors     = ["Philipp Fehre"]
  s.email       = ["philipp.fehre@gmail.com"]
  s.homepage    = "http://github.com/sideshowcoder/translatable"
  s.summary     = "make attributes of active record translatable via the normal i18n backend"
  s.description = "translatable activerecord attributes"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "pg"
  s.add_development_dependency "activerecord-postgres-array"
  s.add_development_dependency "rspec-rails"
end
