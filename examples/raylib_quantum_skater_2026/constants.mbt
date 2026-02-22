///|
let screen_w : Int = 1366

///|
let screen_h : Int = 768

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
let obj_wall : Int = 0

///|
let obj_orb : Int = 1

///|
let obj_gate_alpha : Int = 2

///|
let obj_gate_beta : Int = 3

///|
let obj_boost : Int = 4

///|
let obj_jump_bar : Int = 5

///|
let lane_count : Int = 5

///|
let max_objs : Int = 360

///|
let max_particles : Int = 460

///|
let max_trails : Int = 180

///|
let base_speed : Float = 680.0

///|
let speed_stage_gain : Float = 70.0

///|
let player_jump_speed : Float = 860.0

///|
let player_gravity : Float = 2550.0

///|
let stage_base_distance : Float = 5200.0

///|
let stage_distance_growth : Float = 1800.0

///|
let phase_drain_per_sec : Float = 21.0

///|
let phase_recover_per_sec : Float = 18.0

///|
let phase_switch_cd : Float = 0.24

///|
let invuln_time : Float = 0.65

///|
let combo_decay_time : Float = 3.8

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
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn chance(p : Int) -> Bool {
  randi(0, 99) < p
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn proj_scale(z : Float) -> Float {
  1.0 / (1.0 + z * 0.0042)
}

///|
fn lane_world_x(lane : Int) -> Float {
  let half = Float::from_int(lane_count - 1) * 0.5
  (Float::from_int(lane) - half) * 220.0
}

///|
fn lane_screen_x(lane : Float, z : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  cx + lane * proj_scale(z)
}

///|
fn track_y(z : Float) -> Float {
  let near : Float = Float::from_int(screen_h) - Float::from_int(118)
  let far : Float = Float::from_int(162)
  lerpf(near, far, clampf(z / 2400.0, 0.0, 1.0))
}

///|
fn color_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 12, 32, 255)
}

///|
fn color_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 18, 44, 255)
}

///|
fn color_lane_alpha() -> @raylib.Color {
  @raylib.Color::new(86, 236, 255, 255)
}

///|
fn color_lane_beta() -> @raylib.Color {
  @raylib.Color::new(255, 124, 228, 255)
}

///|
fn color_phase_bar() -> @raylib.Color {
  @raylib.Color::new(136, 230, 255, 255)
}

///|
fn color_hp_bar() -> @raylib.Color {
  @raylib.Color::new(255, 118, 152, 255)
}

///|
fn button_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(22),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(140),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_phase_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}
