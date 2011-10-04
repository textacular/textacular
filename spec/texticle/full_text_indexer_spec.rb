require 'spec_helper'
require 'fileutils'

require 'texticle/searchable'

class WebComic < ActiveRecord::Base
  # string :name
  # string :author
end

class FullTextIndexerTest < Test::Unit::TestCase
  context ".default_file_name" do
    should "generate a file name for a time passed in" do
      now = Time.now.utc

      expected_file_name = "/foo/bar/baz/db/migrate/#{now.strftime('%Y%m%d%H%M%S')}_full_text_search_#{now.to_i}.rb"

      assert_equal(expected_file_name, Texticle::FullTextIndexer.default_file_name(now))
    end
  end

  context "when we've listed one specific field in a Searchable call" do
    should "generate the right sql" do
      WebComic.extend Searchable(:name)
      @file_name = File.join('.', 'fake_migration.rb')

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

      FileUtils.rm(@file_name)
    end
  end

  context "when we've listed two specific fields in a Searchable call" do
    should "generate the right sql" do
      WebComic.extend Searchable(:name, :author)
      @file_name = File.join('.', 'fake_migration.rb')

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

      FileUtils.rm(@file_name)
    end
  end
end
