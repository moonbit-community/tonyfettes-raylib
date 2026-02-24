///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let hud_h : Int = 112

///|
let play_left : Float = 42.0

///|
let play_right : Float = Float::from_int(screen_w) - 42.0

///|
let play_top : Float = Float::from_int(hud_h) + 18.0

///|
let play_bottom : Float = Float::from_int(screen_h) - 24.0

///|
fn shrine_x() -> Float {
  Float::from_int(screen_w) * 0.5
}

///|
fn shrine_y() -> Float {
  Float::from_int(screen_h) * 0.55
}

///|
fn bell_orbit_r() -> Float {
  220.0
}

///|
fn bell_pos(i : Int) -> (Float, Float) {
  let cx = shrine_x()
  let cy = shrine_y()
  let r = bell_orbit_r()
  let k = i % bell_count

  if k == 0 {
    (cx, cy - r)
  } else if k == 1 {
    (cx + r, cy)
  } else if k == 2 {
    (cx, cy + r)
  } else {
    (cx - r, cy)
  }
}

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let foe_wisp : Int = 0

///|
let foe_brute : Int = 1

///|
let foe_shaman : Int = 2

///|
let foe_relic : Int = 3

///|
let max_foes : Int = 380

///|
let max_bolts : Int = 420

///|
let max_sparks : Int = 900

///|
let max_rings : Int = 96

///|
let max_echoes : Int = 320

///|
let hero_w : Float = 46.0

///|
let hero_h : Float = 52.0

///|
let hero_accel : Float = 1400.0

///|
let hero_drag : Float = 3.6

///|
let hero_max_speed : Float = 390.0

///|
let hero_invuln_time : Float = 0.62

///|
let hero_hurt_time : Float = 0.56

///|
let dash_cd_time : Float = 1.2

///|
let dash_time : Float = 0.2

///|
let dash_speed : Float = 700.0

///|
let bell_count : Int = 4

///|
let bell_ring_reach : Float = 138.0

///|
let bell_cd_time : Float = 1.38

///|
let bell_cost : Float = 18.0

///|
let bell_shock_radius : Float = 180.0

///|
let bell_shock_damage : Float = 26.0

///|
let bolt_speed : Float = 360.0

///|
let bolt_life : Float = 3.0

///|
let shrine_radius : Float = 64.0

///|
let shrine_max_hp : Float = 100.0

///|
let spirit_max : Float = 100.0

///|
let spirit_regen : Float = 16.0

///|
let spirit_dash_cost : Float = 12.0

///|
let stage_goal_base : Int = 1200

///|
let stage_goal_bonus : Int = 760

///|
let stage_time_base : Float = 60.0

///|
let stage_time_bonus : Float = 10.0

///|
let stage_clear_wait : Float = 1.9

///|
let spawn_cd_min : Float = 0.26

///|
let spawn_cd_max : Float = 1.08

///|
let shrine_drain_wisp : Float = 9.0

///|
let shrine_drain_brute : Float = 16.0

///|
let shrine_drain_shaman : Float = 11.0

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn point_in_rect(
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
fn pointer_on_rect(
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

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 18, 38, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(18, 42, 76, 255)
}

///|
fn cyan() -> @raylib.Color {
  @raylib.Color::new(96, 238, 255, 255)
}

///|
fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 124, 188, 255)
}

///|
fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 212, 122, 255)
}

///|
fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 198, 255)
}

///|
fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(255, 136, 168, 255)
}

///|
fn spirit_col() -> @raylib.Color {
  @raylib.Color::new(120, 244, 204, 255)
}

///|
fn btn_size() -> Float {
  102.0
}

///|
fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (132.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
fn btn_ring_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * 2.0 - 34.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 86.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

///|
fn retry_rect() -> (Float, Float, Float, Float) {
  let w : Float = 220.0
  let h : Float = 66.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.75,
    w,
    h,
  )
}
