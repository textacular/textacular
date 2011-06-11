require 'rubygems'

require 'rake'
require 'pg'
require 'active_record'
require 'benchmark'

require './spec/spec_helper'

namespace :db do
  desc 'Run migrations for test database'
  task :migrate do
    ActiveRecord::Migration.instance_eval do
      create_table :games do |table|
        table.string :system
        table.string :title
      end
    end
  end
end
