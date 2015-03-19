module Scintilla
  class ScintillaBase
    def method_missing(method_name, *args)
      message_id = "SCI_"+method_name.to_s.gsub("_", "").upcase
      send_message(eval(message_id), *args)
    end
    
    def set_text(text)
      self.send_message(SCI_SETTEXT, 0, text)
    end
    
    def get_focus()
      ret = send_message(SCI_GETFOCUS)
      return ( ret != 0 )? true : false
    end
    
    def autoc_select(select)
      self.send_message(SCI_AUTOCSELECT, 0, select)
    end
  end
end
