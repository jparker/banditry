require 'minitest_helper'

class BanditMask
  class TestBanditry < Minitest::Test # :nodoc:
    class TestMask < BanditMask
      bit :read,    0b001
      bit :write,   0b010
      bit :execute, 0b100
    end

    def setup
      @cls = Struct.new(:bitmask) do
        extend Banditry
      end
    end

    def test_mask_defines_reader
      refute_respond_to @cls.new, :bits
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to @cls.new, :bits
    end

    def test_mask_defines_writer
      refute_respond_to @cls.new, :bits=
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to @cls.new, :bits=
    end

    def test_mask_defines_query
      refute_respond_to @cls.new, :bits?
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to @cls.new, :bits?
    end

    def test_reader_instantiates_bandit_mask_with_current_bitmask
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = @cls.new 0b011
      assert_equal [:read, :write], obj.bits
    end

    def test_writer_overwrites_current_bitmask_with_bitmask_for_given_values
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = @cls.new 0b011
      obj.bits = [:read, :execute]
      assert_equal 0b101, obj.bitmask
    end

    def test_query_method_with_a_single_bit
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = @cls.new 0b001
      assert obj.bits?(:read), "#{obj.inspect} must have :read"
      refute obj.bits?(:write), "#{obj.inspect} must NOT have :write"
    end

    def test_query_method_with_multiple_bits
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = @cls.new 0b011
      assert obj.bits?(:read, :write), "#{obj.inspect} must have :read and :write"
      refute obj.bits?(:read, :execute), "#{obj.inspect} must NOT have :read and :execute"
    end

    def test_query_method_with_undefined_bit
      @cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = @cls.new 0b001

      assert_raises ArgumentError do
        obj.bits? :bogus
      end
    end
  end
end
