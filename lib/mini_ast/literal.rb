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

    def hash
      @hash ||= [self.class, @value].hash
    end

    def to_s
      value.inspect
    end
    alias inspect to_s
  end
end
