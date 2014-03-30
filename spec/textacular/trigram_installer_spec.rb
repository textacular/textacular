require 'spec_helper'

class TrigramInstallerTest < Test::Unit::TestCase
  should "generate a migration" do
    content = <<-MIGRATION
class InstallTrigram < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE EXTENSION pg_trgm;")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
  end
end
MIGRATION
    filename = "install_trigram"
    migration_generator = flexmock
    flexmock(Textacular::MigrationGenerator).
      should_receive(:new).
      with(content, filename).
      and_return(migration_generator)
    migration_generator.should_receive(:generate_migration)
    Textacular::TrigramInstaller.new.generate_migration
  end
end
