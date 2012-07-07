# -*- encoding: utf-8 -*-

require File.expand_path('../lib/texticle', __FILE__)

Gem::Specification.new do |s|
  s.name    = %q{texticle}
  s.version = Texticle.version

  s.summary     = %q{Texticle exposes full text search capabilities from PostgreSQL}
  s.description = %q{Texticle exposes full text search capabilities from PostgreSQL, extending
    ActiveRecord with scopes making search easy and fun!}

  s.license  = "MIT"
  s.authors  = ["Ben Hamill", "ecin", "Aaron Patterson"]
  s.email    = ["git-commits@benhamill.com", "ecin@copypastel.com"]
  s.homepage = %q{http://texticle.github.com/texticle}

  s.files         = [
    "CHANGELOG.rdoc",
    "Manifest.txt",
    "README.rdoc",
    "Rakefile",
    "lib/texticle.rb",
    "lib/texticle/searchable.rb",
    "lib/texticle/rails.rb",
    "spec/spec_helper.rb",
    "spec/texticle_spec.rb",
    "spec/texticle/searchable_spec.rb",
    "spec/config.yml"
  ]
  s.executables   = []
  s.test_files    = ["spec/spec_helper.rb", "spec/texticle_spec.rb", "spec/config.yml"]
  s.require_paths = ["lib"]

  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.rdoc_options     = ["--main", "README.rdoc"]



  s.add_development_dependency(%q<pg>, ["~> 0.11.0"])
  s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
  s.add_development_dependency(%q<rake>, ["~> 0.9.0"])

  s.add_dependency(%q<activerecord>, ["~> 3.0"])
end
