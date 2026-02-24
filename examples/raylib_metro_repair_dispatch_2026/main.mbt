///|
let sw : Int = 1366

///|
let sh : Int = 768

///|
let world_x : Int = 24

///|
let world_y : Int = 24

///|
let world_w : Int = 930

///|
let world_h : Int = 720

///|
let world_l : Float = Float::from_int(world_x)

///|
let world_t : Float = Float::from_int(world_y)

///|
let world_r : Float = Float::from_int(world_x + world_w)

///|
let world_b : Float = Float::from_int(world_y + world_h)

///|
let panel_x : Int = world_x + world_w + 16

///|
let panel_w : Int = sw - panel_x - 20

///|
let max_stations : Int = 16

///|
let max_segments : Int = 36

///|
let max_trains : Int = 14

///|
let max_particles : Int = 420

///|
struct Drone {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut energy : Float
  energy_max : Float
  mut hull : Float
  hull_max : Float
  mut repair_cd : Float
  mut scan_cd : Float
  mut scan_t : Float
  mut target_seg : Int
  wobble : Float
}

///|
struct Station {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut line_mask : Int
  mut crowd : Int
  mut spawn_cd : Float
  mut wait_t : Float
  mut strain : Float
  mut name : String
}

///|
struct Segment {
  mut active : Bool
  mut a : Int
  mut b : Int
  mut line : Int
  mut health : Float
  mut fault_t : Float
  mut wear : Float
  mut traffic : Float
  mut spark_cd : Float
}

///|
struct Train {
  mut active : Bool
  mut route_id : Int
  mut route_pos : Int
  mut dir : Int
  mut t : Float
  mut speed : Float
  mut passengers : Int
  mut capacity : Int
  mut delay_t : Float
  mut blink_t : Float
  mut color_id : Int
}

///|
struct Particle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut life : Float
  mut pulse : Float
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
fn clear_stations(stations : Array[Station]) -> Unit {
  for i = 0; i < stations.length(); i = i + 1 {
    stations[i].active = false
    stations[i].x = 0.0
    stations[i].y = 0.0
    stations[i].line_mask = 0
    stations[i].crowd = 0
    stations[i].spawn_cd = 0.0
    stations[i].wait_t = 0.0
    stations[i].strain = 0.0
    stations[i].name = ""
  }
}

///|
fn clear_segments(segments : Array[Segment]) -> Unit {
  for i = 0; i < segments.length(); i = i + 1 {
    segments[i].active = false
    segments[i].a = -1
    segments[i].b = -1
    segments[i].line = 0
    segments[i].health = 0.0
    segments[i].fault_t = 0.0
    segments[i].wear = 0.0
    segments[i].traffic = 0.0
    segments[i].spark_cd = 0.0
  }
}

///|
fn clear_trains(trains : Array[Train]) -> Unit {
  for i = 0; i < trains.length(); i = i + 1 {
    trains[i].active = false
    trains[i].route_id = 0
    trains[i].route_pos = 0
    trains[i].dir = 1
    trains[i].t = 0.0
    trains[i].speed = 0.0
    trains[i].passengers = 0
    trains[i].capacity = 0
    trains[i].delay_t = 0.0
    trains[i].blink_t = 0.0
    trains[i].color_id = 0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].kind = 0
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].life = 0.0
    parts[i].pulse = 0.0
  }
}

///|
fn add_station(
  stations : Array[Station],
  x : Float,
  y : Float,
  line_mask : Int,
  crowd : Int,
  name : String,
) -> Int {
  for i = 0; i < stations.length(); i = i + 1 {
    if not(stations[i].active) {
      stations[i].active = true
      stations[i].x = x
      stations[i].y = y
      stations[i].line_mask = line_mask
      stations[i].crowd = crowd
      stations[i].spawn_cd = randf(1.0, 2.4)
      stations[i].wait_t = 0.0
      stations[i].strain = 0.0
      stations[i].name = name
      return i
    }
  }
  -1
}

///|
fn add_segment(segments : Array[Segment], a : Int, b : Int, line : Int) -> Int {
  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) {
      segments[i].active = true
      segments[i].a = a
      segments[i].b = b
      segments[i].line = line
      segments[i].health = randf(84.0, 100.0)
      segments[i].fault_t = 0.0
      segments[i].wear = 0.0
      segments[i].traffic = 0.0
      segments[i].spark_cd = randf(0.4, 1.4)
      return i
    }
  }
  -1
}

///|
fn add_train(
  trains : Array[Train],
  route_id : Int,
  route_pos : Int,
  dir : Int,
  speed : Float,
  capacity : Int,
  color_id : Int,
) -> Int {
  for i = 0; i < trains.length(); i = i + 1 {
    if not(trains[i].active) {
      trains[i].active = true
      trains[i].route_id = route_id
      trains[i].route_pos = route_pos
      trains[i].dir = if dir >= 0 { 1 } else { -1 }
      trains[i].t = randf(0.0, 0.8)
      trains[i].speed = speed
      trains[i].passengers = @raylib.get_random_value(6, capacity / 2)
      trains[i].capacity = capacity
      trains[i].delay_t = 0.0
      trains[i].blink_t = 0.0
      trains[i].color_id = color_id
      return i
    }
  }
  -1
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
      parts[i].kind = kind
      parts[i].x = x
      parts[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(22.0, 230.0)
      parts[i].vx = @math.cosf(a) * s
      parts[i].vy = @math.sinf(a) * s
      parts[i].size = randf(2.0, 8.0)
      parts[i].life = randf(0.2, 0.9)
      parts[i].pulse = randf(0.0, 20.0)
      return
    }
  }
}

///|
fn burst_particles(
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

    parts[i].pulse = parts[i].pulse + dt
    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt
    parts[i].vx = parts[i].vx * (1.0 - dt * 2.2)
    parts[i].vy = parts[i].vy * (1.0 - dt * 2.1) + 8.0 * dt
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let c = if parts[i].kind == 0 {
      @raylib.Color::new(246, 214, 124, 236)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(130, 210, 252, 236)
    } else if parts[i].kind == 2 {
      @raylib.Color::new(130, 236, 156, 236)
    } else if parts[i].kind == 3 {
      @raylib.Color::new(250, 130, 146, 236)
    } else {
      @raylib.Color::new(198, 198, 216, 226)
    }

    @raylib.draw_circle(
      parts[i].x.to_int(),
      parts[i].y.to_int(),
      parts[i].size * parts[i].life * 2.0,
      c,
    )
  }
}

