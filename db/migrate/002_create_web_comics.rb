class CreateWebComics < ActiveRecord::Migration[ActiveRecord.version.to_s.match(/^(\d+\.)?(\d+)/)[0]]
  def change
    create_table :web_comics do |table|
      table.string :name
      table.string :author
      table.text :review
    end
  end
end
