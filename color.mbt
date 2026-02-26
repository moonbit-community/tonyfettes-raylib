// Color: 4 bytes (r, g, b, a)

///|
pub struct Color {
  r : Byte
  g : Byte
  b : Byte
  a : Byte
} derive(Eq, Show)

///|
pub fn Color::new(r : Int, g : Int, b : Int, a : Int) -> Color {
  { r: r.to_byte(), g: g.to_byte(), b: b.to_byte(), a: a.to_byte() }
}

///|
pub fn Color::to_bytes(color : Color) -> Bytes {
  [color.r, color.g, color.b, color.a]
}

///|
pub fn Color::from_bytes(b : Bytes) -> Color {
  { r: b[0], g: b[1], b: b[2], a: b[3] }
}

// Color constants

///|
pub let lightgray : Color = { r: b'\xC8', g: b'\xC8', b: b'\xC8', a: b'\xFF' }

///|
pub let gray : Color = { r: b'\x82', g: b'\x82', b: b'\x82', a: b'\xFF' }

///|
pub let darkgray : Color = { r: b'\x50', g: b'\x50', b: b'\x50', a: b'\xFF' }

///|
pub let yellow : Color = { r: b'\xFD', g: b'\xF9', b: b'\x00', a: b'\xFF' }

///|
pub let gold : Color = { r: b'\xFF', g: b'\xCB', b: b'\x00', a: b'\xFF' }

///|
pub let orange : Color = { r: b'\xFF', g: b'\xA1', b: b'\x00', a: b'\xFF' }

///|
pub let pink : Color = { r: b'\xFF', g: b'\x6D', b: b'\xC2', a: b'\xFF' }

///|
pub let red : Color = { r: b'\xE6', g: b'\x29', b: b'\x37', a: b'\xFF' }

///|
pub let maroon : Color = { r: b'\xBE', g: b'\x21', b: b'\x37', a: b'\xFF' }

///|
pub let green : Color = { r: b'\x00', g: b'\xE4', b: b'\x30', a: b'\xFF' }

///|
pub let lime : Color = { r: b'\x00', g: b'\x9E', b: b'\x2F', a: b'\xFF' }

///|
pub let darkgreen : Color = { r: b'\x00', g: b'\x75', b: b'\x2C', a: b'\xFF' }

///|
pub let skyblue : Color = { r: b'\x66', g: b'\xBF', b: b'\xFF', a: b'\xFF' }

///|
pub let blue : Color = { r: b'\x00', g: b'\x79', b: b'\xF1', a: b'\xFF' }

///|
pub let darkblue : Color = { r: b'\x00', g: b'\x52', b: b'\xAC', a: b'\xFF' }

///|
pub let purple : Color = { r: b'\xC8', g: b'\x7A', b: b'\xFF', a: b'\xFF' }

///|
pub let violet : Color = { r: b'\x87', g: b'\x3C', b: b'\xBE', a: b'\xFF' }

///|
pub let darkpurple : Color = { r: b'\x70', g: b'\x1F', b: b'\x7E', a: b'\xFF' }

///|
pub let beige : Color = { r: b'\xD3', g: b'\xB0', b: b'\x83', a: b'\xFF' }

///|
pub let brown : Color = { r: b'\x7F', g: b'\x6A', b: b'\x4F', a: b'\xFF' }

///|
pub let darkbrown : Color = { r: b'\x4C', g: b'\x3F', b: b'\x2F', a: b'\xFF' }

///|
pub let white : Color = { r: b'\xFF', g: b'\xFF', b: b'\xFF', a: b'\xFF' }

///|
pub let black : Color = { r: b'\x00', g: b'\x00', b: b'\x00', a: b'\xFF' }

///|
pub let blank : Color = { r: b'\x00', g: b'\x00', b: b'\x00', a: b'\x00' }

///|
pub let magenta : Color = { r: b'\xFF', g: b'\x00', b: b'\xFF', a: b'\xFF' }

///|
pub let raywhite : Color = { r: b'\xF5', g: b'\xF5', b: b'\xF5', a: b'\xFF' }

// Color utility wrappers

///|
pub fn fade(color : Color, alpha : Float) -> Color {
  Color::from_bytes(@ffi.fade(color.to_bytes(), alpha))
}

///|
pub fn color_alpha(color : Color, alpha : Float) -> Color {
  Color::from_bytes(@ffi.color_alpha(color.to_bytes(), alpha))
}

///|
pub fn color_to_int(color : Color) -> Int {
  @ffi.color_to_int(color.to_bytes())
}

///|
pub fn get_color(hex_value : Int) -> Color {
  Color::from_bytes(@ffi.get_color(hex_value))
}

///|
pub fn color_from_hsv(hue : Float, saturation : Float, value : Float) -> Color {
  Color::from_bytes(@ffi.color_from_hsv(hue, saturation, value))
}

///|
pub fn color_tint(color : Color, tint : Color) -> Color {
  Color::from_bytes(@ffi.color_tint(color.to_bytes(), tint.to_bytes()))
}

///|
pub fn color_brightness(color : Color, factor : Float) -> Color {
  Color::from_bytes(@ffi.color_brightness(color.to_bytes(), factor))
}

///|
pub fn color_lerp(color1 : Color, color2 : Color, factor : Float) -> Color {
  Color::from_bytes(
    @ffi.color_lerp(color1.to_bytes(), color2.to_bytes(), factor),
  )
}

///|
pub fn color_is_equal(col1 : Color, col2 : Color) -> Bool {
  @ffi.color_is_equal(col1.to_bytes(), col2.to_bytes())
}

///|
pub fn color_normalize(color : Color) -> Vector4 {
  Vector4::from_bytes(@ffi.color_normalize(color.to_bytes()))
}

///|
pub fn color_from_normalized(normalized : Vector4) -> Color {
  Color::from_bytes(@ffi.color_from_normalized(normalized.to_bytes()))
}

///|
pub fn color_to_hsv(color : Color) -> Vector3 {
  Vector3::from_bytes(@ffi.color_to_hsv(color.to_bytes()))
}

///|
pub fn color_contrast(color : Color, contrast : Float) -> Color {
  Color::from_bytes(@ffi.color_contrast(color.to_bytes(), contrast))
}

///|
pub fn color_alpha_blend(dst : Color, src : Color, tint : Color) -> Color {
  Color::from_bytes(
    @ffi.color_alpha_blend(dst.to_bytes(), src.to_bytes(), tint.to_bytes()),
  )
}

///|
pub using @ffi {get_pixel_data_size}
