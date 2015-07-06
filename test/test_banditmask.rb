require 'minitest_helper'

class TestBanditMask < Minitest::Test
  def teardown
    BanditMask.reset_bits!
  end

  def test_define_bit
    BanditMask.bit :foo, 0b01
    assert_equal({ foo: 0b01 }, BanditMask.bits)

    BanditMask.bit :bar, 0b10
    assert_equal({ foo: 0b01, bar: 0b10 }, BanditMask.bits)
  end

  def test_initialize_with_default_mask
    BanditMask.bit :foo, 0b001
    BanditMask.bit :bar, 0b010
    BanditMask.bit :baz, 0b100

    mask = BanditMask.new
    assert_equal 0, mask.mask
  end

  def test_initialize_with_specific_mask
    BanditMask.bit :foo, 0b001
    BanditMask.bit :bar, 0b010
    BanditMask.bit :baz, 0b100

    mask = BanditMask.new 0b001 | 0b100
    assert_equal 0b101, mask.mask
  end

  def test_add_value_to_mask
    BanditMask.bit :foo, 0b1

    mask = BanditMask.new
    assert_equal 0, mask.mask

    mask << :foo
    assert_equal 0b1, mask.mask
  end

  def test_add_multiple_values_to_mask
    BanditMask.bit :foo, 0b01
    BanditMask.bit :bar, 0b10

    mask = BanditMask.new
    mask << :foo << :bar
    assert_equal 0b11, mask.mask
  end

  def test_add_undefined_value_to_mask
    mask = BanditMask.new

    assert_raises ArgumentError do
      mask << :bogus
    end
  end

  def test_get_list_of_enabled_bits
    BanditMask.bit :foo, 0b001
    BanditMask.bit :bar, 0b010
    BanditMask.bit :baz, 0b100

    mask = BanditMask.new
    mask << :foo << :baz
    assert_equal [:foo, :baz], mask.names
  end

  def test_include
    BanditMask.bit :foo, 0b001
    BanditMask.bit :bar, 0b010
    BanditMask.bit :baz, 0b100

    mask = BanditMask.new
    mask << :foo << :baz

    assert mask.include?(:foo), 'mask should include :foo'
    refute mask.include?(:bar), 'mask should NOT include :bar'
    assert mask.include?(:baz), 'mask should include :baz'
  end

  def test_include_with_undefined_bit
    mask = BanditMask.new

    assert_raises ArgumentError do
      mask.include? :bogus
    end
  end

  def test_coerce_to_integer
    BanditMask.bit :foo, 0b01
    BanditMask.bit :bar, 0b10

    mask = BanditMask.new
    mask << :foo << :bar

    assert_equal 0b11, Integer(mask)
  end

  def test_coerce_to_array
    BanditMask.bit :foo, 0b01
    BanditMask.bit :bar, 0b10

    mask = BanditMask.new
    mask << :foo << :bar

    assert_equal [:foo, :bar], Array(mask)
  end
end
