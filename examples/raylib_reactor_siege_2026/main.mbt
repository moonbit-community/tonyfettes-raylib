///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let world_w : Float = 3600.0

///|
let world_h : Float = 2600.0

///|
let max_enemies : Int = 56

///|
let max_bullets : Int = 520

///|
let max_drops : Int = 84

///|
let max_turrets : Int = 8

///|
let max_particles : Int = 1500

///|
let pad_count : Int = 6

///|
struct Hero {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut hp : Float
  mut shoot_cd : Float
  mut pulse_cd : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
  mut shake_t : Float
  mut scrap : Int
  mut score : Int
}

///|
struct Core {
  x : Float
  y : Float
  mut hp : Float
  mut shield : Float
}

///|
struct Enemy {
  mut active : Bool
  kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut stun_t : Float
  mut bite_cd : Float
}

///|
struct Bullet {
  mut active : Bool
  kind : Int
  mut x : Float
  mut y : Float
  vx : Float
  vy : Float
  dmg : Float
  mut life : Float
}

///|
struct Drop {
  mut active : Bool
  x : Float
  y : Float
  value : Int
  mut t : Float
  mut life : Float
}

///|
struct Turret {
  mut active : Bool
  x : Float
  y : Float
  mut hp : Float
  mut cd : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  size : Float
  mut t : Float
  life : Float
  kind : Int
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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx : Float = ax - bx
  let dy : Float = ay - by
  dx * dx + dy * dy
}

///|
fn inside_rect(px : Float, py : Float, x : Int, y : Int, w : Int, h : Int) -> Bool {
  let x0 : Float = Float::from_int(x)
  let y0 : Float = Float::from_int(y)
  let x1 : Float = Float::from_int(x + w)
  let y1 : Float = Float::from_int(y + h)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn emit_particle(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  size : Float,
  life : Float,
  kind : Int
) -> Unit {
  for i = 0; i < particles.length(); i = i + 1 {
    if not(particles[i].active) {
      particles[i] = {
        active: true,
        x,
        y,
        vx,
        vy,
        size,
        t: 0.0,
        life,
        kind,
      }
      break
    }
  }
}

///|
fn burst_particles(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let mut dx : Float = randf(-1.0, 1.0)
    let mut dy : Float = randf(-1.0, 1.0)
    let d2 : Float = dx * dx + dy * dy
    if d2 < 0.0001 {
      dx = 1.0
      dy = 0.0
    } else {
      let inv : Float = 1.0 / d2.sqrt()
      dx = dx * inv
      dy = dy * inv
    }
    let spd : Float = randf(speed * 0.35, speed)
    emit_particle(
      particles,
      x,
      y,
      dx * spd,
      dy * spd,
      randf(2.0, 6.0),
      randf(0.2, 0.95),
      kind,
    )
  }
}

///|
fn spawn_bullet(
  bullets : FixedArray[Bullet],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  life : Float
) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    if not(bullets[i].active) {
      bullets[i] = {
        active: true,
        kind,
        x,
        y,
        vx,
        vy,
        dmg,
        life,
      }
      break
    }
  }
}

///|
fn spawn_drop(drops : FixedArray[Drop], x : Float, y : Float, value : Int) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].active) {
      drops[i] = {
        active: true,
        x,
        y,
        value,
        t: 0.0,
        life: 20.0,
      }
      break
    }
  }
}

///|
fn spawn_enemy(enemies : FixedArray[Enemy], level : Int, core_x : Float, core_y : Float) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].active) {
      let edge : Int = @raylib.get_random_value(0, 3)
      let kind : Int = if @raylib.get_random_value(0, 100) < (22 + level * 6) { 1 } else { 0 }
      let mut x : Float = 0.0
      let mut y : Float = 0.0
      if edge == 0 {
        x = randf(40.0, world_w - 40.0)
        y = 20.0
      } else if edge == 1 {
        x = world_w - 20.0
        y = randf(40.0, world_h - 40.0)
      } else if edge == 2 {
        x = randf(40.0, world_w - 40.0)
        y = world_h - 20.0
      } else {
        x = 20.0
        y = randf(40.0, world_h - 40.0)
      }

      if dist2(x, y, core_x, core_y) < 420.0 * 420.0 {
        x = x + 480.0
        if x > world_w - 20.0 {
          x = x - 760.0
        }
      }

      enemies[i] = {
        active: true,
        kind,
        x,
        y,
        vx: randf(-30.0, 30.0),
        vy: randf(-30.0, 30.0),
        hp: if kind == 0 { 62.0 + Float::from_int(level) * 11.0 } else { 118.0 + Float::from_int(level) * 18.0 },
        stun_t: 0.0,
        bite_cd: 0.0,
      }
      break
    }
  }
}

///|
fn init_enemy_wave(enemies : FixedArray[Enemy], level : Int, core_x : Float, core_y : Float) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].active = false
  }
  let initial : Int = 12 + level * 3
  for i = 0; i < initial; i = i + 1 {
    spawn_enemy(enemies, level, core_x, core_y)
  }
}

