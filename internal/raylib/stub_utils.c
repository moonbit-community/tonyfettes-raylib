#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Compression & encoding
// ============================================================================

moonbit_bytes_t
moonbit_raylib_compress_data(moonbit_bytes_t data, int data_size) {
  int compDataSize = 0;
  unsigned char *compData = CompressData((const unsigned char *)data, data_size, &compDataSize);
  if (!compData) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(compDataSize, 0);
  memcpy(result, compData, compDataSize);
  RL_FREE(compData);
  return result;
}

moonbit_bytes_t
moonbit_raylib_decompress_data(moonbit_bytes_t comp_data, int comp_data_size) {
  int dataSize = 0;
  unsigned char *data = DecompressData((const unsigned char *)comp_data, comp_data_size, &dataSize);
  if (!data) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(dataSize, 0);
  memcpy(result, data, dataSize);
  RL_FREE(data);
  return result;
}

moonbit_bytes_t
moonbit_raylib_encode_data_base64(moonbit_bytes_t data, int data_size) {
  int outputSize = 0;
  char *encoded = EncodeDataBase64((const unsigned char *)data, data_size, &outputSize);
  if (!encoded) return moonbit_make_bytes(0, 0);
  // outputSize includes null terminator; we exclude it so MoonBit gets clean data
  int len = outputSize > 0 ? outputSize - 1 : 0;
  moonbit_bytes_t result = moonbit_make_bytes(len, 0);
  memcpy(result, encoded, len);
  RL_FREE(encoded);
  return result;
}

moonbit_bytes_t
moonbit_raylib_decode_data_base64(moonbit_bytes_t data) {
  int outputSize = 0;
  unsigned char *decoded = DecodeDataBase64((const unsigned char *)data, &outputSize);
  if (!decoded) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(outputSize, 0);
  memcpy(result, decoded, outputSize);
  RL_FREE(decoded);
  return result;
}

int
moonbit_raylib_compute_crc32(moonbit_bytes_t data, int data_size) {
  return (int)ComputeCRC32((unsigned char *)data, data_size);
}

moonbit_bytes_t
moonbit_raylib_compute_md5(moonbit_bytes_t data, int data_size) {
  unsigned int *hash = ComputeMD5((unsigned char *)data, data_size);
  moonbit_bytes_t result = moonbit_make_bytes(16, 0);
  memcpy(result, hash, 16);
  return result;
}

moonbit_bytes_t
moonbit_raylib_compute_sha1(moonbit_bytes_t data, int data_size) {
  unsigned int *hash = ComputeSHA1((unsigned char *)data, data_size);
  moonbit_bytes_t result = moonbit_make_bytes(20, 0);
  memcpy(result, hash, 20);
  return result;
}

// ============================================================================
// Random sequence
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_random_sequence(int count, int min, int max) {
  int *seq = LoadRandomSequence(count, min, max);
  if (!seq) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(count * sizeof(int), 0);
  memcpy(result, seq, count * sizeof(int));
  UnloadRandomSequence(seq);
  return result;
}

// ============================================================================
// Screen extras
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_screen_to_world_ray_ex(moonbit_bytes_t position, moonbit_bytes_t camera, int width, int height) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Ray ray = GetScreenToWorldRayEx(pos, cam, width, height);
  moonbit_bytes_t result = moonbit_make_bytes(sizeof(Ray), 0);
  memcpy(result, &ray, sizeof(Ray));
  return result;
}
