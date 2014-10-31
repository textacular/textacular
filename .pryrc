require 'textacular'
require 'yaml'
require 'database_cleaner'

include Pry::Helpers::BaseHelpers

Pry.output.puts heading(<<-EOS.strip)
Welcome to the Textacular developer console!
You have some classes you can play with:
EOS

$LOAD_PATH.push(Pathname.new('./spec').realpath.to_s)

##
# Load all of the fixture classes and print their sources.
Dir[ './spec/support/**.rb' ].each do |f|
  require f
  Pry.output.puts colorize_code( File.read( f ) )
  Pry.output.puts
end

config = YAML.load_file File.expand_path(File.dirname(__FILE__) + '/spec/config.yml')
ActiveRecord::Base.establish_connection config.merge(:adapter => :postgresql)
DatabaseCleaner.clean_with(:truncation)
ActiveRecord::Base.logger = Logger.new(STDOUT)

##
# Reloads the console.
def reload
  Pry.save_history
  exec [ $0, ARGV ].flatten.shelljoin
end
alias :reload! :reload
