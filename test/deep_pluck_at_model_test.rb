require 'test_helper'

class DeepPluckAtModelTest < Minitest::Test
  def setup
    Post.where(id: [-1]).ids if ActiveRecord::VERSION::MAJOR == 4 # trigger PRAGMA table_info('posts')
  end

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
