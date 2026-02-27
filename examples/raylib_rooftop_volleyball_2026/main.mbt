///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let ground_y : Float = 700.0

///|
let net_x : Int = 640

///|
let net_h : Int = 172

///|
let set_points : Int = 11

///|
let max_particles : Int = 460

///|
struct Athlete {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut on_ground : Bool
  mut energy : Float
  mut hit_cd : Float
  mut jump_cd : Float
  mut dash_t : Float
  mut flash_t : Float
  mut score : Int
  mut sets : Int
}

///|
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  r : Float
  mut spin : Float
  mut active : Bool
  mut touch_owner : Int
  mut serve_owner : Int
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
struct Wind {
  mut dir : Float
  mut strength : Float
  mut ttl : Float
  mut cd : Float
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
fn spawn_particle(
  ps : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }

    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      ps[i].vx = Float::from_int(@raylib.get_random_value(-240, 240)) * speed
      ps[i].vy = Float::from_int(@raylib.get_random_value(-240, 240)) * speed
      ps[i].ttl = Float::from_int(@raylib.get_random_value(12, 60)) /
        Float::from_int(100)
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
  n : Int,
  speed : Float,
  kind : Int,
) -> Unit {
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
  a.hit_cd = 0.0
  a.jump_cd = 0.0
  a.dash_t = 0.0
  a.flash_t = 0.0
}

///|
fn setup_rally(
  player : Athlete,
  bot : Athlete,
  ball : Ball,
  serve_owner : Int,
) -> Unit {
  reset_athlete(player, 284.0)
  reset_athlete(bot, 996.0)

  ball.active = false
  ball.serve_owner = serve_owner
  ball.touch_owner = 0
  ball.spin = 0.0
  ball.vx = 0.0
  ball.vy = 0.0

  if serve_owner == 1 {
    ball.x = player.x + 34.0
    ball.y = player.y - 86.0
  } else {
    ball.x = bot.x - 34.0
    ball.y = bot.y - 86.0
  }
}

///|
fn setup_match(
  player : Athlete,
  bot : Athlete,
  ball : Ball,
  wind : Wind,
  ps : Array[Particle],
) -> Unit {
  player.score = 0
  player.sets = 0
  bot.score = 0
  bot.sets = 0

  setup_rally(player, bot, ball, 1)

  wind.dir = 1.0
  wind.strength = 0.0
  wind.ttl = 0.0
  wind.cd = 4.0

  clear_particles(ps)
}

