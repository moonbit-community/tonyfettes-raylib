///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let lane_n : Int = 3

///|
let truck_n : Int = 3

///|
let max_meteors : Int = 120

///|
let max_bullets : Int = 260

///|
let max_ores : Int = 140

///|
let max_sparks : Int = 360

///|
struct Truck {
  mut x : Float
  mut lane : Int
  mut hp : Int
  mut cargo : Int
  mut alive : Bool
  mut respawn_t : Float
}

///|
struct Meteor {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut hp : Int
  mut ore : Int
  mut active : Bool
}

///|
struct Bullet {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut active : Bool
}

///|
struct Ore {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut amount : Int
  mut ttl : Float
  mut active : Bool
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
fn sqdist(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
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
fn lane_y(lane : Int) -> Float {
  if lane == 0 {
    560.0
  } else if lane == 1 {
    628.0
  } else {
    696.0
  }
}

///|
fn reset_trucks(trucks : Array[Truck], level : Int) -> Unit {
  for i = 0; i < trucks.length(); i = i + 1 {
    trucks[i].lane = i
    trucks[i].x = -Float::from_int(200 + i * 180)
    trucks[i].hp = 4 + level
    trucks[i].cargo = 1
    trucks[i].alive = true
    trucks[i].respawn_t = 0.0
  }
}

///|
fn clear_meteors(meteors : Array[Meteor]) -> Unit {
  for i = 0; i < meteors.length(); i = i + 1 {
    meteors[i].x = 0.0
    meteors[i].y = 0.0
    meteors[i].vx = 0.0
    meteors[i].vy = 0.0
    meteors[i].r = 0.0
    meteors[i].hp = 0
    meteors[i].ore = 0
    meteors[i].active = false
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].x = 0.0
    bullets[i].y = 0.0
    bullets[i].vx = 0.0
    bullets[i].vy = 0.0
    bullets[i].ttl = 0.0
    bullets[i].active = false
  }
}

///|
fn clear_ores(ores : Array[Ore]) -> Unit {
  for i = 0; i < ores.length(); i = i + 1 {
    ores[i].x = 0.0
    ores[i].y = 0.0
    ores[i].vx = 0.0
    ores[i].vy = 0.0
    ores[i].amount = 0
    ores[i].ttl = 0.0
    ores[i].active = false
  }
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
  speed : Float,
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
        speed
      sparks[i].vy = Float::from_int(@raylib.get_random_value(-240, 240)) *
        speed
      sparks[i].ttl = Float::from_int(@raylib.get_random_value(12, 48)) /
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
  speed : Float,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_spark(sparks, x, y, speed, kind)
  }
}

///|
fn spawn_bullet(
  bullets : Array[Bullet],
  x : Float,
  y : Float,
  dx : Float,
  dy : Float,
) -> Unit {
  let d2 = dx * dx + dy * dy
  if d2 <= 0.00001 {
    return
  }
  let d = d2.sqrt()
  let speed : Float = 720.0

  let mut done = false
  for i = 0; i < bullets.length(); i = i + 1 {
    if done {
      continue
    }
    if not(bullets[i].active) {
      bullets[i].active = true
      bullets[i].x = x
      bullets[i].y = y
      bullets[i].vx = dx / d * speed
      bullets[i].vy = dy / d * speed
      bullets[i].ttl = 1.25
      done = true
    }
  }
}

///|
fn spawn_meteor(meteors : Array[Meteor], level : Int) -> Unit {
  let mut done = false
  for i = 0; i < meteors.length(); i = i + 1 {
    if done {
      continue
    }
    if not(meteors[i].active) {
      let lane = @raylib.get_random_value(0, lane_n - 1)
      let target_x = Float::from_int(@raylib.get_random_value(80, sw - 160))
      let spawn_x = target_x +
        Float::from_int(@raylib.get_random_value(-220, 220))
      let spawn_y : Float = -Float::from_int(@raylib.get_random_value(20, 180))

      let ty = lane_y(lane)
      let dx = target_x - spawn_x
      let dy = ty - spawn_y
      let d2 = dx * dx + dy * dy
      let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

      let speed = Float::from_int(
        @raylib.get_random_value(150 + level * 20, 240 + level * 24),
      )
      let size = Float::from_int(
        @raylib.get_random_value(14 + level, 28 + level * 2),
      )

      meteors[i].active = true
      meteors[i].x = spawn_x
      meteors[i].y = spawn_y
      meteors[i].vx = dx / d * speed +
        Float::from_int(@raylib.get_random_value(-30, 30))
      meteors[i].vy = dy / d * speed
      meteors[i].r = size
      meteors[i].hp = if size > 30.0 { 3 } else if size > 22.0 { 2 } else { 1 }
      meteors[i].ore = if size > 30.0 { 3 } else if size > 22.0 { 2 } else { 1 }
      done = true
    }
  }
}

