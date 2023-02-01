require 'test_helper'
require 'support/web_comic_with_searchable_name'
require 'support/web_comic_with_searchable_name_and_author'

class Textacular::FullTestIndexerTest < BaseTest
  test "with one specific field in a Searchable call generates the right SQL" do
    content = <<~MIGRATION
      class WebComicWithSearchableNameFullTextSearch < ActiveRecord::Migration
      def self.up
        execute(<<-SQL.strip)
          DROP index IF EXISTS web_comics_name_fts_idx;
          CREATE index web_comics_name_fts_idx
            ON web_comics
            USING gin(to_tsvector('english', "web_comics"."name"::text));
        SQL
      end

      def self.down
        execute(<<-SQL.strip)
          DROP index IF EXISTS web_comics_name_fts_idx;
        SQL
      end
      end
    MIGRATION
    output_stream = StringIO.new
    generator = Textacular::MigrationGenerator.new('WebComicWithSearchableName', content)
    generator.instance_variable_set(:@output_stream, output_stream)
    generator.generate_migration
    assert_equal content, output_stream.string
  end

  test "with two specific fields in a Searchable call generates the right SQL" do
    content = <<~MIGRATION
      class WebComicWithSearchableNameAndAuthorFullTextSearch < ActiveRecord::Migration
      def self.up
        execute(<<-SQL.strip)
          DROP index IF EXISTS web_comics_name_fts_idx;
          CREATE index web_comics_name_fts_idx
            ON web_comics
            USING gin(to_tsvector('english', "web_comics"."name"::text));
          DROP index IF EXISTS web_comics_author_fts_idx;
          CREATE index web_comics_author_fts_idx
            ON web_comics
            USING gin(to_tsvector('english', "web_comics"."author"::text));
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

    output_stream = StringIO.new
    generator = Textacular::MigrationGenerator.new('WebComicWithSearchableNameAndAuthor', content)
    generator.instance_variable_set(:@output_stream, output_stream)
    generator.generate_migration
    assert_equal content, output_stream.string

  end

end
