# frozen_string_literal: true
class Achievement < ActiveRecord::Base
  has_many :user_achievements
  has_many :users, :through => :user_achievements
  if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4.0.0')
    has_many :female_users, :conditions => {:gender => 'female'}, :through => :user_achievements, :foreign_key => "user_id", :source => :user
  else
    has_many :female_users, ->{ where(:gender => 'female')}, :through => :user_achievements, :foreign_key => "user_id", :source => :user
  end
  has_and_belongs_to_many :users2, class_name: 'User', :join_table => :user_achievements
end
