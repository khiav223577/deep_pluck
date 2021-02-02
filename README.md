# DeepPluck

[![Gem Version](https://img.shields.io/gem/v/deep_pluck.svg?style=flat)](http://rubygems.org/gems/deep_pluck)
[![Build Status](https://github.com/khiav223577/deep_pluck/workflows/build/badge.svg)](https://github.com/khiav223577/deep_pluck/actions)
[![RubyGems](http://img.shields.io/gem/dt/deep_pluck.svg?style=flat)](http://rubygems.org/gems/deep_pluck)
[![Code Climate](https://codeclimate.com/github/khiav223577/deep_pluck/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/deep_pluck)
[![Test Coverage](https://codeclimate.com/github/khiav223577/deep_pluck/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/deep_pluck/coverage)

Allow you to pluck deeply into nested associations without loading a bunch of records.

## Supports
- Ruby 2.2 ~ 2.7
- Rails 3.2, 4.2, 5.0, 5.1, 5.2, 6.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deep_pluck'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deep_pluck

## Usage

### Similar to #pluck method

```rb
User.deep_pluck(:id, :name)
# SELECT `users`.`id`, `users`.`name` FROM `users`
# =>
# [
#   {'id' => 1, 'name' => 'David'},
#   {'id' => 2, 'name' => 'Jeremy'},
# ]
```

### Pluck attributes from nested associations

```rb
User.deep_pluck(:name, 'posts' => :title)
# SELECT `users`.`id`, `users`.`name` FROM `users`
# SELECT `posts`.`user_id`, `posts`.`title` FROM `posts` WHERE `posts`.`user_id` IN (1, 2)
# =>
# [
#  {
#    'name' => 'David' ,
#    'posts' => [
#      {'title' => 'post1'},
#      {'title' => 'post2'},
#    ],
#  },
#  {
#    'name' => 'Jeremy',
#    'posts' => [
#      {'title' => 'post3'},
#    ],
#  },
# ]
```

### Pluck at models

```rb
user = User.find_by(name: 'David')
user.deep_pluck(:name, :posts => :title)
# =>
# {
#   'name' => 'David' ,
#   :posts => [
#     {'title' => 'post1'},
#     {'title' => 'post2'},
#   ],
# }
```

### Compare with using `#as_json`

Assume the following relations:

> User has_many Posts.<br>
> Post has_many PostComments.<br>
> User has_one Contact.<br>

And the following #as_json example:
```rb
User.where(:name => %w(Pearl Doggy)).includes([{:posts => :post_comments}, :contact]).as_json({
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

```
It works as expected, but is not very DRY, repeat writing `include`, `posts`, `post_comments` so many times.

Not to mention the huge performace improvement by using #deep_pluck.

You could refactor the example with #deep_pluck:
```rb
User.where(:name => %w(Pearl Doggy)).deep_pluck(
  :name,
  :email,
  'posts' => [:name, 'post_comments' => :comment],
  'contact' => :address,
)
```

### Better Performance

#deep_pluck return raw hash data without loading a bunch of records, so that faster than #as_json, or #select.

The following is the benchmark test on 3 users, 6 posts, where `users` table have 14 columns and `posts` have 6 columns. As it shows, `deep_pluck` is 4x faster than `as_json`.


```rb
# Repeat 500 times
# User.includes(:posts).as_json(:only => :email, :include => {:posts => {:only => :title}})
# User.deep_pluck(:email, {'posts' => :title})

                       user     system      total        real
as_json            1.740000   1.230000   2.970000 (  3.231465)
deep_pluck         0.660000   0.030000   0.690000 (  0.880018)
```

The following is the benchmark test on 10000 users, where `users` table have 46 columns. As it shows, `deep_pluck` is 40x faster than `as_json` and 4x faster than `map`.
```rb
# Repeat 1 times
# User.select('account, email').map{|s| {'account' => s.account, 'email' => s.email}}
# User.select('account, email').as_json(:only => [:account, :email])
# User.deep_pluck(:account, :email)

                       user     system      total        real
map                0.210000   0.000000   0.210000 (  0.225421)
as_json            1.980000   0.060000   2.040000 (  2.042205)
deep_pluck         0.040000   0.000000   0.040000 (  0.051673)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/deep_pluck. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

