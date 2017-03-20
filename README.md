# DeepPluck

[![Gem Version](https://img.shields.io/gem/v/deep_pluck.svg?style=flat)](http://rubygems.org/gems/deep_pluck)
[![Build Status](https://travis-ci.org/khiav223577/deep_pluck.svg?branch=master)](https://travis-ci.org/khiav223577/deep_pluck)
[![RubyGems](http://img.shields.io/gem/dt/deep_pluck.svg?style=flat)](http://rubygems.org/gems/deep_pluck)
[![Code Climate](https://codeclimate.com/github/khiav223577/deep_pluck/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/deep_pluck)
[![Test Coverage](https://codeclimate.com/github/khiav223577/deep_pluck/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/deep_pluck/coverage)

Allow you to pluck deeply into nested associations without loading a bunch of records.

And DRY up your code when using #as_json.


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
# => [{'id' => 1, 'name' => 'David'}, {'id' => 2, 'name' => 'Jeremy'}]
```

### Pluck deep into associations
```rb
User.deep_pluck(:name, :posts => :title)
# SELECT `users`.`id`, `users`.`name` FROM `users`
# SELECT `posts`.`user_id`, `posts`.`title` FROM `posts` WHERE `posts`.`user_id` IN (1, 2)
# => [
#  {'name' => 'David' , :posts => [{'title' => 'post1'}, {'title' => 'post2'}]}, 
#  {'name' => 'Jeremy', :posts => [{'title' => 'post3'}]}
# ]
```

### DRY up Rails/ActiveRecord includes when using as_json

Assume the following relations:

> User has_many Posts.<br>
> Post has_many PostComments.<br>
> User has_one Contact.<br>

And the following #as_json example:
```rb
User.where(:name => %w(Pearl Kathenrie)).includes([{:posts => :post_comments}, :contact]).as_json({
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
You could refactor it with #deep_pluck like:
```rb
User.where(:name => %w(Pearl Kathenrie)).deep_pluck(
  :name, 
  :email, 
  'posts' => [:name, 'post_comments' => :comment], 
  'contact' => :address,
)
```

### Better Performance

#deep_pluck return raw hash data without loading a bunch of records.

In that faster than #as_json, or #select.

Will add some benchmarks soon :)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/deep_pluck. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

