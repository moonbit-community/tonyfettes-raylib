///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
}

///|
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
pub fn sky_top() -> @raylib.Color {
  @raylib.Color::new(14, 28, 62, 255)
}

///|
pub fn sky_bottom() -> @raylib.Color {
  @raylib.Color::new(42, 82, 124, 255)
}

///|
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(96, 242, 255, 255)
}

///|
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 126, 198, 255)
}

///|
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 126, 255)
}

///|
pub fn calm_col() -> @raylib.Color {
  @raylib.Color::new(255, 124, 162, 255)
}

///|
pub fn energy_col() -> @raylib.Color {
  @raylib.Color::new(122, 242, 196, 255)
}

///|
pub fn wind_col() -> @raylib.Color {
  @raylib.Color::new(148, 204, 255, 255)
}

///|
pub fn touch_btn_size() -> Float {
  98.0
}

///|
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (126.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (73.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (73.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
pub fn btn_burst_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
pub fn btn_reel_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (
    Float::from_int(screen_w) - s * 2.0 - 34.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 86.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.67,
    w,
    h,
  )
}

///|
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w : Float = 220.0
  let h : Float = 66.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.75,
    w,
    h,
  )
}

///|
pub fn is_hostile(kind : ObjKind) -> Bool {
  match kind {
    Bird | Storm => true
    Lantern | Orb | Koi => false
  }
}

///|
pub fn is_collectible(kind : ObjKind) -> Bool {
  match kind {
    Lantern | Orb | Koi => true
    Bird | Storm => false
  }
}

///|
pub fn obj_hit_r(o : SkyObj) -> Float {
  maxf(o.w, o.h) * 0.34
}

///|
pub fn kite_hit_r(k : Kite) -> Float {
  maxf(k.w, k.h) * 0.32
}

///|
pub fn kite_anchor_x(game : Game) -> Float {
  Float::from_int(screen_w) * 0.5 + sinf(game.time_s * 0.42) * 120.0
}

///|
pub fn kite_anchor_y() -> Float {
  Float::from_int(screen_h) - 10.0
}

///|
pub fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}
