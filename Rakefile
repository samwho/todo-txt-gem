require 'rspec/core/rake_task'

task :default => [:test]

desc "Run all tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = '-cfs'
end
