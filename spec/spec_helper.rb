config = YAML.load_file File.expand_path(File.dirname(__FILE__) + '/config.yml')

ActiveRecord::Base.establish_connection config.merge(:adapter => :postgresql)
