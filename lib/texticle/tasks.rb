require 'rake'
require 'texticle'

namespace :texticle do
  desc "Create full text index migration"
  task :migration => :environment do
    now = Time.now.utc
    filename = "#{now.strftime('%Y%m%d%H%M%S')}_full_text_search_#{now.to_i}.rb"
    File.open(File.join(RAILS_ROOT, 'db', 'migrate', filename), 'wb') { |fh|
      fh.puts "class FullTextSearch#{now.to_i} < ActiveRecord::Migration"
      fh.puts "  def self.up"
      Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
        klass = File.basename(f, '.rb').pluralize.classify.constantize
        if klass.respond_to?(:full_text_indexes)
          (klass.full_text_indexes || []).each do |fti|
            fh.puts <<-eostmt
      ActiveRecord::Base.connection.execute(<<-'eosql')
        #{fti.destroy_sql}
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        #{fti.create_sql}
      eosql
            eostmt
          end
        end
      end
      fh.puts "  end"
      fh.puts "end"
    }
  end

  desc "Create full text indexes"
  task :create_indexes => ['texticle:destroy_indexes'] do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').pluralize.classify.constantize
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          begin
            fti.create
          rescue ActiveRecord::StatementInvalid => e
            warn "WARNING: Couldn't create index for #{klass.to_s}, skipping..."
          end
        end
      end
    end
  end

  desc "Destroy full text indexes"
  task :destroy_indexes => [:environment] do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').pluralize.classify.constantize
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          fti.destroy
        end
      end
    end
  end
end
