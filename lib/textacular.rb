require 'active_record'

require 'textacular/version'

module Textacular
  def self.searchable_language
    'english'
  end

  def search(query = "", exclusive = true)
    warn "[DEPRECATION] `search` is deprecated. Please use `advanced_search` instead. At the next major release `search` will become an alias for `basic_search`."
    advanced_search(query, exclusive)
  end

  def basic_search(query = "", exclusive = true)
    exclusive, query = munge_exclusive_and_query(exclusive, query)
    parsed_query_hash = parse_query_hash(query)
    similarities, conditions = basic_similarities_and_conditions(parsed_query_hash)
    assemble_query(similarities, conditions, exclusive)
  end

  def advanced_search(query = "", exclusive = true)
    exclusive, query = munge_exclusive_and_query(exclusive, query)
    parsed_query_hash = parse_query_hash(query)
    similarities, conditions = advanced_similarities_and_conditions(parsed_query_hash)
    assemble_query(similarities, conditions, exclusive)
  end

  def fuzzy_search(query = '', exclusive = true)
    exclusive, query = munge_exclusive_and_query(exclusive, query)
    parsed_query_hash = parse_query_hash(query)
    similarities, conditions = fuzzy_similarities_and_conditions(parsed_query_hash)
    assemble_query(similarities, conditions, exclusive)
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
        self.send(Helper.search_type(method), query, exclusive)
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

  def munge_exclusive_and_query(exclusive, query)
    unless query.is_a?(Hash)
      exclusive = false
      query = searchable_columns.inject({}) do |terms, column|
        terms.merge column => query.to_s
      end
    end

    [exclusive, query]
  end

  def parse_query_hash(query, table_name = quoted_table_name)
    table_name = connection.quote_table_name(table_name)

    results = []

    query.each do |column_or_table, search_term|
      if search_term.is_a?(Hash)
        results += parse_query_hash(search_term, column_or_table)
      else
        column = connection.quote_column_name(column_or_table)
        search_term = connection.quote normalize(Helper.normalize(search_term))

        results << [table_name, column, search_term]
      end
    end

    results
  end

  def basic_similarities_and_conditions(parsed_query_hash)
    parsed_query_hash.inject([[], []]) do |(similarities, conditions), query_args|
      similarities << basic_similarity_string(*query_args)
      conditions << basic_condition_string(*query_args)

      [similarities, conditions]
    end
  end

  def basic_similarity_string(table_name, column, search_term)
    "ts_rank(to_tsvector(#{quoted_language}, #{table_name}.#{column}::text), plainto_tsquery(#{quoted_language}, #{search_term}::text))"
  end

  def basic_condition_string(table_name, column, search_term)
    "to_tsvector(#{quoted_language}, #{table_name}.#{column}::text) @@ plainto_tsquery(#{quoted_language}, #{search_term}::text)"
  end

  def advanced_similarities_and_conditions(parsed_query_hash)
    parsed_query_hash.inject([[], []]) do |(similarities, conditions), query_args|
      similarities << advanced_similarity_string(*query_args)
      conditions << advanced_condition_string(*query_args)

      [similarities, conditions]
    end
  end

  def advanced_similarity_string(table_name, column, search_term)
    "ts_rank(to_tsvector(#{quoted_language}, #{table_name}.#{column}::text), to_tsquery(#{quoted_language}, #{search_term}::text))"
  end

  def advanced_condition_string(table_name, column, search_term)
    "to_tsvector(#{quoted_language}, #{table_name}.#{column}::text) @@ to_tsquery(#{quoted_language}, #{search_term}::text)"
  end

  def fuzzy_similarities_and_conditions(parsed_query_hash)
    parsed_query_hash.inject([[], []]) do |(similarities, conditions), query_args|
      similarities << fuzzy_similarity_string(*query_args)
      conditions << fuzzy_condition_string(*query_args)

      [similarities, conditions]
    end
  end

  def fuzzy_similarity_string(table_name, column, search_term)
    "similarity(#{table_name}.#{column}, #{search_term})"
  end

  def fuzzy_condition_string(table_name, column, search_term)
    "(#{table_name}.#{column} % #{search_term})"
  end

  def assemble_query(similarities, conditions, exclusive)
    rank = connection.quote_column_name('rank' + rand.to_s)

    select("#{quoted_table_name + '.*,' if scoped.select_values.empty?} #{similarities.join(" + ")} AS #{rank}").
      where(conditions.join(exclusive ? " AND " : " OR ")).
      order("#{rank} DESC")
  end

  def normalize(query)
    query
  end

  def searchable_columns
    columns.select {|column| [:string, :text].include? column.type }.map(&:name)
  end

  def quoted_language
    @quoted_language ||= connection.quote(searchable_language)
  end

  def searchable_language
    Textacular.searchable_language
  end

  module Helper
    class << self
      def normalize(query)
        query.to_s.gsub(' ', '\\\\ ')
      end

      def method_name_regex
        /^(?<search_type>((basic|advanced|fuzzy)_)?search)_by_(?<columns>[_a-zA-Z]\w*)$/
      end

      def search_type(method)
        method.to_s.match(method_name_regex)[:search_type]
      end

      def exclusive_dynamic_search_columns(method)
        if match = method.to_s.match(method_name_regex)
          match[:columns].split('_and_')
        else
          []
        end
      end

      def inclusive_dynamic_search_columns(method)
        if match = method.to_s.match(method_name_regex)
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

require File.expand_path(File.dirname(__FILE__) + '/textacular/full_text_indexer')
