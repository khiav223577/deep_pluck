module DeepPluck
  class Model
  	attr_reader :need_columns
  	def initialize(relation = nil, args = nil)
  		@relation = relation
  		@need_columns = []
  		@associations = {}
  		add(args)
  	end
  	def add(args)
  		return if args == nil
  		args = [args] if not args.is_a?(Array)
  		args.each do |arg|
	      case arg
	      when Hash ; add_association(arg)
	      else      ; add_need_column(arg)
	      end
	    end
  	end
  	def load_all
  		data = @relation.pluck_all(*@need_columns)
	    @associations.each do |key, association|
	      set_includes_data(data, key, association.need_columns)
	    end
	    return data
  	end
	private
  	def add_need_column(column)
  		@need_columns << column
  	end
  	def add_association(hash)
  		hash.each do |key, value|
  			model = (@associations[key] ||= Model.new)
				model.add(value)
  		end
  	end
	#---------------------------------------
	#  includes
	#---------------------------------------
		def set_includes_data(parent, children_store_name, selections, order_by = nil)
	    reflect = @relation.klass.reflect_on_association(children_store_name)
	    if reflect.belongs_to? #Child.where(:id => parent.pluck(:child_id))
	      children = reflect.klass.where(:id => parent.map{|s| s[reflect.foreign_key]}.uniq.compact).order(order_by).pluck_all(*selections)
	      children_hash = Hash[children.map{|s| [s["id"], s]}]
	      parent.each{|s|
	        next if (id = s[reflect.foreign_key]) == nil
	        s[children_store_name] = children_hash[id]
	      }
	      return children
	    else       #Child.where(:parent_id => parent.pluck(:id))
	      parent.each{|s| s[children_store_name] = [] }
	      parent_hash = Hash[parent.map{|s| [s["id"], s]}]
	      children = reflect.klass.where(reflect.foreign_key => parent.map{|s| s["id"]}.uniq.compact).order(order_by).pluck_all(reflect.foreign_key, *selections)
	      children.each{|s|
	        next if (id = s[reflect.foreign_key]) == nil
	        # s.delete(reflect.foreign_key) if s.size != selections.size
	        parent_hash[id][children_store_name] << s
	      }
	      return children
	    end
	  end
  end
end
