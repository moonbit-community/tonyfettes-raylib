// Texture-related constants and non-method utilities

// ============================================================================
// Texture filter constants
// ============================================================================

///|
/// Texture filter: no filter, just pixel approximation.
pub const TextureFilterPoint : Int = 0

///|
/// Texture filter: linear filtering.
pub const TextureFilterBilinear : Int = 1

///|
/// Texture filter: trilinear filtering (linear with mipmaps).
pub const TextureFilterTrilinear : Int = 2

///|
/// Texture filter: anisotropic filtering 4x.
pub const TextureFilterAnisotropic4x : Int = 3

///|
/// Texture filter: anisotropic filtering 8x.
pub const TextureFilterAnisotropic8x : Int = 4

///|
/// Texture filter: anisotropic filtering 16x.
pub const TextureFilterAnisotropic16x : Int = 5

// ============================================================================
// Texture wrap constants
// ============================================================================

///|
/// Texture wrap: repeats texture in tiled mode.
pub const TextureWrapRepeat : Int = 0

///|
/// Texture wrap: clamps texture to edge pixel in tiled mode.
pub const TextureWrapClamp : Int = 1

///|
/// Texture wrap: mirrors and repeats the texture in tiled mode.
pub const TextureWrapMirrorRepeat : Int = 2

///|
/// Texture wrap: mirrors and clamps to border the texture in tiled mode.
pub const TextureWrapMirrorClamp : Int = 3

// ============================================================================
// Pixel format constants
// ============================================================================

///|
/// Pixel format: 8 bit per pixel (no alpha).
pub const PixelformatUncompressedGrayscale : Int = 1

///|
/// Pixel format: 8*2 bpp (2 channels).
pub const PixelformatUncompressedGrayAlpha : Int = 2

///|
/// Pixel format: 16 bpp.
pub const PixelformatUncompressedR5g6b5 : Int = 3

///|
/// Pixel format: 24 bpp.
pub const PixelformatUncompressedR8g8b8 : Int = 4

///|
/// Pixel format: 16 bpp (1 bit alpha).
pub const PixelformatUncompressedR5g5b5a1 : Int = 5

///|
/// Pixel format: 16 bpp (4 bit alpha).
pub const PixelformatUncompressedR4g4b4a4 : Int = 6

///|
/// Pixel format: 32 bpp.
pub const PixelformatUncompressedR8g8b8a8 : Int = 7

///|
/// Pixel format: 32 bpp (1 channel - float).
pub const PixelformatUncompressedR32 : Int = 8

///|
/// Pixel format: 32*3 bpp (3 channels - float).
pub const PixelformatUncompressedR32g32b32 : Int = 9

///|
/// Pixel format: 32*4 bpp (4 channels - float).
pub const PixelformatUncompressedR32g32b32a32 : Int = 10

// ============================================================================
// Texture management extras (non-method utilities)
// ============================================================================

///|
/// Get texture source rectangle that is used for shapes drawing.
pub fn get_shapes_texture_rectangle() -> Rectangle {
  Rectangle::from_bytes(@ffi.get_shapes_texture_rectangle())
}

// ============================================================================
// Cubemap layout constants
// ============================================================================

///|
/// Cubemap layout: automatically detect layout type.
pub const CubemapLayoutAutoDetect : Int = 0

///|
/// Cubemap layout: layout is defined by a vertical line with faces.
pub const CubemapLayoutLineVertical : Int = 1

///|
/// Cubemap layout: layout is defined by a horizontal line with faces.
pub const CubemapLayoutLineHorizontal : Int = 2

///|
/// Cubemap layout: layout is defined by a 3x4 cross with cubemap faces.
pub const CubemapLayoutCrossThreeByFour : Int = 3

///|
/// Cubemap layout: layout is defined by a 4x3 cross with cubemap faces.
pub const CubemapLayoutCrossFourByThree : Int = 4
