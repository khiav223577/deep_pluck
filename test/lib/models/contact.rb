# frozen_string_literal: true

class Contact < ActiveRecord::Base
  belongs_to :user
  has_one :note, as: :parent
end
