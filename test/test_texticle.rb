require "test/unit"
require "texticle"

class TestTexticle < Test::Unit::TestCase
  def test_index_method
    x = Class.new {
      extend Texticle
      class << self; attr_accessor :ns; end

      def self.named_scope *args
        self.ns = [args]
      end

      index do
        name
      end
    }
    assert_equal 1, x.full_text_indexes.length
    assert_equal 1, x.ns.length
  end
end
