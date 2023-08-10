# frozen_string_literal: true

require 'test_helper'

class DeepPluckAtModelTest < Minitest::Test
  def test_1_level_deep
    user = User.where(name: 'Pearl').first
    expected = { 'name' => 'Pearl' }

    assert_queries(0) do
      assert_equal(expected, user.deep_pluck(:name))
    end
  end

  def test_2_level_deep
    user = User.where(name: 'Pearl').first
    expected = { 'name' => 'Pearl', :posts => [{ 'name' => 'post4' }, { 'name' => 'post5' }] }

    assert_queries(1) do
      assert_equal(expected, user.deep_pluck(:name, posts: [:name]))
    end
  end

  def test_2_level_deep_with_id
    user = User.where(name: 'Pearl').first
    expected = { 'id' => user.id, 'name' => 'Pearl', :posts => [{ 'name' => 'post4' }, { 'name' => 'post5' }] }

    assert_queries(1) do
      assert_equal(expected, user.deep_pluck(:id, :name, posts: :name))
    end
  end
end
