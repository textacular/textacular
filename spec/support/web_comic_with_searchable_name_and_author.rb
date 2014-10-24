require 'textacular/searchable'
require 'support/web_comic'

class WebComicWithSearchableNameAndAuthor < WebComic
  extend Searchable(:name, :author)
end
