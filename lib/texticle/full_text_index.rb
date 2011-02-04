module Texticle
  class FullTextIndex # :nodoc:
    attr_accessor :index_columns
		cattr_accessor :rails_models_path
		@@rails_models_path =  File.join(Rails.root,"app","models")

    def initialize name, dictionary, model_class, &block
      @name           = name
      @dictionary     = dictionary
      @model_class    = model_class
      @index_columns  = {}
      @string         = nil
      instance_eval(&block)
    end

    def self.find_constant_of(filename)
      file_dir_name = File.dirname(filename)
      base_name = File.basename(filename, '.rb')
      rel_path = file_dir_name.gsub(@@rails_models_path,"")
      class_name = [rel_path,base_name].join('/').pluralize.classify
      class_name.constantize
    end

    def create
      @model_class.connection.execute create_sql
    end

    def destroy
      @model_class.connection.execute destroy_sql
    end

    def create_sql
      <<-eosql.chomp
CREATE index #{@name}
      ON #{@model_class.table_name}
      USING gin((#{to_s}))
      eosql
    end

    def destroy_sql
      "DROP index IF EXISTS #{@name}"
    end

    def to_s
      return @string if @string
      vectors = []
      @index_columns.sort_by { |k,v| k }.each do |weight, columns|
        c = columns.map { |x| "coalesce(\"#{@model_class.table_name}\".\"#{x}\", '')" }
        ts_vector = "to_tsvector('#{@dictionary}', #{c.join(" || ' ' || ")})"

        if weight == 'none'
          vectors << ts_vector
        else
          vectors << "setweight(#{ts_vector}, '#{weight}')"
        end
      end
      @string = vectors.join(" || ' ' || ")
    end

    def method_missing name, *args
      weight = args.shift || 'none'
      (index_columns[weight] ||= []) << name.to_s
    end
  end
end
