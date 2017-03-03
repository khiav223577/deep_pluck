require 'test_helper'

class DeepPluckTest < Minitest::Test
  def setup
    
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::DeepPluck::VERSION
  end
  
  def test_pluck_with_1_level_deep
    assert_equal [
      {'name' => 'John'},
      {'name' => 'Pearl'},
    ], User.where(:name => %w(John Pearl)).deep_pluck(:name)
  end

  def test_pluck_with_2_level_deep
    assert_equal [
      {'name' => 'Pearl'    , :posts => [{'name' => "post4"}, {'name' => "post5"}]},
      {'name' => 'Kathenrie', :posts => [{'name' => "post6"}]},
    ], User.where(:name => %w(Pearl Kathenrie)).includes(:posts).deep_pluck(:name, :posts => [:name])
  end
end
