module Scintilla
  class ScintillaBase
    def method_missing(method_name, *args)
      if method_name.to_s[0..3].upcase == 'SCI_'
        message_id = 'SCI_' + method_name.to_s[4..-1].gsub('_', '').upcase
        if Scintilla.const_defined?(message_id)
          case message_id
          when 'SCI_GETFOCUS'
            send_message(Scintilla.const_get(message_id), *args) != 0 ? true : false
          when 'SCI_SETTEXT', 'SCI_AUTOCSELECT'
            send_message(Scintilla.const_get(message_id), 0, args[0])
          when 'SCI_GETTARGETTEXT', 'SCI_AUTOCGETCURRENTTEXT', 'SCI_ANNOTATIONGETTEXT', 'SCI_GETTEXT'
            send_message_get_str(Scintilla.const_get(message_id), *args)
          when 'SCI_GETCURLINE'
            send_message_get_curline()
          else
            send_message(Scintilla.const_get(message_id), *args)
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

    def sci_get_focusx
      ret = send_message(SCI_GETFOCUS)
      ret != 0 ? true : false
    end
  end
end