///|
fn draw_bar(x : Int, y : Int, w : Int, h : Int, ratio : Float, fg : @raylib.Color, bg : @raylib.Color) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, bg)
  let r : Float = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(x + 2, y + 2, (Float::from_int(w - 4) * r).to_int(), h - 4, fg)
  @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(228, 236, 248, 168))
}

///|
fn draw_touch_controls(show : Bool) -> Unit {
  if not(show) {
    return
  }

  let pad_x : Int = 24
  let pad_y : Int = sh - 228
  let act_x : Int = sw - 214

  @raylib.draw_rectangle(pad_x, pad_y + 62, 78, 78, @raylib.Color::new(80, 106, 140, 84))
  @raylib.draw_text("L", pad_x + 30, pad_y + 88, 30, @raylib.Color::new(242, 246, 252, 216))

  @raylib.draw_rectangle(pad_x + 168, pad_y + 62, 78, 78, @raylib.Color::new(80, 106, 140, 84))
  @raylib.draw_text("R", pad_x + 198, pad_y + 88, 30, @raylib.Color::new(242, 246, 252, 216))

  @raylib.draw_rectangle(pad_x + 84, pad_y, 78, 78, @raylib.Color::new(80, 106, 140, 84))
  @raylib.draw_text("U", pad_x + 112, pad_y + 26, 30, @raylib.Color::new(242, 246, 252, 216))

  @raylib.draw_rectangle(pad_x + 84, pad_y + 124, 78, 78, @raylib.Color::new(80, 106, 140, 84))
  @raylib.draw_text("D", pad_x + 112, pad_y + 150, 30, @raylib.Color::new(242, 246, 252, 216))

  @raylib.draw_rectangle(act_x, pad_y + 10, 174, 60, @raylib.Color::new(220, 126, 90, 96))
  @raylib.draw_text("FIRE", act_x + 56, pad_y + 30, 26, @raylib.Color::new(255, 244, 230, 228))

  @raylib.draw_rectangle(act_x, pad_y + 76, 174, 60, @raylib.Color::new(108, 170, 232, 96))
  @raylib.draw_text("DASH", act_x + 52, pad_y + 96, 26, @raylib.Color::new(238, 246, 255, 228))

  @raylib.draw_rectangle(act_x, pad_y + 142, 84, 60, @raylib.Color::new(114, 148, 222, 96))
  @raylib.draw_text("PULSE", act_x + 8, pad_y + 162, 21, @raylib.Color::new(244, 248, 255, 228))

  @raylib.draw_rectangle(act_x + 90, pad_y + 142, 84, 60, @raylib.Color::new(120, 190, 136, 96))
  @raylib.draw_text("BUILD", act_x + 100, pad_y + 162, 21, @raylib.Color::new(246, 252, 246, 228))
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [moonbit] example - reactor siege 2026")
  defer @raylib.close_window()

  @raylib.set_target_fps(60)

  let bullets = FixedArray::make(max_bullets, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    dmg: 0.0,
    life: 0.0,
  })

  let enemies = FixedArray::make(max_enemies, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    stun_t: 0.0,
    bite_cd: 0.0,
  })

  let drops = FixedArray::make(max_drops, {
    active: false,
    x: 0.0,
    y: 0.0,
    value: 0,
    t: 0.0,
    life: 0.0,
  })

  let turrets = FixedArray::make(max_turrets, {
    active: false,
    x: 0.0,
    y: 0.0,
    hp: 0.0,
    cd: 0.0,
  })

  let particles = FixedArray::make(max_particles, {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    size: 0.0,
    t: 0.0,
    life: 0.0,
    kind: 0,
  })

  let pad_xs : FixedArray[Float] = FixedArray::make(pad_count, 0.0)
  let pad_ys : FixedArray[Float] = FixedArray::make(pad_count, 0.0)

  let core = {
    x: world_w * 0.5,
    y: world_h * 0.5,
    hp: 1000.0,
    shield: 260.0,
  }

  let hero = {
    x: world_w * 0.5 + 120.0,
    y: world_h * 0.5 + 20.0,
    vx: 0.0,
    vy: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    hp: 260.0,
    shoot_cd: 0.0,
    pulse_cd: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    scrap: 180,
    score: 0,
  }

  let mut level : Int = 1
  let mut timer : Float = 152.0
  let mut spawn_cd : Float = 1.2
  let mut state : Int = 0
  let mut announce_t : Float = 0.0

  let reset_round = fn(new_level : Int) {
    level = new_level
    timer = 158.0 - Float::from_int(level - 1) * 10.0
    if timer < 86.0 {
      timer = 86.0
    }

    hero.x = core.x + 120.0
    hero.y = core.y + 20.0
    hero.vx = 0.0
    hero.vy = 0.0
    hero.aim_x = 1.0
    hero.aim_y = 0.0
    hero.hp = 260.0
    hero.shoot_cd = 0.0
    hero.pulse_cd = 0.0
    hero.dash_t = 0.0
    hero.dash_cd = 0.0
    hero.hit_cd = 0.0
    hero.flash_t = 0.0
    hero.shake_t = 0.0
    hero.scrap = 180
    hero.score = 0

    core.hp = 1000.0 + Float::from_int(level - 1) * 130.0
    core.shield = 260.0

    for i = 0; i < bullets.length(); i = i + 1 {
      bullets[i].active = false
    }
    for i = 0; i < drops.length(); i = i + 1 {
      drops[i].active = false
    }
    for i = 0; i < particles.length(); i = i + 1 {
      particles[i].active = false
    }
    for i = 0; i < turrets.length(); i = i + 1 {
      turrets[i].active = false
      turrets[i].hp = 0.0
      turrets[i].cd = 0.0
    }

    let ring_r : Float = 340.0
    for i = 0; i < pad_count; i = i + 1 {
      let ang : Float = Float::from_int(i) * 6.283 / Float::from_int(pad_count)
      let px : Float = core.x + @math.cosf(ang) * ring_r
      let py : Float = core.y + @math.sinf(ang) * ring_r
      pad_xs[i] = px
      pad_ys[i] = py
    }

    init_enemy_wave(enemies, level, core.x, core.y)

    spawn_cd = 1.0
    announce_t = 2.6
  }

  reset_round(level)

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mut cam_x : Float = hero.x - Float::from_int(sw) * 0.5
    let mut cam_y : Float = hero.y - Float::from_int(sh) * 0.5
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_y < 0.0 {
      cam_y = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }
    if cam_y > world_h - Float::from_int(sh) {
      cam_y = world_h - Float::from_int(sh)
    }

    let mouse = @raylib.get_mouse_position()
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
    let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
    let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)

    let mut fire_down : Bool = @raylib.is_key_down(@raylib.KeyJ) || @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_key_pressed(@raylib.KeyLeftShift)
    let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyQ)
    let mut build_press : Bool = @raylib.is_key_pressed(@raylib.KeyE)

    let pad_x : Int = 24
    let pad_y : Int = sh - 228
    let act_x : Int = sw - 214

    if touching {
      if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 62, 78, 78) {
        move_l = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 62, 78, 78) {
        move_r = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 78, 78) {
        move_u = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 124, 78, 78) {
        move_d = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 10, 174, 60) {
        fire_down = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 76, 174, 60) {
        dash_press = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 142, 84, 60) {
        pulse_press = true
      }
      if inside_rect(mouse.x, mouse.y, act_x + 90, pad_y + 142, 84, 60) {
        build_press = true
      }
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      state = 1
      reset_round(level)
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
        state = 1
        reset_round(level)
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
        if state == 2 {
          level = level + 1
          if level > 8 {
            level = 8
          }
        }
        state = 1
        reset_round(level)
      }
    } else {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      if hero.shoot_cd > 0.0 {
        hero.shoot_cd = hero.shoot_cd - dt
        if hero.shoot_cd < 0.0 {
          hero.shoot_cd = 0.0
        }
      }
      if hero.pulse_cd > 0.0 {
        hero.pulse_cd = hero.pulse_cd - dt
        if hero.pulse_cd < 0.0 {
          hero.pulse_cd = 0.0
        }
      }
      if hero.dash_t > 0.0 {
        hero.dash_t = hero.dash_t - dt
        if hero.dash_t < 0.0 {
          hero.dash_t = 0.0
        }
      }
      if hero.dash_cd > 0.0 {
        hero.dash_cd = hero.dash_cd - dt
        if hero.dash_cd < 0.0 {
          hero.dash_cd = 0.0
        }
      }
      if hero.hit_cd > 0.0 {
        hero.hit_cd = hero.hit_cd - dt
        if hero.hit_cd < 0.0 {
          hero.hit_cd = 0.0
        }
      }
      if hero.flash_t > 0.0 {
        hero.flash_t = hero.flash_t - dt
        if hero.flash_t < 0.0 {
          hero.flash_t = 0.0
        }
      }
      if hero.shake_t > 0.0 {
        hero.shake_t = hero.shake_t - dt
        if hero.shake_t < 0.0 {
          hero.shake_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      let mut ix : Float = 0.0
      let mut iy : Float = 0.0
      if move_l {
        ix = ix - 1.0
      }
      if move_r {
        ix = ix + 1.0
      }
      if move_u {
        iy = iy - 1.0
      }
      if move_d {
        iy = iy + 1.0
      }

      let m2 : Float = ix * ix + iy * iy
      if m2 > 1.0 {
        let inv : Float = 1.0 / m2.sqrt()
        ix = ix * inv
        iy = iy * inv
      }

      let accel : Float = if hero.dash_t > 0.0 { 860.0 } else { 520.0 }
      let max_speed : Float = if hero.dash_t > 0.0 { 520.0 } else { 312.0 }
      let drag : Float = if hero.dash_t > 0.0 { 1.15 } else { 2.2 }

      hero.vx = hero.vx + (ix * accel - hero.vx * drag) * dt
      hero.vy = hero.vy + (iy * accel - hero.vy * drag) * dt

      let sp2 : Float = hero.vx * hero.vx + hero.vy * hero.vy
      let sp : Float = sp2.sqrt()
      if sp > max_speed {
        let inv : Float = max_speed / sp
        hero.vx = hero.vx * inv
        hero.vy = hero.vy * inv
      }

      hero.x = hero.x + hero.vx * dt
      hero.y = hero.y + hero.vy * dt

      if hero.x < 34.0 {
        hero.x = 34.0
        hero.vx = hero.vx.abs() * 0.25
      }
      if hero.x > world_w - 34.0 {
        hero.x = world_w - 34.0
        hero.vx = -hero.vx.abs() * 0.25
      }
      if hero.y < 34.0 {
        hero.y = 34.0
        hero.vy = hero.vy.abs() * 0.25
      }
      if hero.y > world_h - 34.0 {
        hero.y = world_h - 34.0
        hero.vy = -hero.vy.abs() * 0.25
      }

      let aim_world_x : Float = cam_x + mouse.x
      let aim_world_y : Float = cam_y + mouse.y
      let adx : Float = aim_world_x - hero.x
      let ady : Float = aim_world_y - hero.y
      let ad2 : Float = adx * adx + ady * ady
      if ad2 >= 9.0 {
        let inv : Float = 1.0 / ad2.sqrt()
        hero.aim_x = adx * inv
        hero.aim_y = ady * inv
      } else if sp > 20.0 {
        let inv : Float = 1.0 / sp
        hero.aim_x = hero.vx * inv
        hero.aim_y = hero.vy * inv
      }

      if dash_press && hero.dash_cd <= 0.0 {
        hero.dash_t = 0.36
        hero.dash_cd = 2.1
        hero.vx = hero.vx + hero.aim_x * 260.0
        hero.vy = hero.vy + hero.aim_y * 260.0
        burst_particles(particles, hero.x, hero.y, 26, 140.0, 2)
      }

      if pulse_press && hero.pulse_cd <= 0.0 {
        hero.pulse_cd = 8.0
        burst_particles(particles, hero.x, hero.y, 60, 160.0, 1)
        for i = 0; i < enemies.length(); i = i + 1 {
          if not(enemies[i].active) {
            continue
          }
          let d2 : Float = dist2(hero.x, hero.y, enemies[i].x, enemies[i].y)
          if d2 <= 230.0 * 230.0 {
            enemies[i].stun_t = 1.5
            enemies[i].hp = enemies[i].hp - 24.0
          }
        }
      }

      if fire_down && hero.shoot_cd <= 0.0 {
        hero.shoot_cd = if hero.dash_t > 0.0 { 0.06 } else { 0.1 }
        let speed : Float = if hero.dash_t > 0.0 { 690.0 } else { 620.0 }
        spawn_bullet(
          bullets,
          0,
          hero.x + hero.aim_x * 20.0,
          hero.y + hero.aim_y * 20.0,
          hero.aim_x * speed,
          hero.aim_y * speed,
          if hero.dash_t > 0.0 { 42.0 } else { 34.0 },
          1.1,
        )
      }

      if build_press {
        let mut build_idx : Int = -1
        for i = 0; i < pad_count; i = i + 1 {
          let d2 : Float = dist2(hero.x, hero.y, pad_xs[i], pad_ys[i])
          if d2 <= 78.0 * 78.0 {
            build_idx = i
            break
          }
        }

        if build_idx >= 0 {
          let mut slot : Int = build_idx
          if slot >= turrets.length() {
            slot = turrets.length() - 1
          }

          if not(turrets[slot].active) && hero.scrap >= 120 {
            hero.scrap = hero.scrap - 120
            turrets[slot] = {
              active: true,
              x: pad_xs[build_idx],
              y: pad_ys[build_idx],
              hp: 180.0,
              cd: 0.0,
            }
            burst_particles(particles, turrets[slot].x, turrets[slot].y, 24, 80.0, 1)
          } else if turrets[slot].active && hero.scrap >= 80 {
            hero.scrap = hero.scrap - 80
            turrets[slot].hp = turrets[slot].hp + 95.0
            if turrets[slot].hp > 220.0 {
              turrets[slot].hp = 220.0
            }
            burst_particles(particles, turrets[slot].x, turrets[slot].y, 18, 64.0, 2)
          }
        }
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, level, core.x, core.y)
        let mut next : Float = 0.9 - Float::from_int(level - 1) * 0.06
        if next < 0.28 {
          next = 0.28
        }
        spawn_cd = next
      }

      for i = 0; i < turrets.length(); i = i + 1 {
        if not(turrets[i].active) {
          continue
        }

        if turrets[i].hp <= 0.0 {
          turrets[i].active = false
          burst_particles(particles, turrets[i].x, turrets[i].y, 26, 88.0, 2)
          continue
        }

        if turrets[i].cd > 0.0 {
          turrets[i].cd = turrets[i].cd - dt
          if turrets[i].cd < 0.0 {
            turrets[i].cd = 0.0
          }
        }

        if turrets[i].cd <= 0.0 {
          let mut best : Int = -1
          let mut best_d2 : Float = 99999999.0
          for j = 0; j < enemies.length(); j = j + 1 {
            if not(enemies[j].active) {
              continue
            }
            let d2 : Float = dist2(turrets[i].x, turrets[i].y, enemies[j].x, enemies[j].y)
            if d2 < best_d2 && d2 <= 460.0 * 460.0 {
              best_d2 = d2
              best = j
            }
          }

          if best >= 0 {
            let dx : Float = enemies[best].x - turrets[i].x
            let dy : Float = enemies[best].y - turrets[i].y
            let d2 : Float = dx * dx + dy * dy
            let inv : Float = if d2 < 1.0 { 0.0 } else { 1.0 / d2.sqrt() }
            spawn_bullet(
              bullets,
              1,
              turrets[i].x,
              turrets[i].y,
              dx * inv * 560.0,
              dy * inv * 560.0,
              22.0,
              1.2,
            )
            turrets[i].cd = 0.26
          }
        }
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        if enemies[i].stun_t > 0.0 {
          enemies[i].stun_t = enemies[i].stun_t - dt
          if enemies[i].stun_t < 0.0 {
            enemies[i].stun_t = 0.0
          }
        }
        if enemies[i].bite_cd > 0.0 {
          enemies[i].bite_cd = enemies[i].bite_cd - dt
          if enemies[i].bite_cd < 0.0 {
            enemies[i].bite_cd = 0.0
          }
        }

        let target_hero_d2 : Float = dist2(enemies[i].x, enemies[i].y, hero.x, hero.y)
        let mut tx : Float = core.x
        let mut ty : Float = core.y
        if target_hero_d2 <= 280.0 * 280.0 {
          tx = hero.x
          ty = hero.y
        }

        if enemies[i].stun_t > 0.0 {
          enemies[i].vx = enemies[i].vx * (1.0 - dt * 3.4)
          enemies[i].vy = enemies[i].vy * (1.0 - dt * 3.4)
        } else {
          let dx : Float = tx - enemies[i].x
          let dy : Float = ty - enemies[i].y
          let d2 : Float = dx * dx + dy * dy
          let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

          let base_speed : Float = if enemies[i].kind == 0 { 170.0 } else { 126.0 }
          let level_gain : Float = if enemies[i].kind == 0 { 15.0 } else { 12.0 }
          let speed : Float = base_speed + Float::from_int(level - 1) * level_gain
          let txv : Float = dx / d * speed
          let tyv : Float = dy / d * speed

          enemies[i].vx = enemies[i].vx + (txv - enemies[i].vx * 2.0) * dt
          enemies[i].vy = enemies[i].vy + (tyv - enemies[i].vy * 2.0) * dt
        }

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt

        if enemies[i].x < 24.0 {
          enemies[i].x = 24.0
          enemies[i].vx = enemies[i].vx.abs()
        }
        if enemies[i].x > world_w - 24.0 {
          enemies[i].x = world_w - 24.0
          enemies[i].vx = -enemies[i].vx.abs()
        }
        if enemies[i].y < 24.0 {
          enemies[i].y = 24.0
          enemies[i].vy = enemies[i].vy.abs()
        }
        if enemies[i].y > world_h - 24.0 {
          enemies[i].y = world_h - 24.0
          enemies[i].vy = -enemies[i].vy.abs()
        }

        if enemies[i].bite_cd <= 0.0 {
          let hr : Float = 30.0
          if dist2(enemies[i].x, enemies[i].y, hero.x, hero.y) <= hr * hr {
            enemies[i].bite_cd = 0.65
            if hero.hit_cd <= 0.0 {
              let bite_dmg : Float = if enemies[i].kind == 0 { 16.0 } else { 22.0 }
              hero.hp = hero.hp - bite_dmg
              hero.hit_cd = 0.4
              hero.flash_t = 0.16
              hero.shake_t = 0.22
              burst_particles(particles, hero.x, hero.y, 14, 98.0, 2)
            }
          }

          let cr : Float = 42.0
          if dist2(enemies[i].x, enemies[i].y, core.x, core.y) <= cr * cr {
            enemies[i].bite_cd = 0.55
            let dmg : Float = if enemies[i].kind == 0 { 14.0 } else { 22.0 }
            if core.shield > 0.0 {
              core.shield = core.shield - dmg
              if core.shield < 0.0 {
                core.hp = core.hp + core.shield
                core.shield = 0.0
              }
            } else {
              core.hp = core.hp - dmg
            }
            burst_particles(particles, core.x, core.y, 16, 88.0, 1)
          }

          for j = 0; j < turrets.length(); j = j + 1 {
            if not(turrets[j].active) {
              continue
            }
            if dist2(enemies[i].x, enemies[i].y, turrets[j].x, turrets[j].y) <= 30.0 * 30.0 {
              enemies[i].bite_cd = 0.65
              let turret_dmg : Float = if enemies[i].kind == 0 { 18.0 } else { 26.0 }
              turrets[j].hp = turrets[j].hp - turret_dmg
              burst_particles(particles, turrets[j].x, turrets[j].y, 10, 70.0, 2)
              break
            }
          }
        }
      }

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

        if bullets[i].x < 0.0 || bullets[i].y < 0.0 || bullets[i].x > world_w || bullets[i].y > world_h {
          bullets[i].active = false
          continue
        }

        let mut hit : Bool = false
        for j = 0; j < enemies.length(); j = j + 1 {
          if not(enemies[j].active) {
            continue
          }
          if dist2(bullets[i].x, bullets[i].y, enemies[j].x, enemies[j].y) <= 22.0 * 22.0 {
            enemies[j].hp = enemies[j].hp - bullets[i].dmg
            if bullets[i].kind == 0 {
              enemies[j].stun_t = enemies[j].stun_t + 0.06
            } else {
              enemies[j].stun_t = enemies[j].stun_t + 0.14
            }
            let hit_fx_kind : Int = if bullets[i].kind == 0 { 1 } else { 2 }
            burst_particles(particles, bullets[i].x, bullets[i].y, 6, 55.0, hit_fx_kind)
            bullets[i].active = false
            hit = true
            break
          }
        }

        if hit {
          continue
        }
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        if enemies[i].hp <= 0.0 {
          enemies[i].active = false
          let drop_v : Int = if enemies[i].kind == 0 { 34 + level * 6 } else { 66 + level * 10 }
          spawn_drop(drops, enemies[i].x, enemies[i].y, drop_v)
          let kill_score : Int = if enemies[i].kind == 0 { 18 } else { 42 }
          hero.score = hero.score + kill_score
          burst_particles(particles, enemies[i].x, enemies[i].y, 20, 96.0, 2)
        }
      }

      for i = 0; i < drops.length(); i = i + 1 {
        if not(drops[i].active) {
          continue
        }
        drops[i].t = drops[i].t + dt
        drops[i].life = drops[i].life - dt
        if drops[i].life <= 0.0 {
          drops[i].active = false
          continue
        }

        let w : Float = 1.0 + @math.sinf(drops[i].t * 4.0) * 0.14
        if dist2(hero.x, hero.y, drops[i].x, drops[i].y) <= (34.0 * w) * (34.0 * w) {
          hero.scrap = hero.scrap + drops[i].value
          hero.score = hero.score + drops[i].value
          drops[i].active = false
          burst_particles(particles, hero.x, hero.y, 12, 70.0, 1)
          continue
        }
      }

      core.shield = core.shield + dt * 7.0
      if core.shield > 260.0 {
        core.shield = 260.0
      }
      hero.hp = clampf(hero.hp + dt * 2.6, 0.0, 260.0)

      if hero.hp <= 0.0 || core.hp <= 0.0 {
        state = 3
      } else if timer <= 0.0 {
        hero.score = hero.score + hero.scrap + core.hp.to_int()
        state = 2
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
          continue
        }
        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vx = particles[i].vx * (1.0 - dt * 0.75)
        particles[i].vy = particles[i].vy * (1.0 - dt * 0.75)
      }
    }

    let shake_x : Float = if hero.shake_t > 0.0 { randf(-6.0, 6.0) * (hero.shake_t * 4.0) } else { 0.0 }
    let shake_y : Float = if hero.shake_t > 0.0 { randf(-5.0, 5.0) * (hero.shake_t * 4.0) } else { 0.0 }

    cam_x = hero.x - Float::from_int(sw) * 0.5
    cam_y = hero.y - Float::from_int(sh) * 0.5
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_y < 0.0 {
      cam_y = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }
    if cam_y > world_h - Float::from_int(sh) {
      cam_y = world_h - Float::from_int(sh)
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(10, 18, 30, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(18, 28, 40, 255))

    let mut gx : Float = 0.0
    while gx <= world_w {
      let sx : Int = (gx - cam_x + shake_x).to_int()
      if sx >= -2 && sx <= sw + 2 {
        @raylib.draw_line(sx, 0, sx, sh, @raylib.Color::new(44, 62, 82, 110))
      }
      gx = gx + 120.0
    }

    let mut gy : Float = 0.0
    while gy <= world_h {
      let sy : Int = (gy - cam_y + shake_y).to_int()
      if sy >= -2 && sy <= sh + 2 {
        @raylib.draw_line(0, sy, sw, sy, @raylib.Color::new(44, 62, 82, 110))
      }
      gy = gy + 120.0
    }

    @raylib.draw_circle((core.x - cam_x + shake_x).to_int(), (core.y - cam_y + shake_y).to_int(), 68.0, @raylib.Color::new(76, 112, 164, 255))
    @raylib.draw_circle((core.x - cam_x + shake_x).to_int(), (core.y - cam_y + shake_y).to_int(), 44.0, @raylib.Color::new(128, 220, 250, 255))
    let shield_r : Float = 76.0 + core.shield * 0.08
    @raylib.draw_circle_lines((core.x - cam_x + shake_x).to_int(), (core.y - cam_y + shake_y).to_int(), shield_r, @raylib.Color::new(154, 216, 252, 180))

    for i = 0; i < pad_count; i = i + 1 {
      let px : Float = pad_xs[i] - cam_x + shake_x
      let py : Float = pad_ys[i] - cam_y + shake_y
      if px < -40.0 || py < -40.0 || px > Float::from_int(sw + 40) || py > Float::from_int(sh + 40) {
        continue
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), 20.0, @raylib.Color::new(82, 116, 154, 210))
      @raylib.draw_circle_lines(px.to_int(), py.to_int(), 26.0, @raylib.Color::new(184, 204, 230, 190))
    }

    for i = 0; i < turrets.length(); i = i + 1 {
      if not(turrets[i].active) {
        continue
      }
      let tx : Float = turrets[i].x - cam_x + shake_x
      let ty : Float = turrets[i].y - cam_y + shake_y
      if tx < -50.0 || ty < -50.0 || tx > Float::from_int(sw + 50) || ty > Float::from_int(sh + 50) {
        continue
      }

      @raylib.draw_circle(tx.to_int(), ty.to_int(), 16.0, @raylib.Color::new(108, 208, 162, 255))
      @raylib.draw_circle(tx.to_int(), ty.to_int(), 8.0, @raylib.Color::new(54, 80, 64, 255))
      @raylib.draw_rectangle((tx - 3.0).to_int(), (ty - 22.0).to_int(), 6, 12, @raylib.Color::new(214, 236, 248, 250))
    }

    for i = 0; i < drops.length(); i = i + 1 {
      if not(drops[i].active) {
        continue
      }
      let dx : Float = drops[i].x - cam_x + shake_x
      let dy : Float = drops[i].y - cam_y + shake_y
      if dx < -30.0 || dy < -30.0 || dx > Float::from_int(sw + 30) || dy > Float::from_int(sh + 30) {
        continue
      }
      let pulse : Float = 1.0 + @math.sinf(drops[i].t * 4.0) * 0.12
      @raylib.draw_circle(dx.to_int(), dy.to_int(), 11.0 * pulse, @raylib.Color::new(252, 208, 118, 220))
      @raylib.draw_rectangle((dx - 8.0).to_int(), (dy - 6.0).to_int(), 16, 12, @raylib.Color::new(255, 232, 152, 255))
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if not(enemies[i].active) {
        continue
      }
      let ex : Float = enemies[i].x - cam_x + shake_x
      let ey : Float = enemies[i].y - cam_y + shake_y
      if ex < -80.0 || ey < -80.0 || ex > Float::from_int(sw + 80) || ey > Float::from_int(sh + 80) {
        continue
      }

      let col = if enemies[i].stun_t > 0.0 {
        @raylib.Color::new(150, 226, 252, 255)
      } else if enemies[i].kind == 0 {
        @raylib.Color::new(236, 106, 96, 255)
      } else {
        @raylib.Color::new(250, 154, 90, 255)
      }

      let r : Float = if enemies[i].kind == 0 { 14.0 } else { 18.0 }
      @raylib.draw_circle(ex.to_int(), ey.to_int(), r, col)
      @raylib.draw_circle((ex - 4.0).to_int(), (ey - 3.0).to_int(), 2.0, @raylib.Color::new(20, 24, 30, 255))
      @raylib.draw_circle((ex + 4.0).to_int(), (ey - 3.0).to_int(), 2.0, @raylib.Color::new(20, 24, 30, 255))
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      let bx : Float = bullets[i].x - cam_x + shake_x
      let by : Float = bullets[i].y - cam_y + shake_y
      if bx < -8.0 || by < -8.0 || bx > Float::from_int(sw + 8) || by > Float::from_int(sh + 8) {
        continue
      }

      let col = if bullets[i].kind == 0 {
        @raylib.Color::new(252, 236, 130, 255)
      } else {
        @raylib.Color::new(126, 220, 252, 255)
      }
      @raylib.draw_circle(bx.to_int(), by.to_int(), if bullets[i].kind == 0 { 4.0 } else { 3.0 }, col)
    }

    let hx : Float = hero.x - cam_x + shake_x
    let hy : Float = hero.y - cam_y + shake_y

    let hcol = if hero.flash_t > 0.0 {
      @raylib.Color::new(252, 242, 188, 255)
    } else if hero.dash_t > 0.0 {
      @raylib.Color::new(128, 236, 204, 255)
    } else {
      @raylib.Color::new(114, 208, 252, 255)
    }

    @raylib.draw_circle(hx.to_int(), hy.to_int(), 18.0, hcol)
    @raylib.draw_circle(hx.to_int(), hy.to_int(), 8.0, @raylib.Color::new(36, 54, 76, 255))
    @raylib.draw_line(
      hx.to_int(),
      hy.to_int(),
      (hx + hero.aim_x * 28.0).to_int(),
      (hy + hero.aim_y * 28.0).to_int(),
      @raylib.Color::new(246, 248, 252, 255),
    )

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let px : Float = particles[i].x - cam_x + shake_x
      let py : Float = particles[i].y - cam_y + shake_y
      if px < -20.0 || py < -20.0 || px > Float::from_int(sw + 20) || py > Float::from_int(sh + 20) {
        continue
      }

      let life_r : Float = 1.0 - particles[i].t / particles[i].life
      let alpha : Int = clampf(life_r * 220.0, 0.0, 220.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(198, 216, 236, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 196, 126, alpha)
      } else {
        @raylib.Color::new(140, 220, 252, alpha)
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), particles[i].size * life_r, col)
    }

    @raylib.draw_rectangle(16, 14, 570, 194, @raylib.Color::new(12, 20, 34, 204))
    @raylib.draw_rectangle_lines(16, 14, 570, 194, @raylib.Color::new(224, 236, 250, 138))

    @raylib.draw_text("REACTOR SIEGE 2026", 30, 24, 34, @raylib.Color::new(236, 244, 254, 250))
    @raylib.draw_text("Move: WASD/Arrows  Fire:J/Mouse  Dash:Shift  Pulse:Q  Build:E", 32, 64, 21, @raylib.Color::new(190, 208, 236, 244))

    draw_bar(30, 94, 230, 20, hero.hp / 260.0, @raylib.Color::new(232, 130, 118, 255), @raylib.Color::new(90, 52, 52, 230))
    @raylib.draw_text("Pilot HP", 266, 92, 22, @raylib.Color::new(216, 230, 244, 244))

    draw_bar(30, 122, 230, 20, core.hp / (1000.0 + Float::from_int(level - 1) * 130.0), @raylib.Color::new(116, 210, 242, 255), @raylib.Color::new(56, 78, 92, 230))
    @raylib.draw_text("Reactor", 266, 120, 22, @raylib.Color::new(216, 230, 244, 244))

    draw_bar(30, 150, 230, 20, core.shield / 260.0, @raylib.Color::new(144, 234, 198, 255), @raylib.Color::new(58, 88, 74, 230))
    @raylib.draw_text("Shield", 266, 148, 22, @raylib.Color::new(216, 230, 244, 244))

    @raylib.draw_text(
      "Scrap \{hero.scrap}   Score \{hero.score}   Level \{level}",
      32,
      180,
      24,
      @raylib.Color::new(250, 240, 206, 248),
    )

    let pulse_text = if hero.pulse_cd <= 0.0 { "Pulse READY" } else { "Pulse CD \{hero.pulse_cd.to_int()}" }
    let dash_text = if hero.dash_cd <= 0.0 { "Dash READY" } else { "Dash CD \{hero.dash_cd.to_int()}" }

    @raylib.draw_text("Time: \{timer.to_int()}s", sw - 320, 22, 34, @raylib.Color::new(246, 246, 252, 250))
    @raylib.draw_text(dash_text, sw - 320, 62, 24, @raylib.Color::new(176, 220, 252, 248))
    @raylib.draw_text(pulse_text, sw - 320, 88, 24, @raylib.Color::new(216, 214, 248, 248))

    if announce_t > 0.0 {
      let alpha : Int = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Hold the perimeter. Build turrets on pads near the core.",
        sw / 2 - 372,
        218,
        34,
        @raylib.Color::new(244, 248, 252, alpha),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))
      @raylib.draw_text("REACTOR SIEGE", sw / 2 - 292, sh / 2 - 116, 82, @raylib.Color::new(238, 246, 252, 255))
      @raylib.draw_text("Defend the core from waves and keep the grid alive.", sw / 2 - 372, sh / 2 - 12, 34, @raylib.Color::new(192, 216, 242, 246))
      @raylib.draw_text("Build and repair turrets using scrap from kills.", sw / 2 - 332, sh / 2 + 30, 32, @raylib.Color::new(226, 232, 244, 238))
      @raylib.draw_text("Press ENTER to start", sw / 2 - 190, sh / 2 + 92, 44, @raylib.Color::new(252, 238, 174, 255))
    }

    if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 24, 20, 188))
      @raylib.draw_text("WAVE CLEARED", sw / 2 - 220, sh / 2 - 82, 74, @raylib.Color::new(214, 252, 214, 255))
      @raylib.draw_text("Score \{hero.score}   Scrap \{hero.scrap}   Core \{core.hp.to_int()}", sw / 2 - 312, sh / 2 + 8, 38, @raylib.Color::new(236, 246, 238, 248))
      @raylib.draw_text("Press ENTER for next wave", sw / 2 - 232, sh / 2 + 70, 40, @raylib.Color::new(252, 238, 176, 255))
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 8, 8, 198))
      @raylib.draw_text("REACTOR LOST", sw / 2 - 230, sh / 2 - 82, 74, @raylib.Color::new(252, 192, 182, 255))
      @raylib.draw_text("Score \{hero.score}   Time \{timer.to_int()}s", sw / 2 - 200, sh / 2 + 8, 38, @raylib.Color::new(246, 228, 220, 248))
      @raylib.draw_text("Press ENTER to retry", sw / 2 - 184, sh / 2 + 70, 40, @raylib.Color::new(252, 228, 174, 255))
    }

    draw_touch_controls(true)
  }
}
