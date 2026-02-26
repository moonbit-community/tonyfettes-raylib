///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let player_x : Float = 220.0

///|
let lane_count : Int = 3

///|
let max_obstacles : Int = 260

///|
let max_shots : Int = 420

///|
let max_pickups : Int = 140

///|
let max_particles : Int = 920

///|
let target_distance : Float = 5600.0

///|
struct Player {
  mut lane : Int
  mut z : Float
  mut vz : Float
  mut slide_t : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut hp : Float
  mut energy : Float
  mut slash_t : Float
  mut slash_cd : Float
  mut throw_cd : Float
  mut flash_t : Float
  mut trick_t : Float
  mut score : Int
  mut combo : Int
  mut coins : Int
  mut distance : Float
}

///|
struct Obstacle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut lane : Int
  mut hp : Float
  mut atk_cd : Float
  mut pulse_t : Float
}

///|
struct Shot {
  mut active : Bool
  mut from_player : Bool
  mut x : Float
  mut lane : Int
  mut z : Float
  mut vx : Float
  mut dmg : Float
  mut life : Float
}

///|
struct Pickup {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut lane : Int
  mut t : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut t : Float
  mut life : Float
  mut kind : Int
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
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn lane_y(lane : Int) -> Float {
  if lane == 0 {
    248.0
  } else if lane == 1 {
    392.0
  } else {
    534.0
  }
}

///|
fn obstacle_z(obs : Obstacle) -> Float {
  if obs.kind == 3 {
    let phase : Int = (obs.pulse_t * 4.0).to_int() % 2
    if phase == 0 {
      44.0
    } else {
      54.0
    }
  } else {
    0.0
  }
}

///|
fn clear_obstacles(obs : Array[Obstacle]) -> Unit {
  for i = 0; i < obs.length(); i = i + 1 {
    obs[i].active = false
    obs[i].kind = 0
    obs[i].x = 0.0
    obs[i].lane = 0
    obs[i].hp = 0.0
    obs[i].atk_cd = 0.0
    obs[i].pulse_t = 0.0
  }
}

///|
fn clear_shots(shots : Array[Shot]) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    shots[i].active = false
    shots[i].from_player = false
    shots[i].x = 0.0
    shots[i].lane = 0
    shots[i].z = 0.0
    shots[i].vx = 0.0
    shots[i].dmg = 0.0
    shots[i].life = 0.0
  }
}

///|
fn clear_pickups(items : Array[Pickup]) -> Unit {
  for i = 0; i < items.length(); i = i + 1 {
    items[i].active = false
    items[i].kind = 0
    items[i].x = 0.0
    items[i].lane = 0
    items[i].t = 0.0
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
    parts[i].size = 0.0
    parts[i].t = 0.0
    parts[i].life = 0.0
    parts[i].kind = 0
  }
}

///|
fn spawn_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < parts.length(); i = i + 1 {
    if done {
      continue
    }

    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(18, 72)) / 100.0
      parts[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    ignore(i)
    spawn_particle(parts, x, y, speed, kind)
  }
}

