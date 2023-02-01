require 'test_helper'
require 'support/ar_stand_in'
require 'support/not_there'
require 'support/textacular_web_comic'
require 'support/game_extended_with_textacular'
require 'support/game_extended_with_textacular_and_custom_language'
require 'support/game_fail_extended_with_textacular'

class TextacularTest < BaseTest
  test "doesn't break #respond_to?" do
    ARStandIn.respond_to?(:abstract_class?)
  end

  test "defines a #search method" do
    assert GameExtendedWithTextacular.respond_to?(:search)
  end

  test 'searches non-text columns' do
    assert_equal [games(:mario).title], GameExtendedWithTextacular.fuzzy_search(id: games(:mario).id).collect(&:title)
  end

  test "searches across all :string columns (if not indexes have been specified)" do
    assert_equal [games(:mario).title], GameExtendedWithTextacular.advanced_search("Mario").collect(&:title)
    assert_equal Set.new([games(:mario).title, games(:zelda).title]), GameExtendedWithTextacular.advanced_search("NES").collect(&:title).to_set
  end

  test "works if a query has an apostrophe" do
    assert_equal [games(:donkey_kong).title], GameExtendedWithTextacular.advanced_search("Diddy's").collect(&:title)
  end

  test "works if the query contains whitespace" do
    assert_equal [games(:mega_man).title], GameExtendedWithTextacular.advanced_search("Mega Man").collect(&:title)
  end

  test "works if the query contains an accent" do
    assert_equal [games(:takun).title], GameExtendedWithTextacular.advanced_search("Tarurūto-kun").collect(&:title)
  end

  test "searches across records with NULL values" do
    assert_equal [games(:mega_man).title], GameExtendedWithTextacular.advanced_search("Mega").collect(&:title)
  end

  test "with a String argument scopes consecutively" do
    assert_equal [games(:sf_genesis).title], GameExtendedWithTextacular.advanced_search("Genesis").advanced_search("Street Fighter").collect(&:title)
  end

  test "searches across the given columns" do
    assert_empty GameExtendedWithTextacular.advanced_search(title: 'NES')
    assert_empty GameExtendedWithTextacular.advanced_search(system: "Mario")
    assert_empty GameExtendedWithTextacular.advanced_search(system: "NES", title: "Sonic")

    assert_equal [games(:mario).title], GameExtendedWithTextacular.advanced_search(title: "Mario").collect(&:title)
    assert_equal [games(:zelda).title], GameExtendedWithTextacular.advanced_search(title: "Zelda").collect(&:title)
    assert_equal 2, GameExtendedWithTextacular.advanced_search(system: "NES").size

    assert_equal [games(:zelda).title], GameExtendedWithTextacular.advanced_search(system: "NES", title: "Zelda").collect(&:title)
    assert_equal [games(:mega_man).title], GameExtendedWithTextacular.advanced_search(title: "Mega").collect(&:title)
  end

  test "with a Hash argument scopes consecutively" do
    assert_equal [games(:sf_genesis).title], GameExtendedWithTextacular
        .advanced_search(system: "Genesis")
        .advanced_search(title: "Street Fighter").collect(&:title)
  end

  test "casts non-string columns as text" do
    assert_equal [games(:mario).title], GameExtendedWithTextacular.advanced_search(id: games(:mario).id).collect(&:title)
  end

  test "doesn't fetch extra columns" do
    assert_raises ActiveModel::MissingAttributeError do 
      GameExtendedWithTextacular.select(:title).advanced_search("Mario").first.system
    end
  end

  test "finds results" do
    assert_equal [games(:harry_potter_7).title], GameExtendedWithTextacularAndCustomLanguage.advanced_search(title: "harry").collect(&:title)
  end
end
