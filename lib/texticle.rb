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
      text_columns = columns.select {|column| column.type == :string }.map(&:name)

      similarities = text_columns.inject([]) do |array, column|
        array << "ts_rank(to_tsvector(#{quoted_table_name}.#{column}), to_tsquery(#{query}))"
      end.join(" + ")

      conditions = text_columns.inject([]) do |array, column|
        array << "to_tsvector(#{language}, #{column}) @@ to_tsquery(#{query})"
      end.join(" OR ")

      select("#{quoted_table_name}.*, #{similarities} as rank").
        where(conditions).order('rank DESC')
    end
  end

end
