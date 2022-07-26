module MiniAst
  class UnderscoreTransform
    def transform(node)
      return unless node.is_a?(Call)

      transform_call(node)
    end

    private

    def underscore_receiver?(call)
      receiver = call.receiver

      receiver.is_a?(Call) &&
        receiver.root? &&
        receiver.method == :_ &&
        receiver.ary == 0
    end

    def transform_call(call)
      transform_literal_constructor(call) ||
        transform_list_constructor(call) ||
        transform_integer_constructor(call) ||
        transform_assignment(call) ||
        transform_operator_assignment(call)
    end

    def transform_literal_constructor(call)
      # rt(:_, lt(.)) => lt(.)

      return unless call.root? &&
        call.method == :_ &&
        call.ary == 1 &&
        call.no_block? &&
        ((value = call.args[0])).is_a?(Literal)

      # TODO: MapLiteral

      value
    end

    def transform_list_constructor(call)
      # cl(rt(:_), :[], *) => lt([*])

      return unless (receiver = call.receiver).is_a?(Call) &&
        receiver.root? &&
        receiver.method == :_ &&
        receiver.ary == 0 &&
        receiver.no_block? &&
        call.method == :[] &&
        call.no_block?

      # TODO: transform args
      # TODO: ListLiteral

      Literal.new(call.args)
    end

    INTEGER_CONSTRUCTOR_PATTERN = /\A_\d+\z/.freeze

    def transform_integer_constructor(call)
      # rt(:_123) => lt(123)

      return unless call.root? &&
        call.ary == 0 &&
        call.no_block? &&
        call.method.start_with?('_') &&
        call.method.size > 1 &&
        call.method =~ INTEGER_CONSTRUCTOR_PATTERN

      Literal.new(call.method[1..-1].to_i)
    end

    def transform_assignment(call)
      # cl(cl($r, $m), :_, .) => cl($r, $m=, .)     ( a.b._ c => a.b = c )
      # cl(cl($r, $m), :_, *) => cl($r, $m=, [*])   ( a.b._ c, d => a.b = [c, d])

      receiver = call.receiver

      return unless call.method == :_ &&
        call.ary > 0 &&
        call.no_block? &&
        receiver.is_a?(Call) &&
        receiver.no_block? &&
        receiver.ary == 0 &&
        receiver.method =~ /\A\w+\z/

      # TODO: transform receiver and args
      # TODO: ListLiteral

      arg = call.ary == 1 ? call.args[0] : Literal.new(call.args)

      Call.new(receiver.receiver, :"#{receiver.method}=", [arg])
    end

    ASSIGNABLE_OPERATORS = %i[+ - * / % ** & | ^ << >>].freeze

    def transform_operator_assignment(call)
      # a._ / b => a = a / b
      # cl(cl(cl($r, $m), :_), :/, .) => cl($r, $m=, cl($r, $m, .))

      return unless (receiver1 = call.receiver).is_a?(Call) &&
        (receiver2 = receiver1.receiver).is_a?(Call) &&
        ASSIGNABLE_OPERATORS.include?(call.method) &&
        call.ary == 1 &&
        call.no_block? &&
        receiver1.method == :_ &&
        receiver1.ary == 1 &&
        receiver1.no_block? &&
        receiver2.ary == 0 &&
        receiver2.no_block?

      # TODO: transform receiver and args

      binary_operation =
        Call.new(receiver2.receiver, receiver2.method, call.args[0])

      Call.new(receiver2.receiver, :"#{receiver2.method}=", [binary_operation])
    end
  end
end
