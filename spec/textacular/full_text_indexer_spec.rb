require 'spec_helper'
require 'fileutils'

class FullTextIndexerTest < Test::Unit::TestCase
  context ".stream_output" do
    context "when Rails is not defined" do
      setup do
        @indexer = Textacular::FullTextIndexer.new
      end

      should "point to stdout" do
        @output_stream = nil

        @indexer.stream_output do |io|
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

        FileUtils.mkdir_p(File.join('.', 'fake_rails', 'db', 'migrate'))

        @now = Time.now

        @indexer = Textacular::FullTextIndexer.new
      end

      teardown do
        Object.send(:remove_const, :Rails)
        FileUtils.rm_rf(File.join('.', 'fake_rails'))
      end

      should "point to a properly named migration file" do
        expected_file_name = "./fake_rails/db/migrate/#{@now.strftime('%Y%m%d%H%M%S')}_full_text_search.rb"

        @output_stream = nil

        @indexer.stream_output(@now) do |io|
          @output_stream = io
        end

        assert_equal(expected_file_name, @output_stream.path)
      end
    end
  end

  context "when we've listed one specific field in a Searchable call" do
    setup do
      @indexer = Textacular::FullTextIndexer.new
      @output = StringIO.new
      @indexer.instance_variable_set(:@output_stream, @output)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
class WebComicWithSearchableNameFullTextSearch < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
      CREATE index web_comics_name_fts_idx
        ON web_comics
        USING gin(to_tsvector("english", "web_comics"."name"::text));
    SQL
  end

  def self.down
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
    SQL
  end
end
MIGRATION

      @indexer.generate_migration('WebComicWithSearchableName')

      assert_equal(expected_sql, @output.string)
    end
  end

  context "when we've listed two specific fields in a Searchable call" do
    setup do
      @indexer = Textacular::FullTextIndexer.new
      @output = StringIO.new
      @indexer.instance_variable_set(:@output_stream, @output)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
class WebComicWithSearchableNameAndAuthorFullTextSearch < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
      CREATE index web_comics_name_fts_idx
        ON web_comics
        USING gin(to_tsvector("english", "web_comics"."name"::text));
      DROP index IF EXISTS web_comics_author_fts_idx;
      CREATE index web_comics_author_fts_idx
        ON web_comics
        USING gin(to_tsvector("english", "web_comics"."author"::text));
    SQL
  end

  def self.down
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
      DROP index IF EXISTS web_comics_author_fts_idx;
    SQL
  end
end
MIGRATION

      @indexer.generate_migration('WebComicWithSearchableNameAndAuthor')

      assert_equal(expected_sql, @output.string)
    end
  end
end