///|
fn route_len(route : Array[Int]) -> Int {
  route.length()
}

///|
fn route_station(route : Array[Int], pos : Int) -> Int {
  route[clampi(pos, 0, route.length() - 1)]
}

///|
fn next_route_pos(route : Array[Int], pos : Int, dir : Int) -> (Int, Int) {
  let mut ndir : Int = if dir >= 0 { 1 } else { -1 }
  let mut npos : Int = pos + ndir

  if npos < 0 || npos >= route.length() {
    ndir = -ndir
    npos = pos + ndir
  }

  (npos, ndir)
}

///|
fn find_segment(segments : Array[Segment], a : Int, b : Int) -> Int {
  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) {
      continue
    }
    let x : Int = segments[i].a
    let y : Int = segments[i].b
    if (x == a && y == b) || (x == b && y == a) {
      return i
    }
  }
  -1
}

///|
fn station_pos(stations : Array[Station], sid : Int) -> (Float, Float) {
  (stations[sid].x, stations[sid].y)
}

///|
fn train_segment_points(
  train : Train,
  stations : Array[Station],
  route0 : Array[Int],
  route1 : Array[Int],
) -> (Float, Float, Float, Float, Int, Int) {
  let route : Array[Int] = if train.route_id == 0 { route0 } else { route1 }
  let cur_pos : Int = clampi(train.route_pos, 0, route.length() - 1)
  let cur_sid : Int = route_station(route, cur_pos)

  let (next_pos, _ndir) = next_route_pos(route, cur_pos, train.dir)
  let next_sid : Int = route_station(route, next_pos)

  let (ax, ay) = station_pos(stations, cur_sid)
  let (bx, by) = station_pos(stations, next_sid)
  (ax, ay, bx, by, cur_sid, next_sid)
}

///|
fn setup_network(
  stations : Array[Station],
  segments : Array[Segment],
  trains : Array[Train],
) -> (Array[Int], Array[Int]) {
  clear_stations(stations)
  clear_segments(segments)
  clear_trains(trains)

  // line A stations
  ignore(add_station(stations, 120.0, 140.0, 1, 16, "Harbor")) // 0
  ignore(add_station(stations, 268.0, 196.0, 1, 14, "Old Town")) // 1
  ignore(add_station(stations, 428.0, 242.0, 3, 18, "Central X")) // 2 interchange
  ignore(add_station(stations, 604.0, 208.0, 1, 16, "Arena")) // 3
  ignore(add_station(stations, 764.0, 164.0, 1, 15, "Museum")) // 4
  ignore(add_station(stations, 896.0, 110.0, 1, 17, "Hilltop")) // 5

  // line B stations
  ignore(add_station(stations, 136.0, 566.0, 2, 12, "Dock South")) // 6
  ignore(add_station(stations, 292.0, 494.0, 2, 14, "Cedar")) // 7
  ignore(add_station(stations, 562.0, 386.0, 2, 16, "Orbit")) // 8
  ignore(add_station(stations, 742.0, 472.0, 2, 14, "Garden")) // 9
  ignore(add_station(stations, 888.0, 588.0, 2, 18, "Bay End")) // 10

  let route0 : Array[Int] = [0, 1, 2, 3, 4, 5]
  let route1 : Array[Int] = [6, 7, 2, 8, 9, 10]

  for i = 0; i + 1 < route0.length(); i = i + 1 {
    ignore(add_segment(segments, route0[i], route0[i + 1], 0))
  }
  for i = 0; i + 1 < route1.length(); i = i + 1 {
    ignore(add_segment(segments, route1[i], route1[i + 1], 1))
  }

  // a few cross connectors
  ignore(add_segment(segments, 1, 7, 2))
  ignore(add_segment(segments, 3, 8, 2))
  ignore(add_segment(segments, 4, 9, 2))

  // trains
  ignore(add_train(trains, 0, 0, 1, 0.22, 28, 0))
  ignore(add_train(trains, 0, 4, -1, 0.20, 26, 1))
  ignore(add_train(trains, 1, 0, 1, 0.21, 24, 2))
  ignore(add_train(trains, 1, 4, -1, 0.23, 24, 3))
  ignore(add_train(trains, 0, 2, 1, 0.18, 30, 4))

  (route0, route1)
}

///|
fn count_faults(segments : Array[Segment]) -> Int {
  let mut n : Int = 0
  for i = 0; i < segments.length(); i = i + 1 {
    if segments[i].active && segments[i].fault_t > 0.0 {
      n = n + 1
    }
  }
  n
}

