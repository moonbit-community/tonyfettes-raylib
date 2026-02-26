// ============================================================================
// Compression & encoding
// ============================================================================

///|
pub fn compress_data(data : Bytes) -> Bytes {
  @ffi.compress_data(data, data.length())
}

///|
pub fn decompress_data(comp_data : Bytes) -> Bytes {
  @ffi.decompress_data(comp_data, comp_data.length())
}

///|
pub fn encode_data_base64(data : Bytes) -> String {
  @utf8.decode_lossy(@ffi.encode_data_base64(data, data.length()))
}

///|
pub fn decode_data_base64(data : String) -> Bytes {
  @ffi.decode_data_base64(@utf8.encode(data))
}

///|
pub fn compute_crc32(data : Bytes) -> Int {
  @ffi.compute_crc32(data, data.length())
}

///|
pub fn compute_md5(data : Bytes) -> Bytes {
  @ffi.compute_md5(data, data.length())
}

///|
pub fn compute_sha1(data : Bytes) -> Bytes {
  @ffi.compute_sha1(data, data.length())
}

// ============================================================================
// Random sequence
// ============================================================================

///|
pub fn load_random_sequence(count : Int, min : Int, max : Int) -> Array[Int] {
  let bytes = @ffi.load_random_sequence(count, min, max)
  let result = Array::make(count, 0)
  for i in 0..<count {
    result[i] = read_int(bytes, i * 4)
  }
  result
}
