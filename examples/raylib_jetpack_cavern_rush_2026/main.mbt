///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let seg_w : Float = 40.0

///|
let seg_count : Int = 210

///|
let world_w : Float = seg_w * Float::from_int(seg_count)

///|
let world_h : Float = 820.0

///|
let max_enemies : Int = 64

///|
let max_projectiles : Int = 620

///|
let max_crystals : Int = 120

///|
let max_particles : Int = 1600

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut hp : Float
  mut fuel : Float
  mut fire_cd : Float
  mut pulse_cd : Float
  mut storm_cd : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
  mut shake_t : Float
  mut crystals : Int
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
  mut fire_cd : Float
  mut bite_cd : Float
  mut burn_t : Float
  mut slow_t : Float
  mut shock_t : Float
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
struct Crystal {
  mut active : Bool
  x : Float
  y : Float
  value : Int
  mut spin_t : Float
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
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
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
fn sample_line(line : FixedArray[Float], x : Float) -> Float {
  let fx : Float = x / seg_w
  let i0 : Int = clampi(fx.to_int(), 0, seg_count - 1)
  let i1 : Int = i0 + 1
  let t : Float = fx - Float::from_int(i0)
  line[i0] + (line[i1] - line[i0]) * t
}

///|
fn generate_cave(
  cave_top : FixedArray[Float],
  cave_bottom : FixedArray[Float],
) -> Unit {
  let mut top : Float = 150.0
  let mut gap : Float = 360.0

  for i = 0; i <= seg_count; i = i + 1 {
    top = top + randf(-28.0, 28.0)
    top = clampf(top, 90.0, 300.0)

    gap = gap + randf(-36.0, 36.0)
    gap = clampf(gap, 250.0, 430.0)

    let mut bottom : Float = top + gap
    if bottom > world_h - 70.0 {
      top = world_h - 70.0 - gap
      if top < 80.0 {
        top = 80.0
      }
      bottom = top + gap
    }

    cave_top[i] = top
    cave_bottom[i] = bottom
  }
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
  for i = 0; i < particles.length(); i = i + 1 {
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
  for i = 0; i < projectiles.length(); i = i + 1 {
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
fn init_crystals(
  crystals : FixedArray[Crystal],
  cave_top : FixedArray[Float],
  cave_bottom : FixedArray[Float],
  target : Int,
) -> Unit {
  for i = 0; i < crystals.length(); i = i + 1 {
    let frac : Float = Float::from_int(i) / Float::from_int(crystals.length())
    let x : Float = 180.0 + frac * (world_w - 360.0) + randf(-42.0, 42.0)
    let top : Float = sample_line(cave_top, x)
    let bottom : Float = sample_line(cave_bottom, x)
    let y : Float = randf(top + 34.0, bottom - 34.0)

    crystals[i] = {
      active: i < target + 20,
      x,
      y,
      value: 15 + @raylib.get_random_value(0, 30),
      spin_t: randf(0.0, 5.0),
    }
  }
}

///|
fn spawn_enemy(
  enemies : FixedArray[Enemy],
  level : Int,
  player_x : Float,
  cave_top : FixedArray[Float],
  cave_bottom : FixedArray[Float],
) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].active) {
      let kind : Int = if @raylib.get_random_value(0, 100) < 22 + level * 6 {
        1
      } else {
        0
      }
      let x : Float = clampf(
        player_x + randf(520.0, 980.0),
        100.0,
        world_w - 100.0,
      )
      let top : Float = sample_line(cave_top, x)
      let bottom : Float = sample_line(cave_bottom, x)
      let y : Float = randf(top + 34.0, bottom - 34.0)

      enemies[i] = {
        active: true,
        kind,
        x,
        y,
        vx: randf(-20.0, 20.0),
        vy: randf(-18.0, 18.0),
        hp: if kind == 0 {
          64.0 + Float::from_int(level - 1) * 10.0
        } else {
          128.0 + Float::from_int(level - 1) * 18.0
        },
        fire_cd: randf(0.2, 1.2),
        bite_cd: randf(0.0, 0.4),
        burn_t: 0.0,
        slow_t: 0.0,
        shock_t: 0.0,
      }
      break
    }
  }
}

///|
fn init_wave(
  enemies : FixedArray[Enemy],
  level : Int,
  player_x : Float,
  cave_top : FixedArray[Float],
  cave_bottom : FixedArray[Float],
) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].active = false
  }
  let initial : Int = 12 + level * 4
  for i = 0; i < initial; i = i + 1 {
    spawn_enemy(enemies, level, player_x, cave_top, cave_bottom)
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
    @raylib.Color::new(226, 236, 248, 170),
  )
}