///|
fn count_active_segments(segments : Array[Segment]) -> Int {
  let mut n : Int = 0
  for i = 0; i < segments.length(); i = i + 1 {
    if segments[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn update_stations(stations : Array[Station], dt : Float, tier : Int) -> Float {
  let mut total_strain : Float = 0.0

  for i = 0; i < stations.length(); i = i + 1 {
    if not(stations[i].active) {
      continue
    }

    stations[i].spawn_cd = stations[i].spawn_cd - dt
    if stations[i].spawn_cd <= 0.0 {
      let add_n : Int = @raylib.get_random_value(0, 2 + tier / 2)
      stations[i].crowd = stations[i].crowd + add_n
      stations[i].crowd = clampi(stations[i].crowd, 0, 180)

      let mut next_cd : Float = randf(1.0, 2.4) - Float::from_int(tier) * 0.03
      if next_cd < 0.42 {
        next_cd = 0.42
      }
      stations[i].spawn_cd = next_cd
    }

    stations[i].wait_t = stations[i].wait_t +
      dt * Float::from_int(stations[i].crowd) * 0.015
    if stations[i].wait_t > 1000.0 {
      stations[i].wait_t = 1000.0
    }

    stations[i].strain = Float::from_int(stations[i].crowd) * 0.75 +
      stations[i].wait_t * 0.03
    total_strain = total_strain + stations[i].strain
  }

  total_strain
}

///|
fn update_segments(
  segments : Array[Segment],
  stations : Array[Station],
  dt : Float,
  tier : Int,
  parts : Array[Particle],
) -> (Int, Float) {
  let mut new_faults : Int = 0
  let mut health_sum : Float = 0.0

  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) {
      continue
    }

    segments[i].traffic = segments[i].traffic * (1.0 - dt * 0.6)
    if segments[i].traffic < 0.0 {
      segments[i].traffic = 0.0
    }

    segments[i].wear = segments[i].wear +
      dt * (0.4 + Float::from_int(tier) * 0.04)
    segments[i].wear = clampf(segments[i].wear, 0.0, 1000.0)

    segments[i].health = segments[i].health -
      dt * (0.06 + segments[i].traffic * 0.002 + segments[i].wear * 0.0002)
    segments[i].health = clampf(segments[i].health, 0.0, 100.0)

    if segments[i].fault_t > 0.0 {
      segments[i].fault_t = segments[i].fault_t - dt
      if segments[i].fault_t < 0.0 {
        segments[i].fault_t = 0.0
      }

      segments[i].spark_cd = segments[i].spark_cd - dt
      if segments[i].spark_cd <= 0.0 {
        segments[i].spark_cd = randf(0.3, 0.9)
        let ax : Float = stations[segments[i].a].x
        let ay : Float = stations[segments[i].a].y
        let bx : Float = stations[segments[i].b].x
        let by : Float = stations[segments[i].b].y
        let t : Float = randf(0.1, 0.9)
        burst_particles(parts, ax + (bx - ax) * t, ay + (by - ay) * t, 4, 3)
      }
    } else {
      let risk : Float = (100.0 - segments[i].health) * 0.008 +
        Float::from_int(tier) * 0.002
      if @raylib.get_random_value(0, 9999) < (risk * 10000.0 * dt).to_int() {
        segments[i].fault_t = randf(6.0, 14.0)
        segments[i].health = segments[i].health - randf(8.0, 18.0)
        if segments[i].health < 0.0 {
          segments[i].health = 0.0
        }
        new_faults = new_faults + 1

        let mx : Float = (stations[segments[i].a].x + stations[segments[i].b].x) *
          0.5
        let my : Float = (stations[segments[i].a].y + stations[segments[i].b].y) *
          0.5
        burst_particles(parts, mx, my, 16, 3)
      }
    }

    health_sum = health_sum + segments[i].health
  }

  (new_faults, health_sum)
}

///|
fn update_trains(
  trains : Array[Train],
  segments : Array[Segment],
  stations : Array[Station],
  route0 : Array[Int],
  route1 : Array[Int],
  dt : Float,
  parts : Array[Particle],
) -> (Int, Float, Int) {
  let mut delivered_gain : Int = 0
  let mut delay_gain : Float = 0.0
  let mut boarded_gain : Int = 0

  for i = 0; i < trains.length(); i = i + 1 {
    if not(trains[i].active) {
      continue
    }

    if trains[i].blink_t > 0.0 {
      trains[i].blink_t = trains[i].blink_t - dt
      if trains[i].blink_t < 0.0 {
        trains[i].blink_t = 0.0
      }
    }

    let route : Array[Int] = if trains[i].route_id == 0 {
      route0
    } else {
      route1
    }
    let cur_pos : Int = clampi(trains[i].route_pos, 0, route_len(route) - 1)
    let cur_sid : Int = route_station(route, cur_pos)

    let (next_pos, ndir) = next_route_pos(route, cur_pos, trains[i].dir)
    let next_sid : Int = route_station(route, next_pos)

    let seg_id : Int = find_segment(segments, cur_sid, next_sid)
    if seg_id < 0 {
      trains[i].delay_t = trains[i].delay_t + dt
      delay_gain = delay_gain + dt
      continue
    }

    if segments[seg_id].fault_t > 0.0 {
      trains[i].delay_t = trains[i].delay_t + dt
      trains[i].blink_t = 0.1
      delay_gain = delay_gain + dt

      stations[cur_sid].wait_t = stations[cur_sid].wait_t + dt * 0.8
      stations[next_sid].wait_t = stations[next_sid].wait_t + dt * 0.6

      continue
    }

    let (ax, ay) = station_pos(stations, cur_sid)
    let (bx, by) = station_pos(stations, next_sid)
    let dist : Float = maxf(20.0, dist2(ax, ay, bx, by).sqrt())

    let traffic_slow : Float = 1.0 -
      clampf(segments[seg_id].traffic * 0.02, 0.0, 0.45)
    let step : Float = dt * trains[i].speed * traffic_slow * (130.0 / dist)

    trains[i].t = trains[i].t + step
    segments[seg_id].traffic = segments[seg_id].traffic + 1.8 * dt
    segments[seg_id].wear = segments[seg_id].wear +
      dt * (0.8 + Float::from_int(trains[i].passengers) * 0.02)

    if trains[i].t >= 1.0 {
      trains[i].t = trains[i].t - 1.0
      trains[i].route_pos = next_pos
      trains[i].dir = ndir

      // arrival at next station
      delivered_gain = delivered_gain + trains[i].passengers
      trains[i].passengers = 0

      let board : Int = if stations[next_sid].crowd < trains[i].capacity {
        stations[next_sid].crowd
      } else {
        trains[i].capacity
      }
      stations[next_sid].crowd = stations[next_sid].crowd - board
      boarded_gain = boarded_gain + board
      trains[i].passengers = board

      stations[next_sid].wait_t = stations[next_sid].wait_t * 0.65
      trains[i].delay_t = trains[i].delay_t * 0.7

      burst_particles(
        parts,
        stations[next_sid].x,
        stations[next_sid].y,
        5 + board / 4,
        1,
      )
    }
  }

  (delivered_gain, delay_gain, boarded_gain)
}

///|
fn nearest_faulty_segment(
  segments : Array[Segment],
  stations : Array[Station],
  x : Float,
  y : Float,
) -> (Int, Float, Float, Float) {
  let mut best : Int = -1
  let mut best_d2 : Float = 99999999.0
  let mut best_x : Float = x
  let mut best_y : Float = y

  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) || segments[i].fault_t <= 0.0 {
      continue
    }

    let mx : Float = (stations[segments[i].a].x + stations[segments[i].b].x) *
      0.5
    let my : Float = (stations[segments[i].a].y + stations[segments[i].b].y) *
      0.5
    let d2 : Float = dist2(x, y, mx, my)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
      best_x = mx
      best_y = my
    }
  }

  (best, best_d2, best_x, best_y)
}

