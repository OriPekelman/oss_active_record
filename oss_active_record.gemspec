$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oss_active_record/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oss_active_record"
  s.version     = OssActiveRecord::VERSION
  s.authors     = ["Ori Pekelman"]
  s.email       = ["ori@pekelman.com"]
  s.homepage    = "http://www.open-search-server.com"
  s.summary     = "Open search server ActiveRecord integration"
  s.description = "Open search server ActiveRecord integration"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0.rc2"

  s.add_development_dependency "sqlite3"
end
