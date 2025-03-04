# frozen_string_literal: true

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, breed:, name:)
    @name = name
    @id = id
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
              id INTEGER PRIMARY KEY,
              name TEXT,
              breed TEXT
            )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = new(id: id, name: name, breed: breed)
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      new_from_db(row)
    end.first
  end

  def save
    if id
      update
    else
      sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def update
    sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1', name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = create(name: name, breed: breed)
    end

    dog
  end
end
