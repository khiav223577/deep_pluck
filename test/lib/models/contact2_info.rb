# frozen_string_literal: true
class Contact2Info < ActiveRecord::Base
  self.primary_key = :id2
  belongs_to :contact2, :foreign_key => :id2
end
