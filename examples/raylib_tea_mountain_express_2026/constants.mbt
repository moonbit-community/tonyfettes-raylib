///|
let screen_w : Int = 1440

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
let hazard_rock : Int = 0

///|
let hazard_landslide : Int = 1

///|
let hazard_crosswind : Int = 2

///|
let lane_count : Int = 3

///|
let max_hazards : Int = 72

///|
let road_top_y_i : Int = 130

///|
let cart_y : Float = 760.0

///|
let speed_min : Float = 130.0

///|
let speed_base : Float = 260.0

///|
let speed_max : Float = 430.0

///|
let cruise_accel : Float = 200.0

///|
let natural_drag : Float = 0.45

///|
let brake_force : Float = 760.0

///|
let stabilize_speed_penalty : Float = 170.0

///|
let lane_follow_speed : Float = 7.2

///|
let tilt_follow_speed : Float = 8.5

///|
let route_wobble_strength : Float = 0.92

///|
let stabilize_wobble_damp : Float = 6.0

///|
let route_wear_cargo_dps : Float = 1.4

///|
let route_wear_durability_dps : Float = 1.1

///|
let boost_duration : Float = 0.9

///|
let boost_cooldown : Float = 2.3

///|
let boost_accel : Float = 540.0

///|
let boost_heat_gain : Float = 38.0

///|
let boost_heat_cool_idle : Float = 14.0

///|
let boost_heat_cool_stabilize : Float = 18.0

///|
let boost_heat_start_limit : Float = 88.0

///|
let boost_heat_critical : Float = 100.0

///|
let overheat_durability_dps : Float = 5.2

///|
let overheat_cargo_dps : Float = 4.4

///|
let overheat_reputation_dps : Float = 2.6

///|
let hazard_spawn_base : Float = 1.15

///|
let hazard_spawn_floor : Float = 0.42

///|
let hazard_spawn_difficulty_step : Float = 0.03

///|
let hazard_collision_window : Float = 54.0

///|
let hazard_pass_window : Float = 60.0

///|
let checkpoint_distance_base : Float = 1500.0

///|
let checkpoint_distance_step : Float = 180.0

///|
let checkpoint_timer_base : Float = 23.0

///|
let checkpoint_timer_decay : Float = 0.55

///|
let checkpoint_timer_min : Float = 10.5

///|
let delivery_quality_floor : Float = 34.0

///|
let delivery_durability_floor : Float = 26.0

///|
let delivery_reputation_gain : Float = 5.5

///|
let delivery_reputation_loss_base : Float = 9.0

///|
let delivery_reputation_loss_late : Float = 7.5

///|
let delivery_reputation_loss_quality : Float = 8.5

///|
let delivery_reputation_loss_durability : Float = 5.0

///|
let delivery_score_base : Int = 180

///|
let delivery_multiplier_max : Int = 6

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
fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
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
fn road_depth(y : Float) -> Float {
  clamp01(
    (y - Float::from_int(road_top_y_i)) /
    (Float::from_int(screen_h) - Float::from_int(road_top_y_i)),
  )
}

///|
fn road_half_width(y : Float) -> Float {
  let t = road_depth(y)
  130.0 + t * 440.0
}

///|
fn road_center_x(world_t : Float, y : Float) -> Float {
  let t = road_depth(y)
  let base = Float::from_int(screen_w) * 0.5
  let curve0 = sinf(world_t * 0.56 + t * 2.7) * 88.0
  let curve1 = cosf(world_t * 0.28 + t * 5.8) * 36.0
  base + curve0 + curve1
}

///|
fn lane_center_x(world_t : Float, lane : Int, y : Float) -> Float {
  let span = Float::from_int(lane_count - 1)
  let t = Float::from_int(clampi(lane, 0, lane_count - 1)) / span
  let offset = (t - 0.5) * 2.0
  let road_center = road_center_x(world_t, y)
  let lane_extent = road_half_width(y) * 0.55
  road_center + offset * lane_extent
}

///|
fn checkpoint_segment_distance(index : Int) -> Float {
  checkpoint_distance_base +
  Float::from_int(index - 1) * checkpoint_distance_step
}

///|
fn checkpoint_time_limit(index : Int) -> Float {
  clampf(
    checkpoint_timer_base - Float::from_int(index - 1) * checkpoint_timer_decay,
    checkpoint_timer_min,
    checkpoint_timer_base,
  )
}

///|
fn hazard_name(kind : Int) -> String {
  if kind == hazard_rock {
    "Rockfall"
  } else if kind == hazard_landslide {
    "Landslide"
  } else {
    "Crosswind"
  }
}

///|
fn hazard_tilt_bias(kind : Int) -> Float {
  if kind == hazard_rock {
    0.0
  } else if kind == hazard_landslide {
    -0.75
  } else {
    0.72
  }
}

///|
fn hazard_durability_hit(kind : Int) -> Float {
  if kind == hazard_rock {
    15.0
  } else if kind == hazard_landslide {
    21.0
  } else {
    11.0
  }
}

///|
fn hazard_cargo_hit(kind : Int) -> Float {
  if kind == hazard_rock {
    13.0
  } else if kind == hazard_landslide {
    16.0
  } else {
    18.0
  }
}
