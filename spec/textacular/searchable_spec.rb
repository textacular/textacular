require 'support/web_comic_with_searchable'

RSpec.describe "Searchable" do
  context "when extending an ActiveRecord::Base subclass" do
    context "with no parameters" do
      let!(:questionable_content) do
        WebComicWithSearchable.create(
          name: 'Questionable Content',
          author: 'Jeph Jaques',
        )
      end

      let!(:johnny_wander) do
        WebComicWithSearchable.create(
          name: 'Johnny Wander',
          author: 'Ananth & Yuko',
        )
      end

      let!(:dominic_deegan) do
        WebComicWithSearchable.create(
          name: 'Dominic Deegan',
          author: 'Mookie',
        )
      end

      let!(:penny_arcade) do
        WebComicWithSearchable.create(
          name: 'Penny Arcade',
          author: 'Tycho & Gabe',
        )
      end

      let!(:null) do
        WebComicWithSearchable.create(
          author: 'Foo',
        )
      end

      it "searches across all columns" do
        expect(
          WebComicWithSearchable.advanced_search("Penny")
        ).to eq([penny_arcade])
        expect(
          WebComicWithSearchable.advanced_search("Dominic")
        ).to eq([dominic_deegan])
      end

      it "ranks results, egen with NULL columns" do
        comic = WebComicWithSearchable.basic_search('Foo').first
        rank = comic.attributes.find { |key, value| key.to_s =~ /\Arank\d+\z/ }.last

        expect(rank).to be_present
      end
    end
  end
end
