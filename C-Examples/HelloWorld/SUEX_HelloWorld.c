#include "RubyUtils.h"


static VALUE hello_world() {
  return RubyUTF8String("Hello World!");
}

// Load this module from Ruby using:
//   require 'SUEX_HelloWorld'
void Init_SUEX_HelloWorld()
{
  VALUE mSUEX_HelloWorld = rb_define_module("SUEX_HelloWorld");
  rb_define_const(mSUEX_HelloWorld, "CEXT_VERSION", RubyUTF8String("1.0.0"));
  rb_define_module_function(mSUEX_HelloWorld, "hello_world", hello_world, 0);
}
