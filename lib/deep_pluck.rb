require "deep_pluck/version"
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
    self.where('').deep_pluck(*args)
  end

  def deep_pluck(*args)
    hash_args = args.select{|s| s.is_a?(Hash) }
    other_args = args.select{|s| !s.is_a?(Hash) }
    model = DeepPluck::Model.new(self.class.where(id: id), preloaded_model: self)
    return model.add(*hash_args).load_all
  end
end
