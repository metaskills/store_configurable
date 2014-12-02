$:.push File.expand_path("../lib", __FILE__)
require "store_configurable/version"

Gem::Specification.new do |s|
  s.name          = 'store_configurable'
  s.version       = StoreConfigurable::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Ken Collins']
  s.email         = ['ken@metaskills.net']
  s.homepage      = 'http://github.com/metaskills/store_configurable/'
  s.summary       = 'A zero-configuration recursive Hash for storing a tree of options in a serialized ActiveRecord column.'
  s.description   = 'Grown up ActiveRecord::Store config options!'
  s.files         = `git ls-files`.split("\n") - ["store_configurable.gemspec"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options  = ['--charset=UTF-8']
  s.add_runtime_dependency     'activerecord', '>= 4.0'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-focus'
  s.add_development_dependency 'pry'
end
