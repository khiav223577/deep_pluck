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
end
