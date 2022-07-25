# frozen_string_literal: true

module MiniAst
  class Literal
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value.inspect
    end
    alias inspect to_s
  end
end
