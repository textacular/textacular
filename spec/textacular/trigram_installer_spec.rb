require 'spec_helper'

describe Textacular::TrigramInstaller do
  it "generate a migration" do
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
      it_receive(:new).
      with(filename, content).
      and_return(migration_generator)
    migration_generator.it_receive(:generate_migration)
    Textacular::TrigramInstaller.new.generate_migration
  end
end
