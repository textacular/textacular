# Module used to conform to Rails 3 plugin API
require File.expand_path(File.dirname(__FILE__) + '/../textacular')

module Textacular
  class Railtie < Rails::Railtie
    initializer "textacular.configure_rails_initialization" do
      ActiveRecord::Base.extend(Textacular)
    end
  end
end
