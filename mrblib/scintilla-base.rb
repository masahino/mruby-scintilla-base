module Scintilla
  class ScintillaBase
    def method_missing(method_name, *args)
      if method_name.to_s[0..3].upcase == 'SCI_'
        message_id = 'SCI_' + method_name.to_s[4..-1].gsub('_', '').upcase
        if Scintilla.const_defined?(message_id)
          send_message(Scintilla.const_get(message_id), *args)
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

    def sci_set_text(text)
      send_message(SCI_SETTEXT, 0, text)
    end

    def sci_get_focus
      ret = send_message(SCI_GETFOCUS)
      ret != 0 ? true : false
    end

    def sci_autoc_select(select)
      send_message(SCI_AUTOCSELECT, 0, select)
    end

    def sci_get_target_text
      send_message_get_str(SCI_GETTARGETTEXT)
    end

    def sci_autoc_get_current_text
      send_message_get_str(SCI_AUTOCGETCURRENTTEXT)
    end

    def sci_annotation_get_text(line)
      send_message_get_str(SCI_ANNOTATIONGETTEXT, line)
    end
  end
end
