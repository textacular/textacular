require 'active_record'

module Texticle

  def search(query = {})
    language = connection.quote('english')

    unless query.is_a?(Hash)
      query = columns.select {|column| column.type == :string }.map(&:name).inject({}) do |terms, column|
        terms.merge column => query.to_s
      end
    end

    similarities = []
    conditions = []

    query.each do |column, search_term|
      column = connection.quote_column_name(column)
      search_term = connection.quote(search_term)
      similarities << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{search_term}))"
      conditions << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{search_term})"
    end

    select("#{quoted_table_name}.*, #{similarities.join(" + ")} as rank").
      where(conditions.join(" OR ")).order('rank DESC')
  end

end