///|
fn spawn_ore(ores : Array[Ore], x : Float, y : Float, amount : Int) -> Unit {
  let mut done = false
  for i = 0; i < ores.length(); i = i + 1 {
    if done {
      continue
    }
    if not(ores[i].active) {
      ores[i].active = true
      ores[i].x = x
      ores[i].y = y
      ores[i].vx = Float::from_int(@raylib.get_random_value(-80, 80))
      ores[i].vy = Float::from_int(@raylib.get_random_value(-130, -40))
      ores[i].amount = amount
      ores[i].ttl = 10.0
      done = true
    }
  }
}

///|
fn setup_level(
  level : Int,
  trucks : Array[Truck],
  meteors : Array[Meteor],
  bullets : Array[Bullet],
  ores : Array[Ore],
  sparks : Array[Spark],
) -> (Int, Float, Float) {
  reset_trucks(trucks, level)
  clear_meteors(meteors)
  clear_bullets(bullets)
  clear_ores(ores)
  clear_sparks(sparks)

  if level == 1 {
    (10, 140.0, 1.05)
  } else if level == 2 {
    (14, 160.0, 0.82)
  } else {
    (18, 185.0, 0.66)
  }
}

///|
fn alive_truck_count(trucks : Array[Truck]) -> Int {
  let mut c = 0
  for i = 0; i < trucks.length(); i = i + 1 {
    if trucks[i].alive {
      c = c + 1
    }
  }
  c
}

///|
fn nearest_truck_for_repair(
  trucks : Array[Truck],
  px : Float,
  py : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 : Float = 130.0 * 130.0

  for i = 0; i < trucks.length(); i = i + 1 {
    if trucks[i].alive && trucks[i].hp < 8 {
      let tx = trucks[i].x
      let ty = lane_y(trucks[i].lane) - 12.0
      let d2 = sqdist(px, py, tx, ty)
      if d2 < best_d2 {
        best_d2 = d2
        best = i
      }
    }
  }

  best
}

