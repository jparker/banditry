require 'banditmask/version'
require 'banditmask/banditry'

class BanditMask
  attr_reader :bitmask

  def initialize(bitmask = 0b0) # :nodoc:
    @bitmask = bitmask
  end

  ##
  # Returns a Hash mapping all defined names to their respective bits.
  #
  #   class MyMask < BanditMask
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
  #   class MyMask < BanditMask
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
  #   class BanditMask
  #     bit :read, 0b01
  #     bit :write, 0b10
  #   end
  #
  #   mask = BanditMask.new 0b01
  #   mask.bits # => [:read]
  def bits
    self.class.bits.select { |bit, _| include? bit }.keys
  end
  alias_method :to_a, :bits

  ##
  # Enables the bit named +bit+. Returns +self+, so calls to #<< can be
  # chained. (Think Array#<<.) Raises +ArgumentError+ if +bit+ does not
  # correspond to a bit that was previously declared with BanditMask.bit.
  #
  #   class BanditMask
  #     bit :read, 0b01
  #     bit :write, 0b10
  #   end
  #
  #   mask = BanditMask.new
  #   mask << :read << :write
  def <<(bit)
    @bitmask |= bit_value(bit)
    self
  end

  ##
  # Returns true if +bit+ is among the currently enabled bits. Returns false
  # otherwise. Raises +ArgumentError+ if +bit+ does not correspond to a bit
  # that was previously declared with BanditMask.bit.
  #
  #   class BanditMask
  #     bit :read, 0b01
  #     bit :write, 0b10
  #   end
  #
  #   mask = BanditMask.new 0b01
  #   mask.include? :read  # => true
  #   mask.include? :write # => false
  def include?(bit)
    bitmask & bit_value(bit) != 0
  end

  private

  def bit_value(bit)
    self.class.bits.fetch(bit) do
      raise ArgumentError, "undefined bit: #{bit.inspect}"
    end
  end
end
