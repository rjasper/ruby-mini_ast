# frozen_string_literal: true

require 'test_helper'

module MiniAst
  class UnderscoreTransformTest < Minitest::Test
    def setup
      @transform = Transform.new(UnderscoreTransform.new)
    end

    def test_transform_literal_helper
      assert_ast lt('Hi!'), -> { _('Hi!') }
    end

    def test_list_literal
      assert_ast lt([lt(1), lt(2)]), -> { _[1, 2] }
    end

    def test_map_literal
      assert_ast lt({ lt(:a) => lt(1) }), -> { _(a: 1) }
    end

    def test_integer_literal
      assert_ast lt(42), -> { _42 }
    end

    def test_assignment
      assert_ast rt(:a=, lt(1)), -> { a._ 1 }
      assert_ast cl(rt(:a), :b=, lt(2)), -> { a.b._ 2 }
    end

    private

    def assert_ast(expected, block)
      ast = MiniAst.build(&block)

      assert_equal(expected, @transform.transform(ast))
    end

    # TODO: extract helpers

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
end
