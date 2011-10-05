require 'rake'
require 'texticle'

namespace :texticle do
  desc 'Create full text search index migration'
  task :create_index_migration => :environment do
    Texticle::FullTextIndexer.new.generate_migration
  end
end
