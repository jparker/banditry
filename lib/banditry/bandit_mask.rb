module Banditry
  class BanditMask
    attr_reader :bitmask

    def initialize(bitmask = nil) # :nodoc:
      @bitmask = bitmask || 0b0
    end

    ##
    # Returns a Hash mapping all defined names to their respective bits.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b01
    #     bit :write, 0b10
    #   end
    #
    #   MyMask.bits # => { :read => 1, :write => 2 }
    def self.bits
      @bits ||= {}
    end

    ##
    # Maps +name+ to +value+ in the global list of defined bits.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b001
    #     bit :write, 0b010
    #     bit :execute, 0b100
    #   end
    def self.bit(name, value)
      bits.update name => value
    end

    ##
    # Returns integer value of current bitmask.
    def to_i
      bitmask
    end

    ##
    # Returns an array of names of the currently enabled bits.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b01
    #     bit :write, 0b10
    #   end
    #
    #   mask = MyMask.new 0b01
    #   mask.bits # => [:read]
    def bits
      self.class.bits.select { |bit, _| include? bit }.keys
    end
    alias_method :to_a, :bits

    ##
    # Enables the bit named +bit+. Returns +self+, so calls to #<< can be
    # chained. (Think Array#<<.) Raises +ArgumentError+ if +bit+ does not
    # correspond to a bit that was previously defined with
    # Banditry::BanditMask.bit.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b01
    #     bit :write, 0b10
    #   end
    #
    #   mask = MyMask.new       # => #<MyMask:0x007f9ebd44ae40 @bitmask=0>
    #   mask << :read << :write # => #<MyMask:0x007f9ebd44ae40 @bitmask=3>
    def <<(bit)
      @bitmask |= bit_value(bit)
      self
    end

    ##
    # Returns a new instance with the current bitmask plus +bit+. Raises
    # +ArgumentError+ if +bit+ does not correspond to a bit that was previously
    # defined by Banditry::BanditMask.bit.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b01
    #     bit :write, 0b10
    #   end
    #
    #   mask = MyMask.new 0b01
    #   mask | :write # => #<MyMask:0x007f9e0bcf5d90 @bitmask=3>
    def |(bit)
      self.class.new bitmask | bit_value(bit)
    end

    ##
    # Returns +true+ if +other+ is an instance of the same class as +self+ and
    # they have the same bitmask.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b01
    #     bit :write, 0b10
    #   end
    #
    #   class MyOtherMask < Banditry::BanditMask
    #     bit :chocolate, 0b01
    #     bit :vanilla, 0b10
    #   end
    #
    #   a = MyMask.new 0b1
    #   b = MyMask.new 0b1
    #   c = MyMask.new 0b0
    #   d = MyOtherMask.new 0b1
    #
    #   a == b # => true
    #   a == c # => false
    #   a == d # => false
    def ==(other)
      other.class == self.class && other.bitmask == bitmask
    end

    alias_method :eql?, :==

    ##
    # Returns an object hash. Two Banditry::BanditMask objects have identical
    # hashes if they have identical bitmasks and are instances of the same
    # class.
    def hash
      [bitmask, self.class].hash
    end

    ##
    # Returns true if every bit in +bits+ is enabled and false otherwise.
    # Raises +ArgumentError+ if +bits+ is empty or if any element in +bits+
    # does not correspond to a bit that was previously defined with
    # Banditry::BanditMask.bit.
    #
    #   class MyMask < Banditry::BanditMask
    #     bit :read, 0b001
    #     bit :write, 0b010
    #     bit :execute, 0b100
    #   end
    #
    #   mask = MyMask.new 0b101
    #
    #   mask.include? :read           # => true
    #   mask.include? :write          # => false
    #   mask.include? :execute        # => true
    #
    #   mask.include? :read, :write   # => false
    #   mask.include? :read, :execute # => true
    def include?(*bits)
      raise ArgumentError, 'wrong number of arguments (0 for 1+)' if bits.empty?
      bits.all? { |bit| bitmask & bit_value(bit) != 0 }
    end

    private

    ##
    # Returns the integer value for the bit named +bit+. Raises +ArgumentError+
    # if +bit+ has not been previously defined with Banditry::BanditMask.bit.
    def bit_value(bit)
      self.class.bits.fetch(bit) do
        raise ArgumentError, "undefined bit: #{bit.inspect}"
      end
    end
  end
end
