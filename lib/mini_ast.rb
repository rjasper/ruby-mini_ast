# frozen_string_literal: true

require 'mini_ast/builder'
require 'mini_ast/call'
require 'mini_ast/literal'
require 'mini_ast/version'

require 'mini_ast/transform'
require 'mini_ast/underscore_transform'

module MiniAst
  def self.build(&)
    builder = Builder.new.__instance_exec(&)

    Builder._to_ast(builder)
  end
end
