require 'support/ar_stand_in'
require 'support/character'

class TextacularWebComic < ARStandIn;
  has_many :characters, :foreign_key => :web_comic_id
  self.table_name = :web_comics
end
