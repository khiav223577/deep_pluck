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
  	attr_reader :need_columns
  	attr_reader :relation
		def reflect_on_association(association_key)
  		@relation.klass.reflect_on_association(association_key)
  	end
  	def get_foreign_key(association_key, reverse = false)
  		reflect = reflect_on_association(association_key)
  		return (reflect.belongs_to? ? 'id' : reflect.foreign_key) if reverse
  		return (reflect.belongs_to? ? reflect.foreign_key : 'id')
  	end
	#---------------------------------------
	#  Contruction OPs
	#---------------------------------------
	private
  	def add_need_column(column)
  		@need_columns << column
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
			selections = model.need_columns
	    reflect = reflect_on_association(children_store_name)
	    if reflect.belongs_to? #Child.where(:id => parent.pluck(:child_id))
	      children = model.load_data{|relaction| relaction.where(:id => parent.map{|s| s[reflect.foreign_key]}.uniq.compact).order(order_by) }
	      children_hash = Hash[children.map{|s| [s["id"], s]}]
	      parent.each{|s|
	        next if (id = s[reflect.foreign_key]) == nil
	        s[children_store_name] = children_hash[id]
	      }
	      return children
	    else       #Child.where(:parent_id => parent.pluck(:id))
	      parent.each{|s| s[children_store_name] = [] }
	      parent_hash = Hash[parent.map{|s| [s["id"], s]}]
	      children = model.load_data{|relaction| relaction.where(reflect.foreign_key => parent.map{|s| s["id"]}.uniq.compact).order(order_by) }
	      children.each{|s|
	        next if (id = s[reflect.foreign_key]) == nil
	        # s.delete(reflect.foreign_key) if s.size != selections.size
	        parent_hash[id][children_store_name] << s
	      }
	      return children
	    end
	  end
  public
  	def load_data
  		prev_need_columns = @parent_model.get_foreign_key(@parent_association_key, true) if @parent_model
  		next_need_columns = @associations.map{|key, _| get_foreign_key(key) }.uniq
			@relation = yield(@relation) if block_given?
  		return @relation.pluck_all(*prev_need_columns, *next_need_columns, *@need_columns)
  	end
  	def load_all
  		data = load_data
	    @associations.each do |key, model|
	      set_includes_data(data, key, model)
	    end
	    return data
  	end
  end
end
