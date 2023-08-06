require 'test_helper'

class DeepPluckPrimaryKeyTest < Minitest::Test
  def setup
  end

  def test_species
    assert_equal [
      { 'name' => 'John', 'species' => [{ 'name' => 'Bat' }, { 'name' => 'bat' }, { 'name' => 'batmen' }]},
      { 'name' => 'Pearl', 'species' => [] },
      { 'name' => 'Doggy', 'species' => [{ 'name' => 'Rat' }, { 'name' => 'rat' }] },
    ], User.where(name: %w[John Pearl Doggy]).deep_pluck(:name, 'species' => :name)
  end
end
