require 'texticle/full_text_index'
require 'texticle/railtie' if defined?(Rails) and Rails::VERSION::MAJOR > 2

####
# Texticle exposes full text search capabilities from PostgreSQL, and allows
# you to declare full text indexes.  Texticle will extend ActiveRecord with
# named_scope methods making searching easy and fun!
#
# Texticle.index is automatically added to ActiveRecord::Base.
#
# To declare an index on a model, just use the index method:
#
#   class Product < ActiveRecord::Base
#     index do
#       name
#       description
#     end
#   end
#
# This will allow you to do full text search on the name and description
# columns for the Product model.  It defines a named_scope method called
# "search", so you can take advantage of the search like this:
#
#   Product.search('foo bar')
#
# Indexes may also be named.  For example:
#
#   class Product < ActiveRecord::Base
#     index 'author' do
#       name
#       author
#     end
#   end
#
# A named index will add a named_scope with the index name prefixed by
# "search".  In order to take advantage of the "author" index, just call:
#
#   Product.search_author('foo bar')
#
# Finally, column names can be ranked.  The ranks are A, B, C, and D.  This
# lets us declare that matches in the "name" column are more important
# than matches in the "description" column:
#
#   class Product < ActiveRecord::Base
#     index do
#       name          'A'
#       description   'B'
#     end
#   end
module Texticle
  # The version of Texticle you are using.
  VERSION = '1.0.3'

  # A list of full text indexes
  attr_accessor :full_text_indexes

  ###
  # Create an index with +name+ using +dictionary+
  def index name = nil, dictionary = 'english', &block
    search_name = ['search', name].compact.join('_')

    class_eval do
      named_scope search_name.to_sym, lambda { |term|
        # Let's extract the individual terms to allow for quoted and wildcard terms.
        term = term.scan(/"([^"]+)"|(\S+)/).flatten.compact.map do |lex| 
          lex =~ /(.+)\*\s*$/ ? "'#{$1}':*" : "'#{lex}'"
        end.join(' & ')
        
        {
          :select => "#{table_name}.*, ts_rank_cd((#{full_text_indexes.first.to_s}),
            to_tsquery(#{connection.quote(term)})) as rank",
          :conditions =>
            ["#{full_text_indexes.first.to_s} @@ to_tsquery(?)", term],
          :order => 'rank DESC'
        }
      }
    end
    index_name = [table_name, name, 'fts_idx'].compact.join('_')
    (self.full_text_indexes ||= []) <<
      FullTextIndex.new(index_name, dictionary, self, &block)
  end
end
