require 'rake'
require 'texticle'

namespace :texticle do
  desc 'Create FTS text index migration'
  task :create_index_migration => :environment do
    Texticle::FullTextIndexer.generate_migration
  end
end
