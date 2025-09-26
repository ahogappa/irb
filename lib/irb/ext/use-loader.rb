# frozen_string_literal: true
#
#   use-loader.rb -
#   	by Keiju ISHITSUKA(keiju@ruby-lang.org)
#

require_relative "loader"

class Object
  alias __original__load__IRB_use_loader__ load
  alias __original__require__IRB_use_loader__ require
  alias __original__require_relative__IRB_use_loader__ require_relative
end

module IRB
  class Context

    IRB.conf[:USE_LOADER] = false

    # Returns whether +irb+'s own file reader method is used by
    # +load+/+require+ or not.
    #
    # This mode is globally affected (irb-wide).
    def use_loader
      IRB.conf[:USE_LOADER]
    end

    alias use_loader? use_loader

    remove_method :use_loader= if method_defined?(:use_loader=)
    # Sets <code>IRB.conf[:USE_LOADER]</code>
    #
    # See #use_loader for more information.
    def use_loader=(opt)
      if IRB.conf[:USE_LOADER] != opt
        IRB.conf[:USE_LOADER] = opt
        if opt
          # HACK: Workaround to autoload RDoc for IRB autocomplete.
          # Those classes/modules try to autoload in RDoc, but not work well by <code>IRB::Irb#eval_input</code>.
          # So, explicitly load them before overriding <code>require</code>.
          #
          # require 'rdoc'
          # RDoc::RI::Driver.new({})
          # RDoc::NormalModule
          # RDoc::NormalClass
          # RDoc::Markup::Document
          # RDoc::Markup::Raw
          # RDoc::Markup::Paragraph
          # RDoc::Markup::BlankLine
          # RDoc::Markup::Verbatim
          # RDoc::Markup::List
          # RDoc::Markup::ListItem
          # RDoc::Markup::Rule
          # RDoc::Markup::IndentedParagraph
          # RDoc::Markup::HardBreak
          # RDoc::Markup::ToRdoc
          # RDoc::Markup::ToAnsi
          # RDoc::Markup::AttributeManager
          # RDoc::Markup::Attributes
          # RDoc::Markup::AttrSpan
          # RDoc::Markup::RegexpHandling
          # RDoc::Markup::ToBs
          # RDoc::Markup::BlockQuote
          # RDoc::Attr
          # RDoc::Comment
          # RDoc::AnyMethod
          # RDoc::SingleClass
          # RDoc::Constant
          # RDoc::Mixin
          # RDoc::Alias
          # RDoc::Include
          class << workspace.main
            include IRB::IrbLoader

            def require(*args)
              # IRB needs original <code>require</code> when initializing.
              # So, do not use <code>irb_require</code> if <code>IRB.conf[:MAIN_CONTEXT]</code> is nil.
              return __original__require__IRB_use_loader__(*args) if IRB.conf[:MAIN_CONTEXT].nil?

              irb_require(*args)
            end

            def require_relative(*args)
              return __original__require_relative__IRB_use_loader__(*args) if IRB.conf[:MAIN_CONTEXT].nil?

              path = args[0]
              if path.start_with?("/")
                irb_require(*args)
              else
                base = IRB.conf[:MAIN_CONTEXT].irb_path

                irb_require(File.expand_path(path, File.dirname(base)))
              end
            end

            def load(*args)
              return __original__load__IRB_use_loader__(*args) if IRB.conf[:MAIN_CONTEXT].nil?

              irb_load(*args)
            end
          end
        else
          class << workspace.main
            def require(*args)
              __original__require__IRB_use_loader__(*args)
            end
            def require_relative(*args)
              __original__require_relative__IRB_use_loader__(*args)
            end
            def load(*args)
              __original__load__IRB_use_loader__(*args)
            end
          end
        end
      end
      print "Switch to load/require#{unless use_loader; ' non';end} trace mode.\n" if verbose?
      opt
    end
  end
end
