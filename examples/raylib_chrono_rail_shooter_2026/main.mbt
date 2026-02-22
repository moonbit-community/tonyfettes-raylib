///|
let sw : Int = 1280

///|
let sh : Int = 720

///|
let rail_l : Float = 220.0

///|
let rail_r : Float = 1060.0

///|
let max_enemies : Int = 240

///|
let max_bullets : Int = 960

///|
let max_pickups : Int = 160

///|
let max_particles : Int = 1300

///|
let max_panels : Int = 240

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut energy : Float
  mut heat : Float
  mut fire_cd : Float
  mut rocket_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut emp_cd : Float
  mut inv_t : Float
  mut shield_on : Bool
  mut score : Int
  mut combo : Int
  mut best_combo : Int
  mut distance : Float
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
  mut phase : Float
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
  mut radius : Float
  mut life : Float
}

///|
struct Pickup {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vy : Float
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
struct Panel {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut hazard : Bool
  mut boost : Bool
  mut t : Float
}

///|
struct Boss {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut hp : Float
  mut max_hp : Float
  mut fire_cd : Float
  mut spawn_cd : Float
  mut phase : Float
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
fn enemy_radius(kind : Int) -> Float {
  if kind == 0 {
    16.0
  } else if kind == 1 {
    20.0
  } else {
    26.0
  }
}

///|
fn enemy_hp(kind : Int, level : Int) -> Float {
  if kind == 0 {
    22.0 + Float::from_int(level) * 2.0
  } else if kind == 1 {
    34.0 + Float::from_int(level) * 3.4
  } else {
    74.0 + Float::from_int(level) * 4.8
  }
}

///|
fn clear_enemies(enemies : Array[Enemy]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].active = false
    enemies[i].kind = 0
    enemies[i].x = 0.0
    enemies[i].y = 0.0
    enemies[i].vx = 0.0
    enemies[i].vy = 0.0
    enemies[i].hp = 0.0
    enemies[i].fire_cd = 0.0
    enemies[i].phase = 0.0
    enemies[i].t = 0.0
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].active = false
    bullets[i].team = 0
    bullets[i].kind = 0
    bullets[i].x = 0.0
    bullets[i].y = 0.0
    bullets[i].vx = 0.0
    bullets[i].vy = 0.0
    bullets[i].dmg = 0.0
    bullets[i].radius = 0.0
    bullets[i].life = 0.0
  }
}

///|
fn clear_pickups(pickups : Array[Pickup]) -> Unit {
  for i = 0; i < pickups.length(); i = i + 1 {
    pickups[i].active = false
    pickups[i].kind = 0
    pickups[i].x = 0.0
    pickups[i].y = 0.0
    pickups[i].vy = 0.0
    pickups[i].t = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].kind = 0
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].life = 0.0
    parts[i].t = 0.0
  }
}

///|
fn clear_panels(panels : Array[Panel]) -> Unit {
  for i = 0; i < panels.length(); i = i + 1 {
    panels[i].active = false
    panels[i].x = 0.0
    panels[i].y = 0.0
    panels[i].w = 0.0
    panels[i].h = 0.0
    panels[i].hazard = false
    panels[i].boost = false
    panels[i].t = 0.0
  }
}

///|
fn add_enemy(
  enemies : Array[Enemy],
  kind : Int,
  x : Float,
  y : Float,
  level : Int,
) -> Bool {
  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].active) {
      enemies[i].active = true
      enemies[i].kind = kind
      enemies[i].x = x
      enemies[i].y = y
      enemies[i].vx = 0.0
      enemies[i].vy = 0.0
      enemies[i].hp = enemy_hp(kind, level)
      enemies[i].phase = randf(0.0, 99.0)
      enemies[i].t = 0.0
      if kind == 0 {
        enemies[i].fire_cd = randf(0.8, 1.4)
      } else if kind == 1 {
        enemies[i].fire_cd = randf(0.66, 1.2)
      } else {
        enemies[i].fire_cd = randf(1.3, 2.0)
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
  radius : Float,
  life : Float,
) -> Bool {
  for i = 0; i < bullets.length(); i = i + 1 {
    if not(bullets[i].active) {
      bullets[i].active = true
      bullets[i].team = team
      bullets[i].kind = kind
      bullets[i].x = x
      bullets[i].y = y
      bullets[i].vx = vx
      bullets[i].vy = vy
      bullets[i].dmg = dmg
      bullets[i].radius = radius
      bullets[i].life = life
      return true
    }
  }
  false
}

///|
fn add_pickup(
  pickups : Array[Pickup],
  kind : Int,
  x : Float,
  y : Float,
  vy : Float,
) -> Bool {
  for i = 0; i < pickups.length(); i = i + 1 {
    if not(pickups[i].active) {
      pickups[i].active = true
      pickups[i].kind = kind
      pickups[i].x = x
      pickups[i].y = y
      pickups[i].vy = vy
      pickups[i].t = 0.0
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
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].kind = kind
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = vx
      parts[i].vy = vy
      parts[i].size = size
      parts[i].life = life
      parts[i].t = 0.0
      return true
    }
  }
  false
}

