$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'textacular'

require "yaml"
require "minitest/pride"
require "minitest/autorun"
require "active_support/test_case"
require "byebug"

config = YAML.load_file File.expand_path(File.dirname(__FILE__) + '/config.yml')
ActiveRecord::Base.establish_connection config.merge(:adapter => :postgresql)

class BaseTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  if self.respond_to?(:fixture_paths=)
    self.fixture_paths << "#{File.dirname(__FILE__)}/fixtures/"
  else
    self.fixture_path = "#{File.dirname(__FILE__)}/fixtures/"
  end
  fixtures :all
end
