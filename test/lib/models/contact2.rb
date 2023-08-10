# frozen_string_literal: true

class Contact2 < ActiveRecord::Base
  self.primary_key = :id2
  belongs_to :user, foreign_key: :user_id2
  has_one :contact2_info, foreign_key: :contact_id2
end
