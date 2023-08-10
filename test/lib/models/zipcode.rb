# frozen_string_literal: true

class Zipcode < ActiveRecord::Base
  has_and_belongs_to_many :counties
end
