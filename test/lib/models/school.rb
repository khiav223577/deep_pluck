# frozen_string_literal: true

class School < ActiveRecord::Base
  has_many :users
end
