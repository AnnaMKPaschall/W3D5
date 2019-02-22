require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
    SELECT 
      * 
    FROM 
      #{self.table_name};
    SQL

    @columns[0].map {|col| col.to_sym}
  end

  def self.finalize!
    # debugger
    columns.each do |col| 
      define_method(col) {self.attributes[col]} #will get key for key value hash (id, name, etc)
      define_method("#{col}=") {|val| self.attributes[col] = val} #need to interpolate because col here is a symbol 

      #define_method("#{name}=") {|val| instance_variable_set("@#{name}", val )} From previous page
    end
  end

  def self.table_name=(table_name)
    # define_method("#{table_name}=") {|val| instance_variable_set("@#{table_name}", val)}
    # self.table_name = table_name ||= "humen"
    @table_name = table_name 
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
    #{table_name}
SQL
parse_all(rows)
#  rows.map {|row| self.parse_all(row)}
#   debugger
#    objs = @rows.map {|row| self.parse_all(row)}
 
  end

  def self.parse_all(results)
    parse = []
    results.each do |result| 
      parse << self.new(result)
    end 
    # debugger 
    parse 
  end 
  
#  class SQLObject
#   def self.find(id)
#   self.all.find { |obj| obj.id == id }
#   end
# end
  def self.find(id)
    # debugger
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
    #{table_name}
    WHERE 
    id = ? 
    SQL
    parse_all(result).first 
  end


  def initialize(params = {})
    # params ||= {}
    params.each do |attr_name, value| #attr_name is key, value is value 
      attr_sym = attr_name.to_sym  
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_sym)

      self.send("#{attr_name}=", value)
    end
  end

  def attributes
   @attributes ||= {} #lazy assignment of empty hash to attributes unless it already exists 
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    col_names = self.columns.join(",")
    q_marks = []
    DBConnection.execute(<<-SQL, *attribute_values, *col_names)
      INSERT INTO 
        self.table_name(*col_names)
      VALUES 
        q_marks.
    
    
    SQL

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
