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
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn squaref(v : Float) -> Float {
  v * v
}

///|
pub fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let roll = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * roll
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn normalize2(x : Float, y : Float) -> (Float, Float) {
  let len2 = x * x + y * y
  if len2 <= 0.000001 {
    (0.0, 0.0)
  } else {
    let inv : Float = Float::from_int(1) / len2.sqrt()
    (x * inv, y * inv)
  }
}

///|
pub fn lane_y(lane : Int) -> Float {
  match clampi(lane, 0, corridor_lanes - 1) {
    0 => Float::from_int(lane_top_y)
    1 => Float::from_int(lane_mid_y)
    _ => Float::from_int(lane_bottom_y)
  }
}

///|
pub fn beacon_position(index : Int) -> (Float, Float) {
  match clampi(index, 0, beacon_count - 1) {
    0 => (Float::from_int(world_x + 760), lane_y(0))
    1 => (Float::from_int(world_x + 900), lane_y(1))
    _ => (Float::from_int(world_x + 760), lane_y(2))
  }
}

///|
pub fn trap_slot_position(index : Int) -> (Float, Float) {
  let normalized = clampi(index, 0, trap_slot_count - 1)
  let row = normalized / trap_slot_cols
  let col = normalized % trap_slot_cols
  let x = Float::from_int(world_x + 170 + col * 140)
  let y = lane_y(row)
  (x, y)
}

///|
pub fn spawn_route_count(night : Int) -> Int {
  if night >= 4 {
    8
  } else {
    6
  }
}

///|
pub fn spawn_route_position(route : Int) -> (Float, Float) {
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
pub fn spawn_route_target(route : Int) -> Int {
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
pub fn spawn_interval_for_night(night : Int) -> Float {
  let level = Float::from_int(clampi(night - 1, 0, 999))
  clampf(
    spawn_interval_start - spawn_interval_decay * level,
    spawn_interval_floor,
    spawn_interval_start,
  )
}

///|
pub fn enemy_hit_radius(kind : Int) -> Float {
  match kind {
    1 => 12.0
    2 => 18.0
    _ => enemy_radius
  }
}

///|
pub fn active_enemy_count(game : Game) -> Int {
  let mut total = 0
  for enemy in game.enemies {
    if enemy.active {
      total = total + 1
    }
  }
  total
}

///|
pub fn living_beacon_count(game : Game) -> Int {
  let mut total = 0
  for beacon in game.beacons {
    if beacon.integrity > 0.0 {
      total = total + 1
    }
  }
  total
}

///|
pub fn beacon_total_integrity(game : Game) -> Float {
  let mut total : Float = 0.0
  for beacon in game.beacons {
    total = total + maxf(beacon.integrity, 0.0)
  }
  total
}
