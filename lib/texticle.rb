require 'texticle/full_text_index'

module Texticle
  VERSION = '1.0.0'

  attr_accessor :full_text_indexes

  def index &block
    class_eval(<<-eoruby)
      named_scope :search, lambda { |term|
        {
          :select => "*, ts_rank_cd((\#{full_text_indexes.first.to_s}),
            plainto_tsquery(\#{connection.quote(term)\})) as rank",
          :conditions =>
            ["\#{full_text_indexes.first.to_s} @@ plainto_tsquery(?)", term],
          :order => 'rank DESC'
        }
      }
    eoruby
    (self.full_text_indexes ||= []) << FullTextIndex.new
  end
end
