///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let field_l : Float = 86.0

///|
let field_t : Float = 92.0

///|
let field_r : Float = 1194.0

///|
let field_b : Float = 668.0

///|
let goal_h : Float = 208.0

///|
let goal_t : Float = (field_t + field_b - goal_h) * 0.5

///|
let goal_b : Float = goal_t + goal_h

///|
let center_x : Float = (field_l + field_r) * 0.5

///|
let center_y : Float = (field_t + field_b) * 0.5

///|
let car_r : Float = 24.0

///|
let max_pickups : Int = 30

///|
let max_particles : Int = 980

///|
struct Car {
  mut x : Float
  mut y : Float
  mut angle : Float
  mut speed : Float
  mut boost : Float
  mut dash_cd : Float
  mut pulse_cd : Float
  mut stun_t : Float
  mut flash_t : Float
}

///|
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  r : Float
  mut last_touch : Int
  mut fire_t : Float
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : Int
  mut t : Float
  mut life : Float
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
fn wrap_deg(a : Float) -> Float {
  let mut r : Float = a
  while r > 180.0 {
    r = r - 360.0
  }
  while r < -180.0 {
    r = r + 360.0
  }
  r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
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
fn clear_pickups(items : Array[Pickup]) -> Unit {
  for i = 0; i < items.length(); i = i + 1 {
    items[i].active = false
    items[i].x = 0.0
    items[i].y = 0.0
    items[i].kind = 0
    items[i].t = 0.0
    items[i].life = 0.0
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
fn spawn_pickup(items : Array[Pickup]) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < items.length(); i = i + 1 {
    if not(items[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    items[slot].active = true
    items[slot].x = randf(field_l + 120.0, field_r - 120.0)
    items[slot].y = randf(field_t + 92.0, field_b - 92.0)
    items[slot].kind = @raylib.get_random_value(0, 2)
    items[slot].t = 0.0
    items[slot].life = randf(8.0, 15.0)
    true
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut left = n
  for i = 0; i < parts.length(); i = i + 1 {
    if left <= 0 {
      break
    }
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-280, 280)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-280, 280)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(16, 74)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn reset_round(
  player : Car,
  ai : Car,
  ball : Ball,
  kickoff_to_right : Bool,
) -> Unit {
  player.x = field_l + 188.0
  player.y = center_y
  player.angle = 0.0
  player.speed = 0.0
  player.stun_t = 0.0
  player.flash_t = 0.0

  ai.x = field_r - 188.0
  ai.y = center_y
  ai.angle = 180.0
  ai.speed = 0.0
  ai.stun_t = 0.0
  ai.flash_t = 0.0

  ball.x = center_x
  ball.y = center_y
  ball.vx = if kickoff_to_right { 108.0 } else { -108.0 }
  ball.vy = randf(-48.0, 48.0)
  ball.last_touch = 0
  ball.fire_t = 0.0
}

///|
fn car_forward_x(car : Car) -> Float {
  cosf_deg(car.angle)
}

///|
fn car_forward_y(car : Car) -> Float {
  sinf_deg(car.angle)
}

///|
fn cap_car_in_field(car : Car) -> Bool {
  let mut bounced = false
  if car.x < field_l + car_r {
    car.x = field_l + car_r
    car.speed = -car.speed * 0.36
    bounced = true
  }
  if car.x > field_r - car_r {
    car.x = field_r - car_r
    car.speed = -car.speed * 0.36
    bounced = true
  }
  if car.y < field_t + car_r {
    car.y = field_t + car_r
    car.speed = -car.speed * 0.36
    bounced = true
  }
  if car.y > field_b - car_r {
    car.y = field_b - car_r
    car.speed = -car.speed * 0.36
    bounced = true
  }
  bounced
}

///|
fn collide_car_ball(
  car : Car,
  ball : Ball,
  owner : Int,
  parts : Array[Particle],
) -> Unit {
  let dx = ball.x - car.x
  let dy = ball.y - car.y
  let min_d = car_r + ball.r
  let d2 = dx * dx + dy * dy

  if d2 <= min_d * min_d {
    let mut d = d2.sqrt()
    let mut nx : Float = 1.0
    let mut ny : Float = 0.0
    if d > 0.001 {
      nx = dx / d
      ny = dy / d
    } else {
      d = 1.0
    }

    let push = min_d - d + 0.8
    ball.x = ball.x + nx * push
    ball.y = ball.y + ny * push

    let car_vx = car_forward_x(car) * car.speed
    let car_vy = car_forward_y(car) * car.speed

    let rel = (car_vx - ball.vx) * nx + (car_vy - ball.vy) * ny
    if rel > 0.0 {
      let imp = rel * 1.45 + 62.0
      ball.vx = ball.vx + nx * imp
      ball.vy = ball.vy + ny * imp
    }

    ball.last_touch = owner
    ball.fire_t = 0.14
    burst(parts, ball.x, ball.y, 7, 0.11, 0)
  }
}

///|
fn collide_cars(a : Car, b : Car, parts : Array[Particle]) -> Unit {
  let dx = b.x - a.x
  let dy = b.y - a.y
  let min_d = car_r * 2.0
  let d2 = dx * dx + dy * dy
  if d2 <= min_d * min_d {
    let mut d = d2.sqrt()
    let mut nx : Float = 1.0
    let mut ny : Float = 0.0
    if d > 0.001 {
      nx = dx / d
      ny = dy / d
    } else {
      d = 1.0
    }

    let push = min_d - d + 1.0
    a.x = a.x - nx * push * 0.5
    a.y = a.y - ny * push * 0.5
    b.x = b.x + nx * push * 0.5
    b.y = b.y + ny * push * 0.5

    let a_speed = absf(a.speed)
    let b_speed = absf(b.speed)
    let shock = a_speed + b_speed

    a.speed = a.speed * 0.70
    b.speed = b.speed * 0.70

    if shock > 280.0 {
      a.stun_t = 0.22
      b.stun_t = 0.22
      burst(parts, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5, 14, 0.17, 1)
    } else {
      burst(parts, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5, 6, 0.09, 1)
    }
  }
}

///|
fn update_ball(ball : Ball, dt : Float) -> Int {
  ball.x = ball.x + ball.vx * dt
  ball.y = ball.y + ball.vy * dt

  ball.vx = ball.vx * (1.0 - dt * 0.56)
  ball.vy = ball.vy * (1.0 - dt * 0.56)

  let speed2 = ball.vx * ball.vx + ball.vy * ball.vy
  if speed2 > 780.0 * 780.0 {
    let s : Float = speed2.sqrt()
    let inv : Float = 780.0 / s
    ball.vx = ball.vx * inv
    ball.vy = ball.vy * inv
  }

  if ball.y < field_t + ball.r {
    ball.y = field_t + ball.r
    ball.vy = absf(ball.vy) * 0.86
  }
  if ball.y > field_b - ball.r {
    ball.y = field_b - ball.r
    ball.vy = -absf(ball.vy) * 0.86
  }

  let in_goal_band = ball.y >= goal_t && ball.y <= goal_b

  if ball.x < field_l + ball.r {
    if in_goal_band {
      if ball.x < field_l - 20.0 {
        2
      } else {
        0
      }
    } else {
      ball.x = field_l + ball.r
      ball.vx = absf(ball.vx) * 0.86
      0
    }
  } else if ball.x > field_r - ball.r {
    if in_goal_band {
      if ball.x > field_r + 20.0 {
        1
      } else {
        0
      }
    } else {
      ball.x = field_r - ball.r
      ball.vx = -absf(ball.vx) * 0.86
      0
    }
  } else {
    0
  }
}

///|
fn draw_car(car : Car, is_player : Bool) -> Unit {
  let fx = car_forward_x(car)
  let fy = car_forward_y(car)
  let rx = -fy
  let ry = fx

  let px = car.x + fx * 24.0
  let py = car.y + fy * 24.0

  let lx = car.x - fx * 18.0 + rx * 16.0
  let ly = car.y - fy * 18.0 + ry * 16.0

  let rx0 = car.x - fx * 18.0 - rx * 16.0
  let ry0 = car.y - fy * 18.0 - ry * 16.0

  let base_col = if is_player {
    @raylib.Color::new(108, 208, 250, 255)
  } else {
    @raylib.Color::new(248, 132, 108, 255)
  }

  let glow_col = if car.stun_t > 0.0 {
    @raylib.Color::new(250, 236, 180, 220)
  } else if is_player {
    @raylib.Color::new(150, 236, 255, 150)
  } else {
    @raylib.Color::new(255, 184, 164, 150)
  }

  @raylib.draw_circle(car.x.to_int(), car.y.to_int(), 24.0, glow_col)
  @raylib.draw_triangle(
    @raylib.Vector2::new(px, py),
    @raylib.Vector2::new(lx, ly),
    @raylib.Vector2::new(rx0, ry0),
    base_col,
  )

  @raylib.draw_triangle_lines(
    @raylib.Vector2::new(px, py),
    @raylib.Vector2::new(lx, ly),
    @raylib.Vector2::new(rx0, ry0),
    @raylib.Color::new(26, 32, 48, 220),
  )

  let core_col = if is_player {
    @raylib.Color::new(240, 252, 255, 255)
  } else {
    @raylib.Color::new(255, 244, 236, 255)
  }
  @raylib.draw_circle(
    (car.x - fx * 2.0).to_int(),
    (car.y - fy * 2.0).to_int(),
    7.5,
    core_col,
  )
}

///|
fn draw_field_lines() -> Unit {
  @raylib.draw_rectangle(
    field_l.to_int(),
    field_t.to_int(),
    (field_r - field_l).to_int(),
    (field_b - field_t).to_int(),
    @raylib.Color::new(40, 88, 52, 255),
  )

  for i = 0; i < 18; i = i + 1 {
    let stripe_y = field_t.to_int() + i * 32
    let tint = if i % 2 == 0 { 42 } else { 36 }
    @raylib.draw_rectangle(
      field_l.to_int(),
      stripe_y,
      (field_r - field_l).to_int(),
      18,
      @raylib.Color::new(34, tint + 66, 46, 160),
    )
  }

  @raylib.draw_rectangle_lines(
    field_l.to_int(),
    field_t.to_int(),
    (field_r - field_l).to_int(),
    (field_b - field_t).to_int(),
    @raylib.Color::new(240, 245, 250, 220),
  )

  @raylib.draw_line(
    center_x.to_int(),
    field_t.to_int(),
    center_x.to_int(),
    field_b.to_int(),
    @raylib.Color::new(240, 245, 250, 200),
  )
  @raylib.draw_circle_lines(
    center_x.to_int(),
    center_y.to_int(),
    88.0,
    @raylib.Color::new(240, 245, 250, 200),
  )

  @raylib.draw_rectangle(
    (field_l - 28.0).to_int(),
    goal_t.to_int(),
    28,
    (goal_b - goal_t).to_int(),
    @raylib.Color::new(90, 120, 166, 220),
  )
  @raylib.draw_rectangle(
    field_r.to_int(),
    goal_t.to_int(),
    28,
    (goal_b - goal_t).to_int(),
    @raylib.Color::new(90, 120, 166, 220),
  )

  @raylib.draw_rectangle(
    (field_l - 4.0).to_int(),
    (goal_t + 24.0).to_int(),
    20,
    (goal_b - goal_t - 48.0).to_int(),
    @raylib.Color::new(166, 214, 248, 120),
  )
  @raylib.draw_rectangle(
    (field_r - 16.0).to_int(),
    (goal_t + 24.0).to_int(),
    20,
    (goal_b - goal_t - 48.0).to_int(),
    @raylib.Color::new(166, 214, 248, 120),
  )

  @raylib.draw_rectangle(
    (field_l + 26.0).to_int(),
    (center_y - 118.0).to_int(),
    76,
    236,
    @raylib.Color::new(255, 255, 255, 35),
  )
  @raylib.draw_rectangle(
    (field_r - 102.0).to_int(),
    (center_y - 118.0).to_int(),
    76,
    236,
    @raylib.Color::new(255, 255, 255, 35),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "Rocket Arena Soccer 2026")
  @raylib.set_target_fps(60)

  let player : Car = {
    x: field_l + 188.0,
    y: center_y,
    angle: 0.0,
    speed: 0.0,
    boost: 100.0,
    dash_cd: 0.0,
    pulse_cd: 0.0,
    stun_t: 0.0,
    flash_t: 0.0,
  }

  let ai : Car = {
    x: field_r - 188.0,
    y: center_y,
    angle: 180.0,
    speed: 0.0,
    boost: 100.0,
    dash_cd: 0.0,
    pulse_cd: 0.0,
    stun_t: 0.0,
    flash_t: 0.0,
  }

  let ball : Ball = {
    x: center_x,
    y: center_y,
    vx: 90.0,
    vy: 0.0,
    r: 14.0,
    last_touch: 0,
    fire_t: 0.0,
  }

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, x: 0.0, y: 0.0, kind: 0, t: 0.0, life: 0.0 }
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
  let mut match_time : Float = 210.0
  let mut player_score : Int = 0
  let mut ai_score : Int = 0
  let mut style_pts : Int = 0

  let mut kickoff_right : Bool = true
  let mut goal_pause_t : Float = 0.0

  let mut pickup_spawn_cd : Float = 3.2

  let mut msg : String = "Boost, dash and pulse the ball into goal"
  let mut msg_t : Float = 3.0

  let reset_match = fn() {
    match_time = 210.0
    player_score = 0
    ai_score = 0
    style_pts = 0

    player.boost = 100.0
    player.dash_cd = 0.0
    player.pulse_cd = 0.0
    player.speed = 0.0
    player.angle = 0.0
    player.stun_t = 0.0

    ai.boost = 100.0
    ai.dash_cd = 0.0
    ai.pulse_cd = 0.0
    ai.speed = 0.0
    ai.angle = 180.0
    ai.stun_t = 0.0

    goal_pause_t = 0.0
    pickup_spawn_cd = 3.2
    kickoff_right = true

    clear_pickups(pickups)
    clear_particles(particles)
    reset_round(player, ai, ball, kickoff_right)

    msg = "Kickoff"
    msg_t = 1.2
  }

  reset_match()

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

    if ball.fire_t > 0.0 {
      ball.fire_t = ball.fire_t - dt
      if ball.fire_t < 0.0 {
        ball.fire_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_match()
      }
    } else if state == 1 {
      if goal_pause_t > 0.0 {
        goal_pause_t = goal_pause_t - dt
        if goal_pause_t < 0.0 {
          goal_pause_t = 0.0
        }
      } else {
        match_time = match_time - dt
      }

      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }
      player.pulse_cd = player.pulse_cd - dt
      if player.pulse_cd < 0.0 {
        player.pulse_cd = 0.0
      }
      player.stun_t = player.stun_t - dt
      if player.stun_t < 0.0 {
        player.stun_t = 0.0
      }
      player.flash_t = player.flash_t - dt
      if player.flash_t < 0.0 {
        player.flash_t = 0.0
      }

      ai.dash_cd = ai.dash_cd - dt
      if ai.dash_cd < 0.0 {
        ai.dash_cd = 0.0
      }
      ai.pulse_cd = ai.pulse_cd - dt
      if ai.pulse_cd < 0.0 {
        ai.pulse_cd = 0.0
      }
      ai.stun_t = ai.stun_t - dt
      if ai.stun_t < 0.0 {
        ai.stun_t = 0.0
      }
      ai.flash_t = ai.flash_t - dt
      if ai.flash_t < 0.0 {
        ai.flash_t = 0.0
      }

      player.boost = player.boost + dt * 9.5
      if player.boost > 100.0 {
        player.boost = 100.0
      }
      ai.boost = ai.boost + dt * 8.5
      if ai.boost > 100.0 {
        ai.boost = 100.0
      }

      if goal_pause_t <= 0.0 {
        let mut steer_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
          @raylib.is_key_down(@raylib.KeyLeft)
        let mut steer_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
          @raylib.is_key_down(@raylib.KeyRight)
        let mut throttle_f : Bool = @raylib.is_key_down(@raylib.KeyW) ||
          @raylib.is_key_down(@raylib.KeyUp)
        let mut throttle_b : Bool = @raylib.is_key_down(@raylib.KeyS) ||
          @raylib.is_key_down(@raylib.KeyDown)

        let mut boost_down : Bool = @raylib.is_key_down(@raylib.KeyJ)
        let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
        let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

        let pad_x = 20
        let pad_y = sh - 198
        let btn_x = sw - 296
        let btn_y = sh - 236

        if touching {
          if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 58, 78, 58) {
            steer_l = true
          }
          if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 58, 78, 58) {
            steer_r = true
          }
          if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
            throttle_f = true
          }
          if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 116, 78, 58) {
            throttle_b = true
          }
          if inside_rect(mouse.x, mouse.y, btn_x + 74, btn_y + 116, 150, 100) {
            boost_down = true
          }
        }

        if pressed {
          if inside_rect(mouse.x, mouse.y, btn_x + 8, btn_y + 10, 120, 92) {
            dash_press = true
          }
          if inside_rect(mouse.x, mouse.y, btn_x + 136, btn_y + 10, 120, 92) {
            pulse_press = true
          }
        }

        let mut steer : Float = 0.0
        if steer_l {
          steer = steer - 1.0
        }
        if steer_r {
          steer = steer + 1.0
        }

        let mut throttle : Float = 0.0
        if throttle_f {
          throttle = throttle + 1.0
        }
        if throttle_b {
          throttle = throttle - 1.0
        }

        if player.stun_t > 0.0 {
          steer = steer * 0.35
          throttle = throttle * 0.28
        }

        let mut player_engine : Float = 460.0
        if boost_down && player.boost > 0.0 {
          player_engine = 660.0
          player.boost = player.boost - dt * 25.0
          if player.boost < 0.0 {
            player.boost = 0.0
          }

          if @raylib.get_random_value(0, 99) < 24 {
            let bx = player.x - car_forward_x(player) * 18.0
            let by = player.y - car_forward_y(player) * 18.0
            burst(particles, bx, by, 1, 0.09, 2)
          }
        }

        if dash_press && player.dash_cd <= 0.0 && player.boost >= 12.0 {
          player.speed = player.speed + 230.0
          player.dash_cd = 1.26
          player.boost = player.boost - 12.0
          player.flash_t = 0.22
          burst(particles, player.x, player.y, 14, 0.15, 2)
          msg = "Boost dash"
          msg_t = 0.42
        }

        if pulse_press &&
          player.pulse_cd <= 0.0 &&
          player.boost >= 18.0 &&
          dist2(player.x, player.y, ball.x, ball.y) <= 226.0 * 226.0 {
          player.pulse_cd = 2.24
          player.boost = player.boost - 18.0

          let dx = field_r + 180.0 - ball.x
          let dy = center_y - ball.y
          let inv : Float = 1.0 / clampf(absf(dx) + absf(dy), 24.0, 4000.0)
          ball.vx = ball.vx + dx * inv * 420.0
          ball.vy = ball.vy + dy * inv * 420.0
          ball.last_touch = 1
          ball.fire_t = 0.36
          burst(particles, ball.x, ball.y, 18, 0.18, 2)
          msg = "Pulse strike"
          msg_t = 0.52
          style_pts = style_pts + 8
        }

        player.speed = player.speed + throttle * player_engine * dt
        let drag : Float = if absf(throttle) > 0.01 { 1.7 } else { 2.5 }
        player.speed = player.speed * (1.0 - dt * drag)
        if absf(player.speed) < 4.0 {
          player.speed = 0.0
        }

        let turn_rate : Float = 220.0 + absf(player.speed) * 0.30
        player.angle = player.angle + steer * turn_rate * dt
        player.angle = wrap_deg(player.angle)

        player.speed = clampf(player.speed, -160.0, 430.0)
        player.x = player.x + car_forward_x(player) * player.speed * dt
        player.y = player.y + car_forward_y(player) * player.speed * dt

        let p_bounced = cap_car_in_field(player)
        if p_bounced && absf(player.speed) > 160.0 {
          player.stun_t = 0.16
          player.flash_t = 0.16
          burst(particles, player.x, player.y, 8, 0.10, 1)
        }

        // AI driving logic.
        let mut target_x : Float = ball.x
        let mut target_y : Float = ball.y
        let ball_far_right = ball.x > center_x + 120.0
        if ball_far_right {
          target_x = ball.x - 26.0
          target_y = ball.y
        }

        let dist_ball = dist2(ai.x, ai.y, ball.x, ball.y).sqrt()
        if dist_ball < 110.0 {
          target_x = field_l - 120.0
          target_y = center_y + clampf(ball.y - center_y, -90.0, 90.0)
        }

        let desired = Float::from_double(
          @math.atan2(
            (target_y - ai.y).to_double(),
            (target_x - ai.x).to_double(),
          ) *
          57.29577951308232,
        )
        let delta = wrap_deg(desired - ai.angle)

        let mut ai_steer : Float = 0.0
        if delta > 7.0 {
          ai_steer = 1.0
        } else if delta < -7.0 {
          ai_steer = -1.0
        }

        let mut ai_throttle : Float = 1.0
        if absf(delta) > 120.0 {
          ai_throttle = -0.35
        } else if absf(delta) > 72.0 {
          ai_throttle = 0.55
        }

        let mut ai_boosting = false
        if dist_ball > 280.0 && ai.boost > 28.0 && absf(delta) < 28.0 {
          ai_boosting = true
        }

        if ai.stun_t > 0.0 {
          ai_steer = ai_steer * 0.36
          ai_throttle = ai_throttle * 0.24
          ai_boosting = false
        }

        let mut ai_engine : Float = 430.0
        if ai_boosting && ai.boost > 0.0 {
          ai_engine = 620.0
          ai.boost = ai.boost - dt * 21.0
          if ai.boost < 0.0 {
            ai.boost = 0.0
          }
        }

        if dist_ball < 124.0 &&
          ai.dash_cd <= 0.0 &&
          ai.boost >= 12.0 &&
          absf(delta) < 22.0 {
          ai.speed = ai.speed + 210.0
          ai.dash_cd = 1.4
          ai.boost = ai.boost - 12.0
          ai.flash_t = 0.18
          burst(particles, ai.x, ai.y, 10, 0.12, 1)
        }

        if dist_ball < 140.0 &&
          ai.pulse_cd <= 0.0 &&
          ai.boost >= 18.0 &&
          @raylib.get_random_value(0, 99) < 8 {
          ai.pulse_cd = 2.55
          ai.boost = ai.boost - 18.0

          let dx = field_l - 180.0 - ball.x
          let dy = center_y - ball.y
          let inv : Float = 1.0 / clampf(absf(dx) + absf(dy), 24.0, 4000.0)
          ball.vx = ball.vx + dx * inv * 380.0
          ball.vy = ball.vy + dy * inv * 380.0
          ball.last_touch = 2
          ball.fire_t = 0.32
          burst(particles, ball.x, ball.y, 14, 0.16, 1)
        }

        ai.speed = ai.speed + ai_throttle * ai_engine * dt
        let ai_drag : Float = if absf(ai_throttle) > 0.01 { 1.8 } else { 2.3 }
        ai.speed = ai.speed * (1.0 - dt * ai_drag)
        if absf(ai.speed) < 4.0 {
          ai.speed = 0.0
        }

        let ai_turn : Float = 205.0 + absf(ai.speed) * 0.28
        ai.angle = ai.angle + ai_steer * ai_turn * dt
        ai.angle = wrap_deg(ai.angle)

        ai.speed = clampf(ai.speed, -150.0, 410.0)
        ai.x = ai.x + car_forward_x(ai) * ai.speed * dt
        ai.y = ai.y + car_forward_y(ai) * ai.speed * dt

        let ai_bounced = cap_car_in_field(ai)
        if ai_bounced && absf(ai.speed) > 160.0 {
          ai.stun_t = 0.14
          ai.flash_t = 0.14
          burst(particles, ai.x, ai.y, 7, 0.09, 1)
        }

        collide_cars(player, ai, particles)

        collide_car_ball(player, ball, 1, particles)
        collide_car_ball(ai, ball, 2, particles)

        let goal = update_ball(ball, dt)
        if goal == 1 {
          player_score = player_score + 1
          style_pts = style_pts +
            120 +
            (if ball.last_touch == 1 { 30 } else { 0 })
          msg = "GOAL"
          msg_t = 1.0
          kickoff_right = false
          goal_pause_t = 1.65
          burst(particles, center_x, center_y, 36, 0.23, 2)
          reset_round(player, ai, ball, kickoff_right)
        } else if goal == 2 {
          ai_score = ai_score + 1
          msg = "Opponent scored"
          msg_t = 1.0
          kickoff_right = true
          goal_pause_t = 1.65
          burst(particles, center_x, center_y, 28, 0.20, 1)
          reset_round(player, ai, ball, kickoff_right)
        }

        pickup_spawn_cd = pickup_spawn_cd - dt
        if pickup_spawn_cd <= 0.0 {
          ignore(spawn_pickup(pickups))
          pickup_spawn_cd = randf(4.2, 6.8)
        }

        for i = 0; i < pickups.length(); i = i + 1 {
          if not(pickups[i].active) {
            continue
          }

          pickups[i].t = pickups[i].t + dt
          if pickups[i].t >= pickups[i].life {
            pickups[i].active = false
            continue
          }

          let pget = dist2(player.x, player.y, pickups[i].x, pickups[i].y) <=
            30.0 * 30.0
          let aget = dist2(ai.x, ai.y, pickups[i].x, pickups[i].y) <=
            30.0 * 30.0

          if pget {
            if pickups[i].kind == 0 {
              player.boost = clampf(player.boost + 34.0, 0.0, 100.0)
              msg = "Nitro cell"
              msg_t = 0.46
            } else if pickups[i].kind == 1 {
              player.dash_cd = clampf(player.dash_cd - 0.9, 0.0, 99.0)
              player.pulse_cd = clampf(player.pulse_cd - 0.9, 0.0, 99.0)
              msg = "Cooldown chip"
              msg_t = 0.46
            } else {
              player.speed = player.speed + 120.0
              style_pts = style_pts + 24
              msg = "Overdrive"
              msg_t = 0.46
            }
            pickups[i].active = false
            burst(particles, pickups[i].x, pickups[i].y, 10, 0.13, 2)
          } else if aget {
            if pickups[i].kind == 0 {
              ai.boost = clampf(ai.boost + 30.0, 0.0, 100.0)
            } else if pickups[i].kind == 1 {
              ai.dash_cd = clampf(ai.dash_cd - 0.7, 0.0, 99.0)
              ai.pulse_cd = clampf(ai.pulse_cd - 0.7, 0.0, 99.0)
            } else {
              ai.speed = ai.speed + 104.0
            }
            pickups[i].active = false
            burst(particles, pickups[i].x, pickups[i].y, 8, 0.11, 1)
          }
        }

        if player_score >= 7 {
          state = 2
        } else if ai_score >= 7 {
          state = 3
        } else if match_time <= 0.0 {
          if player_score > ai_score ||
            (player_score == ai_score && style_pts >= 0) {
            state = 2
          } else {
            state = 3
          }
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
          particles[i].vx = particles[i].vx * (1.0 - dt * 2.1)
          particles[i].vy = particles[i].vy + 220.0 * dt
        }
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_match()
      }
    }

    @raylib.begin_drawing()

    let bg_col = if state == 2 {
      @raylib.Color::new(12, 24, 22, 255)
    } else if state == 3 {
      @raylib.Color::new(28, 16, 20, 255)
    } else {
      @raylib.Color::new(12, 18, 26, 255)
    }
    @raylib.clear_background(bg_col)

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 22, 34, 255))

    for i = 0; i < 30; i = i + 1 {
      let px = i * 44 + (match_time * 10.0).to_int() % 44
      let py = 36 + i * 19 % 44
      @raylib.draw_circle(px, py, 2.0, @raylib.Color::new(146, 188, 232, 150))
    }

    draw_field_lines()

    for i = 0; i < pickups.length(); i = i + 1 {
      if pickups[i].active {
        let pulse = if (pickups[i].t * 8.0).to_int() % 2 == 0 {
          255
        } else {
          184
        }
        let col = if pickups[i].kind == 0 {
          @raylib.Color::new(128, 236, 168, pulse)
        } else if pickups[i].kind == 1 {
          @raylib.Color::new(128, 212, 248, pulse)
        } else {
          @raylib.Color::new(244, 208, 118, pulse)
        }
        @raylib.draw_circle(
          pickups[i].x.to_int(),
          pickups[i].y.to_int(),
          11.0,
          col,
        )
        @raylib.draw_circle_lines(
          pickups[i].x.to_int(),
          pickups[i].y.to_int(),
          15.0,
          @raylib.Color::new(28, 36, 52, pulse),
        )
      }
    }

    let ball_col = if ball.fire_t > 0.0 {
      @raylib.Color::new(255, 204, 132, 255)
    } else {
      @raylib.Color::new(236, 244, 255, 255)
    }
    if ball.fire_t > 0.0 {
      @raylib.draw_circle(
        ball.x.to_int(),
        ball.y.to_int(),
        ball.r + 6.0,
        @raylib.Color::new(255, 176, 104, 96),
      )
    }
    @raylib.draw_circle(ball.x.to_int(), ball.y.to_int(), ball.r, ball_col)
    @raylib.draw_circle_lines(
      ball.x.to_int(),
      ball.y.to_int(),
      ball.r + 2.0,
      @raylib.Color::new(26, 30, 46, 220),
    )

    draw_car(player, true)
    draw_car(ai, false)

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let ratio : Float = 1.0 - particles[i].t / particles[i].life
      let alpha = (ratio * 255.0).to_int()
      if alpha <= 0 {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(152, 232, 252, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 164, 152, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(154, 244, 196, alpha)
      } else {
        @raylib.Color::new(252, 128, 148, alpha)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 76, @raylib.Color::new(6, 10, 18, 228))
    @raylib.draw_text(
      "ROCKET ARENA SOCCER 2026",
      16,
      12,
      30,
      @raylib.Color::new(238, 246, 255, 255),
    )
    @raylib.draw_text(
      "WASD drive  J boost  K dash  L pulse",
      16,
      48,
      18,
      @raylib.Color::new(178, 208, 236, 255),
    )

    @raylib.draw_text(
      "YOU \{player_score}",
      528,
      14,
      36,
      @raylib.Color::new(142, 228, 255, 255),
    )
    @raylib.draw_text("-", 656, 14, 36, @raylib.Color::new(236, 244, 255, 255))
    @raylib.draw_text(
      "\{ai_score} AI",
      688,
      14,
      36,
      @raylib.Color::new(255, 176, 152, 255),
    )

    @raylib.draw_text(
      "Time \{match_time.to_int()}s",
      920,
      16,
      30,
      @raylib.Color::new(248, 200, 132, 255),
    )

    @raylib.draw_rectangle(16, 86, 240, 10, @raylib.Color::new(18, 24, 36, 255))
    @raylib.draw_rectangle(
      16,
      86,
      (player.boost / 100.0 * 240.0).to_int(),
      10,
      @raylib.Color::new(112, 198, 248, 255),
    )
    @raylib.draw_text(
      "BOOST",
      16,
      100,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    @raylib.draw_text(
      "Dash \{player.dash_cd.to_int()}  Pulse \{player.pulse_cd.to_int()}",
      270,
      86,
      20,
      @raylib.Color::new(206, 188, 160, 255),
    )
    @raylib.draw_text(
      "Style \{style_pts}",
      540,
      86,
      20,
      @raylib.Color::new(252, 224, 162, 255),
    )

    @raylib.draw_rectangle(
      920,
      84,
      240,
      10,
      @raylib.Color::new(18, 24, 36, 255),
    )
    @raylib.draw_rectangle(
      920,
      84,
      (ai.boost / 100.0 * 240.0).to_int(),
      10,
      @raylib.Color::new(248, 162, 136, 255),
    )
    @raylib.draw_text(
      "AI BOOST",
      920,
      98,
      16,
      @raylib.Color::new(214, 198, 174, 255),
    )

    if goal_pause_t > 0.0 {
      @raylib.draw_text(
        "KICKOFF",
        sw / 2 - 88,
        120,
        42,
        @raylib.Color::new(248, 236, 184, 255),
      )
    }

    @raylib.draw_rectangle(
      sw / 2 - 340,
      sh - 52,
      680,
      38,
      @raylib.Color::new(8, 12, 18, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 320,
      sh - 44,
      24,
      @raylib.Color::new(236, 244, 255, if msg_t > 0.0 { 255 } else { 148 }),
    )

    // Touch UI
    @raylib.draw_rectangle(
      20,
      sh - 198,
      238,
      172,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let p0x = 20
    let p0y = sh - 198
    @raylib.draw_rectangle(
      p0x,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "L",
      p0x + 30,
      p0y + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 160,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "R",
      p0x + 190,
      p0y + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "F",
      p0x + 110,
      p0y + 16,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y + 116,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "B",
      p0x + 110,
      p0y + 132,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 296,
      sh - 236,
      272,
      224,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let p1x = sw - 296
    let p1y = sh - 236
    @raylib.draw_rectangle(
      p1x + 8,
      p1y + 10,
      120,
      92,
      @raylib.Color::new(214, 118, 98, 255),
    )
    @raylib.draw_text(
      "DASH",
      p1x + 32,
      p1y + 44,
      30,
      @raylib.Color::new(252, 238, 230, 255),
    )
    @raylib.draw_rectangle(
      p1x + 136,
      p1y + 10,
      120,
      92,
      @raylib.Color::new(86, 148, 216, 255),
    )
    @raylib.draw_text(
      "PULSE",
      p1x + 154,
      p1y + 44,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      p1x + 74,
      p1y + 116,
      150,
      100,
      @raylib.Color::new(98, 186, 138, 255),
    )
    @raylib.draw_text(
      "BOOST",
      p1x + 106,
      p1y + 154,
      30,
      @raylib.Color::new(236, 248, 242, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 468,
        sh / 2 - 204,
        936,
        408,
        @raylib.Color::new(12, 18, 30, 246),
      )
      @raylib.draw_text(
        "ROCKET ARENA SOCCER",
        sw / 2 - 328,
        sh / 2 - 130,
        64,
        @raylib.Color::new(238, 246, 255, 255),
      )
      @raylib.draw_text(
        "Score 7 goals first. Use boost, dash and pulse to outplay the AI.",
        sw / 2 - 358,
        sh / 2 - 26,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad drive, right panel dash/pulse/boost",
        sw / 2 - 334,
        sh / 2 + 16,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 184,
        sh / 2 + 122,
        42,
        @raylib.Color::new(255, 206, 114, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 146))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "CHAMPIONS",
        sw / 2 - 184,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Final: \{player_score} - \{ai_score}",
        sw / 2 - 176,
        sh / 2 - 30,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Style points: \{style_pts}",
        sw / 2 - 166,
        sh / 2 + 20,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 124,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 154))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "DEFEAT",
        sw / 2 - 114,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Final: \{player_score} - \{ai_score}",
        sw / 2 - 176,
        sh / 2 - 30,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Style points: \{style_pts}",
        sw / 2 - 166,
        sh / 2 + 20,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 124,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_match()
      }
    }
  }

  @raylib.close_window()
}
