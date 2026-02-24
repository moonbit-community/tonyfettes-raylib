///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let obstacle_vent : Int = 0

///|
let obstacle_sign : Int = 1

///|
let obstacle_drone : Int = 2

///|
let obstacle_laser : Int = 3

///|
let max_segments : Int = 96

///|
let max_obstacles : Int = 160

///|
let max_chips : Int = 220

///|
let max_anchors : Int = 80

///|
let max_particles : Int = 320

///|
let world_gravity : Float = 2120.0

///|
let jump_speed : Float = -780.0

///|
let double_jump_speed : Float = -720.0

///|
let slide_duration : Float = 0.40

///|
let grapple_duration : Float = 0.34

///|
let coyote_time : Float = 0.10

///|
let jump_buffer_time : Float = 0.12

///|
let invuln_time : Float = 0.70

///|
let hurt_flash_time : Float = 0.24

///|
let stage_intro_time : Float = 1.30

///|
let base_scroll_speed : Float = 390.0

///|
let speed_per_stage : Float = 32.0

///|
let speed_ramp_per_second : Float = 2.6

///|
let stage_base_goal : Float = 1650.0

///|
let stage_goal_growth : Float = 620.0

///|
let player_spawn_x : Float = 210.0

///|
let player_spawn_y : Float = 390.0

///|
let ui_button_size : Float = 104.0

///|
let ui_button_gap : Float = 14.0

///|
let skyline_layers : Int = 3

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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn approachf(v : Float, target : Float, step : Float) -> Float {
  if v < target {
    minf(v + step, target)
  } else {
    maxf(v - step, target)
  }
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
fn ease_out_quad(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  1.0 - (1.0 - x) * (1.0 - x)
}

///|
fn ease_in_out(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  if x < 0.5 {
    2.0 * x * x
  } else {
    1.0 - (-2.0 * x + 2.0) * (-2.0 * x + 2.0) * 0.5
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn chance(percent : Int) -> Bool {
  randi(0, 99) < percent
}

///|
fn rect_contains(
  px : Float,
  py : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  px >= rx && py >= ry && px <= rx + rw && py <= ry + rh
}

///|
fn rect_overlap(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
fn dist_sq(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn color_mix(a : @raylib.Color, b : @raylib.Color, t : Float) -> @raylib.Color {
  let x = clampf(t, 0.0, 1.0)
  let r = (Float::from_int(a.r.to_int()) +
  Float::from_int(b.r.to_int() - a.r.to_int()) * x).to_int()
  let g = (Float::from_int(a.g.to_int()) +
  Float::from_int(b.g.to_int() - a.g.to_int()) * x).to_int()
  let bb = (Float::from_int(a.b.to_int()) +
  Float::from_int(b.b.to_int() - a.b.to_int()) * x).to_int()
  let aa = (Float::from_int(a.a.to_int()) +
  Float::from_int(b.a.to_int() - a.a.to_int()) * x).to_int()
  @raylib.Color::new(
    clampi(r, 0, 255),
    clampi(g, 0, 255),
    clampi(bb, 0, 255),
    clampi(aa, 0, 255),
  )
}

///|
fn neon_blue() -> @raylib.Color {
  @raylib.Color::new(58, 214, 255, 255)
}

///|
fn neon_pink() -> @raylib.Color {
  @raylib.Color::new(255, 88, 182, 255)
}

///|
fn neon_lime() -> @raylib.Color {
  @raylib.Color::new(145, 255, 82, 255)
}

///|
fn neon_orange() -> @raylib.Color {
  @raylib.Color::new(255, 184, 74, 255)
}

///|
fn bg_night() -> @raylib.Color {
  @raylib.Color::new(10, 12, 28, 255)
}

///|
fn bg_haze() -> @raylib.Color {
  @raylib.Color::new(24, 28, 52, 255)
}

///|
fn ui_dark() -> @raylib.Color {
  @raylib.Color::new(24, 28, 36, 240)
}

///|
fn ui_light() -> @raylib.Color {
  @raylib.Color::new(232, 242, 252, 255)
}

///|
fn button_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(screen_w) - s - Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}

///|
fn button_slide_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}

///|
fn button_grapple_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(screen_w) -
    s * Float::from_int(2) -
    ui_button_gap -
    Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}
