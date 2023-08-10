# frozen_string_literal: true

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_comments
  has_many :notes, as: :parent
end
