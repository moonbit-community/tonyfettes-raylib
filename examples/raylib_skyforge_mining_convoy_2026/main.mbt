///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let world_w : Float = 4600.0

///|
let world_h : Float = 2300.0

///|
let max_enemies : Int = 72

///|
let max_bullets : Int = 640

///|
let max_ores : Int = 120

///|
let max_particles : Int = 1600

///|
let convoy_count : Int = 3

///|
struct Pilot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut hp : Float
  mut energy : Float
  mut fire_cd : Float
  mut pulse_cd : Float
  mut overdrive_t : Float
  mut overdrive_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
  mut shake_t : Float
  mut ore : Int
  mut score : Int
  mut combo : Int
}

///|
struct Truck {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut flash_t : Float
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
  mut slow_t : Float
  mut shock_t : Float
}

///|
struct Bullet {
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
struct Ore {
  mut active : Bool
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
      randf(2.0, 6.0),
      randf(0.2, 1.0),
      kind,
    )
  }
}

///|
fn spawn_bullet(
  bullets : FixedArray[Bullet],
  kind : Int,
  from_player : Bool,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  life : Float,
) -> Unit {
  for i in 0..<bullets.length() {
    if not(bullets[i].active) {
      bullets[i] = { active: true, kind, from_player, x, y, vx, vy, dmg, life }
      break
    }
  }
}

///|
fn spawn_ore(ores : FixedArray[Ore], x : Float, y : Float, value : Int) -> Unit {
  for i in 0..<ores.length() {
    if not(ores[i].active) {
      ores[i] = { active: true, x, y, value, t: 0.0, life: 24.0 }
      break
    }
  }
}

