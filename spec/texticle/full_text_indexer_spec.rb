require 'spec_helper'

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

  context "when we've listed fields specific fields in a Searchable call" do
    setup do
      WebComic.extend Searchable(:name)
      @file_name = File.join('.', 'fake_migration.rb')
    end

    teardown do
      FileUtils.rm(@file_name)
    end

    should "generate the right sql" do
      expected_sql = <<-MIGRATION
lsfjfslkjef
MIGRATION

      assert_equal(expected_sql, File.read(@file_name))
    end
  end
end