///|
fn main {
  @raylib.init_window(sw, sh, "Meteor Miner Convoy 2026")
  @raylib.set_target_fps(60)

  let trucks : Array[Truck] = Array::makei(truck_n, fn(i) {
    {
      x: -Float::from_int(200 + i * 180),
      lane: i,
      hp: 5,
      cargo: 1,
      alive: true,
      respawn_t: 0.0,
    }
  })

  let meteors : Array[Meteor] = Array::makei(max_meteors, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, r: 0.0, hp: 0, ore: 0, active: false }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, active: false }
  })

  let ores : Array[Ore] = Array::makei(max_ores, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, amount: 0, ttl: 0.0, active: false }
  })

  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, kind: 0, active: false }
  })

  let mut level = 1
  let mut target = 0
  let mut timer : Float = 0.0
  let mut spawn_base : Float = 0.0

  let (first_target, first_timer, first_spawn) = setup_level(
    level, trucks, meteors, bullets, ores, sparks,
  )
  target = first_target
  timer = first_timer
  spawn_base = first_spawn

  let mut deliveries = 0
  let mut score = 0
  let mut ore_bank = 0

  let mut px : Float = 180.0
  let mut py : Float = 470.0
  let mut pvx : Float = 0.0
  let mut pvy : Float = 0.0
  let mut player_hp = 6
  let mut energy : Float = 100.0

  let mut fire_cd : Float = 0.0
  let mut repair_cd : Float = 0.0
  let mut invuln_t : Float = 0.0

  let mut spawn_cd : Float = 0.8
  let mut wave_t : Float = 0.0

  let mut shake_t : Float = 0.0
  let mut msg = "A/D/W/S move, J fire, K repair truck near you."

  let mut over = false
  let mut won = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm, rspawn) = setup_level(
        level, trucks, meteors, bullets, ores, sparks,
      )
      target = rt
      timer = rtm
      spawn_base = rspawn

      deliveries = 0
      score = 0
      ore_bank = 0

      px = 180.0
      py = 470.0
      pvx = 0.0
      pvy = 0.0
      player_hp = 6
      energy = 100.0
      fire_cd = 0.0
      repair_cd = 0.0
      invuln_t = 0.0
      spawn_cd = 0.8
      wave_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Convoy rebooted. Move out."
    }

    if fire_cd > 0.0 {
      fire_cd = fire_cd - dt
      if fire_cd < 0.0 {
        fire_cd = 0.0
      }
    }

    if repair_cd > 0.0 {
      repair_cd = repair_cd - dt
      if repair_cd < 0.0 {
        repair_cd = 0.0
      }
    }

    if invuln_t > 0.0 {
      invuln_t = invuln_t - dt
      if invuln_t < 0.0 {
        invuln_t = 0.0
      }
    }

    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        won = false
        msg = "Shift ended before quota."
      }

      wave_t = wave_t + dt
      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_meteor(meteors, level)
        let jitter = Float::from_int(@raylib.get_random_value(84, 132)) / 100.0
        spawn_cd = spawn_base * jitter
      }

      let mut move_l = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut do_fire = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut do_repair = @raylib.is_key_pressed(@raylib.KeyK)

      let m = @raylib.get_mouse_position()
      let pad_x = 18
      let pad_y = sh - 182
      let fire_x = sw - 258
      let fire_y = sh - 170
      let repair_x = sw - 122
      let repair_y = sh - 170

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pad_x + 76, pad_y, 72, 54) {
          move_u = true
        }
        if inside_rect(m.x, m.y, pad_x + 76, pad_y + 108, 72, 54) {
          move_d = true
        }
        if inside_rect(m.x, m.y, pad_x, pad_y + 54, 72, 54) {
          move_l = true
        }
        if inside_rect(m.x, m.y, pad_x + 152, pad_y + 54, 72, 54) {
          move_r = true
        }
        if inside_rect(m.x, m.y, fire_x, fire_y, 120, 156) {
          do_fire = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, repair_x, repair_y, 104, 156) {
          do_repair = true
        }
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0

      if move_l {
        ax = ax - 420.0
      }
      if move_r {
        ax = ax + 420.0
      }
      if move_u {
        ay = ay - 420.0
      }
      if move_d {
        ay = ay + 420.0
      }

      pvx = pvx + ax * dt
      pvy = pvy + ay * dt
      pvx = pvx * (Float::from_int(1) - dt * 1.7)
      pvy = pvy * (Float::from_int(1) - dt * 1.7)

      pvx = clampf(pvx, -290.0, 290.0)
      pvy = clampf(pvy, -290.0, 290.0)

      px = px + pvx * dt
      py = py + pvy * dt

      px = clampf(px, 26.0, Float::from_int(sw - 30))
      py = clampf(py, 120.0, 760.0)

      if do_fire && fire_cd <= 0.0 && energy >= 6.0 {
        spawn_bullet(bullets, px + 16.0, py, 1.0, 0.0)
        fire_cd = 0.09
        energy = energy - 6.0
        burst(sparks, px + 18.0, py, 3, 0.23, 2)
      }

      energy = energy + 20.0 * dt
      if energy > 100.0 {
        energy = 100.0
      }

      if do_repair && repair_cd <= 0.0 {
        let idx = nearest_truck_for_repair(trucks, px, py)
        if idx >= 0 && ore_bank >= 2 {
          trucks[idx].hp = trucks[idx].hp + 1
          if trucks[idx].hp > 8 {
            trucks[idx].hp = 8
          }
          ore_bank = ore_bank - 2
          score = score + 42
          repair_cd = 0.32
          msg = "Truck \\{idx + 1} repaired (+1 HP)."
          burst(
            sparks,
            trucks[idx].x,
            lane_y(trucks[idx].lane) - 10.0,
            12,
            0.32,
            3,
          )
        }
      }

      let truck_speed = Float::from_int(66 + level * 7)
      for i = 0; i < trucks.length(); i = i + 1 {
        if trucks[i].alive {
          trucks[i].x = trucks[i].x +
            truck_speed *
            dt *
            (Float::from_int(100 + trucks[i].cargo * 4) / 100.0)

          if trucks[i].x > Float::from_int(sw + 120) {
            deliveries = deliveries + 1
            score = score + 160 + trucks[i].cargo * 24
            trucks[i].x = -Float::from_int(@raylib.get_random_value(120, 420))
            trucks[i].cargo = 1 + level
            msg = "Delivery complete. Total: \\{deliveries}/\\{target}."
            burst(sparks, Float::from_int(sw - 80), lane_y(i), 15, 0.34, 1)
          }
        } else {
          trucks[i].respawn_t = trucks[i].respawn_t - dt
          if trucks[i].respawn_t <= 0.0 {
            trucks[i].alive = true
            trucks[i].hp = 3 + level
            trucks[i].cargo = 1
            trucks[i].x = -Float::from_int(@raylib.get_random_value(160, 440))
            msg = "Salvage truck redeployed."
          }
        }
      }

      for i = 0; i < bullets.length(); i = i + 1 {
        if bullets[i].active {
          bullets[i].x = bullets[i].x + bullets[i].vx * dt
          bullets[i].y = bullets[i].y + bullets[i].vy * dt
          bullets[i].ttl = bullets[i].ttl - dt

          if bullets[i].ttl <= 0.0 ||
            bullets[i].x < -40.0 ||
            bullets[i].x > Float::from_int(sw + 40) ||
            bullets[i].y < -40.0 ||
            bullets[i].y > Float::from_int(sh + 40) {
            bullets[i].active = false
          }
        }
      }

      for i = 0; i < meteors.length(); i = i + 1 {
        if not(meteors[i].active) {
          continue
        }

        meteors[i].x = meteors[i].x + meteors[i].vx * dt
        meteors[i].y = meteors[i].y + meteors[i].vy * dt
        meteors[i].vy = meteors[i].vy + 20.0 * dt

        if meteors[i].x < -120.0 ||
          meteors[i].x > Float::from_int(sw + 120) ||
          meteors[i].y > Float::from_int(sh + 120) {
          meteors[i].active = false
          continue
        }

        let mut killed = false

        for b = 0; b < bullets.length(); b = b + 1 {
          if not(bullets[b].active) {
            continue
          }
          let hit_r = meteors[i].r + 5.0
          if sqdist(bullets[b].x, bullets[b].y, meteors[i].x, meteors[i].y) <=
            hit_r * hit_r {
            bullets[b].active = false
            meteors[i].hp = meteors[i].hp - 1
            burst(sparks, meteors[i].x, meteors[i].y, 6, 0.22, 0)

            if meteors[i].hp <= 0 {
              score = score + 28 + meteors[i].ore * 15
              spawn_ore(ores, meteors[i].x, meteors[i].y, meteors[i].ore)
              burst(sparks, meteors[i].x, meteors[i].y, 18, 0.36, 1)
              meteors[i].active = false
              killed = true
            }
            break
          }
        }

        if killed {
          continue
        }

        if invuln_t <= 0.0 {
          let player_r : Float = 18.0 + meteors[i].r
          if sqdist(px, py, meteors[i].x, meteors[i].y) <= player_r * player_r {
            player_hp = player_hp - 1
            invuln_t = 1.0
            shake_t = 0.25
            msg = "Direct impact! Pilot hull -1."
            burst(sparks, px, py, 20, 0.5, 0)
            meteors[i].active = false
            if player_hp <= 0 {
              over = true
              won = false
              msg = "Command ship destroyed."
            }
            continue
          }
        }

        let mut truck_hit = false
        for t = 0; t < trucks.length(); t = t + 1 {
          if not(trucks[t].alive) {
            continue
          }
          let tx = trucks[t].x
          let ty = lane_y(trucks[t].lane)
          if absf(meteors[i].x - tx) <= 30.0 + meteors[i].r &&
            absf(meteors[i].y - ty) <= 18.0 + meteors[i].r {
            trucks[t].hp = trucks[t].hp - 1
            trucks[t].cargo = if trucks[t].cargo > 1 {
              trucks[t].cargo - 1
            } else {
              1
            }
            msg = "Truck \\{t + 1} struck by meteor."
            burst(sparks, tx, ty - 6.0, 16, 0.42, 0)
            meteors[i].active = false
            truck_hit = true

            if trucks[t].hp <= 0 {
              trucks[t].alive = false
              trucks[t].respawn_t = Float::from_int(10 + level * 2)
              msg = "Truck \\{t + 1} destroyed. Salvage team inbound."
              burst(sparks, tx, ty - 4.0, 26, 0.56, 0)
            }
            break
          }
        }

        if truck_hit {
          continue
        }

        if meteors[i].y >= lane_y(2) + 28.0 {
          meteors[i].active = false
          burst(sparks, meteors[i].x, lane_y(2) + 14.0, 10, 0.33, 2)
        }
      }

      for i = 0; i < ores.length(); i = i + 1 {
        if not(ores[i].active) {
          continue
        }

        ores[i].x = ores[i].x + ores[i].vx * dt
        ores[i].y = ores[i].y + ores[i].vy * dt
        ores[i].vy = ores[i].vy + 180.0 * dt
        ores[i].ttl = ores[i].ttl - dt

        let floor_y = lane_y(2) + 16.0
        if ores[i].y > floor_y {
          ores[i].y = floor_y
          ores[i].vy = -ores[i].vy * 0.36
          ores[i].vx = ores[i].vx * 0.70
        }

        if ores[i].ttl <= 0.0 {
          ores[i].active = false
          continue
        }

        if sqdist(px, py, ores[i].x, ores[i].y) <= 24.0 * 24.0 {
          ore_bank = ore_bank + ores[i].amount
          score = score + ores[i].amount * 12
          msg = "Ore recovered +\\{ores[i].amount}."
          burst(sparks, ores[i].x, ores[i].y, 8, 0.26, 3)
          ores[i].active = false
          continue
        }

        let mut loaded = false
        for t = 0; t < trucks.length(); t = t + 1 {
          if not(trucks[t].alive) {
            continue
          }

          let tx = trucks[t].x
          let ty = lane_y(trucks[t].lane)
          if absf(ores[i].x - tx) < 28.0 && absf(ores[i].y - ty) < 18.0 {
            trucks[t].cargo = trucks[t].cargo + ores[i].amount
            score = score + ores[i].amount * 8
            ores[i].active = false
            loaded = true
            burst(sparks, tx, ty - 6.0, 6, 0.20, 1)
            break
          }
        }

        if loaded {
          continue
        }
      }

      for i = 0; i < sparks.length(); i = i + 1 {
        if not(sparks[i].active) {
          continue
        }

        sparks[i].x = sparks[i].x + sparks[i].vx * dt
        sparks[i].y = sparks[i].y + sparks[i].vy * dt
        sparks[i].vy = sparks[i].vy + 220.0 * dt
        sparks[i].ttl = sparks[i].ttl - dt

        if sparks[i].ttl <= 0.0 {
          sparks[i].active = false
        }
      }

      if alive_truck_count(trucks) <= 0 {
        over = true
        won = false
        msg = "All convoy trucks destroyed."
      }

      if deliveries >= target {
        if level < 3 {
          level = level + 1
          let (nt, ntime, nspawn) = setup_level(
            level, trucks, meteors, bullets, ores, sparks,
          )
          target = nt
          timer = ntime
          spawn_base = nspawn
          deliveries = 0
          ore_bank = ore_bank + 4
          player_hp = if player_hp < 6 { player_hp + 1 } else { 6 }
          px = 180.0
          py = 470.0
          pvx = 0.0
          pvy = 0.0
          spawn_cd = 0.8
          msg = "Sector \\{level} online. Convoy upgraded."
        } else {
          over = true
          won = true
          msg = "Quota complete. Corporate bonus unlocked."
        }
      }
    }

    @raylib.begin_drawing()

    if shake_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(20, 20, 30, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 26, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 20, 38, 255))
    @raylib.draw_rectangle(0, 0, sw, 260, @raylib.Color::new(18, 30, 58, 255))

    let twinkle = (wave_t * 4.0).to_int()
    for i = 0; i < 190; i = i + 1 {
      let x = (i * 173 + 37) % sw
      let y = (i * 97 + 83) % 320
      let v = (i * 11 + twinkle + level * 17) % 100
      let c = if v < 50 { 150 + v } else { 250 - v }
      @raylib.draw_rectangle(x, y, 2, 2, @raylib.Color::new(c, c, c + 12, 255))
    }

    for lane = 0; lane < lane_n; lane = lane + 1 {
      let y = lane_y(lane)
      @raylib.draw_rectangle(
        0,
        (y - 22.0).to_int(),
        sw,
        44,
        @raylib.Color::new(42, 44, 54, 255),
      )
      @raylib.draw_line(
        0,
        (y - 8.0).to_int(),
        sw,
        (y - 8.0).to_int(),
        @raylib.Color::new(120, 126, 140, 255),
      )
      @raylib.draw_line(
        0,
        (y + 8.0).to_int(),
        sw,
        (y + 8.0).to_int(),
        @raylib.Color::new(120, 126, 140, 255),
      )
      for p = 0; p < 24; p = p + 1 {
        let sleeper_x = (p * 62 + (wave_t * 80.0).to_int()) % (sw + 100) - 50
        @raylib.draw_rectangle(
          sleeper_x,
          (y - 14.0).to_int(),
          18,
          28,
          @raylib.Color::new(74, 64, 54, 255),
        )
      }
    }

    @raylib.draw_rectangle(
      sw - 122,
      496,
      122,
      228,
      @raylib.Color::new(44, 72, 94, 255),
    )
    @raylib.draw_rectangle(
      sw - 96,
      536,
      44,
      150,
      @raylib.Color::new(86, 120, 142, 255),
    )
    @raylib.draw_rectangle(
      sw - 112,
      522,
      76,
      14,
      @raylib.Color::new(172, 206, 220, 255),
    )
    @raylib.draw_text(
      "REFINERY",
      sw - 118,
      468,
      24,
      @raylib.Color::new(222, 236, 248, 255),
    )

    for i = 0; i < trucks.length(); i = i + 1 {
      if not(trucks[i].alive) {
        continue
      }

      let tx = trucks[i].x.to_int()
      let ty = lane_y(trucks[i].lane).to_int()

      @raylib.draw_rectangle(
        tx - 30,
        ty - 14,
        60,
        22,
        @raylib.Color::new(208, 164, 82, 255),
      )
      @raylib.draw_rectangle(
        tx + 6,
        ty - 20,
        22,
        16,
        @raylib.Color::new(228, 204, 152, 255),
      )
      @raylib.draw_circle(
        tx - 18,
        ty + 10,
        6.0,
        @raylib.Color::new(28, 30, 36, 255),
      )
      @raylib.draw_circle(
        tx + 18,
        ty + 10,
        6.0,
        @raylib.Color::new(28, 30, 36, 255),
      )
      @raylib.draw_text(
        "\\{trucks[i].cargo}",
        tx - 6,
        ty - 10,
        18,
        @raylib.Color::new(20, 28, 34, 255),
      )

      @raylib.draw_rectangle(
        tx - 28,
        ty - 28,
        56,
        6,
        @raylib.Color::new(30, 30, 36, 255),
      )
      @raylib.draw_rectangle(
        tx - 28,
        ty - 28,
        (Float::from_int(trucks[i].hp) / 8.0 * 56.0).to_int(),
        6,
        @raylib.Color::new(110, 230, 146, 255),
      )
    }

    for i = 0; i < meteors.length(); i = i + 1 {
      if not(meteors[i].active) {
        continue
      }

      let mx = meteors[i].x.to_int()
      let my = meteors[i].y.to_int()
      let r = meteors[i].r

      @raylib.draw_circle(mx, my, r, @raylib.Color::new(130, 92, 64, 255))
      @raylib.draw_circle(
        mx - 4,
        my - 3,
        r * 0.64,
        @raylib.Color::new(166, 118, 82, 255),
      )
      @raylib.draw_circle(
        mx + 6,
        my + 2,
        r * 0.35,
        @raylib.Color::new(102, 72, 50, 255),
      )
      @raylib.draw_text(
        "\\{meteors[i].hp}",
        mx - 5,
        my - 9,
        18,
        @raylib.Color::new(232, 240, 250, 255),
      )
    }

    for i = 0; i < ores.length(); i = i + 1 {
      if not(ores[i].active) {
        continue
      }
      let ox = ores[i].x.to_int()
      let oy = ores[i].y.to_int()
      @raylib.draw_circle(ox, oy, 8.0, @raylib.Color::new(82, 238, 232, 255))
      @raylib.draw_circle(
        ox + 2,
        oy - 2,
        4.0,
        @raylib.Color::new(182, 252, 246, 255),
      )
      @raylib.draw_text(
        "+\\{ores[i].amount}",
        ox - 9,
        oy - 22,
        16,
        @raylib.Color::new(196, 248, 244, 255),
      )
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      @raylib.draw_line(
        bullets[i].x.to_int(),
        bullets[i].y.to_int(),
        (bullets[i].x - bullets[i].vx * 0.02).to_int(),
        (bullets[i].y - bullets[i].vy * 0.02).to_int(),
        @raylib.Color::new(252, 120, 90, 255),
      )
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      let c = if sparks[i].kind == 0 {
        @raylib.Color::new(255, 130, 88, 255)
      } else if sparks[i].kind == 1 {
        @raylib.Color::new(255, 216, 118, 255)
      } else if sparks[i].kind == 2 {
        @raylib.Color::new(236, 118, 108, 255)
      } else {
        @raylib.Color::new(120, 244, 228, 255)
      }
      @raylib.draw_circle(sparks[i].x.to_int(), sparks[i].y.to_int(), 2.0, c)
    }

    if invuln_t <= 0.0 || (invuln_t * 12.0).to_int() % 2 == 0 {
      let pxi = px.to_int()
      let pyi = py.to_int()
      @raylib.draw_triangle(
        @raylib.Vector2::new(px + 24.0, py),
        @raylib.Vector2::new(px - 14.0, py - 12.0),
        @raylib.Vector2::new(px - 14.0, py + 12.0),
        @raylib.Color::new(220, 238, 252, 255),
      )
      @raylib.draw_rectangle(
        pxi - 18,
        pyi - 8,
        16,
        16,
        @raylib.Color::new(96, 186, 242, 255),
      )
      @raylib.draw_circle(
        pxi - 20,
        pyi,
        8.0,
        @raylib.Color::new(98, 246, 236, 255),
      )
      @raylib.draw_line(
        pxi - 25,
        pyi - 10,
        pxi - 34,
        pyi - 14,
        @raylib.Color::new(146, 220, 248, 255),
      )
      @raylib.draw_line(
        pxi - 25,
        pyi + 10,
        pxi - 34,
        pyi + 14,
        @raylib.Color::new(146, 220, 248, 255),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 106, @raylib.Color::new(8, 12, 22, 228))
    @raylib.draw_text(
      "METEOR MINER CONVOY 2026",
      16,
      18,
      34,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_text(
      "Sector \\{level}/3",
      480,
      24,
      30,
      @raylib.Color::new(250, 226, 146, 255),
    )
    @raylib.draw_text(
      "Deliveries \\{deliveries}/\\{target}",
      654,
      24,
      30,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_text(
      "Ore \\{ore_bank}",
      1044,
      24,
      30,
      @raylib.Color::new(122, 246, 236, 255),
    )

    @raylib.draw_text(
      "Pilot HP \\{player_hp}",
      20,
      70,
      24,
      @raylib.Color::new(226, 242, 255, 255),
    )
    @raylib.draw_text(
      "Energy \\{energy.to_int()}%",
      220,
      70,
      24,
      @raylib.Color::new(226, 242, 255, 255),
    )
    @raylib.draw_text(
      "Timer \\{timer.to_int()}",
      470,
      70,
      24,
      @raylib.Color::new(255, 214, 146, 255),
    )
    @raylib.draw_text(
      "Score \\{score}",
      684,
      70,
      24,
      @raylib.Color::new(226, 242, 255, 255),
    )
    @raylib.draw_text(
      "Alive Trucks \\{alive_truck_count(trucks)}",
      932,
      70,
      24,
      @raylib.Color::new(176, 244, 168, 255),
    )

    @raylib.draw_rectangle(
      16,
      108,
      230,
      10,
      @raylib.Color::new(24, 30, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      108,
      (Float::from_int(player_hp) / 6.0 * 230.0).to_int(),
      10,
      @raylib.Color::new(110, 220, 136, 255),
    )
    @raylib.draw_rectangle(
      264,
      108,
      230,
      10,
      @raylib.Color::new(24, 30, 40, 255),
    )
    @raylib.draw_rectangle(
      264,
      108,
      (energy / 100.0 * 230.0).to_int(),
      10,
      @raylib.Color::new(86, 198, 244, 255),
    )
    let timer_total : Float = if level == 1 {
      140.0
    } else if level == 2 {
      160.0
    } else {
      185.0
    }
    let timer_fill = (timer / timer_total * 230.0).to_int()
    @raylib.draw_rectangle(
      512,
      108,
      230,
      10,
      @raylib.Color::new(24, 30, 40, 255),
    )
    @raylib.draw_rectangle(
      512,
      108,
      clampf(Float::from_int(timer_fill), 0.0, 230.0).to_int(),
      10,
      @raylib.Color::new(246, 172, 92, 255),
    )

    @raylib.draw_rectangle(
      8,
      sh - 196,
      236,
      188,
      @raylib.Color::new(8, 14, 28, 220),
    )
    @raylib.draw_text("Touch", 90, sh - 188, 20, @raylib.white)
    let pad_x = 18
    let pad_y = sh - 182
    @raylib.draw_rectangle(
      pad_x + 76,
      pad_y,
      72,
      54,
      @raylib.Color::new(50, 70, 98, 255),
    )
    @raylib.draw_text("U", pad_x + 104, pad_y + 16, 24, @raylib.white)
    @raylib.draw_rectangle(
      pad_x,
      pad_y + 54,
      72,
      54,
      @raylib.Color::new(50, 70, 98, 255),
    )
    @raylib.draw_text("L", pad_x + 28, pad_y + 70, 24, @raylib.white)
    @raylib.draw_rectangle(
      pad_x + 152,
      pad_y + 54,
      72,
      54,
      @raylib.Color::new(50, 70, 98, 255),
    )
    @raylib.draw_text("R", pad_x + 180, pad_y + 70, 24, @raylib.white)
    @raylib.draw_rectangle(
      pad_x + 76,
      pad_y + 108,
      72,
      54,
      @raylib.Color::new(50, 70, 98, 255),
    )
    @raylib.draw_text("D", pad_x + 104, pad_y + 124, 24, @raylib.white)

    let fire_x = sw - 258
    let fire_y = sh - 170
    let repair_x = sw - 122
    let repair_y = sh - 170
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      120,
      156,
      @raylib.Color::new(186, 82, 70, 255),
    )
    @raylib.draw_text("FIRE", fire_x + 24, fire_y + 62, 30, @raylib.white)
    @raylib.draw_rectangle(
      repair_x,
      repair_y,
      104,
      156,
      @raylib.Color::new(70, 138, 126, 255),
    )
    @raylib.draw_text("REPAIR", repair_x + 6, repair_y + 62, 24, @raylib.white)

    @raylib.draw_rectangle(
      250,
      sh - 58,
      sw - 516,
      44,
      @raylib.Color::new(6, 10, 18, 220),
    )
    @raylib.draw_text(
      msg,
      264,
      sh - 50,
      24,
      @raylib.Color::new(224, 236, 248, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 130))
      @raylib.draw_rectangle(
        sw / 2 - 370,
        sh / 2 - 112,
        740,
        224,
        @raylib.Color::new(16, 24, 42, 242),
      )
      @raylib.draw_text(
        if won {
          "MISSION COMPLETE"
        } else {
          "MISSION FAILED"
        },
        sw / 2 - 228,
        sh / 2 - 42,
        62,
        if won {
          @raylib.Color::new(252, 236, 142, 255)
        } else {
          @raylib.Color::new(255, 138, 138, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 44,
        34,
        @raylib.Color::new(224, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
