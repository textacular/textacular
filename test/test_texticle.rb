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
    # One named_scope for search, another for trigram search
    assert_equal 2, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_match "#{x.table_name}_fts_idx", x.executed.first
    assert_equal :search, x.named_scopes.first.first
    assert_equal :tsearch, x.named_scopes[1].first
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
    assert_equal 2, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_match "#{x.table_name}_awesome_fts_idx", x.executed.first
    assert_equal :search_awesome, x.named_scopes.first.first
    assert_equal :tsearch_awesome, x.named_scopes[1].first
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
    assert_match(/foo & bar & foo\\ bar/, ns[:select])
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
    assert_match(/foo & bar:*/, ns[:select])
  end
  
  def test_dictionary_in_select
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome', 'spanish') do
        name
      end
    end

    ns = x.named_scopes.first[1].call('foo')
    assert_match(/to_tsvector\('spanish'/, ns[:select])
    assert_match(/to_tsquery\('spanish'/, ns[:select])
  end

  def test_dictionary_in_conditions
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome', 'spanish') do
        name
      end
    end

    ns = x.named_scopes.first[1].call('foo')
    assert_match(/to_tsvector\('spanish'/, ns[:conditions].first)
    assert_equal 'spanish', ns[:conditions][1]
  end

  def test_multiple_named_indices
    x = fake_model
    x.class_eval do
      extend Texticle
      index('uno') do
        greco
      end
      index('due') do
        guapo
      end
    end

    # TODO: replace the call to #first,
    # as strings don't have such a method in Ruby 1.9.2
    assert_equal :search_uno,  x.named_scopes[0].first
    assert_match(/greco/,      x.named_scopes[0][1].call("foo")[:select].first)
    assert_match(/greco/,      x.named_scopes[0][1].call("foo")[:conditions].first)

    assert_equal :tsearch_uno, x.named_scopes[1].first
    assert_match(/greco/,      x.named_scopes[1][1].call("foo")[:select].first)
    assert_match(/greco/,      x.named_scopes[1][1].call("foo")[:conditions].first)

    assert_equal :search_due,  x.named_scopes[2].first
    assert_match(/guapo/,      x.named_scopes[2][1].call("foo")[:select].first)
    assert_match(/guapo/,      x.named_scopes[2][1].call("foo")[:conditions].first)

    assert_equal :tsearch_due, x.named_scopes[3].first
    assert_match(/guapo/,      x.named_scopes[3][1].call("foo")[:select].first)
    assert_match(/guapo/,      x.named_scopes[3][1].call("foo")[:conditions].first)
  end

end
