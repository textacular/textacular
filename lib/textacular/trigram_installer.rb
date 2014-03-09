require 'fileutils'

class Textacular::TrigramInstaller
  def generate_migration
    stream_output do |io|
      io.puts(<<-MIGRATION)
class InstallTrigram < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE EXTENSION pg_trgm;")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
  end
end
MIGRATION
    end
  end

  def stream_output(now = Time.now.utc, &block)
    if !@output_stream && defined?(Rails)
      FileUtils.mkdir_p(File.dirname(migration_file_name(now)))
      File.open(migration_file_name(now), 'w', &block)
    else
      @output_stream ||= $stdout

      yield @output_stream
    end
  end

  private

  def migration_file_name(now = Time.now.utc)
    File.join(Rails.root, 'db', 'migrate',"#{now.strftime('%Y%m%d%H%M%S')}_install_trigram.rb")
  end
end
