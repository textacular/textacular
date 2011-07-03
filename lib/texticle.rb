require 'active_record'

module Texticle

  def search(query = "")
    language = connection.quote('english')

    exclusive = true

    unless query.is_a?(Hash)
      exclusive = false
      query = columns.select {|column| column.type == :string }.map(&:name).inject({}) do |terms, column|
        terms.merge column => query.to_s
      end
    end

    similarities = []
    conditions = []

    query.each do |column, search_term|
      column = connection.quote_column_name(column)
      search_term = connection.quote normalize(Helper.normalize(search_term))
      similarities << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{search_term}))"
      conditions << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{search_term})"
    end

    rank = connection.quote_column_name('rank' + rand.to_s)

    select("#{quoted_table_name}.*, #{similarities.join(" + ")} AS #{rank}").
      where(conditions.join(exclusive ? " AND " : " OR ")).
      order("#{rank} DESC")
  end

  def method_missing(method, *search_terms)
    if Helper.dynamic_search_method?(method, self.columns)
      columns = Helper.dynamic_search_columns(method)
      metaclass = class << self; self; end
      metaclass.__send__(:define_method, method) do |*args|
        query = columns.inject({}) do |query, column|
          query.merge column => args.shift
        end
        search(query)
      end
      __send__(method, *search_terms)
    else
      super
    end
  end

  def respond_to?(method, include_private = false)
    Helper.dynamic_search_method?(method, self.columns) ? true : super
  end

  private

  def normalize(query)
    query
  end

  module Helper
    class << self
      def normalize(query)
        query.to_s.gsub(' ', '\\\\ ')
      end

      def dynamic_search_columns(method)
        if match = method.to_s.match(/search_by_(?<columns>[_a-zA-Z]\w*)/)
          match[:columns].split('_and_')
        else
          []
        end
      end

      def dynamic_search_method?(method, class_columns)
        string_columns = class_columns.select {|column| column.type == :string }.map(&:name)
        columns = dynamic_search_columns(method)
        unless columns.empty?
          columns.all? {|column| string_columns.include?(column) }
        else
          false
        end
      end
    end
  end

end
