# frozen_string_literal: true

module MiniAst
  class Builder
    def self._to_ast(value)
      case value
      when Array
        Literal.new(value.map { _to_ast(_1) })
      when Hash
        Literal.new(value.to_h { |k, v| [_to_ast(k), _to_ast(v)] })
      when Literal
        value
      when Builder
        value.__receiver
      else
        Literal.new(value)
      end
    end

    def self._record(receiver, method, args = [], block = nil)
      args = args.map { _to_ast(_1) }
      call = Call.new(receiver, method, args, block)

      Builder.new(call)
    end

    alias __instance_exec instance_exec

    (instance_methods - %i[__id__ __send__ object_id hash respond_to? __instance_exec])
      .each { undef_method _1 }

    def initialize(receiver = nil)
      @receiver = receiver
    end

    def __receiver
      @receiver
    end

    %w[! == != <=> === =~ !~].each do |operator|
      class_eval <<~CODE, __FILE__, __LINE__ + 1
        def #{operator}(*args, &block)
          Builder._record(@receiver, :#{operator}, args, block)
        end
      CODE
    end

    def respond_to_missing?(method, include_all)
      true
    end

    def method_missing(method, *args, &block)
      Builder._record(@receiver, method, args, block)
    end
  end
end