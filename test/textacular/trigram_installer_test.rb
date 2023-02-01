require 'test_helper'
class Textacular::TrigramInstallerTest < BaseTest
  test "generates a migration" do
    content = <<~MIGRATION
    class InstallTrigram < ActiveRecord::Migration[5.0]
      def self.up
        ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
      end

      def self.down
        ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
      end
    end
    MIGRATION

    output_stream = StringIO.new
    generator = Textacular::MigrationGenerator.new('install_trigram', content)
    generator.instance_variable_set(:@output_stream, output_stream)
    generator.generate_migration
    assert_equal content, output_stream.string
  end
end
