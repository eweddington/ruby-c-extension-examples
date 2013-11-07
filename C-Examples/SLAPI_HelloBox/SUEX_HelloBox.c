#include "RubyUtils.h"

// This is needed because SLAPI uses bool but doesn't include this header.
#include <stdbool.h>

#include <slapi/slapi.h>
#include <slapi/geometry.h>
#include <slapi/initialize.h>
#include <slapi/model/model.h>
#include <slapi/model/entities.h>
#include <slapi/model/face.h>
#include <slapi/model/edge.h>
#include <slapi/model/vertex.h>


static int hello_box(const char* file_path) {
  // Always initialize the API before using it
  SUInitialize();
  // Create an empty model
  SUModelRef model = SU_INVALID;
  enum SUResult res = SUModelCreate(&model);
  // It's best to always check the return code from each SU function call.
  // Only showing this check once to keep this example short.
  if (res != SU_ERROR_NONE)
    return res;
  // Get the entity container of the model
  SUEntitiesRef entities = SU_INVALID;
  SUModelGetEntities(model, &entities);
  // Create a loop input describing the vertex ordering for a face's outer loop
  SULoopInputRef outer_loop = SU_INVALID;
  SULoopInputCreate(&outer_loop);
  for (size_t i = 0; i < 4; ++i) {
    SULoopInputAddVertexIndex(outer_loop, i);
  }
  // Create the face
  SUFaceRef face = SU_INVALID;
  struct SUPoint3D vertices[4] = { { 0,   0,   0 },
                            { 100, 100, 0 },
                            { 100, 100, 100 },
                            { 0,   0,   100 } };
  SUFaceCreate(&face, vertices, &outer_loop);
  // Add the face to the entities
  SUEntitiesAddFaces(entities, 1, &face);
  // Save the in-memory model to a file
  res = SUModelSaveToFile(model, file_path);
  // Must release the model or there will be memory leaks
  SUModelRelease(&model);
  // Always terminate the API when done using it
  SUTerminate();
  return res;
}

static VALUE _wrap_hello_box(VALUE self, VALUE ruby_path) {
  const char* file_path = StringValueCStr(ruby_path);
  int result = hello_box(file_path);
  return INT2NUM(result);
}

// Load this module from Ruby using:
//   require 'SUEX_HelloWorld'
void Init_SUEX_HelloBox() {
  VALUE mSUEX_HelloBox = rb_define_module("SUEX_HelloBox");
  rb_define_const(mSUEX_HelloBox, "CEXT_VERSION", RubyUTF8String("1.0.0"));
  rb_define_module_function(mSUEX_HelloBox, "hello_box", _wrap_hello_box, 1);
}
