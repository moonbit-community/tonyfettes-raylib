// Color: 4 bytes (r, g, b, a)

///|
/// Color, 4 components, R8G8B8A8 (32bit).
pub struct Color {
  r : Byte
  g : Byte
  b : Byte
  a : Byte
} derive(Eq, Show)

///|
/// Create a new Color from RGBA components.
pub fn Color::new(r : Int, g : Int, b : Int, a : Int) -> Color {
  { r: r.to_byte(), g: g.to_byte(), b: b.to_byte(), a: a.to_byte() }
}

///|
/// Serialize Color to bytes.
pub fn Color::to_bytes(color : Color) -> Bytes {
  [color.r, color.g, color.b, color.a]
}

///|
/// Deserialize Color from bytes.
pub fn Color::from_bytes(b : Bytes) -> Color {
  { r: b[0], g: b[1], b: b[2], a: b[3] }
}

// Color constants

///|
/// Light gray color.
pub let lightgray : Color = { r: b'\xC8', g: b'\xC8', b: b'\xC8', a: b'\xFF' }

///|
/// Gray color.
pub let gray : Color = { r: b'\x82', g: b'\x82', b: b'\x82', a: b'\xFF' }

///|
/// Dark gray color.
pub let darkgray : Color = { r: b'\x50', g: b'\x50', b: b'\x50', a: b'\xFF' }

///|
/// Yellow color.
pub let yellow : Color = { r: b'\xFD', g: b'\xF9', b: b'\x00', a: b'\xFF' }

///|
/// Gold color.
pub let gold : Color = { r: b'\xFF', g: b'\xCB', b: b'\x00', a: b'\xFF' }

///|
/// Orange color.
pub let orange : Color = { r: b'\xFF', g: b'\xA1', b: b'\x00', a: b'\xFF' }

///|
/// Pink color.
pub let pink : Color = { r: b'\xFF', g: b'\x6D', b: b'\xC2', a: b'\xFF' }

///|
/// Red color.
pub let red : Color = { r: b'\xE6', g: b'\x29', b: b'\x37', a: b'\xFF' }

///|
/// Maroon color.
pub let maroon : Color = { r: b'\xBE', g: b'\x21', b: b'\x37', a: b'\xFF' }

///|
/// Green color.
pub let green : Color = { r: b'\x00', g: b'\xE4', b: b'\x30', a: b'\xFF' }

///|
/// Lime color.
pub let lime : Color = { r: b'\x00', g: b'\x9E', b: b'\x2F', a: b'\xFF' }

///|
/// Dark green color.
pub let darkgreen : Color = { r: b'\x00', g: b'\x75', b: b'\x2C', a: b'\xFF' }

///|
/// Sky blue color.
pub let skyblue : Color = { r: b'\x66', g: b'\xBF', b: b'\xFF', a: b'\xFF' }

///|
/// Blue color.
pub let blue : Color = { r: b'\x00', g: b'\x79', b: b'\xF1', a: b'\xFF' }

///|
/// Dark blue color.
pub let darkblue : Color = { r: b'\x00', g: b'\x52', b: b'\xAC', a: b'\xFF' }

///|
/// Purple color.
pub let purple : Color = { r: b'\xC8', g: b'\x7A', b: b'\xFF', a: b'\xFF' }

///|
/// Violet color.
pub let violet : Color = { r: b'\x87', g: b'\x3C', b: b'\xBE', a: b'\xFF' }

///|
/// Dark purple color.
pub let darkpurple : Color = { r: b'\x70', g: b'\x1F', b: b'\x7E', a: b'\xFF' }

///|
/// Beige color.
pub let beige : Color = { r: b'\xD3', g: b'\xB0', b: b'\x83', a: b'\xFF' }

///|
/// Brown color.
pub let brown : Color = { r: b'\x7F', g: b'\x6A', b: b'\x4F', a: b'\xFF' }

///|
/// Dark brown color.
pub let darkbrown : Color = { r: b'\x4C', g: b'\x3F', b: b'\x2F', a: b'\xFF' }

///|
/// White color.
pub let white : Color = { r: b'\xFF', g: b'\xFF', b: b'\xFF', a: b'\xFF' }

///|
/// Black color.
pub let black : Color = { r: b'\x00', g: b'\x00', b: b'\x00', a: b'\xFF' }

///|
/// Blank color (fully transparent).
pub let blank : Color = { r: b'\x00', g: b'\x00', b: b'\x00', a: b'\x00' }

///|
/// Magenta color.
pub let magenta : Color = { r: b'\xFF', g: b'\x00', b: b'\xFF', a: b'\xFF' }

///|
/// Raylib white color (off-white).
pub let raywhite : Color = { r: b'\xF5', g: b'\xF5', b: b'\xF5', a: b'\xFF' }

// Color utility wrappers

