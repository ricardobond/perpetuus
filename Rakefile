require "bundler/gem_tasks"
require "rspec/core/rake_task"

require 'perpetuus'
require 'mg'

MG.new("perpetuus.gemspec")
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

task :reinstall do
  system 'gem uninstall perpetuus'
  system 'rake install'
end