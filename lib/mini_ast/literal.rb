# frozen_string_literal: true

module MiniAst
  class Literal
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def ==(other)
      return true if equal?(other)

      other.is_a?(Literal) && other.value == @value
    end

    def eql?(other)
      return true if equal?(other)

      other.is_a?(Literal) && other.value.eql?(@value)
    end

    HASH_SEED = hash * 31

    def hash
      @hash ||= HASH_SEED + @value.hash
    end

    def to_s
      value.inspect
    end
    alias inspect to_s
  end
end
