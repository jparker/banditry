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
      @cls.mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :perms
    end

    def test_mask_defines_writer
      refute_respond_to @cls.new, :perms=
      @cls.mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :perms=
    end

    def test_mask_defines_has?
      refute_respond_to @cls.new, :has?
      @cls.mask :perm_mask, as: :perms, with: TestMask
      assert_respond_to @cls.new, :has?
    end

    def test_reader_instantiates_bandit_mask_with_current_bitmask
      @cls.mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b011
      assert_equal [:read, :write], obj.perms
    end

    def test_writer_replaces_current_bitmask_with_bitmask_for_given_values
      @cls.mask :perm_mask, as: :perms, with: TestMask
      obj = @cls.new 0b011
      obj.perms = [:read, :execute]
      assert_equal 0b101, obj.perm_mask
    end
  end
end
