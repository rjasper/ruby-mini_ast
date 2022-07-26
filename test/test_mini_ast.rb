# frozen_string_literal: true

require 'test_helper'

class TestMiniAst < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniAst::VERSION
  end

  def test_simple_literals
    assert_ast lt(1), -> { 1 }
    assert_ast lt(1), -> { 1 }
    assert_ast lt('test'), -> { 'test' }
    assert_ast lt(nil), -> {}
  end

  def test_complex_literals
    assert_ast lt([lt(1), lt(2)]), -> { [1, 2] }
    assert_ast lt(lt(:foo) => lt(:bar)), -> { { foo: :bar } }
  end

  def test_calls
    assert_ast rt(:foo), -> { foo }
    assert_ast rt(:foo, lt(42)), -> { foo(42) }
    assert_ast cl(rt(:foo), :bar), -> { foo.bar }
  end

  def test_operators
    # unary
    assert_ast cl(rt(:a), :!), -> { !a }
    assert_ast cl(rt(:a), :~), -> { ~a }
    assert_ast cl(rt(:a), :+@), -> { +a }
    assert_ast cl(rt(:a), :-@), -> { -a }

    # binary
    assert_ast cl(rt(:a), :+, rt(:b)), -> { a + b }
    assert_ast cl(rt(:a), :-, rt(:b)), -> { a - b }
    assert_ast cl(rt(:a), :*, rt(:b)), -> { a * b }
    assert_ast cl(rt(:a), :/, rt(:b)), -> { a / b }
    assert_ast cl(rt(:a), :%, rt(:b)), -> { a % b }
    assert_ast cl(rt(:a), :**, rt(:b)), -> { a**b }
    assert_ast cl(rt(:a), :<, rt(:b)), -> { a < b }
    assert_ast cl(rt(:a), :>, rt(:b)), -> { a > b }
    assert_ast cl(rt(:a), :<=, rt(:b)), -> { a <= b }
    assert_ast cl(rt(:a), :>=, rt(:b)), -> { a >= b }
    assert_ast cl(rt(:a), :<=>, rt(:b)), -> { a <=> b }
    assert_ast cl(rt(:a), :==, rt(:b)), -> { a == b }
    assert_ast cl(rt(:a), :===, rt(:b)), -> { a === b }
    assert_ast cl(rt(:a), :!=, rt(:b)), -> { a != b }
    assert_ast cl(rt(:a), :=~, rt(:b)), -> { a =~ b }
    assert_ast cl(rt(:a), :!~, rt(:b)), -> { a !~ b }
    assert_ast cl(rt(:a), :&, rt(:b)), -> { a & b }
    assert_ast cl(rt(:a), :|, rt(:b)), -> { a | b }
    assert_ast cl(rt(:a), :^, rt(:b)), -> { a ^ b }
    assert_ast cl(rt(:a), :<<, rt(:b)), -> { a << b }
    assert_ast cl(rt(:a), :>>, rt(:b)), -> { a >> b }

    # brackets
    assert_ast cl(rt(:a), :[], rt(:b)), -> { a[b] }
    assert_ast cl(rt(:a), :[]=, rt(:b), rt(:c)), -> { a.[]=(b, c) }
  end

  private

  def assert_ast(expected, block)
    assert_equal(expected, MiniAst.build(&block))
  end

  def cl(receiver, method, *args)
    MiniAst::Call.new(receiver, method, args, nil)
  end

  def rt(method, *args)
    MiniAst::Call.new(nil, method, args, nil)
  end

  def lt(value)
    MiniAst::Literal.new(value)
  end
end
