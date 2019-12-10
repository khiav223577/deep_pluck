# frozen_string_literal: true

class School < ActiveRecord::Base
  belongs_to :city

  has_many :users
end
