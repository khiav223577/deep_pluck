require 'rails_compatibility'
require 'rails_compatibility/unscope_where'
require 'deep_pluck/data_combiner'

module DeepPluck
  class Model
    # ----------------------------------------------------------------
    # ● Initialize
    # ----------------------------------------------------------------
    def initialize(relation, parent_association_key = nil, parent_model = nil, need_columns: [])
      if relation.is_a?(ActiveRecord::Base)
        @model = relation
        @relation = nil
        @klass = @model.class
      else
        @model = nil
        @relation = relation
        @klass = @relation.klass
      end

      @parent_association_key = parent_association_key
      @parent_model = parent_model
      @need_columns = need_columns
      @associations = {}
    end

    # ----------------------------------------------------------------
    # ● Reader
    # ----------------------------------------------------------------
    def get_reflect(association_key)
      @klass.reflect_on_association(association_key.to_sym) || # add to_sym since rails 3 only support symbol
        fail(ActiveRecord::ConfigurationError, "ActiveRecord::ConfigurationError: Association named \
          '#{association_key}' was not found on #{@klass.name}; perhaps you misspelled it?"
      )
    end

    def with_conditions(reflect, relation)
      options = reflect.options
      relation = relation.instance_exec(&reflect.scope) if reflect.respond_to?(:scope) and reflect.scope
      relation = relation.where(options[:conditions]) if options[:conditions]
      return relation
    end

    def get_join_table(reflect)
      options = reflect.options
      return options[:through] if options[:through]
      return (options[:join_table] || reflect.send(:derive_join_table)) if reflect.macro == :has_and_belongs_to_many
      return nil
    end

    def get_primary_key(reflect)
      return (reflect.belongs_to? ? reflect.klass : reflect.active_record).primary_key
    end

    def get_foreign_key(reflect, reverse: false, with_table_name: false)
      reflect = reflect.chain.last
      if reverse and (table_name = get_join_table(reflect)) # reverse = parent
        key = reflect.chain.last.foreign_key
      else
        key = (reflect.belongs_to? == reverse ? get_primary_key(reflect) : reflect.foreign_key)
        table_name = (reverse ? reflect.klass : reflect.active_record).table_name
      end
      return "#{table_name}.#{key}" if with_table_name
      return key.to_s # key may be symbol if specify foreign_key in association options
    end

    def get_association_scope(reflect)
      RailsCompatibility.unscope_where(reflect.association_class.new({}, reflect).send(:association_scope))
    end

    def use_association_to_query?(reflect)
      reflect.through_reflection && reflect.chain.first.macro == :has_one
    end

    # ----------------------------------------------------------------
    # ● Contruction OPs
    # ----------------------------------------------------------------

    private

    def add_need_column(column)
      @need_columns << column
    end

    def add_association(hash)
      hash.each do |key, value|
        model = (@associations[key] ||= Model.new(get_reflect(key).klass.where(''), key, self))
        model.add(value)
      end
    end

    public

    def add(args)
      return self if args == nil
      args = [args] if not args.is_a?(Array)
      args.each do |arg|
        case arg
        when Hash ; add_association(arg)
        else      ; add_need_column(arg)
        end
      end
      return self
    end

    # ----------------------------------------------------------------
    # ● Load
    # ----------------------------------------------------------------
    private

    def do_query(parent, reflect, relation)
      parent_key = get_foreign_key(reflect)
      relation_key = get_foreign_key(reflect, reverse: true, with_table_name: true)
      ids = parent.map{|s| s[parent_key] }
      ids.uniq!
      ids.compact!
      relation = with_conditions(reflect, relation)
      query = { relation_key => ids }
      query[reflect.type] = reflect.active_record.to_s if reflect.type

      return get_association_scope(reflect).where(query) if use_association_to_query?(reflect)
      return relation.joins(get_join_table(reflect)).where(query)
    end

    def set_includes_data(parent, column_name, model)
      reflect = get_reflect(column_name)
      reverse = !reflect.belongs_to?
      foreign_key = get_foreign_key(reflect, reverse: reverse)
      primary_key = get_foreign_key(reflect, reverse: !reverse)
      children = model.load_data{|relation| do_query(parent, reflect, relation) }
      # reverse = false: Child.where(:id => parent.pluck(:child_id))
      # reverse = true : Child.where(:parent_id => parent.pluck(:id))
      return DataCombiner.combine_data(
        parent,
        children,
        primary_key,
        column_name,
        foreign_key,
        reverse,
        reflect.collection?,
      )
    end

    def get_query_columns
      if @parent_model
        parent_reflect = @parent_model.get_reflect(@parent_association_key)
        prev_need_columns = @parent_model.get_foreign_key(parent_reflect, reverse: true, with_table_name: true)
      end
      next_need_columns = @associations.map{|key, _| get_foreign_key(get_reflect(key), with_table_name: true) }.uniq
      return [*prev_need_columns, *next_need_columns, *@need_columns].uniq(&Helper::TO_KEY_PROC)
    end

    def pluck_values(columns)
      includes_values = @relation.includes_values
      @relation.includes_values = []

      result = @relation.pluck_all(*columns)

      @relation.includes_values = includes_values
      return result
    end

    def loaded_models
      return [@model] if @model
      return @relation if @relation.loaded
    end

    public

    def load_data
      columns = get_query_columns
      key_columns = columns.map(&Helper::TO_KEY_PROC)
      @relation = yield(@relation) if block_given?
      @data = loaded_models ? loaded_models.as_json(root: false, only: key_columns) : pluck_values(columns)
      if @data.size != 0
        # for delete_extra_column_data!
        @extra_columns = key_columns - @need_columns.map(&Helper::TO_KEY_PROC)
        @associations.each do |key, model|
          set_includes_data(@data, key, model)
        end
      end
      return @data
    end

    def load_all
      load_data
      delete_extra_column_data!
      return @data
    end

    def delete_extra_column_data!
      return if @data.blank?
      @data.each{|s| s.except!(*@extra_columns) }
      @associations.each{|_, model| model.delete_extra_column_data! }
    end

    # ----------------------------------------------------------------
    # ● Helper methods
    # ----------------------------------------------------------------
    module Helper
      TO_KEY_PROC = proc{|s| Helper.column_to_key(s) }
      def self.column_to_key(key) # user_achievements.user_id => user_id
        key = key[/(\w+)[^\w]*\z/]
        key.gsub!(/[^\w]+/, '')
        return key
      end
    end
  end
end
