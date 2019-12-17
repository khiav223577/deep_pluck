# frozen_string_literal: true

require 'active_record'
module DeepPluck
  class Utils
    class << self
      if ActiveRecord::VERSION::MAJOR < 4
        def unscope_where(relation)
          relation.tap{|s| s.where_values = [] }
        end
      else
        def unscope_where(relation)
          relation.unscope(:where)
        end
      end
    end
  end
end

