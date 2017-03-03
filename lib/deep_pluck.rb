require "deep_pluck/version"
require 'active_record'
require 'pluck_all'

class ActiveRecord::Relation
	def deep_pluck(*args)
		pluck_all(*args)
	end
end

class ActiveRecord::Base
  def self.deep_pluck(*args)
    self.where('').deep_pluck(*args)
  end
end
