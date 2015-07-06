require 'minitest_helper'

class TestBanditMask < Minitest::Test # :nodoc:
  def setup
    @cls = Class.new(BanditMask)
  end

  def test_define_bit
    @cls.bit :read, 0b01
    assert_equal({ read: 0b01 }, @cls.bits)

    @cls.bit :write, 0b10
    assert_equal({ read: 0b01, write: 0b10 }, @cls.bits)
  end

  def test_initialize_with_default_mask
    @cls.bit :read, 0b001
    @cls.bit :write, 0b010
    @cls.bit :execute, 0b100

    mask = @cls.new
    assert_equal 0, mask.to_i
  end

  def test_initialize_with_specific_mask
    @cls.bit :read, 0b001
    @cls.bit :write, 0b010
    @cls.bit :execute, 0b100

    mask = @cls.new 0b001 | 0b100
    assert_equal 0b101, mask.to_i
  end

  def test_add_value_to_mask
    @cls.bit :read, 0b1

    mask = @cls.new
    assert_equal 0, mask.to_i

    mask << :read
    assert_equal 0b1, mask.to_i
  end

  def test_add_multiple_values_to_mask
    @cls.bit :read, 0b01
    @cls.bit :write, 0b10

    mask = @cls.new
    mask << :read << :write
    assert_equal 0b11, mask.to_i
  end

  def test_add_undefined_value_to_mask
    mask = @cls.new

    assert_raises ArgumentError do
      mask << :bogus
    end
  end

  def test_get_list_of_enabled_bits
    @cls.bit :read, 0b001
    @cls.bit :write, 0b010
    @cls.bit :execute, 0b100

    mask = @cls.new
    mask << :read << :execute
    assert_equal [:read, :execute], mask.bits
  end

  def test_include_with_a_single_bit
    @cls.bit :read, 0b001
    @cls.bit :write, 0b010
    @cls.bit :execute, 0b100

    mask = @cls.new
    mask << :read << :execute

    assert_includes mask, :read
    refute_includes mask, :write
    assert_includes mask, :execute
  end

  def test_include_with_multiple_bits
    @cls.bit :read, 0b001
    @cls.bit :write, 0b010
    @cls.bit :execute, 0b100

    mask = @cls.new
    mask << :read << :execute

    refute mask.include?(:read, :write),
      "#{mask.inspect} must NOT have :read and :write"
    assert mask.include?(:read, :execute),
      "#{mask.inspect} must have :read and :execute"
  end

  def test_include_with_undefined_bit
    mask = @cls.new

    assert_raises ArgumentError do
      mask.include? :bogus
    end
  end

  def test_include_without_any_arguments
    mask = @cls.new

    assert_raises ArgumentError do
      mask.include?
    end
  end

  def test_coerce_to_integer
    @cls.bit :read, 0b01
    @cls.bit :write, 0b10

    mask = @cls.new
    mask << :read << :write

    assert_equal 0b11, Integer(mask)
  end

  def test_coerce_to_array
    @cls.bit :read, 0b01
    @cls.bit :write, 0b10

    mask = @cls.new
    mask << :read << :write

    assert_equal [:read, :write], Array(mask)
  end
end
