class CreateCharacters < ActiveRecord::Migration[ActiveRecord.version.to_s.match(/^(\d+\.)?(\d+)/)[0]]
  def change
    create_table :characters do |table|
      table.string :name
      table.string :description
      table.integer :web_comic_id
    end
  end
end
