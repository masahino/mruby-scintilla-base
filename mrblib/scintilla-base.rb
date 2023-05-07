module Scintilla
  class ScintillaBase
    def method_missing(method_s, *args)
      method_name = method_s.to_s.upcase
      if method_name.start_with?('SCI_')
        message_name = "SCI_#{method_name[4..].delete('_')}"
        if Scintilla.const_defined?(message_name)
          message_id = Scintilla.const_get(message_name)
          case message_id
          when SCI_GETFOCUS, SCI_AUTOCACTIVE, SCI_GETREADONLY, SCI_CALLTIPACTIVE
            send_message(message_id, *args) != 0
          when SCI_SETTEXT, SCI_AUTOCSELECT
            send_message(message_id, 0, args[0])
          when SCI_GETTARGETTEXT, SCI_AUTOCGETCURRENTTEXT, SCI_ANNOTATIONGETTEXT, SCI_GETSELTEXT,
            SCI_GETPROPERTY, SCI_GETWORDCHARS, SCI_GETLEXERLANGUAGE, SCI_MARGINGETTEXT
            send_message_get_str(message_id, *args)
          when SCI_GETTEXT
            send_message_get_text(args[0])
          when SCI_GETTEXTRANGE
            send_message_get_text_range(message_id, *args)
          when SCI_GETCURLINE
            send_message_get_curline
          when SCI_GETLINE
            send_message_get_line(args[0])
          when SCI_GETDOCPOINTER, SCI_CREATEDOCUMENT
            send_message_get_docpointer(message_id, *args)
          when SCI_SETDOCPOINTER, SCI_ADDREFDOCUMENT, SCI_RELEASEDOCUMENT
            send_message_set_docpointer(message_id, args[0])
          when SCI_SETILEXER
            send_message_set_pointer(message_id, args[0])
          else
            send_message(message_id, *args)
          end
        else
          raise "#{message_id} unknown"
        end
      else
        super
      end
    end

    def respond_to_missing?(sym, _include_private)
      sym.to_s[0..3].upcase == 'SCI_'
    end
  end
end
