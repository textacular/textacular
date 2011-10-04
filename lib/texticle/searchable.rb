require 'texticle'

def Searchable(*searchable_columns)
  Module.new do

    include Texticle

    define_method(:searchable_columns) do
      searchable_columns.map(&:to_s)
    end

    private :searchable_columns

    def indexable_columns
      searchable_columns.to_enum
    end
  end
end

Searchable = Texticle
