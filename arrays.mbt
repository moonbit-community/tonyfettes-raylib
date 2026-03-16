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
  @ffi.float_array_get(self.0, index)
}

///|
pub fn FloatArray::op_set(
  self : FloatArray,
  index : Int,
  value : Float,
) -> Unit {
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
  @ffi.ubyte_array_get(self.0, index)
}

///|
pub fn UByteArray::op_set(self : UByteArray, index : Int, value : Int) -> Unit {
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
  @ffi.ushort_array_get(self.0, index)
}

///|
pub fn UShortArray::op_set(
  self : UShortArray,
  index : Int,
  value : Int,
) -> Unit {
  @ffi.ushort_array_set(self.0, index, value)
}

// ============================================================================
// MatrixArray — GC-managed view into parent's Matrix* array
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
