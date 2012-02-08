require 'rake'
require 'texticle'

namespace :texticle do
  desc "Install trigram text search module"
  task :install_trigram => [:environment] do
    installer = Texticle::PostgresModuleInstaller.new
    installer.install_module('pg_trgm')

    puts "Trigram text search module successfully installed into '#{installer.db_name}' database."
  end
end
