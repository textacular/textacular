require 'test_helper'
require 'support/web_comic_with_searchable'
require 'support/web_comic_with_searchable_name'
require 'support/web_comic_with_searchable_name_and_author'
require 'support/character'

class Textacular::SearchableText < BaseTest

  test "when extending an ActiveRecord::Base subclass with no parameters searches across all columns" do
    assert_equal [web_comics(:penny_arcade).name], WebComicWithSearchable.advanced_search("Penny").collect(&:name)
    assert_equal [web_comics(:dominic_deegan).name], WebComicWithSearchable.advanced_search("Dominic").collect(&:name)
  end

  test "when extending an ActiveRecord::Base subclass with no parameters ranks results, even with NULL columns" do
    comic = WebComicWithSearchable.basic_search('Foo').first
    rank = comic.attributes.find { |key, value| key.to_s =~ /\Arank\d+\z/ }.last
    assert rank.present?
  end

  test "with one column as a parameter only searches across the given column" do
    assert_equal [web_comics(:penny_arcade).name], WebComicWithSearchableName.advanced_search("Penny").collect(&:name)
    assert_empty WebComicWithSearchableName.advanced_search("Tycho")
  end

  ["hello \\", "tebow!" , "food &"].each do |search_term|
    test "basic search works with interesting term \"#{search_term}\"" do
      assert_empty WebComicWithSearchableName.basic_search(search_term)
    end
  end

  ["hello \\", "tebow!" , "food &"].each do |search_term|
    test "advanced_search fails with interesting term \"#{search_term}\"" do
      assert_raises ActiveRecord::StatementInvalid do
        WebComicWithSearchableName.advanced_search(search_term).first
      end
    end
  end
  
  test "advanced_search searches with negation" do
    assert_empty WebComicWithSearchableName.advanced_search('foo & ! bar')
  end


  # Uses websearch_to_tsquery
  ["hello \\", "tebow!" , "food &"].each do |search_term|
    test "web search works with interesting term \"#{search_term}\"" do
      assert_empty WebComicWithSearchableName.web_search(search_term)
    end
  end

  test "does fuzzy searching" do
    assert_equal [web_comics(:questionable_content).name], WebComicWithSearchableName.fuzzy_search('Questio').collect(&:name)
  end

  test "return a valid rank when fuzzy searching on NULL columns" do
    search_result = WebComicWithSearchableNameAndAuthor.fuzzy_search('Questio')
    assert_equal [web_comics(:questionable_content).name], search_result.collect(&:name)
    assert search_result.first.attributes.find { |k, _| k[0..3] == 'rank' }.last
  end

  test "defines :searchable_columns as private" do
    assert_raises NoMethodError do
      WebComicWithSearchableName.searchable_columns
    end

    begin
      WebComicWithSearchableName.searchable_columns
    rescue NoMethodError => error
      assert_match /private method/, error.message
    end
  end

  test "defines #indexable_columns which returns a write-proof Enumerable" do
    assert_kind_of Enumerator, WebComicWithSearchableName.indexable_columns
    assert_raises NoMethodError do
      WebComicWithSearchableName.indexable_columns[0] = 'foo'
    end
  end
end
