module Scintilla
  class ScintillaTest < ScintillaBase
    attr_reader :last_message

    def initialize
      super
      @last_message = 0
    end

    def send_message(message, *_args)
      @last_message = message
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
