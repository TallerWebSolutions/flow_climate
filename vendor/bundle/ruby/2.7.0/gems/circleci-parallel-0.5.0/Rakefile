require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new do |task|
  task.verbose = false
end

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new

task default: %i[spec rubocop]

task ci: %i[spec rubocop]
