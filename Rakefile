#!/usr/bin/env rake
DUMMY_PATH = "./spec/dummy"

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
  require 'rspec/core/rake_task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Translatable'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

# get access to db:create, db:migrate, in dummy app
load "#{DUMMY_PATH}/Rakefile"

desc 'Default: run the specs'
task :default => 'spec:unit'

namespace :spec do
  desc "Run unit specs"
  RSpec::Core::RakeTask.new('unit') do |t|
    t.pattern = 'spec/{*_spec.rb}'
  end
end

def move_database_config_into_place target, template
    unless File.exists? target
      cp template, target
      puts "database configuration is in place, please edit ./spec/dumm/config/database.yml according to your needs"
    else
      puts "database configuration is already present, please edit ./spec/dumm/config/database.yml according to your needs"
    end
  end
end

namespace :setup do
  desc "Move database.yml into place"
  task :database_config do
    config = "#{DUMMY_PATH}/config/database.yml"
    config_template = "#{config}.sample"
    move_database_config_into_place config, config_template
  end
end

namespace :travis do
  desc "Move database.yml into place"
  task :database_config do
    config = "#{DUMMY_PATH}/config/database.yml"
    config_template = "#{config}.travis"
    move_database_config_into_place confi, config_template
  end
end


# TODO document setup with rake tasks

desc "Run the unit specs"
task :spec => ['spec:unit']

