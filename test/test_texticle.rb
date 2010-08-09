require 'helper'

class TestTexticle < TexticleTestCase
  def test_index_method
    x = fake_model
    x.class_eval do
      extend Texticle
      index do
        name
      end
    end
    assert_equal 1, x.full_text_indexes.length
    assert_equal 1, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_match "#{x.table_name}_fts_idx", x.executed.first
    assert_equal :search, x.named_scopes.first.first
  end

  def test_named_index
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    assert_equal 1, x.full_text_indexes.length
    assert_equal 1, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_match "#{x.table_name}_awesome_fts_idx", x.executed.first
    assert_equal :search_awesome, x.named_scopes.first.first
  end

  def test_named_scope_select
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    ns = x.named_scopes.first[1].call('foo')
    assert_match(/^#{x.table_name}\.\*/, ns[:select])
  end
  
  def test_double_quoted_queries
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    
    ns = x.named_scopes.first[1].call('foo bar "foo bar"')
    assert_match(/'foo' & 'bar' & 'foo bar'/, ns[:select])
  end
  
  def test_wildcard_queries
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    
    ns = x.named_scopes.first[1].call('foo bar*')
    assert_match(/'foo' & 'bar:*'/, ns[:select])
  end
end
