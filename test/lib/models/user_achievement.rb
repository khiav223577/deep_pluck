# frozen_string_literal: true
class UserAchievement < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
end
