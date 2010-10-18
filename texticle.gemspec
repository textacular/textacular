# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{texticle}
  s.version = "1.0.4.20101015113653"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = %q{2010-10-15}
  s.description = %q{Texticle exposes full text search capabilities from PostgreSQL, and allows
you to declare full text indexes.  Texticle will extend ActiveRecord with
named_scope methods making searching easy and fun!}
  s.email = ["aaronp@rubyforge.org"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/texticle.rb", "lib/texticle/full_text_index.rb", "lib/texticle/railtie.rb", "lib/texticle/tasks.rb", "rails/init.rb", "test/helper.rb", "test/test_full_text_index.rb", "test/test_texticle.rb"]
  s.homepage = %q{http://texticle.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{texticle}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Texticle exposes full text search capabilities from PostgreSQL, and allows you to declare full text indexes}
  s.test_files = ["test/test_full_text_index.rb", "test/test_texticle.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
