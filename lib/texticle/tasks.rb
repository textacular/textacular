require 'rake'
require 'texticle'

namespace :texticle => [:environment] do
  task :create_indexes do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').classify.constantize
      if klass.respond_to?(:full_text_indexes)
        klass.full_text_indexes.each do |fti|
          fti.create
        end
      end
    end
  end

  task :destroy_indexes do
    Dir[File.join(RAILS_ROOT, 'app', 'models', '*.rb')].each do |f|
      klass = File.basename(f, '.rb').classify.constantize
      if klass.respond_to?(:full_text_indexes)
        klass.full_text_indexes.each do |fti|
          fti.destroy
        end
      end
    end
  end
end
