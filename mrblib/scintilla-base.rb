module Scintilla
  class ScintillaBase
    def method_missing(method_name, *args)
      if method_name.to_s[0..3].upcase == "SCI_"
        message_id = "Scintilla::SCI_"+method_name.to_s[4..-1].gsub("_", "").upcase
        send_message(eval(message_id), *args)
      else
        $stderr.puts "method missing #{method_name}"
      end
    end
    
    def sci_set_text(text)
      self.send_message(SCI_SETTEXT, 0, text)
    end
    
    def sci_get_focus()
      ret = send_message(SCI_GETFOCUS)
      return ( ret != 0 )? true : false
    end
    
    def sci_autoc_select(select)
      self.send_message(SCI_AUTOCSELECT, 0, select)
    end

    def sci_get_target_text()
      self.send_message_get_str(SCI_GETTARGETTEXT)
    end

    def sci_autoc_get_current_text()
      self.send_message_get_str(SCI_AUTOCGETCURRENTTEXT)
    end

    def sci_annotation_get_text(line)
      self.send_message_get_str(SCI_ANNOTATIONGETTEXT, line)
    end
  end
end
