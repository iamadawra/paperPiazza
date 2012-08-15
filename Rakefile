#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake'

require File.expand_path('../config/application', __FILE__)

Paperpiazza::Application.load_tasks
#require 'annotate/tasks'

#require 'rspec/core/rake_task'
#
#desc "Run non-JS specs"
RSpec::Core::RakeTask.new("non_js_specs") do |t|
  t.pattern = FileList.new(
    "./spec/models/**/*_spec.rb",
    "./spec/controllers/**/*_spec.rb",
    "./spec/requests/**/*_spec.rb",
  )
end

#desc "Run JS specs"
RSpec::Core::RakeTask.new("js_specs") do |t|
  t.pattern = "./spec/requests_js/*_spec.rb"
end
#
task :default => :non_js_specs


