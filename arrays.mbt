// Typed array wrappers over #external raw C pointers

// ============================================================================
// FloatArray — wraps raw float* with length tracking
// ============================================================================

///|
struct FloatArray(@ffi.FloatArray, Int)

///|
fn FloatArray::is_null(self : FloatArray) -> Bool {
  @ffi.float_array_is_null(self.0)
}

///|
pub fn FloatArray::length(self : FloatArray) -> Int {
  self.1
}

///|
pub fn FloatArray::op_get(self : FloatArray, index : Int) -> Float {
  guard index >= 0 && index < self.1
  @ffi.float_array_get(self.0, index)
}

///|
pub fn FloatArray::op_set(
  self : FloatArray,
  index : Int,
  value : Float,
) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.float_array_set(self.0, index, value)
}

// ============================================================================
// UByteArray — wraps raw unsigned char* with length tracking
// ============================================================================

///|
struct UByteArray(@ffi.UByteArray, Int)

///|
fn UByteArray::is_null(self : UByteArray) -> Bool {
  @ffi.ubyte_array_is_null(self.0)
}

///|
pub fn UByteArray::length(self : UByteArray) -> Int {
  self.1
}

///|
pub fn UByteArray::op_get(self : UByteArray, index : Int) -> Int {
  guard index >= 0 && index < self.1
  @ffi.ubyte_array_get(self.0, index)
}

///|
pub fn UByteArray::op_set(self : UByteArray, index : Int, value : Byte) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.ubyte_array_set(self.0, index, value)
}

// ============================================================================
// UShortArray — wraps raw unsigned short* with length tracking
// ============================================================================

///|
struct UShortArray(@ffi.UShortArray, Int)

///|
fn UShortArray::is_null(self : UShortArray) -> Bool {
  @ffi.ushort_array_is_null(self.0)
}

///|
pub fn UShortArray::length(self : UShortArray) -> Int {
  self.1
}

///|
pub fn UShortArray::op_get(self : UShortArray, index : Int) -> Int {
  guard index >= 0 && index < self.1
  @ffi.ushort_array_get(self.0, index)
}

///|
pub fn UShortArray::op_set(
  self : UShortArray,
  index : Int,
  value : UInt16,
) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.ushort_array_set(self.0, index, value)
}

// ============================================================================
// MatrixArray — wraps raw Matrix* with length tracking
// ============================================================================

///|
struct MatrixArray(@ffi.MatrixArray, Int)

///|
fn MatrixArray::is_null(self : MatrixArray) -> Bool {
  @ffi.matrix_array_is_null(self.0)
}

///|
pub fn MatrixArray::length(self : MatrixArray) -> Int {
  self.1
}

///|
pub fn MatrixArray::op_get(self : MatrixArray, index : Int) -> Matrix {
  guard index >= 0 && index < self.1
  Matrix::from_bytes(@ffi.matrix_array_op_get(self.0, index))
}

///|
pub fn MatrixArray::op_set(
  self : MatrixArray,
  index : Int,
  value : Matrix,
) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.matrix_array_op_set(self.0, index, value.to_bytes())
}
