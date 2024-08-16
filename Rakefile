require "bundler/gem_tasks"

require 'active_record'
require 'pry'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

file 'spec/config.yml' do |t|
  sh 'erb spec/config.yml.example > spec/config.yml'
end

desc 'Fire up an interactive terminal to play with'
task :console => :'db:connect' do
  Pry.start
end

namespace :db do

  task :connect => 'test/config.yml' do |t|
    ActiveRecord::Base.establish_connection \
      YAML.load_file 'test/config.yml'
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
      if ActiveRecord.version >= Gem::Version.new('7.2.0')
        ActiveRecord::Base.connection_pool.migration_context.up
      elsif ActiveRecord.version >= Gem::Version.new('6.0.0')
        ActiveRecord::Migration.new.migration_context.up
      elsif ActiveRecord.version >= Gem::Version.new('5.2')
        migrations = ActiveRecord::Migration.new.migration_context.migrations
        ActiveRecord::Migrator.new(:up, migrations, nil).migrate
      else
        migrations = ActiveRecord::Migrator.migrations('db/migrate')
        ActiveRecord::Migrator.new(:up, migrations, nil).migrate
      end
    end

    desc 'Reverse the test database migrations'
    task :down => :'db:connect' do
      if ActiveRecord.version >= Gem::Version.new('7.2.0')
        ActiveRecord::Base.connection_pool.migration_context.down
      elsif ActiveRecord.version >= Gem::Version.new('6.0.0')
        ActiveRecord::Migration.new.migration_context.down
      elsif ActiveRecord.version >= Gem::Version.new('5.2')
        migrations = ActiveRecord::Migration.new.migration_context.migrations
        ActiveRecord::Migrator.new(:down, migrations, nil).migrate
      else
        migrations = ActiveRecord::Migrator.migrations('db/migrate')
        ActiveRecord::Migrator.new(:down, migrations, nil).migrate
      end
    end
  end
  task :migrate => :'migrate:up'

  desc 'Create and configure the test database'
  task :setup => [ :create, :migrate ]

  desc 'Drop the test tables and database'
  task :teardown => [ :'migrate:down', :drop ]
end
