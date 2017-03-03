require "deep_pluck/version"
require 'active_record'
require 'pluck_all'

class ActiveRecord::Relation
  def deep_pluck(*args)
    next_level_hash = {}
    current_level_columns = [:id]
    args.each do |arg|
      case arg
      when Hash ; next_level_hash.deep_merge!(arg)
      else      ; current_level_columns << arg
      end
    end
    data = pluck_all(*current_level_columns)
    should_delete_id = (data.first.size == current_level_columns.size)
    next_level_hash.each do |key, select_columns|
      deep_pluck_includes_data(data, key, select_columns)
    end
    data.each{|s| s.delete('id')} if should_delete_id
    return data
  end
private
  def deep_pluck_includes_data(parent, children_store_name, selections, order_by = nil)
    reflect = klass.reflect_on_association(children_store_name)
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
      should_delete_id = (children.first.size != selections.size)
      children.each{|s|
        next if (id = s[reflect.foreign_key]) == nil
        s.delete(reflect.foreign_key) if should_delete_id
        parent_hash[id][children_store_name] << s
      }
      return children
    end
  end
end

class ActiveRecord::Base
  def self.deep_pluck(*args)
    self.where('').deep_pluck(*args)
  end
end
