require 'rake'
require 'texticle'

namespace :texticle do
  desc 'Create full text search index migration, give the model for which you want to create the indexes'
  task :create_index_migration, [:model_name] => :environment do |task, args|
    raise 'A model name is required' unless args[:model_name]
    Texticle::FullTextIndexer.new.generate_migration(args[:model_name])
  end

  desc "Install trigram text search module"
  task :install_trigram => [:environment] do
    share_dir = `pg_config --sharedir`.chomp

    raise RuntimeError, "Cannot find Postgres's shared directory." unless $?.success?

    trigram = "#{share_dir}/contrib/pg_trgm.sql"

    unless system("ls #{trigram}")
      raise RuntimeError, 'cannot find trigram module; was it compiled and installed?'
    end

    db_name = ActiveRecord::Base.connection.current_database

    unless system("psql -d #{db_name} -f #{trigram}")
      raise RuntimeError, "`psql -d #{db_name} -f #{trigram}` cannot complete successfully"
    end

    puts "Trigram text search module successfully installed into '#{db_name}' database."
  end
end
