# frozen_string_literal: true

require_relative "mini_ast/version"

module MiniAst
  def self.build(&block)
    builder = Builder.new.__instance_exec(&block)

    Builder._to_ast(builder)
  end
end
