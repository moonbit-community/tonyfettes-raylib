///|
struct PlayerShip {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut hull : Float
  hull_max : Float
  mut energy : Float
  energy_max : Float
  mut cutter_heat : Float
  mut cutter_cd : Float
  mut repair_cd : Float
  mut sonar_cd : Float
  mut sonar_t : Float
  mut ping_x : Float
  mut ping_y : Float
  mut wake_t : Float
}

///|
struct IceChunk {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut hard : Float
  mut crack_t : Float
  mut tone : Float
}

///|
struct ConvoyShip {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut hp : Float
  mut cargo : Int
  mut route_i : Int
  mut stuck_t : Float
  mut panic : Float
  mut blink_t : Float
  mut id : Int
}

///|
struct StormCell {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut intensity : Float
  mut life : Float
  mut phase : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
struct Waypoint {
  x : Float
  y : Float
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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn clear_ice(ice : Array[IceChunk]) -> Unit {
  for i = 0; i < ice.length(); i = i + 1 {
    ice[i].active = false
    ice[i].x = 0.0
    ice[i].y = 0.0
    ice[i].vx = 0.0
    ice[i].vy = 0.0
    ice[i].radius = 0.0
    ice[i].hard = 0.0
    ice[i].crack_t = 0.0
    ice[i].tone = 0.0
  }
}

///|
fn clear_convoys(convoys : Array[ConvoyShip]) -> Unit {
  for i = 0; i < convoys.length(); i = i + 1 {
    convoys[i].active = false
    convoys[i].x = 0.0
    convoys[i].y = 0.0
    convoys[i].vx = 0.0
    convoys[i].vy = 0.0
    convoys[i].speed = 0.0
    convoys[i].hp = 0.0
    convoys[i].cargo = 0
    convoys[i].route_i = 0
    convoys[i].stuck_t = 0.0
    convoys[i].panic = 0.0
    convoys[i].blink_t = 0.0
    convoys[i].id = 0
  }
}

///|
fn clear_storms(storms : Array[StormCell]) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    storms[i].active = false
    storms[i].x = 0.0
    storms[i].y = 0.0
    storms[i].vx = 0.0
    storms[i].vy = 0.0
    storms[i].radius = 0.0
    storms[i].intensity = 0.0
    storms[i].life = 0.0
    storms[i].phase = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].life = 0.0
    parts[i].size = 0.0
    parts[i].kind = 0
  }
}

///|
fn add_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = if kind == 0 {
        randf(8.0, 46.0)
      } else if kind == 1 {
        randf(40.0, 180.0)
      } else {
        randf(18.0, 100.0)
      }
      parts[i].vx = @math.cosf(a) * s
      parts[i].vy = @math.sinf(a) * s
      parts[i].life = if kind == 0 {
        randf(0.5, 1.2)
      } else if kind == 1 {
        randf(0.15, 0.45)
      } else {
        randf(0.22, 0.72)
      }
      parts[i].size = if kind == 1 { randf(2.0, 6.5) } else { randf(1.8, 4.8) }
      parts[i].kind = kind
      return
    }
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_particle(parts, x, y, kind)
  }
}

///|
fn update_particles(parts : Array[Particle], dt : Float) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }
    parts[i].life = parts[i].life - dt
    if parts[i].life <= 0.0 {
      parts[i].active = false
      continue
    }

    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt

    if parts[i].kind == 0 {
      parts[i].vy = parts[i].vy + dt * 10.0
      parts[i].vx = parts[i].vx * (1.0 - dt * 0.8)
    } else if parts[i].kind == 1 {
      parts[i].vy = parts[i].vy + dt * 180.0
      parts[i].vx = parts[i].vx * (1.0 - dt * 4.5)
    } else {
      parts[i].vy = parts[i].vy + dt * 40.0
      parts[i].vx = parts[i].vx * (1.0 - dt * 2.3)
    }
  }
}

///|
fn init_route(
  route : Array[Waypoint],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  route.clear()

  let left_x : Float = Float::from_int(world_x + 80)
  let right_x : Float = Float::from_int(world_x + world_w - 90)
  let top_y : Float = Float::from_int(world_y + 90)
  let bottom_y : Float = Float::from_int(world_y + world_h - 90)
  let mid_y : Float = Float::from_int(world_y + world_h / 2)

  route.push({ x: left_x, y: mid_y + randf(-40.0, 40.0) })
  route.push({
    x: left_x + 190.0,
    y: clampf(mid_y + randf(-180.0, -40.0), top_y, bottom_y),
  })
  route.push({
    x: left_x + 360.0,
    y: clampf(mid_y + randf(40.0, 210.0), top_y, bottom_y),
  })
  route.push({
    x: left_x + 560.0,
    y: clampf(mid_y + randf(-220.0, -70.0), top_y, bottom_y),
  })
  route.push({
    x: left_x + 770.0,
    y: clampf(mid_y + randf(70.0, 220.0), top_y, bottom_y),
  })
  route.push({
    x: left_x + 980.0,
    y: clampf(mid_y + randf(-170.0, 170.0), top_y, bottom_y),
  })
  route.push({
    x: right_x - 170.0,
    y: clampf(mid_y + randf(-120.0, 120.0), top_y, bottom_y),
  })
  route.push({ x: right_x, y: mid_y + randf(-50.0, 50.0) })
}

///|
fn setup_ice_field(
  ice : Array[IceChunk],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  route : Array[Waypoint],
) -> Unit {
  clear_ice(ice)

  let mut filled : Int = 0
  let target : Int = ice.length() - 35

  while filled < target {
    let x : Float = randf(world_l + 28.0, world_r - 28.0)
    let y : Float = randf(world_t + 28.0, world_b - 28.0)

    // keep start/end harbor and route lanes somewhat open
    let mut lane_penalty : Float = 99999.0
    for i = 0; i < route.length(); i = i + 1 {
      let d2v : Float = dist2(x, y, route[i].x, route[i].y)
      if d2v < lane_penalty {
        lane_penalty = d2v
      }
    }

    if lane_penalty < 46.0 * 46.0 {
      continue
    }

    let mut overlap : Bool = false
    for j = 0; j < ice.length(); j = j + 1 {
      if not(ice[j].active) {
        continue
      }
      let rr : Float = ice[j].radius + 16.0
      if dist2(x, y, ice[j].x, ice[j].y) < rr * rr {
        overlap = true
        break
      }
    }
    if overlap {
      continue
    }

    ice[filled].active = true
    ice[filled].x = x
    ice[filled].y = y
    ice[filled].vx = randf(-22.0, 22.0)
    ice[filled].vy = randf(-22.0, 22.0)
    ice[filled].radius = randf(10.0, 38.0)
    ice[filled].hard = randf(28.0, 100.0)
    ice[filled].crack_t = 0.0
    ice[filled].tone = randf(0.0, 1.0)

    filled = filled + 1
  }
}

///|
fn spawn_convoy(
  convoys : Array[ConvoyShip],
  route : Array[Waypoint],
  tier : Int,
  serial : Int,
) -> Bool {
  for i = 0; i < convoys.length(); i = i + 1 {
    if convoys[i].active {
      continue
    }

    let cargo : Int = 8 + @raylib.get_random_value(0, 8 + tier * 3)
    convoys[i].active = true
    convoys[i].x = route[0].x - randf(50.0, 120.0)
    convoys[i].y = route[0].y + randf(-30.0, 30.0)
    convoys[i].vx = 0.0
    convoys[i].vy = 0.0
    convoys[i].speed = randf(56.0, 82.0) + Float::from_int(tier) * 2.0
    convoys[i].hp = 100.0
    convoys[i].cargo = cargo
    convoys[i].route_i = 1
    convoys[i].stuck_t = 0.0
    convoys[i].panic = 0.0
    convoys[i].blink_t = 0.0
    convoys[i].id = serial
    return true
  }
  false
}

