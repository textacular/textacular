require 'spec_helper'

describe Textacular::FullTextIndexer do
  describe "when we've listed one specific field in a Searchable call" do
    it "generate the right sql" do
      filename = "web_comic_with_searchable_name_full_text_search"
      content = <<-MIGRATION
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

      migration_generator = flexmock
      flexmock(Textacular::MigrationGenerator).
        it_receive(:new).
        with(content, filename).
        and_return(migration_generator)
      migration_generator.it_receive(:generate_migration)
      Textacular::FullTextIndexer.new.generate_migration('WebComicWithSearchableName')
    end
  end

  describe "when we've listed two specific fields in a Searchable call" do
    it "generate the right sql" do
      filename = "web_comic_with_searchable_name_and_author_full_text_search"
      content = <<-MIGRATION
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

      migration_generator = flexmock
      flexmock(Textacular::MigrationGenerator).
        it_receive(:new).
        with(content, filename).
        and_return(migration_generator)
      migration_generator.it_receive(:generate_migration)
      Textacular::FullTextIndexer.new.generate_migration('WebComicWithSearchableNameAndAuthor')
    end
  end
end
