# frozen_string_literal: true

class PostComment < ActiveRecord::Base
  belongs_to :post
end
