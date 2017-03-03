ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.string :profile_pic
    t.string :pet_pic
    t.text :serialized_attribute
  end
  create_table :posts, :force => true do |t|
    t.integer :user_id
    t.string :name
    t.string :title
  end
end
class User < ActiveRecord::Base
  serialize :serialized_attribute, Hash
  has_many :posts
end
class Post < ActiveRecord::Base
  belongs_to :user
end
users = User.create([
  {:name => 'John', :email => 'john@example.com'},
  {:name => 'Pearl', :email => 'pearl@example.com', :serialized_attribute => {:testing => true, :deep => {:deep => :deep}}},
  {:name => 'Kathenrie', :email => 'kathenrie@example.com'},
])
User.where(:name => 'John').update_all(:profile_pic => 'JohnProfile.jpg') # skip carrierwave
User.where(:name => 'Kathenrie').update_all(:profile_pic => 'Profile.jpg', :pet_pic => 'Pet.png') # skip carrierwave
Post.create([
  {:name => 'post1', :title => "John's post1", :user_id => users[0].id},
  {:name => 'post2', :title => "John's post2", :user_id => users[0].id},
  {:name => 'post3', :title => "John's post3", :user_id => users[0].id},
  {:name => 'post4', :title => "Pearl's post1", :user_id => users[1].id},
  {:name => 'post5', :title => "Pearl's post2", :user_id => users[1].id},
  {:name => 'post6', :title => "Kathenrie's post1", :user_id => users[2].id},
])
