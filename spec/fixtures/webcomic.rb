class WebComic < ActiveRecord::Base
  # string :name
  # string :author
  # integer :id

  has_many :characters
end
