require 'minitest_helper'

class TestBanditry < Minitest::Test # :nodoc:
  class TestMask < Banditry::BanditMask
    bit :read,    0b001
    bit :write,   0b010
    bit :execute, 0b100
  end

  # class method

  def test_bandit_mask_defines_class_method
    refute_respond_to cls, :perms
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    assert_respond_to cls, :perms
  end

  def test_bandit_mask_raises_error_if_class_method_exists
    def cls.perms; end

    e = assert_raises Banditry::MethodCollisionError do
      cls.bandit_mask :bitmask, as: :perms, with: TestMask
    end
    assert_equal "method `#{cls}.perms` already exists", e.message
  end

  def test_class_method_delegates_to_bandit_mask_bits
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    assert_equal({ read: 0b001, write: 0b010, execute: 0b100 }, cls.perms)
  end

  # reader method

  def test_bandit_mask_defines_reader_method
    refute_respond_to cls.new, :perms
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    assert_respond_to cls.new, :perms
  end

  def test_bandit_mask_raises_error_if_reader_method_exists
    cls.class_eval { def perms; end }

    e = assert_raises Banditry::MethodCollisionError do
      cls.bandit_mask :bitmask, as: :perms, with: TestMask
    end
    assert_equal "method `#{cls}#perms` already exists", e.message
  end

  def test_reader_method_instantiates_bandit_mask_with_current_bitmask
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new 0b011

    assert_equal TestMask.new(0b011), obj.perms
  end

  def test_bandit_mask_defines_writer_method
    refute_respond_to cls.new, :perms=
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    assert_respond_to cls.new, :perms=
  end

  def test_bandit_mask_raises_error_if_writer_method_exists
    cls.class_eval { def perms=; end }

    e = assert_raises Banditry::MethodCollisionError do
      cls.bandit_mask :bitmask, as: :perms, with: TestMask
    end
    assert_equal "method `#{cls}#perms=` already exists", e.message
  end

  # writer method

  def test_writer_method_overwrites_current_bitmask_if_given_an_array
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new 0b011
    obj.perms = [:read, :execute]

    assert_equal 0b101, obj.bitmask
  end

  def test_writer_method_updates_current_bitmask_if_given_bandit_mask
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new
    obj.perms |= :read
    obj.perms |= :execute

    assert_equal 0b101, obj.bitmask
  end

  # query method

  def test_bandit_mask_defines_query_method
    refute_respond_to cls.new, :perms?
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    assert_respond_to cls.new, :perms?
  end

  def test_bandit_mask_raises_error_if_query_method_exists
    cls.class_eval { def perms?; end }

    e = assert_raises Banditry::MethodCollisionError do
      cls.bandit_mask :bitmask, as: :perms, with: TestMask
    end
    assert_equal "method `#{cls}#perms?` already exists", e.message
  end

  def test_query_method_with_a_single_bit
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new 0b001

    assert obj.perms?(:read), "#{obj.inspect} must have :read"
    refute obj.perms?(:write), "#{obj.inspect} must NOT have :write"
  end

  def test_query_method_with_multiple_bits
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new 0b011

    assert obj.perms?(:read, :write),
      "#{obj.inspect} must have :read and :write"
    refute obj.perms?(:read, :execute),
      "#{obj.inspect} must NOT have :read and :execute"
  end

  def test_query_method_with_undefined_bit
    cls.bandit_mask :bitmask, as: :perms, with: TestMask
    obj = cls.new 0b001

    assert_raises(ArgumentError) { obj.perms? :bogus }
  end

  def cls
    @cls ||= Struct.new(:bitmask) do
      extend Banditry
    end
  end
end
