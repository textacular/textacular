require 'support/game_extended_with_textacular'

class GameExtendedWithTextacularAndCustomLanguage < GameExtendedWithTextacular
  def searchable_language
    'spanish'
  end
end
