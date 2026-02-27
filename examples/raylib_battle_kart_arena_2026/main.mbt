///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let outer_l : Float = 120.0

///|
let outer_t : Float = 110.0

///|
let outer_r : Float = 1160.0

///|
let outer_b : Float = 710.0

///|
let inner_l : Float = 360.0

///|
let inner_t : Float = 250.0

///|
let inner_r : Float = 920.0

///|
let inner_b : Float = 570.0

///|
let wp_n : Int = 8

///|
let kart_n : Int = 4

///|
let max_shots : Int = 200

///|
let max_pickups : Int = 6

///|
let max_sparks : Int = 260

///|
struct Kart {
  mut x : Float
  mut y : Float
  mut angle : Float
  mut speed : Float
  mut hp : Int
  mut lap : Int
  mut next_wp : Int
  mut shoot_cd : Float
}

///|
struct Shot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut owner : Int
  mut active : Bool
}

///|
struct Pickup {
  x : Float
  y : Float
  kind : Int
  mut active : Bool
  mut respawn : Float
}

///|
struct Spark {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut kind : Int
  mut active : Bool
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
fn inside_rect(
  px : Float,
  py : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
fn deg2rad(a : Float) -> Double {
  a.to_double() * 0.017453292519943295
}

///|
fn sinf_deg(a : Float) -> Float {
  Float::from_double(@math.sin(deg2rad(a)))
}

///|
fn cosf_deg(a : Float) -> Float {
  Float::from_double(@math.cos(deg2rad(a)))
}

///|
fn track_contains(x : Float, y : Float, margin : Float) -> Bool {
  let in_outer = x >= outer_l + margin &&
    x <= outer_r - margin &&
    y >= outer_t + margin &&
    y <= outer_b - margin
  let in_inner = x >= inner_l - margin &&
    x <= inner_r + margin &&
    y >= inner_t - margin &&
    y <= inner_b + margin
  in_outer && not(in_inner)
}

///|
fn set_wp(
  wx : Array[Float],
  wy : Array[Float],
  i : Int,
  x : Float,
  y : Float,
) -> Unit {
  wx[i] = x
  wy[i] = y
}

///|
fn init_waypoints(wx : Array[Float], wy : Array[Float]) -> Unit {
  set_wp(wx, wy, 0, 260.0, 180.0)
  set_wp(wx, wy, 1, 640.0, 160.0)
  set_wp(wx, wy, 2, 1020.0, 180.0)
  set_wp(wx, wy, 3, 1040.0, 410.0)
  set_wp(wx, wy, 4, 1020.0, 640.0)
  set_wp(wx, wy, 5, 640.0, 660.0)
  set_wp(wx, wy, 6, 260.0, 640.0)
  set_wp(wx, wy, 7, 240.0, 410.0)
}

///|
fn reset_karts(karts : Array[Kart]) -> Unit {
  karts[0] = {
    x: 236.0,
    y: 412.0,
    angle: 0.0,
    speed: 0.0,
    hp: 4,
    lap: 0,
    next_wp: 0,
    shoot_cd: 0.0,
  }
  karts[1] = {
    x: 214.0,
    y: 456.0,
    angle: 0.0,
    speed: 0.0,
    hp: 4,
    lap: 0,
    next_wp: 0,
    shoot_cd: 0.4,
  }
  karts[2] = {
    x: 214.0,
    y: 368.0,
    angle: 0.0,
    speed: 0.0,
    hp: 4,
    lap: 0,
    next_wp: 0,
    shoot_cd: 0.7,
  }
  karts[3] = {
    x: 188.0,
    y: 412.0,
    angle: 0.0,
    speed: 0.0,
    hp: 4,
    lap: 0,
    next_wp: 0,
    shoot_cd: 1.0,
  }
}

///|
fn clear_shots(shots : Array[Shot]) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    shots[i].x = 0.0
    shots[i].y = 0.0
    shots[i].vx = 0.0
    shots[i].vy = 0.0
    shots[i].ttl = 0.0
    shots[i].owner = -1
    shots[i].active = false
  }
}

///|
fn set_pickup(
  pickups : Array[Pickup],
  i : Int,
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  pickups[i] = { x, y, kind, active: true, respawn: 0.0 }
}

