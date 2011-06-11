require 'spec_helper'

class Game < ActiveRecord::Base
  # string :system
  # string :title
end

class TexticleTest < Test::Unit::TestCase

  context "after extending an ActiveRecord::Base subclass" do
    setup do
      Game.extend(Texticle)
      @zelda = Game.create :system => "NES",     :title => "Legend of Zelda"
      @mario = Game.create :system => "NES",     :title => "Super Mario Bros."
      @sonic = Game.create :system => "Genesis", :title => "Sonic the Hedgehog"
      @fight = Game.create :system => "SNES",    :title => "Fighter's History"
    end

    teardown do
      Game.delete_all
    end

    should "define a #search method" do
      assert Game.respond_to?(:search)
    end

    context "when searching with a string argument" do
      should "search across all :string columns if no indexes have been specified" do
        assert_equal @mario, Game.search("Mario").first
        assert_equal 1,      Game.search("Mario").count

        assert (Game.search("NES") && [@mario, @zelda]) == [@mario, @zelda]
        assert_equal 2,      Game.search("NES").count
      end

      should "not fail if the query contains an apostrophe" do
        assert_equal @fight, Game.search("Fighter's").first
        assert_equal 1,      Game.search("Fighter's").count
      end
    end

    context "when searching with a hash argument" do
      should "search across the given columns" do
        assert Game.search(:title => "NES").empty?
        assert Game.search(:system => "Mario").empty?

        assert_equal @mario, Game.search(:title => "Mario").first
        assert_equal 1,      Game.search(:title => "Mario").count

        assert_equal 2,      Game.search(:system => "NES").count
      end
    end
  end

end
