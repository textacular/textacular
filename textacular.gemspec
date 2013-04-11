# -*- encoding: utf-8 -*-

require File.expand_path('../lib/textacular/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'textacular'
  s.version = Textacular::VERSION

  s.summary     = 'Textacular exposes full text search capabilities from PostgreSQL'
  s.description = 'Textacular exposes full text search capabilities from PostgreSQL, extending
    ActiveRecord with scopes making search easy and fun!'

  s.license  = 'MIT'
  s.authors  = ['Ben Hamill', 'ecin', 'Aaron Patterson']
  s.email    = ['git-commits@benhamill.com', 'ecin@copypastel.com']
  s.homepage = 'http://textacular.github.com/textacular'

  s.files         = [
    'CHANGELOG.md',
    'Gemfile',
    'README.md',
    'Rakefile',
    'lib/textacular.rb',
    'lib/textacular/full_text_indexer.rb',
    'lib/textacular/postgres_module_installer.rb',
    'lib/textacular/rails.rb',
    'lib/textacular/searchable.rb',
    'lib/textacular/tasks.rb',
    'lib/textacular/version.rb'
  ]
  s.executables   = []
  s.test_files    = [
    'spec/config.yml.example',
    'spec/fixtures/character.rb',
    'spec/fixtures/game.rb',
    'spec/fixtures/webcomic.rb',
    'spec/spec_helper.rb',
    'spec/textacular/searchable_spec.rb',
    'spec/textacular_spec.rb'
  ]
  s.require_paths = ['lib']

  s.add_development_dependency 'pg', '~> 0.14.0'
  s.add_development_dependency 'shoulda', '~> 2.11.3'
  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'

  s.add_dependency('activerecord', [">= 3.0", "< 4.1"])
end
