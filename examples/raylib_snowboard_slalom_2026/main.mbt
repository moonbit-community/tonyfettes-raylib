///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let rider_screen_y : Float = 540.0

///|
let max_gates : Int = 72

///|
let max_obstacles : Int = 280

///|
let max_pickups : Int = 120

///|
let max_particles : Int = 920

///|
struct Rider {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut stamina : Float
  mut speed : Float
  mut air_t : Float
  mut trick_t : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut flash_t : Float
  mut score : Int
  mut combo : Int
}

///|
struct Gate {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut state : Int
  mut pulse_t : Float
}

///|
struct Obstacle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : Int
  mut size : Float
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : Int
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
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
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
fn clear_gates(gates : Array[Gate]) -> Unit {
  for i = 0; i < gates.length(); i = i + 1 {
    gates[i].active = false
    gates[i].x = 0.0
    gates[i].y = 0.0
    gates[i].w = 0.0
    gates[i].state = 0
    gates[i].pulse_t = 0.0
  }
}

///|
fn clear_obstacles(obs : Array[Obstacle]) -> Unit {
  for i = 0; i < obs.length(); i = i + 1 {
    obs[i].active = false
    obs[i].x = 0.0
    obs[i].y = 0.0
    obs[i].kind = 0
    obs[i].size = 0.0
  }
}

///|
fn clear_pickups(ps : Array[Pickup]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].kind = 0
    ps[i].t = 0.0
  }
}

///|
fn clear_particles(ps : Array[Particle]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].size = 0.0
    ps[i].t = 0.0
    ps[i].life = 0.0
    ps[i].kind = 0
  }
}

