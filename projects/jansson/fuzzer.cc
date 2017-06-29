#include <stdint.h>
#include "jansson.h"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  json_t *root;
  json_error_t error;
  const char *json = reinterpret_cast<const char *>(data);
  root = json_loadb(json, size, 0, &error);
  if (root) {
    json_decref(root);
  }

  return 0;
}