///|
fn reset_pickups(pickups : Array[Pickup]) -> Unit {
  set_pickup(pickups, 0, 640.0, 190.0, 0)
  set_pickup(pickups, 1, 1020.0, 410.0, 1)
  set_pickup(pickups, 2, 640.0, 630.0, 2)
  set_pickup(pickups, 3, 260.0, 410.0, 0)
  set_pickup(pickups, 4, 430.0, 190.0, 1)
  set_pickup(pickups, 5, 850.0, 630.0, 2)
}

///|
fn clear_sparks(sparks : Array[Spark]) -> Unit {
  for i = 0; i < sparks.length(); i = i + 1 {
    sparks[i].x = 0.0
    sparks[i].y = 0.0
    sparks[i].vx = 0.0
    sparks[i].vy = 0.0
    sparks[i].ttl = 0.0
    sparks[i].kind = 0
    sparks[i].active = false
  }
}

///|
fn spawn_spark(
  sparks : Array[Spark],
  x : Float,
  y : Float,
  speed_scale : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < sparks.length(); i = i + 1 {
    if done {
      continue
    }
    if not(sparks[i].active) {
      sparks[i].active = true
      sparks[i].x = x
      sparks[i].y = y
      sparks[i].vx = Float::from_int(@raylib.get_random_value(-240, 240)) *
        speed_scale
      sparks[i].vy = Float::from_int(@raylib.get_random_value(-240, 240)) *
        speed_scale
      sparks[i].ttl = Float::from_int(@raylib.get_random_value(14, 50)) /
        Float::from_int(100)
      sparks[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  sparks : Array[Spark],
  x : Float,
  y : Float,
  n : Int,
  speed_scale : Float,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_spark(sparks, x, y, speed_scale, kind)
  }
}

///|
fn spawn_shot(
  shots : Array[Shot],
  x : Float,
  y : Float,
  dx : Float,
  dy : Float,
  owner : Int,
) -> Unit {
  let d2 = dx * dx + dy * dy
  if d2 <= 0.0001 {
    return
  }
  let d = d2.sqrt()
  let speed : Float = 680.0

  let mut done = false
  for i = 0; i < shots.length(); i = i + 1 {
    if done {
      continue
    }
    if not(shots[i].active) {
      shots[i].active = true
      shots[i].x = x
      shots[i].y = y
      shots[i].vx = dx / d * speed
      shots[i].vy = dy / d * speed
      shots[i].ttl = 1.6
      shots[i].owner = owner
      done = true
    }
  }
}

///|
fn update_waypoint_progress(
  kart : Kart,
  wx : Array[Float],
  wy : Array[Float],
) -> Unit {
  let tx = wx[kart.next_wp]
  let ty = wy[kart.next_wp]
  let dx = tx - kart.x
  let dy = ty - kart.y
  if dx * dx + dy * dy <= 58.0 * 58.0 {
    kart.next_wp = kart.next_wp + 1
    if kart.next_wp >= wp_n {
      kart.next_wp = 0
      kart.lap = kart.lap + 1
    }
  }
}

///|
fn resolve_track_collision(kart : Kart) -> Unit {
  if kart.x < outer_l + 16.0 {
    kart.x = outer_l + 16.0
    kart.speed = -kart.speed * 0.38
  }
  if kart.x > outer_r - 16.0 {
    kart.x = outer_r - 16.0
    kart.speed = -kart.speed * 0.38
  }
  if kart.y < outer_t + 16.0 {
    kart.y = outer_t + 16.0
    kart.speed = -kart.speed * 0.38
  }
  if kart.y > outer_b - 16.0 {
    kart.y = outer_b - 16.0
    kart.speed = -kart.speed * 0.38
  }

  if kart.x > inner_l - 12.0 &&
    kart.x < inner_r + 12.0 &&
    kart.y > inner_t - 12.0 &&
    kart.y < inner_b + 12.0 {
    let dl = absf(kart.x - inner_l)
    let dr = absf(inner_r - kart.x)
    let dt = absf(kart.y - inner_t)
    let db = absf(inner_b - kart.y)

    if dl <= dr && dl <= dt && dl <= db {
      kart.x = inner_l - 12.0
    } else if dr <= dl && dr <= dt && dr <= db {
      kart.x = inner_r + 12.0
    } else if dt <= dl && dt <= dr && dt <= db {
      kart.y = inner_t - 12.0
    } else {
      kart.y = inner_b + 12.0
    }

    kart.speed = -kart.speed * 0.32
  }
}

///|
fn respawn_kart(karts : Array[Kart], i : Int) -> Unit {
  if i == 0 {
    karts[i].x = 236.0
    karts[i].y = 412.0
  } else if i == 1 {
    karts[i].x = 214.0
    karts[i].y = 456.0
  } else if i == 2 {
    karts[i].x = 214.0
    karts[i].y = 368.0
  } else {
    karts[i].x = 188.0
    karts[i].y = 412.0
  }
  karts[i].angle = 0.0
  karts[i].speed = 0.0
  karts[i].next_wp = 0
}

///|
fn main {
  @raylib.init_window(sw, sh, "Battle Kart Arena 2026")
  @raylib.set_target_fps(60)

  let wx : Array[Float] = Array::make(wp_n, 0.0)
  let wy : Array[Float] = Array::make(wp_n, 0.0)
  init_waypoints(wx, wy)

  let karts : Array[Kart] = Array::makei(kart_n, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      angle: 0.0,
      speed: 0.0,
      hp: 4,
      lap: 0,
      next_wp: 0,
      shoot_cd: 0.0,
    }
  })
  reset_karts(karts)

  let shots : Array[Shot] = Array::makei(max_shots, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, owner: -1, active: false }
  })
  clear_shots(shots)

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { x: 0.0, y: 0.0, kind: 0, active: false, respawn: 0.0 }
  })
  reset_pickups(pickups)

  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, kind: 0, active: false }
  })
  clear_sparks(sparks)

  let mut ammo = 10
  let mut boost : Float = 70.0
  let mut score = 0

  let lap_target = 3
  let mut fire_cd : Float = 0.0
  let mut hit_flash : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "WASD drive, Space/J fire, Shift/K boost."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_karts(karts)
      clear_shots(shots)
      reset_pickups(pickups)
      clear_sparks(sparks)

      ammo = 10
      boost = 70.0
      score = 0
      fire_cd = 0.0
      hit_flash = 0.0
      shake_t = 0.0
      over = false
      won = false
      msg = "Race reset."
    }

    if fire_cd > 0.0 {
      fire_cd = fire_cd - dt
      if fire_cd < 0.0 {
        fire_cd = 0.0
      }
    }
    if hit_flash > 0.0 {
      hit_flash = hit_flash - dt
      if hit_flash < 0.0 {
        hit_flash = 0.0
      }
    }
    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }

    if not(over) {
      let mut left = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut right = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut accel = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut brake = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut fire = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      let mut boost_on = @raylib.is_key_down(@raylib.KeyLeftShift) ||
        @raylib.is_key_down(@raylib.KeyK)

      let ctl_x = 20
      let ctl_y = sh - 176
      let fire_x = sw - 198
      let fire_y = sh - 154
      let boost_x = sw - 198
      let boost_y = sh - 250
      let m = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x, ctl_y, 74, 54) {
          left = true
        }
        if inside_rect(m.x, m.y, ctl_x + 82, ctl_y, 74, 54) {
          right = true
        }
        if inside_rect(m.x, m.y, ctl_x, ctl_y + 60, 74, 54) {
          accel = true
        }
        if inside_rect(m.x, m.y, ctl_x + 82, ctl_y + 60, 74, 54) {
          brake = true
        }
        if inside_rect(m.x, m.y, fire_x, fire_y, 166, 116) {
          fire = true
        }
        if inside_rect(m.x, m.y, boost_x, boost_y, 166, 84) {
          boost_on = true
        }
      }

      let mut turn : Float = 0.0
      if left {
        turn = turn - 1.0
      }
      if right {
        turn = turn + 1.0
      }

      let mut acc : Float = 0.0
      if accel {
        acc = acc + 280.0
      }
      if brake {
        acc = acc - 340.0
      }

      if boost_on && boost > 0.0 {
        acc = acc + 220.0
        boost = boost - 22.0 * dt
        if boost < 0.0 {
          boost = 0.0
        }
      } else {
        boost = boost + 10.0 * dt
        if boost > 100.0 {
          boost = 100.0
        }
      }

      let turn_strength : Float = Float::from_int(120) +
        absf(karts[0].speed) * 0.22
      karts[0].angle = karts[0].angle + turn * turn_strength * dt
      karts[0].speed = karts[0].speed + acc * dt
      karts[0].speed = karts[0].speed * (Float::from_int(1) - dt * 0.90)
      karts[0].speed = clampf(karts[0].speed, -180.0, 390.0)

      karts[0].x = karts[0].x + cosf_deg(karts[0].angle) * karts[0].speed * dt
      karts[0].y = karts[0].y + sinf_deg(karts[0].angle) * karts[0].speed * dt
      resolve_track_collision(karts[0])

      if not(track_contains(karts[0].x, karts[0].y, 10.0)) {
        karts[0].speed = karts[0].speed * 0.86
      }

      update_waypoint_progress(karts[0], wx, wy)

      if fire && fire_cd <= 0.0 && ammo > 0 {
        let sx = karts[0].x + cosf_deg(karts[0].angle) * 24.0
        let sy = karts[0].y + sinf_deg(karts[0].angle) * 24.0
        spawn_shot(
          shots,
          sx,
          sy,
          cosf_deg(karts[0].angle),
          sinf_deg(karts[0].angle),
          0,
        )
        fire_cd = 0.14
        ammo = ammo - 1
      }

      for i = 1; i < karts.length(); i = i + 1 {
        let tx = wx[karts[i].next_wp]
        let ty = wy[karts[i].next_wp]
        let dx = tx - karts[i].x
        let dy = ty - karts[i].y
        let d2 = dx * dx + dy * dy
        if d2 > 0.001 {
          let d = d2.sqrt()
          let nx = dx / d
          let ny = dy / d
          let ai_speed : Float = Float::from_int(190 + i * 10)
          karts[i].x = karts[i].x + nx * ai_speed * dt
          karts[i].y = karts[i].y + ny * ai_speed * dt
          karts[i].angle = Float::from_double(
            @math.atan2(ny.to_double(), nx.to_double()) * 57.29577951308232,
          )
        }

        resolve_track_collision(karts[i])
        update_waypoint_progress(karts[i], wx, wy)

        karts[i].shoot_cd = karts[i].shoot_cd - dt
        if karts[i].shoot_cd <= 0.0 {
          let pdx = karts[0].x - karts[i].x
          let pdy = karts[0].y - karts[i].y
          if pdx * pdx + pdy * pdy <= 250.0 * 250.0 {
            spawn_shot(shots, karts[i].x, karts[i].y, pdx, pdy, i)
            karts[i].shoot_cd = Float::from_int(
                @raylib.get_random_value(90, 150),
              ) /
              Float::from_int(100)
          }
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if pickups[i].active {
          let dx = karts[0].x - pickups[i].x
          let dy = karts[0].y - pickups[i].y
          if dx * dx + dy * dy <= 28.0 * 28.0 {
            if pickups[i].kind == 0 {
              ammo = ammo + 4
              if ammo > 16 {
                ammo = 16
              }
              msg = "Ammo +4"
            } else if pickups[i].kind == 1 {
              boost = boost + 35.0
              if boost > 100.0 {
                boost = 100.0
              }
              msg = "Boost +35"
            } else {
              karts[0].hp = karts[0].hp + 1
              if karts[0].hp > 5 {
                karts[0].hp = 5
              }
              msg = "Integrity +1"
            }
            pickups[i].active = false
            pickups[i].respawn = 8.0
            burst(sparks, pickups[i].x, pickups[i].y, 16, 1.0, 0)
          }
        } else {
          pickups[i].respawn = pickups[i].respawn - dt
          if pickups[i].respawn <= 0.0 {
            pickups[i].respawn = 0.0
            pickups[i].active = true
          }
        }
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }

        shots[i].x = shots[i].x + shots[i].vx * dt
        shots[i].y = shots[i].y + shots[i].vy * dt
        shots[i].ttl = shots[i].ttl - dt

        if shots[i].ttl <= 0.0 ||
          shots[i].x < 0.0 ||
          shots[i].x > Float::from_int(sw) ||
          shots[i].y < 0.0 ||
          shots[i].y > Float::from_int(sh) {
          shots[i].active = false
          continue
        }

        if shots[i].owner == 0 {
          let mut hit = false
          for j = 1; j < karts.length(); j = j + 1 {
            if hit {
              continue
            }
            let dx = shots[i].x - karts[j].x
            let dy = shots[i].y - karts[j].y
            if dx * dx + dy * dy <= 18.0 * 18.0 {
              shots[i].active = false
              karts[j].hp = karts[j].hp - 1
              hit = true
              burst(sparks, karts[j].x, karts[j].y, 10, 0.9, 1)
              if karts[j].hp <= 0 {
                score = score + 120
                karts[j].hp = 4
                respawn_kart(karts, j)
                burst(sparks, karts[j].x, karts[j].y, 16, 1.2, 2)
              } else {
                score = score + 24
              }
            }
          }
        } else {
          let dx = shots[i].x - karts[0].x
          let dy = shots[i].y - karts[0].y
          if dx * dx + dy * dy <= 18.0 * 18.0 {
            shots[i].active = false
            karts[0].hp = karts[0].hp - 1
            hit_flash = 0.22
            shake_t = 0.16
            burst(sparks, karts[0].x, karts[0].y, 12, 1.0, 2)
            if karts[0].hp <= 0 {
              over = true
              won = false
              msg = "Your kart is destroyed."
            }
          }
        }
      }

      if karts[0].lap >= lap_target {
        over = true
        won = true
        score = score + 500 + karts[0].hp * 60
        msg = "Finish reached."
      }

      let mut ai_won = false
      for i = 1; i < karts.length(); i = i + 1 {
        if karts[i].lap >= lap_target {
          ai_won = true
        }
      }
      if ai_won && not(over) {
        over = true
        won = false
        msg = "AI finished first."
      }
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      sparks[i].x = sparks[i].x + sparks[i].vx * dt
      sparks[i].y = sparks[i].y + sparks[i].vy * dt
      sparks[i].vx = sparks[i].vx * (Float::from_int(1) - dt * 2.4)
      sparks[i].vy = sparks[i].vy * (Float::from_int(1) - dt * 2.4)
      sparks[i].ttl = sparks[i].ttl - dt
      if sparks[i].ttl <= 0.0 {
        sparks[i].active = false
      }
    }

    let shake_x = if shake_t > 0.0 {
      Float::from_int(@raylib.get_random_value(-5, 5)) * shake_t * 8.0
    } else {
      0.0
    }

    @raylib.begin_drawing()

    if hit_flash > 0.0 {
      @raylib.clear_background(@raylib.Color::new(42, 18, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(12, 18, 28, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 24, 38, 255))
    @raylib.draw_rectangle(0, 0, sw, 220, @raylib.Color::new(26, 44, 70, 255))

    let ol = (outer_l + shake_x).to_int()
    let ot = outer_t.to_int()
    let ow = (outer_r - outer_l).to_int()
    let oh = (outer_b - outer_t).to_int()
    @raylib.draw_rectangle(ol, ot, ow, oh, @raylib.Color::new(90, 96, 104, 255))

    let il = (inner_l + shake_x).to_int()
    let it = inner_t.to_int()
    let iw = (inner_r - inner_l).to_int()
    let ih = (inner_b - inner_t).to_int()
    @raylib.draw_rectangle(il, it, iw, ih, @raylib.Color::new(38, 92, 58, 255))

    for i = 0; i < 36; i = i + 1 {
      let dash_x = ol + i * 30
      @raylib.draw_rectangle(
        dash_x,
        ot + oh / 2 - 4,
        16,
        8,
        @raylib.Color::new(228, 226, 210, 255),
      )
    }

    @raylib.draw_rectangle(
      ol + 6,
      ot + oh / 2 - 72,
      8,
      144,
      @raylib.Color::new(252, 104, 104, 255),
    )
    @raylib.draw_text(
      "START",
      ol + 20,
      ot + oh / 2 - 16,
      22,
      @raylib.Color::new(248, 220, 220, 255),
    )

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }
      let x = (pickups[i].x + shake_x).to_int()
      let y = pickups[i].y.to_int()
      let c = if pickups[i].kind == 0 {
        @raylib.Color::new(116, 220, 246, 255)
      } else if pickups[i].kind == 1 {
        @raylib.Color::new(246, 194, 104, 255)
      } else {
        @raylib.Color::new(142, 238, 152, 255)
      }
      @raylib.draw_circle(x, y, 12.0, c)
      @raylib.draw_circle_lines(x, y, 12.0, @raylib.Color::new(22, 30, 42, 255))
    }

    for i = 0; i < karts.length(); i = i + 1 {
      let x = (karts[i].x + shake_x).to_int()
      let y = karts[i].y.to_int()
      let c = if i == 0 {
        @raylib.Color::new(90, 214, 246, 255)
      } else if i == 1 {
        @raylib.Color::new(246, 112, 102, 255)
      } else if i == 2 {
        @raylib.Color::new(246, 194, 94, 255)
      } else {
        @raylib.Color::new(168, 148, 246, 255)
      }
      @raylib.draw_circle(x, y, 17.0, c)
      @raylib.draw_circle(x, y, 9.0, @raylib.Color::new(24, 30, 42, 255))
      let hx = x + (cosf_deg(karts[i].angle) * 20.0).to_int()
      let hy = y + (sinf_deg(karts[i].angle) * 20.0).to_int()
      @raylib.draw_line(x, y, hx, hy, @raylib.Color::new(244, 244, 248, 255))
      @raylib.draw_text("\{karts[i].lap + 1}", x - 6, y - 33, 20, @raylib.white)
    }

    for i = 0; i < shots.length(); i = i + 1 {
      if not(shots[i].active) {
        continue
      }
      let x = (shots[i].x + shake_x).to_int()
      let y = shots[i].y.to_int()
      @raylib.draw_circle(x, y, 4.0, @raylib.Color::new(246, 248, 252, 255))
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      let a = (sparks[i].ttl * 255.0).to_int()
      if a <= 0 {
        continue
      }
      let c = if sparks[i].kind == 0 {
        @raylib.Color::new(122, 236, 250, a)
      } else if sparks[i].kind == 1 {
        @raylib.Color::new(250, 220, 138, a)
      } else {
        @raylib.Color::new(250, 128, 128, a)
      }
      @raylib.draw_circle(
        (sparks[i].x + shake_x).to_int(),
        sparks[i].y.to_int(),
        2.2,
        c,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 98, @raylib.Color::new(8, 12, 20, 230))
    @raylib.draw_text(
      "BATTLE KART ARENA 2026",
      16,
      20,
      34,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @raylib.draw_text(
      "Lap \{karts[0].lap + 1}/\{lap_target}",
      436,
      30,
      30,
      @raylib.Color::new(246, 230, 136, 255),
    )
    @raylib.draw_text(
      "HP \{karts[0].hp}",
      646,
      30,
      30,
      @raylib.Color::new(216, 236, 252, 255),
    )
    @raylib.draw_text(
      "Ammo \{ammo}",
      780,
      30,
      30,
      @raylib.Color::new(216, 236, 252, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      930,
      30,
      30,
      @raylib.Color::new(216, 236, 252, 255),
    )

    @raylib.draw_rectangle(20, 78, 280, 12, @raylib.Color::new(30, 42, 62, 255))
    @raylib.draw_rectangle(
      20,
      78,
      (boost / 100.0 * 280.0).to_int(),
      12,
      @raylib.Color::new(120, 212, 252, 255),
    )
    @raylib.draw_text(
      "Boost \{boost.to_int()}",
      306,
      70,
      20,
      @raylib.Color::new(204, 228, 246, 255),
    )

    let ctl_x = 20
    let ctl_y = sh - 176
    @raylib.draw_rectangle(
      8,
      sh - 190,
      160,
      180,
      @raylib.Color::new(10, 16, 28, 220),
    )
    @raylib.draw_text("Touch", 56, sh - 186, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      74,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("LEFT", ctl_x + 14, ctl_y + 18, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 82,
      ctl_y,
      74,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("RIGHT", ctl_x + 86, ctl_y + 18, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x,
      ctl_y + 60,
      74,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("ACC", ctl_x + 18, ctl_y + 78, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 82,
      ctl_y + 60,
      74,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("BRK", ctl_x + 98, ctl_y + 78, 20, @raylib.white)

    let boost_x = sw - 198
    let boost_y = sh - 250
    @raylib.draw_rectangle(
      boost_x,
      boost_y,
      166,
      84,
      @raylib.Color::new(72, 106, 180, 255),
    )
    @raylib.draw_text("BOOST", boost_x + 36, boost_y + 26, 34, @raylib.white)

    let fire_x = sw - 198
    let fire_y = sh - 154
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      166,
      116,
      @raylib.Color::new(188, 82, 76, 255),
    )
    @raylib.draw_text("FIRE", fire_x + 52, fire_y + 40, 38, @raylib.white)

    @raylib.draw_rectangle(
      176,
      sh - 52,
      sw - 390,
      36,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text(
      msg,
      186,
      sh - 46,
      22,
      @raylib.Color::new(224, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(
        sw / 2 - 340,
        sh / 2 - 100,
        680,
        200,
        @raylib.Color::new(16, 24, 40, 242),
      )
      @raylib.draw_text(
        if won {
          "RACE WON"
        } else {
          "RACE LOST"
        },
        sw / 2 - 170,
        sh / 2 - 34,
        56,
        if won {
          @raylib.Color::new(248, 236, 142, 255)
        } else {
          @raylib.Color::new(250, 132, 132, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 40,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
