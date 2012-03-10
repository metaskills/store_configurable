require 'bundler'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc 'Test the StoreConfigurable gem.'
Rake::TestTask.new do |t|
  t.libs = ['lib','test']
  t.test_files = Dir.glob("test/**/*_test.rb").sort
  t.verbose = true
end

task :default => [:test]
