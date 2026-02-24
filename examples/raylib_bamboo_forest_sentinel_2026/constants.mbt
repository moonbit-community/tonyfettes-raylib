///|
let screen_w : Int = 1500

///|
let screen_h : Int = 900

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
let world_x : Int = 44

///|
let world_y : Int = 48

///|
let world_w : Int = 1040

///|
let world_h : Int = 804

///|
let hud_x : Int = world_x + world_w + 24

///|
let hud_y : Int = world_y

///|
let hud_w : Int = 348

///|
let hud_h : Int = world_h

///|
let corridor_lanes : Int = 3

///|
let lane_top_y : Int = world_y + 176

///|
let lane_mid_y : Int = world_y + world_h / 2

///|
let lane_bottom_y : Int = world_y + world_h - 176

///|
let player_radius : Float = 16.0

///|
let player_speed : Float = 312.0

///|
let dash_speed : Float = 860.0

///|
let dash_time : Float = 0.12

///|
let dash_cooldown : Float = 0.92

///|
let dash_energy_cost : Float = 18.0

///|
let basic_attack_damage : Float = 34.0

///|
let basic_attack_range : Float = 90.0

///|
let basic_attack_arc_dot : Float = 0.28

///|
let basic_attack_energy_cost : Float = 6.0

///|
let basic_attack_cooldown : Float = 0.22

///|
let attack_flash_time : Float = 0.14

///|
let energy_max : Float = 100.0

///|
let energy_regen : Float = 14.0

///|
let sweep_charge_max : Float = 100.0

///|
let sweep_charge_passive : Float = 3.8

///|
let sweep_charge_hit : Float = 8.0

///|
let sweep_charge_kill : Float = 16.0

///|
let sweep_radius : Float = 250.0

///|
let sweep_damage : Float = 88.0

///|
let sweep_fx_time : Float = 0.34

///|
let trap_slot_cols : Int = 6

///|
let trap_slot_rows : Int = 3

///|
let trap_slot_count : Int = trap_slot_cols * trap_slot_rows

///|
let trap_place_range : Float = 46.0

///|
let trap_place_energy_cost : Float = 18.0

///|
let trap_place_cooldown : Float = 0.46

///|
let trap_trigger_radius : Float = 54.0

///|
let trap_damage : Float = 44.0

///|
let trap_rearm_time : Float = 1.18

///|
let trap_flash_time : Float = 0.20

///|
let trap_slow_time : Float = 1.10

///|
let trap_slow_factor : Float = 0.56

///|
let trap_remove_range : Float = 56.0

///|
let trap_remove_refund : Float = 8.0

///|
let beacon_count : Int = 3

///|
let beacon_radius : Float = 26.0

///|
let beacon_integrity_max : Float = 140.0

///|
let max_enemies : Int = 260

///|
let enemy_radius : Float = 14.0

///|
let enemy_hp_base : Float = 58.0

///|
let enemy_hp_step : Float = 6.4

///|
let enemy_speed_base : Float = 92.0

///|
let enemy_speed_step : Float = 7.2

///|
let enemy_damage_base : Float = 14.0

///|
let enemy_damage_step : Float = 1.5

///|
let night_spawn_base : Int = 10

///|
let night_spawn_step : Int = 4

///|
let spawn_interval_start : Float = 1.04

///|
let spawn_interval_decay : Float = 0.06

///|
let spawn_interval_floor : Float = 0.28

///|
let night_banner_time : Float = 1.35

///|
let night_clear_energy_bonus : Float = 20.0

///|
let night_clear_charge_bonus : Float = 22.0

///|
let score_kill_base : Int = 40

///|
let score_night_clear_bonus : Int = 220

///|
let status_default_t : Float = 1.4

///|
let shake_hit_time : Float = 0.18

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
fn squaref(v : Float) -> Float {
  v * v
}

///|
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let roll = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * roll
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn lane_y(lane : Int) -> Float {
  match clampi(lane, 0, corridor_lanes - 1) {
    0 => Float::from_int(lane_top_y)
    1 => Float::from_int(lane_mid_y)
    _ => Float::from_int(lane_bottom_y)
  }
}

///|
fn beacon_position(index : Int) -> (Float, Float) {
  match clampi(index, 0, beacon_count - 1) {
    0 => (Float::from_int(world_x + 760), lane_y(0))
    1 => (Float::from_int(world_x + 900), lane_y(1))
    _ => (Float::from_int(world_x + 760), lane_y(2))
  }
}

///|
fn trap_slot_position(index : Int) -> (Float, Float) {
  let normalized = clampi(index, 0, trap_slot_count - 1)
  let row = normalized / trap_slot_cols
  let col = normalized % trap_slot_cols
  let x = Float::from_int(world_x + 170 + col * 140)
  let y = lane_y(row)
  (x, y)
}

///|
fn spawn_route_count(night : Int) -> Int {
  if night >= 4 {
    8
  } else {
    6
  }
}

///|
fn spawn_route_position(route : Int) -> (Float, Float) {
  let mid_x = world_x + world_w / 2
  match route {
    0 => (Float::from_int(world_x + 12), lane_y(0))
    1 => (Float::from_int(world_x + 12), lane_y(1))
    2 => (Float::from_int(world_x + 12), lane_y(2))
    3 => (Float::from_int(world_x + world_w - 12), lane_y(0))
    4 => (Float::from_int(world_x + world_w - 12), lane_y(1))
    5 => (Float::from_int(world_x + world_w - 12), lane_y(2))
    6 => (Float::from_int(mid_x - 120), Float::from_int(world_y + 12))
    _ => (Float::from_int(mid_x + 120), Float::from_int(world_y + 12))
  }
}

///|
fn spawn_route_target(route : Int) -> Int {
  match route {
    0 => 0
    1 => 1
    2 => 2
    3 => 0
    4 => 1
    5 => 2
    6 => 0
    _ => 2
  }
}

///|
fn spawn_interval_for_night(night : Int) -> Float {
  let level = Float::from_int(clampi(night - 1, 0, 999))
  clampf(
    spawn_interval_start - spawn_interval_decay * level,
    spawn_interval_floor,
    spawn_interval_start,
  )
}

///|
fn enemy_hit_radius(kind : Int) -> Float {
  match kind {
    1 => 12.0
    2 => 18.0
    _ => enemy_radius
  }
}
