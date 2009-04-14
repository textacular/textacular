require 'rake'
require 'texticle'

namespace :texticle do
  desc "Create full text indexes"
  task :create_indexes => [:environment] do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').classify.constantize
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          fti.create
        end
      end
    end
  end

  desc "Destroy full text indexes"
  task :destroy_indexes => [:environment] do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').classify.constantize
      if klass.respond_to?(:full_text_indexes)
        (klass.full_text_indexes || []).each do |fti|
          fti.destroy
        end
      end
    end
  end
end
