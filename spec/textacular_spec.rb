# coding: utf-8
# Above for Ruby 1.9 tests

require 'support/ar_stand_in'
require 'support/not_there'
require 'support/textacular_web_comic'
require 'support/game_extended_with_textacular'
require 'support/game_extended_with_textacular_and_custom_language'
require 'support/game_fail_extended_with_textacular'

RSpec.describe Textacular do
  context "after extending ActiveRecord::Base" do
    it "doesn't break #respond_to?" do
      expect{ ARStandIn.respond_to?(:abstract_class?) }.to_not raise_error
    end

    it "doesn't break #respond_to? for table-less classes" do
      expect(NotThere.table_exists?).to be_falsey
      expect { NotThere.respond_to? :system }.to_not raise_error
    end

    it "doesn't break #method_missing" do
      expect { ARStandIn.random }.to raise_error(NoMethodError)

      begin
        ARStandIn.random
      rescue NoMethodError => error
        expect(error.message).to match(/undefined method `random'/)
      end
    end

    it "doesn't break #method_missing for table-less classes" do
      expect(NotThere.table_exists?).to be_falsey

      expect { NotThere.random }.to raise_error(NoMethodError)

      begin
        NotThere.random
      rescue NoMethodError => error
        expect(error.message).to match(/undefined method `random'/)
      end
    end

    context "when finding models based on searching a related model" do
      let(:webcomics_with_tall_characters) do
        [johnny_wander]
      end

      let(:webcomics_with_angry_characters) do
        [johnny_wander, penny_arcade, questionable_content]
      end

      let(:webcomics_with_crude_characters) do
        [penny_arcade, questionable_content]
      end

      let!(:johnny_wander) do
        TextacularWebComic.create(:name => "Johnny Wander", :author => "Ananth & Yuko").tap do |comic|
          comic.characters.create :name => 'Ananth', :description => 'Stubble! What is under that hat?!?'
          comic.characters.create :name => 'Yuko', :description => 'So... small. Carl Sagan haircut.'
          comic.characters.create :name => 'John', :description => 'Tall. Anger issues?'
          comic.characters.create :name => 'Cricket', :description => 'Chirrup!'
        end
      end

      let!(:questionable_content) do
        TextacularWebComic.create(:name => "Questionable Content", :author => "Jeph Jaques").tap do |comic|
          comic.characters.create :name => 'Martin', :description => 'the insecure protagonist'
          comic.characters.create :name => 'Faye', :description => 'a sarcastic barrista with anger management issues'
          comic.characters.create :name => 'Pintsize', :description => 'a crude AnthroPC'
        end
      end

      let!(:penny_arcade) do
        TextacularWebComic.create(:name => "Penny Arcade", :author => "Tycho & Gabe").tap do |comic|
          comic.characters.create :name => 'Gabe', :description => 'the simple one'
          comic.characters.create :name => 'Tycho', :description => 'the wordy one'
          comic.characters.create :name => 'Div', :description => 'a crude divx player with anger management issues'
        end
      end

      it "looks in the related model with nested searching syntax" do
        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'tall'}
          )
        ).to eq(webcomics_with_tall_characters)

        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'anger'}
          ).sort
        ).to eq(webcomics_with_angry_characters.sort)

        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'crude'}
          ).sort
        ).to eq(webcomics_with_crude_characters.sort)
      end
    end
  end

  context "after extending an ActiveRecord::Base subclass" do
    context "when the DB connection is unavailable" do
      before do
        GameFailExtendedWithTextacular.establish_connection({:adapter => :postgresql, :database =>'unavailable', :username=>'bad', :pool=>5, :timeout=>5000}) rescue nil
      end

      it "doesn't break respond_to?" do
        expect { GameFailExtendedWithTextacular.respond_to?(:advanced_search) }.to_not raise_error
      end
    end

    context "when the DB connection is available" do
      let!(:zelda) do
        GameExtendedWithTextacular.create(
          :system => "NES",
          :title => "Legend of Zelda",
          :description => "A Link to the Past."
        )
      end

      let!(:mario) do
        GameExtendedWithTextacular.create(
          :system => "NES",
          :title => "Super Mario Bros.",
          :description => "The original platformer."
        )
      end

      let!(:sonic) do
        GameExtendedWithTextacular.create(
          :system => "Genesis",
          :title => "Sonic the Hedgehog",
          :description => "Spiky."
        )
      end

      let!(:donkey_kong) do
        GameExtendedWithTextacular.create(
          :system => "SNES",
          :title => "Diddy's Kong Quest",
          :description => "Donkey Kong Country 2"
        )
      end

      let!(:mega_man) do
        GameExtendedWithTextacular.create(
          :system => nil,
          :title => "Mega Man",
          :description => "Beware Dr. Brain"
        )
      end

      let!(:sf_nes) do
        GameExtendedWithTextacular.create(
          :system => "SNES",
          :title => "Street Fighter 2",
          :description => "Yoga Flame!"
        )
      end

      let!(:sf_genesis) do
        GameExtendedWithTextacular.create(
          :system => "Genesis",
          :title => "Street Fighter 2",
          :description => "Yoga Flame!"
        )
      end

      let!(:takun) do
        GameExtendedWithTextacular.create(
          :system => "Saturn",
          :title => "Magical Tarurūto-kun",
          :description => "カッコイイ！"
        )
      end

      it "defines a #search method" do
        expect(GameExtendedWithTextacular).to respond_to(:search)
      end

      describe "#advanced_search" do
        context "with a String argument" do
          it "searches across all :string columns (if not indexes have been specified)" do
            expect(
              GameExtendedWithTextacular.advanced_search("Mario")
            ).to eq([mario])

            expect(
              GameExtendedWithTextacular.advanced_search("NES").to_set
            ).to eq(Set.new([mario, zelda]))
          end

          it "works if a query has an apostrophe" do
            expect(GameExtendedWithTextacular.advanced_search("Diddy's")).to eq([donkey_kong])
          end

          it "works if the query contains whitespace" do
            expect(GameExtendedWithTextacular.advanced_search("Mega Man")).to eq([mega_man])
          end

          it "works if the query contains an accent" do
            expect(GameExtendedWithTextacular.advanced_search("Tarurūto-kun")).to eq([takun])
          end

          it "searches across records with NULL values" do
            expect(GameExtendedWithTextacular.advanced_search("Mega")).to eq([mega_man])
          end

          it "scopes consecutively" do
            expect(
              GameExtendedWithTextacular.advanced_search("Genesis").advanced_search("Street Fighter")
            ).to eq([sf_genesis])
          end
        end

        context "with a Hash argument" do
          it "searches across the given columns" do
            expect(
              GameExtendedWithTextacular.advanced_search(:title => 'NES')
            ).to be_empty
            expect(
              GameExtendedWithTextacular.advanced_search(:system => "Mario")
            ).to be_empty
            expect(
              GameExtendedWithTextacular.advanced_search(:system => "NES", :title => "Sonic")
            ).to be_empty

            expect(
              GameExtendedWithTextacular.advanced_search(:title => "Mario")
            ).to eq([mario])

            expect(
              GameExtendedWithTextacular.advanced_search(:system => "NES").size
            ).to eq(2)

            expect(
              GameExtendedWithTextacular.advanced_search(:system => "NES", :title => "Zelda")
            ).to eq([zelda])
            expect(
              GameExtendedWithTextacular.advanced_search(:title => "Mega")
            ).to eq([mega_man])
          end

          it "scopes consecutively" do
            expect(
              GameExtendedWithTextacular
                .advanced_search(:system => "Genesis")
                .advanced_search(:title => "Street Fighter")
            ).to eq([sf_genesis])
          end

          it "casts non-string columns as text" do
            expect(
              GameExtendedWithTextacular.advanced_search(:id => mario.id)
            ).to eq([mario])
          end
        end

        context "via dynamic method names" do
          it "only exists prior to 4.0.0" do
            current_version = Gem::Version.new(Textacular.version)

            expect(current_version).to be < Gem::Version.new("4.0.0")
          end

          it "generates methods for each string column" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_title("Mario")
            ).to eq([mario])
            expect(
              GameExtendedWithTextacular.advanced_search_by_system("Saturn")
            ).to eq([takun])
          end

          it "generates methods for each text column" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_description("platform")
            ).to eq([mario])
          end

          it "generates methods for any combination of string and text columns" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_title_and_system("Mario", "NES")
            ).to eq([mario])
            expect(
              GameExtendedWithTextacular.advanced_search_by_system_and_title("Genesis", "Sonic")
            ).to eq([sonic])
            expect(
              GameExtendedWithTextacular.advanced_search_by_title_and_title("Mario", "Mario")
            ).to eq([mario])
            expect(
              GameExtendedWithTextacular.advanced_search_by_title_and_description("Man", "Brain")
            ).to eq([mega_man])
          end

          it "generates methods for inclusive searches" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_system_or_title("Saturn", "Mega Man").to_set
            ).to eq(Set.new([mega_man, takun]))
          end

          it "scopes consecutively" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_system("Genesis").advanced_search_by_title("Street Fighter")
            ).to eq([sf_genesis])
          end

          it "generates methods for non-string columns" do
            expect(
              GameExtendedWithTextacular.advanced_search_by_id(mario.id)
            ).to eq([mario])
          end

          it "works with #respond_to?" do
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_system)
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_title)
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_system_and_title)
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_system_or_title)
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_title_and_title_and_title)
            expect(GameExtendedWithTextacular).to respond_to(:advanced_search_by_id)

            expect(GameExtendedWithTextacular).to_not respond_to(:advanced_search_by_title_and_title_or_title)
          end

          it "allows for 2 arguments to #respond_to?" do
            expect(GameExtendedWithTextacular.respond_to?(:searchable_language, true)).to be_truthy
          end
        end

        context "after selecting columns to return" do
          it "doesn't fetch extra columns" do
            expect {
              GameExtendedWithTextacular.select(:title).advanced_search("Mario").first.system
            }.to raise_error(ActiveModel::MissingAttributeError)
          end
        end

        context "after setting a custom language" do
          let!(:harry_potter_7) do
            GameExtendedWithTextacularAndCustomLanguage.create(
              :system => "PS3",
              :title => "Harry Potter & the Deathly Hallows"
            )
          end

          it "finds results" do
            expect(
              GameExtendedWithTextacularAndCustomLanguage.advanced_search_by_title("harry")
            ).to eq([harry_potter_7])
          end
        end
      end
    end
  end
end
