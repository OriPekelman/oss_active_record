$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oss_active_record/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'oss_active_record'
  s.version     = OssActiveRecord::VERSION
  s.authors     = ['Ori Pekelman', 'Emmanuel Keller']
  s.email       = ['ori@pekelman.com', 'ekeller@open-search-server.com']
  s.homepage    = 'https://github.com/jaeksoft/oss_active_record'
  s.summary     = 'OpenSearchServer ActiveRecord integration'
  s.description = 'oss_active_record is a library providing an all-ruby API for the OpenSearchServer search engine.'
  s.license     = 'MIT'

  s.metadata      = { 'Issues' => 'https://github.com/jaeksoft/oss_active_record/issues' }

  s.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.0.0'
  s.add_dependency 'oss_rb', '>= 0.2.0'
  s.add_development_dependency 'sqlite3'
end
