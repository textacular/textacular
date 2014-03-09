class Textacular::FullTextIndexer
  def generate_migration(model_name)
    content = <<-MIGRATION
class #{model_name}FullTextSearch < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      #{up_migration(model_name)}
    SQL
  end

  def self.down
    execute(<<-SQL.strip)
      #{down_migration(model_name)}
    SQL
  end
end
MIGRATION
    filename = "#{model_name.underscore}_full_text_search"
    generator = Textacular::MigrationGenerator.new(content, filename)
    generator.generate_migration
  end

  private

  def up_migration(model_name)
    migration_with_type(model_name, :up)
  end

  def down_migration(model_name)
    migration_with_type(model_name, :down)
  end

  def migration_with_type(model_name, type)
    sql_lines = ''

    model = Kernel.const_get(model_name)
    model.indexable_columns.each do |column|
      sql_lines << drop_index_sql_for(model, column)
      sql_lines << create_index_sql_for(model, column) if type == :up
    end

    sql_lines.strip.gsub("\n","\n      ")
  end

  def drop_index_sql_for(model, column)
    "DROP index IF EXISTS #{index_name_for(model, column)};\n"
  end

  def create_index_sql_for(model, column)
    # The spacing gets sort of wonky in here.

    <<-SQL
CREATE index #{index_name_for(model, column)}
  ON #{model.table_name}
  USING gin(to_tsvector("#{dictionary}", "#{model.table_name}"."#{column}"::text));
SQL
  end

  def index_name_for(model, column)
    "#{model.table_name}_#{column}_fts_idx"
  end

  def dictionary
    Textacular.searchable_language
  end
end
