require "bundler/gem_tasks"

require 'active_record'
require 'pry'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

file 'spec/config.yml' do |t|
  sh 'erb spec/config.yml.example > spec/config.yml'
end

desc 'Fire up an interactive terminal to play with'
task :console => :'db:connect' do
  Pry.start
end

namespace :db do

  task :connect => 'spec/config.yml' do |t|
    ActiveRecord::Base.establish_connection \
      YAML.load_file 'spec/config.yml'
  end

  task :disconnect do
    ActiveRecord::Base.clear_all_connections!
  end

  desc 'Create the test database'
  task :create do
    sh 'createdb textacular'
  end

  desc 'Drop the test database'
  task :drop => :disconnect do
    sh 'dropdb textacular'
  end

  namespace :migrate do

    desc 'Run the test database migrations'
    task :up => :'db:connect' do
      if ActiveRecord.version >= Gem::Version.new('6.0.0')
        context = ActiveRecord::Migration.new.migration_context
        migrations = context.migrations
        schema_migration = context.schema_migration
      elsif ActiveRecord.version >= Gem::Version.new('5.2')
        migrations = ActiveRecord::Migration.new.migration_context.migrations
        schema_migration = nil
      else
        migrations = ActiveRecord::Migrator.migrations('db/migrate')
        schema_migration = nil
      end
      ActiveRecord::Migrator.new(:up, migrations, schema_migration).migrate
    end

    desc 'Reverse the test database migrations'
    task :down => :'db:connect' do
      migrations = if ActiveRecord.version.version >= '5.2'
        ActiveRecord::Migration.new.migration_context.migrations
      else
        ActiveRecord::Migrator.migrations('db/migrate')
      end
      ActiveRecord::Migrator.new(:down, migrations, nil).migrate
    end
  end
  task :migrate => :'migrate:up'

  desc 'Create and configure the test database'
  task :setup => [ :create, :migrate ]

  desc 'Drop the test tables and database'
  task :teardown => [ :'migrate:down', :drop ]
end
