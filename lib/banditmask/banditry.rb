require 'forwardable'

class BanditMask
  module Banditry
    def self.extended(cls) # :nodoc:
      cls.extend Forwardable
    end

    ##
    # Creates wrapper methods for reading and writing the bitmask stored in
    # +attribute+ using the class +with+. +with+ defaults to BanditMask, but
    # you can (and probably) should define your own class descending from
    # +BanditMask+ to fill this role. The name of the accessor methods will be
    # derived from +as+, e.g., if +as+ is +:foo+, the reader method will be
    # +:foo+ and the writer will be +:foo=+.
    #
    # The reader method will call BanditMask#bits to get an array of the
    # enabled bit names represented by +attribute+.
    #
    # The writer method will replace the current bitmask with an Integer
    # representation of a new BanditMask built up using BanditMask#<<.
    #
    # In addition to the accessor methods, a method named +has?+ will be added
    # which delegates to the BanditMask#include?.
    #
    #   class ThingMask < BanditMask
    #     # ...
    #     # bit :foo, 0b1
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

        define_method :"#{wrapper}=" do |bits|
          mask = bits.reduce(cls.new) { |mask, bit| mask << bit }
          send :"#{attribute}=", Integer(mask)
        end

        def_delegator wrapper, :include?, :has?
      end
    end
  end
end