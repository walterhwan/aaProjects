require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    if class_name == "Human" || class_name == :Human
      class_name.to_s.underscore + 's'
    else
      class_name.to_s.underscore.pluralize
    end
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name.to_s.underscore.singularize}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.underscore.singularize}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      # foreign_key_val is a integer i.e foreign_key: :actor_id => id = 2
      foreign_key_val = self.send(options.foreign_key)
      model_class = options.model_class
      model_class.where(options.primary_key => foreign_key_val) .first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      # foreign_key_val is a integer i.e foreign_key: :actor_id => id = 2
      primary_key_val = self.send(options.primary_key)
      model_class = options.model_class
      model_class.where(options.foreign_key => primary_key_val)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
