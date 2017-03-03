require 'test_helper'

class DeepPluckTest < Minitest::Test
  def setup
    
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::DeepPluck::VERSION
  end
  
  def test_basic_pluck
    assert_equal [
      {'name' => 'John'},
    ], User.where(:name => 'John').deep_pluck(:name)
  end

end
