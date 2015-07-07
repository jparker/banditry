require 'banditry/version'
require 'banditry/bandit_mask'
require 'forwardable'

module Banditry
  class BanditryError < StandardError
  end

  class MethodCollisionError < BanditryError
  end

  ##
  # Creates wrapper methods for reading, writing, and querying the bitmask
  # stored in +attribute+ using the class +with+. +with+ defaults to
  # Banditry::BanditMask, but you can (and probably should) define your own
  # class inheriting from+Banditry::BanditMask to fill this role. The name of
  # the accessor methods will be derived from +as+, e.g., if +as+ is +:foo+,
  # the methods will be named +:foo+, +:foo=+, and +:foo?+.
  #
  # The reader method will return a Banditry::BanditMask representation of
  # +attribute+.
  #
  # The writer method overwrites the current bitmask if with an Array of bits,
  # or it updates the current bitmask if sent an individual bit, e.g., using
  # +#|+.
  #
  # In addition to the accessor methods, a query method that delegates to
  # Banditry::BanditMask#include? will be added.
  #
  #   class FileMask < Banditry::BanditMask
  #     bit :r, 0b001
  #     bit :w, 0b010
  #     bit :x, 0b100
  #   end
  #
  #   class FileObject
  #     attr_accessor :mode_mask
  #
  #     extend Banditry
  #     bandit_mask :mode_mask, as: :mode, with: FileMask
  #   end
  #
  #   file = FileObject.new
  #   file.mode_mask       # => nil
  #   file.mode |= :r
  #   file.mode_mask       # => 1
  #   file.mode |= :w
  #   file.mode_mask       # => 3
  #   file.mode = [:r, :x]
  #   file.mode_mask       # => 5
  def bandit_mask(attribute, as:, with: BanditMask)
    class_eval do
      extend SingleForwardable

      generate_class_method as, with
      generate_reader attribute, as, with
      generate_writer attribute, as, with
      generate_query attribute, as, with
    end
  end

  private

  def generate_class_method(virt, bandit)
    respond_to? virt and
      raise MethodCollisionError, "method `#{self}.#{virt}` already exists"

    def_single_delegator bandit, :bits, virt
  end

  def generate_reader(attr, virt, bandit)
    instance_methods.include? virt and
      raise MethodCollisionError, "method `#{self}##{virt}` already exists"

    define_method virt do
      instance_variable_get(:"@#{virt}") ||
        instance_variable_set(:"@#{virt}", bandit.new(send(attr)))
    end
  end

  def generate_writer(attr, virt, bandit)
    instance_methods.include? :"#{virt}=" and
      raise MethodCollisionError, "method `#{self}##{virt}=` already exists"

    define_method :"#{virt}=" do |bits|
      mask = case bits
             when BanditMask
               bits
             else
               bits.inject(bandit.new) { |bm, bit| bm << bit }
             end
      send :"#{attr}=", Integer(mask)
      instance_variable_set :"@#{virt}", mask
    end
  end

  def generate_query(attr, virt, bandit)
    instance_methods.include? :"#{virt}?" and
      raise MethodCollisionError, "method `#{self}##{virt}?` already exists"

    define_method :"#{virt}?" do |*bits|
      bandit.new(send(attr)).include? *bits
    end
  end
end
