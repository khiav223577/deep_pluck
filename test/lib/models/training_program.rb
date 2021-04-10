# frozen_string_literal: true

class TrainingProgram < ActiveRecord::Base
  has_and_belongs_to_many :training_providers,
    inverse_of: :borrower_training_programs,
    join_table: :training_programs_training_providers
end
