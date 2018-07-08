require 'test_helper'

class DeepPluckAtModelTest < Minitest::Test
  def test_1_level_deep
    expected = {'name' => 'Pearl'}
    assert_equal(expected, User.where(:name => %w(Pearl)).first.deep_pluck(:name))
  end

  def test_2_level_deep
    expected = {'name' => 'Pearl' , :posts => [{'name' => "post4"}, {'name' => "post5"}]}
    assert_equal(expected, User.where(:name => %w(Pearl)).first.deep_pluck(:name, :posts => [:name]))
  end

  def test_2_level_deep_with_id
    user = User.where(name: 'Pearl').first
    expected = {'id' => user.id, 'name' => 'Pearl', :posts => [{'name' => "post4"}, {'name' => "post5"}]}
    assert_equal(expected, user.deep_pluck(:id, :name, posts: :name))
  end
end
