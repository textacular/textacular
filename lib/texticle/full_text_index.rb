module Texticle
  class FullTextIndex
    attr_accessor :index_columns

    def initialize name, model_class, &block
      @name           = name
      @model_class    = model_class
      @index_columns  = {}
      instance_eval(&block)
    end

    def method_missing name, *args
      weight = args.shift || :none
      index_columns[weight] = name.to_s
    end
  end
end
