# StoreConfigurable

A zero-configuration recursive Hash for storing a tree of options in a serialized ActiveRecord column. Includes self aware hooks that delegate dirty/changed state to your configs owner. Read my article [*A Lesson In Recursion In Ruby*](http://metaskills.net/2012/03/12/store-configurable-a-lesson-in-recursion-in-ruby/) if you are interested in how this library works.

<img src="http://cdn.actionmoniker.com/share/recursive_kitty_small.jpg" alt="Recursive Github Kitty" width="260" height="160" style="float:right; margin:-20px 35px 15px 15px; background-color:#fff; padding:13px; -moz-box-shadow: 5px 5px 5px rgba(0,0,0,0.5); -webkit-box-shadow: 5px 5px 5px rgba(0,0,0,0.5); box-shadow: 5px 5px 5px rgba(0,0,0,0.5); -moz-transform: rotate(-2deg); -webkit-transform: rotate(-2deg); transform: rotate(-2deg);">

[![Build Status](https://secure.travis-ci.org/metaskills/store_configurable.png)](http://travis-ci.org/metaskills/store_configurable)

## Installation

Install the gem with bundler. We follow a semantic versioning format that tracks ActiveRecord's minor version. So this means to use the latest 3.2.x version of StoreConfigurable with any ActiveRecord 3.2 version.

```ruby
gem 'store_configurable', '~> 4.0.0'
```

Our `4.0.x` version works for ActiveRecord 4.0.x or 4.1.x.


## Setup

To use StoreConfigurable, you must create a `_config` column in the model's table. Make sure that you declare this column as a text type, so there's plenty of room.

```ruby
class AddStoreConfigurableField < ActiveRecord::Migration
  def up
    add_column :users, :_config, :text
  end
  def down
    remove_column :users, :_config
  end
end
```

Next declare that your model uses StoreConfigurable with the `store_configurable` method.

```ruby
class User < ActiveRecord::Base
  store_configurable
end
```


## Usage

Our `config` method is your gateway to StoreConfigurable and unlike ActiveRecord's new Store object in 3.2, there is no configuration needed to start using it for any property. It will dynamically expand for every property or namespace. This allows you or other plugins' configurations to be grouped in logical nodes. All examples below assume that StoreConfigurable is being used on a User instance as shown in the setup above.

```ruby
@user.config.remember_me = true
@user.config.sortable_tables.column    = 'created_at'
@user.config.sortable_tables.direction = 'asc'
@user.config.you.should.never.need.to.do.this.but.you.could.if.you.wanted.to = 'deep_value'
@user.save
```

#### Dirty Hooks

StoreConfigurable is smart enought to let your parent object know when it changes. It is not dumb either. It will only trigger changes if the values you set are different, are new, or change the configs state. Some examples assuming the saved record's data above.

```ruby
@user = User.find(42)
@user.config_changed? # => false

@user.config.remember_me = true   # Same value
@user.config_changed?             # => false

@user.config.sortable_tables.column    = 'updated_at'
@user.config.sortable_tables.direction = 'desc'
@user.config_changed? # => true
```

#### Hash Syntax

The StoreConfigurable data objects supports most `Hash` methods with the exception of a few that rely on making a copy of the data, like `dup`. This means you can delete whole branches of data or itterate over your data collection. Again, StoreConfigurable reports all changes to the owner object via ActiveRecord's dirty support.

```ruby
@user.config.sortable_tables.delete   # Deletes this node/namespace.
@user.config.clear                    # Hash method to purge.
@user.config_changed?                 # => true
```

#### Choose Your Style

You can choose to get or set config values via any method or hash key syntax you choose. It really does not matter! This means you can mix and match dot property notation, hash string or symbol syntax and it will just work.

```ruby
@user.config.color = '#c1c1c1'
@user.config['remember_me'] = true
@user.config[:sortable_tables].direction = 'asc'
@user.config.sortable_tables['column'] = 'updated_at'

@user.config['color']                       # => '#c1c1c1'
@user.config[:color]                        # => '#c1c1c1'
@user.config.remember_me                    # => true
@user.config.sortable_tables[:direction]    # => 'asc'
@user.config[:sortable_tables][:column]     # => 'updated_at'
```


## Stored Data

StoreConfigurable persists your configuration data in YAML format to the `_config` text column. We use Ruby's `YAML::Omap` type on the backend so we can decouple our datastore from our proxy object manager. This means you can easily load this data via other means if you want to.

```yaml
--- !omap
- :remember_me: true
- :sortable_tables: !omap
  - :column: created_at
  - :direction: asc
- :you: !omap
  - :should: !omap
    - :never: !omap
      - :need: !omap
        - :to: !omap
          - :do: !omap
            - :this: deep_value
```

## Todo

* Incorporate an option to compress serialized data. Gzip, [MessagePack](http://msgpack.org/), Etc...


## Other Solutions

* [StoreField](https://github.com/kenn/store_field) - Similar approach but no dirty tracking and still requires manual key configs.


## Contributing

StoreConfigurable is fully tested with ActiveRecord 3.2 to 4.0 and upward. If you detect a problem, open up a github issue or fork the repo and help out. After you fork or clone the repository, the following commands will get you up and running on the test suite.

```shell
$ bundle install
$ bundle exec appraisal update
$ bundle exec appraisal rake test
```

We use the [appraisal](https://github.com/thoughtbot/appraisal) gem from Thoughtbot to help us generate the individual gemfiles for each ActiveSupport version and to run the tests locally against each generated Gemfile. The `rake appraisal test` command actually runs our test suite against all ActiveRecord versions in our `Appraisal` file. If you want to run the tests for a specific ActiveRecord version, use `rake -T` for a list. For example, the following command will run the tests for Rails 3.2 only.

```shell
$ bundle exec appraisal activerecord40 rake test
```


## License

* Released under the MIT license thanks to Decisiv, Inc.
* Copyright (c) 2014 Ken Collins

