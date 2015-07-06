# [![Gem Version](https://badge.fury.io/rb/banditmask.svg)](http://badge.fury.io/rb/banditmask) [![Build Status](https://travis-ci.org/jparker/banditmask.svg?branch=master)](https://travis-ci.org/jparker/banditmask)

# BanditMask

BanditMask provides a generic wrapper for working with bitmasks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'banditmask'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banditmask

## Usage

Create a class which inherits from `BanditMask`, and declare the available bit
names and their corresponding values.

```ruby
class ChmodMask < BanditMask
  bit :read,    0b001
  bit :write,   0b010
  bit :execute, 0b100
end

ChmodMask.bits # => { :read => 1, :write => 2, :execute => 4 }
```

Instantiate a new mask class:

```ruby
mask = ChmodMask.new
# or
current_bitmask = 0b001 | 0b010
mask = ChmodMask.new current_bitmask
```

Enable bits by name.

```ruby
mask << :read << :write
```

Ask whether specific bits are enabled.

```ruby
mask.include? :read           # => true
mask.include? :write          # => true
mask.include? :execute        # => false
mask.include? :read, :write   # => true
mask.include? :read, :execute # => true
```

Retrieve a list of all currently enabled bits.

```ruby
mask.bits # => [:read, :write]
```

In an class with a bitmask attribute, extend `BanditMask::Banditry` and call
`BanditMask::Banditry.bandit_mask` to add accessor methods for working with the
bitmask attribute.

```ruby
class ObjectWithBitmaskAttribute
  attr_accessor :bitmask

  extend BanditMask::Banditry
  bandit_mask :bitmask, as: :bits, with: ChmodMask
end

obj = ObjectWithBitmaskAttribute.new
obj.bitmask = 0b011
```

This gives you a reader method which delegates to `BanditMask#bits`.

```ruby
obj.bits # => [:read, :write]
```

It also gives you a writer method which lets you overwrite the bitmask.

```ruby
obj.bits = [:read, :execute]
obj.bitmask # => 5
```

Finally, it gives you a query method for checking whether particular bits are
set on the bitmask.

```ruby
obj.has? :read           # => true
obj.has? :write          # => false
obj.has? :execute        # => true
obj.has? :read, :write   # => false
obj.has? :read, :execute # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release` to create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/banditmask/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
