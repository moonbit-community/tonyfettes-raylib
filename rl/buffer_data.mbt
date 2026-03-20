// BufferData — tagged union for passing typed array data to rlgl buffer functions.
// Allows users to pass mesh data (FloatArray, UShortArray, etc.) directly
// without manual bytes conversion.

///|
/// Typed buffer data for rlgl buffer operations.
pub(all) enum BufferData {
  /// Float array data (e.g., vertex positions, normals, texcoords).
  Floats(@root.FloatArray)
  /// Unsigned short array data (e.g., vertex indices).
  UShorts(@root.UShortArray)
  /// Signed short array data.
  Shorts(@root.ShortArray)
  /// Unsigned byte array data (e.g., vertex colors).
  UBytes(@root.UByteArray)
  /// Raw byte data (e.g., user-defined structs for SSBOs).
  Raw(Bytes)
}

///|
/// Get the size of this buffer data in bytes.
pub fn BufferData::byte_size(self : BufferData) -> Int {
  match self {
    Floats(arr) => arr.length() * 4
    UShorts(arr) => arr.length() * 2
    Shorts(arr) => arr.length() * 2
    UBytes(arr) => arr.length()
    Raw(bytes) => bytes.length()
  }
}