///|
fn spawn_storm(
  storms : Array[StormCell],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
) -> Bool {
  for i = 0; i < storms.length(); i = i + 1 {
    if storms[i].active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      storms[i].x = world_l - 40.0
      storms[i].y = randf(world_t + 20.0, world_b - 20.0)
      storms[i].vx = randf(16.0, 46.0)
      storms[i].vy = randf(-12.0, 12.0)
    } else if side == 1 {
      storms[i].x = world_r + 40.0
      storms[i].y = randf(world_t + 20.0, world_b - 20.0)
      storms[i].vx = randf(-46.0, -16.0)
      storms[i].vy = randf(-12.0, 12.0)
    } else if side == 2 {
      storms[i].x = randf(world_l + 20.0, world_r - 20.0)
      storms[i].y = world_t - 40.0
      storms[i].vx = randf(-14.0, 14.0)
      storms[i].vy = randf(16.0, 42.0)
    } else {
      storms[i].x = randf(world_l + 20.0, world_r - 20.0)
      storms[i].y = world_b + 40.0
      storms[i].vx = randf(-14.0, 14.0)
      storms[i].vy = randf(-42.0, -16.0)
    }

    storms[i].active = true
    storms[i].radius = randf(68.0, 138.0)
    storms[i].intensity = randf(0.7, 1.5) + Float::from_int(tier) * 0.04
    storms[i].life = randf(20.0, 40.0) + Float::from_int(tier) * 1.0
    storms[i].phase = randf(0.0, 20.0)
    return true
  }
  false
}