///|
fn apply_repair(
  drone : Drone,
  segments : Array[Segment],
  stations : Array[Station],
  parts : Array[Particle],
) -> Int {
  if drone.repair_cd > 0.0 || drone.energy <= 0.0 {
    return 0
  }

  let mut repaired : Int = 0

  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) {
      continue
    }

    let mx : Float = (stations[segments[i].a].x + stations[segments[i].b].x) *
      0.5
    let my : Float = (stations[segments[i].a].y + stations[segments[i].b].y) *
      0.5
    let d2 : Float = dist2(drone.x, drone.y, mx, my)

    if d2 <= 64.0 * 64.0 {
      if segments[i].fault_t > 0.0 {
        segments[i].fault_t = segments[i].fault_t - 4.0
        if segments[i].fault_t < 0.0 {
          segments[i].fault_t = 0.0
        }
        segments[i].health = minf(100.0, segments[i].health + 12.0)
        segments[i].wear = maxf(0.0, segments[i].wear - 8.0)
        repaired = repaired + 1
        burst_particles(parts, mx, my, 14, 2)
      } else if segments[i].health < 98.0 {
        segments[i].health = minf(100.0, segments[i].health + 8.0)
        segments[i].wear = maxf(0.0, segments[i].wear - 4.0)
        repaired = repaired + 1
        burst_particles(parts, mx, my, 8, 2)
      }
    }
  }

  if repaired > 0 {
    drone.energy = drone.energy - 8.0
    if drone.energy < 0.0 {
      drone.energy = 0.0
    }
    drone.repair_cd = 0.28
  }

  repaired
}

///|
fn draw_world_bg(t : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    world_x - 10,
    world_y - 10,
    world_w + 20,
    world_h + 20,
    @raylib.Color::new(20, 30, 52, 255),
    @raylib.Color::new(14, 20, 34, 255),
  )

  for i = 0; i < 36; i = i + 1 {
    let fi : Float = Float::from_int(i)
    let x : Int = (fi * 70.0 + t * (16.0 + Float::from_int(i % 5) * 4.0)).to_int() %
      world_w +
      world_x
    let y : Int = (fi * 122.0 + t * 22.0).to_int() % world_h + world_y
    @raylib.draw_circle(
      x,
      y,
      1.0 + Float::from_int(i % 3),
      @raylib.Color::new(102, 138, 206, 96),
    )
  }

  // road grid hint
  for i = 0; i < 14; i = i + 1 {
    let y : Int = world_y + i * 52
    @raylib.draw_line(
      world_x,
      y,
      world_x + world_w,
      y,
      @raylib.Color::new(40, 52, 78, 56),
    )
  }
  for i = 0; i < 18; i = i + 1 {
    let x : Int = world_x + i * 52
    @raylib.draw_line(
      x,
      world_y,
      x,
      world_y + world_h,
      @raylib.Color::new(40, 52, 78, 56),
    )
  }
}

///|
fn segment_color(seg : Segment, selected : Bool) -> @raylib.Color {
  if seg.fault_t > 0.0 {
    if selected {
      @raylib.Color::new(252, 166, 176, 252)
    } else {
      @raylib.Color::new(244, 122, 138, 244)
    }
  } else if seg.health > 70.0 {
    if selected {
      @raylib.Color::new(172, 240, 194, 248)
    } else {
      @raylib.Color::new(124, 224, 172, 232)
    }
  } else if seg.health > 35.0 {
    if selected {
      @raylib.Color::new(252, 230, 166, 250)
    } else {
      @raylib.Color::new(248, 210, 126, 236)
    }
  } else if selected {
    @raylib.Color::new(252, 184, 144, 250)
  } else {
    @raylib.Color::new(244, 150, 110, 236)
  }
}

///|
fn draw_segments(
  segments : Array[Segment],
  stations : Array[Station],
  selected_fault : Int,
  t : Float,
) -> Unit {
  for i = 0; i < segments.length(); i = i + 1 {
    if not(segments[i].active) {
      continue
    }

    let ax : Float = stations[segments[i].a].x
    let ay : Float = stations[segments[i].a].y
    let bx : Float = stations[segments[i].b].x
    let by : Float = stations[segments[i].b].y

    let col = segment_color(segments[i], i == selected_fault)
    let thick : Float = if segments[i].line == 0 {
      9.0
    } else if segments[i].line == 1 {
      8.0
    } else {
      7.0
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(ax, ay),
      @raylib.Vector2::new(bx, by),
      thick,
      col,
    )

    if segments[i].fault_t > 0.0 {
      let pulse : Float = @math.sinf(t * 14.0 + Float::from_int(i) * 0.9) * 0.5 +
        0.5
      let mx : Float = (ax + bx) * 0.5
      let my : Float = (ay + by) * 0.5
      @raylib.draw_circle(
        mx.to_int(),
        my.to_int(),
        7.0 + pulse * 4.0,
        @raylib.Color::new(252, 214, 220, 232),
      )
    }

    // tiny health tag
    let mx : Int = ((ax + bx) * 0.5).to_int()
    let my : Int = ((ay + by) * 0.5).to_int()
    @raylib.draw_text(
      "\{segments[i].health.to_int()}%",
      mx - 22,
      my - 10,
      16,
      @raylib.Color::new(236, 242, 252, 224),
    )
  }
}

///|
fn draw_stations(stations : Array[Station]) -> Unit {
  for i = 0; i < stations.length(); i = i + 1 {
    if not(stations[i].active) {
      continue
    }

    let col = if stations[i].line_mask == 1 {
      @raylib.Color::new(110, 196, 252, 246)
    } else if stations[i].line_mask == 2 {
      @raylib.Color::new(140, 228, 146, 246)
    } else {
      @raylib.Color::new(222, 184, 252, 246)
    }

    let r : Float = 16.0 +
      clampf(Float::from_int(stations[i].crowd) * 0.03, 0.0, 16.0)
    @raylib.draw_circle(stations[i].x.to_int(), stations[i].y.to_int(), r, col)
    @raylib.draw_circle(
      stations[i].x.to_int(),
      stations[i].y.to_int(),
      8.0,
      @raylib.Color::new(24, 34, 52, 248),
    )

    @raylib.draw_text(
      stations[i].name,
      (stations[i].x - 54.0).to_int(),
      (stations[i].y - r - 22.0).to_int(),
      18,
      @raylib.Color::new(232, 242, 255, 242),
    )

    @raylib.draw_text(
      "\{stations[i].crowd}",
      (stations[i].x - 8.0).to_int(),
      (stations[i].y - 8.0).to_int(),
      20,
      @raylib.Color::new(246, 250, 252, 248),
    )
  }
}

