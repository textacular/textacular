class CreateTrigramExtension < ActiveRecord::Migration[ActiveRecord.version.to_s.match(/^(\d+\.)?(\d+)/)[0]]
  def up
    execute 'CREATE EXTENSION pg_trgm;'
  end

  def down
    execute 'DROP EXTENSION pg_trgm;'
  end
end