///|
fn spawn_particle(
  ps : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done : Bool = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }

    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      ps[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      ps[i].t = 0.0
      ps[i].life = Float::from_int(@raylib.get_random_value(16, 70)) / 100.0
      ps[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  ps : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    ignore(i)
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn nearest_gate_y(
  gates : Array[Gate],
  gate_count : Int,
  rider_y : Float,
) -> Float {
  let mut best : Float = 9999999.0
  for i = 0; i < gate_count; i = i + 1 {
    if gates[i].state == 0 {
      let dy = gates[i].y - rider_y
      if dy >= -50.0 && dy < best {
        best = dy
      }
    }
  }
  best
}

///|
fn setup_course(
  gates : Array[Gate],
  obs : Array[Obstacle],
  pickups : Array[Pickup],
) -> (Int, Float) {
  clear_gates(gates)
  clear_obstacles(obs)
  clear_pickups(pickups)

  let gate_count : Int = 66
  let mut y : Float = 460.0

  for i = 0; i < gate_count; i = i + 1 {
    gates[i].active = true
    gates[i].x = randf(180.0, 1100.0)
    gates[i].y = y + randf(-28.0, 34.0)
    gates[i].w = randf(180.0, 248.0)
    gates[i].state = 0
    gates[i].pulse_t = randf(0.0, 1.0)

    y = y + randf(170.0, 220.0)
  }

  let course_end : Float = gates[gate_count - 1].y + 500.0

  for i = 0; i < obs.length(); i = i + 1 {
    obs[i].active = true
    obs[i].x = randf(70.0, world_w - 70.0)
    obs[i].y = randf(360.0, course_end + 120.0)
    obs[i].kind = @raylib.get_random_value(0, 2)
    obs[i].size = if obs[i].kind == 0 {
      randf(14.0, 22.0)
    } else if obs[i].kind == 1 {
      randf(18.0, 28.0)
    } else {
      randf(16.0, 24.0)
    }
  }

  let mut p = 0
  for i = 0; i < gate_count; i = i + 1 {
    if i % 2 == 0 && p < pickups.length() {
      pickups[p].active = true
      pickups[p].x = gates[i].x + randf(-52.0, 52.0)
      pickups[p].y = gates[i].y + randf(-30.0, 30.0)
      pickups[p].kind = @raylib.get_random_value(0, 2)
      pickups[p].t = randf(0.0, 1.0)
      p = p + 1
    }
  }

  (gate_count, course_end)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Snowboard Slalom 2026")
  @raylib.set_target_fps(60)

  let rider : Rider = {
    x: 640.0,
    y: 220.0,
    vx: 0.0,
    hp: 230.0,
    stamina: 100.0,
    speed: 220.0,
    air_t: 0.0,
    trick_t: 0.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    flash_t: 0.0,
    score: 0,
    combo: 0,
  }

  let gates : Array[Gate] = Array::makei(max_gates, fn(_i) {
    { active: false, x: 0.0, y: 0.0, w: 0.0, state: 0, pulse_t: 0.0 }
  })

  let obstacles : Array[Obstacle] = Array::makei(max_obstacles, fn(_i) {
    { active: false, x: 0.0, y: 0.0, kind: 0, size: 0.0 }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, x: 0.0, y: 0.0, kind: 0, t: 0.0 }
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

  let mut gate_count : Int = 0
  let mut course_end : Float = 0.0

  let mut state : Int = 0
  let mut time_left : Float = 240.0
  let mut gates_clean : Int = 0
  let mut gates_miss : Int = 0
  let mut wave : Int = 1

  let mut msg : String = "Ski through gates, avoid obstacles, land tricks"
  let mut msg_t : Float = 3.4

  let reset_game = fn() {
    rider.x = 640.0
    rider.y = 220.0
    rider.vx = 0.0
    rider.hp = 230.0
    rider.stamina = 100.0
    rider.speed = 220.0
    rider.air_t = 0.0
    rider.trick_t = 0.0
    rider.boost_t = 0.0
    rider.boost_cd = 0.0
    rider.flash_t = 0.0
    rider.score = 0
    rider.combo = 0

    time_left = 240.0
    gates_clean = 0
    gates_miss = 0
    wave = 1

    let (n, end_y) = setup_course(gates, obstacles, pickups)
    gate_count = n
    course_end = end_y

    clear_particles(particles)

    msg = "Gate 1 incoming"
    msg_t = 2.2
  }

  reset_game()

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

    if rider.flash_t > 0.0 {
      rider.flash_t = rider.flash_t - dt
      if rider.flash_t < 0.0 {
        rider.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_game()
      }
    } else if state == 1 {
      time_left = time_left - dt

      rider.air_t = rider.air_t - dt
      if rider.air_t < 0.0 {
        rider.air_t = 0.0
      }
      rider.boost_t = rider.boost_t - dt
      if rider.boost_t < 0.0 {
        rider.boost_t = 0.0
      }
      rider.boost_cd = rider.boost_cd - dt
      if rider.boost_cd < 0.0 {
        rider.boost_cd = 0.0
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut jump_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut boost_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)

      let pad_x : Int = 28
      let pad_y : Int = sh - 186
      let btn_x : Int = sw - 248
      let btn_y : Int = sh - 212

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 54, 92, 72) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 112, pad_y + 54, 92, 72) {
          move_r = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 6, 108, 82) {
          jump_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 118, btn_y + 6, 108, 82) {
          boost_press = true
        }
      }

      let steer_axis : Int = if move_l && not(move_r) {
        -1
      } else if move_r && not(move_l) {
        1
      } else {
        0
      }

      let mut steer_acc : Float = 760.0
      if rider.air_t > 0.0 {
        steer_acc = 440.0
      }
      rider.vx = rider.vx + Float::from_int(steer_axis) * steer_acc * dt

      let mut drag : Float = 3.0
      if rider.air_t > 0.0 {
        drag = 1.8
      }
      rider.vx = rider.vx * (Float::from_int(1) - dt * drag)

      let mut max_vx : Float = 280.0
      if rider.boost_t > 0.0 {
        max_vx = 390.0
      }
      rider.vx = clampf(rider.vx, -max_vx, max_vx)

      rider.x = rider.x + rider.vx * dt
      rider.x = clampf(rider.x, 28.0, world_w - 28.0)

      rider.speed = 226.0 +
        rider.y / course_end * 130.0 +
        Float::from_int(wave - 1) * 10.0
      if rider.boost_t > 0.0 {
        rider.speed = rider.speed + 220.0
      }
      if rider.hp < 90.0 {
        rider.speed = rider.speed - 40.0
      }
      if rider.speed < 120.0 {
        rider.speed = 120.0
      }

      rider.y = rider.y + rider.speed * dt

      rider.stamina = rider.stamina + dt * 21.0
      if rider.stamina > 100.0 {
        rider.stamina = 100.0
      }

      if jump_press && rider.air_t <= 0.0 && rider.stamina >= 16.0 {
        rider.air_t = 0.58
        rider.trick_t = 0.0
        rider.stamina = rider.stamina - 16.0
        msg = "Jump"
        msg_t = 0.52
        burst(particles, rider.x, rider.y - 10.0, 10, 0.22, 0)
      }

      if rider.air_t > 0.0 {
        if steer_axis != 0 {
          rider.trick_t = rider.trick_t + dt * 1.22
          if rider.boost_t > 0.0 {
            rider.trick_t = rider.trick_t + dt * 0.82
          }
          if rider.trick_t > 1.7 {
            rider.trick_t = 1.7
          }
        }
      }

      if boost_press && rider.boost_cd <= 0.0 && rider.stamina >= 24.0 {
        rider.boost_t = 0.40
        rider.boost_cd = 1.55
        rider.stamina = rider.stamina - 24.0
        burst(particles, rider.x, rider.y, 16, 0.26, 1)
      }

      if rider.air_t <= 0.0 && rider.trick_t > 0.0 {
        if rider.trick_t >= 0.26 {
          let trick_pts : Int = (rider.trick_t * 480.0).to_int() +
            rider.combo * 7
          rider.score = rider.score + trick_pts
          rider.combo = rider.combo + 1
          msg = "Trick +\{trick_pts}"
          msg_t = 0.86
          burst(particles, rider.x, rider.y, 16, 0.24, 1)
        }
        rider.trick_t = 0.0
      }

      for i = 0; i < gate_count; i = i + 1 {
        if not(gates[i].active) {
          continue
        }

        gates[i].pulse_t = gates[i].pulse_t + dt

        if gates[i].state == 0 && rider.y >= gates[i].y {
          let dx = absf(rider.x - gates[i].x)
          if dx <= gates[i].w * 0.5 {
            gates[i].state = 1
            gates_clean = gates_clean + 1
            rider.combo = rider.combo + 1
            rider.score = rider.score + 120 + rider.combo * 8
            rider.hp = rider.hp + 4.0
            if rider.hp > 230.0 {
              rider.hp = 230.0
            }
            msg = "Gate clean"
            msg_t = 0.6
            burst(particles, gates[i].x, gates[i].y, 8, 0.20, 1)
          } else {
            gates[i].state = 2
            gates_miss = gates_miss + 1
            rider.combo = 0
            rider.hp = rider.hp - 16.0
            rider.flash_t = 0.16
            msg = "Missed gate"
            msg_t = 0.7
            burst(particles, gates[i].x, gates[i].y, 10, 0.24, 3)
          }

          if gates_clean % 11 == 0 {
            wave = wave + 1
          }
        }
      }

      for i = 0; i < obstacles.length(); i = i + 1 {
        if not(obstacles[i].active) {
          continue
        }

        if obstacles[i].y < rider.y - 120.0 {
          obstacles[i].active = false
          continue
        }

        if absf(obstacles[i].y - rider.y) <= obstacles[i].size + 22.0 &&
          absf(obstacles[i].x - rider.x) <= obstacles[i].size + 16.0 {
          let hit_dmg : Float = if obstacles[i].kind == 1 { 22.0 } else { 14.0 }
          rider.hp = rider.hp - hit_dmg
          rider.flash_t = 0.2
          let push_x : Float = if rider.x < obstacles[i].x {
            -160.0
          } else {
            160.0
          }
          rider.vx = rider.vx + push_x
          rider.combo = 0
          obstacles[i].active = false
          msg = "Hit obstacle"
          msg_t = 0.72
          burst(particles, rider.x, rider.y, 14, 0.26, 3)
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }

        pickups[i].t = pickups[i].t + dt

        if dist2(rider.x, rider.y, pickups[i].x, pickups[i].y) <= 28.0 * 28.0 {
          if pickups[i].kind == 0 {
            rider.hp = rider.hp + 30.0
            if rider.hp > 230.0 {
              rider.hp = 230.0
            }
            msg = "Medkit"
          } else if pickups[i].kind == 1 {
            rider.stamina = rider.stamina + 30.0
            if rider.stamina > 100.0 {
              rider.stamina = 100.0
            }
            msg = "Energy"
          } else {
            rider.boost_cd = rider.boost_cd - 0.6
            if rider.boost_cd < 0.0 {
              rider.boost_cd = 0.0
            }
            rider.score = rider.score + 38
            msg = "Turbo cell"
          }

          msg_t = 0.62
          rider.score = rider.score + 24
          pickups[i].active = false
          burst(particles, rider.x, rider.y, 10, 0.22, 0)
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
          particles[i].vy = particles[i].vy + 300.0 * dt
        }
      }

      if rider.hp <= 0.0 || time_left <= 0.0 {
        state = 3
      } else if rider.y >= course_end {
        state = 2
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_game()
      }
    }

    let cam_y : Float = rider.y - rider_screen_y

    @raylib.begin_drawing()

    let mut bg = @raylib.Color::new(142, 192, 250, 255)
    if state == 2 {
      bg = @raylib.Color::new(148, 210, 186, 255)
    } else if state == 3 {
      bg = @raylib.Color::new(176, 146, 168, 255)
    }
    @raylib.clear_background(bg)

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(220, 236, 255, 170))

    let line_shift = (cam_y / 36.0).to_int() % 2
    for i = -2; i < 28; i = i + 1 {
      let sy = i * 36 - cam_y.to_int() % 36
      let stripe = if (i + line_shift) % 2 == 0 { 236 } else { 226 }
      @raylib.draw_rectangle(
        0,
        sy,
        sw,
        36,
        @raylib.Color::new(stripe, stripe + 10, 255, 255),
      )
    }

    for i = 0; i < 24; i = i + 1 {
      let ridge_x = i * 62 + (cam_y * 0.25).to_int() % 62
      @raylib.draw_rectangle(
        ridge_x,
        74,
        2,
        sh - 74,
        @raylib.Color::new(208, 226, 246, 170),
      )
    }

    for i = 0; i < gate_count; i = i + 1 {
      if not(gates[i].active) {
        continue
      }

      let sy = gates[i].y - cam_y
      if sy < -90.0 || sy > Float::from_int(sh + 90) {
        continue
      }

      let lx = gates[i].x - gates[i].w * 0.5
      let rx = gates[i].x + gates[i].w * 0.5

      let mut pole_col = @raylib.Color::new(74, 106, 168, 255)
      let mut banner_col = @raylib.Color::new(86, 188, 246, 220)
      if gates[i].state == 1 {
        pole_col = @raylib.Color::new(72, 162, 104, 255)
        banner_col = @raylib.Color::new(108, 232, 160, 220)
      } else if gates[i].state == 2 {
        pole_col = @raylib.Color::new(178, 82, 104, 255)
        banner_col = @raylib.Color::new(236, 128, 144, 220)
      }

      @raylib.draw_rectangle(
        (lx - 6.0).to_int(),
        (sy - 40.0).to_int(),
        12,
        80,
        pole_col,
      )
      @raylib.draw_rectangle(
        (rx - 6.0).to_int(),
        (sy - 40.0).to_int(),
        12,
        80,
        pole_col,
      )
      @raylib.draw_rectangle(
        (lx + 6.0).to_int(),
        (sy - 24.0).to_int(),
        (gates[i].w - 12.0).to_int(),
        16,
        banner_col,
      )
    }

    for i = 0; i < obstacles.length(); i = i + 1 {
      if not(obstacles[i].active) {
        continue
      }

      let sy = obstacles[i].y - cam_y
      if sy < -70.0 || sy > Float::from_int(sh + 70) {
        continue
      }

      if obstacles[i].kind == 0 {
        @raylib.draw_circle(
          obstacles[i].x.to_int(),
          sy.to_int(),
          obstacles[i].size,
          @raylib.Color::new(112, 126, 148, 255),
        )
      } else if obstacles[i].kind == 1 {
        @raylib.draw_triangle(
          @raylib.Vector2::new(obstacles[i].x, sy - obstacles[i].size),
          @raylib.Vector2::new(
            obstacles[i].x - obstacles[i].size,
            sy + obstacles[i].size,
          ),
          @raylib.Vector2::new(
            obstacles[i].x + obstacles[i].size,
            sy + obstacles[i].size,
          ),
          @raylib.Color::new(66, 132, 86, 255),
        )
      } else {
        @raylib.draw_rectangle(
          (obstacles[i].x - obstacles[i].size).to_int(),
          (sy - obstacles[i].size).to_int(),
          (obstacles[i].size * 2.0).to_int(),
          (obstacles[i].size * 2.0).to_int(),
          @raylib.Color::new(166, 136, 102, 255),
        )
      }
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }

      let sy = pickups[i].y - cam_y
      if sy < -60.0 || sy > Float::from_int(sh + 60) {
        continue
      }

      let blink = if (pickups[i].t * 7.0).to_int() % 2 == 0 { 255 } else { 180 }
      let col = if pickups[i].kind == 0 {
        @raylib.Color::new(226, 122, 132, blink)
      } else if pickups[i].kind == 1 {
        @raylib.Color::new(122, 226, 162, blink)
      } else {
        @raylib.Color::new(128, 206, 252, blink)
      }
      @raylib.draw_circle(pickups[i].x.to_int(), sy.to_int(), 10.0, col)
      @raylib.draw_circle_lines(
        pickups[i].x.to_int(),
        sy.to_int(),
        16.0,
        @raylib.Color::new(246, 250, 255, blink),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let sy = particles[i].y - cam_y
      let k = particles[i].t / particles[i].life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(118, 220, 252, a)
      if particles[i].kind == 1 {
        c = @raylib.Color::new(142, 248, 188, a)
      } else if particles[i].kind == 2 {
        c = @raylib.Color::new(252, 192, 106, a)
      } else if particles[i].kind == 3 {
        c = @raylib.Color::new(236, 96, 118, a)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        sy.to_int(),
        particles[i].size,
        c,
      )
    }

    let rider_sy : Float = rider.y - cam_y

    let mut body_col = @raylib.Color::new(242, 176, 72, 255)
    if rider.flash_t > 0.0 {
      body_col = @raylib.Color::new(255, 240, 222, 255)
    }

    @raylib.draw_rectangle(
      (rider.x - 24.0).to_int(),
      (rider_sy + 8.0).to_int(),
      48,
      8,
      @raylib.Color::new(62, 78, 112, 255),
    )
    @raylib.draw_circle(
      rider.x.to_int(),
      (rider_sy - 4.0).to_int(),
      13.0,
      body_col,
    )
    @raylib.draw_rectangle(
      (rider.x - 8.0).to_int(),
      (rider_sy + 4.0).to_int(),
      16,
      12,
      @raylib.Color::new(28, 34, 48, 255),
    )

    if rider.air_t > 0.0 {
      @raylib.draw_circle_lines(
        rider.x.to_int(),
        rider_sy.to_int(),
        24.0,
        @raylib.Color::new(132, 224, 252, 220),
      )
    }

    if rider.boost_t > 0.0 {
      @raylib.draw_rectangle(
        (rider.x - 28.0).to_int(),
        (rider_sy + 2.0).to_int(),
        6,
        10,
        @raylib.Color::new(112, 212, 252, 255),
      )
      @raylib.draw_rectangle(
        (rider.x + 22.0).to_int(),
        (rider_sy + 2.0).to_int(),
        6,
        10,
        @raylib.Color::new(112, 212, 252, 255),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 12, 22, 222))
    @raylib.draw_text(
      "SNOWBOARD SLALOM 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 244, 255, 255),
    )
    @raylib.draw_text(
      "A/D steer  J jump trick  K boost",
      20,
      48,
      18,
      @raylib.Color::new(178, 204, 236, 255),
    )

    @raylib.draw_text(
      "Score \{rider.score}",
      470,
      16,
      28,
      @raylib.Color::new(246, 216, 118, 255),
    )
    @raylib.draw_text(
      "Combo \{rider.combo}",
      670,
      16,
      28,
      @raylib.Color::new(170, 238, 194, 255),
    )
    @raylib.draw_text(
      "Clean \{gates_clean}/\{gate_count}",
      860,
      16,
      28,
      @raylib.Color::new(180, 226, 252, 255),
    )
    @raylib.draw_text(
      "Time \{time_left.to_int()}s",
      1100,
      16,
      28,
      @raylib.Color::new(248, 188, 132, 255),
    )

    @raylib.draw_rectangle(20, 82, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      82,
      (rider.hp / 230.0 * 220.0).to_int(),
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
      (rider.stamina / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(116, 198, 248, 255),
    )
    @raylib.draw_text(
      "STAMINA",
      254,
      96,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    let dist_left : Float = course_end - rider.y
    let next_gate_dy = nearest_gate_y(gates, gate_count, rider.y)
    @raylib.draw_text(
      "Finish \{dist_left.to_int()}m",
      520,
      82,
      20,
      @raylib.Color::new(234, 238, 248, 255),
    )
    if next_gate_dy < 9000000.0 {
      @raylib.draw_text(
        "Next gate \{next_gate_dy.to_int()}m",
        700,
        82,
        20,
        @raylib.Color::new(196, 226, 248, 255),
      )
    }
    @raylib.draw_text(
      "Missed \{gates_miss}",
      920,
      82,
      20,
      @raylib.Color::new(242, 162, 172, 255),
    )
    @raylib.draw_text(
      "Wave \{wave}",
      1080,
      82,
      20,
      @raylib.Color::new(250, 206, 132, 255),
    )

    @raylib.draw_rectangle(
      16,
      sh - 204,
      234,
      194,
      @raylib.Color::new(8, 12, 20, 208),
    )
    let lpx = 28
    let lpy = sh - 186
    @raylib.draw_rectangle(
      lpx,
      lpy + 54,
      92,
      72,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "LEFT",
      lpx + 18,
      lpy + 80,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      lpx + 112,
      lpy + 54,
      92,
      72,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "RIGHT",
      lpx + 124,
      lpy + 80,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 258,
      sh - 220,
      242,
      210,
      @raylib.Color::new(8, 12, 20, 208),
    )
    let rbx = sw - 248
    let rby = sh - 212
    @raylib.draw_rectangle(
      rbx,
      rby + 6,
      108,
      82,
      @raylib.Color::new(90, 156, 226, 255),
    )
    @raylib.draw_text(
      "JUMP",
      rbx + 18,
      rby + 36,
      26,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      rbx + 118,
      rby + 6,
      108,
      82,
      @raylib.Color::new(214, 112, 92, 255),
    )
    @raylib.draw_text(
      "BOOST",
      rbx + 132,
      rby + 36,
      24,
      @raylib.Color::new(252, 236, 228, 255),
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
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 156 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 128))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 244),
      )
      @raylib.draw_text(
        "SNOWBOARD SLALOM",
        sw / 2 - 264,
        sh / 2 - 132,
        62,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Thread gates, avoid trees and rocks, chain tricks in the air",
        sw / 2 - 352,
        sh / 2 - 30,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left-right pad, jump and boost buttons",
        sw / 2 - 280,
        sh / 2 + 16,
        28,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 166,
        sh / 2 + 106,
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
        "COURSE CLEARED",
        sw / 2 - 220,
        sh / 2 - 132,
        60,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{rider.score}",
        sw / 2 - 150,
        sh / 2 - 38,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Clean gates: \{gates_clean} / \{gate_count}",
        sw / 2 - 220,
        sh / 2 + 20,
        34,
        @raylib.Color::new(170, 236, 198, 255),
      )
      @raylib.draw_text(
        "Missed gates: \{gates_miss}",
        sw / 2 - 180,
        sh / 2 + 62,
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
        "RUN FAILED",
        sw / 2 - 168,
        sh / 2 - 132,
        60,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{rider.score}",
        sw / 2 - 150,
        sh / 2 - 38,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Clean gates: \{gates_clean}",
        sw / 2 - 160,
        sh / 2 + 20,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Time left: \{time_left.to_int()}s",
        sw / 2 - 160,
        sh / 2 + 62,
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
        reset_game()
      }
    }
  }

  @raylib.close_window()
}
