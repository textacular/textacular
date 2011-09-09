$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'yaml'
require 'texticle'
require 'shoulda'
require 'ruby-debug' if RUBY_VERSION =~ /$1\.8/

config = YAML.load_file File.expand_path(File.dirname(__FILE__) + '/config.yml')
ActiveRecord::Base.establish_connection config.merge(:adapter => :postgresql)
