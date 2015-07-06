require 'minitest_helper'

class TestBanditMask < Minitest::Test # :nodoc:
  def setup
    @cls = Class.new(BanditMask)
  end

  def test_define_bit
    @cls.bit :foo, 0b01
    assert_equal({ foo: 0b01 }, @cls.bits)

    @cls.bit :bar, 0b10
    assert_equal({ foo: 0b01, bar: 0b10 }, @cls.bits)
  end

  def test_initialize_with_default_mask
    @cls.bit :foo, 0b001
    @cls.bit :bar, 0b010
    @cls.bit :baz, 0b100

    mask = @cls.new
    assert_equal 0, mask.mask
  end

  def test_initialize_with_specific_mask
    @cls.bit :foo, 0b001
    @cls.bit :bar, 0b010
    @cls.bit :baz, 0b100

    mask = @cls.new 0b001 | 0b100
    assert_equal 0b101, mask.mask
  end

  def test_add_value_to_mask
    @cls.bit :foo, 0b1

    mask = @cls.new
    assert_equal 0, mask.mask

    mask << :foo
    assert_equal 0b1, mask.mask
  end

  def test_add_multiple_values_to_mask
    @cls.bit :foo, 0b01
    @cls.bit :bar, 0b10

    mask = @cls.new
    mask << :foo << :bar
    assert_equal 0b11, mask.mask
  end

  def test_add_undefined_value_to_mask
    mask = @cls.new

    assert_raises ArgumentError do
      mask << :bogus
    end
  end

  def test_get_list_of_enabled_bits
    @cls.bit :foo, 0b001
    @cls.bit :bar, 0b010
    @cls.bit :baz, 0b100

    mask = @cls.new
    mask << :foo << :baz
    assert_equal [:foo, :baz], mask.names
  end

  def test_include
    @cls.bit :foo, 0b001
    @cls.bit :bar, 0b010
    @cls.bit :baz, 0b100

    mask = @cls.new
    mask << :foo << :baz

    assert mask.include?(:foo), 'mask should include :foo'
    refute mask.include?(:bar), 'mask should NOT include :bar'
    assert mask.include?(:baz), 'mask should include :baz'
  end

  def test_include_with_undefined_bit
    mask = @cls.new

    assert_raises ArgumentError do
      mask.include? :bogus
    end
  end

  def test_coerce_to_integer
    @cls.bit :foo, 0b01
    @cls.bit :bar, 0b10

    mask = @cls.new
    mask << :foo << :bar

    assert_equal 0b11, Integer(mask)
  end

  def test_coerce_to_array
    @cls.bit :foo, 0b01
    @cls.bit :bar, 0b10

    mask = @cls.new
    mask << :foo << :bar

    assert_equal [:foo, :bar], Array(mask)
  end
end
