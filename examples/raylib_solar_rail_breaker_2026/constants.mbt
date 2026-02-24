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
let ring_count : Int = 4

///|
let max_enemies : Int = 160

///|
let max_bullets : Int = 240

///|
let max_enemy_bullets : Int = 260

///|
let max_flares : Int = 24

///|
let max_particles : Int = 520

///|
let max_shocks : Int = 180

///|
let base_radius : Float = Float::from_int(120)

///|
let ring_gap : Float = Float::from_int(62)

///|
let player_hit_r : Float = Float::from_int(20)

///|
let player_turn_speed : Float = 2.9

///|
let player_switch_cd : Float = 0.17

///|
let player_shot_cd : Float = 0.15

///|
let player_beam_cd : Float = 1.2

///|
let player_phase_max : Float = Float::from_int(100)

///|
let phase_drain : Float = Float::from_int(24)

///|
let phase_recover : Float = Float::from_int(16)

///|
let player_invuln_t : Float = 0.66

///|
let enemy_base_speed : Float = 1.1

///|
let enemy_speed_stage : Float = 0.08

///|
let enemy_fire_base : Float = 1.2

///|
let stage_time : Float = Float::from_int(36)

///|
let stage_clear_delay : Float = 1.8

///|
let pi : Float = 3.14159265

///|
let tau : Float = 6.28318530

///|
fn f(i : Int) -> Float {
  Float::from_int(i)
}

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
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn wrap_angle(a : Float) -> Float {
  let mut v = a
  while v > pi {
    v = v - tau
  }
  while v < -pi {
    v = v + tau
  }
  v
}

///|
fn shortest_angle(from : Float, to : Float) -> Float {
  wrap_angle(to - from)
}

///|
fn angle_dist(a : Float, b : Float) -> Float {
  absf(shortest_angle(a, b))
}

///|
fn ring_radius(ring : Int) -> Float {
  base_radius + Float::from_int(ring) * ring_gap
}

///|
fn world_x(radius : Float, angle : Float) -> Float {
  radius * cosf(angle)
}

///|
fn world_y(radius : Float, angle : Float) -> Float {
  radius * sinf(angle)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn ease_in_out(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  if x < 0.5 {
    f(2) * x * x
  } else {
    f(1) - (-f(2) * x + f(2)) * (-f(2) * x + f(2)) * 0.5
  }
}

///|
fn center_x() -> Float {
  Float::from_int(screen_w / 2)
}

///|
fn center_y() -> Float {
  Float::from_int(screen_h / 2)
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(10, 8, 24, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(20, 18, 42, 255)
}

///|
fn ring_alpha() -> @raylib.Color {
  @raylib.Color::new(88, 226, 255, 255)
}

///|
fn ring_beta() -> @raylib.Color {
  @raylib.Color::new(255, 136, 230, 255)
}

///|
fn phase_bar_col() -> @raylib.Color {
  @raylib.Color::new(146, 236, 255, 255)
}

///|
fn hp_bar_col() -> @raylib.Color {
  @raylib.Color::new(255, 126, 154, 255)
}

///|
fn button_size() -> Float {
  Float::from_int(102)
}

///|
fn button_left_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(24),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_right_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(138),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_in_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(3) - Float::from_int(48),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_out_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn button_fire_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}
