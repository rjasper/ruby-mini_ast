# frozen_string_literal: true

module MiniAst
  class Call
    attr_reader :receiver, :method, :args, :block

    def initialize(receiver, method, args, block)
      @receiver = receiver
      @method = method
      @args = args
      @block = block
    end

    def ==(other)
      return true if equal?(other)

      other.is_a?(Call) &&
        other.receiver == @receiver &&
        other.method == @method &&
        other.args == @args &&
        other.block == @block
    end

    def eql?(other)
      return true if equal?(other)

      other.is_a?(Call) &&
        other.receiver.eql?(@receiver) &&
        other.method.eql?(@method) &&
        other.args.eql?(@args) &&
        other.block.eql?(@block)
    end

    HASH_SEED = hash * 31

    def hash
      @hash ||= begin
        hash = HASH_SEED + @receiver.hash
        hash = (hash * 31) + @method.hash
        hash = (hash * 31) + @args.hash
        hash = (hash * 31) + @block.hash
        hash
      end
    end

    def to_s
      case method
      when :!, :~
        # !foo
        return "#{method}#{receiver}" if args.size == 0
      when :+@
        # +foo
        return "+#{receiver}" if args.size == 0
      when :-@
        # -foo
        return "-#{receiver}" if args.size == 0
      when :+, :-, :*, :/, :%, :**, :<, :>, :<=, :>=, :<=>, :==, :===, :!=, :=~, :!~, :&, :|, :^, :<<, :>>
        # foo + bar
        return "(#{receiver} #{method} #{args.first})" if args.size == 1
      when :[]
        # foo[a, b, ...]
        return "#{receiver}[#{args.map(&:to_s).join(', ')}]"
      when :[]=
        # (foo[a, b, ...] = 1)
        return "(#{receiver}[#{args[0..-2].map(&:to_s).join(', ')}] = #{args.last})"
      end

      receiver_part = receiver.nil? ? '' : "#{receiver}."

      if method.end_with?('=') && args.size == 1
        # foo.bar = 42

        "(#{receiver_part}#{method[0..-2]} = #{args.first})"
      else
        # foo.bar OR foo.bar(arg1, arg2, ...)

        args_part = args.size == 0 ? '' : "(#{args.map(&:to_s).join(', ')})"
        "#{receiver_part}#{method}#{args_part}"
      end
    end
    alias inspect to_s
  end
end
