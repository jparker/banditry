require "banditmask/version"

class BanditMask
  attr_reader :mask

  def initialize(mask = 0b0) # :nodoc:
    @mask = mask
  end

  ##
  # Returns a Hash mapping all defined names to their respective bits.
  #
  #   class BanditMask
  #     bit :read, 0b01
  #     bit :write, 0b10
  #   end
  #
  #   BanditMask.bits # => { :read => 1, :write => 2 }
  def self.bits
    @bits ||= {}
  end

  ##
  # Maps +name+ to +value+ in the global list of defined bits.
  #
  #   class BanditMask
  #     bit :read, 0b001
  #     bit :write, 0b010
  #     bit :execute, 0b100
  #   end
  def self.bit(name, value)
    bits.update name => value
  end

  ##
  # Clears all defined bits.
  def self.reset_bits!
    @bits = {}
  end

  ##
  # Returns integer value of current bitmask.
  def to_i
    mask
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
  #   mask.names # => [:read]
  def names
    self.class.bits.select { |name, _| include? name }.keys
  end
  alias_method :to_a, :names

  ##
  # Enables the bit named +name+. Returns +self+, so calles to #<< can be
  # chained (think Array#<<). Raises +ArgumentError+ if +name+ does not
  # correspond to a bit that was previously declared with BanditMask.bit.
  #
  #   class BanditMask
  #     bit :read, 0b01
  #     bit :write, 0b10
  #   end
  #
  #   mask = BanditMask.new
  #   mask << :read << :write
  def <<(name)
    @mask |= name_to_bit(name)
    self
  end

  ##
  # Returns true if +name+ is among the currently enabled bits. Returns false
  # otherwise. Raises +ArgumentError+ if +name+ does not correspond to a bit
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
  def include?(name)
    @mask & name_to_bit(name) != 0
  end

  private

  def name_to_bit(name)
    self.class.bits.fetch(name) do
      raise ArgumentError, "undefined bit: #{name.inspect}"
    end
  end
end
