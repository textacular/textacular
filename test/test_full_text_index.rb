require "test/unit"
require "texticle"

class TestFullTextIndex < Test::Unit::TestCase
  class FakeModel
    attr_accessor :connected, :executed

    def initialize
      @connected = false
      @executed  = []
    end

    def connection
      @connected = true
      self
    end

    def execute sql
      @executed << sql
    end
  end

  def test_initialize
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name
      value 'A'
    end
    assert_equal 'name',  fti.index_columns[:none]
    assert_equal 'value', fti.index_columns['A']
  end
end
