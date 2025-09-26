# frozen_string_literal: true
#
#   load.rb -
#   	by Keiju ISHITSUKA(keiju@ruby-lang.org)
#
require_relative "../ext/loader"

module IRB
  # :stopdoc:

  module Command
    class LoaderCommand < Base
      include RubyArgsExtractor
      include IrbLoader

      def raise_cmd_argument_error
        raise CommandArgumentError.new("Please specify the file name.")
      end
    end

    class Load < LoaderCommand
      category "IRB"
      description "Load a Ruby file."

      def execute(arg)
        args, kwargs = ruby_args(arg)
        execute_internal(*args, **kwargs)
      end

      def execute_internal(file_name = nil, priv = nil)
        raise_cmd_argument_error unless file_name
        irb_load(file_name, priv)
      end
    end

    class Require < LoaderCommand
      category "IRB"
      description "Require a Ruby file."

      def execute(arg)
        args, kwargs = ruby_args(arg)
        execute_internal(*args, **kwargs)
      end

      def execute_internal(file_name = nil)
        raise_cmd_argument_error unless file_name

        irb_require(file_name)
      end
    end

    class Source < LoaderCommand
      category "IRB"
      description "Loads a given file in the current session."

      def execute(arg)
        args, kwargs = ruby_args(arg)
        execute_internal(*args, **kwargs)
      end

      def execute_internal(file_name = nil)
        raise_cmd_argument_error unless file_name

        source_file(file_name)
      end
    end
  end
  # :startdoc:
end
