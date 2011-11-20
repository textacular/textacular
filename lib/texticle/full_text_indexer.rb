class Texticle::FullTextIndexer
  def generate_migration(model_name)
    stream_output do |io|
      io.puts(<<-MIGRATION)
class FullTextSearch < ActiveRecord::Migration
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
    end
  end

  def stream_output(now = Time.now.utc, &block)
    if !@output_stream && defined?(Rails)
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
  USING gin(to_tsvector('#{dictionary}', '#{column}'::text));
SQL
  end

  def index_name_for(model, column)
    "#{model.table_name}_#{column}_fts_idx"
  end

  #def for_each_indexable_model(&block)
  #  ObjectSpace.each_object(Class) do |obj|
  #    begin
  #      puts obj.name if obj.name == 'Note'
  #      if obj < ActiveRecord::Base
  #        puts "Check #{obj.name} .."
  #        if obj.respond_to?(:indexable_columns)
  #          puts " ===> found a class: #{obj.name}"
  #          block.call(obj)
  #        end
  #      end
  #    rescue
  #      # ignore errors
  #    end
  #  end
  #end

  def dictionary
    Texticle.searchable_language
  end
end