///|
fn active_ice_count(ice : Array[IceChunk]) -> Int {
  let mut n : Int = 0
  for i = 0; i < ice.length(); i = i + 1 {
    if ice[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn active_convoy_count(convoys : Array[ConvoyShip]) -> Int {
  let mut n : Int = 0
  for i = 0; i < convoys.length(); i = i + 1 {
    if convoys[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn active_storm_count(storms : Array[StormCell]) -> Int {
  let mut n : Int = 0
  for i = 0; i < storms.length(); i = i + 1 {
    if storms[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn update_ice(
  ice : Array[IceChunk],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  wave_t : Float,
) -> Float {
  let mut hazard_sum : Float = 0.0

  for i = 0; i < ice.length(); i = i + 1 {
    if not(ice[i].active) {
      continue
    }

    let wobble : Float = 0.3 +
      0.7 * (@math.sinf(wave_t * 0.6 + Float::from_int(i) * 0.35) * 0.5 + 0.5)
    let drift_mul : Float = 0.8 + wobble * 0.5

    ice[i].x = ice[i].x + ice[i].vx * dt * drift_mul
    ice[i].y = ice[i].y + ice[i].vy * dt * drift_mul

    if ice[i].x < world_l + ice[i].radius {
      ice[i].x = world_l + ice[i].radius
      ice[i].vx = absf(ice[i].vx) * randf(0.6, 1.2)
    } else if ice[i].x > world_r - ice[i].radius {
      ice[i].x = world_r - ice[i].radius
      ice[i].vx = -absf(ice[i].vx) * randf(0.6, 1.2)
    }

    if ice[i].y < world_t + ice[i].radius {
      ice[i].y = world_t + ice[i].radius
      ice[i].vy = absf(ice[i].vy) * randf(0.6, 1.2)
    } else if ice[i].y > world_b - ice[i].radius {
      ice[i].y = world_b - ice[i].radius
      ice[i].vy = -absf(ice[i].vy) * randf(0.6, 1.2)
    }

    ice[i].hard = clampf(ice[i].hard - dt * 0.05, 0.0, 120.0)
    if ice[i].hard <= 0.5 {
      ice[i].active = false
      continue
    }

    if ice[i].crack_t > 0.0 {
      ice[i].crack_t = ice[i].crack_t - dt
      if ice[i].crack_t < 0.0 {
        ice[i].crack_t = 0.0
      }
    }

    hazard_sum = hazard_sum + ice[i].hard * (ice[i].radius * 0.02)
  }

  hazard_sum
}

///|
fn update_storms(
  storms : Array[StormCell],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }

    storms[i].life = storms[i].life - dt
    if storms[i].life <= 0.0 {
      storms[i].active = false
      continue
    }

    storms[i].phase = storms[i].phase + dt * (0.8 + storms[i].intensity * 0.4)

    let pulse : Float = 0.92 + 0.16 * (@math.sinf(storms[i].phase) * 0.5 + 0.5)
    storms[i].x = storms[i].x + storms[i].vx * dt * pulse
    storms[i].y = storms[i].y + storms[i].vy * dt * pulse

    if storms[i].x < world_l - 120.0 {
      storms[i].x = world_l - 120.0
      storms[i].vx = absf(storms[i].vx)
    } else if storms[i].x > world_r + 120.0 {
      storms[i].x = world_r + 120.0
      storms[i].vx = -absf(storms[i].vx)
    }

    if storms[i].y < world_t - 120.0 {
      storms[i].y = world_t - 120.0
      storms[i].vy = absf(storms[i].vy)
    } else if storms[i].y > world_b + 120.0 {
      storms[i].y = world_b + 120.0
      storms[i].vy = -absf(storms[i].vy)
    }
  }
}

///|
fn update_player_damage_from_hazards(
  ship : PlayerShip,
  ice : Array[IceChunk],
  storms : Array[StormCell],
  dt : Float,
) -> Float {
  let mut damage : Float = 0.0

  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }
    let d2 : Float = dist2(ship.x, ship.y, storms[i].x, storms[i].y)
    let rr : Float = storms[i].radius
    if d2 < rr * rr {
      let ratio : Float = 1.0 - d2.sqrt() / rr
      let dmg : Float = dt * storms[i].intensity * (1.8 + ratio * 2.1)
      damage = damage + dmg
      ship.energy = maxf(
        0.0,
        ship.energy - dt * storms[i].intensity * (0.6 + ratio * 1.5),
      )
    }
  }

  for i = 0; i < ice.length(); i = i + 1 {
    if not(ice[i].active) {
      continue
    }
    let rr : Float = ice[i].radius + 12.0
    let d2 : Float = dist2(ship.x, ship.y, ice[i].x, ice[i].y)
    if d2 < rr * rr {
      let d : Float = maxf(0.001, d2.sqrt())
      let push : Float = (rr - d) * dt * 18.0
      let nx : Float = (ship.x - ice[i].x) / d
      let ny : Float = (ship.y - ice[i].y) / d
      ship.x = ship.x + nx * push
      ship.y = ship.y + ny * push

      if ship.cutter_heat <= 0.2 {
        damage = damage + dt * (ice[i].hard * 0.02 + 2.2)
      }
    }
  }

  damage
}

///|
fn carve_ice_with_cutter(
  ship : PlayerShip,
  ice : Array[IceChunk],
  parts : Array[Particle],
  dt : Float,
  cutting : Bool,
) -> (Int, Float) {
  if not(cutting) || ship.energy <= 0.0 {
    ship.cutter_heat = maxf(0.0, ship.cutter_heat - dt * 1.7)
    (0, 0.0)
  } else {
    ship.cutter_heat = minf(1.0, ship.cutter_heat + dt * 1.6)
    ship.energy = maxf(0.0, ship.energy - dt * (6.0 + ship.cutter_heat * 9.0))

    let mut cleared : Int = 0
    let mut score_gain : Float = 0.0

    for i = 0; i < ice.length(); i = i + 1 {
      if not(ice[i].active) {
        continue
      }

      let rr : Float = ice[i].radius + 44.0
      let d2 : Float = dist2(ship.x, ship.y, ice[i].x, ice[i].y)
      if d2 > rr * rr {
        continue
      }

      let impact : Float = dt * (26.0 + ship.cutter_heat * 55.0)
      ice[i].hard = ice[i].hard - impact
      ice[i].crack_t = 0.25

      if @raylib.get_random_value(0, 100) < 36 {
        burst(parts, ice[i].x, ice[i].y, 2, 1)
      }

      score_gain = score_gain + impact * 0.45

      if ice[i].hard <= 0.0 {
        ice[i].active = false
        cleared = cleared + 1
        burst(parts, ice[i].x, ice[i].y, 10, 2)
      }
    }

    (cleared, score_gain)
  }
}

///|
fn repair_nearby_convoys(
  ship : PlayerShip,
  convoys : Array[ConvoyShip],
  parts : Array[Particle],
  energy_cost : Float,
) -> Int {
  if ship.energy < energy_cost || ship.repair_cd > 0.0 {
    0
  } else {
    let mut count : Int = 0
    for i = 0; i < convoys.length(); i = i + 1 {
      if not(convoys[i].active) {
        continue
      }
      if convoys[i].hp >= 99.0 {
        continue
      }

      let d2 : Float = dist2(ship.x, ship.y, convoys[i].x, convoys[i].y)
      if d2 > 90.0 * 90.0 {
        continue
      }

      convoys[i].hp = minf(100.0, convoys[i].hp + 26.0)
      convoys[i].panic = maxf(0.0, convoys[i].panic - 1.2)
      convoys[i].blink_t = 0.35
      burst(parts, convoys[i].x, convoys[i].y, 8, 2)
      count = count + 1
    }

    if count > 0 {
      ship.energy = ship.energy - energy_cost
      ship.repair_cd = 0.65
    }

    count
  }
}

///|
fn scan_hazards(
  ship : PlayerShip,
  ice : Array[IceChunk],
  storms : Array[StormCell],
) -> (Bool, Float, Float, Int) {
  if ship.sonar_cd > 0.0 {
    (false, ship.ping_x, ship.ping_y, 0)
  } else {
    let mut best_x : Float = ship.x
    let mut best_y : Float = ship.y
    let mut best_d2 : Float = 999999999.0
    let mut kind : Int = 0

    for i = 0; i < ice.length(); i = i + 1 {
      if not(ice[i].active) || ice[i].hard < 24.0 {
        continue
      }
      let d2v : Float = dist2(ship.x, ship.y, ice[i].x, ice[i].y)
      if d2v < best_d2 {
        best_d2 = d2v
        best_x = ice[i].x
        best_y = ice[i].y
        kind = 1
      }
    }

    for i = 0; i < storms.length(); i = i + 1 {
      if not(storms[i].active) {
        continue
      }
      let d2v : Float = dist2(ship.x, ship.y, storms[i].x, storms[i].y)
      if d2v < best_d2 {
        best_d2 = d2v
        best_x = storms[i].x
        best_y = storms[i].y
        kind = 2
      }
    }

    if kind == 0 {
      ship.sonar_cd = 1.0
      (false, ship.x, ship.y, 0)
    } else {
      ship.sonar_cd = 2.4
      ship.sonar_t = 2.1
      ship.ping_x = best_x
      ship.ping_y = best_y
      (true, best_x, best_y, kind)
    }
  }
}

///|
fn update_convoys(
  convoys : Array[ConvoyShip],
  route : Array[Waypoint],
  ice : Array[IceChunk],
  storms : Array[StormCell],
  parts : Array[Particle],
  dt : Float,
) -> (Int, Int, Int, Float) {
  let mut delivered : Int = 0
  let mut sunk : Int = 0
  let mut score_gain : Int = 0
  let mut wait_accum : Float = 0.0

  for i = 0; i < convoys.length(); i = i + 1 {
    if not(convoys[i].active) {
      continue
    }

    if convoys[i].blink_t > 0.0 {
      convoys[i].blink_t = convoys[i].blink_t - dt
      if convoys[i].blink_t < 0.0 {
        convoys[i].blink_t = 0.0
      }
    }

    convoys[i].panic = maxf(0.0, convoys[i].panic - dt * 0.42)

    if convoys[i].route_i >= route.length() {
      convoys[i].active = false
      delivered = delivered + 1
      score_gain = score_gain + convoys[i].cargo * 9 + convoys[i].hp.to_int()
      burst(parts, convoys[i].x, convoys[i].y, 14, 2)
      continue
    }

    let tx : Float = route[convoys[i].route_i].x
    let ty : Float = route[convoys[i].route_i].y

    let mut blocked : Bool = false
    let mut block_damage : Float = 0.0

    for j = 0; j < ice.length(); j = j + 1 {
      if not(ice[j].active) {
        continue
      }

      let rr : Float = ice[j].radius + 18.0
      let d2v : Float = dist2(convoys[i].x, convoys[i].y, ice[j].x, ice[j].y)
      if d2v < rr * rr {
        if ice[j].hard > 20.0 {
          blocked = true
          block_damage = block_damage + 0.6 + ice[j].hard * 0.015
        } else {
          ice[j].hard = maxf(0.0, ice[j].hard - dt * 2.6)
        }
      }
    }

    let mut storm_slow : Float = 0.0
    for j = 0; j < storms.length(); j = j + 1 {
      if not(storms[j].active) {
        continue
      }

      let rr : Float = storms[j].radius
      let d2v : Float = dist2(
        convoys[i].x,
        convoys[i].y,
        storms[j].x,
        storms[j].y,
      )
      if d2v < rr * rr {
        let ratio : Float = 1.0 - d2v.sqrt() / rr
        storm_slow = storm_slow + storms[j].intensity * (0.16 + ratio * 0.5)
        convoys[i].hp = convoys[i].hp -
          dt * storms[j].intensity * (0.6 + ratio * 1.5)
        convoys[i].panic = convoys[i].panic + dt * 1.0
      }
    }

    if blocked {
      convoys[i].stuck_t = convoys[i].stuck_t + dt
      convoys[i].panic = convoys[i].panic + dt * 0.65
      convoys[i].hp = convoys[i].hp - dt * (0.45 + block_damage)
      convoys[i].vx = convoys[i].vx * (1.0 - dt * 3.6)
      convoys[i].vy = convoys[i].vy * (1.0 - dt * 3.6)
      wait_accum = wait_accum + dt
      if convoys[i].stuck_t > 4.5 {
        convoys[i].hp = convoys[i].hp - dt * 1.8
      }
    } else {
      convoys[i].stuck_t = maxf(0.0, convoys[i].stuck_t - dt * 2.2)

      let dx : Float = tx - convoys[i].x
      let dy : Float = ty - convoys[i].y
      let d : Float = maxf(0.0001, (dx * dx + dy * dy).sqrt())

      let slow : Float = clampf(1.0 - storm_slow, 0.28, 1.0)
      let speed : Float = convoys[i].speed * slow

      convoys[i].vx = dx / d * speed
      convoys[i].vy = dy / d * speed

      convoys[i].x = convoys[i].x + convoys[i].vx * dt
      convoys[i].y = convoys[i].y + convoys[i].vy * dt

      if d < 18.0 {
        convoys[i].route_i = convoys[i].route_i + 1
      }
    }

    convoys[i].hp = clampf(convoys[i].hp, 0.0, 100.0)

    if convoys[i].hp <= 0.0 {
      convoys[i].active = false
      sunk = sunk + 1
      score_gain = score_gain - 60
      burst(parts, convoys[i].x, convoys[i].y, 18, 1)
      continue
    }
  }

  (delivered, sunk, score_gain, wait_accum)
}

///|
fn draw_ocean(
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
  scene_t : Float,
) -> Unit {
  @raylib.draw_rectangle(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(12, 34, 58, 255),
  )

  let mut y : Int = world_y
  while y < world_y + world_h {
    let p : Float = Float::from_int(y - world_y) / Float::from_int(world_h)
    let wave : Float = @math.sinf(scene_t * 0.8 + Float::from_int(y) * 0.02) *
      0.5 +
      0.5

    let c0 : Int = 24 + (p * 24.0).to_int() + (wave * 5.0).to_int()
    let c1 : Int = 62 + (p * 42.0).to_int() + (wave * 8.0).to_int()
    let c2 : Int = 98 + (p * 28.0).to_int() + (wave * 10.0).to_int()

    @raylib.draw_rectangle(
      world_x,
      y,
      world_w,
      4,
      @raylib.Color::new(c0, c1, c2, 255),
    )
    y = y + 4
  }

  @raylib.draw_rectangle_lines(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(140, 188, 222, 220),
  )
}

///|
fn draw_route(route : Array[Waypoint]) -> Unit {
  for i = 0; i < route.length() - 1; i = i + 1 {
    let ax : Int = route[i].x.to_int()
    let ay : Int = route[i].y.to_int()
    let bx : Int = route[i + 1].x.to_int()
    let by : Int = route[i + 1].y.to_int()

    @raylib.draw_line(ax, ay, bx, by, @raylib.Color::new(88, 140, 186, 170))
    @raylib.draw_line(
      ax,
      ay + 1,
      bx,
      by + 1,
      @raylib.Color::new(150, 206, 238, 120),
    )
  }

  for i = 0; i < route.length(); i = i + 1 {
    @raylib.draw_circle(
      route[i].x.to_int(),
      route[i].y.to_int(),
      6.0,
      @raylib.Color::new(202, 236, 255, 205),
    )
  }
}

///|
fn draw_ice(ice : Array[IceChunk], scene_t : Float) -> Unit {
  for i = 0; i < ice.length(); i = i + 1 {
    if not(ice[i].active) {
      continue
    }

    let hard01 : Float = clampf(ice[i].hard / 100.0, 0.0, 1.0)
    let pulse : Float = 0.82 +
      0.2 * (@math.sinf(scene_t * 1.8 + ice[i].tone * 12.0) * 0.5 + 0.5)

    let cr : Int = 158 + (hard01 * 48.0).to_int()
    let cg : Int = 198 + (hard01 * 42.0).to_int()
    let cb : Int = 222 + (pulse * 25.0).to_int()

    @raylib.draw_circle(
      ice[i].x.to_int(),
      ice[i].y.to_int(),
      ice[i].radius + 1.5,
      @raylib.Color::new(102, 154, 194, 180),
    )
    @raylib.draw_circle(
      ice[i].x.to_int(),
      ice[i].y.to_int(),
      ice[i].radius,
      @raylib.Color::new(cr, cg, cb, 238),
    )

    if ice[i].crack_t > 0.0 {
      let r : Float = ice[i].radius * (0.28 + 0.18 * ice[i].crack_t)
      @raylib.draw_circle(
        ice[i].x.to_int(),
        ice[i].y.to_int(),
        r,
        @raylib.Color::new(234, 248, 255, 188),
      )
    }

    if ice[i].hard > 72.0 {
      @raylib.draw_circle(
        (ice[i].x + ice[i].radius * 0.28).to_int(),
        (ice[i].y - ice[i].radius * 0.2).to_int(),
        maxf(1.5, ice[i].radius * 0.16),
        @raylib.Color::new(240, 252, 255, 152),
      )
    }
  }
}

///|
fn draw_storms(storms : Array[StormCell], scene_t : Float) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }

    let pulse : Float = 0.84 +
      0.22 * (@math.sinf(scene_t * 2.1 + storms[i].phase * 1.9) * 0.5 + 0.5)
    let r0 : Float = storms[i].radius * pulse
    let r1 : Float = storms[i].radius * (0.62 + pulse * 0.16)

    let alpha0 : Int = 56 + (storms[i].intensity * 58.0).to_int()
    let alpha1 : Int = 26 + (storms[i].intensity * 32.0).to_int()

    @raylib.draw_circle(
      storms[i].x.to_int(),
      storms[i].y.to_int(),
      r0,
      @raylib.Color::new(134, 172, 216, alpha0),
    )
    @raylib.draw_circle(
      storms[i].x.to_int(),
      storms[i].y.to_int(),
      r1,
      @raylib.Color::new(192, 218, 250, alpha1),
    )

    let bolt_x : Int = (storms[i].x +
    @math.sinf(scene_t * 4.0 + storms[i].phase) * storms[i].radius * 0.28).to_int()
    let bolt_y : Int = (storms[i].y +
    @math.cosf(scene_t * 3.2 + storms[i].phase * 0.7) * storms[i].radius * 0.24).to_int()
    @raylib.draw_circle(
      bolt_x,
      bolt_y,
      3.0 + storms[i].intensity * 1.8,
      @raylib.Color::new(248, 250, 255, 210),
    )
  }
}

///|
fn convoy_color(hp : Float, panic : Float) -> @raylib.Color {
  let hp01 : Float = clampf(hp / 100.0, 0.0, 1.0)
  let panic01 : Float = clampf(panic / 4.0, 0.0, 1.0)

  let r : Int = 94 +
    ((Float::from_int(1) - hp01) * 116.0).to_int() +
    (panic01 * 22.0).to_int()
  let g : Int = 188 -
    ((Float::from_int(1) - hp01) * 88.0).to_int() -
    (panic01 * 24.0).to_int()
  let b : Int = 236 - (panic01 * 34.0).to_int()

  @raylib.Color::new(r, g, b, 248)
}

///|
fn draw_convoys(convoys : Array[ConvoyShip]) -> Unit {
  for i = 0; i < convoys.length(); i = i + 1 {
    if not(convoys[i].active) {
      continue
    }

    let col : @raylib.Color = if convoys[i].blink_t > 0.0 {
      @raylib.Color::new(248, 244, 186, 252)
    } else {
      convoy_color(convoys[i].hp, convoys[i].panic)
    }

    let x : Int = convoys[i].x.to_int()
    let y : Int = convoys[i].y.to_int()

    @raylib.draw_rectangle(x - 14, y - 8, 28, 16, col)
    @raylib.draw_rectangle(
      x - 8,
      y - 12,
      16,
      8,
      @raylib.Color::new(232, 246, 255, 230),
    )
    @raylib.draw_rectangle(
      x - 20,
      y - 2,
      10,
      4,
      @raylib.Color::new(74, 114, 146, 228),
    )

    @raylib.draw_text(
      "#\{convoys[i].id} \{convoys[i].hp.to_int()}%",
      x - 20,
      y - 26,
      14,
      @raylib.Color::new(230, 242, 255, 222),
    )
  }
}

///|
fn draw_player(ship : PlayerShip, scene_t : Float) -> Unit {
  let hull_col : @raylib.Color = if ship.hull < 35.0 {
    @raylib.Color::new(242, 146, 148, 250)
  } else {
    @raylib.Color::new(242, 242, 248, 250)
  }

  let x : Float = ship.x
  let y : Float = ship.y
  let nx : Float = @math.cosf(ship.heading)
  let ny : Float = @math.sinf(ship.heading)

  let arm : Float = 18.0
  @raylib.draw_line(
    (x - arm).to_int(),
    y.to_int(),
    (x + arm).to_int(),
    y.to_int(),
    @raylib.Color::new(90, 130, 164, 242),
  )
  @raylib.draw_line(
    x.to_int(),
    (y - 14.0).to_int(),
    x.to_int(),
    (y + 14.0).to_int(),
    @raylib.Color::new(90, 130, 164, 242),
  )

  @raylib.draw_rectangle(
    (x - 13.0).to_int(),
    (y - 9.0).to_int(),
    26,
    18,
    hull_col,
  )
  @raylib.draw_rectangle(
    (x - 7.0).to_int(),
    (y - 13.0).to_int(),
    14,
    8,
    @raylib.Color::new(214, 236, 250, 240),
  )
  @raylib.draw_line(
    x.to_int(),
    y.to_int(),
    (x + nx * 26.0).to_int(),
    (y + ny * 26.0).to_int(),
    @raylib.Color::new(246, 248, 255, 232),
  )

  let wake_r : Float = 10.0 +
    (@math.sinf(scene_t * 4.6 + ship.wake_t) * 0.5 + 0.5) * 6.0
  @raylib.draw_circle(
    (x - nx * 18.0).to_int(),
    (y - ny * 18.0).to_int(),
    wake_r,
    @raylib.Color::new(180, 216, 246, 80),
  )

  if ship.cutter_heat > 0.04 {
    let glow : Float = 12.0 + ship.cutter_heat * 26.0
    let cx : Float = x + nx * 20.0
    let cy : Float = y + ny * 20.0
    @raylib.draw_circle(
      cx.to_int(),
      cy.to_int(),
      glow,
      @raylib.Color::new(248, 204, 136, 96),
    )
    @raylib.draw_circle(
      cx.to_int(),
      cy.to_int(),
      5.0 + ship.cutter_heat * 6.0,
      @raylib.Color::new(248, 232, 168, 212),
    )
  }

  if ship.sonar_t > 0.0 {
    let p : Float = ship.sonar_t / 2.1
    let rr : Float = (1.0 - p) * 140.0 + 16.0
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      rr,
      @raylib.Color::new(166, 222, 250, 88),
    )
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let col : @raylib.Color = if parts[i].kind == 0 {
      @raylib.Color::new(206, 230, 252, 180)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(250, 212, 138, 220)
    } else {
      @raylib.Color::new(172, 244, 206, 210)
    }

    @raylib.draw_circle(
      parts[i].x.to_int(),
      parts[i].y.to_int(),
      parts[i].size,
      col,
    )
  }
}

///|
fn draw_harbors(
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  let left_x : Int = world_x + 12
  let right_x : Int = world_x + world_w - 94
  let mid_y : Int = world_y + world_h / 2

  @raylib.draw_rectangle(
    left_x,
    mid_y - 90,
    82,
    180,
    @raylib.Color::new(48, 86, 124, 228),
  )
  @raylib.draw_rectangle(
    left_x + 8,
    mid_y - 70,
    16,
    140,
    @raylib.Color::new(78, 128, 170, 235),
  )
  @raylib.draw_rectangle(
    left_x + 30,
    mid_y - 56,
    16,
    112,
    @raylib.Color::new(78, 128, 170, 235),
  )
  @raylib.draw_rectangle(
    left_x + 52,
    mid_y - 42,
    16,
    84,
    @raylib.Color::new(78, 128, 170, 235),
  )

  @raylib.draw_rectangle(
    right_x,
    mid_y - 100,
    82,
    200,
    @raylib.Color::new(62, 102, 142, 228),
  )
  @raylib.draw_rectangle(
    right_x + 8,
    mid_y - 72,
    18,
    148,
    @raylib.Color::new(104, 148, 186, 235),
  )
  @raylib.draw_rectangle(
    right_x + 34,
    mid_y - 56,
    18,
    120,
    @raylib.Color::new(104, 148, 186, 235),
  )
  @raylib.draw_rectangle(
    right_x + 58,
    mid_y - 38,
    16,
    92,
    @raylib.Color::new(104, 148, 186, 235),
  )

  @raylib.draw_text(
    "BASE",
    left_x + 8,
    mid_y + 96,
    24,
    @raylib.Color::new(212, 236, 255, 244),
  )
  @raylib.draw_text(
    "EXIT",
    right_x + 8,
    mid_y + 106,
    24,
    @raylib.Color::new(212, 236, 255, 244),
  )
}

///|
fn draw_touch_controls(
  sw : Int,
  sh : Int,
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
) -> Unit {
  let pad_x : Int = 32
  let pad_y : Int = sh - 204

  fn dpad_box(
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    label : String,
    active : Bool,
  ) -> Unit {
    let fill : @raylib.Color = if active {
      @raylib.Color::new(120, 176, 220, 224)
    } else {
      @raylib.Color::new(42, 72, 108, 196)
    }
    @raylib.draw_rectangle(x, y, w, h, fill)
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(166, 204, 236, 236),
    )
    @raylib.draw_text(
      label,
      x + w / 2 - @raylib.measure_text(label, 28) / 2,
      y + 11,
      28,
      @raylib.Color::new(232, 246, 255, 250),
    )
  }

  dpad_box(
    pad_x + 84,
    pad_y,
    76,
    56,
    "U",
    hold && inside_rect(mouse_x, mouse_y, pad_x + 84, pad_y, 76, 56),
  )
  dpad_box(
    pad_x,
    pad_y + 66,
    76,
    56,
    "L",
    hold && inside_rect(mouse_x, mouse_y, pad_x, pad_y + 66, 76, 56),
  )
  dpad_box(
    pad_x + 168,
    pad_y + 66,
    76,
    56,
    "R",
    hold && inside_rect(mouse_x, mouse_y, pad_x + 168, pad_y + 66, 76, 56),
  )
  dpad_box(
    pad_x + 84,
    pad_y + 132,
    76,
    56,
    "D",
    hold && inside_rect(mouse_x, mouse_y, pad_x + 84, pad_y + 132, 76, 56),
  )

  let cut_x : Float = Float::from_int(sw - 300)
  let cut_y : Float = Float::from_int(sh - 160)
  let repair_x : Float = Float::from_int(sw - 182)
  let repair_y : Float = Float::from_int(sh - 236)
  let scan_x : Float = Float::from_int(sw - 110)
  let scan_y : Float = Float::from_int(sh - 134)

  fn draw_round_btn(
    x : Float,
    y : Float,
    r : Float,
    label : String,
    active : Bool,
  ) -> Unit {
    let fill : @raylib.Color = if active {
      @raylib.Color::new(130, 194, 236, 226)
    } else {
      @raylib.Color::new(40, 78, 116, 190)
    }
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      r + 4.0,
      @raylib.Color::new(10, 20, 36, 180),
    )
    @raylib.draw_circle(x.to_int(), y.to_int(), r, fill)
    @raylib.draw_text(
      label,
      x.to_int() - @raylib.measure_text(label, 24) / 2,
      y.to_int() - 11,
      24,
      @raylib.Color::new(232, 246, 255, 246),
    )
  }

  draw_round_btn(
    cut_x,
    cut_y,
    56.0,
    "CUT",
    hold && dist2(mouse_x, mouse_y, cut_x, cut_y) <= 56.0 * 56.0,
  )
  draw_round_btn(
    repair_x,
    repair_y,
    44.0,
    "FIX",
    hold && dist2(mouse_x, mouse_y, repair_x, repair_y) <= 44.0 * 44.0,
  )
  draw_round_btn(
    scan_x,
    scan_y,
    42.0,
    "SCAN",
    hold && dist2(mouse_x, mouse_y, scan_x, scan_y) <= 42.0 * 42.0,
  )
}

