# frozen_string_literal: true

class County < ActiveRecord::Base
  has_and_belongs_to_many :zipcodes
end
