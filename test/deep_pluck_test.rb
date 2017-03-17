require 'test_helper'

class DeepPluckTest < Minitest::Test
  def setup
    
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::DeepPluck::VERSION
  end
  
  def test_with_none
    user_none = (ActiveRecord::Base.respond_to?(:none) ? User.none : User.where('1=0'))
    assert_equal [], user_none.deep_pluck(:id, :name)
    assert_equal [], user_none.deep_pluck(:id, :name, :posts => [:name])
  end

  def test_behavior_like_pluck_all_when_1_level_deep
    assert_equal User.pluck_all(:id, :name), User.deep_pluck(:id, :name)
  end

  def test_1_level_deep
    assert_equal [
      {'name' => 'John'},
      {'name' => 'Pearl'},
    ], User.where(:name => %w(John Pearl)).deep_pluck(:name)
  end

  def test_2_level_deep
    assert_equal [
      {'name' => 'Pearl'    , :posts => [{'name' => "post4"}, {'name' => "post5"}]},
      {'name' => 'Kathenrie', :posts => [{'name' => "post6"}]},
    ], User.where(:name => %w(Pearl Kathenrie)).deep_pluck(:name, :posts => [:name])
    assert_equal [
      {'name' => 'John' , :contact => {'address' => "John's Home"}},
      {'name' => 'Pearl', :contact => {'address' => "Pearl's Home"}},
    ], User.where(:name => %w(John Pearl)).deep_pluck(:name, :contact => :address)
  end

  def test_3_level_deep
    assert_equal [
      {'name' => 'Pearl'    , :posts => [{'name' => "post4", :post_comments => [{'comment' => 'cool!'}]}, {'name' => "post5", :post_comments => []}]},
      {'name' => 'Kathenrie', :posts => [{'name' => "post6", :post_comments => [{'comment' => 'hahahahahahha'}]}]},
    ], User.where(:name => %w(Pearl Kathenrie)).deep_pluck(:name, :posts => [:name, :post_comments => :comment])
  end

  def test_two_associations
    assert_equal [
      {'name' => 'Pearl'    , :posts => [{'name' => "post4"}, {'name' => "post5"}], :contact => {'address' => "Pearl's Home"}},
      {'name' => 'Kathenrie', :posts => [{'name' => "post6"}], :contact => {'address' => "Kathenrie's Home"}},
    ], User.where(:name => %w(Pearl Kathenrie)).deep_pluck(:name, :contact => :address, :posts => :name)
  end

  def test_2_level_deep_and_reverse_association
    assert_equal [
      {'name' => 'post4', :user => {'name' => "Pearl"}},
      {'name' => 'post5', :user => {'name' => "Pearl"}},
      {'name' => 'post6', :user => {'name' => "Kathenrie"}},
    ], Post.where(:name => %w(post4 post5 post6)).deep_pluck(:name, :user => [:name])
  end

  def test_many_to_many
    expected = [
      {"name" => "John"     , :achievements => [{"name" => "achievement1"}]}, 
      {"name" => "Pearl"    , :achievements => [{"name" => "achievement1"}, {"name" => "achievement3"}]}, 
      {"name" => "Kathenrie", :achievements => []},
    ]
    assert_equal expected, User.deep_pluck(:name, :achievements => :name)
    expected = [
      {"name" => "achievement1", :users => [{"name" => "John"}, {"name" => "Pearl"}]}, 
      {"name" => "achievement2", :users => []},
      {"name" => "achievement3", :users => [{"name" => "Pearl"}]},
    ]
    assert_equal expected, Achievement.deep_pluck(:name, :users => :name)
  end

  def test_with_join_and_2_level_deep
    expected = [
      {"name" => "Pearl"    , "post_name" => "post4", :achievements => [{"name" => "achievement1"}, {"name" => "achievement3"}]}, 
      {"name" => "Pearl"    , "post_name" => "post5", :achievements => [{"name" => "achievement1"}, {"name" => "achievement3"}]}, 
      {"name" => "Kathenrie", "post_name" => "post6", :achievements => []}]
    assert_equal expected, User.where(:name => %w(Pearl Kathenrie)).joins(:posts).deep_pluck(:'users.name', :'posts.name AS post_name', :achievements => :name)
    expected = [
      {"name" => "post3", "achievement" => "achievement1", :user => {"email" => "john@example.com"}},
      {"name" => "post4", "achievement" => "achievement1", :user => {"email" => "pearl@example.com"}},
      {"name" => "post5", "achievement" => "achievement1", :user => {"email" => "pearl@example.com"}},
      {"name" => "post4", "achievement" => "achievement3", :user => {"email" => "pearl@example.com"}},
      {"name" => "post5", "achievement" => "achievement3", :user => {"email" => "pearl@example.com"}},
    ]
    assert_equal expected, Post.where(:name => %w(post3 post4 post5 post6)).joins(:user => :achievements).deep_pluck(:'posts.name', :'achievements.name AS achievement', :user => :email)
  end

  def test_as_json_equality
    expected = User.where(:name => %w(Pearl Kathenrie)).includes([{:posts => :post_comments}, :contact]).as_json({
      :root => false,
      :only => [:name, :email], 
      :include => {
        'posts' => {
          :only => :name, 
          :include => {
            'post_comments' => {
              :only => :comment,
            },
          },
        },
        'contact' => {
          :only => :address,
        },
      },
    })
    assert_equal expected, User.where(:name => %w(Pearl Kathenrie)).deep_pluck(
      :name, 
      :email, 
      'posts' => [:name, 'post_comments' => :comment], 
      'contact' => :address,
    )
  end

  def test_wrong_association_name
    assert_raises ActiveRecord::ConfigurationError do 
      User.deep_pluck(:name, :postss => :name)
    end
    assert_raises ActiveRecord::ConfigurationError do 
      User.deep_pluck(:name, :posts => {:post_comments2 => :comment})
    end
  end
end