///|
fn draw_action_bar(
  panel_x : Int,
  y : Int,
  label : String,
  value : Float,
  maxv : Float,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_text(
    label,
    panel_x + 18,
    y,
    23,
    @raylib.Color::new(216, 234, 250, 242),
  )
  @raylib.draw_rectangle(
    panel_x + 18,
    y + 28,
    370,
    20,
    @raylib.Color::new(18, 30, 46, 255),
  )
  let p01 : Float = if maxv <= 0.0001 {
    0.0
  } else {
    clampf(value / maxv, 0.0, 1.0)
  }
  let fw : Int = (Float::from_int(370) * p01).to_int()
  @raylib.draw_rectangle(panel_x + 18, y + 28, fw, 20, color)
  @raylib.draw_rectangle_lines(
    panel_x + 18,
    y + 28,
    370,
    20,
    @raylib.Color::new(168, 202, 234, 236),
  )
  @raylib.draw_text(
    "\{value.to_int()}/\{maxv.to_int()}",
    panel_x + 270,
    y + 52,
    19,
    @raylib.Color::new(220, 238, 254, 238),
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  active : Bool,
) -> Unit {
  let fill : @raylib.Color = if active {
    @raylib.Color::new(110, 172, 214, 240)
  } else {
    @raylib.Color::new(44, 84, 124, 220)
  }

  @raylib.draw_rectangle(x, y, w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(202, 228, 252, 244),
  )
  @raylib.draw_text(
    text,
    x + w / 2 - @raylib.measure_text(text, 34) / 2,
    y + h / 2 - 17,
    34,
    @raylib.Color::new(238, 248, 255, 252),
  )
}

///|
fn main {
  let sw : Int = 1680
  let sh : Int = 940
  @raylib.init_window(
    sw, sh, "raylib [core] example - icebreaker convoy command",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(120)

  let world_x : Int = 20
  let world_y : Int = 20
  let panel_w : Int = 420
  let world_w : Int = sw - panel_w - 40
  let world_h : Int = sh - 40

  let world_l : Float = Float::from_int(world_x)
  let world_t : Float = Float::from_int(world_y)
  let world_r : Float = Float::from_int(world_x + world_w)
  let world_b : Float = Float::from_int(world_y + world_h)

  let ice : Array[IceChunk] = Array::makei(260, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      hard: 0.0,
      crack_t: 0.0,
      tone: 0.0,
    }
  })

  let convoys : Array[ConvoyShip] = Array::makei(26, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      speed: 0.0,
      hp: 0.0,
      cargo: 0,
      route_i: 0,
      stuck_t: 0.0,
      panic: 0.0,
      blink_t: 0.0,
      id: 0,
    }
  })

  let storms : Array[StormCell] = Array::makei(18, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      intensity: 0.0,
      life: 0.0,
      phase: 0.0,
    }
  })

  let parts : Array[Particle] = Array::makei(920, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  let route : Array[Waypoint] = []

  let ship : PlayerShip = {
    x: Float::from_int(world_x + 74),
    y: Float::from_int(world_y + world_h / 2),
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    hull: 100.0,
    hull_max: 100.0,
    energy: 100.0,
    energy_max: 100.0,
    cutter_heat: 0.0,
    cutter_cd: 0.0,
    repair_cd: 0.0,
    sonar_cd: 0.0,
    sonar_t: 0.0,
    ping_x: 0.0,
    ping_y: 0.0,
    wake_t: randf(0.0, 20.0),
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 420.0
  let mut delivered : Int = 0
  let mut target_delivered : Int = 34
  let mut sunk : Int = 0
  let mut sunk_limit : Int = 10
  let mut score : Int = 0
  let mut tier : Int = 1
  let mut convoy_serial : Int = 1
  let mut spawn_cd : Float = 2.0
  let mut storm_cd : Float = 5.0
  let mut wait_accum : Float = 0.0
  let mut ice_cleared : Int = 0
  let mut scene_t : Float = 0.0
  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut last_hazard_sum : Float = 0.0

  fn reset_run() -> Unit {
    init_route(route, world_x, world_y, world_w, world_h)
    setup_ice_field(ice, world_l, world_t, world_r, world_b, route)

    clear_convoys(convoys)
    clear_storms(storms)
    clear_particles(parts)

    ship.x = Float::from_int(world_x + 74)
    ship.y = Float::from_int(world_y + world_h / 2)
    ship.vx = 0.0
    ship.vy = 0.0
    ship.heading = 0.0
    ship.hull = 100.0
    ship.energy = 100.0
    ship.cutter_heat = 0.0
    ship.cutter_cd = 0.0
    ship.repair_cd = 0.0
    ship.sonar_cd = 0.0
    ship.sonar_t = 0.0
    ship.ping_x = ship.x
    ship.ping_y = ship.y
    ship.wake_t = randf(0.0, 20.0)

    timer = 420.0
    delivered = 0
    target_delivered = 34
    sunk = 0
    sunk_limit = 10
    score = 0
    tier = 1
    convoy_serial = 1
    spawn_cd = 1.8
    storm_cd = 5.0
    wait_accum = 0.0
    ice_cleared = 0
    scene_t = 0.0
    msg = "Escort convoy through the pack ice"
    msg_t = 2.4
    last_hazard_sum = 0.0
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }
    scene_t = scene_t + dt

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if ship.cutter_cd > 0.0 {
      ship.cutter_cd = ship.cutter_cd - dt
      if ship.cutter_cd < 0.0 {
        ship.cutter_cd = 0.0
      }
    }
    if ship.repair_cd > 0.0 {
      ship.repair_cd = ship.repair_cd - dt
      if ship.repair_cd < 0.0 {
        ship.repair_cd = 0.0
      }
    }
    if ship.sonar_cd > 0.0 {
      ship.sonar_cd = ship.sonar_cd - dt
      if ship.sonar_cd < 0.0 {
        ship.sonar_cd = 0.0
      }
    }
    if ship.sonar_t > 0.0 {
      ship.sonar_t = ship.sonar_t - dt
      if ship.sonar_t < 0.0 {
        ship.sonar_t = 0.0
      }
    }

    update_particles(parts, dt)

    if state == 0 {
      if click ||
        @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      tier = 1 + delivered / 5
      if tier > 9 {
        tier = 9
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut cut_hold : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut repair_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyU)
      let mut scan_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if hold {
        let pad_x : Int = 32
        let pad_y : Int = sh - 204

        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 76, 56) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 66, 76, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 66, 76, 56) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 132, 76, 56) {
          move_d = true
        }

        let cut_x : Float = Float::from_int(sw - 300)
        let cut_y : Float = Float::from_int(sh - 160)
        let repair_x : Float = Float::from_int(sw - 182)
        let repair_y : Float = Float::from_int(sh - 236)

        if dist2(mouse.x, mouse.y, cut_x, cut_y) <= 56.0 * 56.0 {
          cut_hold = true
        }
        if dist2(mouse.x, mouse.y, repair_x, repair_y) <= 44.0 * 44.0 {
          repair_press = true
        }
      }

      if click {
        let scan_x : Float = Float::from_int(sw - 110)
        let scan_y : Float = Float::from_int(sh - 134)
        if dist2(mouse.x, mouse.y, scan_x, scan_y) <= 42.0 * 42.0 {
          scan_press = true
        }
      }

      let accel : Float = 430.0
      if move_l {
        ship.vx = ship.vx - accel * dt
      }
      if move_r {
        ship.vx = ship.vx + accel * dt
      }
      if move_u {
        ship.vy = ship.vy - accel * dt
      }
      if move_d {
        ship.vy = ship.vy + accel * dt
      }

      let drag : Float = 5.8
      ship.vx = ship.vx * (1.0 - dt * drag)
      ship.vy = ship.vy * (1.0 - dt * drag)

      let max_speed : Float = 240.0
      let sp2 : Float = ship.vx * ship.vx + ship.vy * ship.vy
      if sp2 > max_speed * max_speed {
        let k : Float = max_speed / sp2.sqrt()
        ship.vx = ship.vx * k
        ship.vy = ship.vy * k
      }

      ship.x = clampf(ship.x + ship.vx * dt, world_l + 8.0, world_r - 8.0)
      ship.y = clampf(ship.y + ship.vy * dt, world_t + 8.0, world_b - 8.0)
      ship.wake_t = ship.wake_t + dt * (2.6 + sp2.sqrt() * 0.01)

      if sp2 > 50.0 {
        ship.heading = @math.atan2f(ship.vy, ship.vx)
      }

      let speed_norm : Float = sp2.sqrt() / max_speed
      ship.energy = maxf(0.0, ship.energy - dt * (0.55 + speed_norm * 0.72))

      // Base harbor recharge lane on the left side
      if inside_rect(
          ship.x,
          ship.y,
          world_x + 10,
          world_y + world_h / 2 - 120,
          120,
          240,
        ) {
        ship.energy = minf(ship.energy_max, ship.energy + dt * 20.0)
        ship.hull = minf(ship.hull_max, ship.hull + dt * 7.2)
      }

      let (cleared_now, cutter_score) = carve_ice_with_cutter(
        ship, ice, parts, dt, cut_hold,
      )
      if cleared_now > 0 {
        ice_cleared = ice_cleared + cleared_now
        score = score + cleared_now * 18 + cutter_score.to_int()
        msg = "Cutter opened \{cleared_now} lane(s)"
        msg_t = 0.8
      } else if cutter_score > 0.0 {
        score = score + cutter_score.to_int()
      }

      if repair_press {
        let fixed : Int = repair_nearby_convoys(ship, convoys, parts, 9.0)
        if fixed > 0 {
          score = score + fixed * 24
          msg = "Patched \{fixed} convoy ship(s)"
          msg_t = 0.9
        } else if ship.repair_cd <= 0.0 {
          msg = "No damaged convoy in range"
          msg_t = 0.55
          ship.repair_cd = 0.25
        }
      }

      if scan_press {
        let (ok, px, py, kind) = scan_hazards(ship, ice, storms)
        if ok {
          ship.ping_x = px
          ship.ping_y = py
          if kind == 1 {
            msg = "Sonar: dense ice ahead"
          } else {
            msg = "Sonar: storm vector detected"
          }
          msg_t = 0.95
          burst(parts, ship.x, ship.y, 8, 2)
          burst(parts, px, py, 12, 2)
        } else if ship.sonar_cd <= 1.0 {
          msg = "Sonar clear"
          msg_t = 0.6
        }
      }

      update_storms(storms, dt, world_l, world_t, world_r, world_b)
      last_hazard_sum = update_ice(
        ice, dt, world_l, world_t, world_r, world_b, scene_t,
      )

      let hazard_damage : Float = update_player_damage_from_hazards(
        ship, ice, storms, dt,
      )
      if hazard_damage > 0.0 {
        ship.hull = maxf(0.0, ship.hull - hazard_damage)
      }

      let (delivered_now, sunk_now, convoy_score, wait_now) = update_convoys(
        convoys, route, ice, storms, parts, dt,
      )
      delivered = delivered + delivered_now
      sunk = sunk + sunk_now
      score = score + convoy_score
      wait_accum = wait_accum + wait_now

      if delivered_now > 0 {
        msg = "Convoy delivered +\{delivered_now}"
        msg_t = 1.0
      }
      if sunk_now > 0 {
        msg = "Convoy lost +\{sunk_now}"
        msg_t = 1.0
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        let spawned : Bool = spawn_convoy(convoys, route, tier, convoy_serial)
        if spawned {
          convoy_serial = convoy_serial + 1
          spawn_cd = 3.1 - Float::from_int(tier) * 0.2 + randf(0.0, 1.3)
          if spawn_cd < 1.0 {
            spawn_cd = 1.0
          }
        } else {
          spawn_cd = 0.7
        }
      }

      storm_cd = storm_cd - dt
      if storm_cd <= 0.0 {
        let max_storms : Int = 2 + tier / 2
        if active_storm_count(storms) < max_storms {
          ignore(spawn_storm(storms, world_l, world_t, world_r, world_b, tier))
        }
        storm_cd = randf(6.2, 10.8) - Float::from_int(tier) * 0.26
        if storm_cd < 2.4 {
          storm_cd = 2.4
        }
      }

      // Keep pressure if player over-clears all ice lanes
      if active_ice_count(ice) < 38 {
        let mut refill : Int = 0
        while refill < 10 {
          let x : Float = randf(world_l + 20.0, world_r - 20.0)
          let y : Float = randf(world_t + 20.0, world_b - 20.0)
          let mut ok : Bool = true
          for k = 0; k < route.length(); k = k + 1 {
            if dist2(x, y, route[k].x, route[k].y) < 42.0 * 42.0 {
              ok = false
              break
            }
          }
          if not(ok) {
            refill = refill + 1
            continue
          }

          for k = 0; k < ice.length(); k = k + 1 {
            if not(ice[k].active) {
              ice[k].active = true
              ice[k].x = x
              ice[k].y = y
              ice[k].vx = randf(-22.0, 22.0)
              ice[k].vy = randf(-22.0, 22.0)
              ice[k].radius = randf(10.0, 24.0)
              ice[k].hard = randf(30.0, 80.0)
              ice[k].crack_t = 0.0
              ice[k].tone = randf(0.0, 1.0)
              break
            }
          }

          refill = refill + 1
        }
      }

      if delivered >= target_delivered {
        state = 2
        msg = "Convoy secured"
        msg_t = 3.0
        burst(parts, ship.x, ship.y, 64, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Shift ended before quota"
        msg_t = 3.0
      } else if sunk >= sunk_limit {
        state = 3
        msg = "Too many convoy losses"
        msg_t = 3.0
      } else if ship.hull <= 0.0 {
        state = 3
        msg = "Icebreaker destroyed"
        msg_t = 3.0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(8, 16, 28, 255))

    draw_ocean(world_x, world_y, world_w, world_h, scene_t)
    draw_route(route)
    draw_harbors(world_x, world_y, world_w, world_h)
    draw_storms(storms, scene_t)
    draw_ice(ice, scene_t)
    draw_convoys(convoys)
    draw_player(ship, scene_t)

    if ship.sonar_t > 0.0 {
      @raylib.draw_circle(
        ship.ping_x.to_int(),
        ship.ping_y.to_int(),
        24.0 + (2.1 - ship.sonar_t) * 44.0,
        @raylib.Color::new(180, 232, 252, 100),
      )
      @raylib.draw_circle(
        ship.ping_x.to_int(),
        ship.ping_y.to_int(),
        10.0,
        @raylib.Color::new(244, 252, 255, 210),
      )
    }

    draw_particles(parts)

    let panel_x : Int = world_x + world_w + 16
    @raylib.draw_rectangle(
      panel_x,
      world_y,
      panel_w - 16,
      world_h,
      @raylib.Color::new(14, 24, 38, 245),
    )
    @raylib.draw_rectangle_lines(
      panel_x,
      world_y,
      panel_w - 16,
      world_h,
      @raylib.Color::new(126, 168, 208, 240),
    )

    @raylib.draw_text(
      "ICEBREAKER CONVOY COMMAND",
      panel_x + 16,
      36,
      34,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Cut lanes. Escort freighters. Survive storms.",
      panel_x + 16,
      78,
      20,
      @raylib.Color::new(192, 220, 248, 240),
    )

    @raylib.draw_text(
      "Time",
      panel_x + 16,
      118,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{timer.to_int()}s",
      panel_x + 102,
      118,
      30,
      @raylib.Color::new(248, 220, 152, 252),
    )

    @raylib.draw_text(
      "Delivered",
      panel_x + 16,
      154,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{delivered}/\{target_delivered}",
      panel_x + 140,
      154,
      30,
      @raylib.Color::new(138, 228, 164, 252),
    )

    @raylib.draw_text(
      "Lost",
      panel_x + 16,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{sunk}/\{sunk_limit}",
      panel_x + 84,
      190,
      30,
      @raylib.Color::new(248, 148, 158, 252),
    )

    @raylib.draw_text(
      "Tier",
      panel_x + 206,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      panel_x + 266,
      190,
      30,
      @raylib.Color::new(248, 214, 130, 252),
    )

    @raylib.draw_text(
      "Score",
      panel_x + 16,
      226,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{score}",
      panel_x + 92,
      226,
      30,
      @raylib.Color::new(156, 220, 252, 252),
    )

    @raylib.draw_text(
      "Ice cleared",
      panel_x + 16,
      262,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{ice_cleared}",
      panel_x + 154,
      262,
      30,
      @raylib.Color::new(206, 232, 252, 248),
    )

    @raylib.draw_text(
      "Traffic delay",
      panel_x + 16,
      298,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{wait_accum.to_int()}s",
      panel_x + 162,
      298,
      30,
      @raylib.Color::new(244, 204, 146, 248),
    )

    @raylib.draw_text(
      "Active convoys",
      panel_x + 16,
      334,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_convoy_count(convoys)}",
      panel_x + 182,
      334,
      30,
      @raylib.Color::new(192, 226, 252, 248),
    )

    @raylib.draw_text(
      "Ice hazard",
      panel_x + 16,
      370,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{last_hazard_sum.to_int()}",
      panel_x + 154,
      370,
      30,
      @raylib.Color::new(192, 226, 252, 248),
    )

    draw_action_bar(
      panel_x,
      414,
      "Hull",
      ship.hull,
      ship.hull_max,
      @raylib.Color::new(132, 228, 162, 252),
    )
    draw_action_bar(
      panel_x,
      488,
      "Energy",
      ship.energy,
      ship.energy_max,
      @raylib.Color::new(128, 206, 252, 252),
    )
    draw_action_bar(
      panel_x,
      562,
      "Cutter Heat",
      ship.cutter_heat * 100.0,
      100.0,
      @raylib.Color::new(246, 182, 122, 252),
    )

    @raylib.draw_text(
      "Controls",
      panel_x + 16,
      642,
      30,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "WASD / Arrows : move",
      panel_x + 16,
      680,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "J / Space : hold cutter",
      panel_x + 16,
      706,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "L / U : repair nearby",
      panel_x + 16,
      732,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "K / H : sonar ping",
      panel_x + 16,
      758,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "Mobile: d-pad + CUT/FIX/SCAN",
      panel_x + 16,
      784,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )

    draw_touch_controls(sw, sh, mouse.x, mouse.y, hold)

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = world_x + world_w / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        18,
        bw,
        52,
        @raylib.Color::new(10, 18, 30, 230),
      )
      @raylib.draw_rectangle_lines(
        bx,
        18,
        bw,
        52,
        @raylib.Color::new(188, 214, 248, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        30,
        30,
        @raylib.Color::new(238, 248, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 14, 24, 214))
      @raylib.draw_text(
        "ICEBREAKER CONVOY COMMAND",
        sw / 2 - 470,
        146,
        82,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Arctic logistics survival",
        sw / 2 - 206,
        238,
        38,
        @raylib.Color::new(194, 220, 252, 248),
      )

      @raylib.draw_rectangle(
        sw / 2 - 520,
        304,
        1040,
        288,
        @raylib.Color::new(16, 26, 42, 238),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 520,
        304,
        1040,
        288,
        @raylib.Color::new(166, 196, 244, 244),
      )

      @raylib.draw_text(
        "Mission",
        sw / 2 - 484,
        338,
        34,
        @raylib.Color::new(236, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Escort freighters from BASE to EXIT",
        sw / 2 - 484,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Cut through heavy ice before convoy stalls",
        sw / 2 - 484,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Repair damaged ships and dodge storms",
        sw / 2 - 484,
        454,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Touch controls fully supported",
        sw / 2 - 484,
        490,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_text(
        "Failure",
        sw / 2 + 72,
        338,
        34,
        @raylib.Color::new(236, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Timer reaches zero",
        sw / 2 + 72,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Too many convoy losses",
        sw / 2 + 72,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Icebreaker hull collapses",
        sw / 2 + 72,
        454,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )

      let hover_start : Bool = inside_rect(
        mouse.x,
        mouse.y,
        sw / 2 - 210,
        638,
        420,
        94,
      )
      draw_button(sw / 2 - 210, 638, 420, 94, "START OPERATION", hover_start)
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 24, 14, 204))
      @raylib.draw_text(
        "CONVOY SECURED",
        sw / 2 - 274,
        194,
        86,
        @raylib.Color::new(168, 248, 186, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{target_delivered}",
        sw / 2 - 190,
        336,
        42,
        @raylib.Color::new(236, 248, 240, 252),
      )
      @raylib.draw_text(
        "Score \{score}",
        sw / 2 - 100,
        390,
        38,
        @raylib.Color::new(250, 234, 164, 248),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 96,
        472,
        34,
        @raylib.Color::new(214, 234, 252, 244),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(26, 8, 14, 214))
      @raylib.draw_text(
        "OPERATION FAILED",
        sw / 2 - 286,
        194,
        84,
        @raylib.Color::new(248, 156, 166, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{target_delivered}",
        sw / 2 - 190,
        334,
        42,
        @raylib.Color::new(246, 230, 236, 252),
      )
      @raylib.draw_text(
        "Losses \{sunk}/\{sunk_limit}",
        sw / 2 - 124,
        386,
        38,
        @raylib.Color::new(252, 190, 198, 246),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 96,
        468,
        34,
        @raylib.Color::new(220, 234, 252, 244),
      )
    }
  }
}
