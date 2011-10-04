require 'spec_helper'
require 'texticle/searchable'

class WebComic < ActiveRecord::Base
  # string :name
  # string :author
end

class SearchableTest < Test::Unit::TestCase

  context "when extending an ActiveRecord::Base subclass" do
    setup do
      @qcont = WebComic.create :name => "Questionable Content", :author => "Jeff Jaques"
      @jhony = WebComic.create :name => "Johnny Wander", :author => "Ananth & Yuko"
      @ddeeg = WebComic.create :name => "Dominic Deegan", :author => "Mookie"
      @penny = WebComic.create :name => "Penny Arcade", :author => "Tycho & Gabe"
    end

    teardown do
      WebComic.delete_all
    end

    context "with no paramters" do
      setup do
        WebComic.extend Searchable
      end

      should "search across all columns" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_equal [@ddeeg], WebComic.search("Dominic")
      end
    end

    context "with one column as parameter" do
      setup do
        WebComic.extend Searchable(:name)
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_empty WebComic.search("Tycho")
      end

      should "define :searchable_columns as private" do
        assert_raise(NoMethodError) { WebComic.searchable_columns }
        begin
          WebComic.searchable_columns
        rescue NoMethodError => error
          assert_match error.message, /private method/
        end
      end

      should "define #indexable_columns which returns a write-proof Enumerable" do
        assert_equal(Enumerator, WebComic.indexable_columns.class)
        assert_raise(NoMethodError) { WebComic.indexable_columns[0] = 'foo' }
      end
    end

    context "with two columns as parameters" do
      setup do
        WebComic.extend Searchable(:name, :author)
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_equal [@penny], WebComic.search("Tycho")
      end
    end
  end

end
