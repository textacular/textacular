module Texticle
  class FullTextIndex
    attr_accessor :index_columns

    def initialize name, model_class, &block
      @name           = name
      @model_class    = model_class
      @index_columns  = {}
      instance_eval(&block)
    end

    def create
      @model_class.connection.execute(<<-eosql)
        CREATE index #{@name}
        ON #{@model_class.table_name}
        USING gin((#{to_s}))
      eosql
    end

    def to_s
      vectors = []
      @index_columns.sort_by { |k,v| k }.each do |weight, columns|
        if weight == 'none'
          vectors << "to_tsvector('english', #{columns.join(", ")})"
        else
          vectors <<
        "setweight(to_tsvector('english', #{columns.join(", ")}), '#{weight}')"
        end
      end
      vectors.join(" || ' ' || ")
    end

    def method_missing name, *args
      weight = args.shift || 'none'
      (index_columns[weight] ||= []) << name.to_s
    end
  end
end
