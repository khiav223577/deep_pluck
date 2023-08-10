# frozen_string_literal: true

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
    assert_equal [], user_none.deep_pluck(:id, :name, posts: [:name])
  end

  def test_behavior_like_pluck_all_when_1_level_deep
    assert_equal User.pluck_all(:id, :name), User.deep_pluck(:id, :name)
  end

  def test_1_level_deep
    assert_equal [
      { 'name' => 'John' },
      { 'name' => 'Pearl' },
    ], User.where(name: %w[John Pearl]).deep_pluck(:name)
  end

  def test_2_level_deep
    assert_equal [
      { 'name' => 'Pearl', :posts => [{ 'name' => 'post4' }, { 'name' => 'post5' }] },
      { 'name' => 'Doggy', :posts => [{ 'name' => 'post6' }] },
    ], User.where(name: %w[Pearl Doggy]).deep_pluck(:name, posts: [:name])

    assert_equal [
      { 'name' => 'John', :contact => { 'address' => "John's Home" }},
      { 'name' => 'Pearl', :contact => { 'address' => "Pearl's Home" }},
      { 'name' => 'Catty', :contact => nil },
    ], User.where(name: %w[John Pearl Catty]).deep_pluck(:name, contact: :address)
  end

  def test_3_level_deep
    assert_equal [
      { 'name' => 'Pearl', :posts => [{ 'name' => 'post4', :post_comments => [{ 'comment' => 'cool!' }] }, { 'name' => 'post5', :post_comments => [] }] },
      { 'name' => 'Doggy', :posts => [{ 'name' => 'post6', :post_comments => [{ 'comment' => 'hahahahahahha' }] }] },
    ], User.where(name: %w[Pearl Doggy]).deep_pluck(:name, posts: [:name, post_comments: :comment])
  end

  def test_two_associations
    assert_equal [
      { 'name' => 'Pearl', :posts => [{ 'name' => 'post4' }, { 'name' => 'post5' }], :contact => { 'address' => "Pearl's Home" }},
      { 'name' => 'Doggy', :posts => [{ 'name' => 'post6' }], :contact => { 'address' => "Doggy's Home" }},
    ], User.where(name: %w[Pearl Doggy]).deep_pluck(:name, contact: :address, posts: :name)
  end

  def test_2_level_deep_and_reverse_association
    assert_equal [
      { 'name' => 'post4', :user => { 'name' => 'Pearl' }},
      { 'name' => 'post5', :user => { 'name' => 'Pearl' }},
      { 'name' => 'post6', :user => { 'name' => 'Doggy' }},
    ], Post.where(name: %w[post4 post5 post6]).deep_pluck(:name, user: [:name])
  end

  def test_many_to_many
    expected = [
      { 'name' => 'John', :achievements => [{ 'name' => 'achievement1' }] },
      { 'name' => 'Pearl', :achievements => [{ 'name' => 'achievement1' }, { 'name' => 'achievement3' }] },
      { 'name' => 'Doggy', :achievements => [] },
      { 'name' => 'Catty', :achievements => [] },
    ]
    assert_equal expected, User.deep_pluck(:name, achievements: :name)
    expected = [
      { 'name' => 'achievement1', :users => [{ 'name' => 'John' }, { 'name' => 'Pearl' }] },
      { 'name' => 'achievement2', :users => [] },
      { 'name' => 'achievement3', :users => [{ 'name' => 'Pearl' }] },
    ]
    assert_equal expected, Achievement.deep_pluck(:name, users: :name)
  end

  def test_has_and_belongs_to_many
    expected = [
      { 'name' => 'John', :achievements2 => [{ 'name' => 'achievement1' }] },
      { 'name' => 'Pearl', :achievements2 => [{ 'name' => 'achievement1' }, { 'name' => 'achievement3' }] },
      { 'name' => 'Doggy', :achievements2 => [] },
      { 'name' => 'Catty', :achievements2 => [] },
    ]
    assert_equal expected, User.deep_pluck(:name, achievements2: :name)
    expected = [
      { 'name' => 'achievement1', :users2 => [{ 'name' => 'John' }, { 'name' => 'Pearl' }] },
      { 'name' => 'achievement2', :users2 => [] },
      { 'name' => 'achievement3', :users2 => [{ 'name' => 'Pearl' }] },
    ]
    assert_equal expected, Achievement.deep_pluck(:name, users2: :name)
  end

  def test_with_join_and_2_level_deep
    expected = [
      { 'name' => 'Pearl', 'post_name' => 'post4', :achievements => [{ 'name' => 'achievement1' }, { 'name' => 'achievement3' }] },
      { 'name' => 'Pearl', 'post_name' => 'post5', :achievements => [{ 'name' => 'achievement1' }, { 'name' => 'achievement3' }] },
      { 'name' => 'Doggy', 'post_name' => 'post6', :achievements => [] }]
    assert_equal expected, User.where(name: %w[Pearl Doggy]).joins(:posts).deep_pluck(:'users.name', :'posts.name AS post_name', achievements: :name)
    expected = [
      { 'name' => 'post3', 'achievement' => 'achievement1', :user => { 'email' => 'john@example.com' }},
      { 'name' => 'post4', 'achievement' => 'achievement1', :user => { 'email' => 'pearl@example.com' }},
      { 'name' => 'post5', 'achievement' => 'achievement1', :user => { 'email' => 'pearl@example.com' }},
      { 'name' => 'post4', 'achievement' => 'achievement3', :user => { 'email' => 'pearl@example.com' }},
      { 'name' => 'post5', 'achievement' => 'achievement3', :user => { 'email' => 'pearl@example.com' }},
    ]
    assert_equal expected, Post.where(name: %w[post3 post4 post5 post6]).joins(user: :achievements).deep_pluck(:'posts.name', :'achievements.name AS achievement', user: :email)
  end

  def test_as_json_equality
    expected = User.where(name: %w[Pearl Doggy]).includes([{ posts: :post_comments }, :contact]).as_json(
      root: false,
      only: [:name, :email],
      include: {
        'posts'   => {
          only: :name,
          include: {
            'post_comments' => {
              only: :comment,
            },
          },
        },
        'contact' => {
          only: :address,
        },
      },
    )
    assert_equal expected, User.where(name: %w[Pearl Doggy]).deep_pluck(
      :name,
      :email,
      'posts'   => [:name, 'post_comments' => :comment],
      'contact' => :address,
    )
  end

  def test_wrong_association_name
    assert_raises ActiveRecord::ConfigurationError do
      User.deep_pluck(:name, postss: :name)
    end
    assert_raises ActiveRecord::ConfigurationError do
      User.deep_pluck(:name, posts: { post_comments2: :comment })
    end
  end

  def test_should_not_except_need_columns
    users = User.limit(1).includes(:posts)
    expected = users.as_json(
      root: false,
      only: :id,
      include: {
        'posts' => {
          only: :name,
        },
      },
    )
    assert_equal expected, users.deep_pluck(:id, 'posts' => :name)
  end

  def test_custom_foreign_key
    expected = [
      { 'name' => 'Pearl', :contact2 => { 'address' => "Pearl's Home2" }},
      { 'name' => 'Doggy', :contact2 => { 'address' => "Doggy's Home2" }},
      { 'name' => 'Catty', :contact2 => nil },
    ]
    assert_equal expected, User.where(name: %w[Pearl Doggy Catty]).deep_pluck(:name, contact2: :address)
    expected = [
      { 'address' => "John's Home2", :user => { 'name' => 'John' } },
      { 'address' => "Pearl's Home2", :user => { 'name' => 'Pearl' } },
      { 'address' => "Doggy's Home2", :user => { 'name' => 'Doggy' },  },
      { 'address' => "no one's Home2", :user => nil },
    ]
    assert_equal expected, Contact2.deep_pluck(:address, user: :name)
  end

  def test_custom_primary_key
    expected = [
      { 'address' => "John's Home2", :contact2_info => { 'info' => 'info1' } },
      { 'address' => "Pearl's Home2", :contact2_info => { 'info' => 'info2' } },
      { 'address' => "Doggy's Home2", :contact2_info => { 'info' => 'info3' } },
      { 'address' => "no one's Home2", :contact2_info => nil },
    ]
    assert_equal expected, Contact2.deep_pluck(:address, contact2_info: :info)
    expected = [
      { 'info' => 'info1', :contact2 => { user: { 'name' => 'John' }}},
      { 'info' => 'info2', :contact2 => { user: { 'name' => 'Pearl' }}},
      { 'info' => 'info3', :contact2 => { user: { 'name' => 'Doggy' }}},
    ]
    assert_equal expected, Contact2Info.deep_pluck(:info, contact2: { user: :name })
  end

  def test_conditional_relations
    assert_equal [
      { 'name' => 'John', :posts_1_3 => [{ 'title' => "John's post1" }, { 'title' => "John's post3" }] },
      { 'name' => 'Pearl', :posts_1_3 => [{ 'title' => "Pearl's post1" }] },
      { 'name' => 'Doggy', :posts_1_3 => [{ 'title' => "Doggy's post1" }] },
      { 'name' => 'Catty', :posts_1_3 => [] },
    ], User.deep_pluck(:name, posts_1_3: [:title])
  end

  def test_conditional_through_relations
    expected = [
      { 'name' => 'achievement1', :female_users => [{ 'name' => 'Pearl' }] },
      { 'name' => 'achievement2', :female_users => [] },
      { 'name' => 'achievement3', :female_users => [{ 'name' => 'Pearl' }] },
    ]
    assert_equal expected, Achievement.deep_pluck(:name, female_users: :name)
  end

  def test_polymorphic_relations
    user_expected = [{ notes: [{ 'content' => 'user note' }] }]
    contact_expected = [{ note: { 'content' => 'contact note' }}]
    post_expected = [{ notes: [{ 'content' => 'post note' }] }]

    assert_equal user_expected, User.where(id: 1).deep_pluck(notes: [:content])
    assert_equal contact_expected, Contact.where(id: 1).deep_pluck(note: [:content])
    assert_equal post_expected, Post.where(id: 1).deep_pluck(notes: [:content])
  end
end
