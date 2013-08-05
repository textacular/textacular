class CreateWebComics < ActiveRecord::Migration
  def change
    create_table :web_comics do |table|
      table.string :name
      table.string :author
      table.text :review
    end
  end
end
