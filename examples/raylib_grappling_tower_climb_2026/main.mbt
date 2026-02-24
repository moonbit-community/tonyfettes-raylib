///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let tower_l : Float = 342.0

///|
let tower_r : Float = 938.0

///|
let tower_w : Float = tower_r - tower_l

///|
let gravity : Float = 760.0

///|
let max_platforms : Int = 260

///|
let max_anchors : Int = 260

///|
let max_drones : Int = 140

///|
let max_bullets : Int = 560

///|
let max_crystals : Int = 200

///|
let max_particles : Int = 1000

///|
struct Pilot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut face : Int
  mut hp : Float
  mut energy : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut bomb_cd : Float
  mut inv_t : Float
  mut grapple_on : Bool
  mut gx : Float
  mut gy : Float
  mut gl : Float
  mut grounded : Bool
  mut coyote_t : Float
  mut jump_buf_t : Float
  mut flash_t : Float
  mut score : Int
  mut combo : Int
  mut best_h : Float
}

///|
struct Platform {
  mut active : Bool
  mut x : Float
  mut base_x : Float
  mut y : Float
  mut w : Float
  mut moving : Bool
  mut amp : Float
  mut speed : Float
  mut phase : Float
}

///|
struct Anchor {
  mut active : Bool
  mut x : Float
  mut y : Float
}

///|
struct Drone {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut base_y : Float
  mut vx : Float
  mut hp : Float
  mut fire_cd : Float
  mut stun_t : Float
  mut t : Float
}

///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut life : Float
  mut team : Int
}

///|
struct Crystal {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut value : Int
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
fn clear_platforms(platforms : Array[Platform]) -> Unit {
  for i = 0; i < platforms.length(); i = i + 1 {
    platforms[i].active = false
    platforms[i].x = 0.0
    platforms[i].base_x = 0.0
    platforms[i].y = 0.0
    platforms[i].w = 0.0
    platforms[i].moving = false
    platforms[i].amp = 0.0
    platforms[i].speed = 0.0
    platforms[i].phase = 0.0
  }
}

///|
fn clear_anchors(anchors : Array[Anchor]) -> Unit {
  for i = 0; i < anchors.length(); i = i + 1 {
    anchors[i].active = false
    anchors[i].x = 0.0
    anchors[i].y = 0.0
  }
}

///|
fn clear_drones(drones : Array[Drone]) -> Unit {
  for i = 0; i < drones.length(); i = i + 1 {
    drones[i].active = false
    drones[i].kind = 0
    drones[i].x = 0.0
    drones[i].y = 0.0
    drones[i].base_y = 0.0
    drones[i].vx = 0.0
    drones[i].hp = 0.0
    drones[i].fire_cd = 0.0
    drones[i].stun_t = 0.0
    drones[i].t = 0.0
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].active = false
    bullets[i].x = 0.0
    bullets[i].y = 0.0
    bullets[i].vx = 0.0
    bullets[i].vy = 0.0
    bullets[i].dmg = 0.0
    bullets[i].life = 0.0
    bullets[i].team = 0
  }
}

