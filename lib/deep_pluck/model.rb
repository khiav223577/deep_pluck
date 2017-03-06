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
    def reflect_on_association(association_key)
      @relation.klass.reflect_on_association(association_key)
    end
    def get_foreign_key(association_key, reverse = false)
      reflect = reflect_on_association(association_key)
      return (reflect.belongs_to? ? @relation.klass.primary_key : reflect.foreign_key) if reverse
      return (reflect.belongs_to? ? reflect.foreign_key : @relation.klass.primary_key)
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
        model = (@associations[key] ||= Model.new(reflect_on_association(key).klass.where(''), key, self))
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
    def set_includes_data(parent, children_store_name, model, order_by = nil)
      reflect = reflect_on_association(children_store_name)
      if reflect.belongs_to? #Child.where(:id => parent.pluck(:child_id))
        children = model.load_data{|relaction| relaction.where(:id => parent.map{|s| s[reflect.foreign_key]}.uniq.compact).order(order_by) }
        children_hash = Hash[children.map{|s| [s["id"], s]}]
        parent.each{|s|
          next if (id = s[reflect.foreign_key]) == nil
          s[children_store_name] = children_hash[id]
        }
      else       #Child.where(:parent_id => parent.pluck(:id))
        parent.each{|s| s[children_store_name] = [] } if reflect.collection?
        parent_hash = Hash[parent.map{|s| [s["id"], s]}]
        children = model.load_data{|relaction| relaction.where(reflect.foreign_key => parent.map{|s| s["id"]}.uniq.compact).order(order_by) }
        children.each{|s|
          next if (id = s[reflect.foreign_key]) == nil
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
      prev_need_columns = @parent_model.get_foreign_key(@parent_association_key, true) if @parent_model
      next_need_columns = @associations.map{|key, _| get_foreign_key(key) }.uniq
      all_need_columns = [*prev_need_columns, *next_need_columns, *@need_columns].uniq
      @extra_columns = all_need_columns - @need_columns
      @relation = yield(@relation) if block_given?
      @data = @relation.pluck_all(*all_need_columns)
      @associations.each do |key, model|
        set_includes_data(@data, key, model)
      end
      return @data
    end
    def load_all
      load_data
      delete_extra_column_data!
      return @data
    end
    def delete_extra_column_data!
      @data.each{|s| s.except!(*@extra_columns) } if @data
      @associations.each{|_, model| model.delete_extra_column_data! }
    end
  end
end