///|
fn tick_athlete(a : Athlete, dt : Float) -> Unit {
  if a.hit_cd > 0.0 {
    a.hit_cd = a.hit_cd - dt
    if a.hit_cd < 0.0 {
      a.hit_cd = 0.0
    }
  }

  if a.jump_cd > 0.0 {
    a.jump_cd = a.jump_cd - dt
    if a.jump_cd < 0.0 {
      a.jump_cd = 0.0
    }
  }

  if a.dash_t > 0.0 {
    a.dash_t = a.dash_t - dt
    if a.dash_t < 0.0 {
      a.dash_t = 0.0
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
fn update_athlete_movement(
  a : Athlete,
  dt : Float,
  move_left : Bool,
  move_right : Bool,
  jump_pressed : Bool,
  dash_pressed : Bool,
  min_x : Float,
  max_x : Float,
) -> Unit {
  if dash_pressed && a.dash_t <= 0.0 && a.energy >= 32.0 {
    a.dash_t = 0.22
    a.energy = a.energy - 32.0
    a.flash_t = 0.16
  }

  let accel : Float = if a.dash_t > 0.0 { 1450.0 } else { 1060.0 }
  let max_speed : Float = if a.dash_t > 0.0 { 430.0 } else { 298.0 }

  if move_left {
    a.vx = a.vx - accel * dt
  }
  if move_right {
    a.vx = a.vx + accel * dt
  }

  if not(move_left) && not(move_right) {
    a.vx = a.vx * (Float::from_int(1) - dt * 7.6)
  }

  a.vx = clampf(a.vx, -max_speed, max_speed)

  if jump_pressed && a.on_ground && a.jump_cd <= 0.0 {
    a.vy = -536.0
    a.on_ground = false
    a.jump_cd = 0.16
  }

  a.vy = a.vy + 980.0 * dt

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
fn attempt_hit_ball(
  a : Athlete,
  ball : Ball,
  owner : Int,
  ps : Array[Particle],
) -> Bool {
  if a.hit_cd > 0.0 {
    return false
  }

  let hand_x = if owner == 1 { a.x + 24.0 } else { a.x - 24.0 }
  let hand_y = a.y - 36.0

  if sqdist(hand_x, hand_y, ball.x, ball.y) > 88.0 * 88.0 {
    return false
  }

  let target_x : Float = if owner == 1 {
    Float::from_int(@raylib.get_random_value(net_x + 90, sw - 66))
  } else {
    Float::from_int(@raylib.get_random_value(66, net_x - 90))
  }

  let mut target_y : Float = -Float::from_int(
    @raylib.get_random_value(240, 420),
  )

  // Air-time contact allows a downward spike toward the opposite floor.
  if not(a.on_ground) && ball.y > a.y - 20.0 {
    target_y = Float::from_int(@raylib.get_random_value(120, 280))
  }

  let dx = target_x - ball.x
  let dy = target_y
  let d2 = dx * dx + dy * dy
  let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

  let base_speed : Float = if a.dash_t > 0.0 { 790.0 } else { 680.0 }

  ball.vx = dx / d * base_speed + a.vx * 0.30
  ball.vy = dy / d * base_speed + a.vy * 0.18
  ball.spin = ball.spin +
    (if owner == 1 { 1.0 } else { -1.0 }) *
    Float::from_int(@raylib.get_random_value(16, 44))
  ball.touch_owner = owner

  a.hit_cd = 0.22
  a.energy = a.energy - 14.0
  if a.energy < 0.0 {
    a.energy = 0.0
  }

  burst(ps, hand_x, hand_y, 13, 0.35, if owner == 1 { 1 } else { 2 })
  true
}

///|
fn spawn_wind(wind : Wind, set_no : Int) -> Unit {
  wind.dir = if @raylib.get_random_value(0, 1) == 0 { -1.0 } else { 1.0 }
  wind.strength = Float::from_int(
    @raylib.get_random_value(36 + set_no * 8, 86 + set_no * 11),
  )
  wind.ttl = Float::from_int(@raylib.get_random_value(180, 420)) /
    Float::from_int(100)
  wind.cd = Float::from_int(@raylib.get_random_value(560, 980)) /
    Float::from_int(100)
}

///|
fn update_wind(wind : Wind, dt : Float, set_no : Int) -> Unit {
  if wind.ttl > 0.0 {
    wind.ttl = wind.ttl - dt
    if wind.ttl < 0.0 {
      wind.ttl = 0.0
    }
  } else {
    wind.cd = wind.cd - dt
    if wind.cd <= 0.0 {
      spawn_wind(wind, set_no)
    }
  }
}

///|
fn set_no(player : Athlete, bot : Athlete) -> Int {
  player.sets + bot.sets + 1
}

///|
fn resolve_point(
  winner : Int,
  player : Athlete,
  bot : Athlete,
  ball : Ball,
  ps : Array[Particle],
  round_msg : Ref[String],
  rally_wait : Ref[Float],
  over : Ref[Bool],
  won : Ref[Bool],
) -> Unit {
  if winner == 1 {
    player.score = player.score + 1
    round_msg.val = "Point to Player"
    burst(ps, Float::from_int(net_x + 260), 124.0, 20, 0.44, 3)
  } else {
    bot.score = bot.score + 1
    round_msg.val = "Point to Rival"
    burst(ps, Float::from_int(net_x - 260), 124.0, 20, 0.44, 0)
  }

  let score_diff = player.score - bot.score
  let score_gap = if score_diff < 0 { -score_diff } else { score_diff }
  let mut set_closed = false
  let mut set_winner = 0

  if (player.score >= set_points || bot.score >= set_points) && score_gap >= 2 {
    set_closed = true
    if player.score > bot.score {
      player.sets = player.sets + 1
      set_winner = 1
      round_msg.val = "Set won by Player"
      burst(ps, 360.0, 200.0, 32, 0.55, 1)
    } else {
      bot.sets = bot.sets + 1
      set_winner = 2
      round_msg.val = "Set won by Rival"
      burst(ps, 920.0, 200.0, 32, 0.55, 2)
    }

    player.score = 0
    bot.score = 0
  }

  if player.sets >= 2 {
    over.val = true
    won.val = true
    round_msg.val = "Championship won"
  }

  if bot.sets >= 2 {
    over.val = true
    won.val = false
    round_msg.val = "Rival takes championship"
  }

  let next_server = if set_closed { set_winner } else { winner }
  setup_rally(player, bot, ball, next_server)
  rally_wait.val = if set_closed { 1.5 } else { 1.0 }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Rooftop Volleyball 2026")
  @raylib.set_target_fps(60)

  let player : Athlete = {
    x: 284.0,
    y: ground_y,
    vx: 0.0,
    vy: 0.0,
    on_ground: true,
    energy: 100.0,
    hit_cd: 0.0,
    jump_cd: 0.0,
    dash_t: 0.0,
    flash_t: 0.0,
    score: 0,
    sets: 0,
  }

  let bot : Athlete = {
    x: 996.0,
    y: ground_y,
    vx: 0.0,
    vy: 0.0,
    on_ground: true,
    energy: 100.0,
    hit_cd: 0.0,
    jump_cd: 0.0,
    dash_t: 0.0,
    flash_t: 0.0,
    score: 0,
    sets: 0,
  }

  let ball : Ball = {
    x: 318.0,
    y: 612.0,
    vx: 0.0,
    vy: 0.0,
    r: 16.0,
    spin: 0.0,
    active: false,
    touch_owner: 0,
    serve_owner: 1,
  }

  let wind : Wind = { dir: 1.0, strength: 0.0, ttl: 0.0, cd: 4.0 }

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, kind: 0, active: false }
  })

  setup_match(player, bot, ball, wind, particles)

  let mut rally_wait : Float = 1.2
  let mut crowd_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0
  let mut stars = 0

  let mut over = false
  let mut won = false
  let mut round_msg = "A/D move, W jump, J hit, K dash"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    crowd_t = crowd_t + dt

    let move_left_x = 16
    let move_left_y = sh - 178
    let move_right_x = 120
    let move_right_y = sh - 178
    let jump_x = sw - 334
    let jump_y = sh - 170
    let hit_x = sw - 216
    let hit_y = sh - 170
    let dash_x = sw - 100
    let dash_y = sh - 170

    if @raylib.is_key_pressed(@raylib.KeyR) {
      setup_match(player, bot, ball, wind, particles)
      rally_wait = 1.2
      flash_t = 0.0
      shake_t = 0.0
      stars = 0
      over = false
      won = false
      round_msg = "Match reset"
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
      particles[i].vy = particles[i].vy + 280.0 * dt
      particles[i].ttl = particles[i].ttl - dt

      if particles[i].ttl <= 0.0 {
        particles[i].active = false
      }
    }

    if not(over) {
      if rally_wait > 0.0 {
        rally_wait = rally_wait - dt
        if rally_wait < 0.0 {
          rally_wait = 0.0
        }
      }

      tick_athlete(player, dt)
      tick_athlete(bot, dt)

      update_wind(wind, dt, set_no(player, bot))

      let mut p_left = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut p_right = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut p_jump = @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut p_hit = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut p_dash = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyLeftShift)

      let mouse = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(mouse.x, mouse.y, move_left_x, move_left_y, 92, 152) {
          p_left = true
        }
        if inside_rect(mouse.x, mouse.y, move_right_x, move_right_y, 92, 152) {
          p_right = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(mouse.x, mouse.y, jump_x, jump_y, 108, 152) {
          p_jump = true
        }
        if inside_rect(mouse.x, mouse.y, hit_x, hit_y, 108, 152) {
          p_hit = true
        }
        if inside_rect(mouse.x, mouse.y, dash_x, dash_y, 92, 152) {
          p_dash = true
        }
      }

      update_athlete_movement(
        player,
        dt,
        p_left,
        p_right,
        p_jump,
        p_dash,
        70.0,
        Float::from_int(net_x - 36),
      )

      let mut bot_target : Float = 930.0
      if ball.active {
        if ball.x >= Float::from_int(net_x - 32) || ball.vx > 0.0 {
          let fall_t = clampf(
            (ground_y - ball.y) / clampf(absf(ball.vy) + 220.0, 220.0, 1400.0),
            0.0,
            1.7,
          )
          bot_target = ball.x + ball.vx * fall_t
          bot_target = clampf(
            bot_target,
            Float::from_int(net_x + 36),
            Float::from_int(sw - 70),
          )
        }
      } else if ball.serve_owner == 2 {
        bot_target = 1020.0
      }

      let b_left = bot.x > bot_target + 12.0
      let b_right = bot.x < bot_target - 12.0
      let mut b_jump = false
      let mut b_dash = false
      let mut b_hit = false

      if ball.active {
        let near_ball = absf(ball.x - bot.x) < 120.0
        if near_ball && ball.y < bot.y - 28.0 && ball.vy > -260.0 {
          b_jump = true
        }

        if absf(bot.x - bot_target) > 180.0 &&
          bot.dash_t <= 0.0 &&
          bot.energy >= 34.0 {
          b_dash = true
        }

        if sqdist(bot.x - 20.0, bot.y - 36.0, ball.x, ball.y) <= 90.0 * 90.0 {
          b_hit = true
        }
      }

      update_athlete_movement(
        bot,
        dt,
        b_left,
        b_right,
        b_jump,
        b_dash,
        Float::from_int(net_x + 36),
        Float::from_int(sw - 70),
      )

      if ball.active {
        if p_hit {
          ignore(attempt_hit_ball(player, ball, 1, particles))
        }

        if b_hit {
          ignore(attempt_hit_ball(bot, ball, 2, particles))
        }
      }

      if not(ball.active) && rally_wait <= 0.0 {
        if ball.serve_owner == 1 {
          if p_hit || p_jump {
            ball.active = true
            ball.touch_owner = 1
            ball.x = player.x + 32.0
            ball.y = player.y - 86.0
            ball.vx = Float::from_int(@raylib.get_random_value(420, 520))
            ball.vy = -Float::from_int(@raylib.get_random_value(420, 560))
            ball.spin = Float::from_int(@raylib.get_random_value(16, 38))
            round_msg = "Player serve"
            burst(particles, ball.x, ball.y, 10, 0.32, 1)
          }
        } else {
          ball.active = true
          ball.touch_owner = 2
          ball.x = bot.x - 32.0
          ball.y = bot.y - 86.0
          ball.vx = -Float::from_int(@raylib.get_random_value(420, 520))
          ball.vy = -Float::from_int(@raylib.get_random_value(420, 560))
          ball.spin = -Float::from_int(@raylib.get_random_value(16, 38))
          round_msg = "Rival serve"
          burst(particles, ball.x, ball.y, 10, 0.32, 2)
        }
      }

      if ball.active {
        if wind.ttl > 0.0 {
          ball.vx = ball.vx + wind.dir * wind.strength * dt
        }

        ball.vx = ball.vx + ball.spin * dt * 2.4
        ball.spin = ball.spin * (Float::from_int(1) - dt * 1.1)

        ball.vy = ball.vy + 980.0 * dt
        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt

        if ball.x < ball.r {
          ball.x = ball.r
          ball.vx = absf(ball.vx) * 0.85
          ball.spin = -ball.spin * 0.65
          burst(particles, ball.x, ball.y, 8, 0.25, 0)
        }

        if ball.x > Float::from_int(sw) - ball.r {
          ball.x = Float::from_int(sw) - ball.r
          ball.vx = -absf(ball.vx) * 0.85
          ball.spin = -ball.spin * 0.65
          burst(particles, ball.x, ball.y, 8, 0.25, 0)
        }

        if ball.y < 42.0 {
          ball.y = 42.0
          ball.vy = absf(ball.vy) * 0.78
          burst(particles, ball.x, ball.y, 8, 0.20, 3)
        }

        let net_left : Float = Float::from_int(net_x) - 11.0
        let net_right : Float = Float::from_int(net_x) + 11.0
        let net_top : Float = ground_y - Float::from_int(net_h)

        if ball.x + ball.r >= net_left &&
          ball.x - ball.r <= net_right &&
          ball.y + ball.r >= net_top &&
          ball.y - ball.r <= ground_y {
          if ball.y < net_top + 16.0 {
            ball.y = net_top - ball.r
            ball.vy = -absf(ball.vy) * 0.76
          } else if ball.x < Float::from_int(net_x) {
            ball.x = net_left - ball.r
            ball.vx = -absf(ball.vx) * 0.74
          } else {
            ball.x = net_right + ball.r
            ball.vx = absf(ball.vx) * 0.74
          }
          ball.spin = -ball.spin * 0.45
          burst(particles, ball.x, ball.y, 14, 0.30, 2)
        }

        if ball.y + ball.r >= ground_y {
          ball.y = ground_y - ball.r
          ball.active = false

          let winner = if ball.x < Float::from_int(net_x) { 2 } else { 1 }

          let msg_ref : Ref[String] = { val: round_msg }
          let rally_ref : Ref[Float] = { val: rally_wait }
          let over_ref : Ref[Bool] = { val: over }
          let won_ref : Ref[Bool] = { val: won }

          resolve_point(
            winner, player, bot, ball, particles, msg_ref, rally_ref, over_ref, won_ref,
          )

          round_msg = msg_ref.val
          rally_wait = rally_ref.val
          over = over_ref.val
          won = won_ref.val

          flash_t = 0.24
          shake_t = 0.16
          if winner == 1 {
            stars = stars + 2
          }
        }
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-4, 4))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(28, 18, 30, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 28, 255))
    }

    let pulse = (crowd_t * 3.0).to_int() % 160
    let glow = if pulse < 80 { pulse } else { 160 - pulse }

    @raylib.draw_rectangle(
      0,
      0,
      sw,
      sh,
      @raylib.Color::new(14, 20 + glow / 6, 40 + glow / 3, 255),
    )
    @raylib.draw_rectangle(
      0,
      0,
      sw,
      280,
      @raylib.Color::new(20, 30 + glow / 6, 62 + glow / 3, 255),
    )

    for i = 0; i < 90; i = i + 1 {
      let x = (i * 86 + (crowd_t * 48.0).to_int()) % (sw + 180) - 90
      let h = 130 + i * 43 % 280
      let w = 44 + i * 17 % 76
      let c = 22 + i * 13 % 62
      @raylib.draw_rectangle(
        x,
        sh - h,
        w,
        h,
        @raylib.Color::new(c, c + 8, c + 28, 255),
      )
      if i % 2 == 0 {
        @raylib.draw_rectangle(
          x + 8,
          sh - h + 22,
          8,
          h - 34,
          @raylib.Color::new(86, 210, 248, 194),
        )
      }
      if i % 3 == 0 {
        @raylib.draw_rectangle(
          x + 26,
          sh - h + 40,
          8,
          h - 48,
          @raylib.Color::new(242, 132, 226, 188),
        )
      }
    }

    let court_top = ground_y - 6.0
    @raylib.draw_rectangle(
      0,
      court_top.to_int(),
      sw,
      sh - court_top.to_int(),
      @raylib.Color::new(58, 56, 64, 255),
    )
    @raylib.draw_rectangle(
      0,
      (court_top + 6.0).to_int(),
      sw,
      42,
      @raylib.Color::new(74, 74, 82, 255),
    )

    for i = 0; i < 36; i = i + 1 {
      let x = (i * 40 + (crowd_t * 100.0).to_int()) % (sw + 80) - 40
      @raylib.draw_line(
        x,
        (court_top + 8.0).to_int(),
        x + 18,
        (court_top + 38.0).to_int(),
        @raylib.Color::new(96, 96, 106, 255),
      )
    }

    @raylib.draw_line(
      0,
      (court_top - 2.0).to_int(),
      sw,
      (court_top - 2.0).to_int(),
      @raylib.Color::new(230, 230, 234, 255),
    )
    @raylib.draw_line(
      net_x,
      (court_top - 2.0).to_int(),
      net_x,
      (court_top - Float::from_int(net_h)).to_int(),
      @raylib.Color::new(214, 220, 232, 255),
    )

    for y = 0; y < net_h / 12; y = y + 1 {
      let yy = (court_top - Float::from_int(net_h) + Float::from_int(y * 12)).to_int()
      @raylib.draw_line(
        net_x - 22,
        yy,
        net_x + 22,
        yy,
        @raylib.Color::new(196, 204, 224, 255),
      )
    }

    @raylib.draw_rectangle(
      net_x - 4,
      (court_top - Float::from_int(net_h)).to_int(),
      8,
      net_h + 6,
      @raylib.Color::new(186, 190, 204, 255),
    )

    let player_color = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 236, 148, 255)
    } else {
      @raylib.Color::new(90, 210, 248, 255)
    }

    let bot_color = if bot.flash_t > 0.0 {
      @raylib.Color::new(252, 236, 148, 255)
    } else {
      @raylib.Color::new(248, 118, 210, 255)
    }

    let px = (player.x + shake_x).to_int()
    let py = player.y.to_int()

    @raylib.draw_circle(
      px,
      py - 60,
      14.0,
      @raylib.Color::new(236, 242, 250, 255),
    )
    @raylib.draw_rectangle(px - 14, py - 46, 28, 34, player_color)
    @raylib.draw_line(
      px - 10,
      py - 34,
      px - 26 + (player.vx * 0.03).to_int(),
      py - 16,
      player_color,
    )
    @raylib.draw_line(
      px + 10,
      py - 34,
      px + 26 + (player.vx * 0.03).to_int(),
      py - 16,
      player_color,
    )
    @raylib.draw_line(px - 8, py - 12, px - 14, py + 16, player_color)
    @raylib.draw_line(px + 8, py - 12, px + 14, py + 16, player_color)

    if player.dash_t > 0.0 {
      @raylib.draw_line(
        px - 38,
        py - 52,
        px - 10,
        py - 52,
        @raylib.Color::new(250, 230, 136, 255),
      )
      @raylib.draw_line(
        px - 48,
        py - 40,
        px - 20,
        py - 40,
        @raylib.Color::new(250, 230, 136, 255),
      )
      @raylib.draw_line(
        px - 38,
        py - 28,
        px - 10,
        py - 28,
        @raylib.Color::new(250, 230, 136, 255),
      )
    }

    let bx = (bot.x + shake_x).to_int()
    let by = bot.y.to_int()

    @raylib.draw_circle(
      bx,
      by - 60,
      14.0,
      @raylib.Color::new(236, 242, 250, 255),
    )
    @raylib.draw_rectangle(bx - 14, by - 46, 28, 34, bot_color)
    @raylib.draw_line(
      bx - 10,
      by - 34,
      bx - 26 + (bot.vx * 0.03).to_int(),
      by - 16,
      bot_color,
    )
    @raylib.draw_line(
      bx + 10,
      by - 34,
      bx + 26 + (bot.vx * 0.03).to_int(),
      by - 16,
      bot_color,
    )
    @raylib.draw_line(bx - 8, by - 12, bx - 14, by + 16, bot_color)
    @raylib.draw_line(bx + 8, by - 12, bx + 14, by + 16, bot_color)

    if bot.dash_t > 0.0 {
      @raylib.draw_line(
        bx + 38,
        by - 52,
        bx + 10,
        by - 52,
        @raylib.Color::new(250, 230, 136, 255),
      )
      @raylib.draw_line(
        bx + 48,
        by - 40,
        bx + 20,
        by - 40,
        @raylib.Color::new(250, 230, 136, 255),
      )
      @raylib.draw_line(
        bx + 38,
        by - 28,
        bx + 10,
        by - 28,
        @raylib.Color::new(250, 230, 136, 255),
      )
    }

    if ball.active || rally_wait > 0.0 {
      let ball_x = (ball.x + shake_x).to_int()
      let ball_y = ball.y.to_int()

      @raylib.draw_circle(
        ball_x,
        ball_y,
        ball.r,
        @raylib.Color::new(250, 244, 232, 255),
      )
      @raylib.draw_circle(
        ball_x - 4,
        ball_y - 2,
        ball.r * 0.55,
        @raylib.Color::new(244, 206, 112, 255),
      )
      @raylib.draw_line(
        ball_x - ball.r.to_int(),
        ball_y,
        ball_x + ball.r.to_int(),
        ball_y,
        @raylib.Color::new(210, 194, 176, 255),
      )
      @raylib.draw_line(
        ball_x,
        ball_y - ball.r.to_int(),
        ball_x,
        ball_y + ball.r.to_int(),
        @raylib.Color::new(210, 194, 176, 255),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let c = if particles[i].kind == 0 {
        @raylib.Color::new(255, 116, 122, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 120, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(226, 156, 252, 255)
      } else {
        @raylib.Color::new(118, 230, 246, 255)
      }
      @raylib.draw_circle(
        (particles[i].x + shake_x).to_int(),
        particles[i].y.to_int(),
        2.0,
        c,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 118, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text(
      "ROOFTOP VOLLEYBALL 2026",
      16,
      18,
      34,
      @raylib.Color::new(236, 246, 255, 255),
    )

    @raylib.draw_text(
      "Player",
      420,
      18,
      26,
      @raylib.Color::new(110, 226, 250, 255),
    )
    @raylib.draw_text(
      "Rival",
      770,
      18,
      26,
      @raylib.Color::new(248, 140, 226, 255),
    )

    @raylib.draw_text(
      "Sets \{player.sets}",
      404,
      50,
      30,
      @raylib.Color::new(220, 236, 250, 255),
    )
    @raylib.draw_text(
      "Sets \{bot.sets}",
      754,
      50,
      30,
      @raylib.Color::new(220, 236, 250, 255),
    )

    @raylib.draw_text(
      "Pts \{player.score}",
      526,
      50,
      30,
      @raylib.Color::new(250, 232, 142, 255),
    )
    @raylib.draw_text(
      "Pts \{bot.score}",
      876,
      50,
      30,
      @raylib.Color::new(250, 232, 142, 255),
    )

    @raylib.draw_text(
      "Stars \{stars}",
      1080,
      24,
      30,
      @raylib.Color::new(250, 228, 136, 255),
    )

    @raylib.draw_text(
      "P-Energy \{player.energy.to_int()}%",
      20,
      78,
      22,
      @raylib.Color::new(214, 236, 252, 255),
    )
    @raylib.draw_text(
      "B-Energy \{bot.energy.to_int()}%",
      246,
      78,
      22,
      @raylib.Color::new(214, 236, 252, 255),
    )

    @raylib.draw_rectangle(20, 104, 190, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      104,
      (player.energy / 100.0 * 190.0).to_int(),
      8,
      @raylib.Color::new(96, 202, 246, 255),
    )

    @raylib.draw_rectangle(
      246,
      104,
      190,
      8,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      246,
      104,
      (bot.energy / 100.0 * 190.0).to_int(),
      8,
      @raylib.Color::new(236, 126, 214, 255),
    )

    if wind.ttl > 0.0 {
      let dir = if wind.dir > 0.0 { "->" } else { "<-" }
      @raylib.draw_text(
        "Wind \{dir} \{wind.strength.to_int()}",
        470,
        82,
        28,
        @raylib.Color::new(166, 234, 250, 255),
      )
    } else {
      @raylib.draw_text(
        "Wind calm",
        470,
        82,
        28,
        @raylib.Color::new(130, 146, 170, 255),
      )
    }

    @raylib.draw_rectangle(
      16,
      sh - 182,
      202,
      172,
      @raylib.Color::new(8, 14, 28, 220),
    )
    @raylib.draw_text("Touch", 78, sh - 174, 20, @raylib.white)
    @raylib.draw_rectangle(
      move_left_x,
      move_left_y,
      92,
      152,
      @raylib.Color::new(52, 72, 100, 255),
    )
    @raylib.draw_text(
      "LEFT",
      move_left_x + 18,
      move_left_y + 62,
      28,
      @raylib.white,
    )
    @raylib.draw_rectangle(
      move_right_x,
      move_right_y,
      92,
      152,
      @raylib.Color::new(52, 72, 100, 255),
    )
    @raylib.draw_text(
      "RIGHT",
      move_right_x + 10,
      move_right_y + 62,
      28,
      @raylib.white,
    )

    @raylib.draw_rectangle(
      jump_x,
      jump_y,
      108,
      152,
      @raylib.Color::new(72, 154, 220, 255),
    )
    @raylib.draw_text("JUMP", jump_x + 16, jump_y + 58, 30, @raylib.white)
    @raylib.draw_rectangle(
      hit_x,
      hit_y,
      108,
      152,
      @raylib.Color::new(214, 110, 82, 255),
    )
    @raylib.draw_text("HIT", hit_x + 28, hit_y + 58, 30, @raylib.white)
    @raylib.draw_rectangle(
      dash_x,
      dash_y,
      92,
      152,
      @raylib.Color::new(94, 188, 124, 255),
    )
    @raylib.draw_text("DASH", dash_x + 8, dash_y + 58, 26, @raylib.white)

    @raylib.draw_rectangle(
      224,
      sh - 54,
      sw - 448,
      38,
      @raylib.Color::new(6, 10, 18, 220),
    )
    @raylib.draw_text(
      round_msg,
      236,
      sh - 46,
      24,
      @raylib.Color::new(224, 236, 248, 255),
    )

    if rally_wait > 0.0 && not(over) {
      let countdown = rally_wait.to_int() + 1
      @raylib.draw_text(
        "Next rally \{countdown}",
        sw / 2 - 92,
        sh / 2 - 30,
        36,
        @raylib.Color::new(248, 236, 142, 255),
      )
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 130))
      @raylib.draw_rectangle(
        sw / 2 - 340,
        sh / 2 - 104,
        680,
        208,
        @raylib.Color::new(16, 24, 40, 244),
      )
      @raylib.draw_text(
        if won {
          "CHAMPION"
        } else {
          "DEFEAT"
        },
        sw / 2 - 160,
        sh / 2 - 30,
        72,
        if won {
          @raylib.Color::new(252, 238, 148, 255)
        } else {
          @raylib.Color::new(252, 140, 140, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 46,
        34,
        @raylib.Color::new(224, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
