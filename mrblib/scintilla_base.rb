module Scintilla
  # ScintillaBase
  class ScintillaBase
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

    def handler_bool(message_id, *args)
      send_message(message_id, *args) != 0
    end

    def handler_2nd_arg(message_id, *args)
      send_message(message_id, 0, args[0])
    end

    def handler_get_curline(_message_id, *_args)
      send_message_get_curline
    end

    def handler_get_line(_message_id, *args)
      send_message_get_line(args[0])
    end

    def method_missing(method_s, *args)
      method_name = method_s.to_s.upcase
      if method_name.start_with?('SCI_')
        message_name = "SCI_#{method_name[4..].delete('_')}"
        if Scintilla.const_defined?(message_name)
          message_id = Scintilla.const_get(message_name)
          handler = MESSAGE_HANDLERS[message_id]
          if handler
            send(handler, message_id, *args)
          else
            send_message(message_id, *args)
          end
        else
          raise "#{message_name} unknown"
        end
      else
        super
      end
    end

    def respond_to_missing?(sym, _include_private)
      sym.to_s.upcase.start_with?('SCI_')
    end
  end
end
