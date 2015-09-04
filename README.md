# Uidable

Create the uid(unqiue identifier) attribute in your model or class.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uidable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uidable

## Usage

### ActiveRecord

1. Create a migration to add the uid column in your table.
2. Include uidable in your model.
3. Setup uidable with/without options in your model.
4. Uid is generated and ready to use when a record is created. Note that the uid is still nil when the record is initialized but haven't be saved.

A migration example:

    class AddUidToMyModels < ActiveRecord::Migration
      def change
        add_column :my_models, :uid, :string, null: false
        add_index :my_models, :uid, unique: true
      end
    end

A model example:

    class MyModel
      include Uidable
      uidable
    end

    a = MyClass.new
    a.uid # nil
    a.save
    a.uid "cmerft8rotdy7wvmtxc63ljoxos67bc8"

### Ruby Class

1. Include uidable in your class.
2. Setup uidable with/without options in your class.
3. Uid is generated and ready to use when an instance is initialized.

A class example:

    class MyClass
      include Uidable
      uidable uid_size: 64, read_only: false
    end

    a = MyClass.new
    a.uid # "zcf45ltmkyh4w2ofsc1rp8dka6wi4flt3h3szwo1z4rkfsvk387mclg1cikutbc7"

Please reference tests for more usage examples.

## Options

### Uid Name

The default uid attribute is named with "uid", you can change it with `uid_name: <name>`. Note that you need change the column name in your migration as well.

### Uid Size

The default uid is a 32-bit length string with numbers and alphabets. You can change the uid size with `uid_size: <size>`. If you want to generate the uid with your own way, please see [Redefine uid generation].

### Read Only

The uid is read only by default. You can disabled it with `read_only: false`.

## Options for ActiveRecord

### Uniqueness and Presence Validation

The uniqueness and presence validation is enabled by default. You can disable them with `uniqueness: false` and `presence: false`. Note that you should change your migration as well if needed.

### Set to_param

If the option `set_to_param: true` is given, the `to_param` is overrided with uid and it means you can use uid in your routes path.

### Scope

If the option `scope: true` is given, a scope `with_uid` is created and you can use it to find records with uid. Note that if you change the uid name with the option `uid_name: <name>`, the scope is also changed to `with_<name>`.

## Redefine Uid Generation

You override `gen_uid` method in your class/model if you want to generate your own uid. Here is an example:

    require `random_token`

    class MyModel < ActiveRecord::Base
      include Uidable
      uidable

      private

      def gen_uid
        RandomToken.gen(64, s: 8)
      end
    end

## Test

Run `ruby test/test_all.rb`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/sibevin/uidable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

Sibevin Wang

## Copyright

Copyright (c) 2015 Sibevin Wang. Released under the MIT license.
