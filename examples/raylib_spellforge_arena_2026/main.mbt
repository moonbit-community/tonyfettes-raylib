///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let world_w : Float = 3400.0

///|
let world_h : Float = 2400.0

///|
let max_enemies : Int = 68

///|
let max_projectiles : Int = 620

///|
let max_orbs : Int = 96

///|
let max_particles : Int = 1500

///|
struct Mage {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut hp : Float
  mut mana : Float
  mut fire_cd : Float
  mut frost_cd : Float
  mut storm_cd : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
  mut shake_t : Float
  mut score : Int
  mut combo : Int
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
  mut burn_t : Float
  mut slow_t : Float
  mut shock_t : Float
  mut bite_cd : Float
}

///|
struct Projectile {
  mut active : Bool
  kind : Int
  from_player : Bool
  mut x : Float
  mut y : Float
  vx : Float
  vy : Float
  dmg : Float
  mut life : Float
}

///|
struct Orb {
  mut active : Bool
  kind : Int
  x : Float
  y : Float
  value : Int
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
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
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
  kind : Int,
) -> Unit {
  for i in 0..<particles.length() {
    if not(particles[i].active) {
      particles[i] = { active: true, x, y, vx, vy, size, t: 0.0, life, kind }
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
  kind : Int,
) -> Unit {
  for i in 0..<count {
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
      randf(2.0, 6.4),
      randf(0.2, 1.0),
      kind,
    )
  }
}

///|
fn spawn_projectile(
  projectiles : FixedArray[Projectile],
  kind : Int,
  from_player : Bool,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  life : Float,
) -> Unit {
  for i in 0..<projectiles.length() {
    if not(projectiles[i].active) {
      projectiles[i] = {
        active: true,
        kind,
        from_player,
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
fn spawn_orb(
  orbs : FixedArray[Orb],
  x : Float,
  y : Float,
  kind : Int,
  value : Int,
) -> Unit {
  for i in 0..<orbs.length() {
    if not(orbs[i].active) {
      orbs[i] = { active: true, kind, x, y, value, t: 0.0, life: 22.0 }
      break
    }
  }
}

///|
fn spawn_enemy(
  enemies : FixedArray[Enemy],
  level : Int,
  center_x : Float,
  center_y : Float,
) -> Unit {
  for i in 0..<enemies.length() {
    if not(enemies[i].active) {
      let edge : Int = @raylib.get_random_value(0, 3)
      let kind : Int = if @raylib.get_random_value(0, 100) < 25 + level * 6 {
        1
      } else {
        0
      }
      let mut x : Float = 0.0
      let mut y : Float = 0.0

      if edge == 0 {
        x = randf(30.0, world_w - 30.0)
        y = 18.0
      } else if edge == 1 {
        x = world_w - 18.0
        y = randf(30.0, world_h - 30.0)
      } else if edge == 2 {
        x = randf(30.0, world_w - 30.0)
        y = world_h - 18.0
      } else {
        x = 18.0
        y = randf(30.0, world_h - 30.0)
      }

      if dist2(x, y, center_x, center_y) < 360.0 * 360.0 {
        x = x + 420.0
        if x > world_w - 24.0 {
          x = x - 720.0
        }
      }

      enemies[i] = {
        active: true,
        kind,
        x,
        y,
        vx: randf(-40.0, 40.0),
        vy: randf(-40.0, 40.0),
        hp: if kind == 0 {
          66.0 + Float::from_int(level - 1) * 10.0
        } else {
          128.0 + Float::from_int(level - 1) * 20.0
        },
        burn_t: 0.0,
        slow_t: 0.0,
        shock_t: 0.0,
        bite_cd: randf(0.0, 0.4),
      }
      break
    }
  }
}

///|
fn init_wave(
  enemies : FixedArray[Enemy],
  level : Int,
  center_x : Float,
  center_y : Float,
) -> Unit {
  for enemy in enemies {
    enemy.active = false
  }
  let initial : Int = 14 + level * 4
  for i in 0..<initial {
    spawn_enemy(enemies, level, center_x, center_y)
  }
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fg : @raylib.Color,
  bg : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, bg)
  let r : Float = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    (Float::from_int(w - 4) * r).to_int(),
    h - 4,
    fg,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(228, 236, 248, 172),
  )
}

///|
fn draw_touch_controls(show : Bool) -> Unit {
  if not(show) {
    return
  }

  let pad_x : Int = 24
  let pad_y : Int = sh - 228
  let act_x : Int = sw - 234

  @raylib.draw_rectangle(
    pad_x,
    pad_y + 62,
    78,
    78,
    @raylib.Color::new(84, 110, 146, 86),
  )
  @raylib.draw_text(
    "L",
    pad_x + 30,
    pad_y + 88,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    pad_x + 168,
    pad_y + 62,
    78,
    78,
    @raylib.Color::new(84, 110, 146, 86),
  )
  @raylib.draw_text(
    "R",
    pad_x + 198,
    pad_y + 88,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y,
    78,
    78,
    @raylib.Color::new(84, 110, 146, 86),
  )
  @raylib.draw_text(
    "U",
    pad_x + 112,
    pad_y + 26,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y + 124,
    78,
    78,
    @raylib.Color::new(84, 110, 146, 86),
  )
  @raylib.draw_text(
    "D",
    pad_x + 112,
    pad_y + 150,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    act_x,
    pad_y + 8,
    204,
    56,
    @raylib.Color::new(220, 110, 88, 92),
  )
  @raylib.draw_text(
    "FIRE",
    act_x + 70,
    pad_y + 26,
    24,
    @raylib.Color::new(252, 244, 230, 232),
  )

  @raylib.draw_rectangle(
    act_x,
    pad_y + 70,
    98,
    56,
    @raylib.Color::new(118, 198, 248, 92),
  )
  @raylib.draw_text(
    "FROST",
    act_x + 12,
    pad_y + 88,
    20,
    @raylib.Color::new(238, 248, 255, 232),
  )

  @raylib.draw_rectangle(
    act_x + 106,
    pad_y + 70,
    98,
    56,
    @raylib.Color::new(162, 138, 252, 92),
  )
  @raylib.draw_text(
    "STORM",
    act_x + 118,
    pad_y + 88,
    20,
    @raylib.Color::new(246, 240, 255, 232),
  )

  @raylib.draw_rectangle(
    act_x,
    pad_y + 132,
    204,
    70,
    @raylib.Color::new(110, 216, 164, 92),
  )
  @raylib.draw_text(
    "DASH",
    act_x + 76,
    pad_y + 156,
    26,
    @raylib.Color::new(242, 252, 246, 232),
  )
}

///|
fn main {
  @raylib.init_window(
    sw, sh, "raylib [moonbit] example - spellforge arena 2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(60)

  let enemies = FixedArray::make(max_enemies, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    burn_t: 0.0,
    slow_t: 0.0,
    shock_t: 0.0,
    bite_cd: 0.0,
  })

  let projectiles = FixedArray::make(max_projectiles, {
    active: false,
    kind: 0,
    from_player: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    dmg: 0.0,
    life: 0.0,
  })

  let orbs = FixedArray::make(max_orbs, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    value: 0,
    t: 0.0,
    life: 0.0,
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

  let mage = {
    x: world_w * 0.5,
    y: world_h * 0.5,
    vx: 0.0,
    vy: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    hp: 300.0,
    mana: 260.0,
    fire_cd: 0.0,
    frost_cd: 0.0,
    storm_cd: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    score: 0,
    combo: 0,
  }

  let mut level : Int = 1
  let mut timer : Float = 164.0
  let mut spawn_cd : Float = 1.0
  let mut state : Int = 0
  let mut announce_t : Float = 0.0

  let reset_round = fn(new_level : Int) {
    level = new_level

    timer = 168.0 - Float::from_int(level - 1) * 9.0
    if timer < 94.0 {
      timer = 94.0
    }

    mage.x = world_w * 0.5
    mage.y = world_h * 0.5
    mage.vx = 0.0
    mage.vy = 0.0
    mage.aim_x = 1.0
    mage.aim_y = 0.0
    mage.hp = 300.0
    mage.mana = 260.0
    mage.fire_cd = 0.0
    mage.frost_cd = 0.0
    mage.storm_cd = 0.0
    mage.dash_t = 0.0
    mage.dash_cd = 0.0
    mage.hit_cd = 0.0
    mage.flash_t = 0.0
    mage.shake_t = 0.0
    mage.score = 0
    mage.combo = 0

    for projectile in projectiles {
      projectile.active = false
    }
    for orb in orbs {
      orb.active = false
    }
    for particle in particles {
      particle.active = false
    }

    init_wave(enemies, level, mage.x, mage.y)
    spawn_cd = 0.85
    announce_t = 2.8
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

    let mut cam_x : Float = mage.x - Float::from_int(sw) * 0.5
    let mut cam_y : Float = mage.y - Float::from_int(sh) * 0.5
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

    let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyRight)
    let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
      @raylib.is_key_down(@raylib.KeyUp)
    let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
      @raylib.is_key_down(@raylib.KeyDown)

    let mut fire_down : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mut frost_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
    let mut storm_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)
    let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
      @raylib.is_key_pressed(@raylib.KeyLeftShift)

    let pad_x : Int = 24
    let pad_y : Int = sh - 228
    let act_x : Int = sw - 234

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
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 8, 204, 56) {
        fire_down = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 70, 98, 56) {
        frost_press = true
      }
      if inside_rect(mouse.x, mouse.y, act_x + 106, pad_y + 70, 98, 56) {
        storm_press = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 132, 204, 70) {
        dash_press = true
      }
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      state = 1
      reset_round(level)
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        state = 1
        reset_round(level)
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
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

      if mage.fire_cd > 0.0 {
        mage.fire_cd = mage.fire_cd - dt
        if mage.fire_cd < 0.0 {
          mage.fire_cd = 0.0
        }
      }
      if mage.frost_cd > 0.0 {
        mage.frost_cd = mage.frost_cd - dt
        if mage.frost_cd < 0.0 {
          mage.frost_cd = 0.0
        }
      }
      if mage.storm_cd > 0.0 {
        mage.storm_cd = mage.storm_cd - dt
        if mage.storm_cd < 0.0 {
          mage.storm_cd = 0.0
        }
      }
      if mage.dash_t > 0.0 {
        mage.dash_t = mage.dash_t - dt
        if mage.dash_t < 0.0 {
          mage.dash_t = 0.0
        }
      }
      if mage.dash_cd > 0.0 {
        mage.dash_cd = mage.dash_cd - dt
        if mage.dash_cd < 0.0 {
          mage.dash_cd = 0.0
        }
      }
      if mage.hit_cd > 0.0 {
        mage.hit_cd = mage.hit_cd - dt
        if mage.hit_cd < 0.0 {
          mage.hit_cd = 0.0
        }
      }
      if mage.flash_t > 0.0 {
        mage.flash_t = mage.flash_t - dt
        if mage.flash_t < 0.0 {
          mage.flash_t = 0.0
        }
      }
      if mage.shake_t > 0.0 {
        mage.shake_t = mage.shake_t - dt
        if mage.shake_t < 0.0 {
          mage.shake_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      mage.mana = mage.mana + dt * 18.0
      if mage.mana > 260.0 {
        mage.mana = 260.0
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

      let accel : Float = if mage.dash_t > 0.0 { 880.0 } else { 540.0 }
      let max_speed : Float = if mage.dash_t > 0.0 { 560.0 } else { 324.0 }
      let drag : Float = if mage.dash_t > 0.0 { 1.0 } else { 2.2 }

      mage.vx = mage.vx + (ix * accel - mage.vx * drag) * dt
      mage.vy = mage.vy + (iy * accel - mage.vy * drag) * dt

      let sp2 : Float = mage.vx * mage.vx + mage.vy * mage.vy
      let sp : Float = sp2.sqrt()
      if sp > max_speed {
        let inv : Float = max_speed / sp
        mage.vx = mage.vx * inv
        mage.vy = mage.vy * inv
      }

      mage.x = mage.x + mage.vx * dt
      mage.y = mage.y + mage.vy * dt

      if mage.x < 28.0 {
        mage.x = 28.0
        mage.vx = mage.vx.abs() * 0.25
      }
      if mage.x > world_w - 28.0 {
        mage.x = world_w - 28.0
        mage.vx = -mage.vx.abs() * 0.25
      }
      if mage.y < 28.0 {
        mage.y = 28.0
        mage.vy = mage.vy.abs() * 0.25
      }
      if mage.y > world_h - 28.0 {
        mage.y = world_h - 28.0
        mage.vy = -mage.vy.abs() * 0.25
      }

      let aim_world_x : Float = cam_x + mouse.x
      let aim_world_y : Float = cam_y + mouse.y
      let adx : Float = aim_world_x - mage.x
      let ady : Float = aim_world_y - mage.y
      let ad2 : Float = adx * adx + ady * ady
      if ad2 >= 9.0 {
        let inv : Float = 1.0 / ad2.sqrt()
        mage.aim_x = adx * inv
        mage.aim_y = ady * inv
      } else if sp > 18.0 {
        let inv : Float = 1.0 / sp
        mage.aim_x = mage.vx * inv
        mage.aim_y = mage.vy * inv
      }

      if dash_press && mage.dash_cd <= 0.0 && mage.mana >= 42.0 {
        mage.mana = mage.mana - 42.0
        mage.dash_t = 0.34
        mage.dash_cd = 1.9
        mage.vx = mage.vx + mage.aim_x * 270.0
        mage.vy = mage.vy + mage.aim_y * 270.0
        burst_particles(particles, mage.x, mage.y, 24, 152.0, 2)
      }

      if fire_down && mage.fire_cd <= 0.0 && mage.mana >= 7.0 {
        mage.mana = mage.mana - 7.0
        mage.fire_cd = if mage.dash_t > 0.0 { 0.055 } else { 0.09 }
        let speed : Float = 690.0
        let dmg : Float = if mage.dash_t > 0.0 { 42.0 } else { 34.0 }
        spawn_projectile(
          projectiles,
          0,
          true,
          mage.x + mage.aim_x * 20.0,
          mage.y + mage.aim_y * 20.0,
          mage.aim_x * speed,
          mage.aim_y * speed,
          dmg,
          1.1,
        )
      }

      if frost_press && mage.frost_cd <= 0.0 && mage.mana >= 46.0 {
        mage.mana = mage.mana - 46.0
        mage.frost_cd = 4.8
        burst_particles(particles, mage.x, mage.y, 52, 150.0, 1)
        for enemy in enemies {
          if not(enemy.active) {
            continue
          }
          let d2 : Float = dist2(mage.x, mage.y, enemy.x, enemy.y)
          if d2 <= 250.0 * 250.0 {
            enemy.hp = enemy.hp - 30.0
            enemy.slow_t = enemy.slow_t + 2.5
          }
        }
      }

      if storm_press && mage.storm_cd <= 0.0 && mage.mana >= 60.0 {
        mage.mana = mage.mana - 60.0
        mage.storm_cd = 7.2
        let mut hits : Int = 0
        for _j in 0..<8 {
          let mut best : Int = -1
          let mut best_d2 : Float = 99999999.0
          for i in 0..<enemies.length() {
            if not(enemies[i].active) {
              continue
            }
            let d2 : Float = dist2(mage.x, mage.y, enemies[i].x, enemies[i].y)
            if d2 < best_d2 && d2 <= 420.0 * 420.0 && enemies[i].shock_t <= 0.08 {
              best = i
              best_d2 = d2
            }
          }
          if best >= 0 {
            enemies[best].hp = enemies[best].hp - 48.0
            enemies[best].shock_t = 1.4
            hits = hits + 1
            burst_particles(
              particles,
              enemies[best].x,
              enemies[best].y,
              22,
              120.0,
              2,
            )
          }
        }
        if hits > 0 {
          mage.combo = mage.combo + hits
          if mage.combo > 40 {
            mage.combo = 40
          }
        }
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, level, mage.x, mage.y)
        let mut next : Float = 0.9 - Float::from_int(level - 1) * 0.06
        if next < 0.24 {
          next = 0.24
        }
        spawn_cd = next
      }

      for enemy in enemies {
        if not(enemy.active) {
          continue
        }

        if enemy.burn_t > 0.0 {
          enemy.burn_t = enemy.burn_t - dt
          if enemy.burn_t < 0.0 {
            enemy.burn_t = 0.0
          }
          enemy.hp = enemy.hp - dt * 12.0
          emit_particle(
            particles,
            enemy.x,
            enemy.y,
            randf(-22.0, 22.0),
            randf(-34.0, -8.0),
            randf(1.5, 3.6),
            randf(0.18, 0.42),
            0,
          )
        }
        if enemy.slow_t > 0.0 {
          enemy.slow_t = enemy.slow_t - dt
          if enemy.slow_t < 0.0 {
            enemy.slow_t = 0.0
          }
        }
        if enemy.shock_t > 0.0 {
          enemy.shock_t = enemy.shock_t - dt
          if enemy.shock_t < 0.0 {
            enemy.shock_t = 0.0
          }
        }
        if enemy.bite_cd > 0.0 {
          enemy.bite_cd = enemy.bite_cd - dt
          if enemy.bite_cd < 0.0 {
            enemy.bite_cd = 0.0
          }
        }

        let dx : Float = mage.x - enemy.x
        let dy : Float = mage.y - enemy.y
        let d2 : Float = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        let base_speed : Float = if enemy.kind == 0 {
          178.0
        } else {
          132.0
        }
        let level_gain : Float = if enemy.kind == 0 { 16.0 } else { 12.0 }
        let mut speed : Float = base_speed +
          Float::from_int(level - 1) * level_gain

        if enemy.slow_t > 0.0 {
          speed = speed * 0.52
        }
        if enemy.shock_t > 0.0 {
          speed = speed * 0.36
        }

        let tx : Float = dx / d * speed
        let ty : Float = dy / d * speed

        enemy.vx = enemy.vx + (tx - enemy.vx * 2.0) * dt
        enemy.vy = enemy.vy + (ty - enemy.vy * 2.0) * dt

        enemy.x = enemy.x + enemy.vx * dt
        enemy.y = enemy.y + enemy.vy * dt

        if enemy.x < 24.0 {
          enemy.x = 24.0
          enemy.vx = enemy.vx.abs()
        }
        if enemy.x > world_w - 24.0 {
          enemy.x = world_w - 24.0
          enemy.vx = -enemy.vx.abs()
        }
        if enemy.y < 24.0 {
          enemy.y = 24.0
          enemy.vy = enemy.vy.abs()
        }
        if enemy.y > world_h - 24.0 {
          enemy.y = world_h - 24.0
          enemy.vy = -enemy.vy.abs()
        }

        if enemy.bite_cd <= 0.0 {
          if dist2(enemy.x, enemy.y, mage.x, mage.y) <= 30.0 * 30.0 {
            enemy.bite_cd = 0.6
            if mage.hit_cd <= 0.0 {
              let bite_dmg : Float = if enemy.kind == 0 {
                14.0
              } else {
                22.0
              }
              mage.hp = mage.hp - bite_dmg
              mage.hit_cd = 0.42
              mage.flash_t = 0.18
              mage.shake_t = 0.24
              mage.combo = 0
              burst_particles(particles, mage.x, mage.y, 18, 108.0, 2)
            }
          }
        }
      }

      for projectile in projectiles {
        if not(projectile.active) {
          continue
        }

        projectile.life = projectile.life - dt
        if projectile.life <= 0.0 {
          projectile.active = false
          continue
        }

        projectile.x = projectile.x + projectile.vx * dt
        projectile.y = projectile.y + projectile.vy * dt

        if projectile.x < 0.0 ||
          projectile.y < 0.0 ||
          projectile.x > world_w ||
          projectile.y > world_h {
          projectile.active = false
          continue
        }

        if projectile.from_player {
          for enemy in enemies {
            if not(enemy.active) {
              continue
            }
            if dist2(
                projectile.x,
                projectile.y,
                enemy.x,
                enemy.y,
              ) <=
              22.0 * 22.0 {
              enemy.hp = enemy.hp - projectile.dmg
              if projectile.kind == 0 {
                enemy.burn_t = enemy.burn_t + 1.8
              }
              burst_particles(
                particles,
                projectile.x,
                projectile.y,
                6,
                60.0,
                0,
              )
              projectile.active = false
              break
            }
          }
        }
      }

      for enemy in enemies {
        if not(enemy.active) {
          continue
        }

        if enemy.hp <= 0.0 {
          enemy.active = false
          let orb_kind : Int = if @raylib.get_random_value(0, 100) < 30 {
            1
          } else {
            0
          }
          let orb_value : Int = if orb_kind == 0 {
            20 + level * 4
          } else {
            26 + level * 5
          }
          spawn_orb(orbs, enemy.x, enemy.y, orb_kind, orb_value)

          let kill_score : Int = if enemy.kind == 0 { 24 } else { 52 }
          mage.score = mage.score + kill_score + mage.combo
          mage.combo = mage.combo + 1
          if mage.combo > 60 {
            mage.combo = 60
          }

          burst_particles(
            particles,
            enemy.x,
            enemy.y,
            24,
            98.0,
            if enemy.kind == 0 {
              0
            } else {
              2
            },
          )
        }
      }

      for orb in orbs {
        if not(orb.active) {
          continue
        }

        orb.t = orb.t + dt
        orb.life = orb.life - dt
        if orb.life <= 0.0 {
          orb.active = false
          continue
        }

        let pulse : Float = 1.0 + @math.sinf(orb.t * 4.2) * 0.12
        if dist2(mage.x, mage.y, orb.x, orb.y) <=
          34.0 * pulse * (34.0 * pulse) {
          if orb.kind == 0 {
            mage.mana = mage.mana + Float::from_int(orb.value)
            if mage.mana > 260.0 {
              mage.mana = 260.0
            }
          } else {
            mage.hp = mage.hp + Float::from_int(orb.value)
            if mage.hp > 300.0 {
              mage.hp = 300.0
            }
          }
          mage.score = mage.score + orb.value
          burst_particles(
            particles,
            mage.x,
            mage.y,
            14,
            74.0,
            if orb.kind == 0 {
              1
            } else {
              2
            },
          )
          orb.active = false
        }
      }

      for particle in particles {
        if not(particle.active) {
          continue
        }
        particle.t = particle.t + dt
        if particle.t >= particle.life {
          particle.active = false
          continue
        }
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.vx = particle.vx * (1.0 - dt * 0.75)
        particle.vy = particle.vy * (1.0 - dt * 0.75)
      }

      if mage.hp <= 0.0 {
        state = 3
      } else if timer <= 0.0 {
        mage.score = mage.score + mage.hp.to_int() + mage.mana.to_int()
        state = 2
      }
    }

    let shake_x : Float = if mage.shake_t > 0.0 {
      randf(-6.0, 6.0) * (mage.shake_t * 3.6)
    } else {
      0.0
    }
    let shake_y : Float = if mage.shake_t > 0.0 {
      randf(-5.0, 5.0) * (mage.shake_t * 3.6)
    } else {
      0.0
    }

    cam_x = mage.x - Float::from_int(sw) * 0.5
    cam_y = mage.y - Float::from_int(sh) * 0.5
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

    @raylib.clear_background(@raylib.Color::new(12, 18, 30, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(18, 24, 38, 255))

    let mut gx : Float = 0.0
    while gx <= world_w {
      let sx : Int = (gx - cam_x + shake_x).to_int()
      if sx >= -2 && sx <= sw + 2 {
        @raylib.draw_line(sx, 0, sx, sh, @raylib.Color::new(44, 62, 86, 110))
      }
      gx = gx + 120.0
    }

    let mut gy : Float = 0.0
    while gy <= world_h {
      let sy : Int = (gy - cam_y + shake_y).to_int()
      if sy >= -2 && sy <= sh + 2 {
        @raylib.draw_line(0, sy, sw, sy, @raylib.Color::new(44, 62, 86, 110))
      }
      gy = gy + 120.0
    }

    for orb in orbs {
      if not(orb.active) {
        continue
      }
      let ox : Float = orb.x - cam_x + shake_x
      let oy : Float = orb.y - cam_y + shake_y
      if ox < -34.0 ||
        oy < -34.0 ||
        ox > Float::from_int(sw + 34) ||
        oy > Float::from_int(sh + 34) {
        continue
      }
      let pulse : Float = 1.0 + @math.sinf(orb.t * 4.2) * 0.14
      let col = if orb.kind == 0 {
        @raylib.Color::new(120, 206, 252, 220)
      } else {
        @raylib.Color::new(176, 140, 252, 220)
      }
      @raylib.draw_circle(ox.to_int(), oy.to_int(), 10.0 * pulse, col)
      @raylib.draw_circle(
        ox.to_int(),
        oy.to_int(),
        4.0 * pulse,
        @raylib.Color::new(248, 250, 255, 230),
      )
    }

    for enemy in enemies {
      if not(enemy.active) {
        continue
      }
      let ex : Float = enemy.x - cam_x + shake_x
      let ey : Float = enemy.y - cam_y + shake_y
      if ex < -80.0 ||
        ey < -80.0 ||
        ex > Float::from_int(sw + 80) ||
        ey > Float::from_int(sh + 80) {
        continue
      }

      let col = if enemy.shock_t > 0.0 {
        @raylib.Color::new(154, 216, 252, 255)
      } else if enemy.slow_t > 0.0 {
        @raylib.Color::new(166, 186, 252, 255)
      } else if enemy.kind == 0 {
        @raylib.Color::new(236, 112, 96, 255)
      } else {
        @raylib.Color::new(250, 164, 98, 255)
      }

      let r : Float = if enemy.kind == 0 { 14.0 } else { 18.0 }
      @raylib.draw_circle(ex.to_int(), ey.to_int(), r, col)
      @raylib.draw_circle(
        (ex - 4.0).to_int(),
        (ey - 3.0).to_int(),
        2.0,
        @raylib.Color::new(22, 24, 30, 255),
      )
      @raylib.draw_circle(
        (ex + 4.0).to_int(),
        (ey - 3.0).to_int(),
        2.0,
        @raylib.Color::new(22, 24, 30, 255),
      )

      if enemy.burn_t > 0.0 {
        @raylib.draw_circle_lines(
          ex.to_int(),
          ey.to_int(),
          r + 4.0,
          @raylib.Color::new(252, 156, 92, 220),
        )
      }
    }

    for projectile in projectiles {
      if not(projectile.active) {
        continue
      }
      let px : Float = projectile.x - cam_x + shake_x
      let py : Float = projectile.y - cam_y + shake_y
      if px < -8.0 ||
        py < -8.0 ||
        px > Float::from_int(sw + 8) ||
        py > Float::from_int(sh + 8) {
        continue
      }
      let col = if projectile.kind == 0 {
        @raylib.Color::new(252, 216, 128, 255)
      } else if projectile.kind == 1 {
        @raylib.Color::new(142, 214, 252, 255)
      } else {
        @raylib.Color::new(192, 154, 252, 255)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        if projectile.kind == 0 {
          4.0
        } else {
          3.0
        },
        col,
      )
    }

    let hx : Float = mage.x - cam_x + shake_x
    let hy : Float = mage.y - cam_y + shake_y

    let hcol = if mage.flash_t > 0.0 {
      @raylib.Color::new(252, 242, 188, 255)
    } else if mage.dash_t > 0.0 {
      @raylib.Color::new(132, 236, 204, 255)
    } else {
      @raylib.Color::new(118, 212, 252, 255)
    }

    @raylib.draw_circle(hx.to_int(), hy.to_int(), 18.0, hcol)
    @raylib.draw_circle(
      hx.to_int(),
      hy.to_int(),
      8.0,
      @raylib.Color::new(34, 52, 74, 255),
    )
    @raylib.draw_line(
      hx.to_int(),
      hy.to_int(),
      (hx + mage.aim_x * 28.0).to_int(),
      (hy + mage.aim_y * 28.0).to_int(),
      @raylib.Color::new(246, 248, 252, 255),
    )

    for particle in particles {
      if not(particle.active) {
        continue
      }
      let px : Float = particle.x - cam_x + shake_x
      let py : Float = particle.y - cam_y + shake_y
      if px < -20.0 ||
        py < -20.0 ||
        px > Float::from_int(sw + 20) ||
        py > Float::from_int(sh + 20) {
        continue
      }
      let life_r : Float = 1.0 - particle.t / particle.life
      let alpha : Int = clampf(life_r * 220.0, 0.0, 220.0).to_int()
      let col = if particle.kind == 0 {
        @raylib.Color::new(252, 184, 122, alpha)
      } else if particle.kind == 1 {
        @raylib.Color::new(132, 216, 252, alpha)
      } else {
        @raylib.Color::new(194, 164, 252, alpha)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        particle.size * life_r,
        col,
      )
    }

    @raylib.draw_rectangle(
      16,
      14,
      610,
      202,
      @raylib.Color::new(12, 20, 34, 205),
    )
    @raylib.draw_rectangle_lines(
      16,
      14,
      610,
      202,
      @raylib.Color::new(224, 236, 250, 138),
    )

    @raylib.draw_text(
      "SPELLFORGE ARENA 2026",
      30,
      22,
      34,
      @raylib.Color::new(236, 244, 254, 250),
    )
    @raylib.draw_text(
      "Fire:J/Mouse  Frost:K  Storm:L  Dash:Shift/Space",
      32,
      62,
      22,
      @raylib.Color::new(190, 208, 236, 244),
    )

    draw_bar(
      30,
      94,
      236,
      20,
      mage.hp / 300.0,
      @raylib.Color::new(232, 130, 118, 255),
      @raylib.Color::new(90, 52, 52, 230),
    )
    @raylib.draw_text("HP", 272, 92, 22, @raylib.Color::new(216, 230, 244, 244))

    draw_bar(
      30,
      122,
      236,
      20,
      mage.mana / 260.0,
      @raylib.Color::new(118, 206, 252, 255),
      @raylib.Color::new(56, 78, 94, 230),
    )
    @raylib.draw_text(
      "Mana",
      272,
      120,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    let dash_ready : Float = if mage.dash_cd <= 0.0 {
      1.0
    } else {
      1.0 - mage.dash_cd / 1.9
    }
    draw_bar(
      30,
      150,
      236,
      20,
      dash_ready,
      @raylib.Color::new(146, 232, 186, 255),
      @raylib.Color::new(56, 90, 74, 230),
    )
    @raylib.draw_text(
      "Dash",
      272,
      148,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    @raylib.draw_text(
      "Score \{mage.score}   Combo x\{mage.combo}   Level \{level}",
      32,
      184,
      24,
      @raylib.Color::new(250, 240, 206, 248),
    )

    let frost_text = if mage.frost_cd <= 0.0 {
      "Frost READY"
    } else {
      "Frost CD \{mage.frost_cd.to_int()}"
    }
    let storm_text = if mage.storm_cd <= 0.0 {
      "Storm READY"
    } else {
      "Storm CD \{mage.storm_cd.to_int()}"
    }

    @raylib.draw_text(
      "Time: \{timer.to_int()}s",
      sw - 334,
      24,
      34,
      @raylib.Color::new(246, 246, 252, 250),
    )
    @raylib.draw_text(
      frost_text,
      sw - 334,
      64,
      24,
      @raylib.Color::new(170, 222, 252, 248),
    )
    @raylib.draw_text(
      storm_text,
      sw - 334,
      90,
      24,
      @raylib.Color::new(210, 192, 252, 248),
    )

    if announce_t > 0.0 {
      let alpha : Int = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Chain spell effects to build combo and survive the arena.",
        sw / 2 - 372,
        224,
        34,
        @raylib.Color::new(244, 248, 252, alpha),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))
      @raylib.draw_text(
        "SPELLFORGE ARENA",
        sw / 2 - 336,
        sh / 2 - 116,
        80,
        @raylib.Color::new(238, 246, 252, 255),
      )
      @raylib.draw_text(
        "Wield fire, frost, and storm to dominate the circle.",
        sw / 2 - 370,
        sh / 2 - 12,
        34,
        @raylib.Color::new(192, 216, 242, 246),
      )
      @raylib.draw_text(
        "Keep mana flowing by collecting dropped orbs.",
        sw / 2 - 300,
        sh / 2 + 30,
        32,
        @raylib.Color::new(226, 232, 244, 238),
      )
      @raylib.draw_text(
        "Press ENTER to start",
        sw / 2 - 190,
        sh / 2 + 92,
        44,
        @raylib.Color::new(252, 238, 174, 255),
      )
    }

    if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 24, 20, 188))
      @raylib.draw_text(
        "RITUAL COMPLETE",
        sw / 2 - 276,
        sh / 2 - 82,
        74,
        @raylib.Color::new(214, 252, 214, 255),
      )
      @raylib.draw_text(
        "Score \{mage.score}   HP \{mage.hp.to_int()}   Mana \{mage.mana.to_int()}",
        sw / 2 - 324,
        sh / 2 + 8,
        38,
        @raylib.Color::new(236, 246, 238, 248),
      )
      @raylib.draw_text(
        "Press ENTER for next ritual",
        sw / 2 - 250,
        sh / 2 + 70,
        40,
        @raylib.Color::new(252, 238, 176, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 8, 8, 198))
      @raylib.draw_text(
        "RITUAL BROKEN",
        sw / 2 - 258,
        sh / 2 - 82,
        74,
        @raylib.Color::new(252, 192, 182, 255),
      )
      @raylib.draw_text(
        "Score \{mage.score}   Time \{timer.to_int()}s",
        sw / 2 - 204,
        sh / 2 + 8,
        38,
        @raylib.Color::new(246, 228, 220, 248),
      )
      @raylib.draw_text(
        "Press ENTER to retry",
        sw / 2 - 184,
        sh / 2 + 70,
        40,
        @raylib.Color::new(252, 228, 174, 255),
      )
    }

    draw_touch_controls(true)
  }
}
