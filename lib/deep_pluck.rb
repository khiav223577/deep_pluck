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
      deep_pluck_includes_data(data, :user_id, key, select_columns)
    end
    data.each{|s| s.delete('id')} if should_delete_id
    return data
  end
private
  def deep_pluck_includes_data(parent, associate_column_name, children_store_name, selections, reverse = false, order_by = nil)
    child_class = klass.reflect_on_association(children_store_name).klass
    associate_column_name = associate_column_name.to_s
    if reverse #Child.where(:id => parent.pluck(:child_id))
      children = child_class.where(:id => parent.map{|s| s[associate_column_name]}.uniq.compact).order(order_by).pluck_all(*selections)
      children_hash = Hash[children.map{|s| [s["id"], s]}]
      parent.each{|s|
        next if (id = s[associate_column_name]) == nil
        s[children_store_name] = children_hash[id]
      }
      return children
    else       #Child.where(:parent_id => parent.pluck(:id))
      parent.each{|s| s[children_store_name] = [] }
      parent_hash = Hash[parent.map{|s| [s["id"], s]}]
      children = child_class.where(associate_column_name => parent.map{|s| s["id"]}.uniq.compact).order(order_by).pluck_all(associate_column_name, *selections)
      should_delete_id = (children.first.size != selections.size)
      children.each{|s|
        next if (id = s[associate_column_name]) == nil
        s.delete(associate_column_name) if should_delete_id
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
