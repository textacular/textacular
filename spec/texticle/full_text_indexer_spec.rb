require 'spec_helper'
require 'fileutils'
require 'ostruct'

require 'texticle/searchable'

class WebComic < ActiveRecord::Base
  # string :name
  # string :author
end

class FullTextIndexerTest < Test::Unit::TestCase
  context ".output_stream" do
    context "when Rails is not defined" do
      setup do
        @indexer = Texticle::FullTextIndexer.new
      end

      should "point to stdout" do
        assert_equal(@indexer.output_stream, $STDOUT)
      end
    end

    context "When Rails IS defined" do
      setup do
        module ::Rails
          # Stub this out, sort of.
          def self.root
            File.join("/", "foo", "bar", "baz")
          end
        end

        @now = OpenStruct.new(:now => Time.now)

        @indexer = Texticle::FullTextIndexer.new
      end

      teardown do
        Object.send(:remove_const, :Rails)
      end

      should "point to a properly named migration file" do
        expected_file_name = "/foo/bar/baz/db/migrate/#{@now.now.strftime('%Y%m%d%H%M%S')}_full_text_search.rb"

        assert_equal(expected_file_name, @indexer.output_stream(@now))
      end
    end
  end

  context "when we've listed one specific field in a Searchable call" do
    setup do
      WebComic.extend Searchable(:name)
      @indexer = Texticle::FullTextIndexer.new
      @output = StringIO.new
    end

    teardown do
      FileUtils.rm(@file_name)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
class FakeMigration < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
      CREATE index web_comics_name_fts_idx
        ON web_comics
        USING gin((to_tsvector("english", "webcomics"."name"::text)));
    SQL
  end

  def self.down
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
    SQL
  end
end
MIGRATION

      Texticle::FullTextIndexer.generate_migration(@file_name)

      assert_equal(expected_sql, File.read(@file_name))
    end
  end

  context "when we've listed two specific fields in a Searchable call" do
    setup do
      WebComic.extend Searchable(:name, :author)
      @file_name = File.join('.', 'fake_migration.rb')
    end

    teardown do
      FileUtils.rm(@file_name)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
class FakeMigration < ActiveRecord::Migration
  def self.up
    execute(<<-SQL.strip)
      DROP index IF EXISTS web_comics_name_fts_idx;
      CREATE index web_comics_name_fts_idx
        ON web_comics
        USING gin(to_tsvector("english", "webcomics"."name"::text));
      DROP index IF EXISTS web_comics_author_fts_idx;
      CREATE index web_comics_author_fts_idx
        ON web_comics
        USING gin(to_tsvector("english", "webcomics"."author"::text));
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

      Texticle::FullTextIndexer.generate_migration(@file_name)

      assert_equal(expected_sql, File.read(@file_name))
    end
  end
end
