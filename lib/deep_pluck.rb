require "deep_pluck/version"
require 'active_record'
require 'pluck_all'

class ActiveRecord::Relation
  def deep_pluck(*args)
    next_level_hash = {}
    current_level_columns = []
    args.each do |arg|
      case arg
      when Hash ; next_level_hash.deep_merge!(arg)
      else      ; current_level_columns << arg
      end
    end
    return pluck_all(*current_level_columns)
  end
end

class ActiveRecord::Base
  def self.deep_pluck(*args)
    self.where('').deep_pluck(*args)
  end
end
