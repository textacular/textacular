require 'textacular'

include Pry::Helpers::BaseHelpers

Pry.output.puts heading(<<-EOS.strip)
Welcome to the Textacular developer console!
You have some classes you can play with:
EOS

##
# Load all of the fixture classes and print their sources.
Dir[ './spec/fixtures/**.rb' ].each do |f|
  require f
  Pry.output.puts colorize_code( File.read( f ) )
  Pry.output.puts
end

##
# Reloads the console.
def reload
  Pry.save_history
  exec [ $0, ARGV ].flatten.shelljoin
end
alias :reload! :reload