///|
fn spawn_enemy(
  enemies : FixedArray[Enemy],
  level : Int,
  convoy_x : Float,
) -> Unit {
  for i in 0..<enemies.length() {
    if not(enemies[i].active) {
      let kind : Int = if @raylib.get_random_value(0, 100) < 26 + level * 6 {
        1
      } else {
        0
      }
      let side : Int = @raylib.get_random_value(0, 1)
      let x : Float = if side == 0 {
        convoy_x + randf(560.0, 980.0)
      } else {
        convoy_x - randf(540.0, 820.0)
      }
      let y : Float = randf(220.0, world_h - 220.0)

      enemies[i] = {
        active: true,
        kind,
        x: clampf(x, 40.0, world_w - 40.0),
        y,
        vx: randf(-30.0, 30.0),
        vy: randf(-30.0, 30.0),
        hp: if kind == 0 {
          72.0 + Float::from_int(level - 1) * 10.0
        } else {
          138.0 + Float::from_int(level - 1) * 20.0
        },
        fire_cd: randf(0.2, 1.2),
        bite_cd: randf(0.0, 0.5),
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
  convoy_x : Float,
) -> Unit {
  for enemy in enemies {
    enemy.active = false
  }
  let initial : Int = 14 + level * 4
  for i in 0..<initial {
    spawn_enemy(enemies, level, convoy_x)
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
  let by : Int = sh - 228
  let ax : Int = sw - 236

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
    bx + 102,
    by + 24,
    26,
    @raylib.Color::new(244, 248, 252, 220),
  )

  @raylib.draw_rectangle(
    ax,
    by + 8,
    206,
    58,
    @raylib.Color::new(220, 118, 86, 94),
  )
  @raylib.draw_text(
    "FIRE",
    ax + 74,
    by + 28,
    24,
    @raylib.Color::new(252, 244, 232, 230),
  )

  @raylib.draw_rectangle(
    ax,
    by + 72,
    100,
    58,
    @raylib.Color::new(118, 198, 248, 94),
  )
  @raylib.draw_text(
    "PULSE",
    ax + 18,
    by + 91,
    20,
    @raylib.Color::new(238, 248, 255, 230),
  )

  @raylib.draw_rectangle(
    ax + 106,
    by + 72,
    100,
    58,
    @raylib.Color::new(158, 142, 252, 94),
  )
  @raylib.draw_text(
    "STORM",
    ax + 121,
    by + 91,
    20,
    @raylib.Color::new(246, 240, 255, 230),
  )

  @raylib.draw_rectangle(
    ax,
    by + 136,
    206,
    66,
    @raylib.Color::new(112, 212, 160, 94),
  )
  @raylib.draw_text(
    "OVERDRIVE",
    ax + 32,
    by + 158,
    24,
    @raylib.Color::new(242, 252, 246, 230),
  )
}

///|
fn main {
  @raylib.init_window(
    sw, sh, "raylib [moonbit] example - skyforge mining convoy 2026",
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
    fire_cd: 0.0,
    bite_cd: 0.0,
    slow_t: 0.0,
    shock_t: 0.0,
  })

  let bullets = FixedArray::make(max_bullets, {
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

  let ores = FixedArray::make(max_ores, {
    active: false,
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

  let trucks = FixedArray::make(convoy_count, {
    active: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    hp: 0.0,
    flash_t: 0.0,
  })

  let pilot = {
    x: 240.0,
    y: 420.0,
    vx: 0.0,
    vy: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    hp: 300.0,
    energy: 260.0,
    fire_cd: 0.0,
    pulse_cd: 0.0,
    overdrive_t: 0.0,
    overdrive_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    ore: 0,
    score: 0,
    combo: 0,
  }

  let mut level : Int = 1
  let mut timer : Float = 210.0
  let mut spawn_cd : Float = 0.8
  let mut convoy_speed : Float = 88.0
  let mut state : Int = 0
  let mut announce_t : Float = 0.0

  let reset_round = fn(new_level : Int) {
    level = new_level

    timer = 212.0 - Float::from_int(level - 1) * 9.0
    if timer < 114.0 {
      timer = 114.0
    }

    convoy_speed = 88.0 + Float::from_int(level - 1) * 8.0

    pilot.x = 240.0
    pilot.y = 420.0
    pilot.vx = 0.0
    pilot.vy = 0.0
    pilot.aim_x = 1.0
    pilot.aim_y = 0.0
    pilot.hp = 300.0
    pilot.energy = 260.0
    pilot.fire_cd = 0.0
    pilot.pulse_cd = 0.0
    pilot.overdrive_t = 0.0
    pilot.overdrive_cd = 0.0
    pilot.hit_cd = 0.0
    pilot.flash_t = 0.0
    pilot.shake_t = 0.0
    pilot.ore = 0
    pilot.score = 0
    pilot.combo = 0

    let convoy_start : Float = 180.0
    let lane0 : Float = 420.0
    let lane_gap : Float = 180.0

    for i in 0..<trucks.length() {
      trucks[i].active = true
      trucks[i].x = convoy_start - Float::from_int(i) * 150.0
      trucks[i].y = lane0 + Float::from_int(i) * lane_gap
      trucks[i].vx = convoy_speed
      trucks[i].hp = 300.0 + Float::from_int(level - 1) * 36.0
      trucks[i].flash_t = 0.0
    }

    for bullet in bullets {
      bullet.active = false
    }
    for ore in ores {
      ore.active = false
    }
    for particle in particles {
      particle.active = false
    }

    init_wave(enemies, level, convoy_start)

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

    let mut convoy_head_x : Float = 0.0
    for truck in trucks {
      if truck.active && truck.x > convoy_head_x {
        convoy_head_x = truck.x
      }
    }

    let mut cam_x : Float = convoy_head_x - 280.0
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
    let mut overdrive_press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
      @raylib.is_key_pressed(@raylib.KeyLeftShift)

    let bx : Int = 24
    let by : Int = sh - 228
    let ax : Int = sw - 236

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
      if inside_rect(mouse.x, mouse.y, ax, by + 8, 206, 58) {
        fire_down = true
      }
      if inside_rect(mouse.x, mouse.y, ax, by + 72, 100, 58) {
        pulse_press = true
      }
      if inside_rect(mouse.x, mouse.y, ax + 106, by + 72, 100, 58) {
        storm_press = true
      }
      if inside_rect(mouse.x, mouse.y, ax, by + 136, 206, 66) {
        overdrive_press = true
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

      if pilot.fire_cd > 0.0 {
        pilot.fire_cd = pilot.fire_cd - dt
        if pilot.fire_cd < 0.0 {
          pilot.fire_cd = 0.0
        }
      }
      if pilot.pulse_cd > 0.0 {
        pilot.pulse_cd = pilot.pulse_cd - dt
        if pilot.pulse_cd < 0.0 {
          pilot.pulse_cd = 0.0
        }
      }
      if pilot.overdrive_t > 0.0 {
        pilot.overdrive_t = pilot.overdrive_t - dt
        if pilot.overdrive_t < 0.0 {
          pilot.overdrive_t = 0.0
        }
      }
      if pilot.overdrive_cd > 0.0 {
        pilot.overdrive_cd = pilot.overdrive_cd - dt
        if pilot.overdrive_cd < 0.0 {
          pilot.overdrive_cd = 0.0
        }
      }
      if pilot.hit_cd > 0.0 {
        pilot.hit_cd = pilot.hit_cd - dt
        if pilot.hit_cd < 0.0 {
          pilot.hit_cd = 0.0
        }
      }
      if pilot.flash_t > 0.0 {
        pilot.flash_t = pilot.flash_t - dt
        if pilot.flash_t < 0.0 {
          pilot.flash_t = 0.0
        }
      }
      if pilot.shake_t > 0.0 {
        pilot.shake_t = pilot.shake_t - dt
        if pilot.shake_t < 0.0 {
          pilot.shake_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      pilot.energy = pilot.energy + dt * 14.0
      if pilot.energy > 260.0 {
        pilot.energy = 260.0
      }

      let mut ix : Float = 0.0
      if move_l {
        ix = ix - 1.0
      }
      if move_r {
        ix = ix + 1.0
      }

      let accel_x : Float = if pilot.overdrive_t > 0.0 { 780.0 } else { 440.0 }
      let max_speed_x : Float = if pilot.overdrive_t > 0.0 {
        560.0
      } else {
        330.0
      }
      let drag_x : Float = if pilot.overdrive_t > 0.0 { 1.0 } else { 1.9 }

      let mut thrust_force : Float = 0.0
      if thrust_down && pilot.energy > 0.0 {
        thrust_force = 430.0
        pilot.energy = pilot.energy - dt * 24.0
        if pilot.energy < 0.0 {
          pilot.energy = 0.0
        }
      }

      let gravity : Float = 220.0

      pilot.vx = pilot.vx + (ix * accel_x - pilot.vx * drag_x) * dt
      pilot.vy = pilot.vy + (gravity - thrust_force - pilot.vy * 0.85) * dt

      if pilot.vx > max_speed_x {
        pilot.vx = max_speed_x
      }
      if pilot.vx < -max_speed_x {
        pilot.vx = -max_speed_x
      }
      if pilot.vy > 360.0 {
        pilot.vy = 360.0
      }
      if pilot.vy < -360.0 {
        pilot.vy = -360.0
      }

      let aim_world_x : Float = cam_x + mouse.x
      let aim_world_y : Float = mouse.y
      let adx : Float = aim_world_x - pilot.x
      let ady : Float = aim_world_y - pilot.y
      let ad2 : Float = adx * adx + ady * ady
      if ad2 >= 9.0 {
        let inv : Float = 1.0 / ad2.sqrt()
        pilot.aim_x = adx * inv
        pilot.aim_y = ady * inv
      }

      if overdrive_press && pilot.overdrive_cd <= 0.0 && pilot.energy >= 52.0 {
        pilot.energy = pilot.energy - 52.0
        pilot.overdrive_t = 0.36
        pilot.overdrive_cd = 2.2
        pilot.vx = pilot.vx + pilot.aim_x * 260.0
        pilot.vy = pilot.vy + pilot.aim_y * 260.0
        burst_particles(particles, pilot.x, pilot.y, 28, 146.0, 2)
      }

      if fire_down && pilot.fire_cd <= 0.0 && pilot.energy >= 6.0 {
        pilot.energy = pilot.energy - 6.0
        pilot.fire_cd = if pilot.overdrive_t > 0.0 { 0.055 } else { 0.09 }
        let speed : Float = 700.0
        let dmg : Float = if pilot.overdrive_t > 0.0 { 44.0 } else { 34.0 }
        spawn_bullet(
          bullets,
          0,
          true,
          pilot.x + pilot.aim_x * 20.0,
          pilot.y + pilot.aim_y * 20.0,
          pilot.aim_x * speed,
          pilot.aim_y * speed,
          dmg,
          1.1,
        )
      }

      if pulse_press && pilot.pulse_cd <= 0.0 && pilot.energy >= 40.0 {
        pilot.energy = pilot.energy - 40.0
        pilot.pulse_cd = 5.8
        burst_particles(particles, pilot.x, pilot.y, 60, 164.0, 1)
        for enemy in enemies {
          if not(enemy.active) {
            continue
          }
          let d2 : Float = dist2(pilot.x, pilot.y, enemy.x, enemy.y)
          if d2 <= 240.0 * 240.0 {
            enemy.hp = enemy.hp - 30.0
            enemy.slow_t = enemy.slow_t + 2.5
          }
        }
      }

      if storm_press && pilot.overdrive_cd <= 0.0 && pilot.energy >= 56.0 {
        pilot.energy = pilot.energy - 56.0
        for k in 0..<7 {
          let mut best : Int = -1
          let mut best_d2 : Float = 99999999.0
          for i in 0..<enemies.length() {
            if not(enemies[i].active) {
              continue
            }
            let d2 : Float = dist2(pilot.x, pilot.y, enemies[i].x, enemies[i].y)
            if d2 < best_d2 && d2 <= 420.0 * 420.0 && enemies[i].shock_t <= 0.08 {
              best = i
              best_d2 = d2
            }
          }
          if best >= 0 {
            enemies[best].hp = enemies[best].hp - 46.0
            enemies[best].shock_t = 1.4
            pilot.combo = pilot.combo + 1
            if pilot.combo > 60 {
              pilot.combo = 60
            }
            burst_particles(
              particles,
              enemies[best].x,
              enemies[best].y,
              22,
              116.0,
              2,
            )
          }
        }
      }

      pilot.x = pilot.x + pilot.vx * dt
      pilot.y = pilot.y + pilot.vy * dt

      if pilot.x < 24.0 {
        pilot.x = 24.0
        pilot.vx = pilot.vx.abs() * 0.2
      }
      if pilot.x > world_w - 24.0 {
        pilot.x = world_w - 24.0
        pilot.vx = -pilot.vx.abs() * 0.2
      }
      if pilot.y < 90.0 {
        pilot.y = 90.0
        pilot.vy = pilot.vy.abs() * 0.2
      }
      if pilot.y > world_h - 90.0 {
        pilot.y = world_h - 90.0
        pilot.vy = -pilot.vy.abs() * 0.2
      }

      let mut alive_trucks : Int = 0
      for truck in trucks {
        if not(truck.active) {
          continue
        }
        alive_trucks = alive_trucks + 1
        truck.vx = convoy_speed
        truck.x = truck.x + truck.vx * dt
        if truck.x > world_w - 120.0 {
          truck.x = world_w - 120.0
        }

        if truck.flash_t > 0.0 {
          truck.flash_t = truck.flash_t - dt
          if truck.flash_t < 0.0 {
            truck.flash_t = 0.0
          }
        }

        if truck.hp <= 0.0 {
          truck.active = false
          burst_particles(particles, truck.x, truck.y, 32, 100.0, 2)
        }
      }

      if alive_trucks <= 0 {
        state = 3
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, level, convoy_head_x)
        let mut next : Float = 0.88 - Float::from_int(level - 1) * 0.06
        if next < 0.24 {
          next = 0.24
        }
        spawn_cd = next
      }

      for enemy in enemies {
        if not(enemy.active) {
          continue
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
        if enemy.fire_cd > 0.0 {
          enemy.fire_cd = enemy.fire_cd - dt
          if enemy.fire_cd < 0.0 {
            enemy.fire_cd = 0.0
          }
        }
        if enemy.bite_cd > 0.0 {
          enemy.bite_cd = enemy.bite_cd - dt
          if enemy.bite_cd < 0.0 {
            enemy.bite_cd = 0.0
          }
        }

        let mut tx : Float = pilot.x
        let mut ty : Float = pilot.y
        let d2p : Float = dist2(enemy.x, enemy.y, pilot.x, pilot.y)
        if d2p > 260.0 * 260.0 {
          let mut best : Int = -1
          let mut best_d2 : Float = 99999999.0
          for j in 0..<trucks.length() {
            if not(trucks[j].active) {
              continue
            }
            let d2 : Float = dist2(
              enemy.x,
              enemy.y,
              trucks[j].x,
              trucks[j].y,
            )
            if d2 < best_d2 {
              best_d2 = d2
              best = j
            }
          }
          if best >= 0 {
            tx = trucks[best].x
            ty = trucks[best].y
          }
        }

        let dx : Float = tx - enemy.x
        let dy : Float = ty - enemy.y
        let d2 : Float = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        let base_speed : Float = if enemy.kind == 0 {
          176.0
        } else {
          132.0
        }
        let level_gain : Float = if enemy.kind == 0 { 16.0 } else { 12.0 }
        let mut speed : Float = base_speed +
          Float::from_int(level - 1) * level_gain

        if enemy.slow_t > 0.0 {
          speed = speed * 0.56
        }
        if enemy.shock_t > 0.0 {
          speed = speed * 0.34
        }

        let vx_t : Float = dx / d * speed
        let vy_t : Float = dy / d * speed

        enemy.vx = enemy.vx + (vx_t - enemy.vx * 2.0) * dt
        enemy.vy = enemy.vy + (vy_t - enemy.vy * 2.0) * dt

        enemy.x = enemy.x + enemy.vx * dt
        enemy.y = enemy.y + enemy.vy * dt

        if enemy.x < 24.0 {
          enemy.x = 24.0
          enemy.vx = enemy.vx.abs() * 0.3
        }
        if enemy.x > world_w - 24.0 {
          enemy.x = world_w - 24.0
          enemy.vx = -enemy.vx.abs() * 0.3
        }
        if enemy.y < 120.0 {
          enemy.y = 120.0
          enemy.vy = enemy.vy.abs() * 0.3
        }
        if enemy.y > world_h - 120.0 {
          enemy.y = world_h - 120.0
          enemy.vy = -enemy.vy.abs() * 0.3
        }

        if enemy.kind == 1 &&
          enemy.fire_cd <= 0.0 &&
          d <= 520.0 &&
          enemy.shock_t <= 0.0 {
          enemy.fire_cd = 1.3
          let inv : Float = if d2 < 1.0 { 0.0 } else { 1.0 / d2.sqrt() }
          spawn_bullet(
            bullets,
            2,
            false,
            enemy.x,
            enemy.y,
            dx * inv * 360.0,
            dy * inv * 360.0,
            16.0,
            2.1,
          )
        }

        if enemy.bite_cd <= 0.0 {
          if dist2(enemy.x, enemy.y, pilot.x, pilot.y) <= 30.0 * 30.0 {
            enemy.bite_cd = 0.64
            if pilot.hit_cd <= 0.0 {
              let bite_dmg : Float = if enemy.kind == 0 {
                12.0
              } else {
                20.0
              }
              pilot.hp = pilot.hp - bite_dmg
              pilot.hit_cd = 0.42
              pilot.flash_t = 0.16
              pilot.shake_t = 0.22
              pilot.combo = 0
              burst_particles(particles, pilot.x, pilot.y, 16, 96.0, 2)
            }
          }

          for truck in trucks {
            if not(truck.active) {
              continue
            }
            if dist2(enemy.x, enemy.y, truck.x, truck.y) <=
              34.0 * 34.0 {
              enemy.bite_cd = 0.66
              let truck_dmg : Float = if enemy.kind == 0 {
                14.0
              } else {
                24.0
              }
              truck.hp = truck.hp - truck_dmg
              truck.flash_t = 0.14
              burst_particles(particles, truck.x, truck.y, 12, 80.0, 2)
              break
            }
          }
        }
      }

      for bullet in bullets {
        if not(bullet.active) {
          continue
        }

        bullet.life = bullet.life - dt
        if bullet.life <= 0.0 {
          bullet.active = false
          continue
        }

        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt

        if bullet.x < 0.0 ||
          bullet.y < 0.0 ||
          bullet.x > world_w ||
          bullet.y > world_h {
          bullet.active = false
          continue
        }

        if bullet.from_player {
          for enemy in enemies {
            if not(enemy.active) {
              continue
            }
            if dist2(bullet.x, bullet.y, enemy.x, enemy.y) <=
              22.0 * 22.0 {
              enemy.hp = enemy.hp - bullet.dmg
              burst_particles(particles, bullet.x, bullet.y, 6, 56.0, 0)
              bullet.active = false
              break
            }
          }
        } else {
          if dist2(bullet.x, bullet.y, pilot.x, pilot.y) <= 24.0 * 24.0 {
            if pilot.hit_cd <= 0.0 {
              pilot.hp = pilot.hp - bullet.dmg
              pilot.hit_cd = 0.34
              pilot.flash_t = 0.14
              pilot.shake_t = 0.2
              pilot.combo = 0
            }
            burst_particles(particles, bullet.x, bullet.y, 10, 72.0, 2)
            bullet.active = false
            continue
          }

          for truck in trucks {
            if not(truck.active) {
              continue
            }
            if dist2(bullet.x, bullet.y, truck.x, truck.y) <=
              24.0 * 24.0 {
              truck.hp = truck.hp - bullet.dmg
              truck.flash_t = 0.14
              burst_particles(particles, bullet.x, bullet.y, 8, 66.0, 2)
              bullet.active = false
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
          let ore_value : Int = if enemy.kind == 0 {
            18 + level * 3
          } else {
            28 + level * 4
          }
          spawn_ore(ores, enemy.x, enemy.y, ore_value)

          let kill_score : Int = if enemy.kind == 0 { 22 } else { 52 }
          pilot.score = pilot.score + kill_score + pilot.combo
          pilot.combo = pilot.combo + 1
          if pilot.combo > 60 {
            pilot.combo = 60
          }

          burst_particles(
            particles,
            enemy.x,
            enemy.y,
            24,
            96.0,
            if enemy.kind == 0 {
              0
            } else {
              2
            },
          )
        }
      }

      for i in 0..<ores.length() {
        if not(ores[i].active) {
          continue
        }

        ores[i].t = ores[i].t + dt
        ores[i].life = ores[i].life - dt
        if ores[i].life <= 0.0 {
          ores[i].active = false
          continue
        }

        let pulse : Float = 1.0 + @math.sinf(ores[i].t * 4.2) * 0.12
        if dist2(pilot.x, pilot.y, ores[i].x, ores[i].y) <=
          34.0 * pulse * (34.0 * pulse) {
          ores[i].active = false
          pilot.ore = pilot.ore + ores[i].value
          pilot.score = pilot.score + ores[i].value
          pilot.energy = pilot.energy + 16.0
          if pilot.energy > 260.0 {
            pilot.energy = 260.0
          }
          burst_particles(particles, pilot.x, pilot.y, 14, 74.0, 1)
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
        particle.vx = particle.vx * (1.0 - dt * 0.74)
        particle.vy = particle.vy * (1.0 - dt * 0.74)
      }

      if pilot.hp <= 0.0 {
        state = 3
      } else if timer <= 0.0 {
        state = 3
      } else {
        let mut alive : Int = 0
        let mut max_x : Float = 0.0
        for truck in trucks {
          if truck.active {
            alive = alive + 1
            if truck.x > max_x {
              max_x = truck.x
            }
          }
        }

        if alive <= 0 {
          state = 3
        } else if max_x >= world_w - 130.0 {
          pilot.score = pilot.score +
            pilot.hp.to_int() +
            pilot.energy.to_int() +
            pilot.ore
          state = 2
        }
      }
    }

    let shake_x : Float = if pilot.shake_t > 0.0 {
      randf(-6.0, 6.0) * (pilot.shake_t * 3.8)
    } else {
      0.0
    }
    let shake_y : Float = if pilot.shake_t > 0.0 {
      randf(-4.0, 4.0) * (pilot.shake_t * 3.8)
    } else {
      0.0
    }

    cam_x = convoy_head_x - 280.0
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(10, 16, 28, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 30, 46, 255))

    let mut layer_x : Float = -cam_x * 0.2
    while layer_x < Float::from_int(sw + 200) {
      @raylib.draw_triangle(
        @raylib.Vector2::new(layer_x, 220.0),
        @raylib.Vector2::new(layer_x + 120.0, 60.0),
        @raylib.Vector2::new(layer_x + 240.0, 220.0),
        @raylib.Color::new(44, 56, 78, 180),
      )
      layer_x = layer_x + 220.0
    }

    @raylib.draw_rectangle(
      0,
      (world_h - 130.0 + shake_y).to_int(),
      sw,
      180,
      @raylib.Color::new(54, 68, 84, 255),
    )

    let grid_col = @raylib.Color::new(78, 94, 114, 84)
    let mut gx : Float = -cam_x % 160.0 - 160.0
    while gx < Float::from_int(sw + 160) {
      @raylib.draw_line(gx.to_int(), 0, gx.to_int(), sh, grid_col)
      gx = gx + 160.0
    }

    let exit_x : Float = world_w - cam_x - 130.0 + shake_x
    @raylib.draw_circle(
      exit_x.to_int(),
      420,
      40.0,
      @raylib.Color::new(136, 228, 252, 180),
    )
    @raylib.draw_circle(
      exit_x.to_int(),
      420,
      20.0,
      @raylib.Color::new(226, 248, 255, 220),
    )

    for ore in ores {
      if not(ore.active) {
        continue
      }
      let ox : Float = ore.x - cam_x + shake_x
      let oy : Float = ore.y + shake_y
      if ox < -24.0 ||
        oy < -24.0 ||
        ox > Float::from_int(sw + 24) ||
        oy > Float::from_int(sh + 24) {
        continue
      }
      let pulse : Float = 1.0 + @math.sinf(ore.t * 4.0) * 0.12
      @raylib.draw_circle(
        ox.to_int(),
        oy.to_int(),
        10.0 * pulse,
        @raylib.Color::new(136, 216, 252, 220),
      )
      @raylib.draw_rectangle(
        (ox - 6.0).to_int(),
        (oy - 8.0).to_int(),
        12,
        16,
        @raylib.Color::new(212, 240, 255, 255),
      )
    }

    for truck in trucks {
      if not(truck.active) {
        continue
      }
      let tx : Float = truck.x - cam_x + shake_x
      let ty : Float = truck.y + shake_y
      if tx < -120.0 ||
        ty < -120.0 ||
        tx > Float::from_int(sw + 120) ||
        ty > Float::from_int(sh + 120) {
        continue
      }

      let col = if truck.flash_t > 0.0 {
        @raylib.Color::new(252, 220, 160, 255)
      } else {
        @raylib.Color::new(112, 178, 234, 255)
      }

      @raylib.draw_rectangle(
        (tx - 34.0).to_int(),
        (ty - 18.0).to_int(),
        68,
        36,
        col,
      )
      @raylib.draw_rectangle(
        (tx - 18.0).to_int(),
        (ty - 14.0).to_int(),
        36,
        16,
        @raylib.Color::new(226, 242, 252, 255),
      )
      @raylib.draw_circle(
        (tx - 20.0).to_int(),
        (ty + 20.0).to_int(),
        8.0,
        @raylib.Color::new(44, 58, 74, 255),
      )
      @raylib.draw_circle(
        (tx + 20.0).to_int(),
        (ty + 20.0).to_int(),
        8.0,
        @raylib.Color::new(44, 58, 74, 255),
      )
    }

    for enemy in enemies {
      if not(enemy.active) {
        continue
      }
      let ex : Float = enemy.x - cam_x + shake_x
      let ey : Float = enemy.y + shake_y
      if ex < -80.0 ||
        ey < -80.0 ||
        ex > Float::from_int(sw + 80) ||
        ey > Float::from_int(sh + 80) {
        continue
      }

      let col = if enemy.shock_t > 0.0 {
        @raylib.Color::new(154, 216, 252, 255)
      } else if enemy.slow_t > 0.0 {
        @raylib.Color::new(172, 188, 252, 255)
      } else if enemy.kind == 0 {
        @raylib.Color::new(236, 108, 94, 255)
      } else {
        @raylib.Color::new(248, 160, 96, 255)
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
    }

    for bullet in bullets {
      if not(bullet.active) {
        continue
      }
      let px : Float = bullet.x - cam_x + shake_x
      let py : Float = bullet.y + shake_y
      if px < -8.0 ||
        py < -8.0 ||
        px > Float::from_int(sw + 8) ||
        py > Float::from_int(sh + 8) {
        continue
      }

      let col = if bullet.from_player {
        @raylib.Color::new(252, 220, 132, 255)
      } else {
        @raylib.Color::new(242, 146, 146, 255)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        if bullet.from_player {
          4.0
        } else {
          3.0
        },
        col,
      )
    }

    let hx : Float = pilot.x - cam_x + shake_x
    let hy : Float = pilot.y + shake_y
    let hcol = if pilot.flash_t > 0.0 {
      @raylib.Color::new(252, 242, 188, 255)
    } else if pilot.overdrive_t > 0.0 {
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
      @raylib.Color::new(44, 64, 92, 255),
    )
    @raylib.draw_line(
      hx.to_int(),
      hy.to_int(),
      (hx + pilot.aim_x * 24.0).to_int(),
      (hy + pilot.aim_y * 24.0).to_int(),
      @raylib.Color::new(246, 248, 252, 255),
    )

    for particle in particles {
      if not(particle.active) {
        continue
      }
      let px : Float = particle.x - cam_x + shake_x
      let py : Float = particle.y + shake_y
      if px < -20.0 ||
        py < -20.0 ||
        px > Float::from_int(sw + 20) ||
        py > Float::from_int(sh + 20) {
        continue
      }

      let life_r : Float = 1.0 - particle.t / particle.life
      let alpha : Int = clampf(life_r * 220.0, 0.0, 220.0).to_int()
      let col = if particle.kind == 0 {
        @raylib.Color::new(252, 186, 122, alpha)
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
      660,
      208,
      @raylib.Color::new(12, 20, 34, 205),
    )
    @raylib.draw_rectangle_lines(
      16,
      14,
      660,
      208,
      @raylib.Color::new(224, 236, 250, 138),
    )

    @raylib.draw_text(
      "SKYFORGE MINING CONVOY 2026",
      30,
      22,
      34,
      @raylib.Color::new(236, 244, 254, 250),
    )
    @raylib.draw_text(
      "Move:A/D  Lift:W  Fire:J/Mouse  Pulse:K  Storm:L  Overdrive:Shift",
      32,
      62,
      20,
      @raylib.Color::new(190, 208, 236, 244),
    )

    draw_bar(
      30,
      94,
      248,
      20,
      pilot.hp / 300.0,
      @raylib.Color::new(232, 130, 118, 255),
      @raylib.Color::new(90, 52, 52, 230),
    )
    @raylib.draw_text("HP", 284, 92, 22, @raylib.Color::new(216, 230, 244, 244))

    draw_bar(
      30,
      122,
      248,
      20,
      pilot.energy / 260.0,
      @raylib.Color::new(118, 206, 252, 255),
      @raylib.Color::new(56, 78, 94, 230),
    )
    @raylib.draw_text(
      "Energy",
      284,
      120,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    let od_ready : Float = if pilot.overdrive_cd <= 0.0 {
      1.0
    } else {
      1.0 - pilot.overdrive_cd / 2.2
    }
    draw_bar(
      30,
      150,
      248,
      20,
      od_ready,
      @raylib.Color::new(144, 232, 186, 255),
      @raylib.Color::new(56, 90, 74, 230),
    )
    @raylib.draw_text(
      "Overdrive",
      284,
      148,
      22,
      @raylib.Color::new(216, 230, 244, 244),
    )

    @raylib.draw_text(
      "Ore \{pilot.ore}   Score \{pilot.score}   Combo x\{pilot.combo}",
      32,
      184,
      24,
      @raylib.Color::new(250, 240, 206, 248),
    )

    let pulse_text = if pilot.pulse_cd <= 0.0 {
      "Pulse READY"
    } else {
      "Pulse CD \{pilot.pulse_cd.to_int()}"
    }
    let storm_text = if pilot.overdrive_cd <= 0.0 {
      "Storm READY"
    } else {
      "Storm tied to overdrive CD"
    }

    @raylib.draw_text(
      "Time: \{timer.to_int()}s",
      sw - 368,
      24,
      34,
      @raylib.Color::new(246, 246, 252, 250),
    )
    @raylib.draw_text(
      pulse_text,
      sw - 368,
      64,
      24,
      @raylib.Color::new(170, 222, 252, 248),
    )
    @raylib.draw_text(
      storm_text,
      sw - 368,
      90,
      24,
      @raylib.Color::new(210, 192, 252, 248),
    )

    let mut alive_trucks : Int = 0
    for truck in trucks {
      if truck.active {
        alive_trucks = alive_trucks + 1
      }
    }

    @raylib.draw_text(
      "Convoy Alive: \{alive_trucks}/\{convoy_count}",
      sw - 368,
      122,
      24,
      @raylib.Color::new(240, 232, 206, 248),
    )

    if announce_t > 0.0 {
      let alpha : Int = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Escort the convoy to the portal while harvesting ore.",
        sw / 2 - 340,
        224,
        34,
        @raylib.Color::new(244, 248, 252, alpha),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))
      @raylib.draw_text(
        "SKYFORGE CONVOY",
        sw / 2 - 314,
        sh / 2 - 116,
        78,
        @raylib.Color::new(238, 246, 252, 255),
      )
      @raylib.draw_text(
        "Escort fragile mining rigs through hostile skies.",
        sw / 2 - 352,
        sh / 2 - 12,
        34,
        @raylib.Color::new(192, 216, 242, 246),
      )
      @raylib.draw_text(
        "Use pulse/storm to break swarms before trucks collapse.",
        sw / 2 - 398,
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
        "CONVOY DELIVERED",
        sw / 2 - 294,
        sh / 2 - 82,
        74,
        @raylib.Color::new(214, 252, 214, 255),
      )
      @raylib.draw_text(
        "Score \{pilot.score}   HP \{pilot.hp.to_int()}   Ore \{pilot.ore}",
        sw / 2 - 286,
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
        "CONVOY LOST",
        sw / 2 - 208,
        sh / 2 - 82,
        74,
        @raylib.Color::new(252, 192, 182, 255),
      )
      @raylib.draw_text(
        "Ore \{pilot.ore}   Time \{timer.to_int()}s",
        sw / 2 - 176,
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
