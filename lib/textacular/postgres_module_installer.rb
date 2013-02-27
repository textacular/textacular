module Textacular
  class PostgresModuleInstaller
    def install_module(module_name)
      major, minor, patch = postgres_version.split('.')

      if major.to_i >= 9 && minor.to_i >= 1
        install_postgres_91_module(module_name)
      else
        install_postgres_90_module(module_name)
      end
    end

    def db_name
      @db_name ||= ActiveRecord::Base.connection.current_database
    end

    private

    def postgres_version
      @postgres_version ||= ask_pg_config('version').match(/PostgreSQL ([0-9]+(\.[0-9]+)*)/)[1]
    end

    def postgres_share_dir
      @share_dir ||= ask_pg_config('sharedir')
    end

    def ask_pg_config(argument)
      result = `pg_config --#{argument}`.chomp

      raise RuntimeError, "Cannot find Postgres's #{argument}." unless $?.success?

      result
    end

    def install_postgres_90_module(module_name)
      module_location = "#{postgres_share_dir}/contrib/#{module_name}.sql"

      unless system("ls #{module_location}")
        raise RuntimeError, "Cannot find the #{module_name} module. Was it compiled and installed?"
      end

      unless system("psql -d #{db_name} -f #{module_location}")
        raise RuntimeError, "`psql -d #{db_name} -f #{module_location}` cannot complete successfully."
      end
    end

    def install_postgres_91_module(module_name)
      module_location = "#{postgres_share_dir}/extension/#{module_name}.control"

      unless system("ls #{module_location}")
        raise RuntimeError, "Cannot find the #{module_name} module. Was it compiled and installed?"
      end

      ActiveRecord::Base.connection.execute("CREATE EXTENSION #{module_name};")
    end
  end
end
