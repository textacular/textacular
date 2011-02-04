require 'rake'
require 'texticle'

namespace :texticle do
  desc "Create full text index migration"
  task :migration => :environment do
    now = Time.now.utc
    filename = "#{now.strftime('%Y%m%d%H%M%S')}_full_text_search_#{now.to_i}.rb"
    File.open(Rails.root + 'db' + 'migrate' + filename, 'wb') do |fh|
      up_sql_statements = []
      dn_sql_statements = []

      Dir[Rails.root + 'app' + 'models' + '**/*.rb'].each do |f|
        klass = Texticle::FullTextIndex.find_constant_of(f)
        if klass.respond_to?(:full_text_indexes)
          (klass.full_text_indexes || []).each do |fti|
            up_sql_statements << fti.destroy_sql
            up_sql_statements << fti.create_sql
            dn_sql_statements << fti.destroy_sql
          end
        end
      end

      fh.puts "class FullTextSearch#{now.to_i} < ActiveRecord::Migration"
      fh.puts "  def self.up"
      insert_sql_statements_into_migration_file(up_sql_statements, fh)
      fh.puts "  end"
      fh.puts ""

      fh.puts "  def self.down"
      insert_sql_statements_into_migration_file(dn_sql_statements, fh)
      fh.puts "  end"
      fh.puts "end"
    end
  end

  desc "Create full text indexes"
  task :create_indexes => ['texticle:destroy_indexes'] do
    Dir[Rails.root + 'app' + 'models' + '**/*.rb'].each do |f|
      klass = Texticle::FullTextIndex.find_constant_of(f)
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          begin
            fti.create
          rescue ActiveRecord::StatementInvalid => e
            warn "WARNING: Couldn't create index for #{klass.to_s}, skipping..."
          end
        end
      end
    end
  end

  desc "Destroy full text indexes"
  task :destroy_indexes => [:environment] do
    Dir[Rails.root + 'app' + 'models' + '**/*.rb'].each do |f|
      klass = Texticle::FullTextIndex.find_constant_of(f)
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          fti.destroy
        end
      end
    end
  end

  desc "Install trigram text search module"
  task :install_trigram => [:environment] do
    share_dir = `pg_config --sharedir`.chomp
    raise RuntimeError, 'cannot find Postgres\' shared directory' unless $?.exitstatus.zero?
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

  def insert_sql_statements_into_migration_file statements, fh
    statements.each do |statement|
      fh.puts <<-eostmt
    execute(<<-'eosql'.strip)
      #{statement}
    eosql
      eostmt
    end
  end
end
