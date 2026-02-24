// Color utility functions used by raygui controls

// Extract RGBA components from a packed hexadecimal integer.
///|
pub fn get_color(hex_value : Int) -> @raylib.Color {
  let r = (hex_value >> 24) & 0xFF
  let g = (hex_value >> 16) & 0xFF
  let b = (hex_value >> 8) & 0xFF
  let a = hex_value & 0xFF
  @raylib.Color::new(r, g, b, a)
}

// Pack RGBA color components into a single integer.

///|
pub fn color_to_int(color : @raylib.Color) -> Int {
  (color.r.to_int() << 24) |
  (color.g.to_int() << 16) |
  (color.b.to_int() << 8) |
  color.a.to_int()
}

// Apply alpha fade to a color by multiplying its alpha channel.

///|
pub fn gui_fade(color : @raylib.Color, alpha : Float) -> @raylib.Color {
  let clamped : Float = if alpha < 0.0 {
    0.0
  } else if alpha > 1.0 {
    1.0
  } else {
    alpha
  }
  let new_a : Int = (Float::from_int(color.a.to_int()) * clamped).to_int()
  @raylib.Color::new(
    color.r.to_int(),
    color.g.to_int(),
    color.b.to_int(),
    new_a,
  )
}

// Simple 3-component vector, used for HSV color representation.

///|
pub struct Vector3 {
  x : Float
  y : Float
  z : Float
} derive(Eq, Show)

// Convert RGB color values (0.0-1.0 range) to HSV.
// Returns Vector3 where x=H (0-360), y=S (0-1), z=V (0-1).

///|
pub fn convert_rgb_to_hsv(rgb : Vector3) -> Vector3 {
  let min : Float = if rgb.x < rgb.y { rgb.x } else { rgb.y }
  let min : Float = if min < rgb.z { min } else { rgb.z }
  let max : Float = if rgb.x > rgb.y { rgb.x } else { rgb.y }
  let max : Float = if max > rgb.z { max } else { rgb.z }
  let v = max
  let delta : Float = max - min
  if delta < 0.00001 {
    return { x: 0.0, y: 0.0, z: v }
  }
  if max > 0.0 {
    let s : Float = delta / max
    let h : Float = if rgb.x >= max {
      (rgb.y - rgb.z) / delta
    } else if rgb.y >= max {
      2.0 + (rgb.z - rgb.x) / delta
    } else {
      4.0 + (rgb.x - rgb.y) / delta
    }
    let h : Float = h * 60.0
    let h : Float = if h < 0.0 { h + 360.0 } else { h }
    { x: h, y: s, z: v }
  } else {
    { x: 0.0, y: 0.0, z: v }
  }
}

// Convert HSV color values to RGB (0.0-1.0 range).
// Input Vector3 where x=H (0-360), y=S (0-1), z=V (0-1).

///|
pub fn convert_hsv_to_rgb(hsv : Vector3) -> Vector3 {
  if hsv.y <= 0.0 {
    return { x: hsv.z, y: hsv.z, z: hsv.z }
  }
  let hh : Float = if hsv.x >= 360.0 { 0.0 } else { hsv.x }
  let hh : Float = hh / 60.0
  let i = hh.to_int()
  let ff : Float = hh - Float::from_int(i)
  let p : Float = hsv.z * (1.0 - hsv.y)
  let q : Float = hsv.z * (1.0 - hsv.y * ff)
  let t : Float = hsv.z * (1.0 - hsv.y * (1.0 - ff))
  match i {
    0 => { x: hsv.z, y: t, z: p }
    1 => { x: q, y: hsv.z, z: p }
    2 => { x: p, y: hsv.z, z: t }
    3 => { x: p, y: q, z: hsv.z }
    4 => { x: t, y: p, z: hsv.z }
    _ => { x: hsv.z, y: p, z: q }
  }
}

// Check if a point is inside a rectangle.

///|
pub fn check_collision_point_rec(
  point : @raylib.Vector2,
  rec : @raylib.Rectangle,
) -> Bool {
  point.x >= rec.x &&
  point.x <= rec.x + rec.width &&
  point.y >= rec.y &&
  point.y <= rec.y + rec.height
}
