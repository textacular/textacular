require 'active_record'

module Texticle

  def search(query = {})
    language = connection.quote('english')

    unless query.is_a?(Hash)
      query = columns.select {|column| column.type == :string }.map(&:name).inject({}) do |terms, column|
        terms.merge column => query.to_s
      end
    end

    similarities = query.inject([]) do |sql, pair|
      column, text = pair
      column = connection.quote_column_name(column)
      text = connection.quote(text)
      sql << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{text}))"
    end.join(" + ")

    conditions = query.inject([]) do |sql, pair|
      column, text = pair
      column = connection.quote_column_name(column)
      text = connection.quote(text)
      sql << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{text})"
    end.join(" OR ")

    select("#{quoted_table_name}.*, #{similarities} as rank").
      where(conditions).order('rank DESC')
  end

end
