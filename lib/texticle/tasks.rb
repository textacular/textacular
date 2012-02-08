require 'rake'
require 'texticle'

namespace :texticle do
  desc "Install trigram text search module"
  task :install_trigram => [:environment] do
    db_name = ActiveRecord::Base.connection.current_database

    Texticle::PostgresModuleInstaller.new(db_name).install_module('pg_trgm')

    puts "Trigram text search module successfully installed into '#{db_name}' database."
  end
end
