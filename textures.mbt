// Texture-related constants and non-method utilities

// ============================================================================
// Texture filter constants
// ============================================================================

///|
pub const TextureFilterPoint : Int = 0

///|
pub const TextureFilterBilinear : Int = 1

///|
pub const TextureFilterTrilinear : Int = 2

///|
pub const TextureFilterAnisotropic4x : Int = 3

///|
pub const TextureFilterAnisotropic8x : Int = 4

///|
pub const TextureFilterAnisotropic16x : Int = 5

// ============================================================================
// Texture wrap constants
// ============================================================================

///|
pub const TextureWrapRepeat : Int = 0

///|
pub const TextureWrapClamp : Int = 1

///|
pub const TextureWrapMirrorRepeat : Int = 2

///|
pub const TextureWrapMirrorClamp : Int = 3

// ============================================================================
// Pixel format constants
// ============================================================================

///|
pub const PixelformatUncompressedGrayscale : Int = 1

///|
pub const PixelformatUncompressedGrayAlpha : Int = 2

///|
pub const PixelformatUncompressedR5g6b5 : Int = 3

///|
pub const PixelformatUncompressedR8g8b8 : Int = 4

///|
pub const PixelformatUncompressedR5g5b5a1 : Int = 5

///|
pub const PixelformatUncompressedR4g4b4a4 : Int = 6

///|
pub const PixelformatUncompressedR8g8b8a8 : Int = 7

///|
pub const PixelformatUncompressedR32 : Int = 8

///|
pub const PixelformatUncompressedR32g32b32 : Int = 9

///|
pub const PixelformatUncompressedR32g32b32a32 : Int = 10

// ============================================================================
// Texture management extras (non-method utilities)
// ============================================================================

///|
pub fn get_shapes_texture_rectangle() -> Rectangle {
  Rectangle::from_bytes(@ffi.get_shapes_texture_rectangle())
}

// ============================================================================
// Cubemap layout constants
// ============================================================================

///|
pub const CubemapLayoutAutoDetect : Int = 0

///|
pub const CubemapLayoutLineVertical : Int = 1

///|
pub const CubemapLayoutLineHorizontal : Int = 2

///|
pub const CubemapLayoutCrossThreeByFour : Int = 3

///|
pub const CubemapLayoutCrossFourByThree : Int = 4