///|
fn train_color(id : Int) -> @raylib.Color {
  if id % 5 == 0 {
    @raylib.Color::new(246, 194, 118, 252)
  } else if id % 5 == 1 {
    @raylib.Color::new(134, 214, 252, 252)
  } else if id % 5 == 2 {
    @raylib.Color::new(136, 238, 164, 252)
  } else if id % 5 == 3 {
    @raylib.Color::new(244, 158, 176, 252)
  } else {
    @raylib.Color::new(208, 186, 252, 252)
  }
}

///|
fn draw_trains(
  trains : Array[Train],
  stations : Array[Station],
  route0 : Array[Int],
  route1 : Array[Int],
) -> Unit {
  for i = 0; i < trains.length(); i = i + 1 {
    if not(trains[i].active) {
      continue
    }

    let (ax, ay, bx, by, _cur_sid, _next_sid) = train_segment_points(
      trains[i],
      stations,
      route0,
      route1,
    )
    let x : Float = ax + (bx - ax) * trains[i].t
    let y : Float = ay + (by - ay) * trains[i].t

    let col = if trains[i].delay_t > 1.0 {
      @raylib.Color::new(244, 138, 146, 252)
    } else {
      train_color(trains[i].color_id)
    }

    @raylib.draw_rectangle((x - 12.0).to_int(), (y - 8.0).to_int(), 24, 16, col)
    @raylib.draw_rectangle_lines(
      (x - 12.0).to_int(),
      (y - 8.0).to_int(),
      24,
      16,
      @raylib.Color::new(26, 34, 50, 252),
    )

    @raylib.draw_text(
      "\{trains[i].passengers}",
      (x - 7.0).to_int(),
      (y - 26.0).to_int(),
      18,
      @raylib.Color::new(242, 246, 254, 246),
    )

    if trains[i].blink_t > 0.0 {
      let a : Int = clampi((trains[i].blink_t * 400.0).to_int(), 0, 255)
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        16.0,
        @raylib.Color::new(250, 214, 220, a),
      )
    }
  }
}

///|
fn draw_drone(drone : Drone, t : Float) -> Unit {
  let bob : Float = @math.sinf(t * 10.0 + drone.wobble) * 2.0
  let x : Float = drone.x
  let y : Float = drone.y + bob

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    13.0,
    @raylib.Color::new(244, 226, 124, 252),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    8.0,
    @raylib.Color::new(66, 84, 120, 252),
  )

  // rotor arms
  let arm : Float = 20.0 + @math.sinf(t * 20.0) * 3.0
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - arm, y),
    @raylib.Vector2::new(x + arm, y),
    3.0,
    @raylib.Color::new(222, 234, 248, 240),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - arm),
    @raylib.Vector2::new(x, y + arm),
    3.0,
    @raylib.Color::new(222, 234, 248, 240),
  )
}

