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
      before do
        @qc = TextacularWebComic.create :name => "Questionable Content", :author => "Jeph Jaques"
        @jw = TextacularWebComic.create :name => "Johnny Wander", :author => "Ananth & Yuko"
        @pa = TextacularWebComic.create :name => "Penny Arcade", :author => "Tycho & Gabe"

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

      it "looks in the related model with nested searching syntax" do
        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'tall'}
          )
        ).to eq([@jw])

        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'anger'}
          ).sort
        ).to eq([@pa, @jw, @qc].sort)

        expect(
          TextacularWebComic.joins(:characters).advanced_search(
            :characters => {:description => 'crude'}
          ).sort
        ).to eq([@pa, @qc].sort)
      end
    end
  end
end
