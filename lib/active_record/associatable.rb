class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.to_s.constantize
  end

  def table_name
    "#{class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||
                     "#{self_class_name.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options_hash = {})
    options = BelongsToOptions.new(name, options_hash)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      other_table_name = options.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          other.*
        FROM
          #{self.class.table_name} self
        JOIN
          #{other_table_name} other
        ON
          other.#{primary_key} = self.#{foreign_key}
        WHERE
          self.id = ?
      SQL

      options.model_class.parse_all(results).first
    end
  end

  def has_many(name, options_hash = {})
    if options_hash.keys.include?(:through)
      return has_many_through(name, options_hash)
    end

    options = HasManyOptions.new(name, self.name, options_hash)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      other_table_name = options.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          other.*
        FROM
          #{self.class.table_name} self
        JOIN
          #{other_table_name} other
        ON
          self.#{primary_key} = other.#{foreign_key}
        WHERE
          self.id = ?
      SQL

      options.model_class.parse_all(results)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      result = DBConnection.execute(<<-SQL, self.id)
        SELECT
          source.*
        FROM
          #{self.class.table_name} self
        JOIN
          #{through_options.table_name} through
        ON
          through.id = self.#{through_options.foreign_key}
        JOIN
          #{source_options.table_name} source
        ON
          source.id = through.#{source_options.foreign_key}
        WHERE
          self.id = ?
      SQL

      source_options.model_class.parse_all(result).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
