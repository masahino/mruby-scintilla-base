module Scintilla
  class ScintillaBase
    def method_missing(method_name, *args)
      if method_name.to_s[0..3].upcase == "SCI_"
        message_id = "SCI_"+method_name.to_s[4..-1].gsub("_", "").upcase
        send_message(eval(message_id), *args)
      else
        $stderr.puts "method missing #{method_name}"
        super
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
  end
end
