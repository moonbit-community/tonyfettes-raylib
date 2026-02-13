// Re-export opaque types for drawing
///|
pub using @raylib {type Shader, type RenderTexture}

// Drawing lifecycle re-exports

///|
pub using @raylib {
  begin_drawing,
  end_drawing,
  begin_scissor_mode,
  end_scissor_mode,
  begin_blend_mode,
  end_blend_mode,
  begin_texture_mode,
  end_texture_mode,
}

// Drawing wrapper

///|
pub fn clear_background(color : Color) -> Unit {
  @raylib.clear_background(color.to_bytes())
}

// Blend mode constants

///|
pub const BlendAlpha : Int = 0

///|
pub const BlendAdditive : Int = 1

///|
pub const BlendMultiplied : Int = 2
