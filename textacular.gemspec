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
  s.test_files    = [
    'spec/config.yml.example',
    'spec/config.travis.yml',
    'spec/spec_helper.rb',
    'spec/support/ar_stand_in.rb',
    'spec/support/character.rb',
    'spec/support/game.rb',
    'spec/support/game_extended_with_textacular.rb',
    'spec/support/game_extended_with_textacular_and_custom_language.rb',
    'spec/support/game_fail.rb',
    'spec/support/game_fail_extended_with_textacular.rb',
    'spec/support/not_there.rb',
    'spec/support/textacular_web_comic.rb',
    'spec/support/web_comic.rb',
    'spec/support/web_comic_with_searchable.rb',
    'spec/support/web_comic_with_searchable_name.rb',
    'spec/support/web_comic_with_searchable_name_and_author.rb',
    'spec/textacular_spec.rb',
    'spec/textacular/full_text_indexer_spec.rb',
    'spec/textacular/migration_generator_spec.rb',
    'spec/textacular/searchable_spec.rb',
    'spec/textacular/trigram_installer_spec.rb',
  ]
  s.require_paths = ['lib']

  s.add_development_dependency 'pg', '~> 0.14'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'

  s.add_dependency('activerecord', [">= 3.0", "< 5.2"])
end
