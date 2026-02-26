///|
let screen_w : Int = 1440

///|
let screen_h : Int = 860

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_playing : Int = 1

///|
let state_paused : Int = 2

///|
let state_game_over : Int = 3

///|
let play_x : Int = 36

///|
let play_y : Int = 70

///|
let play_w : Int = 1046

///|
let play_h : Int = 752

///|
let hud_x : Int = play_x + play_w + 18

///|
let hud_y : Int = play_y

///|
let hud_w : Int = screen_w - hud_x - play_x

///|
let hud_h : Int = play_h

///|
let play_left : Float = Float::from_int(play_x + 12)

///|
let play_top : Float = Float::from_int(play_y + 12)

///|
let play_right : Float = Float::from_int(play_x + play_w - 12)

///|
let play_bottom : Float = Float::from_int(play_y + play_h - 12)

///|
let shrine_count : Int = 4

///|
fn gate_position() -> (Float, Float) {
  (Float::from_int(play_x + 110), Float::from_int(play_y + play_h / 2))
}

///|
fn shrine_position(index : Int) -> (Float, Float) {
  match clampi(index, 0, shrine_count - 1) {
    0 => (Float::from_int(play_x + play_w - 140), Float::from_int(play_y + 126))
    1 =>
      (
        Float::from_int(play_x + play_w - 168),
        Float::from_int(play_y + play_h / 2),
      )
    2 =>
      (
        Float::from_int(play_x + play_w - 140),
        Float::from_int(play_y + play_h - 126),
      )
    _ =>
      (
        Float::from_int(play_x + play_w / 2 + 106),
        Float::from_int(play_y + 104),
      )
  }
}

///|
let max_lanterns : Int = 20

///|
let max_gusts : Int = 24

///|
let max_sparks : Int = 180

///|
let max_thieves : Int = 18

///|
let patrol_radius : Float = 18.0

///|
let patrol_accel : Float = 980.0

///|
let patrol_drag : Float = 4.2

///|
let patrol_max_speed : Float = 322.0

///|
let guard_time : Float = 1.20

///|
let guard_radius : Float = 112.0

///|
let guard_push : Float = 320.0

///|
let calm_duration : Float = 1.80

///|
let calm_radius : Float = 128.0

///|
let calm_cooldown : Float = 6.20

///|
let lantern_radius : Float = 12.0

///|
let lantern_base_drain : Float = 3.8

///|
let lantern_drag : Float = 1.8

///|
let lantern_escort_regen : Float = 8.2

///|
let escort_pickup_range : Float = 78.0

///|
let escort_pull : Float = 6.2

///|
let delivery_radius : Float = 34.0

///|
let combo_window : Float = 4.2

///|
let combo_bonus_step : Int = 42

///|
let delivery_score_base : Int = 128

///|
let score_per_flame : Int = 2

///|
let extinguish_limit : Int = 7

///|
let interact_stabilize_boost : Float = 6.0

///|
let lantern_spawn_interval : Float = 2.20

///|
let lantern_spawn_floor : Float = 0.86

///|
let gust_spawn_interval : Float = 1.40

///|
let gust_spawn_floor : Float = 0.44

///|
let spark_spawn_interval : Float = 0.18

///|
let spark_spawn_floor : Float = 0.07

///|
let thief_spawn_interval : Float = 7.20

///|
let thief_spawn_floor : Float = 2.50

///|
let gust_drain_power : Float = 16.0

///|
let spark_drain_power : Float = 26.0

///|
let thief_drain_burst : Float = 32.0

///|
let thief_speed : Float = 136.0

///|
let thief_radius : Float = 14.0

///|
let thief_contact_radius : Float = thief_radius + lantern_radius + 4.0

///|
let thief_steal_period : Float = 0.65

///|
let status_default_t : Float = 1.30

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
fn squaref(v : Float) -> Float {
  v * v
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let roll = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * roll
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
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
fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
fn night_top() -> @raylib.Color {
  @raylib.Color::new(12, 20, 42, 255)
}

///|
fn night_bottom() -> @raylib.Color {
  @raylib.Color::new(36, 52, 96, 255)
}

///|
fn street_dark() -> @raylib.Color {
  @raylib.Color::new(30, 28, 40, 255)
}

///|
fn street_mid() -> @raylib.Color {
  @raylib.Color::new(52, 46, 64, 255)
}

///|
fn lantern_frame_col() -> @raylib.Color {
  @raylib.Color::new(212, 178, 124, 255)
}

///|
fn lantern_flame_col(flame : Float) -> @raylib.Color {
  let t = clampf(flame / 100.0, 0.0, 1.0)
  @raylib.Color::new(
    246,
    118 + (t * 122.0).to_int(),
    62 + (t * 130.0).to_int(),
    250,
  )
}

///|
fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(114, 208, 188, 255)
}

///|
fn danger_col() -> @raylib.Color {
  @raylib.Color::new(244, 110, 94, 255)
}

///|
fn calm_col() -> @raylib.Color {
  @raylib.Color::new(118, 212, 252, 255)
}
