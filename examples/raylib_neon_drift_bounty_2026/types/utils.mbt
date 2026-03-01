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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
pub fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
pub fn road_center_at(depth : Float, time_s : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  let sway0 = sinf(depth * 0.0024 + time_s * 0.72) * 146.0
  let sway1 = sinf(depth * 0.0041 + time_s * 1.2 + 1.4) * 84.0
  cx + sway0 + sway1
}

///|
pub fn road_half_width(stage : Int, depth : Float, time_s : Float) -> Float {
  let pulse = sinf(depth * 0.0037 + time_s * 0.95 + 0.7) * 62.0
  let shrink = Float::from_int(stage - 1) * 10.0
  clampf(
    Float::from_int(310) + pulse - shrink,
    Float::from_int(164),
    Float::from_int(332),
  )
}

///|
pub fn lane_to_offset(lane : Int) -> Float {
  (Float::from_int(lane) - Float::from_int(lanes_count - 1) * 0.5) * lane_gap
}

///|
pub fn lane_x(lane : Int, center : Float) -> Float {
  center + lane_to_offset(clampi(lane, 0, lanes_count - 1))
}

///|
pub fn road_edges(stage : Int, depth : Float, time_s : Float) -> (Float, Float) {
  let c = road_center_at(depth, time_s)
  let hw = road_half_width(stage, depth, time_s)
  (c - hw, c + hw)
}

///|
pub fn road_spawn_x(
  game_depth : Float,
  game_time : Float,
  stage : Int,
  y : Float,
) -> Float {
  let d = game_depth + (Float::from_int(screen_h) - y)
  let c = road_center_at(d, game_time)
  let hw = road_half_width(stage, d, game_time)
  let lo = c - hw + 58.0
  let hi = c + hw - 58.0
  randf(lo, hi)
}

///|
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 8, 24, 255)
}

///|
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 24, 46, 255)
}

///|
pub fn road_dark() -> @raylib.Color {
  @raylib.Color::new(14, 20, 34, 255)
}

///|
pub fn road_mid() -> @raylib.Color {
  @raylib.Color::new(20, 30, 52, 255)
}

///|
pub fn neon_yellow() -> @raylib.Color {
  @raylib.Color::new(255, 222, 118, 255)
}

///|
pub fn shield_col() -> @raylib.Color {
  @raylib.Color::new(255, 116, 152, 255)
}

///|
pub fn energy_col() -> @raylib.Color {
  @raylib.Color::new(112, 244, 196, 255)
}

///|
pub fn btn_size() -> Float {
  Float::from_int(104)
}

///|
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(134),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_fire_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_boost_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_hack_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(420)
  let h = Float::from_int(90)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
pub fn result_retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}

///|
pub fn entity_is_hostile(kind : EntityKind) -> Bool {
  match kind {
    FoeBike | FoeDrone | FoeTruck | FoeLaser => true
    ItemCredit | ItemBattery | ItemHackcell => false
  }
}

///|
pub fn is_pickup(kind : EntityKind) -> Bool {
  match kind {
    ItemCredit | ItemBattery | ItemHackcell => true
    FoeBike | FoeDrone | FoeTruck | FoeLaser => false
  }
}

///|
pub fn entity_hit_radius(e : Entity) -> Float {
  maxf(e.w, e.h) * 0.38
}

///|
pub fn player_hit_radius(hero : Player) -> Float {
  maxf(hero.w, hero.h) * 0.34
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
