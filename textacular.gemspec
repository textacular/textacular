# -*- encoding: utf-8 -*-

require File.expand_path('../lib/textacular/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'textacular'
  s.version = Textacular::VERSION

  s.summary     = 'Textacular exposes full text search capabilities from PostgreSQL'
  s.description = 'Textacular exposes full text search capabilities from PostgreSQL, extending
    ActiveRecord with scopes making search easy and fun!'

  s.license  = 'MIT'
  s.authors  = ['Ben Hamill', 'ecin', 'Aaron Patterson', 'Greg Molnar']
  s.email    = ['git-commits@benhamill.com', 'ecin@copypastel.com']
  s.homepage = 'http://textacular.github.com/textacular'

  s.files         = [
    'CHANGELOG.md',
    'Gemfile',
    'README.md',
    'Rakefile',
    'lib/textacular.rb',
    'lib/textacular/full_text_indexer.rb',
    'lib/textacular/migration_generator.rb',
    'lib/textacular/postgres_module_installer.rb',
    'lib/textacular/rails.rb',
    'lib/textacular/searchable.rb',
    'lib/textacular/tasks.rb',
    'lib/textacular/trigram_installer.rb',
    'lib/textacular/version.rb'
  ]
  s.executables   = []

  s.require_paths = ['lib']

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'database_cleaner-active_record'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'byebug'

  s.add_dependency('activerecord', [">= 5.0", "< 7.3"])
end
