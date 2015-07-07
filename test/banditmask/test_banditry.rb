require 'minitest_helper'

class BanditMask
  class TestBanditry < Minitest::Test # :nodoc:
    class TestMask < BanditMask
      bit :read,    0b001
      bit :write,   0b010
      bit :execute, 0b100
    end

    def setup
      @cls = Struct.new(:perm_mask) do
        extend Banditry
      end
    end

    def test_mask_defines_reader
      refute_respond_to @cls.new, :perms
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :perms
    end

    def test_mask_defines_writer
      refute_respond_to @cls.new, :perms=
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :perms=
    end

    def test_mask_defines_query
      refute_respond_to @cls.new, :perms?
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :perms?
    end

    def test_reader_instantiates_bandit_mask_with_current_bitmask
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b011
      assert_equal [:read, :write], obj.perms
    end

    def test_writer_overwrites_current_bitmask_with_bitmask_for_given_values
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b011
      obj.perms = [:read, :execute]
      assert_equal 0b101, obj.perm_mask
    end

    def test_query_method_with_a_single_bit
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b001
      assert obj.perms?(:read), "#{obj.inspect} must have :read"
      refute obj.perms?(:write), "#{obj.inspect} must NOT have :write"
    end

    def test_query_method_with_multiple_bits
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b011
      assert obj.perms?(:read, :write), "#{obj.inspect} must have :read and :write"
      refute obj.perms?(:read, :execute), "#{obj.inspect} must NOT have :read and :execute"
    end

    def test_query_method_with_undefined_bit
      @cls.bandit_mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b001

      assert_raises ArgumentError do
        obj.perms? :bogus
      end
    end
  end
end
