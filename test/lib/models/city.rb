# frozen_string_literal: true

class City < ActiveRecord::Base
  has_many :schools
  has_many :users, through: :schools
end
