RSpec.describe "Textacular::TrigramInstaller" do
  let(:content) do
    <<-MIGRATION
class InstallTrigram < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
  end
end
MIGRATION
  end

  it "generates a migration" do
    generator = double(:migration_generator)

    expect(Textacular::MigrationGenerator).to receive(:new).with('install_trigram', content).and_return(generator)
    expect(generator).to receive(:generate_migration)

    Textacular::TrigramInstaller.new.generate_migration
  end
end
