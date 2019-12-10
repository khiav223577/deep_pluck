require 'test_helper'

class DeepPluckHasOneThroughTest < Minitest::Test
  def setup
  end

  def test_belongs_to_belongs_to # user belongs_to school, school belongs to city
    assert_equal [
      { 'name' => 'John', 'city' => { 'name' => 'Taipei' } },
      { 'name' => 'Pearl' },
    ], User.where(name: %w[John, Pearl]).deep_pluck(:name, 'city' => :name)
  end
end
