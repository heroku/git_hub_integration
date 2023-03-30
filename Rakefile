require 'rake'
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Build and release the gem to Packagecloud.io'
task :packagecloud_release do
  gemspec = Gem::Specification.load(Dir.glob('*.gemspec').first)
  gem_file = "#{gemspec.name}-#{gemspec.version}.gem"

  puts "Building gem..."
  sh "gem build #{gemspec.name}.gemspec"

  puts "Pushing gem to Packagecloud.io..."
  sh "package_cloud push heroku/gemgate/rubygems #{gem_file}"
end
