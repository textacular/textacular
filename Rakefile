require 'rubygems'

require 'rake'
require 'pg'
require 'active_record'
require 'benchmark'

require File.expand_path(File.dirname(__FILE__) + '/spec/spec_helper')

namespace :db do
  desc 'Run migrations for test database'
  task :migrate do
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
      end
    end
  end
  desc 'Drop tables from test database'
  task :drop do
    ActiveRecord::Migration.instance_eval do
      drop_table :games
      drop_table :web_comics
    end
  end
end
