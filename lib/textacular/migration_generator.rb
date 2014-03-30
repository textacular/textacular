require 'fileutils'

class Textacular::MigrationGenerator
  def initialize(filename, content)
    @filename = filename
    @content = content
  end

  def generate_migration
    stream_output do |io|
      io.puts(@content)
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
    File.join(Rails.root, 'db', 'migrate',"#{now.strftime('%Y%m%d%H%M%S')}_#{@filename}.rb")
  end
end
