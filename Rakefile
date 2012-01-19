require 'rubygems'

require 'rake'
require 'pg'
require 'active_record'
require 'benchmark'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/spec')

task :default do
  config = File.open(File.expand_path(File.dirname(__FILE__) + '/spec/config.yml')).read
  if config.match /<username>/
    print "Would you like to create and configure the test database? y/n "
    continue = STDIN.getc
    exit 0 unless continue == "Y" || continue == "y"
    sh "createdb texticle"
    File.open(File.expand_path(File.dirname(__FILE__) + '/spec/config.yml'), "w") do |writable_config|
      writable_config << config.sub(/<username>/, `whoami`.chomp)
    end
    Rake::Task["db:migrate"].invoke
  end
  Rake::Task["test"].invoke
end

task :test do
  require 'texticle_spec'
  require 'texticle/searchable_spec'
end

namespace :db do
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
