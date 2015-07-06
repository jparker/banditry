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

Create a class which inherits from BanditMask and declare the available bit
names and their corresponding values.

```ruby
class ChmodMask < BanditMask
  bit :read,    0b001
  bit :write,   0b010
  bit :execute, 0b100
end

ChmodMask.bits # => { :read => 1, :write => 2, :execute => 4 }
```

To instantiate a new mask class:

```ruby
mask = ChmodMask.new
```

Enable bits by name.

```ruby
mask << :read << :write
```

Ask whether specific bits are enabled.

```ruby
mask.include? :read    # => true
mask.include? :write   # => true
mask.include? :execute # => false
```

Retrieve a list of all currently enabled bits.

```ruby
mask.names # => [:read, :write]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/banditmask/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
