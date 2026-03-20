// Buffer trait — provides a unified interface for passing typed array data
// to rlgl buffer operations without manual bytes conversion.

///|
/// Trait for types that can be passed as buffer data to rlgl operations.
/// Implementors must provide a raw void pointer and byte size.
///
/// Safety: `as_pointer` returns a raw pointer that is only valid during the
/// current FFI call. Do not store the pointer across allocation points.
pub(open) trait Buffer {
  as_pointer(Self) -> @raylib.VoidPointer
  byte_size(Self) -> Int
}

///|
pub impl Buffer for @root.FloatArray with as_pointer(self) {
  @raylib.float_pointer_as_void(self.raw())
}

///|
pub impl Buffer for @root.FloatArray with byte_size(self) {
  self.length() * 4
}

///|
pub impl Buffer for @root.UShortArray with as_pointer(self) {
  @raylib.ushort_pointer_as_void(self.raw())
}

///|
pub impl Buffer for @root.UShortArray with byte_size(self) {
  self.length() * 2
}

///|
pub impl Buffer for @root.ShortArray with as_pointer(self) {
  @raylib.short_pointer_as_void(self.raw())
}

///|
pub impl Buffer for @root.ShortArray with byte_size(self) {
  self.length() * 2
}

///|
pub impl Buffer for @root.UByteArray with as_pointer(self) {
  @raylib.ubyte_pointer_as_void(self.raw())
}

///|
pub impl Buffer for @root.UByteArray with byte_size(self) {
  self.length()
}

///|
pub impl Buffer for Bytes with as_pointer(self) {
  @raylib.bytes_as_void(self)
}

///|
pub impl Buffer for Bytes with byte_size(self) {
  self.length()
}
