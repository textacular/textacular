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

    def table_name; 'fake_model'; end
  end

  def test_initialize
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name
      value 'A'
    end
    assert_equal 'name',  fti.index_columns['none'].first
    assert_equal 'value', fti.index_columns['A'].first
  end

  def test_create
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name
      value 'A'
    end
    fti.create
    assert fm.connected
    assert_equal 1, fm.executed.length
  end

  def test_to_s_no_weight
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name
    end
    assert_equal "to_tsvector('english', name)", fti.to_s
  end

  def test_to_s_A_weight
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name 'A'
    end
    assert_equal "setweight(to_tsvector('english', name), 'A')", fti.to_s
  end

  def test_to_s_multi_weight
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name  'A'
      value 'A'
      description 'B'
    end
    assert_equal "setweight(to_tsvector('english', name, value), 'A') || ' ' || setweight(to_tsvector('english', description), 'B')", fti.to_s
  end

  def test_mixed_weight
    fm = FakeModel.new
    fti = Texticle::FullTextIndex.new('ft_index', fm) do
      name
      value 'A'
    end
    assert_equal "setweight(to_tsvector('english', value), 'A') || ' ' || to_tsvector('english', name)", fti.to_s
  end
end
