module DeepPluck
  module DataCombiner
    class << self
      def combine_data(parent, children, primary_key, column_name, foreign_key, reverse, collection)
        source =  reverse ? parent : children
        target = !reverse ? parent : children
        data_hash = make_data_hash(collection, source, primary_key, column_name)
        assign_values_to_parent(collection, target, data_hash, column_name, foreign_key, reverse: reverse)
        return children
      end

      private

      def make_data_hash(collection, parent, primary_key, column_name)
        return parent.map{|s| [s[primary_key], s] }.to_h if !collection
        hash = {}
        parent.each do |model_hash|
          key = model_hash[primary_key]
          array = (hash[key] ? hash[key][column_name] : []) # share the children if id is duplicated
          model_hash[column_name] = array
          hash[key] = model_hash
        end
        return hash
      end

      def assign_values_to_parent(collection, parent, children_hash, column_name, foreign_key, reverse: false)
        parent.each do |s|
          next if (id = s[foreign_key]) == nil
          left = reverse ? children_hash[id] : s
          right = !reverse ? children_hash[id] : s
          if collection
            left[column_name] << right
          else
            left[column_name] = right
          end
        end
      end
    end
  end
end
