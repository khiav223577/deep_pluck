require 'deep_pluck/version'
require 'deep_pluck/model'
require 'active_record'
require 'pluck_all'

class ActiveRecord::Relation
  def deep_pluck(*args)
    DeepPluck::Model.new(self).add(args).load_all
  end
end

class ActiveRecord::Base
  def self.deep_pluck(*args)
    where('').deep_pluck(*args)
  end

  def deep_pluck(*args)
    hash_args, other_args = args.partition{|s| s.is_a?(Hash) }
    model = DeepPluck::Model.new(self.class.where(id: id), need_columns: other_args)
    model.add(*hash_args) if hash_args.any?
    return model.load_all.first
  end
end
