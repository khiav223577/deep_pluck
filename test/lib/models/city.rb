# frozen_string_literal: true

class City < ActiveRecord::Base
  has_many :schools
end
