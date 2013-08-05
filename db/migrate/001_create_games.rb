class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |table|
      table.string :system
      table.string :title
      table.text :description
    end
  end
end