///|
/// Get color with alpha applied, alpha goes from 0.0 to 1.0.
pub fn fade(color : Color, alpha : Float) -> Color {
  let a : Float = if alpha < 0.0 {
    0.0
  } else if alpha > 1.0 {
    1.0
  } else {
    alpha
  }
  let alpha_byte : Float = 255.0 * a
  { ..color, a: alpha_byte.to_int().to_byte() }
}

///|
/// Get color with alpha applied, alpha goes from 0.0 to 1.0.
pub fn color_alpha(color : Color, alpha : Float) -> Color {
  fade(color, alpha)
}

///|
/// Get hexadecimal value for a Color (0xRRGGBBAA).
pub fn color_to_int(color : Color) -> Int {
  (color.r.to_int() << 24) |
  (color.g.to_int() << 16) |
  (color.b.to_int() << 8) |
  color.a.to_int()
}

///|
/// Get Color structure from hexadecimal value.
pub fn get_color(hex_value : Int) -> Color {
  {
    r: ((hex_value >> 24) & 0xFF).to_byte(),
    g: ((hex_value >> 16) & 0xFF).to_byte(),
    b: ((hex_value >> 8) & 0xFF).to_byte(),
    a: (hex_value & 0xFF).to_byte(),
  }
}

///|
/// Get a Color from HSV values, hue [0..360], saturation/value [0..1].
pub fn color_from_hsv(hue : Float, saturation : Float, value : Float) -> Color {
  let h60 : Float = hue / 60.0
  let six : Float = 6.0
  // Red channel
  let kr : Float = fmodf(5.0 + h60, six)
  let tr : Float = 4.0 - kr
  let kr : Float = if tr < kr { tr } else { kr }
  let kr : Float = if kr < 1.0 { kr } else { 1.0 }
  let kr : Float = if kr > 0.0 { kr } else { 0.0 }
  let r = ((value - value * saturation * kr) * 255.0).to_int()
  // Green channel
  let kg : Float = fmodf(3.0 + h60, six)
  let tg : Float = 4.0 - kg
  let kg : Float = if tg < kg { tg } else { kg }
  let kg : Float = if kg < 1.0 { kg } else { 1.0 }
  let kg : Float = if kg > 0.0 { kg } else { 0.0 }
  let g = ((value - value * saturation * kg) * 255.0).to_int()
  // Blue channel
  let kb : Float = fmodf(1.0 + h60, six)
  let tb : Float = 4.0 - kb
  let kb : Float = if tb < kb { tb } else { kb }
  let kb : Float = if kb < 1.0 { kb } else { 1.0 }
  let kb : Float = if kb > 0.0 { kb } else { 0.0 }
  let b = ((value - value * saturation * kb) * 255.0).to_int()
  { r: r.to_byte(), g: g.to_byte(), b: b.to_byte(), a: b'\xFF' }
}

///|
/// Get color multiplied with another color.
pub fn color_tint(color : Color, tint : Color) -> Color {
  {
    r: (color.r.to_int() * tint.r.to_int() / 255).to_byte(),
    g: (color.g.to_int() * tint.g.to_int() / 255).to_byte(),
    b: (color.b.to_int() * tint.b.to_int() / 255).to_byte(),
    a: (color.a.to_int() * tint.a.to_int() / 255).to_byte(),
  }
}

///|
/// Get color with brightness correction, brightness factor goes from -1.0 to 1.0.
pub fn color_brightness(color : Color, factor : Float) -> Color {
  let factor : Float = if factor > 1.0 {
    1.0
  } else if factor < -1.0 {
    -1.0
  } else {
    factor
  }
  let r = Float::from_int(color.r.to_int())
  let g = Float::from_int(color.g.to_int())
  let b = Float::from_int(color.b.to_int())
  let (r, g, b) : (Float, Float, Float) = if factor < 0.0 {
    let f : Float = 1.0 + factor
    (r * f, g * f, b * f)
  } else {
    (
      (255.0 - r) * factor + r,
      (255.0 - g) * factor + g,
      (255.0 - b) * factor + b,
    )
  }
  {
    r: r.to_int().to_byte(),
    g: g.to_int().to_byte(),
    b: b.to_int().to_byte(),
    a: color.a,
  }
}

///|
/// Get color lerp interpolation between two colors, factor [0.0..1.0].
pub fn color_lerp(color1 : Color, color2 : Color, factor : Float) -> Color {
  let f : Float = if factor < 0.0 {
    0.0
  } else if factor > 1.0 {
    1.0
  } else {
    factor
  }
  let inv : Float = 1.0 - f
  {
    r: (inv * Float::from_int(color1.r.to_int()) +
    f * Float::from_int(color2.r.to_int()))
    .to_int()
    .to_byte(),
    g: (inv * Float::from_int(color1.g.to_int()) +
    f * Float::from_int(color2.g.to_int()))
    .to_int()
    .to_byte(),
    b: (inv * Float::from_int(color1.b.to_int()) +
    f * Float::from_int(color2.b.to_int()))
    .to_int()
    .to_byte(),
    a: (inv * Float::from_int(color1.a.to_int()) +
    f * Float::from_int(color2.a.to_int()))
    .to_int()
    .to_byte(),
  }
}

