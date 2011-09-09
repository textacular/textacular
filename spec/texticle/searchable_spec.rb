require 'spec_helper'
require 'texticle/searchable'

class WebComic < ActiveRecord::Base
  # string :name
  # string :author
  # integer :id

  has_many :characters
end

class Character < ActiveRecord::Base
  # string :name
  # string :description
  # integer :web_comic_id

  belongs_to :web_comic
end

class SearchableTest < Test::Unit::TestCase

  context "when extending an ActiveRecord::Base subclass" do
    setup do
      @qcont = WebComic.create :name => "Questionable Content", :author => "Jeff Jaques"
      @jhony = WebComic.create :name => "Johnny Wander", :author => "Ananth & Yuko"
      @ddeeg = WebComic.create :name => "Dominic Deegan", :author => "Mookie"
      @penny = WebComic.create :name => "Penny Arcade", :author => "Tycho & Gabe"
    end

    teardown do
      WebComic.delete_all
    end

    context "with no paramters" do
      setup do
        WebComic.extend Searchable
      end

      should "search across all columns" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_equal [@ddeeg], WebComic.search("Dominic")
      end
    end

    context "with one column as parameter" do
      setup do
        WebComic.extend Searchable(:name)
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_empty WebComic.search("Tycho")
      end

      should "define :searchable_columns as private" do
        assert_raise(NoMethodError) { WebComic.searchable_columns }
        begin
          WebComic.searchable_columns
        rescue NoMethodError => error
          assert_match error.message, /private method/
        end
      end
    end

    context "with two columns as parameters" do
      setup do
        WebComic.extend Searchable(:name, :author)
      end

      should "only search across the given column" do
        assert_equal [@penny], WebComic.search("Penny")
        assert_equal [@penny], WebComic.search("Tycho")
      end
    end
  end

  context "when finding models based on searching a related model" do
    setup do
      @qc = WebComic.create :name => "Questionable Content", :author => "Jeff Jaques"
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

      Character.extend Searchable(:description)
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
