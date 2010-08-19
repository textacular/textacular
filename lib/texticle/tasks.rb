require 'rake'
require 'texticle'

namespace :texticle do
  desc "Create full text index migration"
  task :migration => :environment do
    now = Time.now.utc
    filename = "#{now.strftime('%Y%m%d%H%M%S')}_full_text_search_#{now.to_i}.rb"
    File.open(Rails.root + 'db' + 'migrate' + filename, 'wb') { |fh|
      up_sql_statements = []
      dn_sql_statements = []

      Dir[Rails.root + 'app' + 'models' + '*.rb'].each do |f|
        klass = find_constant_of_model_in(f)
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
    }
  end

  desc "Create full text indexes"
  task :create_indexes => ['texticle:destroy_indexes'] do
    Dir[Rails.root + 'app' + 'models' + '*.rb'].each do |f|
      klass = find_constant_of_model_in(f)
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
    Dir[Rails.root + 'app' + 'models' + '*.rb'].each do |f|
      klass = find_constant_of_model_in(f)
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          fti.destroy
        end
      end
    end
  end

  def find_constant_of_model_in(filename)
    File.basename(filename, '.rb').pluralize.classify.constantize
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