///|
fn draw_touch_controls(show : Bool) -> Unit {
  if not(show) {
    return
  }

  let bx : Int = 24
  let by : Int = sh - 226
  let ax : Int = sw - 244

  @raylib.draw_rectangle(
    bx,
    by + 70,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 86),
  )
  @raylib.draw_text(
    "L",
    bx + 30,
    by + 96,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    bx + 168,
    by + 70,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 86),
  )
  @raylib.draw_text(
    "R",
    bx + 198,
    by + 96,
    30,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    bx + 84,
    by,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 86),
  )
  @raylib.draw_text(
    "UP",
    bx + 103,
    by + 24,
    26,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    ax,
    by + 8,
    214,
    58,
    @raylib.Color::new(220, 118, 86, 94),
  )
  @raylib.draw_text(
    "FIRE",
    ax + 78,
    by + 27,
    24,
    @raylib.Color::new(252, 244, 232, 230),
  )

  @raylib.draw_rectangle(
    ax,
    by + 72,
    104,
    58,
    @raylib.Color::new(118, 198, 248, 94),
  )
  @raylib.draw_text(
    "PULSE",
    ax + 16,
    by + 91,
    20,
    @raylib.Color::new(238, 248, 255, 230),
  )

  @raylib.draw_rectangle(
    ax + 110,
    by + 72,
    104,
    58,
    @raylib.Color::new(158, 142, 252, 94),
  )
  @raylib.draw_text(
    "STORM",
    ax + 126,
    by + 91,
    20,
    @raylib.Color::new(246, 240, 255, 230),
  )

  @raylib.draw_rectangle(
    ax,
    by + 136,
    214,
    66,
    @raylib.Color::new(112, 212, 160, 94),
  )
  @raylib.draw_text(
    "DASH",
    ax + 84,
    by + 159,
    26,
    @raylib.Color::new(242, 252, 246, 230),
  )
}

