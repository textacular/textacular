class Texticle::FullTextIndexer
  def self.generate_migration(now = Time.now.utc)
    now = Time.now.utc
    filename = "#{now.strftime('%Y%m%d%H%M%S')}_full_text_search_#{now.to_i}.rb"

    File.open(File.join(Rails.root, 'db', 'migrate', filename), 'wb') do |migration_file|
      up_sql_statements = []
      down_sql_statements = []

      Dir[File.join(Rails.root, 'app', 'models', '**/*.rb')].each do |model_file|
        klass = Texticle::FullTextIndex.find_constant_of(model_file)

        if klass.respond_to?(:full_text_indexes)
          klass.full_text_indexes.each do |fti|
            fti.up_sql_statements << fti.destroy_sql
            fti.up_sql_statements << fti.create_sql
            fti.down_sql_statements << fti.destroy_sql
          end
        end
      end

      fh.puts "class FullTextSearch#{now.to_i} < ActiveRecord::Migration"
      fh.puts "  def self.up"
      insert_sql_statements_into_migration_file(up_sql_statements, fh)
      fh.puts "  end\n"

      fh.puts "  def self.down"
      insert_sql_statements_into_migration_file(dn_sql_statements, fh)
      fh.puts "  end"
      fh.puts "end"
    end
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
