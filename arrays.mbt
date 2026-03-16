// Typed array wrappers for C array access

// ============================================================================
// FloatArray
// ============================================================================

///|
struct FloatArray(@ffi.FloatArray)

///|
pub fn FloatArray::from_array(data : Array[Float]) -> FloatArray {
  let count = data.length()
  let buf = @buffer.new(size_hint=count * 4)
  for f in data {
    buf.write_float_le(f)
  }
  @ffi.float_array_new(buf.to_bytes(), count)
}

///|
pub fn FloatArray::length(self : FloatArray) -> Int {
  @ffi.float_array_length(self.0)
}

///|
pub fn FloatArray::op_get(self : FloatArray, index : Int) -> Float {
  @ffi.float_array_op_get(self.0, index)
}

///|
pub fn FloatArray::op_set(self : FloatArray, index : Int, value : Float) -> Unit {
  @ffi.float_array_op_set(self.0, index, value)
}

// ============================================================================
// UByteArray
// ============================================================================

///|
struct UByteArray(@ffi.UByteArray)

///|
pub fn UByteArray::from_array(data : Array[Int]) -> UByteArray {
  let count = data.length()
  let arr = FixedArray::make(count, b'\x00')
  for i, v in data {
    arr[i] = v.to_byte()
  }
  @ffi.ubyte_array_new(FixedArray::unsafe_reinterpret_as_bytes(arr), count)
}

///|
pub fn UByteArray::length(self : UByteArray) -> Int {
  @ffi.ubyte_array_length(self.0)
}

///|
pub fn UByteArray::op_get(self : UByteArray, index : Int) -> Int {
  @ffi.ubyte_array_op_get(self.0, index)
}

///|
pub fn UByteArray::op_set(self : UByteArray, index : Int, value : Int) -> Unit {
  @ffi.ubyte_array_op_set(self.0, index, value)
}

// ============================================================================
// UShortArray
// ============================================================================

///|
struct UShortArray(@ffi.UShortArray)

///|
pub fn UShortArray::from_array(data : Array[Int]) -> UShortArray {
  let count = data.length()
  let buf = @buffer.new(size_hint=count * 2)
  for v in data {
    buf.write_byte((v & 0xFF).to_byte())
    buf.write_byte(((v >> 8) & 0xFF).to_byte())
  }
  @ffi.ushort_array_new(buf.to_bytes(), count)
}

///|
pub fn UShortArray::length(self : UShortArray) -> Int {
  @ffi.ushort_array_length(self.0)
}

///|
pub fn UShortArray::op_get(self : UShortArray, index : Int) -> Int {
  @ffi.ushort_array_op_get(self.0, index)
}

///|
pub fn UShortArray::op_set(self : UShortArray, index : Int, value : Int) -> Unit {
  @ffi.ushort_array_op_set(self.0, index, value)
}

// ============================================================================
// MatrixArray
// ============================================================================

///|
struct MatrixArray(@ffi.MatrixArray)

///|
pub fn MatrixArray::length(self : MatrixArray) -> Int {
  @ffi.matrix_array_length(self.0)
}

///|
pub fn MatrixArray::op_get(self : MatrixArray, index : Int) -> Matrix {
  Matrix::from_bytes(@ffi.matrix_array_op_get(self.0, index))
}

///|
pub fn MatrixArray::op_set(
  self : MatrixArray,
  index : Int,
  value : Matrix,
) -> Unit {
  @ffi.matrix_array_op_set(self.0, index, value.to_bytes())
}
