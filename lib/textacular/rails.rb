# Module used to conform to Rails 3 plugin API
require File.expand_path(File.dirname(__FILE__) + '/../textacular')

module Textacular
  class Railtie < Rails::Railtie
    initializer "textacular.configure_rails_initialization" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.extend(Textacular)
      end
    end

    rake_tasks do
      load 'textacular/tasks.rb'
    end
  end
end
