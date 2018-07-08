module DeepPluck
  class PreloadedModel
    attr_reader :need_columns

    def initialize(active_model, need_columns)
      @active_model = active_model
      @need_columns = need_columns
    end

    def get_hash_data(extra_columns)
      @active_model.as_json(root: false, only: @need_columns + extra_columns)
    end
  end
end
