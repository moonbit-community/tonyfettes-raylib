// Typed array wrappers over #external raw C pointers

// ============================================================================
// FloatArray — wraps raw float* with length tracking
// ============================================================================

///|
struct FloatArray(@ffi.FloatPointer, Int)

///|
fn FloatArray::is_null(self : FloatArray) -> Bool {
  @ffi.float_array_is_null(self.0)
}

///|
/// Get the raw FFI pointer for passing to low-level rlgl functions.
pub fn FloatArray::pointer(self : FloatArray) -> @ffi.FloatPointer {
  self.0
}

///|
/// Get the number of elements in this float array.
pub fn FloatArray::length(self : FloatArray) -> Int {
  self.1
}

///|
/// Allocate a zero-initialized float array with `count` elements.
/// Must be freed with `free()` when no longer needed.
pub fn FloatArray::new(count : Int) -> FloatArray {
  let ptr = @ffi.Pointer::calloc(count, 4)
  FloatArray(@ffi.FloatPointer::from_pointer(ptr), count)
}

///|
/// Free the underlying C memory. Only call on arrays created with `make()`.
pub fn FloatArray::free(self : FloatArray) -> Unit {
  self.0.to_pointer().free()
}

///|
/// Get the float value at the given index (bounds-checked).
pub fn FloatArray::op_get(self : FloatArray, index : Int) -> Float {
  guard index >= 0 && index < self.1
  @ffi.float_array_get(self.0, index)
}

///|
/// Set the float value at the given index (bounds-checked).
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
struct UByteArray(@ffi.UBytePointer, Int)

///|
fn UByteArray::is_null(self : UByteArray) -> Bool {
  @ffi.ubyte_array_is_null(self.0)
}

///|
/// Get the raw FFI pointer for passing to low-level rlgl functions.
pub fn UByteArray::pointer(self : UByteArray) -> @ffi.UBytePointer {
  self.0
}

///|
/// Get the number of elements in this unsigned byte array.
pub fn UByteArray::length(self : UByteArray) -> Int {
  self.1
}

///|
/// Allocate a zero-initialized unsigned byte array with `count` elements.
/// Must be freed with `free()` when no longer needed.
pub fn UByteArray::new(count : Int) -> UByteArray {
  let ptr = @ffi.Pointer::calloc(count, 1)
  UByteArray(@ffi.UBytePointer::from_pointer(ptr), count)
}

///|
/// Free the underlying C memory. Only call on arrays created with `make()`.
pub fn UByteArray::free(self : UByteArray) -> Unit {
  self.0.to_pointer().free()
}

///|
/// Get the unsigned byte value at the given index (bounds-checked).
pub fn UByteArray::op_get(self : UByteArray, index : Int) -> Int {
  guard index >= 0 && index < self.1
  @ffi.ubyte_array_get(self.0, index)
}

///|
/// Set the unsigned byte value at the given index (bounds-checked).
pub fn UByteArray::op_set(self : UByteArray, index : Int, value : Byte) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.ubyte_array_set(self.0, index, value)
}

// ============================================================================
// ShortArray — wraps raw short* with length tracking
// ============================================================================

///|
struct ShortArray(@ffi.ShortPointer, Int)

///|
/// Get the raw FFI pointer for passing to low-level rlgl functions.
pub fn ShortArray::pointer(self : ShortArray) -> @ffi.ShortPointer {
  self.0
}

///|
/// Get the number of elements in this short array.
pub fn ShortArray::length(self : ShortArray) -> Int {
  self.1
}

///|
/// Allocate a zero-initialized short array with `count` elements.
/// Must be freed with `free()` when no longer needed.
pub fn ShortArray::new(count : Int) -> ShortArray {
  let ptr = @ffi.Pointer::calloc(count, 2)
  ShortArray(@ffi.ShortPointer::from_pointer(ptr), count)
}

///|
/// Free the underlying C memory. Only call on arrays created with `make()`.
pub fn ShortArray::free(self : ShortArray) -> Unit {
  self.0.to_pointer().free()
}

///|
/// Get the signed short value at the given index (bounds-checked).
pub fn ShortArray::op_get(self : ShortArray, index : Int) -> Int {
  guard index >= 0 && index < self.1
  @ffi.short_array_get(self.0, index)
}

///|
/// Set the signed short value at the given index (bounds-checked, truncated to 16-bit).
pub fn ShortArray::op_set(self : ShortArray, index : Int, value : Int) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.short_array_set(self.0, index, value)
}

// ============================================================================
// UShortArray — wraps raw unsigned short* with length tracking
// ============================================================================

///|
struct UShortArray(@ffi.UShortPointer, Int)

///|
fn UShortArray::is_null(self : UShortArray) -> Bool {
  @ffi.ushort_array_is_null(self.0)
}

///|
/// Get the raw FFI pointer for passing to low-level rlgl functions.
pub fn UShortArray::pointer(self : UShortArray) -> @ffi.UShortPointer {
  self.0
}

///|
/// Get the number of elements in this unsigned short array.
pub fn UShortArray::length(self : UShortArray) -> Int {
  self.1
}

///|
/// Allocate a zero-initialized unsigned short array with `count` elements.
/// Must be freed with `free()` when no longer needed.
pub fn UShortArray::new(count : Int) -> UShortArray {
  let ptr = @ffi.Pointer::calloc(count, 2)
  UShortArray(@ffi.UShortPointer::from_pointer(ptr), count)
}

///|
/// Free the underlying C memory. Only call on arrays created with `make()`.
pub fn UShortArray::free(self : UShortArray) -> Unit {
  self.0.to_pointer().free()
}

///|
/// Get the unsigned short value at the given index (bounds-checked).
pub fn UShortArray::op_get(self : UShortArray, index : Int) -> Int {
  guard index >= 0 && index < self.1
  @ffi.ushort_array_get(self.0, index)
}

///|
/// Set the unsigned short value at the given index (bounds-checked).
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
/// Get the number of elements in this matrix array.
pub fn MatrixArray::length(self : MatrixArray) -> Int {
  self.1
}

///|
/// Get the Matrix value at the given index (bounds-checked).
pub fn MatrixArray::op_get(self : MatrixArray, index : Int) -> Matrix {
  guard index >= 0 && index < self.1
  Matrix::from_bytes(@ffi.matrix_array_op_get(self.0, index))
}

///|
/// Set the Matrix value at the given index (bounds-checked).
pub fn MatrixArray::op_set(
  self : MatrixArray,
  index : Int,
  value : Matrix,
) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.matrix_array_op_set(self.0, index, value.to_bytes())
}
