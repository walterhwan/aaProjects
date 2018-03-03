require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.


class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.reduce([]) do |objects, hash|
      objects << self.new(hash)
    end
  end

  def self.find(id)
    all_results = self.all
    all_results.find { |obj| obj.id == id }
  end

  def initialize(params = {})
    params.each_pair do |attr_name, val|
      attr_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_sym}'" unless self.class.columns.include?(attr_sym)
      send("#{attr_sym}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      send(col)
    end
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(', ')
    question_marks = (["?"] * columns.length).join(', ')
    table_name = self.class.table_name

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    last_id = DBConnection.last_insert_row_id
    send("id=", last_id)
  end

  def update
    set_line = self.class.columns.map { |col| "#{col} = ?" } .join(', ')
    where_line = "id = #{send(:id)}"

    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{where_line}
    SQL
  end

  def save
    send(:id).nil? ? insert : update
  end
end
