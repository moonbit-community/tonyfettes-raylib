///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let ground_y : Float = 706.0

///|
let left_hoop_x : Float = 186.0

///|
let right_hoop_x : Float = 1094.0

///|
let rim_y : Float = 458.0

///|
let set_target : Int = 21

///|
let max_particles : Int = 520

///|
struct Athlete {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut on_ground : Bool
  mut energy : Float
  mut dash_t : Float
  mut shoot_cd : Float
  mut catch_cd : Float
  mut flash_t : Float
  mut score : Int
}

///|
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  r : Float
  mut spin : Float
  mut owner : Int
  mut shooter : Int
  mut shot_from_x : Float
  mut last_y : Float
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
fn clear_particles(ps : Array[Particle]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].ttl = 0.0
    ps[i].kind = 0
    ps[i].active = false
  }
}

///|
fn spawn_particle(ps : Array[Particle], x : Float, y : Float, speed : Float, kind : Int) -> Unit {
  let mut done = false
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
      ps[i].ttl = Float::from_int(@raylib.get_random_value(12, 62)) / Float::from_int(100)
      ps[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(ps : Array[Particle], x : Float, y : Float, n : Int, speed : Float, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn reset_athlete(a : Athlete, x : Float) -> Unit {
  a.x = x
  a.y = ground_y
  a.vx = 0.0
  a.vy = 0.0
  a.on_ground = true
  a.energy = 100.0
  a.dash_t = 0.0
  a.shoot_cd = 0.0
  a.catch_cd = 0.0
  a.flash_t = 0.0
}

///|
fn setup_possession(player : Athlete, rival : Athlete, ball : Ball, owner : Int) -> Unit {
  reset_athlete(player, 294.0)
  reset_athlete(rival, 986.0)

  ball.owner = owner
  ball.shooter = owner
  ball.active = false
  ball.vx = 0.0
  ball.vy = 0.0
  ball.spin = 0.0

  if owner == 1 {
    ball.x = player.x + 24.0
    ball.y = player.y - 56.0
  } else {
    ball.x = rival.x - 24.0
    ball.y = rival.y - 56.0
  }

  ball.last_y = ball.y
  ball.shot_from_x = ball.x
}

///|
fn tick_athlete(a : Athlete, dt : Float) -> Unit {
  if a.dash_t > 0.0 {
    a.dash_t = a.dash_t - dt
    if a.dash_t < 0.0 {
      a.dash_t = 0.0
    }
  }

  if a.shoot_cd > 0.0 {
    a.shoot_cd = a.shoot_cd - dt
    if a.shoot_cd < 0.0 {
      a.shoot_cd = 0.0
    }
  }

  if a.catch_cd > 0.0 {
    a.catch_cd = a.catch_cd - dt
    if a.catch_cd < 0.0 {
      a.catch_cd = 0.0
    }
  }

  if a.flash_t > 0.0 {
    a.flash_t = a.flash_t - dt
    if a.flash_t < 0.0 {
      a.flash_t = 0.0
    }
  }

  a.energy = a.energy + 20.0 * dt
  if a.energy > 100.0 {
    a.energy = 100.0
  }
}

///|
fn update_athlete_move(
  a : Athlete,
  dt : Float,
  move_left : Bool,
  move_right : Bool,
  jump : Bool,
  dash : Bool,
  min_x : Float,
  max_x : Float,
) -> Unit {
  if dash && a.dash_t <= 0.0 && a.energy >= 30.0 {
    a.dash_t = 0.22
    a.energy = a.energy - 30.0
    a.flash_t = 0.14
  }

  let accel : Float = if a.dash_t > 0.0 { 1480.0 } else { 1060.0 }
  let max_speed : Float = if a.dash_t > 0.0 { 430.0 } else { 304.0 }

  if move_left {
    a.vx = a.vx - accel * dt
  }
  if move_right {
    a.vx = a.vx + accel * dt
  }

  if not(move_left) && not(move_right) {
    a.vx = a.vx * (Float::from_int(1) - dt * 7.2)
  }

  a.vx = clampf(a.vx, -max_speed, max_speed)

  if jump && a.on_ground {
    a.vy = -560.0
    a.on_ground = false
  }

  a.vy = a.vy + 1040.0 * dt

  a.x = a.x + a.vx * dt
  a.y = a.y + a.vy * dt

  if a.y >= ground_y {
    a.y = ground_y
    if a.vy > 0.0 {
      a.vy = 0.0
    }
    a.on_ground = true
  } else {
    a.on_ground = false
  }

  if a.x < min_x {
    a.x = min_x
    if a.vx < 0.0 {
      a.vx = 0.0
    }
  }

  if a.x > max_x {
    a.x = max_x
    if a.vx > 0.0 {
      a.vx = 0.0
    }
  }
}

///|
fn release_shot(shooter : Athlete, team : Int, ball : Ball, target_x : Float, target_y : Float, boost : Float) -> Unit {
  ball.owner = 0
  ball.active = true
  ball.shooter = team
  ball.shot_from_x = ball.x

  let dx = target_x - ball.x
  let dy = target_y - ball.y
  let d2 = dx * dx + dy * dy
  let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

  let speed : Float = 690.0 + boost
  ball.vx = dx / d * speed + shooter.vx * 0.20
  ball.vy = dy / d * speed + shooter.vy * 0.12
  ball.spin = if team == 1 { 22.0 } else { -22.0 }
}

///|
fn resolve_rim_collision(ball : Ball, cx : Float, cy : Float) -> Unit {
  let rr = ball.r + 18.0
  let d2 = sqdist(ball.x, ball.y, cx, cy)
  if d2 <= rr * rr {
    let d : Float = if d2 < 0.001 { 1.0 } else { d2.sqrt() }
    let nx = (ball.x - cx) / d
    let ny = (ball.y - cy) / d

    ball.x = cx + nx * rr
    ball.y = cy + ny * rr

    let rel = ball.vx * nx + ball.vy * ny
    if rel < 0.0 {
      ball.vx = ball.vx - rel * nx * 1.84
      ball.vy = ball.vy - rel * ny * 1.84
      ball.vx = ball.vx * 0.86
      ball.vy = ball.vy * 0.86
      ball.spin = -ball.spin * 0.68
    }
  }
}

///|
fn draw_hoop(x : Float, side : Int) -> Unit {
  let board_x = if side == 1 { (x - 48.0).to_int() } else { (x + 40.0).to_int() }
  @raylib.draw_rectangle(board_x, 380, 12, 182, @raylib.Color::new(216, 228, 236, 255))

  let support_x = if side == 1 { (x - 42.0).to_int() } else { (x + 22.0).to_int() }
  @raylib.draw_rectangle(support_x, 448, 64, 8, @raylib.Color::new(228, 120, 84, 255))

  @raylib.draw_circle_lines(x.to_int(), rim_y.to_int(), 18.0, @raylib.Color::new(248, 146, 92, 255))

  for i = 0; i < 8; i = i + 1 {
    let dx = -16 + i * 4
    @raylib.draw_line((x + Float::from_int(dx)).to_int(), rim_y.to_int(), (x + Float::from_int(dx) * 0.6).to_int(), (rim_y + 42.0).to_int(), @raylib.Color::new(214, 222, 234, 220))
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Street Basketball Duel 2026")
  @raylib.set_target_fps(60)

  let player : Athlete = {
    x: 294.0,
    y: ground_y,
    vx: 0.0,
    vy: 0.0,
    on_ground: true,
    energy: 100.0,
    dash_t: 0.0,
    shoot_cd: 0.0,
    catch_cd: 0.0,
    flash_t: 0.0,
    score: 0,
  }

  let rival : Athlete = {
    x: 986.0,
    y: ground_y,
    vx: 0.0,
    vy: 0.0,
    on_ground: true,
    energy: 100.0,
    dash_t: 0.0,
    shoot_cd: 0.0,
    catch_cd: 0.0,
    flash_t: 0.0,
    score: 0,
  }

  let ball : Ball = {
    x: 320.0,
    y: 640.0,
    vx: 0.0,
    vy: 0.0,
    r: 16.0,
    spin: 0.0,
    owner: 1,
    shooter: 1,
    shot_from_x: 320.0,
    last_y: 640.0,
    active: false,
  }

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

  setup_possession(player, rival, ball, 1)

  let mut match_time : Float = 145.0
  let mut overtime_round = 0
  let mut rally_wait : Float = 0.9

  let mut stars = 0
  let mut crowd_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D move, W jump, J shoot/steal, K dash"

  let ctl_left_x = 16
  let ctl_left_y = sh - 178
  let ctl_right_x = 120
  let ctl_right_y = sh - 178
  let jump_x = sw - 334
  let jump_y = sh - 170
  let shoot_x = sw - 216
  let shoot_y = sh - 170
  let dash_x = sw - 100
  let dash_y = sh - 170

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    crowd_t = crowd_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      player.score = 0
      rival.score = 0
      setup_possession(player, rival, ball, 1)
      clear_particles(particles)
      match_time = 145.0
      overtime_round = 0
      rally_wait = 0.9
      stars = 0
      flash_t = 0.0
      shake_t = 0.0
      over = false
      won = false
      msg = "Tip-off reset"
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

    if not(over) {
      tick_athlete(player, dt)
      tick_athlete(rival, dt)

      if rally_wait > 0.0 {
        rally_wait = rally_wait - dt
        if rally_wait < 0.0 {
          rally_wait = 0.0
        }
      } else {
        match_time = match_time - dt
        if match_time <= 0.0 {
          match_time = 0.0
          if player.score == rival.score {
            overtime_round = overtime_round + 1
            match_time = 24.0
            msg = "Overtime \{overtime_round}"
            burst(particles, Float::from_int(sw / 2), 120.0, 18, 0.34, 2)
          } else {
            over = true
            won = player.score > rival.score
            msg = if won { "Game won" } else { "Game lost" }
          }
        }
      }

      let mut p_left = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
      let mut p_right = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
      let mut p_jump = @raylib.is_key_pressed(@raylib.KeyW) || @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeySpace)
      let mut p_action = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut p_dash = @raylib.is_key_pressed(@raylib.KeyK) || @raylib.is_key_pressed(@raylib.KeyLeftShift)

      let m = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_left_x, ctl_left_y, 92, 152) {
          p_left = true
        }
        if inside_rect(m.x, m.y, ctl_right_x, ctl_right_y, 92, 152) {
          p_right = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, jump_x, jump_y, 108, 152) {
          p_jump = true
        }
        if inside_rect(m.x, m.y, shoot_x, shoot_y, 108, 152) {
          p_action = true
        }
        if inside_rect(m.x, m.y, dash_x, dash_y, 92, 152) {
          p_dash = true
        }
      }

      update_athlete_move(player, dt, p_left, p_right, p_jump, p_dash, 70.0, Float::from_int(sw - 70))

      let mut ai_left = false
      let mut ai_right = false
      let mut ai_jump = false
      let mut ai_dash = false
      let mut ai_shoot = false

      if ball.owner == 2 {
        let target_x : Float = 828.0
        if rival.x > target_x + 18.0 {
          ai_left = true
        } else if rival.x < target_x - 18.0 {
          ai_right = true
        }

        if rival.shoot_cd <= 0.0 && rally_wait <= 0.0 {
          let ready = absf(rival.x - target_x) < 46.0 || match_time < 14.0
          if ready {
            ai_shoot = true
          }
        }
      } else if ball.owner == 1 {
        let defend_x : Float = 904.0
        if rival.x > defend_x + 12.0 {
          ai_left = true
        } else if rival.x < defend_x - 12.0 {
          ai_right = true
        }

        if absf(player.x - rival.x) > 240.0 && rival.energy > 38.0 {
          ai_dash = true
        }
      } else {
        let mut target_x = ball.x
        if target_x < 90.0 {
          target_x = 90.0
        }
        if target_x > Float::from_int(sw - 90) {
          target_x = Float::from_int(sw - 90)
        }

        if rival.x > target_x + 12.0 {
          ai_left = true
        } else if rival.x < target_x - 12.0 {
          ai_right = true
        }

        if ball.y < rival.y - 92.0 && absf(ball.x - rival.x) < 84.0 {
          ai_jump = true
        }

        if absf(rival.x - target_x) > 220.0 && rival.energy > 42.0 {
          ai_dash = true
        }
      }

      update_athlete_move(rival, dt, ai_left, ai_right, ai_jump, ai_dash, 70.0, Float::from_int(sw - 70))

      if ball.owner == 1 {
        ball.x = player.x + 24.0
        ball.y = player.y - 56.0
        ball.last_y = ball.y

        if p_action && player.shoot_cd <= 0.0 && rally_wait <= 0.0 {
          let tx = right_hoop_x + Float::from_int(@raylib.get_random_value(-12, 12))
          let ty = rim_y - Float::from_int(@raylib.get_random_value(96, 186))
          let boost : Float = if player.dash_t > 0.0 { 130.0 } else { 0.0 }
          release_shot(player, 1, ball, tx, ty, boost)
          player.shoot_cd = 0.34
          player.catch_cd = 0.26
          msg = "Player shot"
          burst(particles, ball.x, ball.y, 12, 0.34, 1)
        }
      } else if ball.owner == 2 {
        ball.x = rival.x - 24.0
        ball.y = rival.y - 56.0
        ball.last_y = ball.y

        if ai_shoot && rival.shoot_cd <= 0.0 && rally_wait <= 0.0 {
          let tx = left_hoop_x + Float::from_int(@raylib.get_random_value(-12, 12))
          let ty = rim_y - Float::from_int(@raylib.get_random_value(96, 186))
          let boost : Float = if rival.dash_t > 0.0 { 120.0 } else { 0.0 }
          release_shot(rival, 2, ball, tx, ty, boost)
          rival.shoot_cd = 0.40
          rival.catch_cd = 0.28
          msg = "Rival shot"
          burst(particles, ball.x, ball.y, 12, 0.34, 2)
        }
      } else {
        ball.last_y = ball.y

        ball.vy = ball.vy + 1060.0 * dt
        ball.vx = ball.vx + ball.spin * dt * 2.3
        ball.spin = ball.spin * (Float::from_int(1) - dt * 0.9)

        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt

        if ball.x < ball.r {
          ball.x = ball.r
          ball.vx = absf(ball.vx) * 0.82
          ball.spin = -ball.spin * 0.70
          burst(particles, ball.x, ball.y, 8, 0.22, 0)
        }

        if ball.x > Float::from_int(sw) - ball.r {
          ball.x = Float::from_int(sw) - ball.r
          ball.vx = -absf(ball.vx) * 0.82
          ball.spin = -ball.spin * 0.70
          burst(particles, ball.x, ball.y, 8, 0.22, 0)
        }

        if ball.y + ball.r >= ground_y {
          ball.y = ground_y - ball.r
          if absf(ball.vy) > 90.0 {
            ball.vy = -absf(ball.vy) * 0.72
          } else {
            ball.vy = 0.0
          }
          ball.vx = ball.vx * 0.92
          ball.spin = ball.spin * 0.82
          burst(particles, ball.x, ground_y, 6, 0.18, 0)
        }

        if ball.x - ball.r < 148.0 && ball.x + ball.r > 136.0 && ball.y + ball.r > 380.0 && ball.y - ball.r < 562.0 {
          if ball.vx < 0.0 {
            ball.x = 148.0 + ball.r
            ball.vx = absf(ball.vx) * 0.74
            ball.spin = -ball.spin * 0.72
            burst(particles, ball.x, ball.y, 9, 0.24, 2)
          }
        }

        if ball.x + ball.r > 1132.0 && ball.x - ball.r < 1144.0 && ball.y + ball.r > 380.0 && ball.y - ball.r < 562.0 {
          if ball.vx > 0.0 {
            ball.x = 1132.0 - ball.r
            ball.vx = -absf(ball.vx) * 0.74
            ball.spin = -ball.spin * 0.72
            burst(particles, ball.x, ball.y, 9, 0.24, 2)
          }
        }

        resolve_rim_collision(ball, left_hoop_x, rim_y)
        resolve_rim_collision(ball, right_hoop_x, rim_y)

        let mut scored = false

        if ball.last_y < rim_y - 4.0 && ball.y >= rim_y && absf(ball.x - right_hoop_x) <= 12.0 && ball.vy > 0.0 {
          let mut points = if absf(ball.shot_from_x - right_hoop_x) > 430.0 { 3 } else { 2 }
          if ball.shooter == 2 {
            points = 2
          }
          player.score = player.score + points
          stars = stars + points
          msg = "Player +\{points}"
          burst(particles, right_hoop_x, rim_y, 26, 0.52, 1)
          flash_t = 0.20
          shake_t = 0.16
          setup_possession(player, rival, ball, 2)
          rally_wait = 1.0
          scored = true
        }

        if not(scored) && ball.last_y < rim_y - 4.0 && ball.y >= rim_y && absf(ball.x - left_hoop_x) <= 12.0 && ball.vy > 0.0 {
          let mut points = if absf(ball.shot_from_x - left_hoop_x) > 430.0 { 3 } else { 2 }
          if ball.shooter == 1 {
            points = 2
          }
          rival.score = rival.score + points
          msg = "Rival +\{points}"
          burst(particles, left_hoop_x, rim_y, 26, 0.52, 0)
          flash_t = 0.20
          shake_t = 0.16
          setup_possession(player, rival, ball, 1)
          rally_wait = 1.0
          scored = true
        }

        if not(scored) {
          let player_hand_x = player.x + 18.0
          let player_hand_y = player.y - 46.0
          let rival_hand_x = rival.x - 18.0
          let rival_hand_y = rival.y - 46.0

          let player_near = player.catch_cd <= 0.0 && sqdist(player_hand_x, player_hand_y, ball.x, ball.y) <= 46.0 * 46.0
          let rival_near = rival.catch_cd <= 0.0 && sqdist(rival_hand_x, rival_hand_y, ball.x, ball.y) <= 46.0 * 46.0

          if player_near && rival_near {
            let pd = sqdist(player_hand_x, player_hand_y, ball.x, ball.y)
            let rd = sqdist(rival_hand_x, rival_hand_y, ball.x, ball.y)
            if pd <= rd {
              ball.owner = 1
            } else {
              ball.owner = 2
            }
          } else if player_near {
            ball.owner = 1
          } else if rival_near {
            ball.owner = 2
          }

          if ball.owner != 0 {
            ball.active = false
            ball.vx = 0.0
            ball.vy = 0.0
            ball.spin = 0.0

            if ball.owner == 1 {
              player.catch_cd = 0.24
              rival.catch_cd = 0.12
              msg = "Player rebound"
              burst(particles, ball.x, ball.y, 10, 0.26, 3)
            } else {
              rival.catch_cd = 0.24
              player.catch_cd = 0.12
              msg = "Rival rebound"
              burst(particles, ball.x, ball.y, 10, 0.26, 2)
            }
          }
        }
      }

      if p_action && ball.owner == 2 && player.catch_cd <= 0.0 {
        if sqdist(player.x + 10.0, player.y - 40.0, rival.x - 14.0, rival.y - 40.0) <= 68.0 * 68.0 {
          let chance = @raylib.get_random_value(0, 100)
          if chance < 46 {
            ball.owner = 1
            ball.active = false
            ball.vx = 0.0
            ball.vy = 0.0
            player.catch_cd = 0.34
            rival.catch_cd = 0.26
            msg = "Steal!"
            burst(particles, player.x, player.y - 30.0, 18, 0.38, 3)
          }
        }
      }

      if player.score >= set_target || rival.score >= set_target {
        let diff = player.score - rival.score
        let gap = if diff < 0 { -diff } else { diff }
        if gap >= 2 {
          over = true
          won = player.score > rival.score
          msg = if won { "Target reached" } else { "Rival reached target" }
        }
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(30, 18, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 12, 24, 255))
    }

    let pulse = (crowd_t * 3.0).to_int() % 180
    let glow = if pulse < 90 { pulse } else { 180 - pulse }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 18 + glow / 10, 34 + glow / 4, 255))
    @raylib.draw_rectangle(0, 0, sw, 280, @raylib.Color::new(18, 30 + glow / 8, 62 + glow / 4, 255))

    for i = 0; i < 84; i = i + 1 {
      let x = ((i * 104 + (crowd_t * 68.0).to_int()) % (sw + 180)) - 90
      let h = 120 + (i * 47 % 300)
      let w = 42 + (i * 11 % 70)
      let c = 24 + (i * 13 % 56)
      @raylib.draw_rectangle(x, sh - h, w, h, @raylib.Color::new(c, c + 8, c + 30, 255))
      if i % 2 == 0 {
        @raylib.draw_rectangle(x + 10, sh - h + 28, 8, h - 36, @raylib.Color::new(92, 214, 248, 194))
      }
      if i % 3 == 0 {
        @raylib.draw_rectangle(x + 26, sh - h + 42, 8, h - 52, @raylib.Color::new(248, 144, 226, 188))
      }
    }

    @raylib.draw_rectangle(0, 604, sw, sh - 604, @raylib.Color::new(70, 74, 82, 255))
    @raylib.draw_rectangle(0, 606, sw, 50, @raylib.Color::new(94, 98, 110, 255))

    for i = 0; i < 34; i = i + 1 {
      let x = (i * 46 + (crowd_t * 120.0).to_int()) % (sw + 100) - 50
      @raylib.draw_line(x, 608, x + 20, 654, @raylib.Color::new(120, 122, 132, 255))
    }

    @raylib.draw_line(0, 606, sw, 606, @raylib.Color::new(242, 242, 244, 255))
    @raylib.draw_line(sw / 2, 606, sw / 2, sh, @raylib.Color::new(236, 236, 238, 255))

    @raylib.draw_circle_lines(sw / 2, 666, 92.0, @raylib.Color::new(232, 232, 236, 255))
    @raylib.draw_circle_lines(sw / 2, 666, 42.0, @raylib.Color::new(232, 232, 236, 255))

    @raylib.draw_rectangle(84, 606, 180, 152, @raylib.Color::new(120, 106, 92, 68))
    @raylib.draw_rectangle(sw - 264, 606, 180, 152, @raylib.Color::new(120, 106, 92, 68))

    draw_hoop(left_hoop_x + shake_x, 1)
    draw_hoop(right_hoop_x + shake_x, 2)

    let p_col = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 236, 148, 255)
    } else {
      @raylib.Color::new(94, 214, 248, 255)
    }

    let r_col = if rival.flash_t > 0.0 {
      @raylib.Color::new(252, 236, 148, 255)
    } else {
      @raylib.Color::new(248, 120, 214, 255)
    }

    let px = (player.x + shake_x).to_int()
    let py = player.y.to_int()

    @raylib.draw_circle(px, py - 62, 14.0, @raylib.Color::new(236, 242, 248, 255))
    @raylib.draw_rectangle(px - 16, py - 48, 32, 36, p_col)
    @raylib.draw_line(px - 12, py - 38, px - 26 + (player.vx * 0.03).to_int(), py - 22, p_col)
    @raylib.draw_line(px + 12, py - 38, px + 26 + (player.vx * 0.03).to_int(), py - 22, p_col)
    @raylib.draw_line(px - 10, py - 12, px - 16, py + 20, p_col)
    @raylib.draw_line(px + 10, py - 12, px + 16, py + 20, p_col)

    if player.dash_t > 0.0 {
      @raylib.draw_line(px - 40, py - 54, px - 12, py - 54, @raylib.Color::new(246, 226, 126, 255))
      @raylib.draw_line(px - 48, py - 42, px - 20, py - 42, @raylib.Color::new(246, 226, 126, 255))
      @raylib.draw_line(px - 40, py - 30, px - 12, py - 30, @raylib.Color::new(246, 226, 126, 255))
    }

    let rx = (rival.x + shake_x).to_int()
    let ry = rival.y.to_int()

    @raylib.draw_circle(rx, ry - 62, 14.0, @raylib.Color::new(236, 242, 248, 255))
    @raylib.draw_rectangle(rx - 16, ry - 48, 32, 36, r_col)
    @raylib.draw_line(rx - 12, ry - 38, rx - 26 + (rival.vx * 0.03).to_int(), ry - 22, r_col)
    @raylib.draw_line(rx + 12, ry - 38, rx + 26 + (rival.vx * 0.03).to_int(), ry - 22, r_col)
    @raylib.draw_line(rx - 10, ry - 12, rx - 16, ry + 20, r_col)
    @raylib.draw_line(rx + 10, ry - 12, rx + 16, ry + 20, r_col)

    if rival.dash_t > 0.0 {
      @raylib.draw_line(rx + 40, ry - 54, rx + 12, ry - 54, @raylib.Color::new(246, 226, 126, 255))
      @raylib.draw_line(rx + 48, ry - 42, rx + 20, ry - 42, @raylib.Color::new(246, 226, 126, 255))
      @raylib.draw_line(rx + 40, ry - 30, rx + 12, ry - 30, @raylib.Color::new(246, 226, 126, 255))
    }

    let ball_x = (ball.x + shake_x).to_int()
    let ball_y = ball.y.to_int()

    @raylib.draw_circle(ball_x, ball_y, ball.r, @raylib.Color::new(244, 170, 94, 255))
    @raylib.draw_circle(ball_x - 3, ball_y - 3, ball.r * 0.45, @raylib.Color::new(254, 212, 148, 255))
    if ball.active {
      @raylib.draw_circle_lines(ball_x, ball_y, ball.r + 4.0, @raylib.Color::new(252, 236, 162, 190))
    }
    @raylib.draw_line(ball_x - ball.r.to_int(), ball_y, ball_x + ball.r.to_int(), ball_y, @raylib.Color::new(164, 88, 52, 255))
    @raylib.draw_line(ball_x, ball_y - ball.r.to_int(), ball_x, ball_y + ball.r.to_int(), @raylib.Color::new(164, 88, 52, 255))

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let c = if particles[i].kind == 0 {
        @raylib.Color::new(254, 126, 126, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 130, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(238, 156, 254, 255)
      } else {
        @raylib.Color::new(118, 226, 246, 255)
      }
      @raylib.draw_circle((particles[i].x + shake_x).to_int(), particles[i].y.to_int(), 2.0, c)
    }

    @raylib.draw_rectangle(0, 0, sw, 118, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text("STREET BASKETBALL DUEL 2026", 16, 16, 34, @raylib.Color::new(236, 246, 255, 255))

    @raylib.draw_text("Player \{player.score}", 446, 22, 36, @raylib.Color::new(104, 224, 250, 255))
    @raylib.draw_text("Rival \{rival.score}", 744, 22, 36, @raylib.Color::new(250, 132, 222, 255))
    @raylib.draw_text("Target \{set_target}", 572, 72, 24, @raylib.Color::new(238, 236, 172, 255))

    @raylib.draw_text("Time \{match_time.to_int()}", 892, 72, 30, @raylib.Color::new(252, 222, 150, 255))
    @raylib.draw_text("Stars \{stars}", 1090, 72, 30, @raylib.Color::new(252, 230, 132, 255))

    @raylib.draw_text("P-Energy \{player.energy.to_int()}%", 20, 78, 24, @raylib.Color::new(216, 236, 252, 255))
    @raylib.draw_text("R-Energy \{rival.energy.to_int()}%", 250, 78, 24, @raylib.Color::new(216, 236, 252, 255))

    @raylib.draw_rectangle(20, 106, 190, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(20, 106, (player.energy / 100.0 * 190.0).to_int(), 8, @raylib.Color::new(98, 202, 246, 255))
    @raylib.draw_rectangle(250, 106, 190, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(250, 106, (rival.energy / 100.0 * 190.0).to_int(), 8, @raylib.Color::new(238, 130, 214, 255))

    @raylib.draw_rectangle(16, sh - 182, 202, 172, @raylib.Color::new(8, 14, 28, 220))
    @raylib.draw_text("Touch", 78, sh - 174, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_left_x, ctl_left_y, 92, 152, @raylib.Color::new(52, 72, 100, 255))
    @raylib.draw_text("LEFT", ctl_left_x + 18, ctl_left_y + 62, 28, @raylib.white)
    @raylib.draw_rectangle(ctl_right_x, ctl_right_y, 92, 152, @raylib.Color::new(52, 72, 100, 255))
    @raylib.draw_text("RIGHT", ctl_right_x + 10, ctl_right_y + 62, 28, @raylib.white)

    @raylib.draw_rectangle(jump_x, jump_y, 108, 152, @raylib.Color::new(72, 154, 220, 255))
    @raylib.draw_text("JUMP", jump_x + 16, jump_y + 58, 30, @raylib.white)
    @raylib.draw_rectangle(shoot_x, shoot_y, 108, 152, @raylib.Color::new(214, 110, 82, 255))
    @raylib.draw_text("SHOOT", shoot_x + 8, shoot_y + 58, 30, @raylib.white)
    @raylib.draw_rectangle(dash_x, dash_y, 92, 152, @raylib.Color::new(96, 188, 124, 255))
    @raylib.draw_text("DASH", dash_x + 8, dash_y + 58, 26, @raylib.white)

    @raylib.draw_rectangle(224, sh - 54, sw - 448, 38, @raylib.Color::new(6, 10, 18, 220))
    @raylib.draw_text(msg, 236, sh - 46, 24, @raylib.Color::new(224, 236, 248, 255))

    if rally_wait > 0.0 && not(over) {
      let c = rally_wait.to_int() + 1
      @raylib.draw_text("Inbound in \{c}", sw / 2 - 100, sh / 2 - 30, 36, @raylib.Color::new(252, 236, 148, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(sw / 2 - 360, sh / 2 - 112, 720, 224, @raylib.Color::new(16, 24, 42, 244))
      @raylib.draw_text(
        if won { "VICTORY" } else { "DEFEAT" },
        sw / 2 - 168,
        sh / 2 - 34,
        72,
        if won { @raylib.Color::new(252, 238, 148, 255) } else { @raylib.Color::new(252, 140, 140, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 46, 34, @raylib.Color::new(224, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
