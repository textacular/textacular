# coding: utf-8
require 'spec_helper'
require 'fixtures/webcomic'
require 'fixtures/character'
require 'fixtures/game'

class TexticleTest < Test::Unit::TestCase
  context "after extending ActiveRecord::Base" do
    # before(:all)
    ActiveRecord::Base.extend(Texticle)
    class NotThere < ActiveRecord::Base; end

    should "not break #respond_to?" do
      assert_nothing_raised do
        ActiveRecord::Base.respond_to? :abstract_class?
      end
    end

    should "not break #respond_to? for table-less classes" do
      assert !NotThere.table_exists?
      assert_nothing_raised do
        NotThere.respond_to? :system
      end
    end

    should "not break #method_missing" do
      assert_raise(NoMethodError) { ActiveRecord::Base.random }
      begin
        ActiveRecord::Base.random
      rescue NoMethodError => error
        assert_match error.message, /undefined method `random'/
      end
    end

    should "not break #method_missing for table-less classes" do
      assert !NotThere.table_exists?
      assert_raise(NoMethodError) { NotThere.random }
      begin
        NotThere.random
      rescue NoMethodError => error
        assert_match error.message, /undefined method `random'/
      end
    end

    context "when finding models based on searching a related model" do
      setup do
        @qc = WebComic.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jw = WebComic.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @pa = WebComic.create :name => "Penny Arcade", :author => "Tycho & Gabe"

        @gabe = @pa.characters.create :name => 'Gabe', :description => 'the simple one'
        @tycho = @pa.characters.create :name => 'Tycho', :description => 'the wordy one'
        @div = @pa.characters.create :name => 'Div', :description => 'a crude divx player with anger management issues'

        @martin = @qc.characters.create :name => 'Martin', :description => 'the insecure protagonist'
        @faye = @qc.characters.create :name => 'Faye', :description => 'a sarcastic barrista with anger management issues'
        @pintsize = @qc.characters.create :name => 'Pintsize', :description => 'a crude AnthroPC'

        @ananth = @jw.characters.create :name => 'Ananth', :description => 'Stubble! What is under that hat?!?'
        @yuko = @jw.characters.create :name => 'Yuko', :description => 'So... small. Carl Sagan haircut.'
        @john = @jw.characters.create :name => 'John', :description => 'Tall. Anger issues?'
        @cricket = @jw.characters.create :name => 'Cricket', :description => 'Chirrup!'
      end

      teardown do
        WebComic.delete_all
        Character.delete_all
      end

      should "look in the related model with nested searching syntax" do
        assert_equal [@jw], WebComic.joins(:characters).search(:characters => {:description => 'tall'})
        assert_equal [@pa, @jw, @qc].sort, WebComic.joins(:characters).search(:characters => {:description => 'anger'}).sort
        assert_equal [@pa, @qc].sort, WebComic.joins(:characters).search(:characters => {:description => 'crude'}).sort
      end
    end
  end

  context "after extending an ActiveRecord::Base subclass" do
    # before(:all)
    class ::GameFail < Game; end

    setup do
      @zelda = Game.create :system => "NES",     :title => "Legend of Zelda",    :description => "A Link to the Past."
      @mario = Game.create :system => "NES",     :title => "Super Mario Bros.",  :description => "The original platformer."
      @sonic = Game.create :system => "Genesis", :title => "Sonic the Hedgehog", :description => "Spiky."
      @dkong = Game.create :system => "SNES",    :title => "Diddy's Kong Quest", :description => "Donkey Kong Country 2"
      @megam = Game.create :system => nil,       :title => "Mega Man",           :description => "Beware Dr. Brain"
      @sfnes = Game.create :system => "SNES",    :title => "Street Fighter 2",   :description => "Yoga Flame!"
      @sfgen = Game.create :system => "Genesis", :title => "Street Fighter 2",   :description => "Yoga Flame!"
      @takun = Game.create :system => "Saturn",  :title => "Magical Tarurūto-kun", :description => "カッコイイ！"
    end

    teardown do
      Game.delete_all
    end

    should "not break respond_to? when connection is unavailable" do
      GameFail.establish_connection({:adapter => :postgresql, :database =>'unavailable', :username=>'bad', :pool=>5, :timeout=>5000}) rescue nil

      assert_nothing_raised do
        GameFail.respond_to?(:search)
      end

    end

    should "define a #search method" do
      assert Game.respond_to?(:search)
    end

    context "when searching with a String argument" do
      should "search across all :string columns if no indexes have been specified" do
        assert_equal [@mario], Game.search("Mario")
        assert_equal Set.new([@mario, @zelda]), Game.search("NES").to_set
      end

      should "work if the query contains an apostrophe" do
        assert_equal [@dkong], Game.search("Diddy's")
      end

      should "work if the query contains whitespace" do
        assert_equal [@megam], Game.search("Mega Man")
      end

      should "work if the query contains an accent" do
        assert_equal [@takun], Game.search("Tarurūto-kun")
      end

      should "search across records with NULL values" do
        assert_equal [@megam], Game.search("Mega")
      end

      should "scope consecutively" do
        assert_equal [@sfgen], Game.search("Genesis").search("Street Fighter")
      end
    end

    context "when searching with a Hash argument" do
      should "search across the given columns" do
        assert_empty Game.search(:title => "NES")
        assert_empty Game.search(:system => "Mario")
        assert_empty Game.search(:system => "NES", :title => "Sonic")

        assert_equal [@mario], Game.search(:title => "Mario")

        assert_equal 2, Game.search(:system => "NES").count

        assert_equal [@zelda], Game.search(:system => "NES", :title => "Zelda")
        assert_equal [@megam], Game.search(:title => "Mega")
      end

      should "scope consecutively" do
        assert_equal [@sfgen], Game.search(:system => "Genesis").search(:title => "Street Fighter")
      end

      should "cast non-:string columns as text" do
        assert_equal [@mario], Game.search(:id => @mario.id)
      end
    end

    context "when using dynamic search methods" do
      should "generate methods for each :string column" do
        assert_equal [@mario], Game.search_by_title("Mario")
        assert_equal [@takun], Game.search_by_system("Saturn")
      end

      should "generate methods for each :text column" do
        assert_equal [@mario], Game.search_by_description("platform")
      end

      should "generate methods for any combination of :string and :text columns" do
        assert_equal [@mario], Game.search_by_title_and_system("Mario", "NES")
        assert_equal [@sonic], Game.search_by_system_and_title("Genesis", "Sonic")
        assert_equal [@mario], Game.search_by_title_and_title("Mario", "Mario")
        assert_equal [@megam], Game.search_by_title_and_description("Man", "Brain")
      end

      should "generate methods for inclusive searches" do
        assert_equal Set.new([@megam, @takun]), Game.search_by_system_or_title("Saturn", "Mega Man").to_set
      end

      should "scope consecutively" do
        assert_equal [@sfgen], Game.search_by_system("Genesis").search_by_title("Street Fighter")
      end

      should "generate methods for non-:string columns" do
        assert_equal [@mario], Game.search_by_id(@mario.id)
      end

      should "work with #respond_to?" do
        assert Game.respond_to?(:search_by_system)
        assert Game.respond_to?(:search_by_title)
        assert Game.respond_to?(:search_by_system_and_title)
        assert Game.respond_to?(:search_by_system_or_title)
        assert Game.respond_to?(:search_by_title_and_title_and_title)
        assert Game.respond_to?(:search_by_id)

        assert !Game.respond_to?(:search_by_title_and_title_or_title)
      end

      should "allow for 2 arguments to #respond_to?" do
        assert Game.respond_to?(:normalize, true)
      end
    end

    context "when searching after selecting columns to return" do
      should "not fetch extra columns" do
        assert_raise(ActiveModel::MissingAttributeError) do
          Game.select(:title).search("Mario").first.system
        end
      end
    end
  end

  context "when setting a custom search language" do
    def Game.searchable_language
      'spanish'
    end

    setup do
      Game.create :system => "PS3", :title => "Harry Potter & the Deathly Hallows"
    end

    teardown do
      Game.delete_all
    end

    should "still find results" do
      assert_not_empty Game.search_by_title("harry")
    end
  end
end
