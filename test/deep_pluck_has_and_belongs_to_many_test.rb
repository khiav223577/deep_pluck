require 'test_helper'

class DeepPluckHasAndBelongsToManyTest < Minitest::Test
  def setup
  end

  def test_simple_case
    assert_equal [
      { zipcodes: [{ 'city' => 'Atlanta' }, { 'city'=>'Union City' }] },
      { zipcodes: [{ 'city' => 'Minneapolis' }, { 'city'=>'Edina' }] },
    ], County.deep_pluck(zipcodes: :city)
  end

  def test_custom_association_name
    skip if ActiveRecord::VERSION::MAJOR < 4 # Rails 3 doesn't support inverse_of options in HABTM

    assert_equal TrainingProvider.deep_pluck(:name, borrower_training_programs: :name), [
      'name' => 'provider X',
      borrower_training_programs: [
        'name' => 'program A',
      ],
    ]
  end

  def test_custom_inverse_association_name
    skip if ActiveRecord::VERSION::MAJOR < 4 # Rails 3 doesn't support inverse_of options in HABTM

    assert_equal TrainingProgram.deep_pluck(:name, training_providers: :name), [
      'name' => 'program A',
      training_providers: [
        'name' => 'provider X',
      ],
    ]
  end
end
