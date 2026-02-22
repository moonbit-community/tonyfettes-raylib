///|
let screen_w : Int = 1360

///|
let screen_h : Int = 820

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_pause : Int = 2

///|
let state_game_over : Int = 3

///|
let state_victory : Int = 4

///|
let wagon_count : Int = 3

///|
let lane_count : Int = 5

///|
let max_raiders : Int = 180

///|
let max_bullets : Int = 260

///|
let max_dust : Int = 960

///|
let checkpoint_total : Int = 4

///|
let checkpoint_base_span : Float = 1400.0

///|
let checkpoint_span_step : Float = 220.0

///|
let caravan_speed_base : Float = 132.0

///|
let caravan_speed_step : Float = 20.0

///|
let wagon_gap : Float = 148.0

///|
let wagon_hp_max : Float = 120.0

///|
let player_radius : Float = 16.0

///|
let player_speed : Float = 320.0

///|
let player_drag : Float = 8.0

///|
let player_roll_speed : Float = 760.0

///|
let player_roll_time : Float = 0.22

///|
let player_roll_cd : Float = 1.02

///|
let player_invuln_time : Float = 0.72

///|
let shoot_cd : Float = 0.14

///|
let bullet_speed : Float = 860.0

///|
let bullet_life : Float = 0.82

///|
let bullet_dmg : Float = 28.0

///|
let ammo_max : Int = 42

///|
let ammo_regen_base : Float = 0.58

///|
let repair_range : Float = 92.0

///|
let repair_heal : Float = 34.0

///|
let repair_cd : Float = 0.7

///|
let kit_max : Int = 8

///|
let morale_max : Float = 100.0

///|
let morale_decay : Float = 1.6

///|
let morale_kill_gain : Float = 0.9

///|
let perimeter_outer_rx : Float = 280.0

///|
let perimeter_outer_ry : Float = 195.0

///|
let perimeter_inner_rx : Float = 154.0

///|
let perimeter_inner_ry : Float = 102.0

///|
let spawn_interval_base : Float = 1.35

///|
let spawn_interval_min : Float = 0.34

///|
let raider_skirmisher : Int = 0

///|
let raider_brute : Int = 1

///|
let raider_rider : Int = 2

///|
let desert_lane_top : Float = 228.0

///|
let desert_lane_gap : Float = 94.0

///|
let tau : Float = 6.283185307179586

///|
let caravan_center_x : Float = Float::from_int(screen_w) * 0.48

///|
let caravan_center_y : Float = Float::from_int(screen_h) * 0.57

///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
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
fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
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
  if v <= 0.0 {
    0.0
  } else {
    v.sqrt()
  }
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
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
fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
fn checkpoint_span(idx : Int) -> Float {
  checkpoint_base_span + Float::from_int(maxi(idx, 0)) * checkpoint_span_step
}

///|
fn caravan_speed(checkpoint : Int) -> Float {
  caravan_speed_base + Float::from_int(maxi(checkpoint, 0)) * caravan_speed_step
}

///|
fn wagon_slot_x(index : Int) -> Float {
  caravan_center_x + Float::from_int(index - wagon_count / 2) * wagon_gap
}

///|
fn wagon_slot_y(index : Int) -> Float {
  if index % 2 == 0 {
    caravan_center_y - 24.0
  } else {
    caravan_center_y + 20.0
  }
}

///|
fn lane_base_y(index : Int) -> Float {
  desert_lane_top +
  Float::from_int(clampi(index, 0, lane_count - 1)) * desert_lane_gap
}

///|
fn ellipse_norm(dx : Float, dy : Float, rx : Float, ry : Float) -> Float {
  let nx = dx / maxf(rx, 0.001)
  let ny = dy / maxf(ry, 0.001)
  sqrtf(nx * nx + ny * ny)
}