///|
fn draw_touch_ui() -> Unit {
  let pad_x : Int = 30
  let pad_y : Int = sh - 194

  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y,
    76,
    58,
    @raylib.Color::new(80, 104, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 104, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 104, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 168,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 104, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y + 136,
    76,
    58,
    @raylib.Color::new(80, 104, 154, 160),
  )

  @raylib.draw_text(
    "UP",
    pad_x + 107,
    pad_y + 16,
    24,
    @raylib.Color::new(236, 244, 255, 238),
  )
  @raylib.draw_text(
    "LT",
    pad_x + 24,
    pad_y + 84,
    24,
    @raylib.Color::new(236, 244, 255, 238),
  )
  @raylib.draw_text(
    "RT",
    pad_x + 188,
    pad_y + 84,
    24,
    @raylib.Color::new(236, 244, 255, 238),
  )
  @raylib.draw_text(
    "DN",
    pad_x + 103,
    pad_y + 152,
    24,
    @raylib.Color::new(236, 244, 255, 238),
  )

  let repair_x : Int = sw - 286
  let repair_y : Int = sh - 178
  @raylib.draw_circle(
    repair_x,
    repair_y,
    62.0,
    @raylib.Color::new(244, 132, 108, 176),
  )
  @raylib.draw_text(
    "FIX",
    repair_x - 26,
    repair_y - 13,
    32,
    @raylib.Color::new(250, 246, 244, 248),
  )

  let scan_x : Int = sw - 158
  let scan_y : Int = sh - 248
  @raylib.draw_circle(
    scan_x,
    scan_y,
    54.0,
    @raylib.Color::new(118, 202, 132, 176),
  )
  @raylib.draw_text(
    "SCAN",
    scan_x - 34,
    scan_y - 13,
    28,
    @raylib.Color::new(244, 252, 246, 248),
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  enabled : Bool,
  hover : Bool,
) -> Unit {
  let fill = if not(enabled) {
    @raylib.Color::new(68, 76, 92, 212)
  } else if hover {
    @raylib.Color::new(112, 154, 236, 246)
  } else {
    @raylib.Color::new(86, 122, 204, 234)
  }

  @raylib.draw_rectangle(x, y, w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(214, 228, 252, 246),
  )
  let tw : Int = @raylib.measure_text(label, 23)
  @raylib.draw_text(
    label,
    x + (w - tw) / 2,
    y + h / 2 - 11,
    23,
    @raylib.Color::new(244, 248, 255, 252),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] metro repair dispatch 2026")
  @raylib.set_target_fps(60)

  let stations : Array[Station] = Array::makei(max_stations, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      line_mask: 0,
      crowd: 0,
      spawn_cd: 0.0,
      wait_t: 0.0,
      strain: 0.0,
      name: "",
    }
  })

  let segments : Array[Segment] = Array::makei(max_segments, fn(_i) {
    {
      active: false,
      a: -1,
      b: -1,
      line: 0,
      health: 0.0,
      fault_t: 0.0,
      wear: 0.0,
      traffic: 0.0,
      spark_cd: 0.0,
    }
  })

  let trains : Array[Train] = Array::makei(max_trains, fn(_i) {
    {
      active: false,
      route_id: 0,
      route_pos: 0,
      dir: 1,
      t: 0.0,
      speed: 0.0,
      passengers: 0,
      capacity: 0,
      delay_t: 0.0,
      blink_t: 0.0,
      color_id: 0,
    }
  })

  let parts : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      life: 0.0,
      pulse: 0.0,
    }
  })

  let route0 : Array[Int] = []
  let route1 : Array[Int] = []

  let drone : Drone = {
    x: 130.0,
    y: 110.0,
    vx: 0.0,
    vy: 0.0,
    energy: 100.0,
    energy_max: 100.0,
    hull: 100.0,
    hull_max: 100.0,
    repair_cd: 0.0,
    scan_cd: 0.0,
    scan_t: 0.0,
    target_seg: -1,
    wobble: randf(0.0, 20.0),
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 320.0
  let mut delivered : Int = 0
  let mut target_delivered : Int = 920
  let mut score : Int = 0
  let mut tier : Int = 1
  let mut strain_total : Float = 0.0
  let mut delay_accum : Float = 0.0
  let mut outages_handled : Int = 0
  let mut crowd_peak : Int = 0

  let mut event_cd : Float = 8.0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  fn reset_run() -> Unit {
    let (r0, r1) = setup_network(stations, segments, trains)
    route0.clear()
    route1.clear()
    for i = 0; i < r0.length(); i = i + 1 {
      route0.push(r0[i])
    }
    for i = 0; i < r1.length(); i = i + 1 {
      route1.push(r1[i])
    }

    clear_particles(parts)

    drone.x = 128.0
    drone.y = 108.0
    drone.vx = 0.0
    drone.vy = 0.0
    drone.energy = 100.0
    drone.hull = 100.0
    drone.repair_cd = 0.0
    drone.scan_cd = 0.0
    drone.scan_t = 0.0
    drone.target_seg = -1

    timer = 320.0
    delivered = 0
    target_delivered = 920
    score = 0
    tier = 1
    strain_total = 0.0
    delay_accum = 0.0
    outages_handled = 0
    crowd_peak = 0

    event_cd = 8.0

    msg = "Dispatch online"
    msg_t = 1.8
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    scene_t = scene_t + dt
    while scene_t > 100000.0 {
      scene_t = scene_t - 100000.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    update_particles(parts, dt)

    if state == 0 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      tier = 1 + delivered / 180
      if tier > 8 {
        tier = 8
      }

      if drone.repair_cd > 0.0 {
        drone.repair_cd = drone.repair_cd - dt
        if drone.repair_cd < 0.0 {
          drone.repair_cd = 0.0
        }
      }
      if drone.scan_cd > 0.0 {
        drone.scan_cd = drone.scan_cd - dt
        if drone.scan_cd < 0.0 {
          drone.scan_cd = 0.0
        }
      }
      if drone.scan_t > 0.0 {
        drone.scan_t = drone.scan_t - dt
        if drone.scan_t < 0.0 {
          drone.scan_t = 0.0
        }
      }

      // input
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut repair_action : Bool = @raylib.is_key_pressed(@raylib.KeyJ) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut scan_action : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if hold {
        let pad_x : Int = 30
        let pad_y : Int = sh - 194
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 76, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 68, 76, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 68, 76, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 136, 76, 58) {
          move_d = true
        }

        let repair_x : Float = Float::from_int(sw - 286)
        let repair_y : Float = Float::from_int(sh - 178)
        if dist2(mouse.x, mouse.y, repair_x, repair_y) <= 62.0 * 62.0 {
          repair_action = true
        }
      }

      if click {
        let scan_x : Float = Float::from_int(sw - 158)
        let scan_y : Float = Float::from_int(sh - 248)
        if dist2(mouse.x, mouse.y, scan_x, scan_y) <= 54.0 * 54.0 {
          scan_action = true
        }
      }

      // drone physics
      let acc : Float = 420.0
      if move_l {
        drone.vx = drone.vx - acc * dt
      }
      if move_r {
        drone.vx = drone.vx + acc * dt
      }
      if move_u {
        drone.vy = drone.vy - acc * dt
      }
      if move_d {
        drone.vy = drone.vy + acc * dt
      }

      let drag : Float = 5.8
      drone.vx = drone.vx * (1.0 - dt * drag)
      drone.vy = drone.vy * (1.0 - dt * drag)

      let vmax : Float = 240.0
      let sp2 : Float = drone.vx * drone.vx + drone.vy * drone.vy
      if sp2 > vmax * vmax {
        let inv : Float = vmax / sp2.sqrt()
        drone.vx = drone.vx * inv
        drone.vy = drone.vy * inv
      }

      drone.x = clampf(drone.x + drone.vx * dt, world_l + 12.0, world_r - 12.0)
      drone.y = clampf(drone.y + drone.vy * dt, world_t + 12.0, world_b - 12.0)

      // energy and hull decay
      let speed_norm : Float = sp2.sqrt() / vmax
      drone.energy = drone.energy - dt * (0.7 + speed_norm * 0.6)
      if drone.energy < 0.0 {
        drone.energy = 0.0
      }

      // auto-recharge around depot area
      let depot_x : Int = world_x + 20
      let depot_y : Int = world_y + 20
      let depot_w : Int = 180
      let depot_h : Int = 110
      if inside_rect(drone.x, drone.y, depot_x, depot_y, depot_w, depot_h) {
        drone.energy = minf(drone.energy_max, drone.energy + dt * 22.0)
        drone.hull = minf(drone.hull_max, drone.hull + dt * 8.0)
      }

      // repair action
      if repair_action {
        let repaired : Int = apply_repair(drone, segments, stations, parts)
        if repaired > 0 {
          outages_handled = outages_handled + repaired
          score = score + repaired * 26
          msg = "Repaired \{repaired} segment(s)"
          msg_t = 0.95
        }
      }

      // scan action
      if scan_action && drone.scan_cd <= 0.0 {
        let (sid, d2, tx, ty) = nearest_faulty_segment(
          segments,
          stations,
          drone.x,
          drone.y,
        )
        if sid >= 0 {
          drone.target_seg = sid
          drone.scan_t = 2.0
          drone.scan_cd = 2.4
          let d : Int = d2.sqrt().to_int()
          msg = "Scan lock: fault \{d}m"
          msg_t = 1.0
          burst_particles(parts, drone.x, drone.y, 10, 2)
          burst_particles(parts, tx, ty, 12, 3)
        } else {
          drone.target_seg = -1
          drone.scan_cd = 1.2
          msg = "No active faults"
          msg_t = 0.8
        }
      }

      // station + segment + train systems
      strain_total = update_stations(stations, dt, tier)

      let (new_faults, health_sum) = update_segments(
        segments, stations, dt, tier, parts,
      )
      if new_faults > 0 {
        msg = "Grid faults +\{new_faults}"
        msg_t = 1.1
        score = score - new_faults * 12
      }

      let (delivered_gain, delay_gain, boarded_gain) = update_trains(
        trains, segments, stations, route0, route1, dt, parts,
      )
      delivered = delivered + delivered_gain
      score = score + delivered_gain * 2 + boarded_gain
      delay_accum = delay_accum + delay_gain

      if delay_gain > 0.0 {
        score = score - delay_gain.to_int()
      }

      // random shock events
      event_cd = event_cd - dt
      if event_cd <= 0.0 {
        event_cd = randf(6.0, 10.0) - Float::from_int(tier) * 0.22
        if event_cd < 2.5 {
          event_cd = 2.5
        }

        let shock_n : Int = 1 + @raylib.get_random_value(0, tier / 3)
        let mut affected : Int = 0

        for _i = 0; _i < shock_n; _i = _i + 1 {
          let sid : Int = @raylib.get_random_value(0, segments.length() - 1)
          if not(segments[sid].active) {
            continue
          }
          segments[sid].health = segments[sid].health - randf(6.0, 14.0)
          if segments[sid].health < 0.0 {
            segments[sid].health = 0.0
          }
          if segments[sid].fault_t <= 0.0 {
            segments[sid].fault_t = randf(4.0, 9.0)
          }
          affected = affected + 1

          let mx : Float = (
              stations[segments[sid].a].x + stations[segments[sid].b].x
            ) *
            0.5
          let my : Float = (
              stations[segments[sid].a].y + stations[segments[sid].b].y
            ) *
            0.5
          burst_particles(parts, mx, my, 10, 3)
        }

        if affected > 0 {
          msg = "Power spike damaged \{affected} segments"
          msg_t = 1.0
        }
      }

      // crowd peak
      let mut crowd_now : Int = 0
      for i = 0; i < stations.length(); i = i + 1 {
        if stations[i].active {
          crowd_now = crowd_now + stations[i].crowd
        }
      }
      if crowd_now > crowd_peak {
        crowd_peak = crowd_now
      }

      let seg_n : Int = count_active_segments(segments)
      let avg_health : Float = if seg_n > 0 {
        health_sum / Float::from_int(seg_n)
      } else {
        0.0
      }

      // win/loss
      if delivered >= target_delivered {
        state = 2
        msg = "Metro stabilized"
        msg_t = 3.0
        burst_particles(parts, drone.x, drone.y, 70, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Shift ended"
        msg_t = 3.0
      } else if crowd_now >= 760 {
        state = 3
        msg = "Station overload"
        msg_t = 3.0
      } else if avg_health <= 18.0 {
        state = 3
        msg = "Network integrity collapse"
        msg_t = 3.0
      } else if drone.hull <= 0.0 {
        state = 3
        msg = "Drone destroyed"
        msg_t = 3.0
      }

      // manual loss of hull from faults proximity
      let (fseg, fd2, _fx, _fy) = nearest_faulty_segment(
        segments,
        stations,
        drone.x,
        drone.y,
      )
      if fseg >= 0 && fd2 < 64.0 * 64.0 {
        drone.hull = drone.hull - dt * 3.0
      }

      if drone.hull < 0.0 {
        drone.hull = 0.0
      }
    } else if state == 2 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

    draw_world_bg(scene_t)

    let selected_fault : Int = drone.target_seg
    draw_segments(segments, stations, selected_fault, scene_t)
    draw_stations(stations)
    draw_trains(trains, stations, route0, route1)

    // depot
    let depot_x : Int = world_x + 20
    let depot_y : Int = world_y + 20
    let depot_w : Int = 180
    let depot_h : Int = 110
    @raylib.draw_rectangle(
      depot_x,
      depot_y,
      depot_w,
      depot_h,
      @raylib.Color::new(72, 132, 208, 172),
    )
    @raylib.draw_rectangle_lines(
      depot_x,
      depot_y,
      depot_w,
      depot_h,
      @raylib.Color::new(196, 224, 252, 238),
    )
    @raylib.draw_text(
      "DEPOT",
      depot_x + 52,
      depot_y + 16,
      30,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Recharge + Repair",
      depot_x + 22,
      depot_y + 54,
      22,
      @raylib.Color::new(214, 232, 252, 236),
    )

    draw_drone(drone, scene_t)

    if drone.scan_t > 0.0 &&
      drone.target_seg >= 0 &&
      drone.target_seg < segments.length() &&
      segments[drone.target_seg].active {
      let tx : Float = (
          stations[segments[drone.target_seg].a].x +
          stations[segments[drone.target_seg].b].x
        ) *
        0.5
      let ty : Float = (
          stations[segments[drone.target_seg].a].y +
          stations[segments[drone.target_seg].b].y
        ) *
        0.5
      let alpha : Int = clampi((drone.scan_t * 130.0).to_int(), 0, 220)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(drone.x, drone.y),
        @raylib.Vector2::new(tx, ty),
        4.0,
        @raylib.Color::new(136, 244, 164, alpha),
      )
      @raylib.draw_circle(
        tx.to_int(),
        ty.to_int(),
        10.0,
        @raylib.Color::new(136, 244, 164, alpha),
      )
    }

    draw_particles(parts)

    // panel
    @raylib.draw_rectangle(
      panel_x,
      20,
      panel_w,
      728,
      @raylib.Color::new(16, 22, 34, 246),
    )
    @raylib.draw_rectangle_lines(
      panel_x,
      20,
      panel_w,
      728,
      @raylib.Color::new(164, 188, 234, 242),
    )

    @raylib.draw_text(
      "METRO REPAIR DISPATCH",
      panel_x + 14,
      42,
      34,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Keep lines alive while passenger demand spikes",
      panel_x + 16,
      82,
      20,
      @raylib.Color::new(194, 218, 252, 236),
    )

    @raylib.draw_text(
      "Time",
      panel_x + 16,
      124,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{timer.to_int()}s",
      panel_x + 108,
      124,
      30,
      @raylib.Color::new(248, 228, 148, 252),
    )

    @raylib.draw_text(
      "Delivered",
      panel_x + 16,
      160,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{delivered}/\{target_delivered}",
      panel_x + 138,
      160,
      30,
      @raylib.Color::new(136, 224, 162, 252),
    )

    @raylib.draw_text(
      "Faults",
      panel_x + 16,
      196,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{count_faults(segments)}",
      panel_x + 96,
      196,
      30,
      @raylib.Color::new(248, 136, 150, 252),
    )

    @raylib.draw_text(
      "Tier",
      panel_x + 182,
      196,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      panel_x + 242,
      196,
      30,
      @raylib.Color::new(248, 214, 126, 252),
    )

    @raylib.draw_text(
      "Score",
      panel_x + 16,
      232,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{score}",
      panel_x + 94,
      232,
      30,
      @raylib.Color::new(138, 214, 252, 252),
    )

    @raylib.draw_text(
      "Outages handled",
      panel_x + 16,
      268,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{outages_handled}",
      panel_x + 194,
      268,
      30,
      @raylib.Color::new(226, 238, 254, 252),
    )

    @raylib.draw_text(
      "Delay total",
      panel_x + 16,
      304,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{delay_accum.to_int()}s",
      panel_x + 146,
      304,
      30,
      @raylib.Color::new(244, 198, 136, 252),
    )

    @raylib.draw_text(
      "Crowd peak",
      panel_x + 16,
      340,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{crowd_peak}",
      panel_x + 144,
      340,
      30,
      @raylib.Color::new(244, 198, 136, 252),
    )
    @raylib.draw_text(
      "Strain",
      panel_x + 182,
      340,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{strain_total.to_int()}",
      panel_x + 266,
      340,
      30,
      @raylib.Color::new(164, 226, 248, 252),
    )

    fn draw_bar(
      y : Int,
      label : String,
      value : Float,
      maxv : Float,
      col : @raylib.Color,
    ) -> Unit {
      @raylib.draw_text(
        label,
        panel_x + 16,
        y,
        24,
        @raylib.Color::new(220, 236, 252, 246),
      )
      @raylib.draw_rectangle(
        panel_x + 16,
        y + 28,
        panel_w - 32,
        22,
        @raylib.Color::new(24, 32, 48, 255),
      )
      let p01 : Float = clampf(value / maxv, 0.0, 1.0)
      let fw : Int = (Float::from_int(panel_w - 32) * p01).to_int()
      @raylib.draw_rectangle(panel_x + 16, y + 28, fw, 22, col)
      @raylib.draw_rectangle_lines(
        panel_x + 16,
        y + 28,
        panel_w - 32,
        22,
        @raylib.Color::new(184, 208, 246, 248),
      )
      @raylib.draw_text(
        "\{value.to_int()}/\{maxv.to_int()}",
        panel_x + panel_w - 136,
        y + 54,
        20,
        @raylib.Color::new(228, 242, 255, 244),
      )
    }

    draw_bar(
      388,
      "Drone Energy",
      drone.energy,
      drone.energy_max,
      @raylib.Color::new(134, 214, 252, 252),
    )
    draw_bar(
      468,
      "Drone Hull",
      drone.hull,
      drone.hull_max,
      @raylib.Color::new(134, 236, 164, 252),
    )

    @raylib.draw_text(
      "Controls",
      panel_x + 16,
      556,
      28,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "WASD/Arrows: move",
      panel_x + 16,
      590,
      22,
      @raylib.Color::new(198, 220, 252, 238),
    )
    @raylib.draw_text(
      "J/Space: repair",
      panel_x + 16,
      616,
      22,
      @raylib.Color::new(198, 220, 252, 238),
    )
    @raylib.draw_text(
      "K/H: scan nearest fault",
      panel_x + 16,
      642,
      22,
      @raylib.Color::new(198, 220, 252, 238),
    )
    @raylib.draw_text(
      "Mobile: touch d-pad + buttons",
      panel_x + 16,
      668,
      22,
      @raylib.Color::new(198, 220, 252, 238),
    )

    draw_touch_ui()

    @raylib.draw_text(
      "Dispatch drone to fault hotspots before crowd overload.",
      world_x + 6,
      world_y - 6,
      26,
      @raylib.Color::new(212, 232, 252, 242),
    )

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = sw / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(12, 18, 30, 224),
      )
      @raylib.draw_rectangle_lines(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(186, 210, 248, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        28,
        30,
        @raylib.Color::new(236, 244, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 14, 24, 206))
      @raylib.draw_text(
        "METRO REPAIR DISPATCH",
        sw / 2 - 352,
        152,
        74,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Transit network operations under pressure",
        sw / 2 - 266,
        244,
        38,
        @raylib.Color::new(194, 220, 252, 252),
      )

      @raylib.draw_rectangle(
        sw / 2 - 470,
        314,
        940,
        246,
        @raylib.Color::new(18, 26, 42, 236),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 470,
        314,
        940,
        246,
        @raylib.Color::new(166, 196, 246, 246),
      )

      @raylib.draw_text(
        "Desktop",
        sw / 2 - 436,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Repair faults before trains stall",
        sw / 2 - 436,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Keep crowds below overload",
        sw / 2 - 436,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Hit target delivered count",
        sw / 2 - 436,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 74,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Hold D-pad to move",
        sw / 2 + 74,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Tap FIX and SCAN buttons",
        sw / 2 + 74,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Fully touch playable",
        sw / 2 + 74,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      draw_button(
        sw / 2 - 204,
        604,
        408,
        92,
        "START SHIFT",
        true,
        inside_rect(mouse.x, mouse.y, sw / 2 - 204, 604, 408, 92),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 20, 10, 194))
      @raylib.draw_text(
        "NETWORK STABLE",
        sw / 2 - 252,
        192,
        84,
        @raylib.Color::new(164, 246, 182, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{target_delivered}",
        sw / 2 - 212,
        324,
        40,
        @raylib.Color::new(232, 248, 236, 252),
      )
      @raylib.draw_text(
        "Score \{score}",
        sw / 2 - 86,
        374,
        36,
        @raylib.Color::new(244, 232, 160, 248),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 96,
        454,
        34,
        @raylib.Color::new(216, 234, 252, 246),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 8, 14, 206))
      @raylib.draw_text(
        "SERVICE FAILURE",
        sw / 2 - 258,
        194,
        86,
        @raylib.Color::new(252, 164, 178, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{target_delivered}",
        sw / 2 - 212,
        326,
        40,
        @raylib.Color::new(242, 232, 236, 252),
      )
      @raylib.draw_text(
        "Delay \{delay_accum.to_int()}s  Peak crowd \{crowd_peak}",
        sw / 2 - 262,
        376,
        34,
        @raylib.Color::new(244, 216, 154, 248),
      )
      @raylib.draw_text(
        "Tap or Enter to retry",
        sw / 2 - 164,
        454,
        34,
        @raylib.Color::new(218, 234, 252, 246),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
