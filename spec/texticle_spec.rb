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
        assert_equal @dkong, Game.search("Diddy's").first
        assert_equal 1,      Game.search("Diddy's").count
      end

      should "not fail if the query contains whitespace" do
        assert_equal @megam, Game.search("Mega Man").first
      end

      should "search across records with NULL values" do
        assert_equal @megam, Game.search("Mega").first
      end

      should "scope consecutively" do
        assert_equal @sfgen, Game.search("Genesis").search("Street Fighter").first
      end
    end

    context "when searching with a hash argument" do
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
  end

end
