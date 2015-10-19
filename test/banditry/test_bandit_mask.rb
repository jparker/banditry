require 'minitest_helper'

class TestBanditMask < Minitest::Test # :nodoc:
  def test_bits
    assert_equal({ read: 0b001, write: 0b010, execute: 0b100 }, cls.bits)
  end

  def test_initialize_with_default_mask
    mask = cls.new
    assert_equal 0, mask.to_i
  end

  def test_initialize_with_specific_mask
    mask = cls.new 0b001 | 0b100
    assert_equal 0b101, mask.to_i
  end

  def test_push_bit_into_mask
    mask = cls.new

    assert_equal 0b0, mask.to_i
    mask << :read
    assert_equal 0b1, mask.to_i
  end

  def test_push_is_chainable
    mask = cls.new
    mask << :read << :write
    assert_equal 0b11, mask.to_i
  end

  def test_push_undefined_bit_into_mask
    mask = cls.new

    e = assert_raises(ArgumentError) { mask << :bogus }
    assert_match /undefined bit/, e.message
  end

  def test_bitwise_or_remembers_original_bitmask
    mask = cls.new 0b001

    assert_equal 0b011, Integer(mask | :write)
    assert_equal 0b111, Integer(mask | :write | :execute)
  end

  def test_bitwise_or_returns_new_instance_of_mask_class
    _cls = cls
    mask = _cls.new

    assert_instance_of _cls, mask | :read
  end

  def test_bitwise_or_with_undefined_bit
    mask = cls.new

    e = assert_raises(ArgumentError) { mask | :bogus }
    assert_match /undefined bit/, e.message
  end

  def test_bandit_masks_are_equal_if_bitmask_and_class_are_identical
    _cls = cls
    a = _cls.new | :write | :read
    b = _cls.new | :read | :write
    c = _cls.new | :read
    d = cls.new | :read | :write

    assert_equal a, b
    refute_equal a, c
    refute_equal a, d
  end

  def test_bandit_masks_have_identical_hashes_if_bitmask_and_class_are_identical
    _cls = cls
    a = _cls.new | :write | :read
    b = _cls.new | :read | :write
    c = _cls.new | :read
    d = cls.new | :read | :write

    assert_equal a.hash, b.hash
    refute_equal a.hash, c.hash
    refute_equal a.hash, d.hash
  end

  def test_bandit_masks_are_hash_equal_if_bitmask_and_class_are_identical
    _cls = cls
    a = _cls.new | :write | :read
    b = _cls.new | :read | :write
    c = _cls.new | :read
    d = cls.new | :read | :write

    assert a.eql?(b), "Expected #{a.inspect} to be hash-equal to #{b.inspect}"
    refute a.eql?(c), "Expected #{a.inspect} NOT to be hash-equal to #{c.inspect}"
    refute a.eql?(d), "Expected #{a.inspect} NOT to be hash-equal to #{d.inspect}"
  end

  def test_get_list_of_enabled_bits
    mask = cls.new | :read | :execute
    assert_equal [:read, :execute], mask.bits
  end

  def test_empty_with_nonzero_bitmask
    mask = cls.new | :read
    refute mask.empty?, "#{mask.inspect}#empty? should have been false"
  end

  def test_empty_with_zero_bitmask
    mask = cls.new
    assert mask.empty?, "#{mask.inspect}#empty? should NOT have been false"
  end

  def test_include_with_a_single_bit
    mask = cls.new | :read | :execute

    assert_includes mask, :read
    refute_includes mask, :write
    assert_includes mask, :execute
  end

  def test_include_with_multiple_bits
    mask = cls.new | :read | :execute

    refute mask.include?(:read, :write),
      "#{mask.inspect} must NOT have :read and :write"
    assert mask.include?(:read, :execute),
      "#{mask.inspect} must have :read and :execute"
  end

  def test_include_with_undefined_bit
    mask = cls.new

    e = assert_raises(ArgumentError) { mask.include? :bogus }
    assert_match /undefined bit/, e.message
  end

  def test_include_without_any_arguments
    mask = cls.new

    e = assert_raises(ArgumentError) { mask.include? }
    assert_equal 'wrong number of arguments (0 for 1+)', e.message
  end

  def test_coerce_to_integer
    mask = cls.new | :read | :write
    assert_equal 0b11, Integer(mask)
  end

  def test_coerce_to_array
    mask = cls.new | :read | :write
    assert_equal [:read, :write], Array(mask)
  end

  def test_iterate_over_roles
    mask = cls.new | :read | :write
    yielded_values = []

    mask.each { |bit| yielded_values << bit }

    assert_equal [:read, :write], yielded_values
  end

  def cls
    Class.new Banditry::BanditMask do
      bit :read, 1 << 0
      bit :write, 1 << 1
      bit :execute, 1 << 2
    end
  end
end
