///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let arena_l : Float = 36.0

///|
let arena_r : Float = Float::from_int(sw) - 36.0

///|
let arena_t : Float = 92.0

///|
let arena_b : Float = Float::from_int(sh) - 40.0

///|
let core_x : Float = Float::from_int(sw) * 0.5

///|
let core_y : Float = Float::from_int(sh) * 0.5 + 20.0

///|
let core_r : Float = 44.0

///|
let max_enemies : Int = 260

///|
let max_bullets : Int = 1200

///|
let max_turrets : Int = 120

///|
let max_scraps : Int = 320

///|
let max_particles : Int = 1800

///|
let max_waves : Int = 10

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut hp : Float
  mut energy : Float
  mut heat : Float
  mut inv_t : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut bomb_cd : Float
  mut scrap : Int
  mut score : Int
  mut combo : Int
  mut best_combo : Int
}

///|
struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut fire_cd : Float
  mut t : Float
}

///|
struct Bullet {
  mut active : Bool
  mut team : Int
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut r : Float
  mut life : Float
}

///|
struct Turret {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut hp : Float
  mut fire_cd : Float
  mut t : Float
}

///|
struct Scrap {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut value : Int
  mut life : Float
  mut t : Float
}

///|
struct Particle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut life : Float
  mut t : Float
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
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
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
fn enemy_radius(kind : Int) -> Float {
  if kind == 0 {
    15.0
  } else if kind == 1 {
    20.0
  } else {
    28.0
  }
}

///|
fn enemy_hp(kind : Int, wave : Int) -> Float {
  if kind == 0 {
    24.0 + Float::from_int(wave) * 2.8
  } else if kind == 1 {
    42.0 + Float::from_int(wave) * 4.0
  } else {
    120.0 + Float::from_int(wave) * 8.4
  }
}

///|
fn turret_cost(kind : Int) -> Int {
  if kind == 0 {
    12
  } else {
    26
  }
}

///|
fn turret_range(kind : Int) -> Float {
  if kind == 0 {
    220.0
  } else {
    300.0
  }
}

