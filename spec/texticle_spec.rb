require 'spec_helper'

class Game < ActiveRecord::Base
  # string :system
  # string :title
end

class TexticleTest < Test::Unit::TestCase

  context "after extending an ActiveRecord::Base subclass" do
    setup do
      Game.extend(Texticle)
    end

    teardown do
      Game.delete_all
    end

    should "define a #search method" do
      assert Game.respond_to?(:search)
    end

    context "when searching for a string" do
      setup do
        @zelda = Game.create :system => "NES",     :title => "Legend of Zelda"
        @mario = Game.create :system => "NES",     :title => "Super Mario Bros."
        @sonic = Game.create :system => "Genesis", :title => "Sonic the Hedgehog"
        @fight = Game.create :system => "SNES",    :title => "Fighter's History"
      end

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
  end

end
