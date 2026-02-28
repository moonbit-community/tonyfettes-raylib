///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let rider_screen_y : Float = 538.0

///|
let max_checkpoints : Int = 80

///|
let max_hazards : Int = 320

///|
let max_pickups : Int = 140

///|
let max_particles : Int = 980

///|
struct Rider {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut stamina : Float
  mut speed : Float
  mut air_t : Float
  mut jump_peak : Float
  mut trick_t : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut flash_t : Float
  mut score : Int
  mut combo : Int
  mut coins : Int
}

///|
struct Checkpoint {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut width : Float
  mut state : Int
  mut pulse_t : Float
}

///|
struct Hazard {
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
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn world_to_screen_y(obj_y : Float, rider_y : Float) -> Float {
  obj_y - rider_y + rider_screen_y
}

///|
fn clear_checkpoints(cps : Array[Checkpoint]) -> Unit {
  for cp in cps {
    cp.active = false
    cp.x = 0.0
    cp.y = 0.0
    cp.width = 0.0
    cp.state = 0
    cp.pulse_t = 0.0
  }
}

///|
fn clear_hazards(hs : Array[Hazard]) -> Unit {
  for hs_elem in hs {
    hs_elem.active = false
    hs_elem.x = 0.0
    hs_elem.y = 0.0
    hs_elem.kind = 0
    hs_elem.size = 0.0
  }
}

///|
fn clear_pickups(ps : Array[Pickup]) -> Unit {
  for ps_elem in ps {
    ps_elem.active = false
    ps_elem.x = 0.0
    ps_elem.y = 0.0
    ps_elem.kind = 0
    ps_elem.t = 0.0
  }
}

///|
fn clear_particles(ps : Array[Particle]) -> Unit {
  for ps_elem in ps {
    ps_elem.active = false
    ps_elem.x = 0.0
    ps_elem.y = 0.0
    ps_elem.vx = 0.0
    ps_elem.vy = 0.0
    ps_elem.size = 0.0
    ps_elem.t = 0.0
    ps_elem.life = 0.0
    ps_elem.kind = 0
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
  for ps_elem in ps {
    if done {
      continue
    }

    if not(ps_elem.active) {
      ps_elem.active = true
      ps_elem.x = x
      ps_elem.y = y
      ps_elem.vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps_elem.vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps_elem.size = Float::from_int(@raylib.get_random_value(2, 7))
      ps_elem.t = 0.0
      ps_elem.life = Float::from_int(@raylib.get_random_value(18, 72)) / 100.0
      ps_elem.kind = kind
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
  for i in 0..<count {
    ignore(i)
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn nearest_checkpoint_dy(
  cps : Array[Checkpoint],
  cp_count : Int,
  rider_y : Float,
) -> Float {
  let mut best : Float = 9999999.0
  for i in 0..<cp_count {
    if cps[i].state != 0 {
      continue
    }

    let dy : Float = cps[i].y - rider_y
    if dy >= -40.0 && dy < best {
      best = dy
    }
  }
  best
}

///|
fn generate_course(
  cps : Array[Checkpoint],
  hs : Array[Hazard],
  items : Array[Pickup],
) -> (Int, Float) {
  clear_checkpoints(cps)
  clear_hazards(hs)
  clear_pickups(items)

  let cp_count : Int = 68

  let mut y : Float = 420.0
  for i in 0..<cp_count {
    cps[i].active = true
    cps[i].x = randf(180.0, 1100.0)
    cps[i].y = y + randf(-24.0, 24.0)
    cps[i].width = randf(180.0, 252.0)
    cps[i].state = 0
    cps[i].pulse_t = randf(0.0, 1.0)

    y = y + randf(164.0, 224.0)
  }

  let course_end : Float = cps[cp_count - 1].y + 520.0

  for hs_elem in hs {
    hs_elem.active = true
    hs_elem.x = randf(70.0, world_w - 70.0)
    hs_elem.y = randf(360.0, course_end + 160.0)
    hs_elem.kind = @raylib.get_random_value(0, 3)
    hs_elem.size = if hs_elem.kind == 0 {
      randf(12.0, 20.0)
    } else if hs_elem.kind == 1 {
      randf(18.0, 30.0)
    } else if hs_elem.kind == 2 {
      randf(16.0, 24.0)
    } else {
      randf(14.0, 22.0)
    }
  }

  let mut p = 0
  for i in 0..<cp_count {
    if i % 2 == 0 && p < items.length() {
      items[p].active = true
      items[p].x = cps[i].x + randf(-52.0, 52.0)
      items[p].y = cps[i].y + randf(-34.0, 34.0)
      items[p].kind = @raylib.get_random_value(0, 2)
      items[p].t = randf(0.0, 1.0)
      p = p + 1
    }
  }

  (cp_count, course_end)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Mountain Bike Downhill 2026")
  @raylib.set_target_fps(60)

  let rider : Rider = {
    x: 640.0,
    y: 210.0,
    vx: 0.0,
    hp: 230.0,
    stamina: 100.0,
    speed: 220.0,
    air_t: 0.0,
    jump_peak: 0.0,
    trick_t: 0.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    flash_t: 0.0,
    score: 0,
    combo: 0,
    coins: 0,
  }

  let checkpoints : Array[Checkpoint] = Array::makei(max_checkpoints, fn(_i) {
    { active: false, x: 0.0, y: 0.0, width: 0.0, state: 0, pulse_t: 0.0 }
  })

  let hazards : Array[Hazard] = Array::makei(max_hazards, fn(_i) {
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

  let mut checkpoint_count : Int = 0
  let mut course_end : Float = 0.0

  let mut state : Int = 0
  let mut time_left : Float = 248.0
  let mut clean_count : Int = 0
  let mut miss_count : Int = 0
  let mut tier : Int = 1

  let mut msg : String = "Pedal hard, clear checkpoints, avoid obstacles"
  let mut msg_t : Float = 3.0

  let reset_run = fn() {
    rider.x = 640.0
    rider.y = 210.0
    rider.vx = 0.0
    rider.hp = 230.0
    rider.stamina = 100.0
    rider.speed = 220.0
    rider.air_t = 0.0
    rider.jump_peak = 0.0
    rider.trick_t = 0.0
    rider.boost_t = 0.0
    rider.boost_cd = 0.0
    rider.flash_t = 0.0
    rider.score = 0
    rider.combo = 0
    rider.coins = 0

    time_left = 248.0
    clean_count = 0
    miss_count = 0
    tier = 1

    let (cpn, end_y) = generate_course(checkpoints, hazards, pickups)
    checkpoint_count = cpn
    course_end = end_y

    clear_particles(particles)

    msg = "Run started"
    msg_t = 2.2
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

    if rider.flash_t > 0.0 {
      rider.flash_t = rider.flash_t - dt
      if rider.flash_t < 0.0 {
        rider.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
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
      let mut pedal_d : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut brake_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut jump_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut boost_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)

      let pad_x : Int = 24
      let pad_y : Int = sh - 194
      let btn_x : Int = sw - 252
      let btn_y : Int = sh - 220

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 56, 74, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 154, pad_y + 56, 74, 56) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 77, pad_y, 74, 56) {
          pedal_d = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 77, pad_y + 112, 74, 56) {
          brake_d = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 8, 108, 84) {
          jump_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 116, btn_y + 8, 108, 84) {
          boost_press = true
        }
      }

      let steer : Int = if move_l && not(move_r) {
        -1
      } else if move_r && not(move_l) {
        1
      } else {
        0
      }

      let mut steer_acc : Float = 760.0
      if rider.air_t > 0.0 {
        steer_acc = 460.0
      }
      rider.vx = rider.vx + Float::from_int(steer) * steer_acc * dt

      let mut drag : Float = 3.0
      if rider.air_t > 0.0 {
        drag = 1.8
      }
      rider.vx = rider.vx * (Float::from_int(1) - dt * drag)

      let mut max_vx : Float = 290.0
      if rider.boost_t > 0.0 {
        max_vx = 410.0
      }
      rider.vx = clampf(rider.vx, -max_vx, max_vx)

      rider.x = rider.x + rider.vx * dt
      rider.x = clampf(rider.x, 30.0, world_w - 30.0)

      let mut base_speed : Float = 228.0 +
        rider.y / course_end * 128.0 +
        Float::from_int(tier - 1) * 11.0
      if pedal_d {
        base_speed = base_speed + 74.0
        rider.stamina = rider.stamina - dt * 18.0
      }
      if brake_d {
        base_speed = base_speed - 92.0
        rider.stamina = rider.stamina + dt * 8.0
      }
      if rider.boost_t > 0.0 {
        base_speed = base_speed + 190.0
      }
      if rider.hp < 90.0 {
        base_speed = base_speed - 34.0
      }
      if base_speed < 124.0 {
        base_speed = 124.0
      }
      rider.speed = base_speed

      rider.stamina = rider.stamina + dt * 15.0
      if rider.stamina > 100.0 {
        rider.stamina = 100.0
      }
      if rider.stamina < 0.0 {
        rider.stamina = 0.0
      }

      if jump_press && rider.air_t <= 0.0 && rider.stamina >= 18.0 {
        rider.air_t = 0.62
        rider.jump_peak = 0.62
        rider.trick_t = 0.0
        rider.stamina = rider.stamina - 18.0
        msg = "Bunny hop"
        msg_t = 0.5
        burst(particles, rider.x, rider.y - 8.0, 10, 0.20, 0)
      }

      if rider.air_t > 0.0 && steer != 0 {
        rider.trick_t = rider.trick_t + dt * 1.3
        if rider.boost_t > 0.0 {
          rider.trick_t = rider.trick_t + dt * 0.7
        }
        if rider.trick_t > 1.8 {
          rider.trick_t = 1.8
        }
      }

      if boost_press && rider.boost_cd <= 0.0 && rider.stamina >= 24.0 {
        rider.boost_t = 0.42
        rider.boost_cd = 1.5
        rider.stamina = rider.stamina - 24.0
        burst(particles, rider.x, rider.y, 16, 0.24, 1)
      }

      rider.y = rider.y + rider.speed * dt

      if rider.air_t <= 0.0 && rider.trick_t > 0.0 {
        if rider.trick_t >= 0.24 {
          let trick_pts = (rider.trick_t * 520.0).to_int() + rider.combo * 7
          rider.score = rider.score + trick_pts
          rider.combo = rider.combo + 1
          msg = "Trick +\{trick_pts}"
          msg_t = 0.8
          burst(particles, rider.x, rider.y, 14, 0.22, 1)
        }
        rider.trick_t = 0.0
      }

      for i in 0..<checkpoint_count {
        if not(checkpoints[i].active) {
          continue
        }

        checkpoints[i].pulse_t = checkpoints[i].pulse_t + dt

        if checkpoints[i].state == 0 && rider.y >= checkpoints[i].y {
          let dx = absf(rider.x - checkpoints[i].x)
          if dx <= checkpoints[i].width * 0.5 {
            checkpoints[i].state = 1
            clean_count = clean_count + 1
            rider.combo = rider.combo + 1
            rider.score = rider.score + 128 + rider.combo * 8
            rider.hp = rider.hp + 4.0
            if rider.hp > 230.0 {
              rider.hp = 230.0
            }
            msg = "Checkpoint clean"
            msg_t = 0.6
            burst(particles, checkpoints[i].x, checkpoints[i].y, 8, 0.18, 1)
          } else {
            checkpoints[i].state = 2
            miss_count = miss_count + 1
            rider.combo = 0
            rider.hp = rider.hp - 16.0
            rider.flash_t = 0.14
            msg = "Checkpoint missed"
            msg_t = 0.68
            burst(particles, checkpoints[i].x, checkpoints[i].y, 10, 0.24, 3)
          }

          if clean_count % 10 == 0 {
            tier = tier + 1
          }
        }
      }

      for hazard in hazards {
        if not(hazard.active) {
          continue
        }

        if hazard.y < rider.y - 130.0 {
          hazard.active = false
          continue
        }

        let touch_x = absf(hazard.x - rider.x)
        let touch_y = absf(hazard.y - rider.y)
        if touch_x <= hazard.size + 16.0 && touch_y <= hazard.size + 24.0 {
          let hit_dmg : Float = if hazard.kind == 1 {
            22.0
          } else if hazard.kind == 3 {
            18.0
          } else {
            14.0
          }
          rider.hp = rider.hp - hit_dmg
          rider.flash_t = 0.18

          let push : Float = if rider.x < hazard.x { -160.0 } else { 160.0 }
          rider.vx = rider.vx + push

          rider.combo = 0
          hazard.active = false
          msg = "Crash"
          msg_t = 0.7
          burst(particles, rider.x, rider.y, 14, 0.25, 3)
        }
      }

      for pickup in pickups {
        if not(pickup.active) {
          continue
        }

        pickup.t = pickup.t + dt

        if dist2(rider.x, rider.y, pickup.x, pickup.y) <= 28.0 * 28.0 {
          if pickup.kind == 0 {
            rider.hp = rider.hp + 28.0
            if rider.hp > 230.0 {
              rider.hp = 230.0
            }
            msg = "Repair kit"
          } else if pickup.kind == 1 {
            rider.stamina = rider.stamina + 30.0
            if rider.stamina > 100.0 {
              rider.stamina = 100.0
            }
            msg = "Energy drink"
          } else {
            rider.boost_cd = rider.boost_cd - 0.65
            if rider.boost_cd < 0.0 {
              rider.boost_cd = 0.0
            }
            rider.coins = rider.coins + 1
            rider.score = rider.score + 52
            msg = "Coin"
          }

          rider.score = rider.score + 24
          msg_t = 0.62
          pickup.active = false
          burst(particles, rider.x, rider.y, 10, 0.22, 0)
        }
      }

      for particle in particles {
        if not(particle.active) {
          continue
        }

        particle.t = particle.t + dt
        if particle.t >= particle.life {
          particle.active = false
        } else {
          particle.x = particle.x + particle.vx * dt
          particle.y = particle.y + particle.vy * dt
          particle.vx = particle.vx * (Float::from_int(1) - dt * 2.0)
          particle.vy = particle.vy + 280.0 * dt
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
        reset_run()
      }
    }

    let cam_y : Float = rider.y - rider_screen_y

    @raylib.begin_drawing()

    let mut sky_col = @raylib.Color::new(144, 196, 250, 255)
    if state == 2 {
      sky_col = @raylib.Color::new(148, 212, 188, 255)
    } else if state == 3 {
      sky_col = @raylib.Color::new(176, 146, 170, 255)
    }
    @raylib.clear_background(sky_col)

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(222, 236, 255, 172))

    let line_shift : Int = (cam_y / 36.0).to_int() % 2
    for idx in 0..<30 {
      let i = idx - 2
      let sy : Int = i * 36 - cam_y.to_int() % 36
      let stripe : Int = if (i + line_shift) % 2 == 0 { 236 } else { 226 }
      @raylib.draw_rectangle(
        0,
        sy,
        sw,
        36,
        @raylib.Color::new(stripe, stripe + 10, 255, 255),
      )
    }

    for i in 0..<24 {
      let ridge_x = i * 62 + (cam_y * 0.25).to_int() % 62
      @raylib.draw_rectangle(
        ridge_x,
        74,
        2,
        sh - 74,
        @raylib.Color::new(208, 226, 246, 170),
      )
    }

    for i in 0..<checkpoint_count {
      if not(checkpoints[i].active) {
        continue
      }

      let csy : Float = world_to_screen_y(checkpoints[i].y, rider.y)
      if csy < -90.0 || csy > Float::from_int(sh + 90) {
        continue
      }

      let left_x : Float = checkpoints[i].x - checkpoints[i].width * 0.5
      let right_x : Float = checkpoints[i].x + checkpoints[i].width * 0.5

      let mut pole_col = @raylib.Color::new(74, 106, 168, 255)
      let mut banner_col = @raylib.Color::new(86, 188, 246, 220)
      if checkpoints[i].state == 1 {
        pole_col = @raylib.Color::new(72, 162, 104, 255)
        banner_col = @raylib.Color::new(108, 232, 160, 220)
      } else if checkpoints[i].state == 2 {
        pole_col = @raylib.Color::new(178, 82, 104, 255)
        banner_col = @raylib.Color::new(236, 128, 144, 220)
      }

      @raylib.draw_rectangle(
        (left_x - 6.0).to_int(),
        (csy - 42.0).to_int(),
        12,
        84,
        pole_col,
      )
      @raylib.draw_rectangle(
        (right_x - 6.0).to_int(),
        (csy - 42.0).to_int(),
        12,
        84,
        pole_col,
      )
      @raylib.draw_rectangle(
        (left_x + 6.0).to_int(),
        (csy - 24.0).to_int(),
        (checkpoints[i].width - 12.0).to_int(),
        16,
        banner_col,
      )
    }

    for hazard in hazards {
      if not(hazard.active) {
        continue
      }

      let hsy : Float = world_to_screen_y(hazard.y, rider.y)
      if hsy < -80.0 || hsy > Float::from_int(sh + 80) {
        continue
      }

      if hazard.kind == 0 {
        @raylib.draw_circle(
          hazard.x.to_int(),
          hsy.to_int(),
          hazard.size,
          @raylib.Color::new(114, 128, 152, 255),
        )
      } else if hazard.kind == 1 {
        @raylib.draw_triangle(
          @raylib.Vector2::new(hazard.x, hsy - hazard.size),
          @raylib.Vector2::new(hazard.x - hazard.size, hsy + hazard.size),
          @raylib.Vector2::new(hazard.x + hazard.size, hsy + hazard.size),
          @raylib.Color::new(64, 130, 84, 255),
        )
      } else if hazard.kind == 2 {
        @raylib.draw_rectangle(
          (hazard.x - hazard.size).to_int(),
          (hsy - hazard.size).to_int(),
          (hazard.size * 2.0).to_int(),
          (hazard.size * 2.0).to_int(),
          @raylib.Color::new(168, 138, 104, 255),
        )
      } else {
        @raylib.draw_circle(
          hazard.x.to_int(),
          hsy.to_int(),
          hazard.size,
          @raylib.Color::new(86, 164, 196, 255),
        )
      }
    }

    for pickup in pickups {
      if not(pickup.active) {
        continue
      }

      let psy : Float = world_to_screen_y(pickup.y, rider.y)
      if psy < -70.0 || psy > Float::from_int(sh + 70) {
        continue
      }

      let blink : Int = if (pickup.t * 7.0).to_int() % 2 == 0 {
        255
      } else {
        180
      }
      let pcol = if pickup.kind == 0 {
        @raylib.Color::new(228, 126, 134, blink)
      } else if pickup.kind == 1 {
        @raylib.Color::new(124, 228, 166, blink)
      } else {
        @raylib.Color::new(130, 208, 252, blink)
      }
      @raylib.draw_circle(pickup.x.to_int(), psy.to_int(), 10.0, pcol)
      @raylib.draw_circle_lines(
        pickup.x.to_int(),
        psy.to_int(),
        16.0,
        @raylib.Color::new(246, 250, 255, blink),
      )
    }

    for particle in particles {
      if not(particle.active) {
        continue
      }

      let psy : Float = world_to_screen_y(particle.y, rider.y)
      let k = particle.t / particle.life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(118, 220, 252, a)
      if particle.kind == 1 {
        c = @raylib.Color::new(142, 248, 188, a)
      } else if particle.kind == 2 {
        c = @raylib.Color::new(252, 192, 106, a)
      } else if particle.kind == 3 {
        c = @raylib.Color::new(236, 96, 118, a)
      }
      @raylib.draw_circle(particle.x.to_int(), psy.to_int(), particle.size, c)
    }

    let rider_sy : Float = world_to_screen_y(rider.y, rider.y)

    let mut body_col = @raylib.Color::new(242, 176, 72, 255)
    if rider.flash_t > 0.0 {
      body_col = @raylib.Color::new(255, 240, 220, 255)
    }

    let mut jump_offset : Float = 0.0
    if rider.air_t > 0.0 {
      let k = rider.air_t / rider.jump_peak
      jump_offset = (Float::from_int(1) - k) * 80.0
      if jump_offset > 42.0 {
        jump_offset = 42.0
      }
    }

    @raylib.draw_rectangle(
      (rider.x - 26.0).to_int(),
      (rider_sy + 12.0 - jump_offset).to_int(),
      52,
      8,
      @raylib.Color::new(58, 78, 112, 255),
    )
    @raylib.draw_circle(
      (rider.x - 18.0).to_int(),
      (rider_sy + 16.0 - jump_offset).to_int(),
      8.0,
      @raylib.Color::new(44, 56, 78, 255),
    )
    @raylib.draw_circle(
      (rider.x + 18.0).to_int(),
      (rider_sy + 16.0 - jump_offset).to_int(),
      8.0,
      @raylib.Color::new(44, 56, 78, 255),
    )
    @raylib.draw_circle(
      rider.x.to_int(),
      (rider_sy - 2.0 - jump_offset).to_int(),
      13.0,
      body_col,
    )
    @raylib.draw_rectangle(
      (rider.x - 8.0).to_int(),
      (rider_sy + 4.0 - jump_offset).to_int(),
      16,
      12,
      @raylib.Color::new(28, 34, 48, 255),
    )

    if rider.air_t > 0.0 {
      @raylib.draw_circle_lines(
        rider.x.to_int(),
        (rider_sy - jump_offset).to_int(),
        24.0,
        @raylib.Color::new(132, 224, 252, 220),
      )
    }

    if rider.boost_t > 0.0 {
      @raylib.draw_rectangle(
        (rider.x - 30.0).to_int(),
        (rider_sy + 8.0 - jump_offset).to_int(),
        6,
        10,
        @raylib.Color::new(112, 214, 252, 255),
      )
      @raylib.draw_rectangle(
        (rider.x + 24.0).to_int(),
        (rider_sy + 8.0 - jump_offset).to_int(),
        6,
        10,
        @raylib.Color::new(112, 214, 252, 255),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 12, 22, 222))
    @raylib.draw_text(
      "MOUNTAIN BIKE DOWNHILL 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 244, 255, 255),
    )
    @raylib.draw_text(
      "A/D steer  W pedal  S brake  J jump  K boost",
      20,
      48,
      18,
      @raylib.Color::new(178, 204, 236, 255),
    )

    @raylib.draw_text(
      "Score \{rider.score}",
      500,
      16,
      28,
      @raylib.Color::new(246, 216, 118, 255),
    )
    @raylib.draw_text(
      "Combo \{rider.combo}",
      700,
      16,
      28,
      @raylib.Color::new(170, 238, 194, 255),
    )
    @raylib.draw_text(
      "Clean \{clean_count}/\{checkpoint_count}",
      880,
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
    let next_cp_dy : Float = nearest_checkpoint_dy(
      checkpoints,
      checkpoint_count,
      rider.y,
    )
    @raylib.draw_text(
      "Finish \{dist_left.to_int()}m",
      520,
      82,
      20,
      @raylib.Color::new(234, 238, 248, 255),
    )
    if next_cp_dy < 9000000.0 {
      @raylib.draw_text(
        "Next CP \{next_cp_dy.to_int()}m",
        700,
        82,
        20,
        @raylib.Color::new(196, 226, 248, 255),
      )
    }
    @raylib.draw_text(
      "Miss \{miss_count}",
      900,
      82,
      20,
      @raylib.Color::new(242, 162, 172, 255),
    )
    @raylib.draw_text(
      "Tier \{tier}",
      1020,
      82,
      20,
      @raylib.Color::new(250, 206, 132, 255),
    )
    @raylib.draw_text(
      "Coins \{rider.coins}",
      1120,
      82,
      20,
      @raylib.Color::new(246, 222, 150, 255),
    )

    @raylib.draw_rectangle(
      16,
      sh - 212,
      236,
      198,
      @raylib.Color::new(8, 12, 20, 208),
    )
    let lpx = 24
    let lpy = sh - 194
    @raylib.draw_rectangle(
      lpx,
      lpy + 56,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "L",
      lpx + 28,
      lpy + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      lpx + 154,
      lpy + 56,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "R",
      lpx + 182,
      lpy + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      lpx + 77,
      lpy,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "PED",
      lpx + 94,
      lpy + 16,
      22,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      lpx + 77,
      lpy + 112,
      74,
      56,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "BRK",
      lpx + 92,
      lpy + 128,
      20,
      @raylib.Color::new(214, 232, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 262,
      sh - 226,
      246,
      216,
      @raylib.Color::new(8, 12, 20, 208),
    )
    let rbx = sw - 252
    let rby = sh - 220
    @raylib.draw_rectangle(
      rbx,
      rby + 8,
      108,
      84,
      @raylib.Color::new(88, 156, 228, 255),
    )
    @raylib.draw_text(
      "JUMP",
      rbx + 16,
      rby + 40,
      26,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      rbx + 116,
      rby + 8,
      108,
      84,
      @raylib.Color::new(214, 112, 94, 255),
    )
    @raylib.draw_text(
      "BOOST",
      rbx + 128,
      rby + 40,
      24,
      @raylib.Color::new(252, 236, 228, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 330,
      sh - 54,
      660,
      40,
      @raylib.Color::new(8, 10, 16, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 312,
      sh - 44,
      24,
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 156 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 128))
      @raylib.draw_rectangle(
        sw / 2 - 440,
        sh / 2 - 190,
        880,
        380,
        @raylib.Color::new(14, 20, 32, 244),
      )
      @raylib.draw_text(
        "MOUNTAIN BIKE DOWNHILL",
        sw / 2 - 326,
        sh / 2 - 132,
        56,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Thread checkpoints, keep speed, and chain aerial tricks",
        sw / 2 - 346,
        sh / 2 - 30,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left controls steer/pedal/brake, right controls jump/boost",
        sw / 2 - 420,
        sh / 2 + 14,
        26,
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
        "RUN CLEARED",
        sw / 2 - 180,
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
        "Clean checkpoints: \{clean_count}/\{checkpoint_count}",
        sw / 2 - 276,
        sh / 2 + 18,
        32,
        @raylib.Color::new(170, 236, 198, 255),
      )
      @raylib.draw_text(
        "Misses: \{miss_count}  Coins: \{rider.coins}",
        sw / 2 - 198,
        sh / 2 + 58,
        32,
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
        sw / 2 - 170,
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
        "Clean checkpoints: \{clean_count}",
        sw / 2 - 210,
        sh / 2 + 18,
        32,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Time left: \{time_left.to_int()}s",
        sw / 2 - 186,
        sh / 2 + 58,
        32,
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
