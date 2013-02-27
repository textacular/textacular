require 'rake'
require 'textacular'

namespace :textacular do
  desc 'Create full text search index migration, give the model for which you want to create the indexes'
  task :create_index_migration, [:model_name] => :environment do |task, args|
    raise 'A model name is required' unless args[:model_name]
    Textacular::FullTextIndexer.new.generate_migration(args[:model_name])
  end

  desc "Install trigram text search module"
  task :install_trigram => [:environment] do
    installer = Textacular::PostgresModuleInstaller.new
    installer.install_module('pg_trgm')

    puts "Trigram text search module successfully installed into '#{installer.db_name}' database."
  end
end
