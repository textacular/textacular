require 'spec_helper'
require 'textacular/searchable'

class SearchableTest < Test::Unit::TestCase
  context "when extending an ActiveRecord::Base subclass" do
    context "with no parameters" do
      setup do
        @qcont = WebComicWithSearchable.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchable.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchable.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchable.create :name => "Penny Arcade", :author => "Tycho & Gabe"
      end

      teardown do
        WebComicWithSearchable.delete_all
      end

      should "search across all columns" do
        assert_equal [@penny], WebComicWithSearchable.advanced_search("Penny")
        assert_equal [@ddeeg], WebComicWithSearchable.advanced_search("Dominic")
      end
    end

    context "with one column as parameter" do
      setup do
        @qcont = WebComicWithSearchableName.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchableName.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchableName.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchableName.create :name => "Penny Arcade", :author => "Tycho & Gabe"
      end

      teardown do
        WebComicWithSearchableName.delete_all
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComicWithSearchableName.advanced_search("Penny")
        assert_empty WebComicWithSearchableName.advanced_search("Tycho")
      end

      ["hello \\", "tebow!" , "food &"].each do |search_term|
        should "be fine with searching for crazy character #{search_term} with plain search" do
          # Uses plainto_tsquery
          assert_equal [], WebComicWithSearchableName.basic_search(search_term)
        end

        should "be not fine with searching for crazy character #{search_term} with advanced search" do
          # Uses to_tsquery
          assert_raise(ActiveRecord::StatementInvalid) do
            WebComicWithSearchableName.advanced_search(search_term).all
          end
        end
      end

      should "fuzzy search stuff" do
        assert_equal [@qcont], WebComicWithSearchableName.fuzzy_search('Questio')
      end

      should "define :searchable_columns as private" do
        assert_raise(NoMethodError) { WebComicWithSearchableName.searchable_columns }
        begin
          WebComicWithSearchableName.searchable_columns
        rescue NoMethodError => error
          assert_match error.message, /private method/
        end
      end

      should "define #indexable_columns which returns a write-proof Enumerable" do
        assert_equal(Enumerator, WebComicWithSearchableName.indexable_columns.class)
        assert_raise(NoMethodError) { WebComicWithSearchableName.indexable_columns[0] = 'foo' }
      end
    end

    context "with two columns as parameters" do
      setup do
        @qcont = WebComicWithSearchableNameAndAuthor.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jhony = WebComicWithSearchableNameAndAuthor.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @ddeeg = WebComicWithSearchableNameAndAuthor.create :name => "Dominic Deegan", :author => "Mookie"
        @penny = WebComicWithSearchableNameAndAuthor.create :name => "Penny Arcade", :author => "Tycho & Gabe"
      end

      teardown do
        WebComicWithSearchableNameAndAuthor.delete_all
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComicWithSearchableNameAndAuthor.advanced_search("Penny")
        assert_equal [@penny], WebComicWithSearchableNameAndAuthor.advanced_search("Tycho")
      end
    end
  end
end
