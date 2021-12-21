module Scintilla
  class ScintillaTest < ScintillaBase
    attr_reader :last_message, :last_wparam, :last_lparam, :method_name
    attr_accessor :ret_val

    def initialize
      super
      @last_message = 0
      @last_wparam = nil
      @last_lparam = nil
      @get_str = false
      @ret_val = nil
    end

    def send_message(message, *args)
      @method_name = __method__
      @last_message = message
      @last_wparam = args[0]
      @last_lparam = args[1]
      @ret_val
    end

    def send_message_get_str(message, *args)
      @method_name = __method__
      @last_message = message
      @last_wparam = args[0]
      @last_lparam = args[1]
    end

    def send_message_get_text(wparam)
      @method_name = __method__
      @last_message = 0
      @last_wparam = wparam
      @last_lparam = nil
    end

    def send_message_get_curline
      @method_name = __method__
      @last_message = 0
      @last_wparam = nil
      @last_lparam = nil
    end

    def send_message_get_line(wparam)
      @method_name = __method__
      @last_message = 0
      @last_wparam = wparam
      @last_lparam = nil
    end
  end
end

assert('Scintilla::ScintillaBase#method_missing') do
  st = Scintilla::ScintillaTest.new
  st.sci_set_save_point
  assert_equal Scintilla::SCI_SETSAVEPOINT, st.last_message
  st.Sci_ClearAll
  assert_equal Scintilla::SCI_CLEARALL, st.last_message
  assert_raise(NoMethodError) { st.hogehoge }
  assert_raise(RuntimeError) { st.sci_hogehoge }
  assert_raise(NoMethodError) { st.xxx_sci_hogehoge }
end

assert('Scintilla::ScintillaBase#respond_to') do
  st = Scintilla::ScintillaTest.new
  assert_equal true, st.respond_to?(:sci_get_focus)
  assert_equal true, st.respond_to?(:sci_set_save_point)
  assert_equal false, st.respond_to?(:hogehoge)
end

assert('SCI_GETFOCUS') do
  st = Scintilla::ScintillaTest.new
  st.ret_val = 0
  assert_equal false, st.sci_get_focus
  assert_equal Scintilla::SCI_GETFOCUS, st.last_message
  st.ret_val = 1
  assert_equal true, st.sci_get_focus
  assert_equal Scintilla::SCI_GETFOCUS, st.last_message
end

assert('SCI_SETTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_set_text('hoge')
  assert_equal Scintilla::SCI_SETTEXT, st.last_message
  assert_equal 0, st.last_wparam
  assert_equal 'hoge', st.last_lparam
  st.SCI_SETTEXT('huga')
  assert_equal Scintilla::SCI_SETTEXT, st.last_message
  assert_equal 0, st.last_wparam
  assert_equal 'huga', st.last_lparam
end

assert('SCI_AUTOCSELECT') do
  st = Scintilla::ScintillaTest.new
  st.sci_autoc_select(2)
  assert_equal Scintilla::SCI_AUTOCSELECT, st.last_message
  assert_equal 0, st.last_wparam
  assert_equal 2, st.last_lparam
  st.SCI_autocselect(23)
  assert_equal Scintilla::SCI_AUTOCSELECT, st.last_message
  assert_equal 0, st.last_wparam
  assert_equal 23, st.last_lparam
end

assert('SCI_GETTARGETTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_get_target_text
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETTARGETTEXT, st.last_message
  st.sci_get_targettext
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETTARGETTEXT, st.last_message
end

assert('SCI_AUTOCGETCURRENTTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_autoc_get_current_text
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_AUTOCGETCURRENTTEXT, st.last_message
  st.sci_AUTOC_getcurrenttext
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_AUTOCGETCURRENTTEXT, st.last_message
end

assert('SCI_ANNOTATIONGETTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_annotation_get_text(1)
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_ANNOTATIONGETTEXT, st.last_message
  assert_equal 1, st.last_wparam
  st.sci_annotation_gettext(99)
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_ANNOTATIONGETTEXT, st.last_message
  assert_equal 99, st.last_wparam
end

assert('SCI_GETCURLINE') do
  st = Scintilla::ScintillaTest.new
  st.sci_get_curline
  assert_equal :send_message_get_curline, st.method_name
  assert_equal 0, st.last_message
  st.sci_GETCURLINE
  assert_equal :send_message_get_curline, st.method_name
  assert_equal 0, st.last_message
end

assert('SCI_GETTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_get_text(123)
  assert_equal :send_message_get_text, st.method_name
  assert_equal 0, st.last_message
  assert_equal 123, st.last_wparam
  st.SCI_GETTEXT(5)
  assert_equal :send_message_get_text, st.method_name
  assert_equal 0, st.last_message
  assert_equal 5, st.last_wparam
end

assert('SCI_GETSELTEXT') do
  st = Scintilla::ScintillaTest.new
  st.sci_get_seltext
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETSELTEXT, st.last_message
  st.SCI_GETSELTEXT
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETSELTEXT, st.last_message
end

assert('SCI_GETPROPERTY') do
  st = Scintilla::ScintillaTest.new
  st.sci_get_property('hoge')
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETPROPERTY, st.last_message
  assert_equal 'hoge', st.last_wparam
  st.SCI_GETPROPERTY('huga')
  assert_equal :send_message_get_str, st.method_name
  assert_equal Scintilla::SCI_GETPROPERTY, st.last_message
  assert_equal 'huga', st.last_wparam
end

assert('SCI_GETLINE') do
  st = Scintilla::ScintillaTest.new
  st.sci_getline(1)
  assert_equal :send_message_get_line, st.method_name
  assert_equal 0, st.last_message
  assert_equal 1, st.last_wparam
  st.SCI_GETLINE(222)
  assert_equal :send_message_get_line, st.method_name
  assert_equal 0, st.last_message
  assert_equal 222, st.last_wparam
end
