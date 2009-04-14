module Texticle
  class FullTextIndex
    attr_accessor :index_columns

    def initialize name, dictionary, model_class, &block
      @name           = name
      @dictionary     = dictionary
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

    def destroy
      @model_class.connection.execute(<<-eosql)
        DROP index #{@name}
      eosql
    end

    def to_s
      vectors = []
      @index_columns.sort_by { |k,v| k }.each do |weight, columns|
        c = columns.map { |x| "coalesce(#{x}, '')" }
        if weight == 'none'
          vectors << "to_tsvector('#{@dictionary}', #{c.join(" || ")})"
        else
          vectors <<
        "setweight(to_tsvector('#{@dictionary}', #{c.join(" || ")}), '#{weight}')"
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
