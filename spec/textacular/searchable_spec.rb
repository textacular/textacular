require 'spec_helper'
require 'textacular/searchable'

describe Searchable do
  describe "when extending an ActiveRecord::Base subclass" do
    describe "with no parameters" do
      before do
        @qcont = WebComicWithSearchable.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchable.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchable.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchable.create :name => "Penny Arcade", :author => "Tycho & Gabe"
        @null  = WebComicWithSearchable.create :author => 'Foo'
      end

      after do
        WebComicWithSearchable.delete_all
      end

      it "search across all columns" do
        assert_equal [@penny], WebComicWithSearchable.advanced_search("Penny")
        assert_equal [@ddeeg], WebComicWithSearchable.advanced_search("Dominic")
      end

      it "still rank with NULL columns" do
        comic = WebComicWithSearchable.basic_search('Foo').first
        rank = comic.attributes.find { |key, value| key.to_s =~ /\Arank\d+\z/ }.last

        assert rank
      end
    end

    describe "with one column as parameter" do
      before do
        @qcont = WebComicWithSearchableName.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchableName.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchableName.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchableName.create :name => "Penny Arcade", :author => "Tycho & Gabe"
      end

      after do
        WebComicWithSearchableName.delete_all
      end

      it "only search across the given column" do
        assert_equal [@penny], WebComicWithSearchableName.advanced_search("Penny")
        assert_empty WebComicWithSearchableName.advanced_search("Tycho")
      end

      ["hello \\", "tebow!" , "food &"].each do |search_term|
        it "be fine with searching for crazy character #{search_term} with plain search" do
          # Uses plainto_tsquery
          assert_equal [], WebComicWithSearchableName.basic_search(search_term)
        end

        it "be not fine with searching for crazy character #{search_term} with advanced search" do
          # Uses to_tsquery
          assert_raise(ActiveRecord::StatementInvalid) do
            WebComicWithSearchableName.advanced_search(search_term).first
          end
        end
      end

      it "fuzzy search stuff" do
        assert_equal [@qcont], WebComicWithSearchableName.fuzzy_search('Questio')
      end

      it "define :searchable_columns as private" do
        assert_raise(NoMethodError) { WebComicWithSearchableName.searchable_columns }
        begin
          WebComicWithSearchableName.searchable_columns
        rescue NoMethodError => error
          assert_match /private method/, error.message
        end
      end

      it "define #indexable_columns which returns a write-proof Enumerable" do
        assert_equal(Enumerator, WebComicWithSearchableName.indexable_columns.class)
        assert_raise(NoMethodError) { WebComicWithSearchableName.indexable_columns[0] = 'foo' }
      end
    end

    describe "with two columns as parameters" do
      before do
        @qcont = WebComicWithSearchableNameAndAuthor.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchableNameAndAuthor.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchableNameAndAuthor.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchableNameAndAuthor.create :name => "Penny Arcade", :author => "Tycho & Gabe"
      end

      after do
        WebComicWithSearchableNameAndAuthor.delete_all
      end

      it "only search across the given column" do
        assert_equal [@penny], WebComicWithSearchableNameAndAuthor.advanced_search("Penny")
        assert_equal [@penny], WebComicWithSearchableNameAndAuthor.advanced_search("Tycho")
      end
      it "allow includes" do
        assert_equal [@penny], WebComicWithSearchableNameAndAuthor.includes(:characters).advanced_search("Penny")
      end
    end
  end
end
