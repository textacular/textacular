require 'rubygems'

require 'rake'
require 'yaml'
require 'pg'
require 'active_record'
require 'benchmark'

require 'pry'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/spec')

task :default do
  Rake::Task["db:setup"].invoke
  Rake::Task["test"].invoke
end

file 'spec/config.yml' do |t|
  sh 'erb %s.example > %s' % [ t.name, t.name ]
end

task :environment => 'spec/config.yml' do |t|
  ActiveRecord::Base.establish_connection \
    YAML.load_file 'spec/config.yml'
end

desc 'Fire up an interactive terminal to play with'
task :console => :environment do
  Pry.start
end

task :test do
  require 'textacular_spec'
  require 'textacular/searchable_spec'
  require 'textacular/full_text_indexer_spec'
end

namespace :db do

  desc 'Create the test database'
  task :create do
    sh 'createdb textacular'
  end

  desc 'Drop the test database'
  task :drop do
    sh 'dropdb textacular'
  end

  namespace :migrate do
    class CreateDevelopmentTables < ActiveRecord::Migration
      def change
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

    desc 'Run the test database migrations'
    task :up => :environment do
      CreateDevelopmentTables.migrate :up
    end

    desc 'Reverse the test database migrations'
    task :down => :environment do
      CreateDevelopmentTables.migrate :down
    end
  end
  task :migrate => :'migrate:up'

  desc 'Create and configure the test database'
  task :setup => [ :create, :migrate ]

  desc 'Drop the test tables and database'
  task :teardown => [ :'migrate:down', :drop ]
end
