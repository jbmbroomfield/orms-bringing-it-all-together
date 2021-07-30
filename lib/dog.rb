class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        self.name = name
        self.breed = breed
        self.id = id
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
    
    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(**kwargs)
        dog = self.new(**kwargs)
        dog.save
    end

    def self.new_from_db(array)
        (id, name, breed = array) && self.new(name: name, breed: breed, id: id)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id)[0]
        self.new_from_db(result)
    end

    def self.find_by(**kwargs)
        hash_string = kwargs.map { |key, value| "#{key} = '#{value}'"}.join(' AND ')
        sql = <<-SQL
            SELECT * FROM dogs WHERE #{hash_string}
        SQL
        result = DB[:conn].execute(sql)
        self.new_from_db(result[0])
    end

    def self.find_or_create_by(**kwargs)
        self.find_by(**kwargs) || self.create(**kwargs)
    end

    def self.find_by_name(name)
        self.find_by(name: name)
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end
end
