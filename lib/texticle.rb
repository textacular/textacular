require 'texticle/full_text_index'

module Texticle
  VERSION = '1.0.0'

  attr_accessor :full_text_indexes

  def index name = nil, &block
    search_name = ['search', name].compact.join('_')

    class_eval(<<-eoruby)
      named_scope :#{search_name}, lambda { |term|
        {
          :select => "\#{table_name}.*, ts_rank_cd((\#{full_text_indexes.first.to_s}),
            plainto_tsquery(\#{connection.quote(term)\})) as rank",
          :conditions =>
            ["\#{full_text_indexes.first.to_s} @@ plainto_tsquery(?)", term],
          :order => 'rank DESC'
        }
      }
    eoruby
    index_name = [table_name, name, 'fts_idx'].compact.join('_')
    (self.full_text_indexes ||= []) <<
      FullTextIndex.new(index_name, self, &block)
  end
end
