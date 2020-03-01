require 'test_helper'

class DeepPluckHasOneThroughTest < Minitest::Test
  def setup
  end

  def test_belongs_to_through_belongs_to # user belongs_to school, school belongs to city
    assert_equal [
      { 'name' => 'John', 'city' => { 'name' => 'Taipei' }},
      { 'name' => 'Pearl' },
    ], User.where(name: %w[John Pearl]).deep_pluck(:name, 'city' => :name)
  end

  def test_has_many_through_has_many # city has_many schools, school has_many users
    assert_equal [
      { 'name' => 'Taipei', 'users' => [{ 'name' => 'John' }] },
    ], City.where(name: 'Taipei').deep_pluck(:name, 'users' => :name)
  end
end
