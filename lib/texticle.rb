require 'active_record'

module Texticle

  def search(query = "", exclusive = true)
    language = connection.quote(searchable_language)

    unless query.is_a?(Hash)
      exclusive = false
      query = searchable_columns.inject({}) do |terms, column|
        terms.merge column => query.to_s
      end
    end

    similarities = []
    conditions = []

    query.each do |column, search_term|
      column = connection.quote_column_name(column)
      search_term = connection.quote normalize(Helper.normalize(search_term))
      similarities << "ts_rank(to_tsvector(#{language}, #{quoted_table_name}.#{column}::text), to_tsquery(#{language}, #{search_term}::text))"
      conditions << "to_tsvector(#{language}, #{quoted_table_name}.#{column}::text) @@ to_tsquery(#{language}, #{search_term}::text)"
    end

    rank = connection.quote_column_name('rank' + rand.to_s)

    select("#{quoted_table_name + '.*,' if scoped.select_values.empty?} #{similarities.join(" + ")} AS #{rank}").
      where(conditions.join(exclusive ? " AND " : " OR ")).
      order("#{rank} DESC")
  end

  def method_missing(method, *search_terms)
    return super if self == ActiveRecord::Base
    if Helper.dynamic_search_method?(method, self.columns)
      exclusive = Helper.exclusive_dynamic_search_method?(method, self.columns)
      columns = exclusive ? Helper.exclusive_dynamic_search_columns(method) : Helper.inclusive_dynamic_search_columns(method)
      metaclass = class << self; self; end
      metaclass.__send__(:define_method, method) do |*args|
        query = columns.inject({}) do |query, column|
          query.merge column => args.shift
        end
        search(query, exclusive)
      end
      __send__(method, *search_terms, exclusive)
    else
      super
    end
  rescue ActiveRecord::StatementInvalid
    super
  end

  def respond_to?(method, include_private = false)
    return super if self == ActiveRecord::Base
    Helper.dynamic_search_method?(method, self.columns) or super
  rescue StandardError
    super
  end

  private

  def normalize(query)
    query
  end

  def searchable_columns
    columns.select {|column| [:string, :text].include? column.type }.map(&:name)
  end

  def searchable_language
    'english'
  end

  module Helper
    class << self
      def normalize(query)
        query.to_s.gsub(' ', '\\\\ ')
      end

      def exclusive_dynamic_search_columns(method)
        if match = method.to_s.match(/^search_by_(?<columns>[_a-zA-Z]\w*)$/)
          match[:columns].split('_and_')
        else
          []
        end
      end

      def inclusive_dynamic_search_columns(method)
        if match = method.to_s.match(/^search_by_(?<columns>[_a-zA-Z]\w*)$/)
          match[:columns].split('_or_')
        else
          []
        end
      end

      def exclusive_dynamic_search_method?(method, class_columns)
        string_columns = class_columns.map(&:name)
        columns = exclusive_dynamic_search_columns(method)
        unless columns.empty?
          columns.all? {|column| string_columns.include?(column) }
        else
          false
        end
      end

      def inclusive_dynamic_search_method?(method, class_columns)
        string_columns = class_columns.map(&:name)
        columns = inclusive_dynamic_search_columns(method)
        unless columns.empty?
          columns.all? {|column| string_columns.include?(column) }
        else
          false
        end
      end

      def dynamic_search_method?(method, class_columns)
        exclusive_dynamic_search_method?(method, class_columns) or
          inclusive_dynamic_search_method?(method, class_columns)
      end
    end
  end

end
