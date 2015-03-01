class Textacular::TrigramInstaller
  def generate_migration
    content = <<-MIGRATION
class InstallTrigram < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
  end
end
MIGRATION
    filename = "install_trigram"
    generator = Textacular::MigrationGenerator.new(filename, content)
    generator.generate_migration
  end
end
