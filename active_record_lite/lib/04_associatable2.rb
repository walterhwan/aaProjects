require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      JOIN
        ON
      WHERE
        #{where_line}
    SQL
  end
end
