require 'active_record'

require 'textacular/version'

module Textacular
  autoload :FullTextIndexer,         'textacular/full_text_indexer'
  autoload :PostgresModuleInstaller, 'textacular/postgres_module_installer'
  autoload :TrigramInstaller,        'textacular/trigram_installer'
  autoload :MigrationGenerator,      'textacular/migration_generator'

  def self.searchable_language
    'english'
  end

  def search(query = "", exclusive = true)
    basic_search(query, exclusive)
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
        search_term = connection.quote Helper.normalize(search_term)

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
    "COALESCE(ts_rank(to_tsvector(#{quoted_language}, #{table_name}.#{column}::text), plainto_tsquery(#{quoted_language}, #{search_term}::text)), 0)"
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
    "COALESCE(ts_rank(to_tsvector(#{quoted_language}, #{table_name}.#{column}::text), to_tsquery(#{quoted_language}, #{search_term}::text)), 0)"
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
    "COALESCE(similarity(#{table_name}.#{column}, #{search_term}), 0)"
  end

  def fuzzy_condition_string(table_name, column, search_term)
    "(#{table_name}.#{column} % #{search_term})"
  end

  def assemble_query(similarities, conditions, exclusive)
    rank = connection.quote_column_name('rank' + rand(100000000000000000).to_s)

    select("#{quoted_table_name + '.*,' if select_values.empty?} #{similarities.join(" + ")} AS #{rank}").
      where(conditions.join(exclusive ? " AND " : " OR ")).
      order("#{rank} DESC")
  end

  def select_values
    if ActiveRecord::VERSION::MAJOR >= 4
      all.select_values
    else
      scoped.select_values
    end
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
        query.to_s.gsub(/\s(?![\&|\!|\|])/, '\\\\ ')
      end
    end
  end
end

require 'textacular/rails' if defined?(::Rails)
