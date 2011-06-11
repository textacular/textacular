require 'spec_helper'

class Game < ActiveRecord::Base
  # string :system
  # string :title
end

class TexticleTest < Test::Unit::TestCase

  context "after extending an ActiveRecord::Base subclass" do
    setup do
      Game.extend(Texticle)
    end

    teardown do
      Game.delete_all
    end

    should "define a #search method" do
      assert Game.methods.include?(:search)
    end
  end

end
