require "bundler/gem_tasks"

desc 'Open a pry session preloaded with the library'
task :console do
  sh 'pry --gem'
end
task :c => :console

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
task :default => :spec

namespace :git do
  desc 'Bump git tag and release to origin'
  task :bump do
    require_relative 'lib/grifork'
    version = Grifork::VERSION
    sh "git commit -m #{version}"
    sh "git tag -a v#{version} -m #{version}"
    sh "git push origin master"
    sh "git push origin v#{version}"
  end
end
