require 'minitest_helper'

class BanditMask
  class TestBanditry < Minitest::Test # :nodoc:
    class TestMask < BanditMask
      bit :read,    0b001
      bit :write,   0b010
      bit :execute, 0b100
    end

    def test_bandit_mask_defines_reader_method
      refute_respond_to cls.new, :bits
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to cls.new, :bits
    end

    def test_bandit_mask_defines_writer_method
      refute_respond_to cls.new, :bits=
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to cls.new, :bits=
    end

    def test_bandit_mask_defines_query_method
      refute_respond_to cls.new, :bits?
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      assert_respond_to cls.new, :bits?
    end

    def test_bandit_mask_raises_error_if_reader_method_exists
      def cls.bits; end

      e = assert_raises MethodCollisionError do
        cls.bandit_mask :bitmask, as: :bits, with: TestMask
      end
      assert_equal 'method `bits` already exists', e.message
    end

    def test_bandit_mask_raises_error_if_writer_method_exists
      def cls.bits=; end

      e = assert_raises MethodCollisionError do
        cls.bandit_mask :bitmask, as: :bits, with: TestMask
      end
      assert_equal 'method `bits=` already exists', e.message
    end

    def test_bandit_mask_raises_error_if_query_method_exists
      def cls.bits?; end

      e = assert_raises MethodCollisionError do
        cls.bandit_mask :bitmask, as: :bits, with: TestMask
      end
      assert_equal 'method `bits?` already exists', e.message
    end

    def test_reader_method_instantiates_bandit_mask_with_current_bitmask
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = cls.new 0b011

      assert_equal [:read, :write], obj.bits
    end

    def test_writer_method_overwrites_current_bitmask_with_bitmask_for_given_values
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = cls.new 0b011
      obj.bits = [:read, :execute]

      assert_equal 0b101, obj.bitmask
    end

    def test_query_method_with_a_single_bit
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = cls.new 0b001

      assert obj.bits?(:read), "#{obj.inspect} must have :read"
      refute obj.bits?(:write), "#{obj.inspect} must NOT have :write"
    end

    def test_query_method_with_multiple_bits
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = cls.new 0b011

      assert obj.bits?(:read, :write),
        "#{obj.inspect} must have :read and :write"
      refute obj.bits?(:read, :execute),
        "#{obj.inspect} must NOT have :read and :execute"
    end

    def test_query_method_with_undefined_bit
      cls.bandit_mask :bitmask, as: :bits, with: TestMask
      obj = cls.new 0b001

      assert_raises(ArgumentError) { obj.bits? :bogus }
    end

    def cls
      @cls ||= Struct.new(:bitmask) do
        extend Banditry
      end
    end
  end
end
