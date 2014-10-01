require 'support/ar_stand_in'
require 'support/not_there'
require 'support/textacular_web_comic'

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
end
