class Texticle::FullTextIndexer
  def generate_migration
    stream_output do |io|
      io.puts(<<-MIGRATION)
class FullTextSearch < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      #{up_migration}
    SQL
  end

  def self.down
    execute(<<-SQL.strip)
      #{down_migration}
    SQL
  end
end
MIGRATION
    end
  end

  def stream_output(now = Time.now.utc, &block)
    if !@output_stream && Object.const_defined?(:Rails)
      File.open(migration_file_name(now), 'w', &block)
    else
      @output_stream ||= $stdout

      yield @output_stream
    end
  end

  private

  def migration_file_name(now = Time.now.utc)
    File.join(Rails.root, 'db', 'migrate',"#{now.strftime('%Y%m%d%H%M%S')}_full_text_search.rb")
  end

  def up_migration
    migration_with_type(:up)
  end

  def down_migration
    migration_with_type(:down)
  end

  def migration_with_type(type)
    sql_lines = ''

    for_each_indexable_model do |model|
      model.indexable_columns.each do |column|
        sql_lines << drop_index_sql_for(model, column)
        sql_lines << create_index_sql_for(model, column) if type == :up
      end
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

  def for_each_indexable_model(&block)
    ObjectSpace.each_object do |obj|
      if obj.respond_to?(:indexable_columns) && !obj.is_a?(ActiveRecord::Relation)
        block.call(obj)
      end
    end
  end

  def dictionary
    Texticle.searchable_language
  end
end
