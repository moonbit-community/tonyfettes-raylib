// ============================================================================
// Compression & encoding
// ============================================================================

///|
/// Compress data (DEFLATE algorithm).
pub fn compress_data(data : Bytes) -> Bytes {
  @ffi.compress_data(data, data.length())
}

///|
/// Decompress data (DEFLATE algorithm).
pub fn decompress_data(comp_data : Bytes) -> Bytes {
  @ffi.decompress_data(comp_data, comp_data.length())
}

///|
/// Encode data to Base64 string.
pub fn encode_data_base64(data : Bytes) -> String {
  @utf8.decode_lossy(@ffi.encode_data_base64(data, data.length()))
}

///|
/// Decode Base64 string data.
pub fn decode_data_base64(data : String) -> Bytes {
  @ffi.decode_data_base64(@utf8.encode(data))
}

///|
/// Compute CRC32 hash code.
pub fn compute_crc32(data : Bytes) -> Int {
  @ffi.compute_crc32(data, data.length())
}

///|
/// Compute MD5 hash code, returns 16 bytes.
pub fn compute_md5(data : Bytes) -> Bytes {
  @ffi.compute_md5(data, data.length())
}

///|
/// Compute SHA1 hash code, returns 20 bytes.
pub fn compute_sha1(data : Bytes) -> Bytes {
  @ffi.compute_sha1(data, data.length())
}

// ============================================================================
// Random sequence
// ============================================================================

///|
/// Load random values sequence, no values repeated.
pub fn load_random_sequence(count : Int, min : Int, max : Int) -> Array[Int] {
  let bytes = @ffi.load_random_sequence(count, min, max)
  let result = Array::make(count, 0)
  for i in 0..<count {
    result[i] = read_int(bytes, i * 4)
  }
  result
}