///|
fn clear_enemies(enemies : Array[Enemy]) -> Unit {
  for enemy in enemies {
    enemy.active = false
    enemy.kind = 0
    enemy.x = 0.0
    enemy.y = 0.0
    enemy.vx = 0.0
    enemy.vy = 0.0
    enemy.hp = 0.0
    enemy.fire_cd = 0.0
    enemy.t = 0.0
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for bullet in bullets {
    bullet.active = false
    bullet.team = 0
    bullet.kind = 0
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.dmg = 0.0
    bullet.r = 0.0
    bullet.life = 0.0
  }
}

///|
fn clear_turrets(turrets : Array[Turret]) -> Unit {
  for turret in turrets {
    turret.active = false
    turret.kind = 0
    turret.x = 0.0
    turret.y = 0.0
    turret.hp = 0.0
    turret.fire_cd = 0.0
    turret.t = 0.0
  }
}

///|
fn clear_scraps(scraps : Array[Scrap]) -> Unit {
  for scrap in scraps {
    scrap.active = false
    scrap.kind = 0
    scrap.x = 0.0
    scrap.y = 0.0
    scrap.vx = 0.0
    scrap.vy = 0.0
    scrap.value = 0
    scrap.life = 0.0
    scrap.t = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for part in parts {
    part.active = false
    part.kind = 0
    part.x = 0.0
    part.y = 0.0
    part.vx = 0.0
    part.vy = 0.0
    part.size = 0.0
    part.life = 0.0
    part.t = 0.0
  }
}

///|
fn add_enemy(
  enemies : Array[Enemy],
  kind : Int,
  x : Float,
  y : Float,
  wave : Int,
) -> Bool {
  for enemy in enemies {
    if not(enemy.active) {
      enemy.active = true
      enemy.kind = kind
      enemy.x = x
      enemy.y = y
      enemy.vx = randf(-40.0, 40.0)
      enemy.vy = randf(-40.0, 40.0)
      enemy.hp = enemy_hp(kind, wave)
      enemy.t = randf(0.0, 99.0)
      if kind == 0 {
        enemy.fire_cd = randf(1.6, 2.5)
      } else if kind == 1 {
        enemy.fire_cd = randf(0.8, 1.4)
      } else {
        enemy.fire_cd = randf(1.2, 2.0)
      }
      return true
    }
  }
  false
}

///|
fn add_bullet(
  bullets : Array[Bullet],
  team : Int,
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  r : Float,
  life : Float,
) -> Bool {
  for bullet in bullets {
    if not(bullet.active) {
      bullet.active = true
      bullet.team = team
      bullet.kind = kind
      bullet.x = x
      bullet.y = y
      bullet.vx = vx
      bullet.vy = vy
      bullet.dmg = dmg
      bullet.r = r
      bullet.life = life
      return true
    }
  }
  false
}

///|
fn add_turret(
  turrets : Array[Turret],
  kind : Int,
  x : Float,
  y : Float,
) -> Bool {
  for turret in turrets {
    if not(turret.active) {
      turret.active = true
      turret.kind = kind
      turret.x = x
      turret.y = y
      if kind == 0 {
        turret.hp = 100.0
        turret.fire_cd = randf(0.08, 0.2)
      } else {
        turret.hp = 160.0
        turret.fire_cd = randf(0.2, 0.5)
      }
      turret.t = randf(0.0, 20.0)
      return true
    }
  }
  false
}

///|
fn add_scrap(
  scraps : Array[Scrap],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  value : Int,
  life : Float,
) -> Bool {
  for scrap in scraps {
    if not(scrap.active) {
      scrap.active = true
      scrap.kind = kind
      scrap.x = x
      scrap.y = y
      scrap.vx = vx
      scrap.vy = vy
      scrap.value = value
      scrap.life = life
      scrap.t = randf(0.0, 20.0)
      return true
    }
  }
  false
}

///|
fn add_particle(
  parts : Array[Particle],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  size : Float,
  life : Float,
) -> Bool {
  for part in parts {
    if not(part.active) {
      part.active = true
      part.kind = kind
      part.x = x
      part.y = y
      part.vx = vx
      part.vy = vy
      part.size = size
      part.life = life
      part.t = 0.0
      return true
    }
  }
  false
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  scale : Float,
  kind : Int,
) -> Unit {
  for _i in 0..<count {
    let ang : Float = randf(0.0, 6.283)
    let spd : Float = randf(80.0, 360.0) * scale
    ignore(
      add_particle(
        parts,
        kind,
        x,
        y,
        @math.cosf(ang) * spd,
        @math.sinf(ang) * spd,
        randf(2.0, 5.0) * scale,
        randf(0.2, 0.8),
      ),
    )
  }
}

///|
fn count_active_enemies(enemies : Array[Enemy]) -> Int {
  let mut cnt : Int = 0
  for enemy in enemies {
    if enemy.active {
      cnt = cnt + 1
    }
  }
  cnt
}

///|
fn can_place_turret(turrets : Array[Turret], x : Float, y : Float) -> Bool {
  if x < arena_l + 40.0 ||
    x > arena_r - 40.0 ||
    y < arena_t + 40.0 ||
    y > arena_b - 40.0 {
    return false
  }

  if dist2(x, y, core_x, core_y) <= (core_r + 64.0) * (core_r + 64.0) {
    return false
  }

  for turret in turrets {
    if not(turret.active) {
      continue
    }
    if dist2(x, y, turret.x, turret.y) <= 56.0 * 56.0 {
      return false
    }
  }

  true
}

///|
fn draw_touch_ui(state : Int) -> Unit {
  if state != 1 {
    ignore(())
  } else {
    let pad_x : Int = 20
    let pad_y : Int = sh - 220

    let btn_x : Int = sw - 338
    let btn_y : Int = sh - 236

    @raylib.draw_rectangle(
      pad_x,
      pad_y,
      228,
      198,
      @raylib.Color::new(8, 12, 20, 102),
    )
    @raylib.draw_rectangle_lines(
      pad_x,
      pad_y,
      228,
      198,
      @raylib.Color::new(90, 140, 190, 182),
    )

    @raylib.draw_rectangle(
      pad_x + 12,
      pad_y + 70,
      60,
      60,
      @raylib.Color::new(24, 42, 62, 186),
    )
    @raylib.draw_rectangle(
      pad_x + 156,
      pad_y + 70,
      60,
      60,
      @raylib.Color::new(24, 42, 62, 186),
    )
    @raylib.draw_rectangle(
      pad_x + 84,
      pad_y + 8,
      60,
      60,
      @raylib.Color::new(24, 42, 62, 186),
    )
    @raylib.draw_rectangle(
      pad_x + 84,
      pad_y + 132,
      60,
      60,
      @raylib.Color::new(24, 42, 62, 186),
    )

    @raylib.draw_text(
      "L",
      pad_x + 36,
      pad_y + 88,
      28,
      @raylib.Color::new(216, 236, 252, 246),
    )
    @raylib.draw_text(
      "R",
      pad_x + 180,
      pad_y + 88,
      28,
      @raylib.Color::new(216, 236, 252, 246),
    )
    @raylib.draw_text(
      "U",
      pad_x + 106,
      pad_y + 24,
      28,
      @raylib.Color::new(216, 236, 252, 246),
    )
    @raylib.draw_text(
      "D",
      pad_x + 105,
      pad_y + 146,
      28,
      @raylib.Color::new(216, 236, 252, 246),
    )

    @raylib.draw_rectangle(
      btn_x,
      btn_y,
      308,
      214,
      @raylib.Color::new(8, 12, 20, 112),
    )
    @raylib.draw_rectangle_lines(
      btn_x,
      btn_y,
      308,
      214,
      @raylib.Color::new(96, 144, 198, 184),
    )

    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 12,
      138,
      90,
      @raylib.Color::new(24, 50, 72, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 158,
      btn_y + 12,
      138,
      90,
      @raylib.Color::new(24, 50, 72, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 112,
      138,
      90,
      @raylib.Color::new(24, 50, 72, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 158,
      btn_y + 112,
      138,
      90,
      @raylib.Color::new(24, 50, 72, 196),
    )

    @raylib.draw_text(
      "FIRE",
      btn_x + 44,
      btn_y + 46,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "DASH",
      btn_x + 190,
      btn_y + 46,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "BUILD",
      btn_x + 34,
      btn_y + 146,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "BOMB",
      btn_x + 182,
      btn_y + 146,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] arcade factory defense 2026")
  @raylib.set_target_fps(60)

  let player : Player = {
    x: core_x,
    y: core_y + 160.0,
    vx: 0.0,
    vy: 0.0,
    aim_x: 0.0,
    aim_y: -1.0,
    hp: 120.0,
    energy: 100.0,
    heat: 0.0,
    inv_t: 0.0,
    fire_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    bomb_cd: 0.0,
    scrap: 28,
    score: 0,
    combo: 0,
    best_combo: 0,
  }

  let enemies : Array[Enemy] = Array::makei(max_enemies, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      hp: 0.0,
      fire_cd: 0.0,
      t: 0.0,
    }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    {
      active: false,
      team: 0,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0.0,
      r: 0.0,
      life: 0.0,
    }
  })

  let turrets : Array[Turret] = Array::makei(max_turrets, fn(_i) {
    { active: false, kind: 0, x: 0.0, y: 0.0, hp: 0.0, fire_cd: 0.0, t: 0.0 }
  })

  let scraps : Array[Scrap] = Array::makei(max_scraps, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      value: 0,
      life: 0.0,
      t: 0.0,
    }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      life: 0.0,
      t: 0.0,
    }
  })

  let mut state : Int = 0

  let mut core_hp : Float = 260.0
  let mut core_max_hp : Float = 260.0

  let mut wave : Int = 1
  let mut wave_active : Bool = false
  let mut wave_pre_t : Float = 1.8
  let mut to_spawn : Int = 0
  let mut spawn_cd : Float = 0.0

  let mut selected_turret : Int = 0
  let mut build_mode : Bool = false
  let mut place_cd : Float = 0.0

  let mut msg : String = "Defend the factory core"
  let mut msg_t : Float = 3.0

  let mut stars_t : Float = 0.0

  let reset_run = fn() {
    player.x = core_x
    player.y = core_y + 160.0
    player.vx = 0.0
    player.vy = 0.0
    player.aim_x = 0.0
    player.aim_y = -1.0
    player.hp = 120.0
    player.energy = 100.0
    player.heat = 0.0
    player.inv_t = 0.0
    player.fire_cd = 0.0
    player.dash_cd = 0.0
    player.dash_t = 0.0
    player.bomb_cd = 0.0
    player.scrap = 28
    player.score = 0
    player.combo = 0
    player.best_combo = 0

    core_hp = 260.0
    core_max_hp = 260.0

    wave = 1
    wave_active = false
    wave_pre_t = 1.8
    to_spawn = 0
    spawn_cd = 0.0

    selected_turret = 0
    build_mode = false
    place_cd = 0.0

    clear_enemies(enemies)
    clear_bullets(bullets)
    clear_turrets(turrets)
    clear_scraps(scraps)
    clear_particles(particles)

    // Initial starter turrets.
    ignore(add_turret(turrets, 0, core_x - 130.0, core_y + 30.0))
    ignore(add_turret(turrets, 0, core_x + 130.0, core_y + 30.0))

    msg = "Wave 1 incoming"
    msg_t = 2.0
  }

  let on_player_hit = fn(dmg : Float, text : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut dealt : Float = dmg
      if player.dash_t > 0.0 {
        dealt = dealt * 0.58
      }
      player.hp = player.hp - dealt
      if player.hp < 0.0 {
        player.hp = 0.0
      }
      player.inv_t = 0.42
      player.combo = 0
      msg = text
      msg_t = 0.74
      burst(particles, player.x, player.y, 16, 0.2, 2)
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
    let touch_down : Bool = @raylib.is_mouse_button_down(
      @raylib.MouseButtonLeft,
    )
    let touch_press : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    stars_t = stars_t + dt * 26.0
    while stars_t >= 999999.0 {
      stars_t = stars_t - 999999.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || touch_press {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      // Core timers.
      player.inv_t = player.inv_t - dt
      if player.inv_t < 0.0 {
        player.inv_t = 0.0
      }

      player.fire_cd = player.fire_cd - dt
      if player.fire_cd < 0.0 {
        player.fire_cd = 0.0
      }

      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }

      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }

      player.bomb_cd = player.bomb_cd - dt
      if player.bomb_cd < 0.0 {
        player.bomb_cd = 0.0
      }

      place_cd = place_cd - dt
      if place_cd < 0.0 {
        place_cd = 0.0
      }

      player.energy = player.energy + dt * 10.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      player.heat = player.heat - dt * 38.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      // Wave progression.
      if not(wave_active) {
        wave_pre_t = wave_pre_t - dt
        if wave_pre_t <= 0.0 {
          if wave > max_waves {
            state = 2
            msg = "Factory secured"
            msg_t = 2.2
          } else {
            wave_active = true
            to_spawn = 8 + wave * 3
            spawn_cd = 0.2
            msg = "Wave \{wave} started"
            msg_t = 1.4
          }
        }
      } else {
        spawn_cd = spawn_cd - dt
        if to_spawn > 0 && spawn_cd <= 0.0 {
          let edge : Int = @raylib.get_random_value(0, 3)
          let mut ex : Float = 0.0
          let mut ey : Float = 0.0
          if edge == 0 {
            ex = randf(arena_l, arena_r)
            ey = arena_t - 30.0
          } else if edge == 1 {
            ex = arena_r + 30.0
            ey = randf(arena_t, arena_b)
          } else if edge == 2 {
            ex = randf(arena_l, arena_r)
            ey = arena_b + 30.0
          } else {
            ex = arena_l - 30.0
            ey = randf(arena_t, arena_b)
          }

          let roll : Int = @raylib.get_random_value(0, 99)
          let mut kind : Int = 0
          if wave >= 3 && roll >= 48 {
            kind = 1
          }
          if wave >= 6 && roll >= 82 {
            kind = 2
          }

          ignore(add_enemy(enemies, kind, ex, ey, wave))

          to_spawn = to_spawn - 1
          let next_cd : Float = 0.62 -
            Float::from_int(wave) * 0.028 +
            randf(-0.06, 0.16)
          spawn_cd = clampf(next_cd, 0.2, 0.8)
        }

        if to_spawn == 0 && count_active_enemies(enemies) == 0 {
          wave_active = false
          wave = wave + 1
          wave_pre_t = 3.8
          player.scrap = player.scrap + 8 + wave
          msg = "Wave clear, prepare defenses"
          msg_t = 1.6
        }
      }

      // Input mapping.
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut fire_hold : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyRightShift)
      let mut build_press : Bool = @raylib.is_key_pressed(@raylib.KeyB)
      let type_press : Bool = @raylib.is_key_pressed(@raylib.KeyT)
      let mut bomb_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let mut place_press : Bool = false

      if build_mode {
        place_press = touch_press
      } else if touch_down &&
        not(
          inside_rect(mouse.x, mouse.y, 20, sh - 220, 228, 198) ||
          inside_rect(mouse.x, mouse.y, sw - 338, sh - 236, 308, 214),
        ) {
        fire_hold = true
      }

      // Touch UI zones.
      let pad_x : Int = 20
      let pad_y : Int = sh - 220
      let btn_x : Int = sw - 338
      let btn_y : Int = sh - 236

      if touch_down {
        if inside_rect(mouse.x, mouse.y, pad_x + 12, pad_y + 70, 60, 60) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 156, pad_y + 70, 60, 60) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 8, 60, 60) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 132, 60, 60) {
          move_d = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 12, 138, 90) {
          fire_hold = true
        }
      }

      if touch_press {
        if inside_rect(mouse.x, mouse.y, btn_x + 158, btn_y + 12, 138, 90) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 112, 138, 90) {
          build_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 158, btn_y + 112, 138, 90) {
          bomb_press = true
        }
      }

      if build_press {
        if build_mode {
          build_mode = false
          msg = "Build mode off"
        } else {
          build_mode = true
          msg = "Build mode on"
        }
        msg_t = 0.62
      }

      if type_press {
        selected_turret = 1 - selected_turret
        let tname : String = if selected_turret == 0 {
          "Auto Turret"
        } else {
          "Cannon Turret"
        }
        msg = "Selected: \{tname}"
        msg_t = 0.62
      }

      if build_mode && bomb_press {
        selected_turret = 1 - selected_turret
        let tname : String = if selected_turret == 0 {
          "Auto Turret"
        } else {
          "Cannon Turret"
        }
        msg = "Selected: \{tname}"
        msg_t = 0.62
      }

      // Movement & aim.
      let mut inp_x : Float = 0.0
      let mut inp_y : Float = 0.0
      if move_l {
        inp_x = inp_x - 1.0
      }
      if move_r {
        inp_x = inp_x + 1.0
      }
      if move_u {
        inp_y = inp_y - 1.0
      }
      if move_d {
        inp_y = inp_y + 1.0
      }

      if inp_x * inp_x + inp_y * inp_y > 0.01 {
        let inv : Float = 1.0 / (inp_x * inp_x + inp_y * inp_y).sqrt()
        player.aim_x = inp_x * inv
        player.aim_y = inp_y * inv
      }

      if not(build_mode) {
        let mx : Float = mouse.x
        let my : Float = mouse.y
        if mx >= arena_l && mx <= arena_r && my >= arena_t && my <= arena_b {
          let dx : Float = mx - player.x
          let dy : Float = my - player.y
          let l2 : Float = dx * dx + dy * dy
          if l2 > 1.0 {
            let inv : Float = 1.0 / l2.sqrt()
            player.aim_x = dx * inv
            player.aim_y = dy * inv
          }
        }
      }

      let accel : Float = if player.dash_t > 0.0 { 1600.0 } else { 980.0 }
      player.vx = player.vx + inp_x * accel * dt
      player.vy = player.vy + inp_y * accel * dt

      let drag : Float = if player.dash_t > 0.0 { 2.0 } else { 5.2 }
      player.vx = player.vx * (1.0 - dt * drag)
      player.vy = player.vy * (1.0 - dt * drag)

      let max_spd : Float = if player.dash_t > 0.0 { 460.0 } else { 300.0 }
      let sp2 : Float = player.vx * player.vx + player.vy * player.vy
      if sp2 > max_spd * max_spd {
        let invs : Float = max_spd / sp2.sqrt()
        player.vx = player.vx * invs
        player.vy = player.vy * invs
      }

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 20.0 {
        player.dash_cd = 1.16
        player.dash_t = 0.2
        player.energy = player.energy - 20.0

        let mut dx : Float = player.aim_x
        let mut dy : Float = player.aim_y
        let mut l2 : Float = dx * dx + dy * dy
        if l2 < 0.01 {
          dx = 1.0
          dy = 0.0
          l2 = 1.0
        }
        let inv : Float = 1.0 / l2.sqrt()
        player.vx = player.vx + dx * inv * 520.0
        player.vy = player.vy + dy * inv * 520.0
        burst(particles, player.x, player.y, 16, 0.18, 0)
      }

      player.x = clampf(
        player.x + player.vx * dt,
        arena_l + 16.0,
        arena_r - 16.0,
      )
      player.y = clampf(
        player.y + player.vy * dt,
        arena_t + 16.0,
        arena_b - 16.0,
      )

      // Build placement.
      if build_mode {
        let px : Float = if inside_rect(mouse.x, mouse.y, 0, 0, sw, sh) {
          mouse.x
        } else {
          player.x + player.aim_x * 54.0
        }
        let py : Float = if inside_rect(mouse.x, mouse.y, 0, 0, sw, sh) {
          mouse.y
        } else {
          player.y + player.aim_y * 54.0
        }

        let build_x : Float = clampf(px, arena_l + 30.0, arena_r - 30.0)
        let build_y : Float = clampf(py, arena_t + 30.0, arena_b - 30.0)

        if (
            place_press ||
            (
              touch_down &&
              inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 12, 138, 90)
            )
          ) &&
          place_cd <= 0.0 {
          let cost : Int = turret_cost(selected_turret)
          if player.scrap < cost {
            msg = "Not enough scrap"
            msg_t = 0.5
            place_cd = 0.18
          } else if not(can_place_turret(turrets, build_x, build_y)) {
            msg = "Invalid placement"
            msg_t = 0.4
            place_cd = 0.15
          } else if add_turret(turrets, selected_turret, build_x, build_y) {
            player.scrap = player.scrap - cost
            msg = "Turret built"
            msg_t = 0.44
            place_cd = 0.2
            burst(particles, build_x, build_y, 12, 0.12, 3)
          }
        }
      }

      // Player fire (disabled while build mode).
      if not(build_mode) &&
        fire_hold &&
        player.fire_cd <= 0.0 &&
        player.heat <= 94.0 {
        player.fire_cd = clampf(
          0.116 - Float::from_int(wave) * 0.002,
          0.068,
          0.116,
        )
        player.heat = player.heat + 7.0

        ignore(
          add_bullet(
            bullets,
            1,
            0,
            player.x + player.aim_x * 20.0,
            player.y + player.aim_y * 20.0,
            player.aim_x * 700.0,
            player.aim_y * 700.0,
            14.0,
            4.0,
            1.2,
          ),
        )

        if wave >= 4 {
          let sx : Float = -player.aim_y
          let sy : Float = player.aim_x
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + player.aim_x * 20.0 + sx * 8.0,
              player.y + player.aim_y * 20.0 + sy * 8.0,
              (player.aim_x + sx * 0.12) * 680.0,
              (player.aim_y + sy * 0.12) * 680.0,
              10.0,
              3.0,
              1.0,
            ),
          )
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + player.aim_x * 20.0 - sx * 8.0,
              player.y + player.aim_y * 20.0 - sy * 8.0,
              (player.aim_x - sx * 0.12) * 680.0,
              (player.aim_y - sy * 0.12) * 680.0,
              10.0,
              3.0,
              1.0,
            ),
          )
        }

        burst(
          particles,
          player.x + player.aim_x * 20.0,
          player.y + player.aim_y * 20.0,
          8,
          0.13,
          1,
        )
      }

      // Bomb pulse.
      if not(build_mode) &&
        bomb_press &&
        player.bomb_cd <= 0.0 &&
        player.energy >= 36.0 {
        player.bomb_cd = 5.2
        player.energy = player.energy - 36.0
        msg = "EMP bomb"
        msg_t = 0.56

        burst(particles, player.x, player.y, 88, 0.36, 3)

        for bullet in bullets {
          if bullet.active &&
            bullet.team == 2 &&
            dist2(player.x, player.y, bullet.x, bullet.y) <= 280.0 * 280.0 {
            bullet.active = false
          }
        }

        for enemy in enemies {
          if enemy.active &&
            dist2(player.x, player.y, enemy.x, enemy.y) <= 240.0 * 240.0 {
            enemy.hp = enemy.hp - 44.0
            enemy.vx = enemy.vx * 0.2
            enemy.vy = enemy.vy * 0.2
          }
        }
      }

      // Turret update.
      for turret in turrets {
        if not(turret.active) {
          continue
        }

        turret.t = turret.t + dt
        turret.fire_cd = turret.fire_cd - dt

        let range : Float = turret_range(turret.kind)
        let mut target_i : Int = -1
        let mut best_d2 : Float = 99999999.0

        for e in 0..<enemies.length() {
          if not(enemies[e].active) {
            continue
          }
          let d2 : Float = dist2(turret.x, turret.y, enemies[e].x, enemies[e].y)
          if d2 <= range * range && d2 < best_d2 {
            best_d2 = d2
            target_i = e
          }
        }

        if target_i >= 0 && turret.fire_cd <= 0.0 {
          let tx : Float = enemies[target_i].x - turret.x
          let ty : Float = enemies[target_i].y - turret.y
          let mut inv : Float = 0.0
          let l2 : Float = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }

          if turret.kind == 0 {
            turret.fire_cd = clampf(
              0.24 - Float::from_int(wave) * 0.004,
              0.14,
              0.24,
            )
            ignore(
              add_bullet(
                bullets,
                1,
                1,
                turret.x,
                turret.y,
                tx * inv * 540.0,
                ty * inv * 540.0,
                8.0,
                3.0,
                1.4,
              ),
            )
          } else {
            turret.fire_cd = clampf(
              0.86 - Float::from_int(wave) * 0.012,
              0.46,
              0.86,
            )
            ignore(
              add_bullet(
                bullets,
                1,
                2,
                turret.x,
                turret.y,
                tx * inv * 430.0,
                ty * inv * 430.0,
                28.0,
                7.0,
                1.8,
              ),
            )
          }

          burst(particles, turret.x, turret.y, 5, 0.1, 1)
        }

        if turret.hp <= 0.0 {
          turret.active = false
          burst(particles, turret.x, turret.y, 18, 0.2, 2)
        }
      }

      // Enemies update.
      for enemy in enemies {
        if not(enemy.active) {
          continue
        }

        enemy.t = enemy.t + dt
        enemy.fire_cd = enemy.fire_cd - dt

        // target core by default, sometimes player when close.
        let mut txg : Float = core_x
        let mut tyg : Float = core_y
        if dist2(enemy.x, enemy.y, player.x, player.y) <= 260.0 * 260.0 {
          txg = player.x
          tyg = player.y
        }

        let tx : Float = txg - enemy.x
        let ty : Float = tyg - enemy.y
        let mut inv : Float = 0.0
        let l2 : Float = tx * tx + ty * ty
        if l2 > 0.01 {
          inv = 1.0 / l2.sqrt()
        }

        if enemy.kind == 0 {
          let acc : Float = 180.0 + Float::from_int(wave) * 6.0
          enemy.vx = enemy.vx + tx * inv * acc * dt
          enemy.vy = enemy.vy + ty * inv * acc * dt
        } else if enemy.kind == 1 {
          let orbit : Float = 220.0
          let mut d : Float = 0.0
          if l2 > 0.01 {
            d = l2.sqrt()
          }
          let err : Float = d - orbit
          enemy.vx = enemy.vx +
            tx * inv * err * 0.7 * dt +
            @math.sinf(enemy.t * 2.4) * 24.0 * dt
          enemy.vy = enemy.vy +
            ty * inv * err * 0.7 * dt +
            @math.cosf(enemy.t * 2.0) * 24.0 * dt
        } else {
          let acc : Float = 108.0 + Float::from_int(wave) * 4.0
          enemy.vx = enemy.vx + tx * inv * acc * dt
          enemy.vy = enemy.vy + ty * inv * acc * dt
        }

        let max_spd : Float = if enemy.kind == 2 {
          170.0
        } else {
          240.0 + Float::from_int(wave) * 4.0
        }
        let sp2 : Float = enemy.vx * enemy.vx + enemy.vy * enemy.vy
        if sp2 > max_spd * max_spd {
          let invs : Float = max_spd / sp2.sqrt()
          enemy.vx = enemy.vx * invs
          enemy.vy = enemy.vy * invs
        }

        enemy.x = clampf(enemy.x + enemy.vx * dt, arena_l, arena_r)
        enemy.y = clampf(enemy.y + enemy.vy * dt, arena_t, arena_b)

        if enemy.fire_cd <= 0.0 {
          if enemy.kind == 1 {
            enemy.fire_cd = randf(0.82, 1.4)
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemy.x,
                enemy.y,
                tx * inv * 320.0,
                ty * inv * 320.0,
                8.0,
                5.0,
                2.8,
              ),
            )
          } else if enemy.kind == 2 {
            enemy.fire_cd = randf(1.22, 1.96)
            let sx : Float = -ty * inv
            let sy : Float = tx * inv
            ignore(
              add_bullet(
                bullets,
                2,
                1,
                enemy.x,
                enemy.y,
                tx * inv * 270.0,
                ty * inv * 270.0,
                12.0,
                6.0,
                3.0,
              ),
            )
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemy.x,
                enemy.y,
                tx * inv * 250.0 + sx * 72.0,
                ty * inv * 250.0 + sy * 72.0,
                7.0,
                4.0,
                2.8,
              ),
            )
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemy.x,
                enemy.y,
                tx * inv * 250.0 - sx * 72.0,
                ty * inv * 250.0 - sy * 72.0,
                7.0,
                4.0,
                2.8,
              ),
            )
          }
        }

        // Contact with player.
        let rr_p : Float = enemy_radius(enemy.kind) + 17.0
        if dist2(enemy.x, enemy.y, player.x, player.y) <= rr_p * rr_p {
          on_player_hit(8.0 + Float::from_int(enemy.kind) * 2.4, "Direct hit")
          enemy.vx = -enemy.vx
          enemy.vy = -enemy.vy
        }

        // Contact with core.
        let rr_c : Float = enemy_radius(enemy.kind) + core_r
        if dist2(enemy.x, enemy.y, core_x, core_y) <= rr_c * rr_c {
          core_hp = core_hp - dt * (12.0 + Float::from_int(enemy.kind) * 5.0)
          enemy.vx = (enemy.x - core_x) * 0.8
          enemy.vy = (enemy.y - core_y) * 0.8
        }

        // Ramming turrets.
        for turret in turrets {
          if not(turret.active) {
            continue
          }
          if dist2(enemy.x, enemy.y, turret.x, turret.y) <=
            (enemy_radius(enemy.kind) + 20.0) *
            (enemy_radius(enemy.kind) + 20.0) {
            turret.hp = turret.hp -
              dt * (10.0 + Float::from_int(enemy.kind) * 6.0)
            enemy.hp = enemy.hp - dt * 10.0
          }
        }

        if enemy.hp <= 0.0 {
          let reward : Int = 44 + enemy.kind * 24 + player.combo * 2
          player.score = player.score + reward
          player.combo = player.combo + 1
          if player.combo > player.best_combo {
            player.best_combo = player.combo
          }

          let drop_n : Int = 1 + @raylib.get_random_value(0, 2)
          for d in 0..<drop_n {
            let val : Int = 1 + @raylib.get_random_value(0, 2)
            ignore(
              add_scrap(
                scraps,
                @raylib.get_random_value(0, 2),
                enemy.x,
                enemy.y,
                randf(-90.0, 90.0),
                randf(-90.0, 90.0),
                val,
                randf(12.0, 22.0),
              ),
            )
          }

          burst(particles, enemy.x, enemy.y, 22, 0.2, 0)
          enemy.active = false
        }
      }

      // Scraps update.
      for i in 0..<scraps.length() {
        if not(scraps[i].active) {
          continue
        }

        scraps[i].life = scraps[i].life - dt
        if scraps[i].life <= 0.0 {
          scraps[i].active = false
          continue
        }

        scraps[i].t = scraps[i].t + dt
        scraps[i].x = scraps[i].x + scraps[i].vx * dt
        scraps[i].y = scraps[i].y + scraps[i].vy * dt

        scraps[i].vx = scraps[i].vx * (1.0 - dt * 1.5)
        scraps[i].vy = scraps[i].vy * (1.0 - dt * 1.5)

        scraps[i].x = clampf(scraps[i].x, arena_l + 6.0, arena_r - 6.0)
        scraps[i].y = clampf(scraps[i].y, arena_t + 6.0, arena_b - 6.0)

        if dist2(player.x, player.y, scraps[i].x, scraps[i].y) <= 28.0 * 28.0 {
          player.scrap = player.scrap + scraps[i].value
          player.score = player.score + scraps[i].value * 6
          scraps[i].active = false
          burst(particles, player.x, player.y, 8, 0.12, 0)
        }
      }

      // Bullet update + hit resolve.
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

        if bullet.x < arena_l - 40.0 ||
          bullet.x > arena_r + 40.0 ||
          bullet.y < arena_t - 40.0 ||
          bullet.y > arena_b + 40.0 {
          bullet.active = false
          continue
        }

        if bullet.team == 1 {
          let mut consumed : Bool = false
          for enemy in enemies {
            if consumed {
              continue
            }
            if not(enemy.active) {
              continue
            }
            let rr : Float = bullet.r + enemy_radius(enemy.kind)
            if dist2(bullet.x, bullet.y, enemy.x, enemy.y) <= rr * rr {
              enemy.hp = enemy.hp - bullet.dmg
              consumed = true
              bullet.active = false
              burst(particles, bullet.x, bullet.y, 4, 0.1, 1)
            }
          }
        } else {
          if dist2(bullet.x, bullet.y, player.x, player.y) <=
            (bullet.r + 16.0) * (bullet.r + 16.0) {
            on_player_hit(bullet.dmg, "Enemy projectile")
            bullet.active = false
            continue
          }

          if dist2(bullet.x, bullet.y, core_x, core_y) <=
            (bullet.r + core_r) * (bullet.r + core_r) {
            core_hp = core_hp - bullet.dmg * 0.72
            bullet.active = false
            burst(particles, bullet.x, bullet.y, 4, 0.1, 2)
            continue
          }

          for turret in turrets {
            if not(turret.active) {
              continue
            }
            if dist2(bullet.x, bullet.y, turret.x, turret.y) <=
              (bullet.r + 16.0) * (bullet.r + 16.0) {
              turret.hp = turret.hp - bullet.dmg
              bullet.active = false
              break
            }
          }
        }
      }

      // Particle update.
      for particle in particles {
        if not(particle.active) {
          continue
        }

        particle.life = particle.life - dt
        if particle.life <= 0.0 {
          particle.active = false
          continue
        }

        particle.t = particle.t + dt
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.vx = particle.vx * (1.0 - dt * 1.9)
        particle.vy = particle.vy * (1.0 - dt * 1.9)
      }

      // Loss checks.
      if core_hp <= 0.0 {
        core_hp = 0.0
        state = 3
        msg = "Core destroyed"
        msg_t = 2.4
      }
      if player.hp <= 0.0 {
        state = 3
        msg = "Pilot down"
        msg_t = 2.4
      }
    } else if @raylib.is_key_pressed(@raylib.KeyR) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      touch_press {
      state = 1
      reset_run()
    }

    // Render stage.
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

    // Background grid + moving glow.
    for gy in 0..<14 {
      let y : Int = 92 + gy * 48
      @raylib.draw_line(0, y, sw, y, @raylib.Color::new(20, 30, 46, 130))
    }
    for gx in 0..<26 {
      let x : Int = gx * 50
      @raylib.draw_line(x, 92, x, sh, @raylib.Color::new(20, 30, 46, 106))
    }

    for i in 0..<160 {
      let fi : Float = Float::from_int(i)
      let sx : Int = ((
        fi * 79.0 + stars_t * (0.2 + Float::from_int(i % 7) * 0.08)
      ) %
      Float::from_int(sw)).to_int()
      let sy : Int = ((
        fi * 137.0 + stars_t * (0.16 + Float::from_int(i % 5) * 0.09)
      ) %
      Float::from_int(sh)).to_int()
      let br : Int = 72 + i % 10 * 12
      @raylib.draw_circle(
        sx,
        sy,
        if i % 4 == 0 {
          1.8
        } else {
          1.1
        },
        @raylib.Color::new(br, br, br + 28, 170),
      )
    }

    // Arena bounds.
    @raylib.draw_rectangle(
      arena_l.to_int(),
      arena_t.to_int(),
      (arena_r - arena_l).to_int(),
      (arena_b - arena_t).to_int(),
      @raylib.Color::new(10, 18, 30, 156),
    )
    @raylib.draw_rectangle_lines(
      arena_l.to_int(),
      arena_t.to_int(),
      (arena_r - arena_l).to_int(),
      (arena_b - arena_t).to_int(),
      @raylib.Color::new(72, 112, 154, 206),
    )

    // Core.
    @raylib.draw_circle(
      core_x.to_int(),
      core_y.to_int(),
      core_r + 40.0,
      @raylib.Color::new(58, 124, 168, 66),
    )
    @raylib.draw_circle(
      core_x.to_int(),
      core_y.to_int(),
      core_r,
      @raylib.Color::new(96, 196, 242, 210),
    )
    @raylib.draw_circle_lines(
      core_x.to_int(),
      core_y.to_int(),
      core_r + 8.0,
      @raylib.Color::new(204, 242, 255, 226),
    )

    // Turrets.
    for turret in turrets {
      if not(turret.active) {
        continue
      }

      if turret.kind == 0 {
        @raylib.draw_rectangle(
          (turret.x - 15.0).to_int(),
          (turret.y - 15.0).to_int(),
          30,
          30,
          @raylib.Color::new(82, 170, 210, 242),
        )
      } else {
        @raylib.draw_rectangle(
          (turret.x - 18.0).to_int(),
          (turret.y - 18.0).to_int(),
          36,
          36,
          @raylib.Color::new(126, 156, 214, 242),
        )
      }
      @raylib.draw_rectangle_lines(
        (turret.x - 20.0).to_int(),
        (turret.y - 20.0).to_int(),
        40,
        40,
        @raylib.Color::new(210, 236, 252, 170),
      )
    }

    // Scraps.
    for scrap in scraps {
      if not(scrap.active) {
        continue
      }
      let col = if scrap.kind == 0 {
        @raylib.Color::new(112, 236, 194, 236)
      } else if scrap.kind == 1 {
        @raylib.Color::new(112, 196, 252, 236)
      } else {
        @raylib.Color::new(250, 216, 118, 236)
      }
      @raylib.draw_circle(
        scrap.x.to_int(),
        scrap.y.to_int(),
        6.0 + Float::from_int(scrap.value),
        col,
      )
    }

    // Enemies.
    for enemy in enemies {
      if not(enemy.active) {
        continue
      }
      if enemy.kind == 0 {
        @raylib.draw_circle(
          enemy.x.to_int(),
          enemy.y.to_int(),
          15.0,
          @raylib.Color::new(232, 106, 114, 242),
        )
      } else if enemy.kind == 1 {
        @raylib.draw_rectangle(
          (enemy.x - 18.0).to_int(),
          (enemy.y - 14.0).to_int(),
          36,
          28,
          @raylib.Color::new(236, 146, 80, 242),
        )
      } else {
        @raylib.draw_rectangle(
          (enemy.x - 24.0).to_int(),
          (enemy.y - 20.0).to_int(),
          48,
          40,
          @raylib.Color::new(166, 98, 192, 242),
        )
      }
      @raylib.draw_circle_lines(
        enemy.x.to_int(),
        enemy.y.to_int(),
        enemy_radius(enemy.kind) + 4.0,
        @raylib.Color::new(250, 214, 220, 150),
      )
    }

    // Bullets.
    for bullet in bullets {
      if not(bullet.active) {
        continue
      }
      let col = if bullet.team == 1 {
        if bullet.kind == 2 {
          @raylib.Color::new(128, 234, 255, 250)
        } else {
          @raylib.Color::new(250, 246, 150, 250)
        }
      } else if bullet.kind == 1 {
        @raylib.Color::new(250, 126, 234, 246)
      } else {
        @raylib.Color::new(252, 130, 140, 242)
      }
      @raylib.draw_circle(bullet.x.to_int(), bullet.y.to_int(), bullet.r, col)
    }

    // Player.
    let pcol = if player.inv_t > 0.0 {
      @raylib.Color::new(252, 252, 252, 236)
    } else {
      @raylib.Color::new(96, 194, 250, 246)
    }
    @raylib.draw_rectangle(
      (player.x - 16.0).to_int(),
      (player.y - 12.0).to_int(),
      32,
      24,
      pcol,
    )
    @raylib.draw_circle(
      player.x.to_int(),
      (player.y - 14.0).to_int(),
      8.0,
      @raylib.Color::new(216, 244, 255, 252),
    )
    @raylib.draw_line(
      player.x.to_int(),
      player.y.to_int(),
      (player.x + player.aim_x * 26.0).to_int(),
      (player.y + player.aim_y * 26.0).to_int(),
      @raylib.Color::new(194, 234, 252, 224),
    )
    if player.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        player.x.to_int(),
        player.y.to_int(),
        28.0,
        @raylib.Color::new(124, 220, 252, 210),
      )
    }

    // Build preview.
    if build_mode {
      let px : Float = clampf(mouse.x, arena_l + 30.0, arena_r - 30.0)
      let py : Float = clampf(mouse.y, arena_t + 30.0, arena_b - 30.0)
      let valid : Bool = can_place_turret(turrets, px, py)
      let col = if valid {
        @raylib.Color::new(126, 224, 176, 150)
      } else {
        @raylib.Color::new(234, 118, 140, 150)
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), 20.0, col)
      @raylib.draw_circle_lines(
        px.to_int(),
        py.to_int(),
        turret_range(selected_turret),
        @raylib.Color::new(126, 188, 224, 62),
      )
    }

    // Particles.
    for particle in particles {
      if not(particle.active) {
        continue
      }
      let alpha : Int = (clampf(particle.life / 0.82, 0.0, 1.0) * 255.0).to_int()
      let col = if particle.kind == 0 {
        @raylib.Color::new(112, 224, 252, alpha)
      } else if particle.kind == 1 {
        @raylib.Color::new(252, 236, 146, alpha)
      } else if particle.kind == 2 {
        @raylib.Color::new(252, 132, 132, alpha)
      } else {
        @raylib.Color::new(230, 166, 252, alpha)
      }
      @raylib.draw_circle(
        particle.x.to_int(),
        particle.y.to_int(),
        particle.size,
        col,
      )
    }

    // HUD.
    @raylib.draw_rectangle(0, 0, sw, 86, @raylib.Color::new(8, 12, 20, 232))
    @raylib.draw_text(
      "Arcade Factory Defense 2026",
      16,
      10,
      30,
      @raylib.Color::new(210, 236, 252, 248),
    )
    @raylib.draw_text(
      "Wave \{wave}/\{max_waves}",
      18,
      48,
      22,
      @raylib.Color::new(244, 228, 170, 252),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      206,
      48,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Scrap \{player.scrap}",
      376,
      48,
      22,
      @raylib.Color::new(170, 236, 194, 250),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      548,
      48,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      706,
      48,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Enemies \{count_active_enemies(enemies)}",
      874,
      48,
      22,
      @raylib.Color::new(248, 210, 170, 252),
    )
    @raylib.draw_text(
      "FPS \{@raylib.get_fps()}",
      sw - 118,
      12,
      22,
      @raylib.Color::new(178, 216, 240, 218),
    )

    let core_fill : Int = (clampf(core_hp / core_max_hp, 0.0, 1.0) * 290.0).to_int()
    let hp_fill : Int = (clampf(player.hp / 120.0, 0.0, 1.0) * 230.0).to_int()
    let en_fill : Int = (clampf(player.energy / 100.0, 0.0, 1.0) * 230.0).to_int()
    let heat_fill : Int = (clampf(player.heat / 100.0, 0.0, 1.0) * 230.0).to_int()

    @raylib.draw_rectangle(16, 96, 290, 12, @raylib.Color::new(22, 28, 40, 255))
    @raylib.draw_rectangle(
      16,
      96,
      core_fill,
      12,
      @raylib.Color::new(98, 200, 236, 255),
    )
    @raylib.draw_text(
      "CORE",
      16,
      112,
      16,
      @raylib.Color::new(202, 232, 250, 255),
    )

    @raylib.draw_rectangle(
      16,
      132,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      132,
      hp_fill,
      10,
      @raylib.Color::new(230, 102, 122, 255),
    )
    @raylib.draw_text("HP", 16, 146, 16, @raylib.Color::new(238, 206, 216, 255))

    @raylib.draw_rectangle(
      16,
      164,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      164,
      en_fill,
      10,
      @raylib.Color::new(90, 190, 240, 255),
    )
    @raylib.draw_text("EN", 16, 178, 16, @raylib.Color::new(206, 230, 252, 255))

    @raylib.draw_rectangle(
      16,
      196,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      196,
      heat_fill,
      10,
      @raylib.Color::new(244, 172, 98, 255),
    )
    @raylib.draw_text(
      "HEAT",
      16,
      210,
      16,
      @raylib.Color::new(246, 222, 194, 255),
    )

    let build_label : String = if build_mode { "ON" } else { "OFF" }
    let turret_label : String = if selected_turret == 0 {
      "AUTO (12)"
    } else {
      "CANNON (26)"
    }

    @raylib.draw_text(
      "Build [B]: \{build_label}",
      280,
      100,
      20,
      @raylib.Color::new(222, 234, 248, 242),
    )
    @raylib.draw_text(
      "Type [T]: \{turret_label}",
      280,
      128,
      20,
      @raylib.Color::new(222, 234, 248, 242),
    )
    @raylib.draw_text(
      "Dash [K] \{(player.dash_cd * 10.0).to_int()}",
      280,
      156,
      20,
      @raylib.Color::new(222, 234, 248, 242),
    )
    @raylib.draw_text(
      "Bomb [L] \{(player.bomb_cd * 10.0).to_int()}",
      280,
      184,
      20,
      @raylib.Color::new(222, 234, 248, 242),
    )

    if msg_t > 0.0 {
      @raylib.draw_rectangle(
        sw / 2 - 330,
        sh - 66,
        660,
        36,
        @raylib.Color::new(12, 18, 30, 212),
      )
      @raylib.draw_text(
        msg,
        sw / 2 - 310,
        sh - 58,
        22,
        @raylib.Color::new(226, 244, 252, 248),
      )
    }

    draw_touch_ui(state)

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 164))
      @raylib.draw_rectangle(
        160,
        120,
        960,
        520,
        @raylib.Color::new(12, 18, 34, 238),
      )
      @raylib.draw_rectangle_lines(
        160,
        120,
        960,
        520,
        @raylib.Color::new(94, 154, 210, 206),
      )

      @raylib.draw_text(
        "ARCADE FACTORY DEFENSE 2026",
        188,
        186,
        54,
        @raylib.Color::new(188, 236, 252, 255),
      )
      @raylib.draw_text(
        "Build turret lines, collect scrap, and survive 10 waves.",
        236,
        284,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Move: WASD / Arrows   Fire: J/Space",
        330,
        338,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Build: B   Turret Type: T   Dash: K   Bomb: L",
        272,
        378,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Touch UI supports movement + skills on mobile.",
        320,
        420,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Press Enter or tap to begin",
        442,
        510,
        34,
        @raylib.Color::new(246, 236, 176, 252),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 178))
      @raylib.draw_rectangle(
        286,
        196,
        708,
        360,
        @raylib.Color::new(14, 28, 36, 242),
      )
      @raylib.draw_rectangle_lines(
        286,
        196,
        708,
        360,
        @raylib.Color::new(104, 220, 188, 214),
      )

      @raylib.draw_text(
        "FACTORY SECURED",
        372,
        246,
        60,
        @raylib.Color::new(164, 246, 206, 254),
      )
      @raylib.draw_text(
        "Final Score: \{player.score}",
        454,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Best Combo: \{player.best_combo}   Scrap: \{player.scrap}",
        394,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to run again",
        404,
        470,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 186))
      @raylib.draw_rectangle(
        286,
        196,
        708,
        360,
        @raylib.Color::new(30, 16, 20, 246),
      )
      @raylib.draw_rectangle_lines(
        286,
        196,
        708,
        360,
        @raylib.Color::new(214, 106, 120, 214),
      )

      @raylib.draw_text(
        "DEFENSE FAILED",
        404,
        246,
        60,
        @raylib.Color::new(248, 164, 176, 252),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        498,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Wave Reached: \{wave}",
        500,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to retry",
        430,
        470,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
