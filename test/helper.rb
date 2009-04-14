require "test/unit"
require "texticle"

class TexticleTestCase < Test::Unit::TestCase
  unless RUBY_VERSION >= '1.9'
    undef :default_test
  end

  def setup
    warn "#{name}" if ENV['TESTOPTS'] == '-v'
  end

  def fake_model
    Class.new do
      @connected    = false
      @executed     = []
      @named_scopes = []

      class << self
        attr_accessor :connected, :executed, :named_scopes

        def connection
          @connected = true
          self
        end

        def execute sql
          @executed << sql
        end

        def table_name; 'fake_model'; end

        def named_scope *args
          @named_scopes << args
        end

        def quote thing
          "'#{thing}'"
        end
      end
    end
  end
end
