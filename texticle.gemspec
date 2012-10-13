# -*- encoding: utf-8 -*-

require File.expand_path('../lib/texticle/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'texticle'
  s.version = Texticle::VERSION

  s.summary     = 'Texticle exposes full text search capabilities from PostgreSQL'
  s.description = 'Texticle exposes full text search capabilities from PostgreSQL, extending
    ActiveRecord with scopes making search easy and fun!'

  s.license  = 'MIT'
  s.authors  = ['Ben Hamill', 'ecin', 'Aaron Patterson']
  s.email    = ['git-commits@benhamill.com', 'ecin@copypastel.com']
  s.homepage = 'http://texticle.github.com/texticle'

  s.files         = [
    'CHANGELOG.rdoc',
    'Gemfile',
    'Manifest.txt',
    'README.rdoc',
    'Rakefile',
    'lib/texticle.rb',
    'lib/texticle/full_text_indexer.rb',
    'lib/texticle/rails.rb',
    'lib/texticle/searchable.rb',
    'lib/texticle/tasks.rb'
  ]
  s.executables   = []
  s.test_files    = [
    'spec/config.yml.example',
    'spec/fixtures/character.rb',
    'spec/fixtures/game.rb',
    'spec/fixtures/webcomic.rb',
    'spec/spec_helper.rb',
    'spec/texticle/searchable_spec.rb',
    'spec/texticle_spec.rb'
  ]
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['Manifest.txt', 'CHANGELOG.rdoc', 'README.rdoc']
  s.rdoc_options     = ['--main', 'README.rdoc']



  s.add_development_dependency 'pg', '~> 0.11.0'
  s.add_development_dependency 'shoulda', '~> 2.11.3'
  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'

  s.add_dependency('activerecord', '~> 3.0')
end
