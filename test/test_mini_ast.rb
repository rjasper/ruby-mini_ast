# frozen_string_literal: true

require "test_helper"

class TestMiniAst < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniAst::VERSION
  end

  def test_simple_literals
    assert_equal literal(1), build { 1 }
    assert_equal literal('test'), build { 'test' }
    assert_equal literal(nil), build { nil }
  end

  def test_complex_literals
    assert_equal literal([literal(1), literal(2)]),
      build { [1, 2] }

    assert_equal literal(literal(:foo) => literal(:bar)),
      build { { foo: :bar } }
  end

  def test_calls
    assert_equal call(nil, :foo),
      build { foo }

    assert_equal call(nil, :foo, literal(42)),
      build { foo(42) }

    assert_equal call(call(nil, :foo), :bar),
      build { foo.bar }
  end

  private

  def call(receiver, method, *args)
    MiniAst::Call.new(receiver, method, args, nil)
  end

  def literal(value)
    MiniAst::Literal.new(value)
  end

  def build(&)
    MiniAst.build(&)
  end
end
