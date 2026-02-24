///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let lane_n : Int = 3

///|
let max_obstacles : Int = 150

///|
let max_coins : Int = 220

///|
let max_powerups : Int = 32

///|
let max_particles : Int = 420

///|
struct Runner {
  x : Float
  mut y : Float
  mut lane : Int
  mut vy : Float
  mut hp : Int
  mut lane_cd : Float
  mut dash_t : Float
  mut invuln_t : Float
}

///|
struct Obstacle {
  mut x : Float
  mut lane : Int
  mut kind : Int
  mut w : Float
  mut h : Float
  mut y_off : Float
  mut hp : Int
  mut active : Bool
}

///|
struct Coin {
  mut x : Float
  mut lane : Int
  mut y_off : Float
  mut value : Int
  mut active : Bool
}

///|
struct Powerup {
  mut x : Float
  mut lane : Int
  mut kind : Int
  mut y_off : Float
  mut active : Bool
}

///|
struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut kind : Int
  mut active : Bool
}

///|
struct TrainEvent {
  mut active : Bool
  mut lane : Int
  mut x : Float
  mut warning_t : Float
  mut speed : Float
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn lane_y(lane : Int) -> Float {
  if lane <= 0 {
    490.0
  } else if lane == 1 {
    580.0
  } else {
    670.0
  }
}

///|
fn clear_obstacles(obstacles : Array[Obstacle]) -> Unit {
  for i = 0; i < obstacles.length(); i = i + 1 {
    obstacles[i].x = 0.0
    obstacles[i].lane = 0
    obstacles[i].kind = 0
    obstacles[i].w = 0.0
    obstacles[i].h = 0.0
    obstacles[i].y_off = 0.0
    obstacles[i].hp = 0
    obstacles[i].active = false
  }
}

///|
fn clear_coins(coins : Array[Coin]) -> Unit {
  for i = 0; i < coins.length(); i = i + 1 {
    coins[i].x = 0.0
    coins[i].lane = 0
    coins[i].y_off = 0.0
    coins[i].value = 0
    coins[i].active = false
  }
}

///|
fn clear_powerups(powerups : Array[Powerup]) -> Unit {
  for i = 0; i < powerups.length(); i = i + 1 {
    powerups[i].x = 0.0
    powerups[i].lane = 0
    powerups[i].kind = 0
    powerups[i].y_off = 0.0
    powerups[i].active = false
  }
}

///|
fn clear_particles(particles : Array[Particle]) -> Unit {
  for i = 0; i < particles.length(); i = i + 1 {
    particles[i].x = 0.0
    particles[i].y = 0.0
    particles[i].vx = 0.0
    particles[i].vy = 0.0
    particles[i].ttl = 0.0
    particles[i].kind = 0
    particles[i].active = false
  }
}

///|
fn reset_runner(runner : Runner) -> Unit {
  runner.y = lane_y(1)
  runner.lane = 1
  runner.vy = 0.0
  runner.hp = 6
  runner.lane_cd = 0.0
  runner.dash_t = 0.0
  runner.invuln_t = 0.0
}

///|
fn burst_particle(particles : Array[Particle], x : Float, y : Float, speed : Float, kind : Int) -> Unit {
  let mut done = false
  for i = 0; i < particles.length(); i = i + 1 {
    if done {
      continue
    }
    if not(particles[i].active) {
      particles[i].active = true
      particles[i].x = x
      particles[i].y = y
      particles[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      particles[i].vy = Float::from_int(@raylib.get_random_value(-220, 220)) * speed
      particles[i].ttl = Float::from_int(@raylib.get_random_value(12, 54)) / Float::from_int(100)
      particles[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(particles : Array[Particle], x : Float, y : Float, n : Int, speed : Float, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    burst_particle(particles, x, y, speed, kind)
  }
}

///|
fn set_obstacle_shape(ob : Obstacle, kind : Int) -> Unit {
  ob.kind = kind
  if kind == 0 {
    ob.w = 52.0
    ob.h = 52.0
    ob.y_off = -4.0
    ob.hp = 1
  } else if kind == 1 {
    ob.w = 64.0
    ob.h = 86.0
    ob.y_off = 0.0
    ob.hp = 2
  } else if kind == 2 {
    ob.w = 46.0
    ob.h = 34.0
    ob.y_off = -78.0
    ob.hp = 1
  } else {
    ob.w = 70.0
    ob.h = 30.0
    ob.y_off = -6.0
    ob.hp = 1
  }
}

///|
fn spawn_obstacle(obstacles : Array[Obstacle], level : Int, wave_t : Float) -> Unit {
  let lane = @raylib.get_random_value(0, lane_n - 1)
  let mut kind = @raylib.get_random_value(0, 3)

  if level == 1 {
    kind = @raylib.get_random_value(0, 2)
  }

  let wobble = Float::from_int(((wave_t * 100.0).to_int() % 120) - 60)

  let mut done = false
  for i = 0; i < obstacles.length(); i = i + 1 {
    if done {
      continue
    }
    if not(obstacles[i].active) {
      obstacles[i].active = true
      obstacles[i].lane = lane
      obstacles[i].x = Float::from_int(sw + 140) + wobble
      set_obstacle_shape(obstacles[i], kind)
      done = true
    }
  }
}

///|
fn spawn_coin(coins : Array[Coin], level : Int, wave_t : Float) -> Unit {
  let lane = @raylib.get_random_value(0, lane_n - 1)
  let mut y_off = Float::from_int(@raylib.get_random_value(-62, -18))
  if @raylib.get_random_value(0, 100) < 35 {
    y_off = Float::from_int(@raylib.get_random_value(-104, -70))
  }

  let value = if level >= 3 && @raylib.get_random_value(0, 100) < 24 {
    3
  } else if @raylib.get_random_value(0, 100) < 42 {
    2
  } else {
    1
  }

  let bob = Float::from_int(((wave_t * 120.0).to_int() % 90) - 45) * 0.6

  let mut done = false
  for i = 0; i < coins.length(); i = i + 1 {
    if done {
      continue
    }
    if not(coins[i].active) {
      coins[i].active = true
      coins[i].lane = lane
      coins[i].x = Float::from_int(sw + @raylib.get_random_value(40, 220))
      coins[i].y_off = y_off + bob
      coins[i].value = value
      done = true
    }
  }
}

///|
fn spawn_powerup(powerups : Array[Powerup]) -> Unit {
  let lane = @raylib.get_random_value(0, lane_n - 1)
  let kind = @raylib.get_random_value(0, 2)
  let y_off : Float = if kind == 0 {
    -26.0
  } else if kind == 1 {
    -48.0
  } else {
    -72.0
  }

  let mut done = false
  for i = 0; i < powerups.length(); i = i + 1 {
    if done {
      continue
    }
    if not(powerups[i].active) {
      powerups[i].active = true
      powerups[i].lane = lane
      powerups[i].kind = kind
      powerups[i].x = Float::from_int(sw + @raylib.get_random_value(80, 320))
      powerups[i].y_off = y_off
      done = true
    }
  }
}

///|
fn spawn_train(train : TrainEvent, level : Int) -> Unit {
  train.active = true
  train.lane = @raylib.get_random_value(0, lane_n - 1)
  train.warning_t = Float::from_int(@raylib.get_random_value(120, 200)) / 100.0
  train.x = Float::from_int(sw + 420)
  train.speed = Float::from_int(@raylib.get_random_value(760 + level * 50, 920 + level * 70))
}

///|
fn setup_level(
  level : Int,
  runner : Runner,
  obstacles : Array[Obstacle],
  coins : Array[Coin],
  powerups : Array[Powerup],
  particles : Array[Particle],
  train : TrainEvent,
) -> (Int, Float, Float, Float) {
  reset_runner(runner)
  clear_obstacles(obstacles)
  clear_coins(coins)
  clear_powerups(powerups)
  clear_particles(particles)

  train.active = false
  train.lane = 1
  train.warning_t = 0.0
  train.x = 0.0
  train.speed = 0.0

  if level == 1 {
    (1450, 92.0, 360.0, 0.95)
  } else if level == 2 {
    (2050, 98.0, 430.0, 0.75)
  } else {
    (2800, 104.0, 500.0, 0.60)
  }
}

///|
fn obstacle_hit_center_y(ob : Obstacle) -> Float {
  lane_y(ob.lane) + ob.y_off - ob.h * 0.5
}

///|
fn main {
  @raylib.init_window(sw, sh, "Neon Subway Sprint 2026")
  @raylib.set_target_fps(60)

  let runner : Runner = {
    x: 220.0,
    y: lane_y(1),
    lane: 1,
    vy: 0.0,
    hp: 6,
    lane_cd: 0.0,
    dash_t: 0.0,
    invuln_t: 0.0,
  }

  let obstacles : Array[Obstacle] = Array::makei(max_obstacles, fn(_i) {
    {
      x: 0.0,
      lane: 0,
      kind: 0,
      w: 0.0,
      h: 0.0,
      y_off: 0.0,
      hp: 0,
      active: false,
    }
  })

  let coins : Array[Coin] = Array::makei(max_coins, fn(_i) {
    {
      x: 0.0,
      lane: 0,
      y_off: 0.0,
      value: 0,
      active: false,
    }
  })

  let powerups : Array[Powerup] = Array::makei(max_powerups, fn(_i) {
    {
      x: 0.0,
      lane: 0,
      kind: 0,
      y_off: 0.0,
      active: false,
    }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      ttl: 0.0,
      kind: 0,
      active: false,
    }
  })

  let train : TrainEvent = {
    active: false,
    lane: 1,
    x: 0.0,
    warning_t: 0.0,
    speed: 0.0,
  }

  let mut level = 1
  let mut target_score = 0
  let mut timer : Float = 0.0
  let mut speed : Float = 0.0
  let mut spawn_factor : Float = 0.0

  let (first_target, first_timer, first_speed, first_spawn) = setup_level(
    level,
    runner,
    obstacles,
    coins,
    powerups,
    particles,
    train,
  )
  target_score = first_target
  timer = first_timer
  speed = first_speed
  spawn_factor = first_spawn

  let mut stage_score = 0
  let mut total_score = 0
  let mut stars = 0

  let mut boost : Float = 100.0
  let mut magnet_t : Float = 0.0

  let mut obstacle_cd : Float = 0.75
  let mut coin_cd : Float = 0.22
  let mut powerup_cd : Float = 6.0
  let mut train_cd : Float = 11.0

  let mut wave_t : Float = 0.0
  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false

  let mut msg = "W/S lane switch, K jump, J dash."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    wave_t = wave_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm, rsp, rsf) = setup_level(level, runner, obstacles, coins, powerups, particles, train)
      target_score = rt
      timer = rtm
      speed = rsp
      spawn_factor = rsf

      stage_score = 0
      total_score = 0
      stars = 0

      boost = 100.0
      magnet_t = 0.0

      obstacle_cd = 0.75
      coin_cd = 0.22
      powerup_cd = 6.0
      train_cd = 11.0

      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Run reset."
    }

    if runner.lane_cd > 0.0 {
      runner.lane_cd = runner.lane_cd - dt
      if runner.lane_cd < 0.0 {
        runner.lane_cd = 0.0
      }
    }

    if runner.dash_t > 0.0 {
      runner.dash_t = runner.dash_t - dt
      if runner.dash_t < 0.0 {
        runner.dash_t = 0.0
      }
    }

    if runner.invuln_t > 0.0 {
      runner.invuln_t = runner.invuln_t - dt
      if runner.invuln_t < 0.0 {
        runner.invuln_t = 0.0
      }
    }

    if magnet_t > 0.0 {
      magnet_t = magnet_t - dt
      if magnet_t < 0.0 {
        magnet_t = 0.0
      }
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, ntm, nsp, nsf) = setup_level(level, runner, obstacles, coins, powerups, particles, train)
          target_score = nt
          timer = ntm
          speed = nsp
          spawn_factor = nsf

          stage_score = 0
          boost = 100.0
          magnet_t = 0.0

          obstacle_cd = 0.70
          coin_cd = 0.20
          powerup_cd = 5.0
          train_cd = 9.0
          msg = "Sector \{level} online."
        } else {
          over = true
          won = true
          msg = "Metro sprint complete."
        }
      }
    }

    if flash_t > 0.0 {
      flash_t = flash_t - dt
      if flash_t < 0.0 {
        flash_t = 0.0
      }
    }

    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }

    if not(over) && transition_t <= 0.0 {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        won = false
        msg = "Shift ended before quota."
      }

      let mut move_up = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut move_down = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut jump = @raylib.is_key_pressed(@raylib.KeyK) || @raylib.is_key_pressed(@raylib.KeySpace)
      let mut dash = @raylib.is_key_pressed(@raylib.KeyJ) || @raylib.is_key_pressed(@raylib.KeyLeftShift)

      let m = @raylib.get_mouse_position()
      let ctl_x = 16
      let ctl_y = sh - 186
      let jump_x = sw - 256
      let jump_y = sh - 170
      let dash_x = sw - 124
      let dash_y = sh - 170

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x + 76, ctl_y, 74, 58) {
          move_up = true
        }
        if inside_rect(m.x, m.y, ctl_x + 76, ctl_y + 66, 74, 58) {
          move_down = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, jump_x, jump_y, 116, 154) {
          jump = true
        }
        if inside_rect(m.x, m.y, dash_x, dash_y, 108, 154) {
          dash = true
        }
      }

      if runner.lane_cd <= 0.0 {
        if move_up && runner.lane > 0 {
          runner.lane = runner.lane - 1
          runner.lane_cd = 0.15
        } else if move_down && runner.lane < lane_n - 1 {
          runner.lane = runner.lane + 1
          runner.lane_cd = 0.15
        }
      }

      let ground = lane_y(runner.lane)
      let grounded = runner.y >= ground - 0.4 && absf(runner.vy) < 16.0

      if jump && grounded {
        runner.vy = -470.0
        burst(particles, runner.x - 10.0, runner.y + 6.0, 12, 0.25, 3)
      }

      if dash && runner.dash_t <= 0.0 && boost >= 35.0 {
        runner.dash_t = 0.24
        boost = boost - 35.0
        if boost < 0.0 {
          boost = 0.0
        }
        burst(particles, runner.x + 8.0, runner.y - 8.0, 18, 0.35, 1)
      }

      runner.vy = runner.vy + 980.0 * dt
      runner.y = runner.y + runner.vy * dt

      if runner.y >= ground {
        runner.y = ground
        if runner.vy > 0.0 {
          runner.vy = 0.0
        }
      }

      boost = boost + 24.0 * dt
      if boost > 100.0 {
        boost = 100.0
      }

      obstacle_cd = obstacle_cd - dt
      if obstacle_cd <= 0.0 {
        spawn_obstacle(obstacles, level, wave_t)
        let jitter = Float::from_int(@raylib.get_random_value(86, 128)) / Float::from_int(100)
        obstacle_cd = spawn_factor * jitter
      }

      coin_cd = coin_cd - dt
      if coin_cd <= 0.0 {
        spawn_coin(coins, level, wave_t)
        let jitter = Float::from_int(@raylib.get_random_value(70, 130)) / Float::from_int(100)
        coin_cd = 0.22 * jitter
      }

      powerup_cd = powerup_cd - dt
      if powerup_cd <= 0.0 {
        spawn_powerup(powerups)
        let jitter = Float::from_int(@raylib.get_random_value(72, 138)) / Float::from_int(100)
        powerup_cd = (6.5 - Float::from_int(level)) * jitter
      }

      train_cd = train_cd - dt
      if train_cd <= 0.0 && not(train.active) {
        spawn_train(train, level)
        let jitter = Float::from_int(@raylib.get_random_value(78, 138)) / Float::from_int(100)
        train_cd = (12.0 - Float::from_int(level) * 1.3) * jitter
      }

      let run_x = runner.x
      let run_y = runner.y - 28.0

      for i = 0; i < obstacles.length(); i = i + 1 {
        if not(obstacles[i].active) {
          continue
        }

        let obstacle_speed = if obstacles[i].kind == 2 {
          speed + 90.0
        } else {
          speed
        }
        obstacles[i].x = obstacles[i].x - obstacle_speed * dt

        if obstacles[i].x < -160.0 {
          obstacles[i].active = false
          continue
        }

        let ox = obstacles[i].x
        let oy = obstacle_hit_center_y(obstacles[i])

        let hit_x = absf(run_x - ox) <= obstacles[i].w * 0.5 + 20.0
        let hit_y = absf(run_y - oy) <= obstacles[i].h * 0.5 + 24.0

        if hit_x && hit_y {
          if runner.dash_t > 0.0 {
            obstacles[i].hp = obstacles[i].hp - 1
            burst(particles, ox, oy, 12, 0.30, 1)
            if obstacles[i].hp <= 0 {
              obstacles[i].active = false
              stage_score = stage_score + 55
              total_score = total_score + 55
              msg = "Smash bonus +55"
              burst(particles, ox, oy, 18, 0.45, 2)
            }
          } else if runner.invuln_t <= 0.0 {
            runner.hp = runner.hp - 1
            runner.invuln_t = 0.95
            flash_t = 0.30
            shake_t = 0.22
            msg = "Crash! HP -1"
            burst(particles, run_x, run_y, 20, 0.50, 0)

            if runner.hp <= 0 {
              over = true
              won = false
              msg = "Runner down."
            }
          }
        }
      }

      for i = 0; i < coins.length(); i = i + 1 {
        if not(coins[i].active) {
          continue
        }

        coins[i].x = coins[i].x - speed * dt

        if magnet_t > 0.0 {
          let cy = lane_y(coins[i].lane) + coins[i].y_off
          let dx = run_x - coins[i].x
          let dy = run_y - cy
          let d2 = dx * dx + dy * dy
          if d2 < 210.0 * 210.0 {
            let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }
            coins[i].x = coins[i].x + dx / d * 360.0 * dt
            coins[i].y_off = coins[i].y_off + dy / d * 360.0 * dt
          }
        }

        if coins[i].x < -80.0 {
          coins[i].active = false
          continue
        }

        let cy = lane_y(coins[i].lane) + coins[i].y_off
        if sqdist(run_x, run_y, coins[i].x, cy) <= 30.0 * 30.0 {
          let gain = coins[i].value * 14
          stage_score = stage_score + gain
          total_score = total_score + gain
          stars = stars + coins[i].value
          boost = boost + Float::from_int(4 + coins[i].value * 2)
          if boost > 100.0 {
            boost = 100.0
          }
          coins[i].active = false
          burst(particles, coins[i].x, cy, 8, 0.24, 3)
        }
      }

      for i = 0; i < powerups.length(); i = i + 1 {
        if not(powerups[i].active) {
          continue
        }

        powerups[i].x = powerups[i].x - speed * dt
        if powerups[i].x < -80.0 {
          powerups[i].active = false
          continue
        }

        let py = lane_y(powerups[i].lane) + powerups[i].y_off
        if sqdist(run_x, run_y, powerups[i].x, py) <= 34.0 * 34.0 {
          if powerups[i].kind == 0 {
            if runner.hp < 6 {
              runner.hp = runner.hp + 1
            }
            stage_score = stage_score + 60
            total_score = total_score + 60
            msg = "Med pack +1 HP"
          } else if powerups[i].kind == 1 {
            boost = boost + 42.0
            if boost > 100.0 {
              boost = 100.0
            }
            stage_score = stage_score + 50
            total_score = total_score + 50
            msg = "Battery charged"
          } else {
            magnet_t = 8.0
            stage_score = stage_score + 70
            total_score = total_score + 70
            msg = "Magnet online"
          }

          powerups[i].active = false
          burst(particles, powerups[i].x, py, 15, 0.36, 2)
        }
      }

      if train.active {
        if train.warning_t > 0.0 {
          train.warning_t = train.warning_t - dt
          if train.warning_t < 0.0 {
            train.warning_t = 0.0
          }
        } else {
          train.x = train.x - train.speed * dt

          if train.x < -520.0 {
            train.active = false
          }

          if runner.lane == train.lane {
            let train_hit_x = absf(runner.x - train.x) <= 210.0
            let train_hit_y = runner.y >= lane_y(train.lane) - 50.0
            if train_hit_x && train_hit_y && runner.invuln_t <= 0.0 {
              runner.hp = runner.hp - 2
              if runner.hp < 0 {
                runner.hp = 0
              }
              runner.invuln_t = 1.1
              flash_t = 0.35
              shake_t = 0.25
              msg = "Express train impact!"
              burst(particles, runner.x, runner.y - 20.0, 30, 0.58, 0)

              if runner.hp <= 0 {
                over = true
                won = false
                msg = "Runner down."
              }
            }
          }
        }
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vy = particles[i].vy + 260.0 * dt
        particles[i].ttl = particles[i].ttl - dt

        if particles[i].ttl <= 0.0 {
          particles[i].active = false
        }
      }

      if stage_score >= target_score {
        stars = stars + runner.hp * 2 + timer.to_int() / 8
        transition_t = 2.2
        msg = "Sector clear."
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(32, 16, 28, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 12, 22, 255))
    }

    let pulse = (wave_t * 3.0).to_int() % 140
    let sky_boost = if pulse < 70 { pulse } else { 140 - pulse }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 14 + sky_boost / 3, 30 + sky_boost / 2, 255))
    @raylib.draw_rectangle(0, 0, sw, 270, @raylib.Color::new(16, 26 + sky_boost / 3, 46 + sky_boost / 2, 255))

    for i = 0; i < 72; i = i + 1 {
      let x = ((i * 118 + (wave_t * (60.0 + Float::from_int(level) * 16.0)).to_int()) % (sw + 240)) - 120
      let h = 160 + (i * 57 % 220)
      let w = 48 + (i * 13 % 72)
      let c = 24 + (i * 19 % 52)
      @raylib.draw_rectangle(x, sh - h, w, h, @raylib.Color::new(c, c + 14, c + 44, 255))
      if i % 3 == 0 {
        @raylib.draw_rectangle(x + 8, sh - h + 24, 8, h - 30, @raylib.Color::new(50, 170, 220, 210))
      }
    }

    for lane = 0; lane < lane_n; lane = lane + 1 {
      let y = lane_y(lane)
      @raylib.draw_rectangle(0, (y - 30.0).to_int(), sw, 62, @raylib.Color::new(32, 36, 48, 255))
      @raylib.draw_line(0, (y - 16.0).to_int(), sw, (y - 16.0).to_int(), @raylib.Color::new(112, 122, 144, 255))
      @raylib.draw_line(0, (y + 16.0).to_int(), sw, (y + 16.0).to_int(), @raylib.Color::new(112, 122, 144, 255))

      for p = 0; p < 25; p = p + 1 {
        let x = ((p * 70 + (wave_t * speed / 9.0).to_int()) % (sw + 120)) - 60
        @raylib.draw_rectangle(x, (y - 22.0).to_int(), 20, 44, @raylib.Color::new(68, 60, 52, 255))
      }
    }

    if train.active {
      let y = lane_y(train.lane)
      if train.warning_t > 0.0 {
        let blink = (train.warning_t * 12.0).to_int() % 2 == 0
        if blink {
          @raylib.draw_rectangle(0, (y - 44.0).to_int(), sw, 88, @raylib.Color::new(200, 56, 56, 84))
          @raylib.draw_text("EXPRESS INBOUND", sw / 2 - 160, (y - 24.0).to_int(), 34, @raylib.Color::new(255, 210, 210, 255))
        }
      } else {
        let tx = (train.x + shake_x).to_int()
        @raylib.draw_rectangle(tx - 220, (y - 36.0).to_int(), 440, 72, @raylib.Color::new(194, 72, 88, 255))
        @raylib.draw_rectangle(tx - 206, (y - 20.0).to_int(), 150, 28, @raylib.Color::new(236, 214, 230, 255))
        @raylib.draw_rectangle(tx + 34, (y - 20.0).to_int(), 150, 28, @raylib.Color::new(236, 214, 230, 255))
        @raylib.draw_circle(tx - 154, (y + 28.0).to_int(), 10.0, @raylib.Color::new(30, 34, 42, 255))
        @raylib.draw_circle(tx + 154, (y + 28.0).to_int(), 10.0, @raylib.Color::new(30, 34, 42, 255))
      }
    }

    for i = 0; i < obstacles.length(); i = i + 1 {
      if not(obstacles[i].active) {
        continue
      }

      let ox = (obstacles[i].x + shake_x).to_int()
      let base_y = lane_y(obstacles[i].lane)
      let top = (base_y + obstacles[i].y_off - obstacles[i].h).to_int()

      if obstacles[i].kind == 0 {
        @raylib.draw_rectangle(ox - 26, top, 52, obstacles[i].h.to_int(), @raylib.Color::new(222, 122, 82, 255))
        @raylib.draw_rectangle(ox - 30, top + 10, 60, 10, @raylib.Color::new(246, 188, 72, 255))
      } else if obstacles[i].kind == 1 {
        @raylib.draw_rectangle(ox - 32, top, 64, obstacles[i].h.to_int(), @raylib.Color::new(122, 84, 184, 255))
        @raylib.draw_rectangle(ox - 24, top + 14, 48, 14, @raylib.Color::new(198, 162, 240, 255))
        @raylib.draw_text("2", ox - 6, top + 36, 28, @raylib.Color::new(248, 236, 172, 255))
      } else if obstacles[i].kind == 2 {
        @raylib.draw_circle(ox, top + 20, 22.0, @raylib.Color::new(94, 220, 242, 255))
        @raylib.draw_circle(ox - 4, top + 16, 8.0, @raylib.Color::new(196, 250, 255, 255))
      } else {
        @raylib.draw_rectangle(ox - 35, top + 8, 70, 22, @raylib.Color::new(86, 178, 116, 255))
        @raylib.draw_circle(ox - 22, top + 30, 7.0, @raylib.Color::new(28, 32, 36, 255))
        @raylib.draw_circle(ox + 22, top + 30, 7.0, @raylib.Color::new(28, 32, 36, 255))
      }
    }

    for i = 0; i < coins.length(); i = i + 1 {
      if not(coins[i].active) {
        continue
      }
      let cx = (coins[i].x + shake_x).to_int()
      let cy = (lane_y(coins[i].lane) + coins[i].y_off).to_int()
      let r : Float = if coins[i].value == 3 { 11.0 } else if coins[i].value == 2 { 9.0 } else { 8.0 }
      @raylib.draw_circle(cx, cy, r, @raylib.Color::new(244, 214, 90, 255))
      @raylib.draw_circle(cx, cy, r * 0.55, @raylib.Color::new(252, 240, 180, 255))
      if coins[i].value > 1 {
        @raylib.draw_text("\{coins[i].value}", cx - 6, cy - 10, 18, @raylib.Color::new(80, 60, 20, 255))
      }
    }

    for i = 0; i < powerups.length(); i = i + 1 {
      if not(powerups[i].active) {
        continue
      }
      let px = (powerups[i].x + shake_x).to_int()
      let py = (lane_y(powerups[i].lane) + powerups[i].y_off).to_int()

      if powerups[i].kind == 0 {
        @raylib.draw_rectangle(px - 14, py - 12, 28, 24, @raylib.Color::new(94, 212, 146, 255))
        @raylib.draw_rectangle(px - 4, py - 18, 8, 36, @raylib.Color::new(224, 250, 236, 255))
        @raylib.draw_rectangle(px - 14, py - 4, 28, 8, @raylib.Color::new(224, 250, 236, 255))
      } else if powerups[i].kind == 1 {
        @raylib.draw_rectangle(px - 13, py - 18, 26, 36, @raylib.Color::new(90, 182, 246, 255))
        @raylib.draw_rectangle(px - 6, py - 24, 12, 8, @raylib.Color::new(206, 234, 252, 255))
      } else {
        @raylib.draw_circle(px, py, 16.0, @raylib.Color::new(190, 118, 252, 255))
        @raylib.draw_circle(px, py, 9.0, @raylib.Color::new(238, 214, 255, 255))
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let c = if particles[i].kind == 0 {
        @raylib.Color::new(255, 124, 124, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(250, 212, 118, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(214, 152, 255, 255)
      } else {
        @raylib.Color::new(110, 226, 246, 255)
      }

      @raylib.draw_circle((particles[i].x + shake_x).to_int(), particles[i].y.to_int(), 2.0, c)
    }

    if runner.invuln_t <= 0.0 || (runner.invuln_t * 13.0).to_int() % 2 == 0 {
      let rx = (runner.x + shake_x).to_int()
      let ry = runner.y.to_int()
      let dash_col = if runner.dash_t > 0.0 {
        @raylib.Color::new(252, 232, 124, 255)
      } else {
        @raylib.Color::new(218, 232, 248, 255)
      }

      @raylib.draw_triangle(
        @raylib.Vector2::new(runner.x + 26.0 + shake_x, runner.y - 8.0),
        @raylib.Vector2::new(runner.x - 20.0 + shake_x, runner.y - 22.0),
        @raylib.Vector2::new(runner.x - 20.0 + shake_x, runner.y + 6.0),
        dash_col,
      )
      @raylib.draw_rectangle(rx - 10, ry - 24, 18, 24, @raylib.Color::new(92, 186, 244, 255))
      @raylib.draw_circle(rx - 2, ry - 30, 9.0, @raylib.Color::new(236, 248, 255, 255))
      @raylib.draw_line(rx - 24, ry + 2, rx + 10, ry + 2, @raylib.Color::new(96, 236, 248, 255))

      if runner.dash_t > 0.0 {
        @raylib.draw_line(rx - 50, ry - 8, rx - 16, ry - 8, @raylib.Color::new(250, 222, 122, 255))
        @raylib.draw_line(rx - 56, ry, rx - 22, ry, @raylib.Color::new(250, 222, 122, 255))
        @raylib.draw_line(rx - 50, ry + 8, rx - 16, ry + 8, @raylib.Color::new(250, 222, 122, 255))
      }
    }

    @raylib.draw_rectangle(0, 0, sw, 108, @raylib.Color::new(8, 10, 18, 232))
    @raylib.draw_text("NEON SUBWAY SPRINT 2026", 16, 16, 34, @raylib.Color::new(236, 246, 254, 255))
    @raylib.draw_text("Sector \{level}/3", 432, 24, 30, @raylib.Color::new(246, 224, 140, 255))
    @raylib.draw_text("Stage \{stage_score}/\{target_score}", 614, 24, 30, @raylib.Color::new(214, 236, 252, 255))
    @raylib.draw_text("Total \{total_score}", 944, 24, 30, @raylib.Color::new(214, 236, 252, 255))

    @raylib.draw_text("HP \{runner.hp}", 20, 70, 24, @raylib.Color::new(220, 236, 250, 255))
    @raylib.draw_text("Boost \{boost.to_int()}%", 148, 70, 24, @raylib.Color::new(220, 236, 250, 255))
    @raylib.draw_text("Timer \{timer.to_int()}", 360, 70, 24, @raylib.Color::new(252, 214, 146, 255))
    @raylib.draw_text("Stars \{stars}", 548, 70, 24, @raylib.Color::new(250, 232, 138, 255))
    @raylib.draw_text(
      if magnet_t > 0.0 { "Magnet ON" } else { "Magnet OFF" },
      706,
      70,
      24,
      if magnet_t > 0.0 { @raylib.Color::new(198, 150, 252, 255) } else { @raylib.Color::new(128, 140, 156, 255) },
    )

    @raylib.draw_rectangle(16, 106, 230, 10, @raylib.Color::new(24, 28, 38, 255))
    @raylib.draw_rectangle(16, 106, (Float::from_int(runner.hp) / 6.0 * 230.0).to_int(), 10, @raylib.Color::new(110, 226, 146, 255))
    @raylib.draw_rectangle(264, 106, 230, 10, @raylib.Color::new(24, 28, 38, 255))
    @raylib.draw_rectangle(264, 106, (boost / 100.0 * 230.0).to_int(), 10, @raylib.Color::new(94, 194, 246, 255))

    let stage_ratio = clampf(Float::from_int(stage_score) / Float::from_int(target_score), 0.0, 1.0)
    @raylib.draw_rectangle(512, 106, 230, 10, @raylib.Color::new(24, 28, 38, 255))
    @raylib.draw_rectangle(512, 106, (stage_ratio * 230.0).to_int(), 10, @raylib.Color::new(242, 186, 96, 255))

    @raylib.draw_rectangle(8, sh - 194, 236, 186, @raylib.Color::new(8, 14, 28, 220))
    @raylib.draw_text("Touch", 86, sh - 186, 20, @raylib.white)

    let ctl_x = 16
    let ctl_y = sh - 186
    @raylib.draw_rectangle(ctl_x + 76, ctl_y, 74, 58, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("UP", ctl_x + 92, ctl_y + 18, 24, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 76, ctl_y + 66, 74, 58, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("DN", ctl_x + 90, ctl_y + 84, 24, @raylib.white)

    let jump_x = sw - 256
    let jump_y = sh - 170
    let dash_x = sw - 124
    let dash_y = sh - 170

    @raylib.draw_rectangle(jump_x, jump_y, 116, 154, @raylib.Color::new(88, 142, 218, 255))
    @raylib.draw_text("JUMP", jump_x + 16, jump_y + 58, 30, @raylib.white)
    @raylib.draw_rectangle(dash_x, dash_y, 108, 154, @raylib.Color::new(218, 124, 72, 255))
    @raylib.draw_text("DASH", dash_x + 12, dash_y + 58, 30, @raylib.white)

    @raylib.draw_rectangle(250, sh - 56, sw - 516, 40, @raylib.Color::new(6, 10, 18, 220))
    @raylib.draw_text(msg, 262, sh - 48, 24, @raylib.Color::new(224, 236, 248, 255))

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 110))
      @raylib.draw_text("SECTOR CLEAR", sw / 2 - 166, sh / 2 - 28, 54, @raylib.Color::new(250, 236, 146, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 130))
      @raylib.draw_rectangle(sw / 2 - 350, sh / 2 - 108, 700, 216, @raylib.Color::new(16, 24, 40, 244))
      @raylib.draw_text(
        if won { "RUN COMPLETE" } else { "RUN FAILED" },
        sw / 2 - 190,
        sh / 2 - 34,
        64,
        if won { @raylib.Color::new(252, 238, 146, 255) } else { @raylib.Color::new(252, 140, 140, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 44, 34, @raylib.Color::new(224, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
