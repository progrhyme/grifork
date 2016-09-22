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