///|
fn add_panel(
  panels : Array[Panel],
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  hazard : Bool,
  boost : Bool,
) -> Bool {
  for i = 0; i < panels.length(); i = i + 1 {
    if not(panels[i].active) {
      panels[i].active = true
      panels[i].x = x
      panels[i].y = y
      panels[i].w = w
      panels[i].h = h
      panels[i].hazard = hazard
      panels[i].boost = boost
      panels[i].t = 0.0
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
  for _i = 0; _i < count; _i = _i + 1 {
    let ang = randf(0.0, 6.283)
    let spd = randf(60.0, 260.0) * scale
    ignore(
      add_particle(
        parts,
        kind,
        x,
        y,
        @math.cosf(ang) * spd,
        @math.sinf(ang) * spd,
        randf(2.0, 5.0) * scale,
        randf(0.2, 0.7),
      ),
    )
  }
}

///|
fn draw_touch_ui(state : Int) -> Unit {
  if state != 1 {
    ignore(())
  } else {
    let pad_x : Int = 24
    let pad_y : Int = sh - 220

    let btn_x : Int = sw - 334
    let btn_y : Int = sh - 230

    @raylib.draw_rectangle(
      pad_x,
      pad_y,
      220,
      200,
      @raylib.Color::new(6, 10, 18, 92),
    )
    @raylib.draw_rectangle_lines(
      pad_x,
      pad_y,
      220,
      200,
      @raylib.Color::new(90, 130, 170, 166),
    )

    @raylib.draw_rectangle(
      pad_x + 14,
      pad_y + 74,
      56,
      56,
      @raylib.Color::new(20, 34, 52, 166),
    )
    @raylib.draw_rectangle(
      pad_x + 150,
      pad_y + 74,
      56,
      56,
      @raylib.Color::new(20, 34, 52, 166),
    )
    @raylib.draw_rectangle(
      pad_x + 82,
      pad_y + 14,
      56,
      56,
      @raylib.Color::new(20, 34, 52, 166),
    )
    @raylib.draw_rectangle(
      pad_x + 82,
      pad_y + 134,
      56,
      56,
      @raylib.Color::new(20, 34, 52, 166),
    )
    @raylib.draw_text(
      "L",
      pad_x + 35,
      pad_y + 88,
      24,
      @raylib.Color::new(186, 220, 244, 240),
    )
    @raylib.draw_text(
      "R",
      pad_x + 170,
      pad_y + 88,
      24,
      @raylib.Color::new(186, 220, 244, 240),
    )
    @raylib.draw_text(
      "U",
      pad_x + 102,
      pad_y + 28,
      24,
      @raylib.Color::new(186, 220, 244, 240),
    )
    @raylib.draw_text(
      "D",
      pad_x + 101,
      pad_y + 148,
      24,
      @raylib.Color::new(186, 220, 244, 240),
    )

    @raylib.draw_rectangle(
      btn_x,
      btn_y,
      300,
      206,
      @raylib.Color::new(8, 12, 18, 96),
    )
    @raylib.draw_rectangle_lines(
      btn_x,
      btn_y,
      300,
      206,
      @raylib.Color::new(100, 144, 190, 170),
    )

    @raylib.draw_rectangle(
      btn_x + 14,
      btn_y + 14,
      130,
      82,
      @raylib.Color::new(28, 40, 58, 178),
    )
    @raylib.draw_rectangle(
      btn_x + 156,
      btn_y + 14,
      130,
      82,
      @raylib.Color::new(28, 40, 58, 178),
    )
    @raylib.draw_rectangle(
      btn_x + 14,
      btn_y + 108,
      130,
      82,
      @raylib.Color::new(28, 40, 58, 178),
    )
    @raylib.draw_rectangle(
      btn_x + 156,
      btn_y + 108,
      130,
      82,
      @raylib.Color::new(28, 40, 58, 178),
    )

    @raylib.draw_text(
      "FIRE",
      btn_x + 44,
      btn_y + 46,
      22,
      @raylib.Color::new(244, 250, 254, 242),
    )
    @raylib.draw_text(
      "DASH",
      btn_x + 185,
      btn_y + 46,
      22,
      @raylib.Color::new(244, 250, 254, 242),
    )
    @raylib.draw_text(
      "ROCK",
      btn_x + 42,
      btn_y + 140,
      22,
      @raylib.Color::new(244, 250, 254, 242),
    )
    @raylib.draw_text(
      "EMP",
      btn_x + 198,
      btn_y + 140,
      22,
      @raylib.Color::new(244, 250, 254, 242),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] chrono rail shooter 2026")
  @raylib.set_target_fps(60)

  let player : Player = {
    x: (rail_l + rail_r) * 0.5,
    y: 582.0,
    vx: 0.0,
    vy: 0.0,
    hp: 100.0,
    energy: 100.0,
    heat: 0.0,
    fire_cd: 0.0,
    rocket_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    emp_cd: 0.0,
    inv_t: 0.0,
    shield_on: false,
    score: 0,
    combo: 0,
    best_combo: 0,
    distance: 0.0,
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
      phase: 0.0,
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
      radius: 0.0,
      life: 0.0,
    }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, kind: 0, x: 0.0, y: 0.0, vy: 0.0, t: 0.0 }
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

  let panels : Array[Panel] = Array::makei(max_panels, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      w: 0.0,
      h: 0.0,
      hazard: false,
      boost: false,
      t: 0.0,
    }
  })

  let boss : Boss = {
    active: false,
    x: (rail_l + rail_r) * 0.5,
    y: -240.0,
    hp: 0.0,
    max_hp: 0.0,
    fire_cd: 0.0,
    spawn_cd: 0.0,
    phase: 0.0,
    t: 0.0,
  }

  let mut state : Int = 0
  let mut enemy_cd : Float = 0.6
  let mut pickup_cd : Float = 2.2
  let mut panel_cd : Float = 0.28
  let mut storm_t : Float = 0.0
  let mut msg : String = "Escort the chrono train through the timeline"
  let mut msg_t : Float = 3.0
  let mut boss_triggered : Bool = false
  let distance_goal : Float = 9000.0

  let reset_run = fn() {
    player.x = (rail_l + rail_r) * 0.5
    player.y = 582.0
    player.vx = 0.0
    player.vy = 0.0
    player.hp = 100.0
    player.energy = 100.0
    player.heat = 0.0
    player.fire_cd = 0.0
    player.rocket_cd = 0.0
    player.dash_cd = 0.0
    player.dash_t = 0.0
    player.emp_cd = 0.0
    player.inv_t = 0.0
    player.shield_on = false
    player.score = 0
    player.combo = 0
    player.best_combo = 0
    player.distance = 0.0

    clear_enemies(enemies)
    clear_bullets(bullets)
    clear_pickups(pickups)
    clear_particles(particles)
    clear_panels(panels)

    enemy_cd = 0.68
    pickup_cd = 2.0
    panel_cd = 0.26
    storm_t = 0.0
    msg = "Phase 1: Neon Tunnel"
    msg_t = 2.4
    boss_triggered = false
    boss.active = false
    boss.x = (rail_l + rail_r) * 0.5
    boss.y = -240.0
    boss.hp = 0.0
    boss.max_hp = 0.0
    boss.fire_cd = 0.0
    boss.spawn_cd = 0.0
    boss.phase = 0.0
    boss.t = 0.0

    for i = 0; i < 18; i = i + 1 {
      let y = -Float::from_int(i) * 86.0
      ignore(
        add_panel(
          panels,
          randf(rail_l + 120.0, rail_r - 120.0),
          y,
          randf(130.0, 280.0),
          randf(24.0, 36.0),
          @raylib.get_random_value(0, 99) < 24,
          false,
        ),
      )
    }
  }

  let on_player_hit = fn(dmg : Float, reason : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut final_dmg = dmg
      if player.shield_on {
        final_dmg = final_dmg * 0.44
      }
      player.hp = player.hp - final_dmg
      player.inv_t = 0.36
      player.combo = 0
      msg = reason
      msg_t = 0.9
      burst(particles, player.x, player.y, 16, 0.22, 2)
      if player.hp < 0.0 {
        player.hp = 0.0
      }
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

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      let level : Int = player.distance.to_int() / 900 + 1
      let mut scroll_speed : Float = 220.0 + Float::from_int(level) * 14.0
      if boss.active {
        scroll_speed = 210.0
      }

      storm_t = storm_t + dt * (1.8 + Float::from_int(level) * 0.08)

      player.distance = player.distance + scroll_speed * dt * 0.42

      player.energy = player.energy + dt * 11.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      player.heat = player.heat - dt * 42.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      player.fire_cd = player.fire_cd - dt
      if player.fire_cd < 0.0 {
        player.fire_cd = 0.0
      }

      player.rocket_cd = player.rocket_cd - dt
      if player.rocket_cd < 0.0 {
        player.rocket_cd = 0.0
      }

      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }

      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }

      player.emp_cd = player.emp_cd - dt
      if player.emp_cd < 0.0 {
        player.emp_cd = 0.0
      }

      player.inv_t = player.inv_t - dt
      if player.inv_t < 0.0 {
        player.inv_t = 0.0
      }

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
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut rocket_press : Bool = @raylib.is_key_pressed(@raylib.KeyE)
      let mut emp_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)
      let mut shield_hold : Bool = @raylib.is_key_down(@raylib.KeyRightShift)

      let pad_x : Int = 24
      let pad_y : Int = sh - 220
      let btn_x : Int = sw - 334
      let btn_y : Int = sh - 230

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x + 14, pad_y + 74, 56, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 150, pad_y + 74, 56, 56) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 82, pad_y + 14, 56, 56) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 82, pad_y + 134, 56, 56) {
          move_d = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 14, btn_y + 14, 130, 82) {
          fire_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 156, btn_y + 14, 130, 82) {
          shield_hold = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 156, btn_y + 14, 130, 82) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 14, btn_y + 108, 130, 82) {
          rocket_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 156, btn_y + 108, 130, 82) {
          emp_press = true
        }
      }

      player.shield_on = false
      if shield_hold && player.energy > 0.0 {
        player.shield_on = true
        player.energy = player.energy - dt * 19.0
        if player.energy < 0.0 {
          player.energy = 0.0
        }
      }

      let accel : Float = if player.dash_t > 0.0 { 1700.0 } else { 1050.0 }

      if move_l {
        player.vx = player.vx - accel * dt
      }
      if move_r {
        player.vx = player.vx + accel * dt
      }
      if move_u {
        player.vy = player.vy - accel * 0.8 * dt
      }
      if move_d {
        player.vy = player.vy + accel * 0.8 * dt
      }

      let drag : Float = if player.dash_t > 0.0 { 1.6 } else { 4.8 }
      player.vx = player.vx * (1.0 - dt * drag)
      player.vy = player.vy * (1.0 - dt * drag)

      player.vx = clampf(player.vx, -420.0, 420.0)
      player.vy = clampf(player.vy, -360.0, 360.0)

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 22.0 {
        player.dash_cd = 1.0
        player.dash_t = 0.22
        player.energy = player.energy - 22.0

        let mut dx : Float = 0.0
        let mut dy : Float = -0.7
        if move_l {
          dx = dx - 1.0
        }
        if move_r {
          dx = dx + 1.0
        }
        if move_u {
          dy = dy - 0.8
        }
        if move_d {
          dy = dy + 1.0
        }

        let mut n2 : Float = dx * dx + dy * dy
        if n2 < 0.01 {
          dx = 0.0
          dy = -1.0
          n2 = 1.0
        }
        let inv : Float = 1.0 / n2.sqrt()
        player.vx = player.vx + dx * inv * 520.0
        player.vy = player.vy + dy * inv * 520.0

        burst(particles, player.x, player.y, 18, 0.25, 0)
      }

      if fire_hold && player.fire_cd <= 0.0 && player.heat <= 92.0 {
        let base_cd : Float = clampf(
          0.11 - Float::from_int(level) * 0.002,
          0.065,
          0.11,
        )
        player.fire_cd = base_cd
        player.heat = player.heat + 8.0

        ignore(
          add_bullet(
            bullets,
            1,
            0,
            player.x,
            player.y - 24.0,
            0.0,
            -650.0,
            14.0,
            4.0,
            1.1,
          ),
        )

        if level >= 4 {
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x - 11.0,
              player.y - 18.0,
              -80.0,
              -640.0,
              10.0,
              3.0,
              1.1,
            ),
          )
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + 11.0,
              player.y - 18.0,
              80.0,
              -640.0,
              10.0,
              3.0,
              1.1,
            ),
          )
        }

        burst(particles, player.x, player.y - 24.0, 8, 0.16, 1)
      }

      if rocket_press && player.rocket_cd <= 0.0 && player.energy >= 26.0 {
        player.rocket_cd = 1.35
        player.energy = player.energy - 26.0
        ignore(
          add_bullet(
            bullets,
            1,
            1,
            player.x,
            player.y - 28.0,
            0.0,
            -470.0,
            36.0,
            8.0,
            2.0,
          ),
        )
        msg = "Chrono rocket launched"
        msg_t = 0.48
      }

      if emp_press && player.emp_cd <= 0.0 && player.energy >= 50.0 {
        player.emp_cd = 5.6
        player.energy = player.energy - 50.0
        msg = "EMP pulse"
        msg_t = 0.56

        burst(particles, player.x, player.y, 80, 0.34, 3)

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            bullets[i].team == 2 &&
            dist2(player.x, player.y, bullets[i].x, bullets[i].y) <=
            280.0 * 280.0 {
            bullets[i].active = false
          }
        }

        for i = 0; i < enemies.length(); i = i + 1 {
          if enemies[i].active &&
            dist2(player.x, player.y, enemies[i].x, enemies[i].y) <=
            290.0 * 290.0 {
            enemies[i].hp = enemies[i].hp - 42.0
            enemies[i].vx = enemies[i].vx * 0.2
          }
        }

        if boss.active &&
          dist2(player.x, player.y, boss.x, boss.y) <= 340.0 * 340.0 {
          boss.hp = boss.hp - 54.0
        }
      }

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      player.x = clampf(player.x, rail_l + 20.0, rail_r - 20.0)
      player.y = clampf(player.y, 140.0, Float::from_int(sh) - 48.0)

      panel_cd = panel_cd - dt
      if panel_cd <= 0.0 {
        panel_cd = randf(0.14, 0.42)

        let mut w : Float = randf(124.0, 290.0)
        if boss.active {
          w = randf(148.0, 320.0)
        }
        let h : Float = randf(22.0, 36.0)

        let x = randf(rail_l + w * 0.5 + 2.0, rail_r - w * 0.5 - 2.0)
        let hazard : Bool = @raylib.get_random_value(0, 99) <
          clampf(20.0 + Float::from_int(level) * 1.8, 20.0, 64.0).to_int()
        let boost : Bool = not(hazard) && @raylib.get_random_value(0, 99) < 14
        ignore(add_panel(panels, x, -60.0, w, h, hazard, boost))
      }

      for i = 0; i < panels.length(); i = i + 1 {
        if not(panels[i].active) {
          continue
        }

        panels[i].t = panels[i].t + dt
        panels[i].y = panels[i].y + scroll_speed * dt

        if panels[i].y - panels[i].h * 0.5 > Float::from_int(sh) + 80.0 {
          panels[i].active = false
          continue
        }

        if absf(panels[i].y - player.y) <= panels[i].h * 0.5 + 16.0 &&
          player.x >= panels[i].x - panels[i].w * 0.5 - 12.0 &&
          player.x <= panels[i].x + panels[i].w * 0.5 + 12.0 {
          if panels[i].hazard {
            on_player_hit(12.0, "Rail hazard")
            panels[i].active = false
            burst(particles, player.x, player.y, 14, 0.2, 2)
          } else if panels[i].boost {
            player.vy = player.vy - 180.0
            player.energy = clampf(player.energy + 16.0, 0.0, 100.0)
            panels[i].boost = false
            msg = "Boost strip"
            msg_t = 0.42
            burst(particles, player.x, player.y, 10, 0.18, 0)
          }
        }
      }

      enemy_cd = enemy_cd - dt
      if enemy_cd <= 0.0 {
        if not(boss.active) {
          let roll = @raylib.get_random_value(0, 99)
          let mut kind = 0
          if level >= 3 && roll >= 45 {
            kind = 1
          }
          if level >= 6 && roll >= 78 {
            kind = 2
          }

          let ex = randf(rail_l + 38.0, rail_r - 38.0)
          ignore(add_enemy(enemies, kind, ex, -90.0, level))

          let cd_raw = randf(0.34, 0.94) - Float::from_int(level) * 0.03
          enemy_cd = clampf(cd_raw, 0.16, 0.94)
        } else {
          enemy_cd = 0.4
        }
      }

      pickup_cd = pickup_cd - dt
      if pickup_cd <= 0.0 {
        pickup_cd = randf(3.2, 6.0)
        if @raylib.get_random_value(0, 99) < 68 {
          let kind = @raylib.get_random_value(0, 2)
          ignore(
            add_pickup(
              pickups,
              kind,
              randf(rail_l + 36.0, rail_r - 36.0),
              -40.0,
              randf(130.0, 190.0),
            ),
          )
        }
      }

      if not(boss_triggered) && player.distance >= distance_goal * 0.68 {
        boss_triggered = true
        boss.active = true
        boss.x = (rail_l + rail_r) * 0.5
        boss.y = -220.0
        boss.max_hp = 1400.0
        boss.hp = boss.max_hp
        boss.fire_cd = 1.2
        boss.spawn_cd = 2.2
        boss.phase = randf(0.0, 30.0)
        boss.t = 0.0
        msg = "Boss: Chrono Warden"
        msg_t = 2.2
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        enemies[i].t = enemies[i].t + dt
        enemies[i].fire_cd = enemies[i].fire_cd - dt

        if enemies[i].kind == 0 {
          enemies[i].vy = scroll_speed + 90.0
          enemies[i].vx = @math.sinf(enemies[i].t * 2.2 + enemies[i].phase) *
            96.0
        } else if enemies[i].kind == 1 {
          enemies[i].vy = scroll_speed + 132.0
          enemies[i].vx = @math.sinf(enemies[i].t * 3.0 + enemies[i].phase) *
            148.0
        } else {
          enemies[i].vy = scroll_speed + 78.0
          enemies[i].vx = @math.sinf(enemies[i].t * 1.3 + enemies[i].phase) *
            72.0
        }

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt
        enemies[i].x = clampf(enemies[i].x, rail_l + 18.0, rail_r - 18.0)

        if enemies[i].y > Float::from_int(sh) + 80.0 {
          enemies[i].active = false
          continue
        }

        if enemies[i].fire_cd <= 0.0 &&
          enemies[i].y < Float::from_int(sh) - 20.0 {
          let tx = player.x - enemies[i].x
          let ty = player.y - enemies[i].y
          let mut inv : Float = 0.0
          let l2 : Float = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }

          let spd : Float = 230.0 +
            Float::from_int(level) * 6.0 +
            Float::from_int(enemies[i].kind) * 22.0

          if enemies[i].kind <= 1 {
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemies[i].x,
                enemies[i].y,
                tx * inv * spd,
                ty * inv * spd,
                8.0 + Float::from_int(enemies[i].kind) * 2.0,
                5.0,
                3.4,
              ),
            )
            if enemies[i].kind == 0 {
              enemies[i].fire_cd = randf(0.92, 1.46)
            } else {
              enemies[i].fire_cd = randf(0.72, 1.16)
            }
          } else {
            ignore(
              add_bullet(
                bullets,
                2,
                1,
                enemies[i].x,
                enemies[i].y,
                tx * inv * spd,
                ty * inv * spd,
                12.0,
                6.0,
                3.8,
              ),
            )
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemies[i].x,
                enemies[i].y,
                tx * inv * (spd - 56.0) - 66.0,
                ty * inv * (spd - 56.0),
                8.0,
                4.0,
                3.4,
              ),
            )
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                enemies[i].x,
                enemies[i].y,
                tx * inv * (spd - 56.0) + 66.0,
                ty * inv * (spd - 56.0),
                8.0,
                4.0,
                3.4,
              ),
            )
            enemies[i].fire_cd = randf(1.26, 1.92)
          }
        }

        if dist2(enemies[i].x, enemies[i].y, player.x, player.y) <=
          (enemy_radius(enemies[i].kind) + 17.0) *
          (enemy_radius(enemies[i].kind) + 17.0) {
          on_player_hit(
            10.0 + Float::from_int(enemies[i].kind) * 2.6,
            "Hull collision",
          )
          enemies[i].active = false
          burst(particles, player.x, player.y, 22, 0.25, 2)
        }
      }

      if boss.active {
        boss.t = boss.t + dt
        boss.fire_cd = boss.fire_cd - dt
        boss.spawn_cd = boss.spawn_cd - dt

        if boss.y < 128.0 {
          boss.y = boss.y + dt * 120.0
        } else {
          boss.x = (rail_l + rail_r) * 0.5 +
            @math.sinf(boss.t * 0.9 + boss.phase) * 280.0
        }

        if boss.fire_cd <= 0.0 {
          boss.fire_cd = randf(0.52, 0.9)
          for k = -2; k <= 2; k = k + 1 {
            let tx = player.x - boss.x + Float::from_int(k) * 40.0
            let ty = player.y - boss.y
            let mut inv : Float = 0.0
            let l2 = tx * tx + ty * ty
            if l2 > 0.01 {
              inv = 1.0 / l2.sqrt()
            }
            ignore(
              add_bullet(
                bullets,
                2,
                1,
                boss.x,
                boss.y + 28.0,
                tx * inv * 260.0,
                ty * inv * 260.0,
                10.0,
                6.0,
                4.0,
              ),
            )
          }
        }

        if boss.spawn_cd <= 0.0 {
          boss.spawn_cd = randf(1.5, 2.8)
          ignore(
            add_enemy(
              enemies,
              @raylib.get_random_value(0, 2),
              boss.x + randf(-180.0, 180.0),
              boss.y + 32.0,
              level,
            ),
          )
        }

        if dist2(player.x, player.y, boss.x, boss.y) <= 56.0 * 56.0 {
          on_player_hit(18.0, "Boss ram")
        }

        if boss.hp <= 0.0 {
          boss.active = false
          state = 2
          msg = "Timeline stabilized"
          msg_t = 3.4
          burst(particles, boss.x, boss.y, 120, 0.44, 3)
          player.score = player.score + 1200
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

        if bullets[i].team == 2 {
          bullets[i].y = bullets[i].y + scroll_speed * dt * 0.2
        }

        if bullets[i].x < rail_l - 120.0 ||
          bullets[i].x > rail_r + 120.0 ||
          bullets[i].y < -220.0 ||
          bullets[i].y > Float::from_int(sh) + 220.0 {
          bullets[i].active = false
          continue
        }

        if bullets[i].team == 1 {
          let mut hit_done : Bool = false
          for j = 0; j < enemies.length(); j = j + 1 {
            if hit_done {
              continue
            }
            if not(enemies[j].active) {
              continue
            }

            let rr = bullets[i].radius + enemy_radius(enemies[j].kind)
            if dist2(bullets[i].x, bullets[i].y, enemies[j].x, enemies[j].y) <=
              rr * rr {
              enemies[j].hp = enemies[j].hp - bullets[i].dmg
              bullets[i].active = false
              hit_done = true

              burst(particles, bullets[i].x, bullets[i].y, 6, 0.12, 1)

              if enemies[j].hp <= 0.0 {
                enemies[j].active = false
                player.score = player.score +
                  52 +
                  enemies[j].kind * 24 +
                  player.combo * 3
                player.combo = player.combo + 1
                if player.combo > player.best_combo {
                  player.best_combo = player.combo
                }
                if @raylib.get_random_value(0, 99) < 22 + enemies[j].kind * 10 {
                  ignore(
                    add_pickup(
                      pickups,
                      @raylib.get_random_value(0, 2),
                      enemies[j].x,
                      enemies[j].y,
                      120.0,
                    ),
                  )
                }
                burst(particles, enemies[j].x, enemies[j].y, 22, 0.2, 0)
              }
            }
          }

          if bullets[i].active && boss.active {
            let rr = bullets[i].radius + 48.0
            if dist2(bullets[i].x, bullets[i].y, boss.x, boss.y) <= rr * rr {
              boss.hp = boss.hp - bullets[i].dmg
              bullets[i].active = false
              player.score = player.score + 8
              burst(particles, bullets[i].x, bullets[i].y, 5, 0.1, 3)
            }
          }
        } else {
          let rr = bullets[i].radius + 16.0
          if dist2(bullets[i].x, bullets[i].y, player.x, player.y) <= rr * rr {
            on_player_hit(bullets[i].dmg, "Enemy fire")
            bullets[i].active = false
          }
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }

        pickups[i].t = pickups[i].t + dt
        pickups[i].y = pickups[i].y + (pickups[i].vy + scroll_speed * 0.48) * dt
        pickups[i].x = pickups[i].x +
          @math.sinf(pickups[i].t * 2.0 + Float::from_int(i)) * 38.0 * dt
        pickups[i].x = clampf(pickups[i].x, rail_l + 18.0, rail_r - 18.0)

        if pickups[i].y > Float::from_int(sh) + 70.0 {
          pickups[i].active = false
          continue
        }

        if dist2(player.x, player.y, pickups[i].x, pickups[i].y) <= 26.0 * 26.0 {
          if pickups[i].kind == 0 {
            player.hp = clampf(player.hp + 16.0, 0.0, 100.0)
            msg = "Repair kit"
          } else if pickups[i].kind == 1 {
            player.energy = clampf(player.energy + 26.0, 0.0, 100.0)
            msg = "Energy cell"
          } else {
            player.score = player.score + 160 + player.combo * 4
            msg = "Chrono shard"
          }
          msg_t = 0.55
          pickups[i].active = false
          burst(particles, pickups[i].x, pickups[i].y, 12, 0.16, 0)
        }
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].life = particles[i].life - dt
        if particles[i].life <= 0.0 {
          particles[i].active = false
          continue
        }

        particles[i].t = particles[i].t + dt
        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vy = particles[i].vy + dt * 120.0
        particles[i].vx = particles[i].vx * (1.0 - dt * 1.5)
      }

      if player.hp <= 0.0 {
        state = 3
        msg = "Train lost in timeline fracture"
        msg_t = 3.2
      }

      if player.distance >= distance_goal && not(boss.active) {
        state = 2
        msg = "Route complete"
        msg_t = 2.4
      }
    } else if @raylib.is_key_pressed(@raylib.KeyR) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      pressed {
      state = 1
      reset_run()
    }

    @raylib.begin_drawing()

    @raylib.clear_background(@raylib.Color::new(6, 10, 18, 255))

    let mut horizon_shift : Float = storm_t * 64.0
    while horizon_shift > 64.0 {
      horizon_shift = horizon_shift - 64.0
    }

    for i = 0; i < 14; i = i + 1 {
      let y = (Float::from_int(i) * 64.0 + horizon_shift).to_int() - 64
      let shade : Int = 18 + i * 3
      @raylib.draw_rectangle(
        0,
        y,
        sw,
        32,
        @raylib.Color::new(shade, shade + 8, 32 + i * 4, 255),
      )
    }

    @raylib.draw_rectangle(
      0,
      0,
      rail_l.to_int(),
      sh,
      @raylib.Color::new(10, 14, 24, 255),
    )
    @raylib.draw_rectangle(
      rail_r.to_int(),
      0,
      sw - rail_r.to_int(),
      sh,
      @raylib.Color::new(10, 14, 24, 255),
    )

    @raylib.draw_line(
      rail_l.to_int(),
      0,
      rail_l.to_int(),
      sh,
      @raylib.Color::new(70, 120, 170, 210),
    )
    @raylib.draw_line(
      rail_r.to_int(),
      0,
      rail_r.to_int(),
      sh,
      @raylib.Color::new(70, 120, 170, 210),
    )

    for i = 0; i < panels.length(); i = i + 1 {
      if not(panels[i].active) {
        continue
      }

      let x = (panels[i].x - panels[i].w * 0.5).to_int()
      let y = (panels[i].y - panels[i].h * 0.5).to_int()
      let w = panels[i].w.to_int()
      let h = panels[i].h.to_int()

      let col = if panels[i].hazard {
        @raylib.Color::new(148, 54, 66, 244)
      } else if panels[i].boost {
        @raylib.Color::new(44, 138, 166, 244)
      } else {
        @raylib.Color::new(60, 68, 88, 236)
      }
      @raylib.draw_rectangle(x, y, w, h, col)
      @raylib.draw_rectangle_lines(
        x,
        y,
        w,
        h,
        @raylib.Color::new(22, 28, 40, 255),
      )

      if panels[i].hazard {
        for k = 0; k < 4; k = k + 1 {
          let lx0 = x + 8 + k * ((w - 16) / 4)
          let ly0 = y + 4
          let lx1 = lx0 + 10
          let ly1 = y + h - 4
          @raylib.draw_line(
            lx0,
            ly0,
            lx1,
            ly1,
            @raylib.Color::new(240, 148, 106, 230),
          )
        }
      }
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }

      let col = if pickups[i].kind == 0 {
        @raylib.Color::new(110, 236, 182, 246)
      } else if pickups[i].kind == 1 {
        @raylib.Color::new(102, 170, 252, 246)
      } else {
        @raylib.Color::new(252, 208, 94, 246)
      }
      @raylib.draw_circle(
        pickups[i].x.to_int(),
        pickups[i].y.to_int(),
        10.0,
        col,
      )
      @raylib.draw_circle_lines(
        pickups[i].x.to_int(),
        pickups[i].y.to_int(),
        14.0,
        @raylib.Color::new(250, 250, 250, 180),
      )
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if not(enemies[i].active) {
        continue
      }

      if enemies[i].kind == 0 {
        @raylib.draw_circle(
          enemies[i].x.to_int(),
          enemies[i].y.to_int(),
          16.0,
          @raylib.Color::new(224, 92, 94, 242),
        )
        @raylib.draw_circle_lines(
          enemies[i].x.to_int(),
          enemies[i].y.to_int(),
          20.0,
          @raylib.Color::new(248, 196, 198, 180),
        )
      } else if enemies[i].kind == 1 {
        @raylib.draw_rectangle(
          (enemies[i].x - 18.0).to_int(),
          (enemies[i].y - 14.0).to_int(),
          36,
          28,
          @raylib.Color::new(220, 122, 62, 244),
        )
        @raylib.draw_rectangle_lines(
          (enemies[i].x - 22.0).to_int(),
          (enemies[i].y - 18.0).to_int(),
          44,
          36,
          @raylib.Color::new(248, 226, 200, 176),
        )
      } else {
        @raylib.draw_rectangle(
          (enemies[i].x - 24.0).to_int(),
          (enemies[i].y - 20.0).to_int(),
          48,
          40,
          @raylib.Color::new(156, 84, 170, 240),
        )
        @raylib.draw_circle(
          enemies[i].x.to_int(),
          (enemies[i].y - 4.0).to_int(),
          12.0,
          @raylib.Color::new(236, 188, 250, 210),
        )
      }
    }

    if boss.active {
      @raylib.draw_rectangle(
        (boss.x - 72.0).to_int(),
        (boss.y - 36.0).to_int(),
        144,
        72,
        @raylib.Color::new(140, 56, 166, 246),
      )
      @raylib.draw_rectangle_lines(
        (boss.x - 80.0).to_int(),
        (boss.y - 44.0).to_int(),
        160,
        88,
        @raylib.Color::new(246, 218, 255, 180),
      )
      @raylib.draw_circle(
        boss.x.to_int(),
        (boss.y + 6.0).to_int(),
        17.0,
        @raylib.Color::new(220, 170, 248, 230),
      )

      let boss_fill : Int = (clampf(boss.hp / boss.max_hp, 0.0, 1.0) * 420.0).to_int()

      @raylib.draw_rectangle(
        432,
        18,
        420,
        12,
        @raylib.Color::new(28, 20, 38, 255),
      )
      @raylib.draw_rectangle(
        432,
        18,
        boss_fill,
        12,
        @raylib.Color::new(214, 102, 228, 255),
      )
      @raylib.draw_text(
        "BOSS",
        380,
        14,
        18,
        @raylib.Color::new(240, 208, 252, 250),
      )
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }

      let col = if bullets[i].team == 1 {
        if bullets[i].kind == 1 {
          @raylib.Color::new(120, 238, 255, 248)
        } else {
          @raylib.Color::new(248, 246, 150, 248)
        }
      } else if bullets[i].kind == 1 {
        @raylib.Color::new(244, 114, 232, 246)
      } else {
        @raylib.Color::new(250, 120, 126, 242)
      }

      @raylib.draw_circle(
        bullets[i].x.to_int(),
        bullets[i].y.to_int(),
        bullets[i].radius,
        col,
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let life01 : Float = clampf(particles[i].life / 0.8, 0.0, 1.0)
      let alpha : Int = (life01 * 255.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(104, 220, 254, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 126, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(254, 122, 122, alpha)
      } else {
        @raylib.Color::new(226, 152, 255, alpha)
      }
      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    let player_col = if player.inv_t > 0.0 {
      @raylib.Color::new(244, 244, 244, 230)
    } else {
      @raylib.Color::new(92, 188, 250, 246)
    }

    @raylib.draw_rectangle(
      (player.x - 16.0).to_int(),
      (player.y - 12.0).to_int(),
      32,
      24,
      player_col,
    )
    @raylib.draw_circle(
      player.x.to_int(),
      (player.y - 14.0).to_int(),
      9.0,
      @raylib.Color::new(212, 240, 255, 250),
    )
    @raylib.draw_line(
      player.x.to_int(),
      (player.y - 24.0).to_int(),
      player.x.to_int(),
      (player.y - 44.0).to_int(),
      @raylib.Color::new(164, 224, 255, 180),
    )

    if player.shield_on {
      @raylib.draw_circle_lines(
        player.x.to_int(),
        player.y.to_int(),
        24.0,
        @raylib.Color::new(130, 214, 246, 210),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 76, @raylib.Color::new(8, 10, 18, 228))

    @raylib.draw_text(
      "Chrono Rail Shooter",
      16,
      10,
      28,
      @raylib.Color::new(208, 234, 250, 248),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      16,
      44,
      20,
      @raylib.Color::new(246, 226, 170, 248),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      194,
      44,
      20,
      @raylib.Color::new(182, 242, 200, 248),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      350,
      44,
      20,
      @raylib.Color::new(166, 206, 250, 248),
    )

    @raylib.draw_text(
      "Distance \{player.distance.to_int()} / \{distance_goal.to_int()}",
      524,
      44,
      20,
      @raylib.Color::new(222, 232, 246, 248),
    )

    @raylib.draw_text(
      "FPS \{@raylib.get_fps()}",
      sw - 114,
      12,
      20,
      @raylib.Color::new(170, 210, 236, 220),
    )

    let hp_fill : Int = (clampf(player.hp / 100.0, 0.0, 1.0) * 236.0).to_int()
    let en_fill : Int = (clampf(player.energy / 100.0, 0.0, 1.0) * 236.0).to_int()
    let heat_fill : Int = (clampf(player.heat / 100.0, 0.0, 1.0) * 236.0).to_int()

    @raylib.draw_rectangle(16, 84, 236, 12, @raylib.Color::new(24, 26, 38, 255))
    @raylib.draw_rectangle(
      16,
      84,
      hp_fill,
      12,
      @raylib.Color::new(224, 98, 116, 255),
    )
    @raylib.draw_text("HP", 16, 100, 16, @raylib.Color::new(236, 206, 216, 255))

    @raylib.draw_rectangle(
      16,
      126,
      236,
      12,
      @raylib.Color::new(24, 26, 38, 255),
    )
    @raylib.draw_rectangle(
      16,
      126,
      en_fill,
      12,
      @raylib.Color::new(88, 188, 236, 255),
    )
    @raylib.draw_text("EN", 16, 142, 16, @raylib.Color::new(200, 224, 246, 255))

    @raylib.draw_rectangle(
      16,
      168,
      236,
      12,
      @raylib.Color::new(24, 26, 38, 255),
    )
    @raylib.draw_rectangle(
      16,
      168,
      heat_fill,
      12,
      @raylib.Color::new(238, 170, 94, 255),
    )
    @raylib.draw_text(
      "HEAT",
      16,
      184,
      16,
      @raylib.Color::new(240, 222, 194, 255),
    )

    @raylib.draw_text(
      "Rocket \{(player.rocket_cd * 10.0).to_int()}",
      290,
      96,
      18,
      @raylib.Color::new(228, 234, 248, 240),
    )
    @raylib.draw_text(
      "Dash \{(player.dash_cd * 10.0).to_int()}",
      290,
      124,
      18,
      @raylib.Color::new(228, 234, 248, 240),
    )
    @raylib.draw_text(
      "EMP \{(player.emp_cd * 10.0).to_int()}",
      290,
      152,
      18,
      @raylib.Color::new(228, 234, 248, 240),
    )

    if msg_t > 0.0 {
      @raylib.draw_rectangle(
        420,
        sh - 62,
        440,
        34,
        @raylib.Color::new(14, 18, 28, 208),
      )
      @raylib.draw_text(
        msg,
        438,
        sh - 54,
        20,
        @raylib.Color::new(226, 244, 252, 246),
      )
    }

    draw_touch_ui(state)

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 162))
      @raylib.draw_rectangle(
        220,
        146,
        840,
        420,
        @raylib.Color::new(14, 18, 32, 236),
      )
      @raylib.draw_rectangle_lines(
        220,
        146,
        840,
        420,
        @raylib.Color::new(100, 152, 200, 206),
      )

      @raylib.draw_text(
        "CHRONO RAIL SHOOTER 2026",
        300,
        198,
        48,
        @raylib.Color::new(190, 236, 252, 255),
      )
      @raylib.draw_text(
        "A timeline rogue squad is attacking your train",
        332,
        274,
        26,
        @raylib.Color::new(216, 226, 244, 248),
      )
      @raylib.draw_text(
        "Move: WASD / Arrows   Fire: J or Space",
        342,
        324,
        24,
        @raylib.Color::new(198, 220, 240, 246),
      )
      @raylib.draw_text(
        "Dash: K   Rocket: E   EMP: L   Shield: RightShift",
        292,
        360,
        24,
        @raylib.Color::new(198, 220, 240, 246),
      )
      @raylib.draw_text(
        "Touch: left panel to move, right panel for skills",
        332,
        396,
        24,
        @raylib.Color::new(198, 220, 240, 246),
      )
      @raylib.draw_text(
        "Press Enter or tap to start",
        456,
        462,
        30,
        @raylib.Color::new(244, 236, 170, 254),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 174))
      @raylib.draw_rectangle(
        300,
        200,
        680,
        320,
        @raylib.Color::new(16, 28, 34, 242),
      )
      @raylib.draw_rectangle_lines(
        300,
        200,
        680,
        320,
        @raylib.Color::new(108, 214, 184, 220),
      )

      @raylib.draw_text(
        "MISSION CLEAR",
        440,
        250,
        56,
        @raylib.Color::new(168, 246, 206, 254),
      )
      @raylib.draw_text(
        "Final Score: \{player.score}",
        476,
        334,
        34,
        @raylib.Color::new(232, 246, 252, 252),
      )
      @raylib.draw_text(
        "Best Combo: \{player.best_combo}",
        480,
        374,
        30,
        @raylib.Color::new(210, 232, 250, 244),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to run again",
        414,
        438,
        30,
        @raylib.Color::new(244, 232, 174, 252),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 182))
      @raylib.draw_rectangle(
        300,
        200,
        680,
        320,
        @raylib.Color::new(28, 14, 18, 244),
      )
      @raylib.draw_rectangle_lines(
        300,
        200,
        680,
        320,
        @raylib.Color::new(198, 94, 110, 220),
      )

      @raylib.draw_text(
        "MISSION FAILED",
        440,
        250,
        56,
        @raylib.Color::new(248, 166, 176, 252),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        522,
        334,
        34,
        @raylib.Color::new(232, 246, 252, 252),
      )
      @raylib.draw_text(
        "Distance: \{player.distance.to_int()}m",
        480,
        374,
        30,
        @raylib.Color::new(210, 232, 250, 244),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to retry",
        432,
        438,
        30,
        @raylib.Color::new(244, 232, 174, 252),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
