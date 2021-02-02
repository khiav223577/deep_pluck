require 'test_helper'

class DeepPluckHasAndBelongsToManyTest < Minitest::Test
  def setup
  end

  def test_has_and_belongs_to_many
    assert_equal [
      { zipcodes: [{ 'city' => 'Atlanta' }]},
    ], County.deep_pluck(zipcodes: :city)
  end
end
