require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = 
    "CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  # updates a record if called on an object that is already persisted
  def save
      if self.id
        self.update
      else 
      sql = "INSERT INTO students (name, grade)
      VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade) 
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end 
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id = row[0]
    name =  row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  # query the database table for a record that has a name of the name passed in as an argument. 
  # Then use #new_from_db method to instantiate a Student object with the database row that 
  # the SQL query returns.
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Student.new(result[0], result[1], result[2])
  end

  #This method updates the database row mapped to the given Student instance.
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
