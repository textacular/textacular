require 'active_record'

module Texticle

  def search(query = {})
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
      search_term = connection.quote Helper.normalize(search_term)
      similarities << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{search_term}))"
      conditions << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{search_term})"
    end

    rank = connection.quote_column_name('rank' + rand.to_s)

    select("#{quoted_table_name}.*, #{similarities.join(" + ")} AS #{rank}").
      where(conditions.join(exclusive ? " AND " : " OR ")).
      order("#{rank} DESC")
  end

  private

  module Helper

    class << self

      def normalize(query)
        query.to_s.gsub(' ', '\\\\ ')
      end

    end

  end

end
