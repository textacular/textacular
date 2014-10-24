require 'support/web_comic_with_searchable_name'
require 'support/web_comic_with_searchable_name_and_author'

RSpec.describe Textacular::FullTextIndexer do
  context "with one specific field in a Searchable call" do
    it "generates the right SQL" do
      file_name = "web_comic_with_searchable_name_full_text_search"
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

      generator = double(:migration_generator)
      expect(Textacular::MigrationGenerator).to receive(:new).with(content, file_name).and_return(generator)
      expect(generator).to receive(:generate_migration)

      Textacular::FullTextIndexer.new.generate_migration('WebComicWithSearchableName')
    end
  end

  context "with two specific fields in a Searchable call" do
    it "generates the right SQL" do
      file_name = "web_comic_with_searchable_name_and_author_full_text_search"
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

      generator = double(:migration_generator)
      expect(Textacular::MigrationGenerator).to receive(:new).with(content, file_name).and_return(generator)
      expect(generator).to receive(:generate_migration)

      Textacular::FullTextIndexer.new.generate_migration('WebComicWithSearchableNameAndAuthor')
    end
  end
end
