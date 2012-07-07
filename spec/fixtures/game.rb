require 'active_record'

class Game < ActiveRecord::Base
  # string :system
  # string :title
  # text :description
end

class GameFail < Game; end
