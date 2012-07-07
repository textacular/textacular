require 'spec_helper'
require 'fixtures/webcomic'
require 'texticle/searchable'

class SearchableTest < Test::Unit::TestCase
  context "when extending an ActiveRecord::Base subclass" do
    setup do
      @qcont = WebComic.create :name => "Questionable Content", :author => "Jeph Jaques"
      @jhony = WebComic.create :name => "Johnny Wander", :author => "Ananth & Yuko"
      @ddeeg = WebComic.create :name => "Dominic Deegan", :author => "Mookie"
      @penny = WebComic.create :name => "Penny Arcade", :author => "Tycho & Gabe"
    end

    teardown do
      WebComic.delete_all
      #Object.send(:remove_const, :WebComic) if defined?(WebComic)
    end

    context "with no parameters" do
      setup do
        WebComic.extend Searchable
      end

      should "search across all columns" do
        assert_equal [@penny], WebComic.advanced_search("Penny")
        assert_equal [@ddeeg], WebComic.advanced_search("Dominic")
      end
    end

    context "with one column as parameter" do
      setup do
        WebComic.extend Searchable(:name)
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComic.advanced_search("Penny")
        assert_empty WebComic.advanced_search("Tycho")
      end

      ["hello \\", "tebow!" , "food &"].each do |search_term|
        should "be fine with searching for crazy character #{search_term} with plain search" do
          # Uses plainto_tsquery
          assert_equal [], WebComic.basic_search(search_term)
        end

        should "be not fine with searching for crazy character #{search_term} with advanced search" do
          # Uses to_tsquery
          assert_raise(ActiveRecord::StatementInvalid) do
            WebComic.advanced_search(search_term).all
          end
        end
      end

      should "fuzzy search stuff" do
        assert_equal [@qcont], WebComic.fuzzy_search('Questio')
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
        assert_equal [@penny], WebComic.advanced_search("Penny")
        assert_equal [@penny], WebComic.advanced_search("Tycho")
      end
    end
  end
end
