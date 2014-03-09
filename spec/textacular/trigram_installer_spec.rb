require 'spec_helper'

class TrigramInstallerTest < Test::Unit::TestCase
  context ".stream_output" do
    context "when Rails is not defined" do
      setup do
        @installer = Textacular::TrigramInstaller.new
      end

      should "point to stdout" do
        @output_stream = nil

        @installer.stream_output do |io|
          @output_stream = io
        end

        assert_equal(@output_stream, $stdout)
      end
    end

    context "When Rails IS defined" do
      setup do
        module ::Rails
          # Stub this out, sort of.
          def self.root
            File.join('.', 'fake_rails')
          end
        end

        @now = Time.now

        @installer = Textacular::TrigramInstaller.new
      end

      teardown do
        Object.send(:remove_const, :Rails)
        FileUtils.rm_rf(File.join('.', 'fake_rails'))
      end

      should "point to a properly named migration file" do
        expected_file_name = "./fake_rails/db/migrate/#{@now.strftime('%Y%m%d%H%M%S')}_install_trigram.rb"

        @output_stream = nil

        @installer.stream_output(@now) do |io|
          @output_stream = io
        end

        assert_equal(expected_file_name, @output_stream.path)
      end
    end
  end

  context "the content of the migration" do
    setup do
      @installer = Textacular::TrigramInstaller.new
      @output = StringIO.new
      @installer.instance_variable_set(:@output_stream, @output)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
class InstallTrigram < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE EXTENSION pg_trgm;")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
  end
end
MIGRATION

      @installer.generate_migration

      assert_equal(expected_sql, @output.string)
    end
  end
end
