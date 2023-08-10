# frozen_string_literal: true

class User < ActiveRecord::Base
  serialize :serialized_attribute, Hash

  has_many :posts

  if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4.0.0')
    has_many :posts_1_3, conditions: ['title LIKE ? OR title LIKE ? ', '%post1', '%post3'], class_name: 'Post'
  else
    has_many :posts_1_3, ->{ where('title LIKE ? OR title LIKE ? ', '%post1', '%post3') }, class_name: 'Post'
  end

  has_one :contact
  has_one :contact2, foreign_key: :user_id2
  has_many :notes, as: :parent
  has_many :user_achievements
  has_many :achievements, through: :user_achievements
  has_and_belongs_to_many :achievements2, class_name: 'Achievement', join_table: :user_achievements

  belongs_to :school, **$optional_true
  has_one :city, through: :school

  has_many :questionnaires

  has_many :species, foreign_key: :taxid, primary_key: :species_taxid

  if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('4.0.0')
    has_one :primary_species, conditions: ['"primary" = ?', true], foreign_key: :taxid, primary_key: :species_taxid, class_name: 'Species'
  else
    has_one :primary_species, ->{ where(primary: true) }, foreign_key: :taxid, primary_key: :species_taxid, class_name: 'Species'
  end
end
