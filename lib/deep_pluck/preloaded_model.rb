module DeepPluck
  class PreloadedModel
    def initialize(active_model, need_columns)
      @active_model = active_model
      @need_columns = need_columns
    end

    def get_hash_data(extra_columns)
      @active_model.as_json(only: @need_columns + extra_columns)
    end
  end
end
