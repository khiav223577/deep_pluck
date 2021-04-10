# frozen_string_literal: true

class TrainingProvider < ActiveRecord::Base
  has_and_belongs_to_many :borrower_training_programs,
    class_name: 'TrainingProgram',
    inverse_of: :training_provider,
    join_table: :training_programs_training_providers
end
