# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{texticle}
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ecin", "Aaron Patterson"]
  s.date = %q{2011-08-30}
  s.description = %q{Texticle exposes full text search capabilities from PostgreSQL, extending
    ActiveRecord with scopes making search easy and fun!}
  s.email = ["ecin@copypastel.com"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/texticle.rb", "lib/texticle/searchable.rb",
    "lib/texticle/rails.rb", "spec/spec_helper.rb", "spec/texticle_spec.rb", "spec/texticle/searchable_spec.rb", "spec/config.yml"]
  s.homepage = %q{http://tenderlove.github.com/texticle}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{texticle}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Texticle exposes full text search capabilities from PostgreSQL}
  s.test_files = ["spec/spec_helper.rb", "spec/texticle_spec.rb", "spec/config.yml"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<pg>, ["~> 0.11.0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.0"])
      s.add_development_dependency(%q<ruby-debug19>, ["~> 0.11.6"])

      s.add_dependency(%q<activerecord>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<pg>, ["~> 0.11.0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<rake>, ["~> 0.8.0"])
      s.add_dependency(%q<ruby-debug19>, ["~> 0.11.6"])
      s.add_dependency(%q<activerecord>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<pg>, ["~> 0.11.0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<rake>, ["~> 0.8.0"])
    s.add_dependency(%q<ruby-debug19>, ["~> 0.11.6"])
    s.add_dependency(%q<activerecord>, ["~> 3.0"])
  end
end
