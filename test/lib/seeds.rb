ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :gender
    t.integer :school_id
    t.text :serialized_attribute
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.string :name
    t.string :title
  end

  create_table :post_comments, force: true do |t|
    t.integer :post_id
    t.string :comment
  end

  create_table :contacts, force: true do |t|
    t.integer :user_id
    t.string :address
    t.string :phone_number
  end

  create_table :contact2s, id: false, force: true do |t|
    t.primary_key :id2
    t.integer :user_id2
    t.string :address
    t.string :phone_number
  end

  create_table :contact2_infos, id: false, force: true do |t|
    t.primary_key :id2
    t.string :info
    t.integer :contact_id2
  end

  create_table :user_achievements, force: true do |t|
    t.references :user, index: true
    t.references :achievement, index: true
  end

  create_table :achievements, force: true do |t|
    t.string :name
  end

  create_table :notes, force: true do |t|
    t.integer :parent_id
    t.string :parent_type
    t.string :content
  end

  create_table :schools, force: true do |t|
    t.string :name
    t.integer :city_id
  end

  create_table :cities, force: true do |t|
    t.string :name
  end

  create_table :counties, force: true do |t|
    t.string :name, null: false
  end

  create_table :counties_zipcodes, force: true do |t|
    t.references :county, index: true, null: false
    t.references :zipcode, index: true, null: false
  end

  create_table :zipcodes, force: true do |t|
    t.string :zip, null: false
    t.string :city, null: false
  end

  create_table :training_programs, force: :cascade do |t|
    t.string :name
  end

  create_table :training_providers, force: :cascade do |t|
    t.string :name
  end

  create_table :training_programs_training_providers, id: false, force: :cascade do |t|
    t.references :training_provider, null: false, index: false
    t.references :training_program, null: false, index: false
  end
end

$optional_true = ActiveRecord::VERSION::MAJOR < 5 ? {} : { optional: true }
require 'rails_compatibility/setup_autoload_paths'
RailsCompatibility.setup_autoload_paths [File.expand_path('../models/', __FILE__)]

cities = City.create([
  { name: 'Taipei' },
])

schools = School.create([
  { name: 'high school 01', city: cities[0] },
])

users = User.create([
  { name: 'John', email: 'john@example.com', gender: 'male', school: schools[0] },
  { name: 'Pearl', email: 'pearl@example.com', gender: 'female', serialized_attribute: { testing: true, deep: { deep: :deep }}},
  { name: 'Doggy', email: 'kathenrie@example.com', gender: 'female' },
  { name: 'Catty', email: 'catherine@example.com', gender: 'female' },
])

posts = Post.create([
  { name: 'post1', title: "John's post1", user_id: users[0].id },
  { name: 'post2', title: "John's post2", user_id: users[0].id },
  { name: 'post3', title: "John's post3", user_id: users[0].id },
  { name: 'post4', title: "Pearl's post1", user_id: users[1].id },
  { name: 'post5', title: "Pearl's post2", user_id: users[1].id },
  { name: 'post6', title: "Doggy's post1", user_id: users[2].id },
])

PostComment.create([
  { post_id: posts[2].id, comment: 'WTF?' },
  { post_id: posts[2].id, comment: '...' },
  { post_id: posts[3].id, comment: 'cool!' },
  { post_id: posts[5].id, comment: 'hahahahahahha' },
])

contacts = Contact.create([
  { address: "John's Home", phone_number: '0911666888', user_id: users[0].id },
  { address: "Pearl's Home", phone_number: '1011-0404-934', user_id: users[1].id },
  { address: "Doggy's Home", phone_number: '02-254421', user_id: users[2].id },
])

contact2 = Contact2.create([
  { address: "John's Home2", phone_number: '0911666888', user_id2: users[0].id },
  { address: "Pearl's Home2", phone_number: '1011-0404-934', user_id2: users[1].id },
  { address: "Doggy's Home2", phone_number: '02-254421', user_id2: users[2].id },
])

Contact2Info.create([
  { info: 'info1', contact_id2: contact2[0].id },
  { info: 'info2', contact_id2: contact2[1].id },
  { info: 'info3', contact_id2: contact2[2].id },
])

achievements = Achievement.create([
  { name: 'achievement1' },
  { name: 'achievement2' },
  { name: 'achievement3' },
])

UserAchievement.create([
  { user_id: users[0].id, achievement_id: achievements[0].id },
  { user_id: users[1].id, achievement_id: achievements[0].id },
  { user_id: users[1].id, achievement_id: achievements[2].id },
])

Note.create([
  { parent: users[0], content: 'user note' },
  { parent: contacts[0], content: 'contact note' },
  { parent: posts[0], content: 'post note' },
])

County.create([
  {
    name: 'Fulton',
    zipcodes: [
      Zipcode.new(city: 'Atlanta', zip: '30301'),
      Zipcode.new(city: 'Union City', zip: '30291'),
    ],
  },
  {
    name: 'Hennepin',
    zipcodes: [
      Zipcode.new(city: 'Minneapolis', zip: '55410'),
      Zipcode.new(city: 'Edina', zip: '55416'),
    ],
  },
])

if ActiveRecord::VERSION::MAJOR > 3 # Rails 3 doesn't support inverse_of options in HABTM
  TrainingProgram.create!(
    name: 'program A',
    training_providers: [
      TrainingProvider.create!(name: 'provider X'),
    ],
  )
end

# TODO: wait for globalize to support Rails 7.
SUPPORT_GLOBALIZE = (ActiveRecord::VERSION::MAJOR > 3 && ActiveRecord::VERSION::MAJOR < 7)

if SUPPORT_GLOBALIZE
  require 'globalize'

  ActiveRecord::Schema.define do
    create_table :questionnaires, force: true do |t|
      t.references :user
    end

    Questionnaire.create_translation_table! title: :string
  end

  I18n.available_locales = [:en, :'zh-TW']

  users[0].questionnaires.create!.tap do |questionnaire|
    I18n.with_locale(:en){ questionnaire.update(title: 'What is your favorite food?') }
    I18n.with_locale(:'zh-TW'){ questionnaire.update(title: '你最愛的食物為何？') }
  end

  users[0].questionnaires.create!.tap do |questionnaire|
    I18n.with_locale(:en){ questionnaire.update(title: 'Why did you purchase this product?') }
  end
end
