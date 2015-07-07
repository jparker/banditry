# [![Gem Version](https://badge.fury.io/rb/banditry.svg)](http://badge.fury.io/rb/banditry) [![Build Status](https://travis-ci.org/jparker/banditry.svg?branch=master)](https://travis-ci.org/jparker/banditry)

# Banditry

Banditry provides a generic wrapper for working with bitmasks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'banditry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banditry

## Usage

### Banditry::BanditMask

Create a class which inherits from Banditry::BanditMask, and declare the
available bit names and their corresponding values.

```ruby
class ChmodMask < Banditry::BanditMask
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
mask << :read << :execute
```

Ask whether specific bits are enabled.

```ruby
mask.include? :read           # => true
mask.include? :write          # => false
mask.include? :execute        # => true
mask.include? :read, :write   # => false
mask.include? :read, :execute # => true
```

Retrieve a list of all currently enabled bits.

```ruby
mask.bits # => [:read, :execute]
```

### Banditry

In a class with a bitmask attribute, extend Banditry and call
Banditry.bandit_mask to add accessor methods for working with the bitmask
attribute.

```ruby
class ObjectWithBitmaskAttribute
  attr_accessor :bitmask

  extend Banditry
  bandit_mask :bitmask, as: :bits, with: ChmodMask
end

obj = ObjectWithBitmaskAttribute.new
obj.bitmask = 0b001
```

This gives you a reader method which returns the Banditry::BanditMask
representation of the bitmask attribute.

```ruby
obj.bits # => #<ChmodMask:0x007f941b9518c8 @bitmask=1>
```

It also gives you a writer method which lets you modify the bitmask. The
writer accepts Banditry::BanditMask objects or an Array of bits.

```ruby
obj.bits |= :write
obj.bitmask # => 3
obj.bits = [:read, :execute]
obj.bitmask # => 5
```

Finally, it gives you a query method for checking whether particular bits are
set on the bitmask.

```ruby
obj.bits? :read           # => true
obj.bits? :write          # => false
obj.bits? :execute        # => true
obj.bits? :read, :write   # => false
obj.bits? :read, :execute # => true
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

1. Fork it ( https://github.com/jparker/banditry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
