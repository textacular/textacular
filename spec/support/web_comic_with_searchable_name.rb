require 'textacular/searchable'
require 'support/web_comic'

class WebComicWithSearchableName < WebComic
  extend Searchable(:name)
end