///|
fn clear_crystals(crystals : Array[Crystal]) -> Unit {
  for i = 0; i < crystals.length(); i = i + 1 {
    crystals[i].active = false
    crystals[i].x = 0.0
    crystals[i].y = 0.0
    crystals[i].value = 0
    crystals[i].t = 0.0
    crystals[i].life = 0.0
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
fn add_platform(
  platforms : Array[Platform],
  x : Float,
  y : Float,
  w : Float,
  moving : Bool,
  amp : Float,
  speed : Float,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < platforms.length(); i = i + 1 {
    if not(platforms[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    platforms[slot].active = true
    platforms[slot].x = x
    platforms[slot].base_x = x
    platforms[slot].y = y
    platforms[slot].w = w
    platforms[slot].moving = moving
    platforms[slot].amp = amp
    platforms[slot].speed = speed
    platforms[slot].phase = randf(0.0, 6.28)
    true
  }
}

///|
fn add_anchor(anchors : Array[Anchor], x : Float, y : Float) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < anchors.length(); i = i + 1 {
    if not(anchors[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    anchors[slot].active = true
    anchors[slot].x = x
    anchors[slot].y = y
    true
  }
}

///|
fn add_drone(
  drones : Array[Drone],
  x : Float,
  y : Float,
  kind : Int,
  level : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < drones.length(); i = i + 1 {
    if not(drones[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    drones[slot].active = true
    drones[slot].kind = kind
    drones[slot].x = x
    drones[slot].y = y
    drones[slot].base_y = y
    drones[slot].vx = 0.0
    drones[slot].hp = 32.0 +
      Float::from_int(kind) * 16.0 +
      Float::from_int(level) * 2.8
    drones[slot].fire_cd = randf(0.64, 1.44)
    drones[slot].stun_t = 0.0
    drones[slot].t = randf(0.0, 5.0)
    true
  }
}

///|
fn add_bullet(
  bullets : Array[Bullet],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  life : Float,
  team : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < bullets.length(); i = i + 1 {
    if not(bullets[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    bullets[slot].active = true
    bullets[slot].x = x
    bullets[slot].y = y
    bullets[slot].vx = vx
    bullets[slot].vy = vy
    bullets[slot].dmg = dmg
    bullets[slot].life = life
    bullets[slot].team = team
    true
  }
}

///|
fn add_crystal(
  crystals : Array[Crystal],
  x : Float,
  y : Float,
  value : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < crystals.length(); i = i + 1 {
    if not(crystals[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    crystals[slot].active = true
    crystals[slot].x = x
    crystals[slot].y = y
    crystals[slot].value = value
    crystals[slot].t = 0.0
    crystals[slot].life = randf(8.0, 18.0)
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
      parts[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(18, 74)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn generate_layer(
  platforms : Array[Platform],
  anchors : Array[Anchor],
  crystals : Array[Crystal],
  drones : Array[Drone],
  y : Float,
  level : Int,
) -> Unit {
  let px = randf(tower_l + 90.0, tower_r - 90.0)
  let w = randf(142.0, 246.0)
  let moving = @raylib.get_random_value(0, 99) <
    clampf(16.0 + Float::from_int(level) * 2.4, 16.0, 52.0).to_int()
  let amp = if moving { randf(24.0, 96.0) } else { 0.0 }
  let speed = if moving { randf(0.8, 1.9) } else { 0.0 }
  ignore(add_platform(platforms, px, y, w, moving, amp, speed))

  ignore(
    add_anchor(anchors, px + randf(-w * 0.22, w * 0.22), y - randf(86.0, 132.0)),
  )

  if @raylib.get_random_value(0, 99) < 62 {
    ignore(
      add_crystal(
        crystals,
        px + randf(-w * 0.28, w * 0.28),
        y - 36.0,
        @raylib.get_random_value(20, 64),
      ),
    )
  }

  if @raylib.get_random_value(0, 99) <
    clampf(14.0 + Float::from_int(level) * 1.6, 14.0, 66.0).to_int() {
    let kind = @raylib.get_random_value(0, 2)
    ignore(
      add_drone(
        drones,
        px + randf(-w * 0.24, w * 0.24),
        y - randf(72.0, 148.0),
        kind,
        level,
      ),
    )
  }

  if @raylib.get_random_value(0, 99) < 42 {
    let side_x = if @raylib.get_random_value(0, 1) == 0 {
      tower_l + randf(52.0, 140.0)
    } else {
      tower_r - randf(52.0, 140.0)
    }

    ignore(
      add_platform(
        platforms,
        side_x,
        y - randf(58.0, 96.0),
        randf(94.0, 142.0),
        false,
        0.0,
        0.0,
      ),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Grappling Tower Climb 2026")
  @raylib.set_target_fps(60)

  let pilot : Pilot = {
    x: (tower_l + tower_r) * 0.5,
    y: 110.0,
    vx: 0.0,
    vy: 0.0,
    face: 1,
    hp: 120.0,
    energy: 100.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    bomb_cd: 0.0,
    inv_t: 0.0,
    grapple_on: false,
    gx: 0.0,
    gy: 0.0,
    gl: 0.0,
    grounded: false,
    coyote_t: 0.0,
    jump_buf_t: 0.0,
    flash_t: 0.0,
    score: 0,
    combo: 0,
    best_h: 0.0,
  }

  let platforms : Array[Platform] = Array::makei(max_platforms, fn(_i) {
    {
      active: false,
      x: 0.0,
      base_x: 0.0,
      y: 0.0,
      w: 0.0,
      moving: false,
      amp: 0.0,
      speed: 0.0,
      phase: 0.0,
    }
  })

  let anchors : Array[Anchor] = Array::makei(max_anchors, fn(_i) {
    { active: false, x: 0.0, y: 0.0 }
  })

  let drones : Array[Drone] = Array::makei(max_drones, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      base_y: 0.0,
      vx: 0.0,
      hp: 0.0,
      fire_cd: 0.0,
      stun_t: 0.0,
      t: 0.0,
    }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0.0,
      life: 0.0,
      team: 0,
    }
  })

  let crystals : Array[Crystal] = Array::makei(max_crystals, fn(_i) {
    { active: false, x: 0.0, y: 0.0, value: 0, t: 0.0, life: 0.0 }
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

  let mut cam_y : Float = -310.0
  let mut gen_top_y : Float = 140.0
  let mut target_h : Float = 3200.0
  let mut time_left : Float = 260.0
  let mut spawn_cd : Float = 0.84

  let mut msg : String = "Use grappling hook to climb"
  let mut msg_t : Float = 3.0

  let reset_run = fn() {
    pilot.x = (tower_l + tower_r) * 0.5
    pilot.y = 110.0
    pilot.vx = 0.0
    pilot.vy = 0.0
    pilot.face = 1

    pilot.hp = 120.0
    pilot.energy = 100.0
    pilot.dash_t = 0.0
    pilot.dash_cd = 0.0
    pilot.bomb_cd = 0.0
    pilot.inv_t = 0.0
    pilot.grapple_on = false
    pilot.gx = 0.0
    pilot.gy = 0.0
    pilot.gl = 0.0
    pilot.grounded = false
    pilot.coyote_t = 0.0
    pilot.jump_buf_t = 0.0
    pilot.flash_t = 0.0

    pilot.score = 0
    pilot.combo = 0
    pilot.best_h = 0.0

    target_h = 3200.0
    time_left = 260.0
    spawn_cd = 0.84

    clear_platforms(platforms)
    clear_anchors(anchors)
    clear_drones(drones)
    clear_bullets(bullets)
    clear_crystals(crystals)
    clear_particles(particles)

    ignore(
      add_platform(
        platforms,
        (tower_l + tower_r) * 0.5,
        140.0,
        360.0,
        false,
        0.0,
        0.0,
      ),
    )
    ignore(add_anchor(anchors, (tower_l + tower_r) * 0.5, 58.0))

    gen_top_y = 140.0
    for i = 0; i < 26; i = i + 1 {
      ignore(i)
      gen_top_y = gen_top_y - randf(92.0, 132.0)
      generate_layer(platforms, anchors, crystals, drones, gen_top_y, 1)
    }

    cam_y = pilot.y - 420.0

    msg = "Climb to 3200m"
    msg_t = 2.0
  }

  let on_hit = fn(dmg : Float, text : String) {
    if pilot.inv_t > 0.0 {
      ignore(())
    } else {
      pilot.hp = pilot.hp - dmg
      pilot.inv_t = 0.46
      pilot.flash_t = 0.24
      pilot.combo = 0
      msg = text
      msg_t = 0.62
      burst(particles, pilot.x, pilot.y, 16, 0.18, 3)
    }
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

    if pilot.inv_t > 0.0 {
      pilot.inv_t = pilot.inv_t - dt
      if pilot.inv_t < 0.0 {
        pilot.inv_t = 0.0
      }
    }

    if pilot.flash_t > 0.0 {
      pilot.flash_t = pilot.flash_t - dt
      if pilot.flash_t < 0.0 {
        pilot.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      time_left = time_left - dt

      let height_now = -pilot.y
      if height_now > pilot.best_h {
        pilot.best_h = height_now
      }

      let level : Int = pilot.best_h.to_int() / 380 + 1

      pilot.energy = pilot.energy + dt * 15.0
      if pilot.energy > 100.0 {
        pilot.energy = 100.0
      }

      pilot.dash_t = pilot.dash_t - dt
      if pilot.dash_t < 0.0 {
        pilot.dash_t = 0.0
      }
      pilot.dash_cd = pilot.dash_cd - dt
      if pilot.dash_cd < 0.0 {
        pilot.dash_cd = 0.0
      }
      pilot.bomb_cd = pilot.bomb_cd - dt
      if pilot.bomb_cd < 0.0 {
        pilot.bomb_cd = 0.0
      }

      pilot.coyote_t = pilot.coyote_t - dt
      if pilot.coyote_t < 0.0 {
        pilot.coyote_t = 0.0
      }
      pilot.jump_buf_t = pilot.jump_buf_t - dt
      if pilot.jump_buf_t < 0.0 {
        pilot.jump_buf_t = 0.0
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u_hold : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d_hold : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut jump_press : Bool = @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut grapple_hold : Bool = @raylib.is_key_down(@raylib.KeyJ)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut bomb_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_x : Int = 20
      let pad_y : Int = sh - 198
      let btn_x : Int = sw - 296
      let btn_y : Int = sh - 236

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 58, 78, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 58, 78, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          move_u_hold = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 116, 78, 58) {
          move_d_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 74, btn_y + 116, 150, 100) {
          grapple_hold = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          jump_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 8, btn_y + 10, 120, 92) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 136, btn_y + 10, 120, 92) {
          bomb_press = true
        }
      }

      if jump_press {
        pilot.jump_buf_t = 0.15
      }

      if move_l {
        pilot.face = -1
      }
      if move_r {
        pilot.face = 1
      }

      // Update moving platforms.
      for i = 0; i < platforms.length(); i = i + 1 {
        if not(platforms[i].active) {
          continue
        }

        if platforms[i].moving {
          platforms[i].phase = platforms[i].phase + dt * platforms[i].speed
          platforms[i].x = platforms[i].base_x +
            @math.sinf(platforms[i].phase) * platforms[i].amp
          platforms[i].x = clampf(
            platforms[i].x,
            tower_l + platforms[i].w * 0.5 + 8.0,
            tower_r - platforms[i].w * 0.5 - 8.0,
          )
        }

        if platforms[i].y - cam_y > Float::from_int(sh) + 240.0 {
          platforms[i].active = false
        }
      }

      // Find grapple target or apply rope.
      if grapple_hold {
        if not(pilot.grapple_on) {
          let mut best_i : Int = -1
          let mut best_d2 : Float = 99999999.0
          for i = 0; i < anchors.length(); i = i + 1 {
            if anchors[i].active {
              let d2 = dist2(pilot.x, pilot.y, anchors[i].x, anchors[i].y)
              if d2 <= 290.0 * 290.0 && d2 < best_d2 {
                best_d2 = d2
                best_i = i
              }
            }
          }

          if best_i >= 0 {
            pilot.grapple_on = true
            pilot.gx = anchors[best_i].x
            pilot.gy = anchors[best_i].y
            pilot.gl = clampf(best_d2.sqrt() * 0.78, 84.0, 232.0)
            burst(particles, pilot.gx, pilot.gy, 6, 0.10, 2)
          }
        }
      } else {
        pilot.grapple_on = false
      }

      let mut ax : Float = 0.0
      if move_l {
        ax = ax - 520.0
      }
      if move_r {
        ax = ax + 520.0
      }

      if pilot.dash_t > 0.0 {
        ax = ax * 0.42
      }

      pilot.vx = pilot.vx + ax * dt

      if pilot.grapple_on {
        let dx = pilot.gx - pilot.x
        let dy = pilot.gy - pilot.y
        let d2 = dx * dx + dy * dy
        if d2 > 0.01 {
          let d = d2.sqrt()
          let nx = dx / d
          let ny = dy / d
          let stretch = d - pilot.gl
          if stretch > 0.0 {
            let tforce = stretch * 8.8
            pilot.vx = pilot.vx + nx * tforce * dt
            pilot.vy = pilot.vy + ny * tforce * dt
          }
        }

        pilot.vy = pilot.vy + gravity * 0.56 * dt
      } else {
        pilot.vy = pilot.vy + gravity * dt
      }

      if pilot.jump_buf_t > 0.0 && pilot.coyote_t > 0.0 {
        pilot.vy = -432.0
        pilot.grounded = false
        pilot.coyote_t = 0.0
        pilot.jump_buf_t = 0.0
        pilot.grapple_on = false
        burst(particles, pilot.x, pilot.y + 10.0, 10, 0.12, 0)
      }

      if pilot.grounded && move_u_hold {
        // small hop assist for touch up-hold
        pilot.vy = -360.0
        pilot.grounded = false
        pilot.coyote_t = 0.0
      }

      if dash_press && pilot.dash_cd <= 0.0 && pilot.energy >= 18.0 {
        let mut dir_x : Float = Float::from_int(pilot.face)
        let mut dir_y : Float = 0.0

        if move_u_hold {
          dir_y = dir_y - 0.8
        }
        if move_d_hold {
          dir_y = dir_y + 0.8
        }

        let l2 = dir_x * dir_x + dir_y * dir_y
        if l2 > 0.01 {
          let inv : Float = 1.0 / l2.sqrt()
          dir_x = dir_x * inv
          dir_y = dir_y * inv
        }

        pilot.vx = dir_x * 560.0
        pilot.vy = dir_y * 560.0
        pilot.dash_t = 0.20
        pilot.dash_cd = 1.28
        pilot.energy = pilot.energy - 18.0
        pilot.inv_t = 0.18
        pilot.grapple_on = false
        burst(particles, pilot.x, pilot.y, 18, 0.18, 2)
      }

      if bomb_press && pilot.bomb_cd <= 0.0 && pilot.energy >= 28.0 {
        pilot.bomb_cd = 4.8
        pilot.energy = pilot.energy - 28.0
        msg = "Shock pulse"
        msg_t = 0.72

        for i = 0; i < drones.length(); i = i + 1 {
          if drones[i].active &&
            dist2(pilot.x, pilot.y, drones[i].x, drones[i].y) <= 190.0 * 190.0 {
            drones[i].hp = drones[i].hp - (36.0 + Float::from_int(level) * 1.2)
            drones[i].stun_t = 1.0
            if drones[i].hp <= 0.0 {
              let dx = drones[i].x
              let dy = drones[i].y
              drones[i].active = false
              pilot.score = pilot.score + 88 + pilot.combo * 4
              pilot.combo = pilot.combo + 1
              if @raylib.get_random_value(0, 99) < 56 {
                ignore(
                  add_crystal(
                    crystals,
                    dx,
                    dy,
                    @raylib.get_random_value(22, 72),
                  ),
                )
              }
              burst(particles, dx, dy, 12, 0.18, 1)
            }
          }
        }

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            bullets[i].team == 2 &&
            dist2(pilot.x, pilot.y, bullets[i].x, bullets[i].y) <= 210.0 * 210.0 {
            bullets[i].active = false
          }
        }

        burst(particles, pilot.x, pilot.y, 30, 0.20, 2)
      }

      let drag : Float = if pilot.dash_t > 0.0 { 1.4 } else { 2.5 }
      pilot.vx = pilot.vx * (1.0 - dt * drag)
      pilot.vy = pilot.vy *
        (1.0 - dt * (if pilot.grapple_on { 0.14 } else { 0.04 }))

      pilot.vy = clampf(pilot.vy, -620.0, 620.0)

      let prev_y = pilot.y
      pilot.x = pilot.x + pilot.vx * dt
      pilot.y = pilot.y + pilot.vy * dt

      if pilot.x < tower_l + 18.0 {
        pilot.x = tower_l + 18.0
        pilot.vx = absf(pilot.vx) * 0.24
      }
      if pilot.x > tower_r - 18.0 {
        pilot.x = tower_r - 18.0
        pilot.vx = -absf(pilot.vx) * 0.24
      }

      pilot.grounded = false
      for i = 0; i < platforms.length(); i = i + 1 {
        if not(platforms[i].active) {
          continue
        }

        if pilot.vy >= 0.0 &&
          prev_y + 20.0 <= platforms[i].y &&
          pilot.y + 20.0 >= platforms[i].y {
          let half = platforms[i].w * 0.5
          if pilot.x >= platforms[i].x - half - 16.0 &&
            pilot.x <= platforms[i].x + half + 16.0 {
            pilot.y = platforms[i].y - 20.0
            pilot.vy = 0.0
            pilot.grounded = true
            pilot.coyote_t = 0.12
            break
          }
        }
      }

      if not(pilot.grounded) {
        // coyote timer decays elsewhere; keep as-is
        ignore(())
      }

      if pilot.dash_t > 0.0 {
        for i = 0; i < drones.length(); i = i + 1 {
          if drones[i].active &&
            dist2(pilot.x, pilot.y, drones[i].x, drones[i].y) <= 30.0 * 30.0 {
            let dx = drones[i].x
            let dy = drones[i].y
            drones[i].active = false
            pilot.score = pilot.score + 64 + pilot.combo * 3
            pilot.combo = pilot.combo + 1
            pilot.vx = pilot.vx * 0.78
            pilot.vy = pilot.vy * 0.78
            if @raylib.get_random_value(0, 99) < 46 {
              ignore(
                add_crystal(crystals, dx, dy, @raylib.get_random_value(20, 60)),
              )
            }
            burst(particles, dx, dy, 12, 0.18, 1)
          }
        }
      }

      if pilot.y > cam_y + Float::from_int(sh) + 180.0 {
        on_hit(999.0, "You fell")
      }

      // Spawn / update drones.
      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        if @raylib.get_random_value(0, 99) <
          clampf(24.0 + Float::from_int(level) * 2.0, 24.0, 82.0).to_int() {
          let sy = pilot.y - randf(360.0, 760.0)
          let sx = randf(tower_l + 60.0, tower_r - 60.0)
          ignore(
            add_drone(drones, sx, sy, @raylib.get_random_value(0, 2), level),
          )
        }
        spawn_cd = randf(0.64, 1.32)
      }

      for i = 0; i < drones.length(); i = i + 1 {
        if not(drones[i].active) {
          continue
        }

        drones[i].t = drones[i].t + dt
        drones[i].fire_cd = drones[i].fire_cd - dt
        drones[i].stun_t = drones[i].stun_t - dt
        if drones[i].fire_cd < 0.0 {
          drones[i].fire_cd = 0.0
        }
        if drones[i].stun_t < 0.0 {
          drones[i].stun_t = 0.0
        }

        let dx = pilot.x - drones[i].x
        let mut chase : Float = 0.0
        if dx < -6.0 {
          chase = -1.0
        } else if dx > 6.0 {
          chase = 1.0
        }

        if drones[i].stun_t <= 0.0 {
          let accel : Float = 140.0 +
            Float::from_int(drones[i].kind) * 34.0 +
            Float::from_int(level) * 3.2
          drones[i].vx = drones[i].vx + chase * accel * dt
        }

        drones[i].vx = drones[i].vx * (1.0 - dt * 2.6)
        drones[i].vx = clampf(drones[i].vx, -220.0, 220.0)

        drones[i].x = drones[i].x + drones[i].vx * dt
        drones[i].base_y = drones[i].base_y +
          clampf(pilot.y - 120.0 - drones[i].base_y, -120.0, 120.0) * dt * 0.07
        drones[i].y = drones[i].base_y +
          @math.sinf(
            drones[i].t * (1.3 + Float::from_int(drones[i].kind) * 0.3),
          ) *
          (14.0 + Float::from_int(drones[i].kind) * 6.0)

        drones[i].x = clampf(drones[i].x, tower_l + 24.0, tower_r - 24.0)

        if drones[i].fire_cd <= 0.0 &&
          dist2(drones[i].x, drones[i].y, pilot.x, pilot.y) <= 380.0 * 380.0 {
          drones[i].fire_cd = randf(0.78, 1.66)
          let tx = pilot.x - drones[i].x
          let ty = pilot.y - drones[i].y
          let mut inv : Float = 0.0
          let l2 = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }
          let bspd : Float = 220.0 +
            Float::from_int(drones[i].kind) * 38.0 +
            Float::from_int(level) * 2.0
          ignore(
            add_bullet(
              bullets,
              drones[i].x,
              drones[i].y,
              tx * inv * bspd,
              ty * inv * bspd,
              9.0 + Float::from_int(drones[i].kind) * 2.4,
              2.7,
              2,
            ),
          )
        }

        if dist2(drones[i].x, drones[i].y, pilot.x, pilot.y) <= 24.0 * 24.0 {
          on_hit(8.0 + Float::from_int(drones[i].kind) * 2.0, "Drone collision")
          drones[i].stun_t = 0.54
          drones[i].vx = -drones[i].vx
        }

        if drones[i].y - cam_y > Float::from_int(sh) + 260.0 {
          drones[i].active = false
        }
      }

      // Bullets.
      for i = 0; i < bullets.length(); i = i + 1 {
        if not(bullets[i].active) {
          continue
        }

        bullets[i].life = bullets[i].life - dt
        if bullets[i].life <= 0.0 {
          bullets[i].active = false
          continue
        }

        bullets[i].x = bullets[i].x + bullets[i].vx * dt
        bullets[i].y = bullets[i].y + bullets[i].vy * dt

        if bullets[i].x < tower_l - 30.0 ||
          bullets[i].x > tower_r + 30.0 ||
          bullets[i].y < pilot.y - 1200.0 ||
          bullets[i].y > pilot.y + 1200.0 {
          bullets[i].active = false
          continue
        }

        if bullets[i].team == 2 {
          if pilot.dash_t > 0.0 &&
            dist2(bullets[i].x, bullets[i].y, pilot.x, pilot.y) <= 20.0 * 20.0 {
            bullets[i].active = false
            pilot.score = pilot.score + 2
            burst(particles, bullets[i].x, bullets[i].y, 4, 0.08, 2)
          } else if dist2(bullets[i].x, bullets[i].y, pilot.x, pilot.y) <=
            16.0 * 16.0 {
            bullets[i].active = false
            on_hit(bullets[i].dmg, "Laser hit")
          }
        }
      }

      // Crystals.
      for i = 0; i < crystals.length(); i = i + 1 {
        if not(crystals[i].active) {
          continue
        }

        crystals[i].t = crystals[i].t + dt
        if crystals[i].t >= crystals[i].life {
          crystals[i].active = false
          continue
        }

        if dist2(crystals[i].x, crystals[i].y, pilot.x, pilot.y) <= 24.0 * 24.0 {
          pilot.score = pilot.score + crystals[i].value
          pilot.energy = clampf(
            pilot.energy + Float::from_int(crystals[i].value) * 0.24,
            0.0,
            100.0,
          )
          pilot.combo = pilot.combo + 1
          msg = "Crystal +\{crystals[i].value}"
          msg_t = 0.44
          burst(particles, crystals[i].x, crystals[i].y, 8, 0.11, 2)
          crystals[i].active = false
        }

        if crystals[i].y - cam_y > Float::from_int(sh) + 240.0 {
          crystals[i].active = false
        }
      }

      // Particles.
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
          particles[i].vx = particles[i].vx * (1.0 - dt * 2.0)
          particles[i].vy = particles[i].vy + 220.0 * dt
        }
      }

      // Cleanup / generation.
      for i = 0; i < anchors.length(); i = i + 1 {
        if anchors[i].active &&
          anchors[i].y - cam_y > Float::from_int(sh) + 240.0 {
          anchors[i].active = false
        }
      }

      while pilot.y - 1400.0 < gen_top_y {
        gen_top_y = gen_top_y - randf(92.0, 132.0)
        generate_layer(platforms, anchors, crystals, drones, gen_top_y, level)
      }

      if pilot.best_h >= target_h {
        state = 2
      } else if pilot.hp <= 0.0 || time_left <= 0.0 {
        state = 3
      }

      let target_cam = pilot.y - 420.0
      cam_y = cam_y + (target_cam - cam_y) * dt * 4.6
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

    let bg_col = if state == 2 {
      @raylib.Color::new(12, 24, 24, 255)
    } else if state == 3 {
      @raylib.Color::new(28, 14, 20, 255)
    } else {
      @raylib.Color::new(12, 18, 32, 255)
    }
    @raylib.clear_background(bg_col)

    // Parallax skyline.
    for i = 0; i < 24; i = i + 1 {
      let x = i * 56
      let h = 80 + i * 17 % 220
      let y0 = sh - h - ((cam_y * 0.08).to_int() + i * 12) % 44
      @raylib.draw_rectangle(
        x,
        y0,
        42,
        h + 60,
        @raylib.Color::new(22, 30, 52, 255),
      )
      @raylib.draw_rectangle(
        x + 12,
        y0 + 12,
        8,
        12,
        @raylib.Color::new(90, 162, 244, 120),
      )
    }

    // Tower walls.
    @raylib.draw_rectangle(
      (tower_l - 24.0).to_int(),
      0,
      24,
      sh,
      @raylib.Color::new(44, 52, 70, 255),
    )
    @raylib.draw_rectangle(
      tower_r.to_int(),
      0,
      24,
      sh,
      @raylib.Color::new(44, 52, 70, 255),
    )

    for i = 0; i < 18; i = i + 1 {
      let wy = i * 44 + (cam_y * 0.30).to_int() % 44
      @raylib.draw_rectangle(
        (tower_l - 18.0).to_int(),
        wy,
        10,
        12,
        @raylib.Color::new(108, 152, 214, 120),
      )
      @raylib.draw_rectangle(
        (tower_r + 8.0).to_int(),
        wy,
        10,
        12,
        @raylib.Color::new(108, 152, 214, 120),
      )
    }

    @raylib.draw_rectangle(
      tower_l.to_int(),
      0,
      tower_w.to_int(),
      sh,
      @raylib.Color::new(24, 32, 46, 255),
    )

    for i = 0; i < 16; i = i + 1 {
      let gx = tower_l.to_int() + i * 38
      @raylib.draw_line(gx, 0, gx, sh, @raylib.Color::new(38, 50, 70, 80))
    }

    // Platforms.
    for i = 0; i < platforms.length(); i = i + 1 {
      if not(platforms[i].active) {
        continue
      }

      let sy = platforms[i].y - cam_y
      if sy < -80.0 || sy > Float::from_int(sh) + 80.0 {
        continue
      }

      let px = (platforms[i].x - platforms[i].w * 0.5).to_int()
      let py = sy.to_int()
      @raylib.draw_rectangle(
        px,
        py,
        platforms[i].w.to_int(),
        14,
        @raylib.Color::new(108, 130, 156, 255),
      )
      @raylib.draw_rectangle(
        px + 10,
        py + 4,
        platforms[i].w.to_int() - 20,
        8,
        @raylib.Color::new(150, 176, 206, 190),
      )
    }

    // Anchors.
    for i = 0; i < anchors.length(); i = i + 1 {
      if anchors[i].active {
        let sy = anchors[i].y - cam_y
        if sy >= -40.0 && sy <= Float::from_int(sh) + 40.0 {
          @raylib.draw_circle(
            anchors[i].x.to_int(),
            sy.to_int(),
            8.0,
            @raylib.Color::new(126, 230, 210, 255),
          )
          @raylib.draw_circle_lines(
            anchors[i].x.to_int(),
            sy.to_int(),
            12.0,
            @raylib.Color::new(80, 180, 168, 255),
          )
        }
      }
    }

    // Crystals.
    for i = 0; i < crystals.length(); i = i + 1 {
      if crystals[i].active {
        let sy = crystals[i].y - cam_y
        if sy >= -36.0 && sy <= Float::from_int(sh) + 36.0 {
          let blink = (crystals[i].t * 8.0).to_int() % 2 == 0
          let col = if blink {
            @raylib.Color::new(146, 246, 202, 255)
          } else {
            @raylib.Color::new(112, 216, 176, 220)
          }
          @raylib.draw_triangle(
            @raylib.Vector2::new(crystals[i].x, sy - 10.0),
            @raylib.Vector2::new(crystals[i].x - 8.0, sy + 4.0),
            @raylib.Vector2::new(crystals[i].x + 8.0, sy + 4.0),
            col,
          )
          @raylib.draw_triangle(
            @raylib.Vector2::new(crystals[i].x, sy + 12.0),
            @raylib.Vector2::new(crystals[i].x - 8.0, sy + 4.0),
            @raylib.Vector2::new(crystals[i].x + 8.0, sy + 4.0),
            @raylib.Color::new(98, 194, 158, 220),
          )
        }
      }
    }

    // Drones.
    for i = 0; i < drones.length(); i = i + 1 {
      if drones[i].active {
        let sy = drones[i].y - cam_y
        if sy >= -40.0 && sy <= Float::from_int(sh) + 40.0 {
          let body_col = if drones[i].kind == 0 {
            @raylib.Color::new(226, 132, 126, 255)
          } else if drones[i].kind == 1 {
            @raylib.Color::new(214, 98, 142, 255)
          } else {
            @raylib.Color::new(180, 86, 160, 255)
          }

          @raylib.draw_circle(drones[i].x.to_int(), sy.to_int(), 14.0, body_col)
          @raylib.draw_circle(
            drones[i].x.to_int(),
            sy.to_int(),
            6.0,
            @raylib.Color::new(252, 236, 210, 255),
          )

          if drones[i].stun_t > 0.0 {
            @raylib.draw_circle_lines(
              drones[i].x.to_int(),
              sy.to_int(),
              18.0,
              @raylib.Color::new(134, 228, 255, 255),
            )
          }
        }
      }
    }

    // Bullets.
    for i = 0; i < bullets.length(); i = i + 1 {
      if bullets[i].active {
        let sy = bullets[i].y - cam_y
        if sy >= -20.0 && sy <= Float::from_int(sh) + 20.0 {
          if bullets[i].team == 2 {
            @raylib.draw_circle(
              bullets[i].x.to_int(),
              sy.to_int(),
              4.6,
              @raylib.Color::new(252, 132, 128, 255),
            )
          } else {
            @raylib.draw_circle(
              bullets[i].x.to_int(),
              sy.to_int(),
              4.2,
              @raylib.Color::new(124, 226, 252, 255),
            )
          }
        }
      }
    }

    // Grapple rope.
    if pilot.grapple_on {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(pilot.x, pilot.y - cam_y),
        @raylib.Vector2::new(pilot.gx, pilot.gy - cam_y),
        3.0,
        @raylib.Color::new(148, 236, 214, 220),
      )
    }

    // Pilot.
    let pilot_col = if pilot.flash_t > 0.0 {
      @raylib.Color::new(252, 146, 148, 255)
    } else {
      @raylib.Color::new(126, 214, 252, 255)
    }
    let psy = pilot.y - cam_y
    @raylib.draw_circle(pilot.x.to_int(), psy.to_int(), 14.0, pilot_col)
    @raylib.draw_circle(
      pilot.x.to_int(),
      (psy - 16.0).to_int(),
      10.0,
      @raylib.Color::new(246, 226, 190, 255),
    )
    @raylib.draw_rectangle(
      (pilot.x - 5.0 + Float::from_int(pilot.face * 8)).to_int(),
      (psy - 4.0).to_int(),
      10,
      8,
      @raylib.Color::new(236, 246, 255, 255),
    )

    // Particles.
    for i = 0; i < particles.length(); i = i + 1 {
      if particles[i].active {
        let sy = particles[i].y - cam_y
        if sy < -40.0 || sy > Float::from_int(sh) + 40.0 {
          continue
        }

        let ratio : Float = 1.0 - particles[i].t / particles[i].life
        let alpha = (ratio * 255.0).to_int()
        if alpha <= 0 {
          continue
        }

        let col = if particles[i].kind == 0 {
          @raylib.Color::new(154, 236, 252, alpha)
        } else if particles[i].kind == 1 {
          @raylib.Color::new(252, 172, 142, alpha)
        } else if particles[i].kind == 2 {
          @raylib.Color::new(150, 244, 202, alpha)
        } else {
          @raylib.Color::new(252, 124, 144, alpha)
        }

        @raylib.draw_circle(
          particles[i].x.to_int(),
          sy.to_int(),
          particles[i].size,
          col,
        )
      }
    }

    // HUD.
    @raylib.draw_rectangle(0, 0, sw, 76, @raylib.Color::new(8, 10, 20, 228))
    @raylib.draw_text(
      "GRAPPLING TOWER CLIMB 2026",
      16,
      12,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  W/SPACE jump  J grapple  K dash  L bomb",
      16,
      48,
      18,
      @raylib.Color::new(176, 208, 236, 255),
    )

    @raylib.draw_text(
      "Score \{pilot.score}",
      620,
      14,
      30,
      @raylib.Color::new(248, 216, 126, 255),
    )
    @raylib.draw_text(
      "Height \{pilot.best_h.to_int()}/\{target_h.to_int()}m",
      812,
      14,
      30,
      @raylib.Color::new(164, 236, 202, 255),
    )
    @raylib.draw_text(
      "Time \{time_left.to_int()}s",
      1092,
      14,
      30,
      @raylib.Color::new(246, 188, 132, 255),
    )

    @raylib.draw_rectangle(16, 84, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      16,
      84,
      (pilot.hp / 120.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(112, 224, 160, 255),
    )
    @raylib.draw_text("HP", 16, 98, 16, @raylib.Color::new(186, 210, 232, 255))

    @raylib.draw_rectangle(
      252,
      84,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      252,
      84,
      (pilot.energy / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(118, 198, 248, 255),
    )
    @raylib.draw_text(
      "ENERGY",
      252,
      98,
      16,
      @raylib.Color::new(186, 210, 232, 255),
    )

    @raylib.draw_text(
      "Combo \{pilot.combo}",
      500,
      84,
      20,
      @raylib.Color::new(252, 224, 162, 255),
    )
    @raylib.draw_text(
      "Dash \{pilot.dash_cd.to_int()}  Bomb \{pilot.bomb_cd.to_int()}",
      620,
      84,
      20,
      @raylib.Color::new(206, 190, 162, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 330,
      sh - 52,
      660,
      38,
      @raylib.Color::new(8, 12, 18, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 310,
      sh - 44,
      24,
      @raylib.Color::new(236, 244, 255, if msg_t > 0.0 { 255 } else { 148 }),
    )

    // Touch controls.
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
      "U",
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
      "D",
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
      @raylib.Color::new(214, 118, 102, 255),
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
      "BOMB",
      p1x + 164,
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
      "GRAPPLE",
      p1x + 90,
      p1y + 154,
      26,
      @raylib.Color::new(236, 248, 242, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 470,
        sh / 2 - 206,
        940,
        412,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "GRAPPLING TOWER CLIMB",
        sw / 2 - 354,
        sh / 2 - 132,
        62,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Chain grapples between anchors, evade drones, and climb fast.",
        sw / 2 - 336,
        sh / 2 - 28,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad move/jump, right panel dash/bomb/grapple",
        sw / 2 - 356,
        sh / 2 + 16,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Reach 3200m before time or HP runs out",
        sw / 2 - 236,
        sh / 2 + 60,
        32,
        @raylib.Color::new(252, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 184,
        sh / 2 + 124,
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
        "SUMMIT REACHED",
        sw / 2 - 244,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{pilot.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Best height: \{pilot.best_h.to_int()}m",
        sw / 2 - 192,
        sh / 2 + 18,
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
        "CLIMB FAILED",
        sw / 2 - 206,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{pilot.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Best height: \{pilot.best_h.to_int()}m",
        sw / 2 - 192,
        sh / 2 + 18,
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
        reset_run()
      }
    }
  }

  @raylib.close_window()
}
