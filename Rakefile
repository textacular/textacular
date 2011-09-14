require 'rubygems'

require 'rake'
require 'pg'
require 'active_record'
require 'benchmark'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/spec')
require 'spec_helper'

task :default => :test

task :test do
  require 'texticle_spec'
  require 'texticle/searchable_spec'
end

namespace :db do
  desc 'Run migrations for test database'
  task :migrate do
    ActiveRecord::Migration.instance_eval do
      create_table :games do |table|
        table.string :system
        table.string :title
      end
      create_table :web_comics do |table|
        table.string :name
        table.string :author
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
