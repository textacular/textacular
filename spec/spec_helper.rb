$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'yaml'
require 'texticle'
require 'shoulda'
require 'pry'
require 'active_record'
require 'texticle'
require 'texticle/searchable'

config = YAML.load_file File.expand_path(File.dirname(__FILE__) + '/config.yml')
ActiveRecord::Base.establish_connection config.merge(:adapter => :postgresql)

class ARStandIn < ActiveRecord::Base;
  self.abstract_class = true
  extend Texticle
end

class NotThere < ARStandIn; end

class TexticleWebComic < ARStandIn;
  has_many :characters, :foreign_key => :web_comic_id
  self.table_name = :web_comics
end


class WebComic < ActiveRecord::Base
  # string :name
  # string :author
  # integer :id

  has_many :characters
end

class WebComicWithSearchable < WebComic
  extend Searchable
end

class WebComicWithSearchableName < WebComic
  extend Searchable(:name)
end

class WebComicWithSearchableNameAndAuthor < WebComic
  extend Searchable(:name, :author)
end


class Character < ActiveRecord::Base
  # string :name
  # string :description
  # integer :web_comic_id

  belongs_to :web_comic
end


class Game < ActiveRecord::Base
  # string :system
  # string :title
  # text :description
end

class GameExtendedWithTexticle < Game
  extend Texticle
end

class GameExtendedWithTexticleAndCustomLanguage < GameExtendedWithTexticle
  def searchable_language
    'spanish'
  end
end


class GameFail < Game; end

class GameFailExtendedWithTexticle < GameFail
  extend Texticle
end
