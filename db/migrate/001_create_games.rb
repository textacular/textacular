class CreateGames < ActiveRecord::Migration[ActiveRecord.version.to_s.match(/^(\d+\.)?(\d+)/)[0]]
  def change
    create_table :games do |table|
      table.string :system
      table.string :title
      table.text :description
    end
  end
end
