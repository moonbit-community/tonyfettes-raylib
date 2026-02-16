// ============================================================================
// Compression & encoding
// ============================================================================

///|
pub fn compress_data(data : Bytes) -> Bytes {
  @raylib.compress_data(data, data.length())
}

///|
pub fn decompress_data(comp_data : Bytes) -> Bytes {
  @raylib.decompress_data(comp_data, comp_data.length())
}

///|
pub fn encode_data_base64(data : Bytes) -> String {
  @utf8.decode_lossy(@raylib.encode_data_base64(data, data.length()))
}

///|
pub fn decode_data_base64(data : String) -> Bytes {
  @raylib.decode_data_base64(@utf8.encode(data))
}

///|
pub fn compute_crc32(data : Bytes) -> Int {
  @raylib.compute_crc32(data, data.length())
}

///|
pub fn compute_md5(data : Bytes) -> Bytes {
  @raylib.compute_md5(data, data.length())
}

///|
pub fn compute_sha1(data : Bytes) -> Bytes {
  @raylib.compute_sha1(data, data.length())
}

// ============================================================================
// Random sequence
// ============================================================================

///|
pub fn load_random_sequence(count : Int, min : Int, max : Int) -> Array[Int] {
  let bytes = @raylib.load_random_sequence(count, min, max)
  let result = Array::make(count, 0)
  for i in 0..<count {
    result[i] = read_int(bytes, i * 4)
  }
  result
}
