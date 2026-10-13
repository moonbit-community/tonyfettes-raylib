// ============================================================================
// Compression & encoding
// ============================================================================

///|
#borrow(data)
pub extern "c" fn compress_data(data : Bytes, data_size : Int32) -> Bytes = "moonbit_raylib_compress_data"

///|
#borrow(comp_data)
pub extern "c" fn decompress_data(
  comp_data : Bytes,
  comp_data_size : Int32,
) -> Bytes = "moonbit_raylib_decompress_data"

///|
#borrow(data)
pub extern "c" fn encode_data_base64(data : Bytes, data_size : Int32) -> Bytes = "moonbit_raylib_encode_data_base64"

///|
#borrow(data)
pub extern "c" fn decode_data_base64(data : Bytes) -> Bytes = "moonbit_raylib_decode_data_base64"

///|
#borrow(data)
pub extern "c" fn compute_crc32(data : Bytes, data_size : Int32) -> Int32 = "moonbit_raylib_compute_crc32"

///|
#borrow(data)
pub extern "c" fn compute_md5(data : Bytes, data_size : Int32) -> Bytes = "moonbit_raylib_compute_md5"

///|
#borrow(data)
pub extern "c" fn compute_sha1(data : Bytes, data_size : Int32) -> Bytes = "moonbit_raylib_compute_sha1"

// ============================================================================
// Random sequence
// ============================================================================

///|
pub extern "c" fn load_random_sequence(
  count : Int32,
  min : Int32,
  max : Int32,
) -> Bytes = "moonbit_raylib_load_random_sequence"
