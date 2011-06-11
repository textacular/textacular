require 'active_record'

module Texticle

  def self.extended(klass)
    klass.instance_eval do
      scope :search, __search__
    end
  end

  private

  def __search__
    lambda do |query|
      query = connection.quote(query)
      language = connection.quote('english')
      string_columns = columns.select {|column| column.type == :string }.map {|column| connection.quote_column_name(column.name) }

      similarities = string_columns.inject([]) do |array, column|
        array << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{query}))"
      end.join(" + ")

      conditions = string_columns.inject([]) do |array, column|
        array << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{query})"
      end.join(" OR ")

      select("#{quoted_table_name}.*, #{similarities} as rank").
        where(conditions).order('rank DESC')
    end
  end

end
