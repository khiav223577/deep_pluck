module DeepPluck
  class Model
  #---------------------------------------
  #  Initialize
  #---------------------------------------
    def initialize(relation, parent_association_key = nil, parent_model = nil)
      @relation = relation
      @parent_association_key = parent_association_key
      @parent_model = parent_model
      @need_columns = []
      @associations = {}
    end
  #---------------------------------------
  #  Reader
  #---------------------------------------
    def get_reflect(association_key)
      @relation.klass.reflect_on_association(association_key.to_sym) #add to_sym since rails 3 only support symbol
    end
    def get_foreign_key(reflect, reverse = false)
      if reflect.options[:through] and reverse #reverse = parent
        return "#{reflect.options[:through]}.user_id" #TODO
      end
      return (reflect.belongs_to? ? reflect.active_record.primary_key : reflect.foreign_key) if reverse
      return (reflect.belongs_to? ? reflect.foreign_key : reflect.active_record.primary_key)
    end
  #---------------------------------------
  #  Contruction OPs
  #---------------------------------------
  private
    def add_need_column(column)
      @need_columns << column.to_s
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
  #---------------------------------------
  #  Load
  #---------------------------------------
  private
    def do_query(parent, reflect, relation)
      relation = relation.joins(reflect.options[:through]) if reflect.options[:through]
      parent_key = get_foreign_key(reflect, false)
      relation_key = get_foreign_key(reflect, true)
      ids = parent.map{|s| s[parent_key]}
      ids.uniq!
      ids.compact!
      return relation.where(relation_key => ids)
    end
  private
    def set_includes_data(parent, children_store_name, model)
      reflect = get_reflect(children_store_name)
      if reflect.belongs_to? #Child.where(:id => parent.pluck(:child_id))
        children = model.load_data{|relation| do_query(parent, reflect, relation) }
        children_hash = Hash[children.map{|s| [s["id"], s]}]
        parent.each{|s|
          next if (id = s[reflect.foreign_key]) == nil
          s[children_store_name] = children_hash[id]
        }
      else       #Child.where(:parent_id => parent.pluck(:id))
        if reflect.options[:through]
          foreign_key = 'user_id' #TODO
        else
          foreign_key = reflect.foreign_key
        end
        parent.each{|s| s[children_store_name] = [] } if reflect.collection?
        parent_hash = Hash[parent.map{|s| [s["id"], s]}]
        children = model.load_data{|relation| do_query(parent, reflect, relation) }
        children.each{|s|
          next if (id = s[foreign_key]) == nil
          if reflect.collection?
            parent_hash[id][children_store_name] << s
          else
            parent_hash[id][children_store_name] = s
          end
        }
      end
      return children
    end
  public
    def load_data
      prev_need_columns = @parent_model.get_foreign_key(@parent_model.get_reflect(@parent_association_key), true) if @parent_model
      next_need_columns = @associations.map{|key, _| get_foreign_key(get_reflect(key)) }.uniq
      all_need_columns = [*prev_need_columns, *next_need_columns, *@need_columns].uniq
      @relation = yield(@relation) if block_given?
      @data = @relation.pluck_all(*all_need_columns)
      if @data.size != 0
        @extra_columns = all_need_columns - @need_columns #for delete_extra_column_data!
        @extra_columns.map!{|s| s.sub(/\w+\./, '')} #user_achievements.user_id => user_id
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
  end
end