///|
fn spawn_shot(
  shots : Array[Shot],
  from_player : Bool,
  x : Float,
  lane : Int,
  z : Float,
  vx : Float,
  dmg : Float,
  life : Float,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < shots.length(); i = i + 1 {
    if slot < 0 && not(shots[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    shots[slot].active = true
    shots[slot].from_player = from_player
    shots[slot].x = x
    shots[slot].lane = lane
    shots[slot].z = z
    shots[slot].vx = vx
    shots[slot].dmg = dmg
    shots[slot].life = life
    true
  }
}

///|
fn spawn_obstacle(obs : Array[Obstacle], level : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < obs.length(); i = i + 1 {
    if slot < 0 && not(obs[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 30 {
      0
    } else if roll < 55 {
      1
    } else if roll < 84 {
      2
    } else {
      3
    }

    obs[slot].active = true
    obs[slot].kind = kind
    obs[slot].x = world_w + randf(20.0, 240.0)
    obs[slot].lane = @raylib.get_random_value(0, lane_count - 1)
    obs[slot].hp = if kind == 2 {
      44.0 + Float::from_int(level) * 4.0
    } else if kind == 3 {
      34.0 + Float::from_int(level) * 3.0
    } else {
      1.0
    }
    obs[slot].atk_cd = randf(0.4, 1.2)
    obs[slot].pulse_t = randf(0.0, 1.0)
    true
  }
}

///|
fn spawn_pickup(items : Array[Pickup]) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < items.length(); i = i + 1 {
    if slot < 0 && not(items[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let roll = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 58 { 0 } else if roll < 84 { 1 } else { 2 }

    items[slot].active = true
    items[slot].kind = kind
    items[slot].x = world_w + randf(50.0, 260.0)
    items[slot].lane = @raylib.get_random_value(0, lane_count - 1)
    items[slot].t = randf(0.0, 1.0)
    true
  }
}

///|
fn nearest_obstacle_dy(obs : Array[Obstacle], player_dist : Float) -> Int {
  ignore(player_dist)
  let mut closest : Int = 9999
  for i = 0; i < obs.length(); i = i + 1 {
    if not(obs[i].active) {
      continue
    }
    let dx = (obs[i].x - player_x).to_int()
    if dx >= 0 && dx < closest {
      closest = dx
    }
  }
  closest
}

///|
fn main {
  @raylib.init_window(sw, sh, "Ninja Rooftop Chase 2026")
  @raylib.set_target_fps(60)

  let player : Player = {
    lane: 1,
    z: 0.0,
    vz: 0.0,
    slide_t: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    hp: 220.0,
    energy: 100.0,
    slash_t: 0.0,
    slash_cd: 0.0,
    throw_cd: 0.0,
    flash_t: 0.0,
    trick_t: 0.0,
    score: 0,
    combo: 0,
    coins: 0,
    distance: 0.0,
  }

  let obstacles : Array[Obstacle] = Array::makei(max_obstacles, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      lane: 0,
      hp: 0.0,
      atk_cd: 0.0,
      pulse_t: 0.0,
    }
  })

  let shots : Array[Shot] = Array::makei(max_shots, fn(_i) {
    {
      active: false,
      from_player: false,
      x: 0.0,
      lane: 0,
      z: 0.0,
      vx: 0.0,
      dmg: 0.0,
      life: 0.0,
    }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, kind: 0, x: 0.0, lane: 0, t: 0.0 }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      t: 0.0,
      life: 0.0,
      kind: 0,
    }
  })

  let mut state : Int = 0
  let mut level : Int = 1
  let mut time_left : Float = 228.0
  let mut obstacle_cd : Float = 0.35
  let mut pickup_cd : Float = 2.4
  let mut milestone : Float = 500.0

  let mut msg : String = "Dash the rooftops"
  let mut msg_t : Float = 3.0

  let mut kills : Int = 0
  let mut missed : Int = 0

  let reset_run = fn() {
    player.lane = 1
    player.z = 0.0
    player.vz = 0.0
    player.slide_t = 0.0
    player.dash_t = 0.0
    player.dash_cd = 0.0
    player.hp = 220.0
    player.energy = 100.0
    player.slash_t = 0.0
    player.slash_cd = 0.0
    player.throw_cd = 0.0
    player.flash_t = 0.0
    player.trick_t = 0.0
    player.score = 0
    player.combo = 0
    player.coins = 0
    player.distance = 0.0

    level = 1
    time_left = 228.0
    obstacle_cd = 0.35
    pickup_cd = 2.4
    milestone = 500.0

    msg = "Run started"
    msg_t = 2.0

    kills = 0
    missed = 0

    clear_obstacles(obstacles)
    clear_shots(shots)
    clear_pickups(pickups)
    clear_particles(particles)

    for i = 0; i < 8; i = i + 1 {
      ignore(i)
      ignore(spawn_obstacle(obstacles, level))
    }
    for i = 0; i < 4; i = i + 1 {
      ignore(i)
      ignore(spawn_pickup(pickups))
    }
  }

  let on_hit = fn(dmg : Float, text : String) {
    player.hp = player.hp - dmg
    player.flash_t = 0.18
    player.combo = 0
    msg = text
    msg_t = 0.66
    burst(particles, player_x, lane_y(player.lane) - player.z, 14, 0.24, 3)
  }

  let on_kill = fn(x : Float, lane : Int, bonus : Int) {
    let pts : Int = 92 + player.combo * 6 + bonus
    player.score = player.score + pts
    player.combo = player.combo + 1
    kills = kills + 1
    msg = "KO +\{pts}"
    msg_t = 0.56
    burst(particles, x, lane_y(lane), 11, 0.20, 1)
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
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let pressed : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if player.flash_t > 0.0 {
      player.flash_t = player.flash_t - dt
      if player.flash_t < 0.0 {
        player.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      time_left = time_left - dt

      player.slide_t = player.slide_t - dt
      if player.slide_t < 0.0 {
        player.slide_t = 0.0
      }
      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }
      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }
      player.slash_t = player.slash_t - dt
      if player.slash_t < 0.0 {
        player.slash_t = 0.0
      }
      player.slash_cd = player.slash_cd - dt
      if player.slash_cd < 0.0 {
        player.slash_cd = 0.0
      }
      player.throw_cd = player.throw_cd - dt
      if player.throw_cd < 0.0 {
        player.throw_cd = 0.0
      }

      let mut lane_up_press : Bool = @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft)
      let mut lane_down_press : Bool = @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight)
      let mut jump_press : Bool = @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut slide_down : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut slash_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut throw_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_x : Int = 22
      let pad_y : Int = sh - 194
      let btn_x : Int = sw - 266
      let btn_y : Int = sh - 230

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 56, 74, 56) {
          lane_up_press = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 154, pad_y + 56, 74, 56) {
          lane_down_press = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 77, pad_y + 112, 74, 56) {
          slide_down = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, pad_x + 77, pad_y, 74, 56) {
          jump_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 8, 108, 84) {
          slash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 118, btn_y + 8, 108, 84) {
          throw_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 56, btn_y + 102, 144, 92) {
          dash_press = true
        }
      }

      if lane_up_press && player.lane > 0 {
        player.lane = player.lane - 1
      }
      if lane_down_press && player.lane < lane_count - 1 {
        player.lane = player.lane + 1
      }

      if jump_press &&
        player.z <= 0.0 &&
        player.slide_t <= 0.0 &&
        player.energy >= 8.0 {
        player.z = 0.1
        player.vz = 520.0
        player.energy = player.energy - 8.0
        player.trick_t = 0.0
        msg = "Leap"
        msg_t = 0.4
        burst(particles, player_x, lane_y(player.lane), 8, 0.18, 0)
      }

      if player.z > 0.0 || player.vz > 0.0 {
        player.vz = player.vz - 1400.0 * dt
        player.z = player.z + player.vz * dt
        if player.z < 0.0 {
          player.z = 0.0
          player.vz = 0.0
          if player.trick_t > 0.2 {
            let trick_pts = (player.trick_t * 520.0).to_int() + player.combo * 4
            player.score = player.score + trick_pts
            player.combo = player.combo + 1
            msg = "Flip +\{trick_pts}"
            msg_t = 0.72
            burst(particles, player_x, lane_y(player.lane), 14, 0.22, 1)
          }
          player.trick_t = 0.0
        }
      }

      if slide_down && player.z <= 0.0 {
        player.slide_t = 0.15
      }

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 20.0 {
        player.dash_t = 0.30
        player.dash_cd = 1.4
        player.energy = player.energy - 20.0
        burst(particles, player_x, lane_y(player.lane), 16, 0.22, 1)
      }

      if slash_press && player.slash_cd <= 0.0 && player.energy >= 6.0 {
        player.slash_t = 0.14
        player.slash_cd = 0.30
        player.energy = player.energy - 6.0
        if player.z > 14.0 {
          player.trick_t = player.trick_t + 0.32
          if player.trick_t > 1.8 {
            player.trick_t = 1.8
          }
        }
      }

      if throw_press && player.throw_cd <= 0.0 && player.energy >= 10.0 {
        player.throw_cd = 0.28
        player.energy = player.energy - 10.0
        ignore(
          spawn_shot(
            shots,
            true,
            player_x + 12.0,
            player.lane,
            player.z + 10.0,
            720.0,
            30.0 + Float::from_int(level) * 2.0,
            1.30,
          ),
        )
        burst(
          particles,
          player_x + 14.0,
          lane_y(player.lane) - player.z,
          6,
          0.18,
          2,
        )
      }

      player.energy = player.energy + dt * 14.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      level = (player.distance / 720.0).to_int() + 1

      let mut run_speed : Float = 248.0 + Float::from_int(level - 1) * 11.0
      if player.dash_t > 0.0 {
        run_speed = run_speed + 180.0
      }
      if player.hp < 90.0 {
        run_speed = run_speed - 24.0
      }
      if run_speed < 150.0 {
        run_speed = 150.0
      }

      player.distance = player.distance + run_speed * dt * 0.11

      if player.distance >= milestone {
        milestone = milestone + 500.0
        player.score = player.score + 160
        msg = "Milestone +160"
        msg_t = 0.8
      }

      obstacle_cd = obstacle_cd - dt
      if obstacle_cd <= 0.0 {
        ignore(spawn_obstacle(obstacles, level))
        let jitter = Float::from_int(@raylib.get_random_value(72, 138)) / 100.0
        obstacle_cd = (0.45 - Float::from_int(level - 1) * 0.02) * jitter
        if obstacle_cd < 0.13 {
          obstacle_cd = 0.13
        }
      }

      pickup_cd = pickup_cd - dt
      if pickup_cd <= 0.0 {
        ignore(spawn_pickup(pickups))
        pickup_cd = randf(2.0, 4.4)
      }

      for i = 0; i < obstacles.length(); i = i + 1 {
        if not(obstacles[i].active) {
          continue
        }

        obstacles[i].pulse_t = obstacles[i].pulse_t + dt

        let move_speed = if obstacles[i].kind == 2 {
          run_speed * 0.94
        } else {
          run_speed
        }
        obstacles[i].x = obstacles[i].x - move_speed * dt

        if obstacles[i].x < -120.0 {
          obstacles[i].active = false
          missed = missed + 1
          continue
        }

        if obstacles[i].kind == 2 && obstacles[i].x < 900.0 {
          obstacles[i].atk_cd = obstacles[i].atk_cd - dt
          if obstacles[i].atk_cd <= 0.0 {
            obstacles[i].atk_cd = randf(0.85, 1.45)
            ignore(
              spawn_shot(
                shots,
                false,
                obstacles[i].x - 8.0,
                obstacles[i].lane,
                0.0,
                -420.0 - Float::from_int(level) * 16.0,
                12.0 + Float::from_int(level) * 1.6,
                1.45,
              ),
            )
          }
        }

        if obstacles[i].lane != player.lane {
          continue
        }

        let dx = absf(obstacles[i].x - player_x)
        let oz = obstacle_z(obstacles[i])

        if obstacles[i].kind == 0 {
          if dx < 30.0 && player.z < 36.0 {
            on_hit(14.0, "Crate hit")
            obstacles[i].active = false
          }
        } else if obstacles[i].kind == 1 {
          if dx < 30.0 && player.slide_t <= 0.0 && player.z < 24.0 {
            on_hit(12.0, "Sign smash")
            obstacles[i].active = false
          }
        } else if obstacles[i].kind == 2 {
          if player.slash_t > 0.0 && dx < 74.0 && player.z < 30.0 {
            obstacles[i].hp = obstacles[i].hp -
              (36.0 + Float::from_int(level) * 2.0)
            burst(
              particles,
              obstacles[i].x,
              lane_y(obstacles[i].lane),
              7,
              0.18,
              2,
            )
            if obstacles[i].hp <= 0.0 {
              on_kill(obstacles[i].x, obstacles[i].lane, 10)
              obstacles[i].active = false
            }
          } else if dx < 28.0 && player.z < 24.0 {
            on_hit(18.0, "Guard tackled")
            obstacles[i].active = false
          }
        } else if player.slash_t > 0.0 &&
          dx < 72.0 &&
          absf(player.z - oz) < 38.0 {
          obstacles[i].hp = obstacles[i].hp -
            (34.0 + Float::from_int(level) * 1.6)
          burst(
            particles,
            obstacles[i].x,
            lane_y(obstacles[i].lane) - oz,
            8,
            0.20,
            2,
          )
          if obstacles[i].hp <= 0.0 {
            on_kill(obstacles[i].x, obstacles[i].lane, 18)
            obstacles[i].active = false
          }
        } else if dx < 28.0 && absf(player.z - oz) < 24.0 {
          on_hit(16.0, "Drone crash")
          obstacles[i].active = false
        }
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }

        shots[i].life = shots[i].life - dt
        if shots[i].life <= 0.0 {
          shots[i].active = false
          continue
        }

        shots[i].x = shots[i].x + shots[i].vx * dt
        if shots[i].x < -120.0 || shots[i].x > world_w + 120.0 {
          shots[i].active = false
          continue
        }

        if shots[i].from_player {
          for j = 0; j < obstacles.length(); j = j + 1 {
            if not(obstacles[j].active) {
              continue
            }
            if obstacles[j].kind != 2 && obstacles[j].kind != 3 {
              continue
            }
            if obstacles[j].lane != shots[i].lane {
              continue
            }

            let oz = obstacle_z(obstacles[j])
            if absf(shots[i].x - obstacles[j].x) < 26.0 &&
              absf(shots[i].z - oz) < 36.0 {
              obstacles[j].hp = obstacles[j].hp - shots[i].dmg
              shots[i].active = false
              burst(
                particles,
                obstacles[j].x,
                lane_y(obstacles[j].lane) - oz,
                6,
                0.16,
                2,
              )
              if obstacles[j].hp <= 0.0 {
                on_kill(obstacles[j].x, obstacles[j].lane, 14)
                obstacles[j].active = false
              }
              break
            }
          }
        } else if shots[i].lane == player.lane &&
          absf(shots[i].x - player_x) < 20.0 &&
          absf(shots[i].z - player.z) < 24.0 {
          shots[i].active = false
          on_hit(shots[i].dmg, "Shot hit")
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }

        pickups[i].t = pickups[i].t + dt
        pickups[i].x = pickups[i].x - run_speed * dt

        if pickups[i].x < -90.0 {
          pickups[i].active = false
          continue
        }

        if pickups[i].lane == player.lane &&
          absf(pickups[i].x - player_x) < 24.0 &&
          player.z < 26.0 {
          if pickups[i].kind == 0 {
            player.coins = player.coins + 1
            player.score = player.score + 34 + player.combo * 2
            msg = "Coin"
          } else if pickups[i].kind == 1 {
            player.hp = player.hp + 24.0
            if player.hp > 220.0 {
              player.hp = 220.0
            }
            msg = "Medpack"
          } else {
            player.energy = player.energy + 24.0
            if player.energy > 100.0 {
              player.energy = 100.0
            }
            msg = "Energy"
          }
          msg_t = 0.58
          pickups[i].active = false
          burst(particles, player_x, lane_y(player.lane) - player.z, 8, 0.18, 0)
        }
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
        } else {
          particles[i].x = particles[i].x + particles[i].vx * dt
          particles[i].y = particles[i].y + particles[i].vy * dt
          particles[i].vx = particles[i].vx * (Float::from_int(1) - dt * 2.0)
          particles[i].vy = particles[i].vy + 280.0 * dt
        }
      }

      if player.distance >= target_distance {
        state = 2
      } else if player.hp <= 0.0 || time_left <= 0.0 {
        state = 3
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }

    @raylib.begin_drawing()

    let mut bg_col = @raylib.Color::new(18, 24, 40, 255)
    if state == 2 {
      bg_col = @raylib.Color::new(20, 34, 42, 255)
    } else if state == 3 {
      bg_col = @raylib.Color::new(34, 20, 30, 255)
    }
    @raylib.clear_background(bg_col)

    for i = 0; i < 20; i = i + 1 {
      let x = i * 68 + (player.distance * 0.8).to_int() % 68
      let h = 120 + i * 17 % 260
      @raylib.draw_rectangle(
        x,
        sh - h,
        52,
        h,
        @raylib.Color::new(24, 32, 54, 255),
      )
      @raylib.draw_rectangle(
        x + 12,
        sh - h + 24,
        8,
        h - 30,
        @raylib.Color::new(90, 164, 238, 140),
      )
    }

    for lane = 0; lane < lane_count; lane = lane + 1 {
      let ly = lane_y(lane)
      @raylib.draw_rectangle(
        0,
        (ly + 18.0).to_int(),
        sw,
        24,
        @raylib.Color::new(42, 48, 66, 255),
      )
      let shift = (player.distance * 20.0).to_int() % 72
      for i = 0; i < 22; i = i + 1 {
        @raylib.draw_rectangle(
          i * 72 - shift,
          (ly + 26.0).to_int(),
          44,
          4,
          @raylib.Color::new(94, 108, 142, 220),
        )
      }
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }

      let py = lane_y(pickups[i].lane)
      let blink : Int = if (pickups[i].t * 7.0).to_int() % 2 == 0 {
        255
      } else {
        180
      }
      let col = if pickups[i].kind == 0 {
        @raylib.Color::new(246, 214, 120, blink)
      } else if pickups[i].kind == 1 {
        @raylib.Color::new(236, 132, 148, blink)
      } else {
        @raylib.Color::new(132, 214, 246, blink)
      }
      @raylib.draw_circle(pickups[i].x.to_int(), py.to_int(), 10.0, col)
      @raylib.draw_circle_lines(
        pickups[i].x.to_int(),
        py.to_int(),
        16.0,
        @raylib.Color::new(248, 252, 255, blink),
      )
    }

    for i = 0; i < obstacles.length(); i = i + 1 {
      if not(obstacles[i].active) {
        continue
      }

      let oy = lane_y(obstacles[i].lane) - obstacle_z(obstacles[i])
      if obstacles[i].kind == 0 {
        @raylib.draw_rectangle(
          (obstacles[i].x - 18.0).to_int(),
          (oy - 20.0).to_int(),
          36,
          40,
          @raylib.Color::new(144, 120, 94, 255),
        )
      } else if obstacles[i].kind == 1 {
        @raylib.draw_rectangle(
          (obstacles[i].x - 20.0).to_int(),
          (oy - 44.0).to_int(),
          40,
          14,
          @raylib.Color::new(210, 102, 142, 255),
        )
        @raylib.draw_rectangle(
          (obstacles[i].x - 20.0).to_int(),
          (oy - 30.0).to_int(),
          40,
          8,
          @raylib.Color::new(246, 164, 196, 255),
        )
      } else if obstacles[i].kind == 2 {
        @raylib.draw_rectangle(
          (obstacles[i].x - 16.0).to_int(),
          (oy - 26.0).to_int(),
          32,
          34,
          @raylib.Color::new(168, 82, 92, 255),
        )
        @raylib.draw_rectangle(
          (obstacles[i].x - 8.0).to_int(),
          (oy - 18.0).to_int(),
          16,
          20,
          @raylib.Color::new(30, 34, 52, 255),
        )
      } else {
        @raylib.draw_circle(
          obstacles[i].x.to_int(),
          oy.to_int(),
          16.0,
          @raylib.Color::new(110, 204, 246, 255),
        )
        @raylib.draw_circle(
          (obstacles[i].x - 8.0).to_int(),
          oy.to_int(),
          3.0,
          @raylib.Color::new(34, 48, 70, 255),
        )
        @raylib.draw_circle(
          (obstacles[i].x + 8.0).to_int(),
          oy.to_int(),
          3.0,
          @raylib.Color::new(34, 48, 70, 255),
        )
      }
    }

    for i = 0; i < shots.length(); i = i + 1 {
      if not(shots[i].active) {
        continue
      }

      let sy = lane_y(shots[i].lane) - shots[i].z
      let c = if shots[i].from_player {
        @raylib.Color::new(132, 226, 248, 255)
      } else {
        @raylib.Color::new(246, 134, 156, 255)
      }
      @raylib.draw_circle(shots[i].x.to_int(), sy.to_int(), 4.0, c)
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let k = particles[i].t / particles[i].life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(122, 224, 252, a)
      if particles[i].kind == 1 {
        c = @raylib.Color::new(142, 246, 182, a)
      } else if particles[i].kind == 2 {
        c = @raylib.Color::new(252, 190, 104, a)
      } else if particles[i].kind == 3 {
        c = @raylib.Color::new(236, 96, 118, a)
      }
      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        c,
      )
    }

    let py = lane_y(player.lane) - player.z

    let mut body_col = @raylib.Color::new(242, 188, 90, 255)
    if player.flash_t > 0.0 {
      body_col = @raylib.Color::new(255, 240, 220, 255)
    }

    let mut h : Int = 30
    if player.slide_t > 0.0 {
      h = 18
    }
    @raylib.draw_rectangle(
      (player_x - 20.0).to_int(),
      (py - Float::from_int(h / 2)).to_int(),
      40,
      h,
      body_col,
    )
    @raylib.draw_rectangle(
      (player_x - 8.0).to_int(),
      (py - Float::from_int(h / 2 - 4)).to_int(),
      16,
      h - 8,
      @raylib.Color::new(30, 36, 54, 255),
    )
    @raylib.draw_rectangle(
      (player_x - 24.0).to_int(),
      (py + Float::from_int(h / 2 - 2)).to_int(),
      48,
      6,
      @raylib.Color::new(74, 96, 132, 255),
    )

    if player.slash_t > 0.0 {
      @raylib.draw_circle_lines(
        (player_x + 34.0).to_int(),
        py.to_int(),
        22.0,
        @raylib.Color::new(170, 236, 255, 220),
      )
    }
    if player.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        player_x.to_int(),
        py.to_int(),
        28.0,
        @raylib.Color::new(122, 220, 252, 220),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 12, 22, 226))
    @raylib.draw_text(
      "NINJA ROOFTOP CHASE 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 244, 255, 255),
    )
    @raylib.draw_text(
      "A/D lane  W jump  S slide  J slash  K throw  L dash",
      20,
      48,
      18,
      @raylib.Color::new(178, 204, 236, 255),
    )

    @raylib.draw_text(
      "Score \{player.score}",
      560,
      16,
      28,
      @raylib.Color::new(246, 216, 118, 255),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      740,
      16,
      28,
      @raylib.Color::new(170, 238, 194, 255),
    )
    @raylib.draw_text(
      "Dist \{player.distance.to_int()}m",
      920,
      16,
      28,
      @raylib.Color::new(180, 226, 252, 255),
    )
    @raylib.draw_text(
      "Time \{time_left.to_int()}s",
      1110,
      16,
      28,
      @raylib.Color::new(248, 188, 132, 255),
    )

    @raylib.draw_rectangle(20, 82, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      82,
      (player.hp / 220.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(108, 224, 154, 255),
    )
    @raylib.draw_text("HP", 20, 96, 16, @raylib.Color::new(182, 208, 230, 255))

    @raylib.draw_rectangle(
      254,
      82,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      254,
      82,
      (player.energy / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(116, 198, 248, 255),
    )
    @raylib.draw_text(
      "ENERGY",
      254,
      96,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    let nearest : Int = nearest_obstacle_dy(obstacles, player.distance)
    @raylib.draw_text(
      "Kills \{kills}",
      520,
      84,
      20,
      @raylib.Color::new(172, 236, 198, 255),
    )
    @raylib.draw_text(
      "Coins \{player.coins}",
      640,
      84,
      20,
      @raylib.Color::new(246, 222, 150, 255),
    )
    @raylib.draw_text(
      "Missed \{missed}",
      772,
      84,
      20,
      @raylib.Color::new(242, 162, 172, 255),
    )
    @raylib.draw_text(
      "Level \{level}",
      900,
      84,
      20,
      @raylib.Color::new(250, 206, 132, 255),
    )
    if nearest < 9000 {
      @raylib.draw_text(
        "Next threat \{nearest}px",
        1012,
        84,
        20,
        @raylib.Color::new(196, 226, 248, 255),
      )
    }

    @raylib.draw_rectangle(
      12,
      sh - 212,
      246,
      200,
      @raylib.Color::new(8, 12, 20, 210),
    )
    let p0x = 22
    let p0y = sh - 194
    @raylib.draw_rectangle(
      p0x,
      p0y + 56,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "UP",
      p0x + 20,
      p0y + 74,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 154,
      p0y + 56,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "DN",
      p0x + 172,
      p0y + 74,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 77,
      p0y,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "JMP",
      p0x + 90,
      p0y + 16,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 77,
      p0y + 112,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "SLD",
      p0x + 90,
      p0y + 128,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 272,
      sh - 236,
      256,
      226,
      @raylib.Color::new(8, 12, 20, 210),
    )
    let p1x = sw - 266
    let p1y = sh - 230
    @raylib.draw_rectangle(
      p1x,
      p1y + 8,
      108,
      84,
      @raylib.Color::new(88, 156, 228, 255),
    )
    @raylib.draw_text(
      "SLASH",
      p1x + 12,
      p1y + 40,
      24,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      p1x + 118,
      p1y + 8,
      108,
      84,
      @raylib.Color::new(214, 112, 94, 255),
    )
    @raylib.draw_text(
      "THROW",
      p1x + 128,
      p1y + 40,
      22,
      @raylib.Color::new(252, 236, 228, 255),
    )
    @raylib.draw_rectangle(
      p1x + 56,
      p1y + 102,
      144,
      92,
      @raylib.Color::new(112, 178, 126, 255),
    )
    @raylib.draw_text(
      "DASH",
      p1x + 96,
      p1y + 136,
      28,
      @raylib.Color::new(236, 246, 240, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 320,
      sh - 54,
      640,
      40,
      @raylib.Color::new(8, 10, 16, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 302,
      sh - 44,
      24,
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 160 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 450,
        sh / 2 - 196,
        900,
        392,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "NINJA ROOFTOP CHASE",
        sw / 2 - 286,
        sh / 2 - 132,
        58,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Rush across neon rooftops and survive the chase",
        sw / 2 - 302,
        sh / 2 - 30,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad for lane/jump/slide, right pad for combat/dash",
        sw / 2 - 412,
        sh / 2 + 14,
        24,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Reach 5600m before time ends",
        sw / 2 - 190,
        sh / 2 + 52,
        28,
        @raylib.Color::new(250, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 166,
        sh / 2 + 112,
        40,
        @raylib.Color::new(255, 204, 112, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 148))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "CHASE ESCAPED",
        sw / 2 - 206,
        sh / 2 - 132,
        60,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 148,
        sh / 2 - 36,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Kills: \{kills}  Coins: \{player.coins}",
        sw / 2 - 188,
        sh / 2 + 18,
        34,
        @raylib.Color::new(170, 236, 198, 255),
      )
      @raylib.draw_text(
        "Missed threats: \{missed}",
        sw / 2 - 176,
        sh / 2 + 60,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 156))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "CHASE FAILED",
        sw / 2 - 188,
        sh / 2 - 132,
        60,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 148,
        sh / 2 - 36,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Distance: \{player.distance.to_int()}m",
        sw / 2 - 186,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Time left: \{time_left.to_int()}s",
        sw / 2 - 176,
        sh / 2 + 60,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }
  }

  @raylib.close_window()
}
