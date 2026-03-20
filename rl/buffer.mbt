// Buffer — tagged union for passing typed array data to rlgl buffer operations
// without manual bytes conversion. Only non-GC array types are accepted.

///|
/// Typed buffer data for rlgl buffer operations.
pub(all) enum Buffer {
  /// Float array data (e.g., vertex positions, normals, texcoords).
  FloatArray(@root.FloatArray)
  /// Unsigned short array data (e.g., vertex indices).
  UShortArray(@root.UShortArray)
  /// Signed short array data.
  ShortArray(@root.ShortArray)
  /// Unsigned byte array data (e.g., vertex colors).
  UByteArray(@root.UByteArray)
}

///|
/// Get the raw pointer for FFI use.
pub fn Buffer::to_pointer(self : Buffer) -> @raylib.Pointer {
  match self {
    FloatArray(arr) => arr.pointer().to_pointer()
    UShortArray(arr) => arr.pointer().to_pointer()
    ShortArray(arr) => arr.pointer().to_pointer()
    UByteArray(arr) => arr.pointer().to_pointer()
  }
}

///|
/// Get the size of this buffer data in bytes.
pub fn Buffer::byte_size(self : Buffer) -> Int {
  match self {
    FloatArray(arr) => arr.length() * 4
    UShortArray(arr) => arr.length() * 2
    ShortArray(arr) => arr.length() * 2
    UByteArray(arr) => arr.length()
  }
}
