require 'texticle'

def Searchable(*searchable_columns)
  Module.new do

    include Texticle

    private

    define_method(:searchable_columns) do
      searchable_columns.map(&:to_s)
    end
  end
end

Searchable = Texticle
