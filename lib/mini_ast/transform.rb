module MiniAst
  class Transform
    def initialize(transform)
      @transform = transform
    end

    def transform(node)
      new_node = @transform.transform(node)
      new_node.nil? ? traverse(node) : new_node
    end

    private

    def transform_call(call)
      receiver = transform_call_receiver(call)
      args = transform_call_args(call.args)

      if receiver.equal?(call.receiver) && args.equal?(call.args)
        call
      else
        Call.new(receiver, call.method, args, call.block)
      end
    end

    def transform_call_receiver(receiver)
      receiver.nil? ? nil : transform(receiver)
    end

    def transform_call_args(args)
      new_args = args.map { transform(_1) }
      unchanged = args.lazy.zip(new_args).all? { |a, b| a.equal?(b) }

      unchanged ? args : new_args
    end

    def traverse(node)
      case node
      when Literal
        node
      when Call
        transform_call(call)
      else
        raise "Unexpected node: #{node.class}"
      end
    end
  end
end
