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
  create_table :post_comments, :force => true do |t|
    t.integer :post_id
    t.string :comment
  end
  create_table :contacts, :force => true do |t|
    t.integer :user_id
    t.string :address
    t.string :phone_number
  end
  create_table :user_achievements, :force => true do |t|
    t.references :user, index: true
    t.references :achievement, index: true
  end
  create_table :achievements, :force => true do |t|
    t.string :name
  end
end
class User < ActiveRecord::Base
  serialize :serialized_attribute, Hash
  has_many :posts
  has_one :contact
  has_many :user_achievements
  has_many :achievements, :through => :user_achievements
  has_and_belongs_to_many :achievements2, class_name: 'Achievement', :join_table => :user_achievements
end
class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_comments
end
class PostComment < ActiveRecord::Base
  belongs_to :post
end
class Contact < ActiveRecord::Base
  belongs_to :user
end
class UserAchievement < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
end

class Achievement < ActiveRecord::Base
  has_many :user_achievements
  has_many :users, :through => :user_achievements
  has_and_belongs_to_many :users2, class_name: 'User', :join_table => :user_achievements
end

users = User.create([
  {:name => 'John', :email => 'john@example.com'},
  {:name => 'Pearl', :email => 'pearl@example.com', :serialized_attribute => {:testing => true, :deep => {:deep => :deep}}},
  {:name => 'Kathenrie', :email => 'kathenrie@example.com'},
])
User.where(:name => 'John').update_all(:profile_pic => 'JohnProfile.jpg') # skip carrierwave
User.where(:name => 'Kathenrie').update_all(:profile_pic => 'Profile.jpg', :pet_pic => 'Pet.png') # skip carrierwave
posts = Post.create([
  {:name => 'post1', :title => "John's post1", :user_id => users[0].id},
  {:name => 'post2', :title => "John's post2", :user_id => users[0].id},
  {:name => 'post3', :title => "John's post3", :user_id => users[0].id},
  {:name => 'post4', :title => "Pearl's post1", :user_id => users[1].id},
  {:name => 'post5', :title => "Pearl's post2", :user_id => users[1].id},
  {:name => 'post6', :title => "Kathenrie's post1", :user_id => users[2].id},
])
PostComment.create([
  {:post_id => posts[2].id, :comment => "WTF?"},
  {:post_id => posts[2].id, :comment => "..."},
  {:post_id => posts[3].id, :comment => "cool!"},
  {:post_id => posts[5].id, :comment => "hahahahahahha"},
])
Contact.create([
  {:address => "John's Home", :phone_number => "0911666888", :user_id => users[0].id},
  {:address => "Pearl's Home", :phone_number => "1011-0404-934", :user_id => users[1].id},
  {:address => "Kathenrie's Home", :phone_number => "02-254421", :user_id => users[2].id},
])
achievements = Achievement.create([
  {:name => 'achievement1'},
  {:name => 'achievement2'},
  {:name => 'achievement3'},
])
UserAchievement.create([
  {:user_id => users[0].id, :achievement_id => achievements[0].id},
  {:user_id => users[1].id, :achievement_id => achievements[0].id},
  {:user_id => users[1].id, :achievement_id => achievements[2].id},
])
