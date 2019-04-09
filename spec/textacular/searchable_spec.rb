require 'support/web_comic_with_searchable'
require 'support/web_comic_with_searchable_name'
require 'support/web_comic_with_searchable_name_and_author'
require 'support/character'

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

    context "with one column as a parameter" do
      let!(:questionable_content) do
        WebComicWithSearchableName.create(
          name: 'Questionable Content',
          author: nil,
        )
      end

      let!(:johnny_wander) do
        WebComicWithSearchableName.create(
          name: 'Johnny Wander',
          author: 'Ananth & Yuko',
        )
      end

      let!(:dominic_deegan) do
        WebComicWithSearchableName.create(
          name: 'Dominic Deegan',
          author: 'Mookie',
        )
      end

      let!(:penny_arcade) do
        WebComicWithSearchableName.create(
          name: 'Penny Arcade',
          author: 'Tycho & Gabe',
        )
      end

      it "only searches across the given column" do
        expect(WebComicWithSearchableName.advanced_search("Penny")).to eq([penny_arcade])

        expect(WebComicWithSearchableName.advanced_search("Tycho")).to be_empty
      end

      describe "basic search" do # Uses plainto_tsquery
        ["hello \\", "tebow!" , "food &"].each do |search_term|
          it "works with interesting term \"#{search_term}\"" do
            expect(WebComicWithSearchableName.basic_search(search_term)).to be_empty
          end
        end
      end

      describe "advanced_search" do # Uses to_tsquery
        ["hello \\", "tebow!" , "food &"].each do |search_term|
          it "fails with interesting term \"#{search_term}\"" do
            expect {
              WebComicWithSearchableName.advanced_search(search_term).first
            }.to raise_error(ActiveRecord::StatementInvalid)
          end
        end
        it "searches with negation" do
          expect(WebComicWithSearchableName.advanced_search('foo & ! bar')).to be_empty
        end
      end

      it "does fuzzy searching" do
        expect(
          WebComicWithSearchableName.fuzzy_search('Questio')
        ).to eq([questionable_content])
      end

      it "return a valid rank when fuzzy searching on NULL columns" do
        qcont_with_author = questionable_content.becomes(WebComicWithSearchableNameAndAuthor)
        search_result = WebComicWithSearchableNameAndAuthor.fuzzy_search('Questio')
        expect([qcont_with_author]).to eq(search_result)
        expect(search_result.first.attributes.find { |k, _| k[0..3] == 'rank' }.last).to be_truthy
      end

      it "defines :searchable_columns as private" do
        expect { WebComicWithSearchableName.searchable_columns }.to raise_error(NoMethodError)

        begin
          WebComicWithSearchableName.searchable_columns
        rescue NoMethodError => error
          expect(error.message).to match(/private method/)
        end
      end

      it "defines #indexable_columns which returns a write-proof Enumerable" do
        expect(WebComicWithSearchableName.indexable_columns).to be_an(Enumerator)

        expect {
          WebComicWithSearchableName.indexable_columns[0] = 'foo'
        }.to raise_error(NoMethodError)
      end
    end

    context "with two columns as parameters" do
      let!(:questionable_content) do
        WebComicWithSearchableNameAndAuthor.create(
          name: 'Questionable Content',
          author: 'Jeph Jaques',
        )
      end

      let!(:johnny_wander) do
        WebComicWithSearchableNameAndAuthor.create(
          name: 'Johnny Wander',
          author: 'Ananth & Yuko',
        )
      end

      let!(:dominic_deegan) do
        WebComicWithSearchableNameAndAuthor.create(
          name: 'Dominic Deegan',
          author: 'Mookie',
        )
      end

      let!(:penny_arcade) do
        WebComicWithSearchableNameAndAuthor.create(
          name: 'Penny Arcade',
          author: 'Tycho & Gabe',
        )
      end

      it "only searches across the given columns" do
        expect(
          WebComicWithSearchableNameAndAuthor.advanced_search("Penny")
        ).to eq([penny_arcade])

        expect(
          WebComicWithSearchableNameAndAuthor.advanced_search("Tycho")
        ).to eq([penny_arcade])
      end

      it "allows includes" do
        expect(
          WebComicWithSearchableNameAndAuthor.includes(:characters).advanced_search("Penny")
        ).to eq([penny_arcade])
      end
    end

    context 'custom rank' do
      let!(:questionable_content) do
        WebComicWithSearchableName.create(
          name: 'Questionable Content',
          author: nil,
        )
      end

      it "is selected for search" do
        search_result = WebComicWithSearchableNameAndAuthor.search('Questionable Content', true, 'my_rank')
        expect(search_result.first.attributes['my_rank']).to be_truthy
      end

      it "is selected for basic_search" do
        search_result = WebComicWithSearchableNameAndAuthor.basic_search('Questionable Content', true, 'my_rank')
        expect(search_result.first.attributes['my_rank']).to be_truthy
      end

      it "is selected for advanced_search" do
        search_result = WebComicWithSearchableNameAndAuthor.advanced_search('Questionable Content', true, 'my_rank')
        expect(search_result.first.attributes['my_rank']).to be_truthy
      end

      it "is selected for fuzzy_search" do
        search_result = WebComicWithSearchableNameAndAuthor.fuzzy_search('Questionable Content', true, 'my_rank')
        expect(search_result.first.attributes['my_rank']).to be_truthy
      end
    end
  end
end