///|
fn main {
  @raylib.init_window(
    sw, sh, "raylib [moonbit] example - jetpack cavern rush 2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(60)

  let cave_top : FixedArray[Float] = FixedArray::make(seg_count + 1, 0.0)
  let cave_bottom : FixedArray[Float] = FixedArray::make(seg_count + 1, 0.0)

  let enemies = FixedArray::make(max_enemies, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    fire_cd: 0.0,
    bite_cd: 0.0,
    burn_t: 0.0,
    slow_t: 0.0,
    shock_t: 0.0,
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

  let crystals = FixedArray::make(max_crystals, {
    active: false,
    x: 0.0,
    y: 0.0,
    value: 0,
    spin_t: 0.0,
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

  let player = {
    x: 140.0,
    y: world_h * 0.5,
    vx: 0.0,
    vy: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    hp: 280.0,
    fuel: 220.0,
    fire_cd: 0.0,
    pulse_cd: 0.0,
    storm_cd: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    crystals: 0,
    score: 0,
    combo: 0,
  }

  let mut level : Int = 1
  let mut timer : Float = 194.0
  let mut spawn_cd : Float = 0.9
  let mut state : Int = 0
  let mut announce_t : Float = 0.0
  let mut target_crystals : Int = 42

  let reset_round = fn(new_level : Int) {
    level = new_level
    timer = 198.0 - Float::from_int(level - 1) * 9.0
    if timer < 108.0 {
      timer = 108.0
    }

    target_crystals = 42 + (level - 1) * 6
    if target_crystals > 70 {
      target_crystals = 70
    }

    generate_cave(cave_top, cave_bottom)

    player.x = 140.0
    player.y = world_h * 0.5
    player.vx = 0.0
    player.vy = 0.0
    player.aim_x = 1.0
    player.aim_y = 0.0
    player.hp = 280.0
    player.fuel = 220.0
    player.fire_cd = 0.0
    player.pulse_cd = 0.0
    player.storm_cd = 0.0
    player.dash_t = 0.0
    player.dash_cd = 0.0
    player.hit_cd = 0.0
    player.flash_t = 0.0
    player.shake_t = 0.0
    player.crystals = 0
    player.score = 0
    player.combo = 0

    for i = 0; i < projectiles.length(); i = i + 1 {
      projectiles[i].active = false
    }
    for i = 0; i < particles.length(); i = i + 1 {
      particles[i].active = false
    }

    init_wave(enemies, level, player.x, cave_top, cave_bottom)
    init_crystals(crystals, cave_top, cave_bottom, target_crystals)

    spawn_cd = 0.8
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

    let mut cam_x : Float = player.x - Float::from_int(sw) * 0.38
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }

    let mouse = @raylib.get_mouse_position()
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyRight)
    let mut thrust_down : Bool = @raylib.is_key_down(@raylib.KeyW) ||
      @raylib.is_key_down(@raylib.KeyUp)
    let mut fire_down : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
    let mut storm_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)
    let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
      @raylib.is_key_pressed(@raylib.KeyLeftShift)

    let bx : Int = 24
    let by : Int = sh - 226
    let ax : Int = sw - 244

    if touching {
      if inside_rect(mouse.x, mouse.y, bx, by + 70, 78, 78) {
        move_l = true
      }
      if inside_rect(mouse.x, mouse.y, bx + 168, by + 70, 78, 78) {
        move_r = true
      }
      if inside_rect(mouse.x, mouse.y, bx + 84, by, 78, 78) {
        thrust_down = true
      }
      if inside_rect(mouse.x, mouse.y, ax, by + 8, 214, 58) {
        fire_down = true
      }
      if inside_rect(mouse.x, mouse.y, ax, by + 72, 104, 58) {
        pulse_press = true
      }
      if inside_rect(mouse.x, mouse.y, ax + 110, by + 72, 104, 58) {
        storm_press = true
      }
      if inside_rect(mouse.x, mouse.y, ax, by + 136, 214, 66) {
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

      if player.fire_cd > 0.0 {
        player.fire_cd = player.fire_cd - dt
        if player.fire_cd < 0.0 {
          player.fire_cd = 0.0
        }
      }
      if player.pulse_cd > 0.0 {
        player.pulse_cd = player.pulse_cd - dt
        if player.pulse_cd < 0.0 {
          player.pulse_cd = 0.0
        }
      }
      if player.storm_cd > 0.0 {
        player.storm_cd = player.storm_cd - dt
        if player.storm_cd < 0.0 {
          player.storm_cd = 0.0
        }
      }
      if player.dash_t > 0.0 {
        player.dash_t = player.dash_t - dt
        if player.dash_t < 0.0 {
          player.dash_t = 0.0
        }
      }
      if player.dash_cd > 0.0 {
        player.dash_cd = player.dash_cd - dt
        if player.dash_cd < 0.0 {
          player.dash_cd = 0.0
        }
      }
      if player.hit_cd > 0.0 {
        player.hit_cd = player.hit_cd - dt
        if player.hit_cd < 0.0 {
          player.hit_cd = 0.0
        }
      }
      if player.flash_t > 0.0 {
        player.flash_t = player.flash_t - dt
        if player.flash_t < 0.0 {
          player.flash_t = 0.0
        }
      }
      if player.shake_t > 0.0 {
        player.shake_t = player.shake_t - dt
        if player.shake_t < 0.0 {
          player.shake_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      player.fuel = player.fuel + dt * 6.0
      if player.fuel > 220.0 {
        player.fuel = 220.0
      }

      let mut ix : Float = 0.0
      if move_l {
        ix = ix - 1.0
      }
      if move_r {
        ix = ix + 1.0
      }

      let accel_x : Float = if player.dash_t > 0.0 { 760.0 } else { 420.0 }
      let max_speed_x : Float = if player.dash_t > 0.0 { 540.0 } else { 320.0 }
      let drag_x : Float = if player.dash_t > 0.0 { 1.0 } else { 1.9 }

      let mut thrust_force : Float = 0.0
      if thrust_down && player.fuel > 0.0 {
        thrust_force = 420.0
        player.fuel = player.fuel - dt * 24.0
        if player.fuel < 0.0 {
          player.fuel = 0.0
        }
      }

      let gravity : Float = 210.0

      player.vx = player.vx + (ix * accel_x - player.vx * drag_x) * dt
      player.vy = player.vy + (gravity - thrust_force - player.vy * 0.85) * dt

      if player.vx > max_speed_x {
        player.vx = max_speed_x
      }
      if player.vx < -max_speed_x {
        player.vx = -max_speed_x
      }
      if player.vy > 360.0 {
        player.vy = 360.0
      }
      if player.vy < -360.0 {
        player.vy = -360.0
      }

      let aim_world_x : Float = cam_x + mouse.x
      let aim_world_y : Float = mouse.y
      let adx : Float = aim_world_x - player.x
      let ady : Float = aim_world_y - player.y
      let ad2 : Float = adx * adx + ady * ady
      if ad2 >= 9.0 {
        let inv : Float = 1.0 / ad2.sqrt()
        player.aim_x = adx * inv
        player.aim_y = ady * inv
      } else {
        let sp2 : Float = player.vx * player.vx + player.vy * player.vy
        if sp2 > 24.0 {
          let sp : Float = sp2.sqrt()
          let inv : Float = 1.0 / sp
          player.aim_x = player.vx * inv
          player.aim_y = player.vy * inv
        }
      }

      if dash_press && player.dash_cd <= 0.0 && player.fuel >= 28.0 {
        player.fuel = player.fuel - 28.0
        player.dash_t = 0.24
        player.dash_cd = 2.0
        player.vx = player.vx + player.aim_x * 260.0
        player.vy = player.vy + player.aim_y * 260.0
        burst_particles(particles, player.x, player.y, 24, 132.0, 2)
      }

      if fire_down && player.fire_cd <= 0.0 && player.fuel >= 6.0 {
        player.fuel = player.fuel - 6.0
        player.fire_cd = if player.dash_t > 0.0 { 0.06 } else { 0.095 }
        let speed : Float = 700.0
        let dmg : Float = if player.dash_t > 0.0 { 44.0 } else { 34.0 }
        spawn_projectile(
          projectiles,
          0,
          true,
          player.x + player.aim_x * 20.0,
          player.y + player.aim_y * 20.0,
          player.aim_x * speed,
          player.aim_y * speed,
          dmg,
          1.1,
        )
      }

      if pulse_press && player.pulse_cd <= 0.0 && player.fuel >= 40.0 {
        player.fuel = player.fuel - 40.0
        player.pulse_cd = 5.8
        burst_particles(particles, player.x, player.y, 58, 160.0, 1)
        for i = 0; i < enemies.length(); i = i + 1 {
          if not(enemies[i].active) {
            continue
          }
          let d2 : Float = dist2(player.x, player.y, enemies[i].x, enemies[i].y)
          if d2 <= 240.0 * 240.0 {
            enemies[i].hp = enemies[i].hp - 28.0
            enemies[i].slow_t = enemies[i].slow_t + 2.4
          }
        }
      }

      if storm_press && player.storm_cd <= 0.0 && player.fuel >= 56.0 {
        player.fuel = player.fuel - 56.0
        player.storm_cd = 7.6
        for k = 0; k < 7; k = k + 1 {
          let mut best : Int = -1
          let mut best_d2 : Float = 99999999.0
          for i = 0; i < enemies.length(); i = i + 1 {
            if not(enemies[i].active) {
              continue
            }
            let d2 : Float = dist2(
              player.x,
              player.y,
              enemies[i].x,
              enemies[i].y,
            )
            if d2 < best_d2 && d2 <= 420.0 * 420.0 && enemies[i].shock_t <= 0.08 {
              best = i
              best_d2 = d2
            }
          }
          if best >= 0 {
            enemies[best].hp = enemies[best].hp - 46.0
            enemies[best].shock_t = 1.4
            player.combo = player.combo + 1
            if player.combo > 60 {
              player.combo = 60
            }
            burst_particles(
              particles,
              enemies[best].x,
              enemies[best].y,
              20,
              112.0,
              2,
            )
          }
        }
      }

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      if player.x < 24.0 {
        player.x = 24.0
        player.vx = player.vx.abs() * 0.2
      }
      if player.x > world_w - 24.0 {
        player.x = world_w - 24.0
        player.vx = -player.vx.abs() * 0.2
      }

      let top : Float = sample_line(cave_top, player.x)
      let bottom : Float = sample_line(cave_bottom, player.x)
      let pr : Float = 16.0

      if player.y - pr < top + 4.0 {
        player.y = top + pr + 4.0
        player.vy = player.vy.abs() * 0.2
        if player.hit_cd <= 0.0 {
          player.hp = player.hp - 14.0
          player.hit_cd = 0.38
          player.flash_t = 0.16
          player.shake_t = 0.2
        }
      }
      if player.y + pr > bottom - 4.0 {
        player.y = bottom - pr - 4.0
        player.vy = -player.vy.abs() * 0.2
        if player.hit_cd <= 0.0 {
          player.hp = player.hp - 14.0
          player.hit_cd = 0.38
          player.flash_t = 0.16
          player.shake_t = 0.2
        }
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, level, player.x, cave_top, cave_bottom)
        let mut next : Float = 0.9 - Float::from_int(level - 1) * 0.06
        if next < 0.24 {
          next = 0.24
        }
        spawn_cd = next
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        if enemies[i].burn_t > 0.0 {
          enemies[i].burn_t = enemies[i].burn_t - dt
          if enemies[i].burn_t < 0.0 {
            enemies[i].burn_t = 0.0
          }
          enemies[i].hp = enemies[i].hp - dt * 12.0
        }
        if enemies[i].slow_t > 0.0 {
          enemies[i].slow_t = enemies[i].slow_t - dt
          if enemies[i].slow_t < 0.0 {
            enemies[i].slow_t = 0.0
          }
        }
        if enemies[i].shock_t > 0.0 {
          enemies[i].shock_t = enemies[i].shock_t - dt
          if enemies[i].shock_t < 0.0 {
            enemies[i].shock_t = 0.0
          }
        }
        if enemies[i].fire_cd > 0.0 {
          enemies[i].fire_cd = enemies[i].fire_cd - dt
          if enemies[i].fire_cd < 0.0 {
            enemies[i].fire_cd = 0.0
          }
        }
        if enemies[i].bite_cd > 0.0 {
          enemies[i].bite_cd = enemies[i].bite_cd - dt
          if enemies[i].bite_cd < 0.0 {
            enemies[i].bite_cd = 0.0
          }
        }

        let dx : Float = player.x - enemies[i].x
        let dy : Float = player.y - enemies[i].y
        let d2 : Float = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        let base_speed : Float = if enemies[i].kind == 0 {
          176.0
        } else {
          130.0
        }
        let level_gain : Float = if enemies[i].kind == 0 { 16.0 } else { 12.0 }
        let mut speed : Float = base_speed +
          Float::from_int(level - 1) * level_gain
        if enemies[i].slow_t > 0.0 {
          speed = speed * 0.56
        }
        if enemies[i].shock_t > 0.0 {
          speed = speed * 0.34
        }

        let tx : Float = dx / d * speed
        let ty : Float = dy / d * speed

        enemies[i].vx = enemies[i].vx + (tx - enemies[i].vx * 2.0) * dt
        enemies[i].vy = enemies[i].vy + (ty - enemies[i].vy * 2.0) * dt

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt

        let etop : Float = sample_line(cave_top, enemies[i].x)
        let ebottom : Float = sample_line(cave_bottom, enemies[i].x)
        if enemies[i].y < etop + 18.0 {
          enemies[i].y = etop + 18.0
          enemies[i].vy = enemies[i].vy.abs() * 0.2
        }
        if enemies[i].y > ebottom - 18.0 {
          enemies[i].y = ebottom - 18.0
          enemies[i].vy = -enemies[i].vy.abs() * 0.2
        }

        if enemies[i].bite_cd <= 0.0 &&
          dist2(enemies[i].x, enemies[i].y, player.x, player.y) <= 30.0 * 30.0 {
          enemies[i].bite_cd = 0.62
          if player.hit_cd <= 0.0 {
            let bite_dmg : Float = if enemies[i].kind == 0 {
              12.0
            } else {
              20.0
            }
            player.hp = player.hp - bite_dmg
            player.hit_cd = 0.42
            player.flash_t = 0.18
            player.shake_t = 0.22
            player.combo = 0
            burst_particles(particles, player.x, player.y, 18, 98.0, 2)
          }
        }

        if enemies[i].kind == 1 &&
          enemies[i].fire_cd <= 0.0 &&
          d <= 460.0 &&
          enemies[i].shock_t <= 0.0 {
          enemies[i].fire_cd = 1.2
          let inv : Float = if d2 < 1.0 { 0.0 } else { 1.0 / d2.sqrt() }
          spawn_projectile(
            projectiles,
            2,
            false,
            enemies[i].x,
            enemies[i].y,
            dx * inv * 360.0,
            dy * inv * 360.0,
            16.0,
            2.1,
          )
        }
      }

      for i = 0; i < projectiles.length(); i = i + 1 {
        if not(projectiles[i].active) {
          continue
        }

        projectiles[i].life = projectiles[i].life - dt
        if projectiles[i].life <= 0.0 {
          projectiles[i].active = false
          continue
        }

        projectiles[i].x = projectiles[i].x + projectiles[i].vx * dt
        projectiles[i].y = projectiles[i].y + projectiles[i].vy * dt

        if projectiles[i].x < 0.0 ||
          projectiles[i].y < 0.0 ||
          projectiles[i].x > world_w ||
          projectiles[i].y > world_h {
          projectiles[i].active = false
          continue
        }

        if projectiles[i].from_player {
          for j = 0; j < enemies.length(); j = j + 1 {
            if not(enemies[j].active) {
              continue
            }
            if dist2(
                projectiles[i].x,
                projectiles[i].y,
                enemies[j].x,
                enemies[j].y,
              ) <=
              22.0 * 22.0 {
              enemies[j].hp = enemies[j].hp - projectiles[i].dmg
              if projectiles[i].kind == 0 {
                enemies[j].burn_t = enemies[j].burn_t + 1.8
              }
              burst_particles(
                particles,
                projectiles[i].x,
                projectiles[i].y,
                6,
                58.0,
                0,
              )
              projectiles[i].active = false
              break
            }
          }
        } else if dist2(projectiles[i].x, projectiles[i].y, player.x, player.y) <=
          24.0 * 24.0 {
          if player.hit_cd <= 0.0 {
            player.hp = player.hp - projectiles[i].dmg
            player.hit_cd = 0.34
            player.flash_t = 0.14
            player.shake_t = 0.2
          }
          burst_particles(
            particles,
            projectiles[i].x,
            projectiles[i].y,
            10,
            72.0,
            2,
          )
          projectiles[i].active = false
        }
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        if enemies[i].hp <= 0.0 {
          enemies[i].active = false
          let kill_score : Int = if enemies[i].kind == 0 { 22 } else { 54 }
          player.score = player.score + kill_score + player.combo
          player.combo = player.combo + 1
          if player.combo > 60 {
            player.combo = 60
          }

          burst_particles(
            particles,
            enemies[i].x,
            enemies[i].y,
            22,
            96.0,
            if enemies[i].kind == 0 {
              0
            } else {
              2
            },
          )
        }
      }

      for i = 0; i < crystals.length(); i = i + 1 {
        if not(crystals[i].active) {
          continue
        }

        crystals[i].spin_t = crystals[i].spin_t + dt
        if dist2(player.x, player.y, crystals[i].x, crystals[i].y) <=
          28.0 * 28.0 {
          crystals[i].active = false
          player.crystals = player.crystals + 1
          player.score = player.score + crystals[i].value + player.combo * 2
          player.fuel = player.fuel + 18.0
          if player.fuel > 220.0 {
            player.fuel = 220.0
          }
          burst_particles(particles, crystals[i].x, crystals[i].y, 16, 70.0, 1)
        }
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

      if player.hp <= 0.0 {
        state = 3
      } else if timer <= 0.0 {
        state = 3
      } else if player.crystals >= target_crystals &&
        player.x >= world_w - 240.0 {
        player.score = player.score + player.hp.to_int() + player.fuel.to_int()
        state = 2
      }
    }

    let shake_x : Float = if player.shake_t > 0.0 {
      randf(-6.0, 6.0) * (player.shake_t * 3.8)
    } else {
      0.0
    }
    let shake_y : Float = if player.shake_t > 0.0 {
      randf(-4.0, 4.0) * (player.shake_t * 3.8)
    } else {
      0.0
    }

    cam_x = player.x - Float::from_int(sw) * 0.38
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(10, 16, 28, 255))

    let start_seg : Int = clampi((cam_x / seg_w).to_int() - 2, 0, seg_count - 1)
    let end_seg : Int = clampi(
      start_seg + sw / seg_w.to_int() + 6,
      0,
      seg_count - 1,
    )

    for i = start_seg; i <= end_seg; i = i + 1 {
      let x0 : Float = Float::from_int(i) * seg_w - cam_x + shake_x
      let top0 : Float = cave_top[i] + shake_y
      let top1 : Float = cave_top[i + 1] + shake_y
      let bottom0 : Float = cave_bottom[i] + shake_y
      let bottom1 : Float = cave_bottom[i + 1] + shake_y

      let top_avg : Float = (top0 + top1) * 0.5
      let bottom_avg : Float = (bottom0 + bottom1) * 0.5

      @raylib.draw_rectangle(
        x0.to_int(),
        0,
        seg_w.to_int() + 1,
        top_avg.to_int(),
        @raylib.Color::new(38, 48, 66, 255),
      )
      @raylib.draw_rectangle(
        x0.to_int(),
        bottom_avg.to_int(),
        seg_w.to_int() + 1,
        sh - bottom_avg.to_int(),
        @raylib.Color::new(38, 48, 66, 255),
      )

      @raylib.draw_line(
        x0.to_int(),
        top_avg.to_int(),
        (x0 + seg_w).to_int(),
        ((top_avg + top1) * 0.5).to_int(),
        @raylib.Color::new(116, 132, 158, 210),
      )
      @raylib.draw_line(
        x0.to_int(),
        bottom_avg.to_int(),
        (x0 + seg_w).to_int(),
        ((bottom_avg + bottom1) * 0.5).to_int(),
        @raylib.Color::new(116, 132, 158, 210),
      )
    }

    let exit_x : Float = world_w - cam_x - 180.0 + shake_x
    let exit_top : Float = sample_line(cave_top, world_w - 180.0) + shake_y
    let exit_bottom : Float = sample_line(cave_bottom, world_w - 180.0) +
      shake_y
    let exit_mid : Float = (exit_top + exit_bottom) * 0.5
    @raylib.draw_circle(
      exit_x.to_int(),
      exit_mid.to_int(),
      34.0,
      @raylib.Color::new(138, 228, 252, 180),
    )
    @raylib.draw_circle(
      exit_x.to_int(),
      exit_mid.to_int(),
      18.0,
      @raylib.Color::new(222, 248, 255, 220),
    )

    for i = 0; i < crystals.length(); i = i + 1 {
      if not(crystals[i].active) {
        continue
      }
      let cx : Float = crystals[i].x - cam_x + shake_x
      let cy : Float = crystals[i].y + shake_y
      if cx < -24.0 ||
        cy < -24.0 ||
        cx > Float::from_int(sw + 24) ||
        cy > Float::from_int(sh + 24) {
        continue
      }

      let pulse : Float = 1.0 + @math.sinf(crystals[i].spin_t * 4.0) * 0.12
      @raylib.draw_circle(
        cx.to_int(),
        cy.to_int(),
        10.0 * pulse,
        @raylib.Color::new(128, 216, 252, 220),
      )
      @raylib.draw_rectangle(
        (cx - 5.0).to_int(),
        (cy - 9.0).to_int(),
        10,
        18,
        @raylib.Color::new(194, 236, 255, 255),
      )
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if not(enemies[i].active) {
        continue
      }
      let ex : Float = enemies[i].x - cam_x + shake_x
      let ey : Float = enemies[i].y + shake_y
      if ex < -80.0 ||
        ey < -80.0 ||
        ex > Float::from_int(sw + 80) ||
        ey > Float::from_int(sh + 80) {
        continue
      }

      let col = if enemies[i].shock_t > 0.0 {
        @raylib.Color::new(154, 216, 252, 255)
      } else if enemies[i].slow_t > 0.0 {
        @raylib.Color::new(170, 186, 252, 255)
      } else if enemies[i].kind == 0 {
        @raylib.Color::new(234, 108, 94, 255)
      } else {
        @raylib.Color::new(248, 160, 96, 255)
      }

      let r : Float = if enemies[i].kind == 0 { 14.0 } else { 18.0 }
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

      if enemies[i].burn_t > 0.0 {
        @raylib.draw_circle_lines(
          ex.to_int(),
          ey.to_int(),
          r + 4.0,
          @raylib.Color::new(252, 162, 98, 220),
        )
      }
    }

    for i = 0; i < projectiles.length(); i = i + 1 {
      if not(projectiles[i].active) {
        continue
      }
      let px : Float = projectiles[i].x - cam_x + shake_x
      let py : Float = projectiles[i].y + shake_y
      if px < -8.0 ||
        py < -8.0 ||
        px > Float::from_int(sw + 8) ||
        py > Float::from_int(sh + 8) {
        continue
      }

      let col = if projectiles[i].from_player {
        @raylib.Color::new(252, 220, 132, 255)
      } else {
        @raylib.Color::new(242, 146, 146, 255)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        if projectiles[i].from_player {
          4.0
        } else {
          3.0
        },
        col,
      )
    }

    let hx : Float = player.x - cam_x + shake_x
    let hy : Float = player.y + shake_y

    let hcol = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 242, 188, 255)
    } else if player.dash_t > 0.0 {
      @raylib.Color::new(132, 236, 204, 255)
    } else {
      @raylib.Color::new(118, 214, 252, 255)
    }

    @raylib.draw_circle(hx.to_int(), hy.to_int(), 16.0, hcol)
    @raylib.draw_rectangle(
      (hx - 10.0).to_int(),
      (hy - 6.0).to_int(),
      20,
      12,
      @raylib.Color::new(42, 64, 92, 255),
    )
    @raylib.draw_line(
      hx.to_int(),
      hy.to_int(),
      (hx + player.aim_x * 24.0).to_int(),
      (hy + player.aim_y * 24.0).to_int(),
      @raylib.Color::new(246, 248, 252, 255),
    )

    if player.vy > 20.0 || player.vy < -20.0 {
      emit_particle(
        particles,
        player.x - 12.0,
        player.y + 14.0,
        randf(-40.0, -10.0),
        randf(-20.0, 20.0),
        randf(1.8, 3.6),
        randf(0.15, 0.32),
        1,
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let px : Float = particles[i].x - cam_x + shake_x
      let py : Float = particles[i].y + shake_y
      if px < -20.0 ||
        py < -20.0 ||
        px > Float::from_int(sw + 20) ||
        py > Float::from_int(sh + 20) {
        continue
      }

      let life_r : Float = 1.0 - particles[i].t / particles[i].life
      let alpha : Int = clampf(life_r * 220.0, 0.0, 220.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(252, 186, 122, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(132, 216, 252, alpha)
      } else {
        @raylib.Color::new(194, 164, 252, alpha)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        particles[i].size * life_r,
        col,
      )
    }

    @raylib.draw_rectangle(
      16,
      14,
      640,
      206,
      @raylib.Color::new(12, 20, 34, 205),
    )
    @raylib.draw_rectangle_lines(
      16,
      14,
      640,
      206,
      @raylib.Color::new(224, 236, 250, 138),
    )

    @raylib.draw_text(
      "JETPACK CAVERN RUSH 2026",
      30,
      22,
      34,
      @raylib.Color::new(236, 244, 254, 250),
    )
    @raylib.draw_text(
      "Move:A/D  Thrust:W  Fire:J/Mouse  Pulse:K  Storm:L  Dash:Shift",
      32,
      62,
      20,
      @raylib.Color::new(190, 208, 236, 244),
    )

    draw_bar(
      30,
      94,
      242,
      20,
      player.hp / 280.0,
      @raylib.Color::new(232, 130, 118, 255),
      @raylib.Color::new(90, 52, 52, 230),
    )
    @raylib.draw_text("HP", 278, 92, 22, @raylib.Color::new(216, 230, 244, 244))

    draw_bar(
      30,
      122,
      242,
      20,
      player.fuel / 220.0,
      @raylib.Color::new(118, 206, 252, 255),
      @raylib.Color::new(56, 78, 94, 230),
    )
    @raylib.draw_text(
      "Fuel",
      278,
      120,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    let dash_ready : Float = if player.dash_cd <= 0.0 {
      1.0
    } else {
      1.0 - player.dash_cd / 2.0
    }
    draw_bar(
      30,
      150,
      242,
      20,
      dash_ready,
      @raylib.Color::new(144, 232, 186, 255),
      @raylib.Color::new(56, 90, 74, 230),
    )
    @raylib.draw_text(
      "Dash",
      278,
      148,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    @raylib.draw_text(
      "Crystals \{player.crystals}/\{target_crystals}   Score \{player.score}   Combo x\{player.combo}",
      32,
      184,
      24,
      @raylib.Color::new(250, 240, 206, 248),
    )

    let pulse_text = if player.pulse_cd <= 0.0 {
      "Pulse READY"
    } else {
      "Pulse CD \{player.pulse_cd.to_int()}"
    }
    let storm_text = if player.storm_cd <= 0.0 {
      "Storm READY"
    } else {
      "Storm CD \{player.storm_cd.to_int()}"
    }

    @raylib.draw_text(
      "Time: \{timer.to_int()}s",
      sw - 344,
      24,
      34,
      @raylib.Color::new(246, 246, 252, 250),
    )
    @raylib.draw_text(
      pulse_text,
      sw - 344,
      64,
      24,
      @raylib.Color::new(170, 222, 252, 248),
    )
    @raylib.draw_text(
      storm_text,
      sw - 344,
      90,
      24,
      @raylib.Color::new(210, 192, 252, 248),
    )

    if announce_t > 0.0 {
      let alpha : Int = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Collect enough crystals, then reach the portal at the cavern end.",
        sw / 2 - 420,
        224,
        34,
        @raylib.Color::new(244, 248, 252, alpha),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))
      @raylib.draw_text(
        "JETPACK CAVERN RUSH",
        sw / 2 - 380,
        sh / 2 - 116,
        78,
        @raylib.Color::new(238, 246, 252, 255),
      )
      @raylib.draw_text(
        "Fly the unstable tunnel and collect crystal charge.",
        sw / 2 - 360,
        sh / 2 - 12,
        34,
        @raylib.Color::new(192, 216, 242, 246),
      )
      @raylib.draw_text(
        "Fight guardians, manage fuel, and escape through portal.",
        sw / 2 - 390,
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
        "ESCAPE COMPLETE",
        sw / 2 - 280,
        sh / 2 - 82,
        74,
        @raylib.Color::new(214, 252, 214, 255),
      )
      @raylib.draw_text(
        "Score \{player.score}   HP \{player.hp.to_int()}   Fuel \{player.fuel.to_int()}",
        sw / 2 - 330,
        sh / 2 + 8,
        38,
        @raylib.Color::new(236, 246, 238, 248),
      )
      @raylib.draw_text(
        "Press ENTER for next run",
        sw / 2 - 230,
        sh / 2 + 70,
        40,
        @raylib.Color::new(252, 238, 176, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 8, 8, 198))
      @raylib.draw_text(
        "RUN FAILED",
        sw / 2 - 188,
        sh / 2 - 82,
        74,
        @raylib.Color::new(252, 192, 182, 255),
      )
      @raylib.draw_text(
        "Crystals \{player.crystals}/\{target_crystals}   Time \{timer.to_int()}s",
        sw / 2 - 336,
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
