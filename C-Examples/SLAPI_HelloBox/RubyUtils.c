#include "RubyUtils.h"


static int enc_utf8_index = -1;

VALUE RubyUTF8String(const char* string) {
  VALUE ruby_string = rb_str_new2(string);
  // Mark all strings as UTF-8 encoded Ruby 2.0 generally expects strings to be
  // Encoded UTF-8.
  // Looking at rb_obj_encoding it appear that negative indexes are invalid so
  // we use this to indicate uninitialized encoding index. This is done to avoid
  // Looking up the index everytime we return a string.
  if (enc_utf8_index < 0)
    enc_utf8_index = rb_enc_find_index("UTF-8");
  rb_enc_associate_index(ruby_string, enc_utf8_index);
  return ruby_string;
}
