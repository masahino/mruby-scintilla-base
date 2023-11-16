module Scintilla
  # The ScintillaBase class serves as a wrapper for handling Scintilla messages.
  # It dynamically defines methods to interact with the Scintilla library,
  # improving performance for repeated method calls.
  class ScintillaBase
    # Mapping of Scintilla message IDs to their corresponding handler methods.
    # This allows for modular handling of different message types.
    MESSAGE_HANDLERS = {
      SCI_GETFOCUS => :handler_bool,
      SCI_AUTOCACTIVE => :handler_bool,
      SCI_GETREADONLY => :handler_bool,
      SCI_CALLTIPACTIVE => :handler_bool,
      SCI_SETTEXT => :handler_2nd_arg,
      SCI_AUTOCSELECT => :handler_2nd_arg,
      SCI_GETTARGETTEXT => :send_message_get_str,
      SCI_AUTOCGETCURRENTTEXT => :send_message_get_str,
      SCI_ANNOTATIONGETTEXT => :send_message_get_str,
      SCI_GETSELTEXT => :send_message_get_str,
      SCI_GETPROPERTY => :send_message_get_str,
      SCI_GETWORDCHARS => :send_message_get_str,
      SCI_GETLEXERLANGUAGE => :send_message_get_str,
      SCI_MARGINGETTEXT => :send_message_get_str,
      SCI_GETTEXT => :send_message_get_text,
      SCI_GETTEXTRANGE => :send_message_get_text_range,
      SCI_GETCURLINE => :handler_get_curline,
      SCI_GETLINE => :handler_get_line,
      SCI_GETDOCPOINTER => :send_message_get_docpointer,
      SCI_CREATEDOCUMENT => :send_message_get_docpointer,
      SCI_SETDOCPOINTER => :send_message_set_docpointer,
      SCI_ADDREFDOCUMENT => :send_message_set_docpointer,
      SCI_RELEASEDOCUMENT => :send_message_set_docpointer,
      SCI_SETILEXER => :send_message_set_pointer
    }.freeze

    # Handles boolean type messages. Converts the response to a boolean value.
    # @param message_id [Integer] The message ID corresponding to the Scintilla message.
    # @param args [Array] Additional arguments for the message.
    # @return [Boolean] The boolean result of the message.
    def handler_bool(message_id, *args)
      send_message(message_id, *args) != 0
    end

    # Handles messages that require a single argument.
    # This is typically used for messages where the second argument is significant.
    # @param message_id [Integer] The message ID corresponding to the Scintilla message.
    # @param args [Array] Additional arguments for the message.]]
    def handler_2nd_arg(message_id, *args)
      send_message(message_id, 0, args[0])
    end

    # Handles the `SCI_GETCURLINE` message to retrieve the current line.
    # It sends a message to Scintilla and returns the current line as a string.
    # This method is specialized to handle string retrieval from Scintilla.
    # @return [Array] An array containing the current line's text and the caret position.
    def handler_get_curline(_message_id, *_args)
      send_message_get_curline
    end

    # Handles the `SCI_GETLINE` message to retrieve a specific line.
    # It sends a message to Scintilla and returns the requested line as a string.
    # This method is specialized to handle string retrieval from Scintilla.
    # @param line_number [Integer] The line number to retrieve.
    # @return [String] The text of the specified line.
    def handler_get_line(_message_id, *args)
      send_message_get_line(args[0])
    end

    # Dynamically defines a method for a Scintilla message.
    # This reduces method_missing overhead for subsequent calls.
    # @param method_s [Symbol] The method name to define.
    # @param message_name [String] The corresponding Scintilla message name.
    def define_dynamic_method(method_s, message_name)
      message_id = Scintilla.const_get(message_name)
      handler = MESSAGE_HANDLERS[message_id]
      if handler
        self.class.define_method(method_s) do |*dyn_args|
          send(handler, message_id, *dyn_args)
        end
      else
        self.class.define_method(method_s) do |*dyn_args|
          send_message(message_id, *dyn_args)
        end
      end
    end

    # Overrides the method_missing to handle undefined method calls.
    # It dynamically defines methods for Scintilla messages to improve performance.
    # @param method_s [Symbol] The missing method name.
    # @param args [Array] Arguments passed to the method.
    def method_missing(method_s, *args)
      upper_method_name = method_s.to_s.upcase
      if upper_method_name.start_with?('SCI_')
        message_name = "SCI_#{upper_method_name[4..].delete('_')}"
        if Scintilla.const_defined?(message_name)
          define_dynamic_method(method_s, message_name)
          send(method_s, *args)
        else
          super
        end
      else
        super
      end
    end

    # Checks if the method is handled by ScintillaBase.
    # Used in conjunction with method_missing to define methods dynamically.
    # @param sym [Symbol] The method name to check.
    # @param include_private [Boolean] Whether to include private methods in the check.
    # @return [Boolean] True if the method is handled, false otherwise.]]]
    def respond_to_missing?(sym, _include_private = false)
      sym.to_s.upcase.start_with?('SCI_')
    end
  end
end
