class BanditMask
  module Banditry
    ##
    # Creates wrapper methods for reading, writing, and querying the bitmask
    # stored in +attribute+ using the class +with+. +with+ defaults to
    # BanditMask, but you can (and probably should) define your own class
    # descending from +BanditMask+ to fill this role. The name of the accessor
    # methods will be derived from +as+, e.g., if +as+ is +:foo+, the reader
    # method will be +:foo+ and the writer method will be +:foo=+, and the
    # query method will be +:foo?+.
    #
    # The reader method will call BanditMask#bits to get an array of the
    # enabled bit names represented by +attribute+.
    #
    # The writer method will overwrite the current bitmask with an Integer
    # representation of a new BanditMask built up using BanditMask#<<.
    #
    # In addition to the accessor methods, a query method that delegates to
    # BanditMask#include? will be added.
    #
    #   class ThingMask < BanditMask
    #     bit :read, 0b001
    #     bit :write, 0b010
    #     bit :execute, 0b100
    #     # ...
    #   end
    #
    #   class Thing
    #     attr_accessor :bitmask
    #
    #     extend BanditMask::Banditry
    #     bandit_mask :bitmask, as: :bits, with: ThingMask
    #   end
    def bandit_mask(attribute, as:, with: BanditMask)
      cls = with
      wrapper = as

      class_eval do
        ##
        # A reader method which instances a new BanditMask object and calls
        # BanditMask#bits.
        define_method wrapper do
          cls.new(send(attribute)).bits
        end

        ##
        # A writer method which overwrites the current bitmask attribute with
        # the bitmask representation of the given bits.
        define_method :"#{wrapper}=" do |bits|
          mask = bits.reduce(cls.new) { |mask, bit| mask << bit }
          send :"#{attribute}=", Integer(mask)
        end

        ##
        # A query method which returns +true+ if each of the bits in +bits+ is
        # enabled in the current bitmask and +false+ otherwise.
        define_method :"#{wrapper}?" do |*bits|
          cls.new(send(attribute)).include? *bits
        end
      end
    end
  end
end
