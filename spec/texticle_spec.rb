# coding: utf-8
require 'spec_helper'

class Game < ActiveRecord::Base
  # string :system
  # string :title

  def to_s
    "#{system}: #{title}"
  end
end

class TexticleTest < Test::Unit::TestCase

  context "after extending an ActiveRecord::Base subclass" do
    setup do
      Game.extend(Texticle)
      @zelda = Game.create :system => "NES",     :title => "Legend of Zelda"
      @mario = Game.create :system => "NES",     :title => "Super Mario Bros."
      @sonic = Game.create :system => "Genesis", :title => "Sonic the Hedgehog"
      @dkong = Game.create :system => "SNES",    :title => "Diddy's Kong Quest"
      @megam = Game.create :system => nil,       :title => "Mega Man"
      @sfnes = Game.create :system => "SNES",    :title => "Street Fighter 2"
      @sfgen = Game.create :system => "Genesis", :title => "Street Fighter 2"
      @takun = Game.create :system => "Saturn",  :title => "Magical Tarurūto-kun"
    end

    teardown do
      Game.delete_all
    end

    should "define a #search method" do
      assert Game.respond_to?(:search)
    end

    context "when searching with a String argument" do
      should "search across all :string columns if no indexes have been specified" do
        assert_equal @mario, Game.search("Mario").first
        assert_equal 1,      Game.search("Mario").count

        assert (Game.search("NES") && [@mario, @zelda]) == [@mario, @zelda]
        assert_equal 2,      Game.search("NES").count
      end

      should "work if the query contains an apostrophe" do
        assert_equal @dkong, Game.search("Diddy's").first
        assert_equal 1,      Game.search("Diddy's").count
      end

      should "work if the query contains whitespace" do
        assert_equal @megam, Game.search("Mega Man").first
      end

      should "work if the query contains an accent" do
        assert_equal @takun, Game.search("Tarurūto-kun").first
      end

      should "search across records with NULL values" do
        assert_equal @megam, Game.search("Mega").first
      end

      should "scope consecutively" do
        assert_equal @sfgen, Game.search("Genesis").search("Street Fighter").first
      end
    end

    context "when searching with a Hash argument" do
      should "search across the given columns" do
        assert Game.search(:title => "NES").empty?
        assert Game.search(:system => "Mario").empty?
        puts Game.search(:system => "NES", :title => "Sonic").to_a
        assert Game.search(:system => "NES", :title => "Sonic").empty?

        assert_equal @mario, Game.search(:title => "Mario").first
        assert_equal 1,      Game.search(:title => "Mario").count

        assert_equal 2,      Game.search(:system => "NES").count

        assert_equal @zelda, Game.search(:system => "NES", :title => "Zelda").first
        assert_equal @megam, Game.search(:title => "Mega").first
      end

      should "scope consecutively" do
        assert_equal @sfgen, Game.search(:system => "Genesis").search(:title => "Street Fighter").first
      end
    end

    context "when using dynamic search methods" do
      should "generate methods for each :string column" do
        assert_equal @mario, Game.search_by_title("Mario").first
        assert_equal @takun, Game.search_by_system("Saturn").first
      end

      should "generate methods for any combination of :string columns" do
        assert_equal @mario, Game.search_by_title_and_system("Mario", "NES").first
        assert_equal @sonic, Game.search_by_system_and_title("Genesis", "Sonic").first
        assert_equal @mario, Game.search_by_title_and_title("Mario", "Mario").first
      end

      should "scope consecutively" do
        assert_equal @sfgen, Game.search_by_system("Genesis").search_by_title("Street Fighter").first
      end

      should "not generate methods for non-:string columns" do
        assert_raise(NoMethodError) { Game.search_by_id }
      end

      should "work with #respond_to?" do
        assert Game.respond_to?(:search_by_system)
        assert Game.respond_to?(:search_by_title)
        assert Game.respond_to?(:search_by_system_and_title)
        assert Game.respond_to?(:search_by_title_and_title_and_title)

        assert !Game.respond_to?(:search_by_id)
      end

      should "allow for 2 arguments to #respond_to?" do
        assert Game.respond_to?(:normalize, true)
      end
    end

    context "when searching after selecting columns to return" do
      should "limit the search to the selected columns" do
        assert_empty Game.select(:system).search("Mario")
        assert_equal @mario.title, Game.select(:title).search("Mario").first.title
      end

      should "not fetch extra columns" do
        assert_raise(ActiveModel::MissingAttributeError) do
          Game.select(:title).search("Mario").first.system
        end
      end
    end
  end

end
