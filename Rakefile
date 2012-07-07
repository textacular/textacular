require 'rubygems'

require 'rake'
require 'pg'
require 'active_record'
require 'benchmark'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/spec')

task :default do
  Rake::Task["db:setup"].invoke
  Rake::Task["test"].invoke
end

task :test do
  require 'texticle_spec'
  require 'texticle/searchable_spec'
end

namespace :db do
  desc 'Create and configure the test database'
  task :setup do
    spec_directory = "#{File.expand_path(File.dirname(__FILE__))}/spec"

    STDOUT.puts "Detecting database configuration..."

    if File.exists?("#{spec_directory}/config.yml")
      STDOUT.puts "Configuration detected. Skipping confguration."
    else
      STDOUT.puts "Would you like to create and configure the test database? y/N"
      continue = STDIN.gets.chomp

      unless continue =~ /^[y]$/i
        STDOUT.puts "Done."
        exit 0
      end

      STDOUT.puts "Creating database..."
      `createdb texticle`

      STDOUT.puts "Writing configuration file..."

      config_example = File.read("#{spec_directory}/config.yml.example")

      File.open("#{spec_directory}/config.yml", "w") do |config|
        config << config_example.sub(/<username>/, `whoami`.chomp)
      end

      STDOUT.puts "Running migrations..."
      Rake::Task["db:migrate"].invoke

      STDOUT.puts 'Done.'
    end
  end

  desc 'Run migrations for test database'
  task :migrate do
    require 'spec_helper'
    ActiveRecord::Migration.instance_eval do
      create_table :games do |table|
        table.string :system
        table.string :title
        table.text :description
      end
      create_table :web_comics do |table|

        table.string :name
        table.string :author
        table.text :review
        table.integer :id
      end

      create_table :characters do |table|
        table.string :name
        table.string :description
        table.integer :web_comic_id
      end
    end
  end

  desc 'Drop tables from test database'
  task :drop do
    require 'spec_helper'
    ActiveRecord::Migration.instance_eval do
      drop_table :games
      drop_table :web_comics
      drop_table :characters
    end
  end
end
