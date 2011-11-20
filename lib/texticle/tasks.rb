require 'rake'
require 'texticle'

namespace :texticle do
  desc 'Create full text search index migration, give the model for which you want to create the indexes'
  task :create_index_migration, [:model_name] => :environment do |t,args|
    raise 'A model name is required' unless args[:model_name]
    Texticle::FullTextIndexer.new.generate_migration(args[:model_name])
  end
end
