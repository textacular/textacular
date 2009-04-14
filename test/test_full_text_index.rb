require 'helper'

class TestFullTextIndex < TexticleTestCase
  def test_initialize
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fake_model) do
      name
      value 'A'
    end
    assert_equal 'name',  fti.index_columns['none'].first
    assert_equal 'value', fti.index_columns['A'].first
  end

  def test_destroy
    fm = fake_model
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fm) do
      name
      value 'A'
    end
    fti.destroy
    assert fm.connected
    assert_equal 1, fm.executed.length
    executed = fm.executed.first
    assert_match "DROP index #{fti.instance_variable_get(:@name)}", executed
  end

  def test_create
    fm = fake_model
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fm) do
      name
      value 'A'
    end
    fti.create
    assert fm.connected
    assert_equal 1, fm.executed.length
    executed = fm.executed.first
    assert_match fti.to_s, executed
    assert_match "CREATE index #{fti.instance_variable_get(:@name)}", executed
    assert_match "ON #{fm.table_name}", executed
  end

  def test_to_s_no_weight
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fake_model) do
      name
    end
    assert_equal "to_tsvector('english', coalesce(name, ''))", fti.to_s
  end

  def test_to_s_A_weight
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fake_model) do
      name 'A'
    end
    assert_equal "setweight(to_tsvector('english', coalesce(name, '')), 'A')", fti.to_s
  end

  def test_to_s_multi_weight
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fake_model) do
      name  'A'
      value 'A'
      description 'B'
    end
    assert_equal "setweight(to_tsvector('english', coalesce(name, '') || coalesce(value, '')), 'A') || ' ' || setweight(to_tsvector('english', coalesce(description, '')), 'B')", fti.to_s
  end

  def test_mixed_weight
    fti = Texticle::FullTextIndex.new('ft_index', 'english', fake_model) do
      name
      value 'A'
    end
    assert_equal "setweight(to_tsvector('english', coalesce(value, '')), 'A') || ' ' || to_tsvector('english', coalesce(name, ''))", fti.to_s
  end
end