///|
/// Check if two colors are equal.
pub fn color_is_equal(col1 : Color, col2 : Color) -> Bool {
  col1 == col2
}

///|
/// Get Color normalized as float [0..1].
pub fn color_normalize(color : Color) -> Vector4 {
  {
    x: Float::from_int(color.r.to_int()) / 255.0,
    y: Float::from_int(color.g.to_int()) / 255.0,
    z: Float::from_int(color.b.to_int()) / 255.0,
    w: Float::from_int(color.a.to_int()) / 255.0,
  }
}

///|
/// Get Color from normalized values [0..1].
pub fn color_from_normalized(normalized : Vector4) -> Color {
  {
    r: (normalized.x * 255.0).to_int().to_byte(),
    g: (normalized.y * 255.0).to_int().to_byte(),
    b: (normalized.z * 255.0).to_int().to_byte(),
    a: (normalized.w * 255.0).to_int().to_byte(),
  }
}

///|
/// Get HSV values for a Color, hue [0..360], saturation/value [0..1].
pub fn color_to_hsv(color : Color) -> Vector3 {
  let rf = Float::from_int(color.r.to_int()) / 255.0
  let gf = Float::from_int(color.g.to_int()) / 255.0
  let bf = Float::from_int(color.b.to_int()) / 255.0
  let min = fminf(fminf(rf, gf), bf)
  let max = fmaxf(fmaxf(rf, gf), bf)
  let v = max
  let delta = max - min
  if delta < 0.00001 {
    return { x: 0.0, y: 0.0, z: v }
  }
  let s = if max > 0.0 { delta / max } else { return { x: 0.0, y: 0.0, z: v } }
  let h = if rf >= max {
    (gf - bf) / delta
  } else if gf >= max {
    2.0 + (bf - rf) / delta
  } else {
    4.0 + (rf - gf) / delta
  }
  let h = h * 60.0
  let h = if h < 0.0 { h + 360.0 } else { h }
  { x: h, y: s, z: v }
}

///|
/// Get color with contrast correction, contrast values between -1.0 and 1.0.
pub fn color_contrast(color : Color, contrast : Float) -> Color {
  let contrast : Float = if contrast < -1.0 {
    -1.0
  } else if contrast > 1.0 {
    1.0
  } else {
    contrast
  }
  let factor : Float = (1.0 + contrast) * (1.0 + contrast)
  let clampf = fn(v : Float) -> Float {
    if v < 0.0 {
      return 0.0
    }
    if v > 255.0 {
      return 255.0
    }
    v
  }
  let pr : Float = Float::from_int(color.r.to_int()) / 255.0
  let pr : Float = clampf(((pr - 0.5) * factor + 0.5) * 255.0)
  let pg : Float = Float::from_int(color.g.to_int()) / 255.0
  let pg : Float = clampf(((pg - 0.5) * factor + 0.5) * 255.0)
  let pb : Float = Float::from_int(color.b.to_int()) / 255.0
  let pb : Float = clampf(((pb - 0.5) * factor + 0.5) * 255.0)
  {
    r: pr.to_int().to_byte(),
    g: pg.to_int().to_byte(),
    b: pb.to_int().to_byte(),
    a: color.a,
  }
}

///|
/// Get src alpha-blended into dst color with tint.
pub fn color_alpha_blend(dst : Color, src : Color, tint : Color) -> Color {
  // Apply tint to source
  let sr = (src.r.to_int() * (tint.r.to_int() + 1)) >> 8
  let sg = (src.g.to_int() * (tint.g.to_int() + 1)) >> 8
  let sb = (src.b.to_int() * (tint.b.to_int() + 1)) >> 8
  let sa = (src.a.to_int() * (tint.a.to_int() + 1)) >> 8
  if sa == 0 {
    dst
  } else if sa == 255 {
    { r: sr.to_byte(), g: sg.to_byte(), b: sb.to_byte(), a: sa.to_byte() }
  } else {
    let alpha = sa + 1
    let out_a = (alpha * 256 + dst.a.to_int() * (256 - alpha)) >> 8
    if out_a > 0 {
      let out_r = (
          (sr * alpha * 256 + dst.r.to_int() * dst.a.to_int() * (256 - alpha)) /
          out_a
        ) >>
        8
      let out_g = (
          (sg * alpha * 256 + dst.g.to_int() * dst.a.to_int() * (256 - alpha)) /
          out_a
        ) >>
        8
      let out_b = (
          (sb * alpha * 256 + dst.b.to_int() * dst.a.to_int() * (256 - alpha)) /
          out_a
        ) >>
        8
      {
        r: out_r.to_byte(),
        g: out_g.to_byte(),
        b: out_b.to_byte(),
        a: out_a.to_byte(),
      }
    } else {
      { r: b'\x00', g: b'\x00', b: b'\x00', a: b'\x00' }
    }
  }
}

///|
pub using @ffi {get_pixel_data_size}
