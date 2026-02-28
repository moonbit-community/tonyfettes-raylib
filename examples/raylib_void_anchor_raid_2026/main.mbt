///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_l : Float = 34.0

///|
let world_r : Float = Float::from_int(sw) - 34.0

///|
let world_t : Float = 90.0

///|
let world_b : Float = Float::from_int(sh) - 34.0

///|
let max_anchors : Int = 12

///|
let max_enemies : Int = 260

///|
let max_bullets : Int = 1200

///|
let max_orbs : Int = 300

///|
let max_walls : Int = 80

///|
let max_particles : Int = 1800

///|
let anchor_hold_goal : Float = 10.0

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
  mut pulse_cd : Float
  mut score : Int
  mut combo : Int
  mut best_combo : Int
}

///|
struct Anchor {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut progress : Float
  mut owner : Int
  mut fire_cd : Float
  mut t : Float
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
  mut stun_t : Float
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
struct Orb {
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
struct Wall {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
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
    26.0
  }
}

///|
fn enemy_hp(kind : Int, wave : Int) -> Float {
  if kind == 0 {
    26.0 + Float::from_int(wave) * 2.8
  } else if kind == 1 {
    44.0 + Float::from_int(wave) * 4.2
  } else {
    108.0 + Float::from_int(wave) * 8.6
  }
}

///|
fn circle_rect_hit(
  cx : Float,
  cy : Float,
  r : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  let nx : Float = clampf(cx, rx, rx + rw)
  let ny : Float = clampf(cy, ry, ry + rh)
  let dx : Float = cx - nx
  let dy : Float = cy - ny
  dx * dx + dy * dy <= r * r
}

///|
fn any_wall_hit(x : Float, y : Float, r : Float, walls : Array[Wall]) -> Bool {
  for wall in walls {
    if not(wall.active) {
      continue
    }
    if circle_rect_hit(x, y, r, wall.x, wall.y, wall.w, wall.h) {
      return true
    }
  }
  false
}

///|
fn move_with_walls(
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  r : Float,
  dt : Float,
  walls : Array[Wall],
) -> (Float, Float, Float, Float) {
  let mut nx : Float = clampf(x + vx * dt, world_l + r, world_r - r)
  let mut ny : Float = y
  let mut nvx : Float = vx
  let mut nvy : Float = vy

  if any_wall_hit(nx, ny, r, walls) {
    nx = x
    nvx = -nvx * 0.16
  }

  ny = clampf(y + nvy * dt, world_t + r, world_b - r)
  if any_wall_hit(nx, ny, r, walls) {
    ny = y
    nvy = -nvy * 0.16
  }

  (nx, ny, nvx, nvy)
}

///|
fn clear_anchors(anchors : Array[Anchor]) -> Unit {
  for anchor in anchors {
    anchor.active = false
    anchor.x = 0.0
    anchor.y = 0.0
    anchor.r = 0.0
    anchor.progress = 0.0
    anchor.owner = 0
    anchor.fire_cd = 0.0
    anchor.t = 0.0
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
    enemy.stun_t = 0.0
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
fn clear_orbs(orbs : Array[Orb]) -> Unit {
  for orb in orbs {
    orb.active = false
    orb.kind = 0
    orb.x = 0.0
    orb.y = 0.0
    orb.vx = 0.0
    orb.vy = 0.0
    orb.value = 0
    orb.life = 0.0
    orb.t = 0.0
  }
}

///|
fn clear_walls(walls : Array[Wall]) -> Unit {
  for wall in walls {
    wall.active = false
    wall.x = 0.0
    wall.y = 0.0
    wall.w = 0.0
    wall.h = 0.0
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
fn add_anchor(anchors : Array[Anchor], x : Float, y : Float, r : Float) -> Bool {
  for anchor in anchors {
    if not(anchor.active) {
      anchor.active = true
      anchor.x = x
      anchor.y = y
      anchor.r = r
      anchor.progress = 0.0
      anchor.owner = 0
      anchor.fire_cd = randf(0.3, 0.8)
      anchor.t = randf(0.0, 20.0)
      return true
    }
  }
  false
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
      enemy.vx = randf(-30.0, 30.0)
      enemy.vy = randf(-30.0, 30.0)
      enemy.hp = enemy_hp(kind, wave)
      enemy.fire_cd = randf(0.8, 1.8)
      enemy.stun_t = 0.0
      enemy.t = randf(0.0, 20.0)
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
fn add_orb(
  orbs : Array[Orb],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  value : Int,
  life : Float,
) -> Bool {
  for orb in orbs {
    if not(orb.active) {
      orb.active = true
      orb.kind = kind
      orb.x = x
      orb.y = y
      orb.vx = vx
      orb.vy = vy
      orb.value = value
      orb.life = life
      orb.t = randf(0.0, 10.0)
      return true
    }
  }
  false
}

///|
fn add_wall(
  walls : Array[Wall],
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  for wall in walls {
    if not(wall.active) {
      wall.active = true
      wall.x = x
      wall.y = y
      wall.w = w
      wall.h = h
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
    let spd : Float = randf(70.0, 340.0) * scale
    ignore(
      add_particle(
        parts,
        kind,
        x,
        y,
        @math.cosf(ang) * spd,
        @math.sinf(ang) * spd,
        randf(2.0, 5.2) * scale,
        randf(0.16, 0.84),
      ),
    )
  }
}

///|
fn count_active_enemies(enemies : Array[Enemy]) -> Int {
  let mut n : Int = 0
  for enemy in enemies {
    if enemy.active {
      n = n + 1
    }
  }
  n
}

///|
fn count_owned_anchors(anchors : Array[Anchor], owner : Int) -> Int {
  let mut n : Int = 0
  for anchor in anchors {
    if anchor.active && anchor.owner == owner {
      n = n + 1
    }
  }
  n
}

///|
fn count_total_anchors(anchors : Array[Anchor]) -> Int {
  let mut n : Int = 0
  for anchor in anchors {
    if anchor.active {
      n = n + 1
    }
  }
  n
}

///|
fn setup_map(walls : Array[Wall], anchors : Array[Anchor]) -> Unit {
  clear_walls(walls)
  clear_anchors(anchors)

  // perimeter
  ignore(add_wall(walls, world_l, world_t, world_r - world_l, 14.0))
  ignore(add_wall(walls, world_l, world_b - 14.0, world_r - world_l, 14.0))
  ignore(add_wall(walls, world_l, world_t, 14.0, world_b - world_t))
  ignore(add_wall(walls, world_r - 14.0, world_t, 14.0, world_b - world_t))

  // cross + blocks
  ignore(add_wall(walls, 620.0, 180.0, 40.0, 130.0))
  ignore(add_wall(walls, 620.0, 460.0, 40.0, 130.0))
  ignore(add_wall(walls, 420.0, 350.0, 170.0, 40.0))
  ignore(add_wall(walls, 690.0, 350.0, 170.0, 40.0))

  ignore(add_wall(walls, 240.0, 180.0, 160.0, 24.0))
  ignore(add_wall(walls, 880.0, 180.0, 160.0, 24.0))
  ignore(add_wall(walls, 240.0, 560.0, 160.0, 24.0))
  ignore(add_wall(walls, 880.0, 560.0, 160.0, 24.0))

  // anchors: center + four corners
  ignore(add_anchor(anchors, 640.0, 380.0, 56.0))
  ignore(add_anchor(anchors, 170.0, 170.0, 52.0))
  ignore(add_anchor(anchors, 1110.0, 170.0, 52.0))
  ignore(add_anchor(anchors, 170.0, 590.0, 52.0))
  ignore(add_anchor(anchors, 1110.0, 590.0, 52.0))
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
      "CAP",
      btn_x + 196,
      btn_y + 46,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "DASH",
      btn_x + 40,
      btn_y + 146,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "PULSE",
      btn_x + 178,
      btn_y + 146,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] void anchor raid 2026")
  @raylib.set_target_fps(60)

  let walls : Array[Wall] = Array::makei(max_walls, fn(_i) {
    { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0 }
  })

  let anchors : Array[Anchor] = Array::makei(max_anchors, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      r: 0.0,
      progress: 0.0,
      owner: 0,
      fire_cd: 0.0,
      t: 0.0,
    }
  })

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
      stun_t: 0.0,
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

  let orbs : Array[Orb] = Array::makei(max_orbs, fn(_i) {
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

  let player : Player = {
    x: 130.0,
    y: world_b - 80.0,
    vx: 0.0,
    vy: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    hp: 100.0,
    energy: 100.0,
    heat: 0.0,
    inv_t: 0.0,
    fire_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    pulse_cd: 0.0,
    score: 0,
    combo: 0,
    best_combo: 0,
  }

  let mut state : Int = 0

  let mut timer : Float = 420.0
  let mut hold_t : Float = 0.0

  let mut wave : Int = 1
  let mut wave_active : Bool = false
  let mut wave_prep_t : Float = 1.8
  let mut to_spawn : Int = 0
  let mut spawn_cd : Float = 0.0

  let mut msg : String = "Capture all anchors"
  let mut msg_t : Float = 3.0

  let mut stars_t : Float = 0.0

  let reset_run = fn() {
    setup_map(walls, anchors)

    clear_enemies(enemies)
    clear_bullets(bullets)
    clear_orbs(orbs)
    clear_particles(particles)

    player.x = 130.0
    player.y = world_b - 80.0
    player.vx = 0.0
    player.vy = 0.0
    player.aim_x = 1.0
    player.aim_y = 0.0
    player.hp = 100.0
    player.energy = 100.0
    player.heat = 0.0
    player.inv_t = 0.0
    player.fire_cd = 0.0
    player.dash_cd = 0.0
    player.dash_t = 0.0
    player.pulse_cd = 0.0
    player.score = 0
    player.combo = 0
    player.best_combo = 0

    timer = 420.0
    hold_t = 0.0

    wave = 1
    wave_active = false
    wave_prep_t = 1.8
    to_spawn = 0
    spawn_cd = 0.0

    msg = "Capture and hold anchors"
    msg_t = 2.2

    ignore(add_enemy(enemies, 0, world_r - 90.0, world_t + 80.0, wave))
    ignore(add_enemy(enemies, 0, world_r - 90.0, world_b - 80.0, wave))
  }

  let on_player_hit = fn(dmg : Float, reason : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut dealt : Float = dmg
      if player.dash_t > 0.0 {
        dealt = dealt * 0.56
      }
      player.hp = player.hp - dealt
      if player.hp < 0.0 {
        player.hp = 0.0
      }
      player.inv_t = 0.42
      player.combo = 0
      msg = reason
      msg_t = 0.72
      burst(particles, player.x, player.y, 18, 0.2, 2)
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

    stars_t = stars_t + dt * 24.0
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
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

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

      player.pulse_cd = player.pulse_cd - dt
      if player.pulse_cd < 0.0 {
        player.pulse_cd = 0.0
      }

      player.energy = player.energy + dt * 10.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      player.heat = player.heat - dt * 36.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      // wave logic
      if not(wave_active) {
        wave_prep_t = wave_prep_t - dt
        if wave_prep_t <= 0.0 {
          wave_active = true
          to_spawn = 8 + wave * 3
          spawn_cd = 0.2
          msg = "Wave \{wave} incoming"
          msg_t = 1.3
        }
      } else {
        spawn_cd = spawn_cd - dt
        if to_spawn > 0 && spawn_cd <= 0.0 {
          let edge : Int = @raylib.get_random_value(0, 3)
          let mut ex : Float = 0.0
          let mut ey : Float = 0.0
          if edge == 0 {
            ex = randf(world_l + 20.0, world_r - 20.0)
            ey = world_t + 20.0
          } else if edge == 1 {
            ex = world_r - 20.0
            ey = randf(world_t + 20.0, world_b - 20.0)
          } else if edge == 2 {
            ex = randf(world_l + 20.0, world_r - 20.0)
            ey = world_b - 20.0
          } else {
            ex = world_l + 20.0
            ey = randf(world_t + 20.0, world_b - 20.0)
          }

          let roll : Int = @raylib.get_random_value(0, 99)
          let mut kind : Int = 0
          if wave >= 3 && roll >= 45 {
            kind = 1
          }
          if wave >= 7 && roll >= 82 {
            kind = 2
          }

          ignore(add_enemy(enemies, kind, ex, ey, wave))
          to_spawn = to_spawn - 1
          let next_cd : Float = 0.68 -
            Float::from_int(wave) * 0.026 +
            randf(-0.08, 0.16)
          spawn_cd = clampf(next_cd, 0.22, 0.8)
        }

        if to_spawn == 0 && count_active_enemies(enemies) == 0 {
          wave_active = false
          wave = wave + 1
          wave_prep_t = 2.8
          player.energy = clampf(player.energy + 14.0, 0.0, 100.0)
          msg = "Wave cleared"
          msg_t = 1.1
        }
      }

      // input
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
      let mut capture_hold : Bool = @raylib.is_key_down(@raylib.KeyH)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyRightShift)
      let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

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
        if inside_rect(mouse.x, mouse.y, btn_x + 158, btn_y + 12, 138, 90) {
          capture_hold = true
        }
      }

      if touch_press {
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 112, 138, 90) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 158, btn_y + 112, 138, 90) {
          pulse_press = true
        }
      }

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

      let mut aim_x : Float = player.aim_x
      let mut aim_y : Float = player.aim_y
      let mouse_in : Bool = mouse.x >= world_l &&
        mouse.x <= world_r &&
        mouse.y >= world_t &&
        mouse.y <= world_b
      if mouse_in {
        let dx : Float = mouse.x - player.x
        let dy : Float = mouse.y - player.y
        let l2 : Float = dx * dx + dy * dy
        if l2 > 1.0 {
          let inv : Float = 1.0 / l2.sqrt()
          aim_x = dx * inv
          aim_y = dy * inv
        }
      } else if inp_x * inp_x + inp_y * inp_y > 0.01 {
        let inv : Float = 1.0 / (inp_x * inp_x + inp_y * inp_y).sqrt()
        aim_x = inp_x * inv
        aim_y = inp_y * inv
      }

      player.aim_x = aim_x
      player.aim_y = aim_y

      let accel : Float = if player.dash_t > 0.0 { 1650.0 } else { 980.0 }
      player.vx = player.vx + inp_x * accel * dt
      player.vy = player.vy + inp_y * accel * dt

      let drag : Float = if player.dash_t > 0.0 { 2.1 } else { 5.3 }
      player.vx = player.vx * (1.0 - drag * dt)
      player.vy = player.vy * (1.0 - drag * dt)

      let max_spd : Float = if player.dash_t > 0.0 { 470.0 } else { 310.0 }
      let sp2 : Float = player.vx * player.vx + player.vy * player.vy
      if sp2 > max_spd * max_spd {
        let invs : Float = max_spd / sp2.sqrt()
        player.vx = player.vx * invs
        player.vy = player.vy * invs
      }

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 18.0 {
        player.dash_cd = 1.14
        player.dash_t = 0.22
        player.energy = player.energy - 18.0

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

        burst(particles, player.x, player.y, 14, 0.16, 0)
      }

      if pulse_press && player.pulse_cd <= 0.0 && player.energy >= 36.0 {
        player.pulse_cd = 5.8
        player.energy = player.energy - 36.0
        msg = "Void pulse"
        msg_t = 0.58

        burst(particles, player.x, player.y, 76, 0.33, 3)

        for enemy in enemies {
          if not(enemy.active) {
            continue
          }
          let d2 : Float = dist2(player.x, player.y, enemy.x, enemy.y)
          if d2 <= 250.0 * 250.0 {
            enemy.hp = enemy.hp - 24.0
            enemy.stun_t = clampf(enemy.stun_t + 1.6, 0.0, 3.0)
            enemy.vx = enemy.vx * 0.2
            enemy.vy = enemy.vy * 0.2
          }
        }

        for bullet in bullets {
          if bullet.active &&
            bullet.team == 2 &&
            dist2(player.x, player.y, bullet.x, bullet.y) <= 280.0 * 280.0 {
            bullet.active = false
          }
        }

        for anchor in anchors {
          if not(anchor.active) {
            continue
          }
          if dist2(player.x, player.y, anchor.x, anchor.y) <= 220.0 * 220.0 {
            anchor.progress = clampf(anchor.progress + 22.0, -100.0, 100.0)
          }
        }
      }

      let (px, py, pvx, pvy) = move_with_walls(
        player.x,
        player.y,
        player.vx,
        player.vy,
        16.0,
        dt,
        walls,
      )
      player.x = px
      player.y = py
      player.vx = pvx
      player.vy = pvy

      // shooting
      if fire_hold && player.fire_cd <= 0.0 && player.heat <= 94.0 {
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

        if wave >= 5 {
          let sx : Float = -player.aim_y
          let sy : Float = player.aim_x
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + player.aim_x * 20.0 + sx * 8.0,
              player.y + player.aim_y * 20.0 + sy * 8.0,
              (player.aim_x + sx * 0.1) * 680.0,
              (player.aim_y + sy * 0.1) * 680.0,
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
              (player.aim_x - sx * 0.1) * 680.0,
              (player.aim_y - sy * 0.1) * 680.0,
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
          0.12,
          1,
        )
      }

      // anchors capture and fire
      for i in 0..<anchors.length() {
        if not(anchors[i].active) {
          continue
        }

        anchors[i].t = anchors[i].t + dt
        anchors[i].fire_cd = anchors[i].fire_cd - dt

        let in_player : Bool = dist2(
            player.x,
            player.y,
            anchors[i].x,
            anchors[i].y,
          ) <=
          (anchors[i].r + 18.0) * (anchors[i].r + 18.0)

        let mut enemy_near : Int = 0
        for enemy in enemies {
          if not(enemy.active) {
            continue
          }
          if dist2(enemy.x, enemy.y, anchors[i].x, anchors[i].y) <=
            (anchors[i].r + enemy_radius(enemy.kind)) *
            (anchors[i].r + enemy_radius(enemy.kind)) {
            enemy_near = enemy_near + 1
          }
        }

        if in_player {
          let mut cap_speed : Float = 21.0
          if capture_hold && player.energy > 0.0 {
            cap_speed = 34.0
            player.energy = player.energy - dt * 14.0
            if player.energy < 0.0 {
              player.energy = 0.0
            }
          }
          anchors[i].progress = anchors[i].progress + cap_speed * dt
        }

        if enemy_near > 0 {
          anchors[i].progress = anchors[i].progress -
            (8.0 + Float::from_int(enemy_near) * 4.0) * dt
        }

        anchors[i].progress = clampf(anchors[i].progress, -100.0, 100.0)

        if anchors[i].progress >= 55.0 {
          anchors[i].owner = 1
        } else if anchors[i].progress <= -55.0 {
          anchors[i].owner = -1
        } else {
          anchors[i].owner = 0
        }

        // anchor weapon
        if anchors[i].fire_cd <= 0.0 {
          if anchors[i].owner == 1 {
            let mut target_i : Int = -1
            let mut best_d2 : Float = 99999999.0
            for e in 0..<enemies.length() {
              if not(enemies[e].active) {
                continue
              }
              let d2 : Float = dist2(
                anchors[i].x,
                anchors[i].y,
                enemies[e].x,
                enemies[e].y,
              )
              if d2 <= 320.0 * 320.0 && d2 < best_d2 {
                best_d2 = d2
                target_i = e
              }
            }
            if target_i >= 0 {
              let tx : Float = enemies[target_i].x - anchors[i].x
              let ty : Float = enemies[target_i].y - anchors[i].y
              let mut inv : Float = 0.0
              let l2 : Float = tx * tx + ty * ty
              if l2 > 0.01 {
                inv = 1.0 / l2.sqrt()
              }
              ignore(
                add_bullet(
                  bullets,
                  1,
                  1,
                  anchors[i].x,
                  anchors[i].y,
                  tx * inv * 520.0,
                  ty * inv * 520.0,
                  8.0,
                  3.0,
                  1.6,
                ),
              )
              anchors[i].fire_cd = 0.48
            }
          } else if anchors[i].owner == -1 {
            if dist2(anchors[i].x, anchors[i].y, player.x, player.y) <=
              340.0 * 340.0 {
              let tx : Float = player.x - anchors[i].x
              let ty : Float = player.y - anchors[i].y
              let mut inv : Float = 0.0
              let l2 : Float = tx * tx + ty * ty
              if l2 > 0.01 {
                inv = 1.0 / l2.sqrt()
              }
              ignore(
                add_bullet(
                  bullets,
                  2,
                  1,
                  anchors[i].x,
                  anchors[i].y,
                  tx * inv * 360.0,
                  ty * inv * 360.0,
                  9.0,
                  5.0,
                  2.4,
                ),
              )
              anchors[i].fire_cd = 1.1
            }
          }
        }
      }

      // hold objective
      let owned_n : Int = count_owned_anchors(anchors, 1)
      let total_n : Int = count_total_anchors(anchors)
      if owned_n == total_n {
        hold_t = hold_t + dt
      } else {
        hold_t = hold_t - dt * 0.6
        if hold_t < 0.0 {
          hold_t = 0.0
        }
      }

      if hold_t >= anchor_hold_goal {
        state = 2
        msg = "Anchors stabilized"
        msg_t = 2.2
      }

      // enemies update
      for enemy in enemies {
        if not(enemy.active) {
          continue
        }

        enemy.t = enemy.t + dt
        enemy.fire_cd = enemy.fire_cd - dt
        enemy.stun_t = enemy.stun_t - dt
        if enemy.stun_t < 0.0 {
          enemy.stun_t = 0.0
        }

        // choose target
        let mut target_x : Float = player.x
        let mut target_y : Float = player.y

        let mut nearest_anchor : Int = -1
        let mut best_anchor_d2 : Float = 99999999.0
        for a in 0..<anchors.length() {
          if not(anchors[a].active) {
            continue
          }
          if anchors[a].owner == -1 {
            continue
          }
          let d2 : Float = dist2(enemy.x, enemy.y, anchors[a].x, anchors[a].y)
          if d2 < best_anchor_d2 {
            best_anchor_d2 = d2
            nearest_anchor = a
          }
        }

        let player_d2 : Float = dist2(enemy.x, enemy.y, player.x, player.y)
        if player_d2 <= 240.0 * 240.0 {
          target_x = player.x
          target_y = player.y
        } else if nearest_anchor >= 0 {
          target_x = anchors[nearest_anchor].x
          target_y = anchors[nearest_anchor].y
        }

        if enemy.stun_t > 0.0 {
          enemy.vx = enemy.vx * (1.0 - dt * 7.0)
          enemy.vy = enemy.vy * (1.0 - dt * 7.0)
        } else {
          let tx : Float = target_x - enemy.x
          let ty : Float = target_y - enemy.y
          let mut inv : Float = 0.0
          let l2 : Float = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }

          if enemy.kind == 0 {
            let acc : Float = 170.0 + Float::from_int(wave) * 6.0
            enemy.vx = enemy.vx + tx * inv * acc * dt
            enemy.vy = enemy.vy + ty * inv * acc * dt
          } else if enemy.kind == 1 {
            let orbit : Float = 210.0
            let mut d : Float = 0.0
            if l2 > 0.01 {
              d = l2.sqrt()
            }
            let err : Float = d - orbit
            enemy.vx = enemy.vx +
              tx * inv * err * 0.72 * dt +
              @math.sinf(enemy.t * 2.2) * 20.0 * dt
            enemy.vy = enemy.vy +
              ty * inv * err * 0.72 * dt +
              @math.cosf(enemy.t * 2.0) * 20.0 * dt
          } else {
            let acc : Float = 112.0 + Float::from_int(wave) * 4.0
            enemy.vx = enemy.vx + tx * inv * acc * dt
            enemy.vy = enemy.vy + ty * inv * acc * dt
          }

          if enemy.fire_cd <= 0.0 && player_d2 <= 360.0 * 360.0 {
            let mut iv : Float = 0.0
            if player_d2 > 0.01 {
              iv = 1.0 / player_d2.sqrt()
            }
            if enemy.kind == 1 {
              enemy.fire_cd = randf(0.8, 1.4)
              ignore(
                add_bullet(
                  bullets,
                  2,
                  0,
                  enemy.x,
                  enemy.y,
                  (player.x - enemy.x) * iv * 300.0,
                  (player.y - enemy.y) * iv * 300.0,
                  8.0,
                  5.0,
                  2.8,
                ),
              )
            } else if enemy.kind == 2 {
              enemy.fire_cd = randf(1.4, 2.2)
              let sx : Float = -(player.y - enemy.y) * iv
              let sy : Float = (player.x - enemy.x) * iv
              ignore(
                add_bullet(
                  bullets,
                  2,
                  1,
                  enemy.x,
                  enemy.y,
                  (player.x - enemy.x) * iv * 250.0,
                  (player.y - enemy.y) * iv * 250.0,
                  12.0,
                  6.0,
                  3.2,
                ),
              )
              ignore(
                add_bullet(
                  bullets,
                  2,
                  0,
                  enemy.x,
                  enemy.y,
                  (player.x - enemy.x) * iv * 240.0 + sx * 68.0,
                  (player.y - enemy.y) * iv * 240.0 + sy * 68.0,
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
                  (player.x - enemy.x) * iv * 240.0 - sx * 68.0,
                  (player.y - enemy.y) * iv * 240.0 - sy * 68.0,
                  7.0,
                  4.0,
                  2.8,
                ),
              )
            }
          }
        }

        let max_spd : Float = if enemy.kind == 2 {
          170.0
        } else {
          230.0 + Float::from_int(wave) * 3.0
        }
        let sp2 : Float = enemy.vx * enemy.vx + enemy.vy * enemy.vy
        if sp2 > max_spd * max_spd {
          let invs : Float = max_spd / sp2.sqrt()
          enemy.vx = enemy.vx * invs
          enemy.vy = enemy.vy * invs
        }

        let (nx, ny, nvx, nvy) = move_with_walls(
          enemy.x,
          enemy.y,
          enemy.vx,
          enemy.vy,
          enemy_radius(enemy.kind),
          dt,
          walls,
        )
        enemy.x = nx
        enemy.y = ny
        enemy.vx = nvx
        enemy.vy = nvy

        if dist2(enemy.x, enemy.y, player.x, player.y) <=
          (enemy_radius(enemy.kind) + 16.0) * (enemy_radius(enemy.kind) + 16.0) {
          on_player_hit(7.0 + Float::from_int(enemy.kind) * 2.0, "Enemy impact")
          enemy.vx = -enemy.vx
          enemy.vy = -enemy.vy
        }

        if enemy.hp <= 0.0 {
          let reward : Int = 52 + enemy.kind * 28 + player.combo * 2
          player.score = player.score + reward
          player.combo = player.combo + 1
          if player.combo > player.best_combo {
            player.best_combo = player.combo
          }

          let drops : Int = 1 + @raylib.get_random_value(0, 2)
          for d in 0..<drops {
            let kind : Int = @raylib.get_random_value(0, 1)
            ignore(
              add_orb(
                orbs,
                kind,
                enemy.x,
                enemy.y,
                randf(-100.0, 100.0),
                randf(-100.0, 100.0),
                1 + @raylib.get_random_value(0, 2),
                randf(22.0, 48.0),
              ),
            )
          }

          burst(particles, enemy.x, enemy.y, 20, 0.2, 0)
          enemy.active = false
        }
      }

      // orbs
      for orb in orbs {
        if not(orb.active) {
          continue
        }

        orb.life = orb.life - dt
        if orb.life <= 0.0 {
          orb.active = false
          continue
        }

        orb.t = orb.t + dt
        orb.x = orb.x + orb.vx * dt
        orb.y = orb.y + orb.vy * dt
        orb.vx = orb.vx * (1.0 - dt * 1.6)
        orb.vy = orb.vy * (1.0 - dt * 1.6)

        orb.x = clampf(orb.x, world_l + 6.0, world_r - 6.0)
        orb.y = clampf(orb.y, world_t + 6.0, world_b - 6.0)

        if dist2(player.x, player.y, orb.x, orb.y) <= 28.0 * 28.0 {
          if orb.kind == 0 {
            player.score = player.score + orb.value * 8
          } else {
            player.energy = clampf(
              player.energy + Float::from_int(orb.value) * 8.0,
              0.0,
              100.0,
            )
          }
          orb.active = false
          burst(particles, player.x, player.y, 8, 0.12, 0)
        }
      }

      // bullets
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

        if bullet.x < world_l - 50.0 ||
          bullet.x > world_r + 50.0 ||
          bullet.y < world_t - 50.0 ||
          bullet.y > world_b + 50.0 {
          bullet.active = false
          continue
        }

        // walls
        let mut blocked : Bool = false
        for w in 0..<walls.length() {
          if not(walls[w].active) {
            continue
          }
          if circle_rect_hit(
              bullet.x,
              bullet.y,
              bullet.r,
              walls[w].x,
              walls[w].y,
              walls[w].w,
              walls[w].h,
            ) {
            bullet.active = false
            blocked = true
            break
          }
        }
        if blocked {
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
              bullet.active = false
              consumed = true
              burst(particles, bullet.x, bullet.y, 4, 0.1, 1)
            }
          }

          if bullet.active {
            for anchor in anchors {
              if not(anchor.active) || anchor.owner != -1 {
                continue
              }
              if dist2(bullet.x, bullet.y, anchor.x, anchor.y) <=
                (bullet.r + anchor.r) * (bullet.r + anchor.r) {
                anchor.progress = clampf(
                  anchor.progress + bullet.dmg * 1.1,
                  -100.0,
                  100.0,
                )
                bullet.active = false
                break
              }
            }
          }
        } else {
          if dist2(bullet.x, bullet.y, player.x, player.y) <=
            (bullet.r + 16.0) * (bullet.r + 16.0) {
            on_player_hit(bullet.dmg, "Enemy projectile")
            bullet.active = false
            continue
          }

          for anchor in anchors {
            if not(anchor.active) || anchor.owner != 1 {
              continue
            }
            if dist2(bullet.x, bullet.y, anchor.x, anchor.y) <=
              (bullet.r + anchor.r) * (bullet.r + anchor.r) {
              anchor.progress = clampf(
                anchor.progress - bullet.dmg * 1.1,
                -100.0,
                100.0,
              )
              bullet.active = false
              break
            }
          }
        }
      }

      // particles
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

      // loss conditions
      if timer <= 0.0 {
        state = 3
        msg = "Time expired"
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

    // render
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

    for gy in 0..<15 {
      let y : Int = 90 + gy * 44
      @raylib.draw_line(0, y, sw, y, @raylib.Color::new(22, 30, 46, 122))
    }
    for gx in 0..<26 {
      let x : Int = gx * 50
      @raylib.draw_line(x, 90, x, sh, @raylib.Color::new(22, 30, 46, 102))
    }

    for i in 0..<170 {
      let fi : Float = Float::from_int(i)
      let sx : Int = ((
        fi * 79.0 + stars_t * (0.2 + Float::from_int(i % 7) * 0.08)
      ) %
      Float::from_int(sw)).to_int()
      let sy : Int = ((
        fi * 137.0 + stars_t * (0.16 + Float::from_int(i % 5) * 0.09)
      ) %
      Float::from_int(sh)).to_int()
      let br : Int = 70 + i % 10 * 12
      @raylib.draw_circle(
        sx,
        sy,
        if i % 4 == 0 {
          1.8
        } else {
          1.1
        },
        @raylib.Color::new(br, br, br + 28, 166),
      )
    }

    @raylib.draw_rectangle(
      world_l.to_int(),
      world_t.to_int(),
      (world_r - world_l).to_int(),
      (world_b - world_t).to_int(),
      @raylib.Color::new(10, 18, 30, 150),
    )
    @raylib.draw_rectangle_lines(
      world_l.to_int(),
      world_t.to_int(),
      (world_r - world_l).to_int(),
      (world_b - world_t).to_int(),
      @raylib.Color::new(72, 114, 156, 206),
    )

    // walls
    for wall in walls {
      if not(wall.active) {
        continue
      }
      @raylib.draw_rectangle(
        wall.x.to_int(),
        wall.y.to_int(),
        wall.w.to_int(),
        wall.h.to_int(),
        @raylib.Color::new(66, 76, 98, 236),
      )
      @raylib.draw_rectangle_lines(
        wall.x.to_int(),
        wall.y.to_int(),
        wall.w.to_int(),
        wall.h.to_int(),
        @raylib.Color::new(168, 188, 216, 124),
      )
    }

    // anchors
    for anchor in anchors {
      if not(anchor.active) {
        continue
      }

      let col = if anchor.owner == 1 {
        @raylib.Color::new(102, 224, 168, 236)
      } else if anchor.owner == -1 {
        @raylib.Color::new(232, 120, 132, 236)
      } else {
        @raylib.Color::new(150, 176, 206, 236)
      }

      @raylib.draw_circle(anchor.x.to_int(), anchor.y.to_int(), anchor.r, col)
      @raylib.draw_circle_lines(
        anchor.x.to_int(),
        anchor.y.to_int(),
        anchor.r + 8.0,
        @raylib.Color::new(232, 242, 252, 176),
      )

      let p01 : Float = clampf((anchor.progress + 100.0) / 200.0, 0.0, 1.0)
      let prog_fill : Int = (Float::from_int(80) * p01).to_int()
      @raylib.draw_rectangle(
        (anchor.x - 40.0).to_int(),
        (anchor.y + anchor.r + 8.0).to_int(),
        80,
        6,
        @raylib.Color::new(22, 30, 42, 255),
      )
      @raylib.draw_rectangle(
        (anchor.x - 40.0).to_int(),
        (anchor.y + anchor.r + 8.0).to_int(),
        prog_fill,
        6,
        @raylib.Color::new(132, 214, 248, 255),
      )
    }

    // orbs
    for orb in orbs {
      if not(orb.active) {
        continue
      }
      let col = if orb.kind == 0 {
        @raylib.Color::new(112, 236, 196, 236)
      } else {
        @raylib.Color::new(112, 198, 252, 236)
      }
      @raylib.draw_circle(
        orb.x.to_int(),
        orb.y.to_int(),
        6.0 + Float::from_int(orb.value),
        col,
      )
    }

    // enemies
    for enemy in enemies {
      if not(enemy.active) {
        continue
      }
      if enemy.kind == 0 {
        @raylib.draw_circle(
          enemy.x.to_int(),
          enemy.y.to_int(),
          15.0,
          @raylib.Color::new(230, 106, 116, 242),
        )
      } else if enemy.kind == 1 {
        @raylib.draw_rectangle(
          (enemy.x - 18.0).to_int(),
          (enemy.y - 14.0).to_int(),
          36,
          28,
          @raylib.Color::new(238, 152, 82, 242),
        )
      } else {
        @raylib.draw_rectangle(
          (enemy.x - 24.0).to_int(),
          (enemy.y - 20.0).to_int(),
          48,
          40,
          @raylib.Color::new(168, 100, 194, 240),
        )
      }
      @raylib.draw_circle_lines(
        enemy.x.to_int(),
        enemy.y.to_int(),
        enemy_radius(enemy.kind) + 4.0,
        @raylib.Color::new(252, 218, 224, 152),
      )
      if enemy.stun_t > 0.0 {
        @raylib.draw_circle_lines(
          enemy.x.to_int(),
          enemy.y.to_int(),
          enemy_radius(enemy.kind) + 10.0,
          @raylib.Color::new(132, 220, 254, 188),
        )
      }
    }

    // bullets
    for bullet in bullets {
      if not(bullet.active) {
        continue
      }
      let col = if bullet.team == 1 {
        @raylib.Color::new(248, 246, 152, 248)
      } else if bullet.kind == 1 {
        @raylib.Color::new(248, 128, 234, 246)
      } else {
        @raylib.Color::new(252, 132, 142, 242)
      }
      @raylib.draw_circle(bullet.x.to_int(), bullet.y.to_int(), bullet.r, col)
    }

    // player
    let pcol = if player.inv_t > 0.0 {
      @raylib.Color::new(252, 252, 252, 236)
    } else {
      @raylib.Color::new(98, 196, 252, 246)
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
      @raylib.Color::new(220, 246, 255, 252),
    )
    @raylib.draw_line(
      player.x.to_int(),
      player.y.to_int(),
      (player.x + player.aim_x * 26.0).to_int(),
      (player.y + player.aim_y * 26.0).to_int(),
      @raylib.Color::new(196, 236, 252, 224),
    )
    if player.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        player.x.to_int(),
        player.y.to_int(),
        28.0,
        @raylib.Color::new(126, 222, 252, 214),
      )
    }

    // particles
    for particle in particles {
      if not(particle.active) {
        continue
      }
      let alpha : Int = (clampf(particle.life / 0.84, 0.0, 1.0) * 255.0).to_int()
      let col = if particle.kind == 0 {
        @raylib.Color::new(114, 224, 252, alpha)
      } else if particle.kind == 1 {
        @raylib.Color::new(252, 236, 148, alpha)
      } else if particle.kind == 2 {
        @raylib.Color::new(252, 132, 132, alpha)
      } else {
        @raylib.Color::new(232, 168, 252, alpha)
      }
      @raylib.draw_circle(
        particle.x.to_int(),
        particle.y.to_int(),
        particle.size,
        col,
      )
    }

    // HUD
    @raylib.draw_rectangle(0, 0, sw, 86, @raylib.Color::new(8, 12, 20, 232))
    @raylib.draw_text(
      "Void Anchor Raid 2026",
      16,
      10,
      30,
      @raylib.Color::new(210, 236, 252, 248),
    )
    @raylib.draw_text(
      "Wave \{wave}",
      20,
      48,
      22,
      @raylib.Color::new(246, 228, 170, 252),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      164,
      48,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      346,
      48,
      22,
      @raylib.Color::new(170, 236, 194, 250),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      510,
      48,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Anchors \{count_owned_anchors(anchors, 1)}/\{count_total_anchors(anchors)}",
      684,
      48,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      1020,
      48,
      22,
      @raylib.Color::new(248, 214, 174, 252),
    )
    @raylib.draw_text(
      "FPS \{@raylib.get_fps()}",
      sw - 118,
      12,
      22,
      @raylib.Color::new(178, 216, 240, 218),
    )

    let hp_ratio : Float = clampf(player.hp / 100.0, 0.0, 1.0)
    let en_ratio : Float = clampf(player.energy / 100.0, 0.0, 1.0)
    let heat_ratio : Float = clampf(player.heat / 100.0, 0.0, 1.0)
    let hold_ratio : Float = clampf(hold_t / anchor_hold_goal, 0.0, 1.0)

    let hp_fill : Int = (hp_ratio * 230.0).to_int()
    let en_fill : Int = (en_ratio * 230.0).to_int()
    let heat_fill : Int = (heat_ratio * 230.0).to_int()
    let hold_fill : Int = (hold_ratio * 290.0).to_int()

    @raylib.draw_rectangle(16, 94, 290, 12, @raylib.Color::new(22, 28, 40, 255))
    @raylib.draw_rectangle(
      16,
      94,
      hold_fill,
      12,
      @raylib.Color::new(102, 212, 170, 255),
    )
    @raylib.draw_text(
      "HOLD",
      16,
      110,
      16,
      @raylib.Color::new(208, 236, 220, 255),
    )

    @raylib.draw_rectangle(
      16,
      130,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      130,
      hp_fill,
      10,
      @raylib.Color::new(230, 102, 122, 255),
    )
    @raylib.draw_text("HP", 16, 144, 16, @raylib.Color::new(238, 206, 216, 255))

    @raylib.draw_rectangle(
      16,
      162,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      162,
      en_fill,
      10,
      @raylib.Color::new(90, 190, 240, 255),
    )
    @raylib.draw_text("EN", 16, 176, 16, @raylib.Color::new(206, 230, 252, 255))

    @raylib.draw_rectangle(
      16,
      194,
      230,
      10,
      @raylib.Color::new(22, 28, 40, 255),
    )
    @raylib.draw_rectangle(
      16,
      194,
      heat_fill,
      10,
      @raylib.Color::new(244, 172, 98, 255),
    )
    @raylib.draw_text(
      "HEAT",
      16,
      208,
      16,
      @raylib.Color::new(246, 222, 194, 255),
    )

    @raylib.draw_text(
      "Capture [H]  Dash [K] \{(player.dash_cd * 10.0).to_int()}  Pulse [L] \{(player.pulse_cd * 10.0).to_int()}",
      332,
      100,
      20,
      @raylib.Color::new(224, 236, 250, 244),
    )
    @raylib.draw_text(
      "Enemies \{count_active_enemies(enemies)}  Hold \{hold_t.to_int()} / \{anchor_hold_goal.to_int()} sec",
      332,
      130,
      20,
      @raylib.Color::new(224, 236, 250, 244),
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
        "VOID ANCHOR RAID 2026",
        262,
        186,
        56,
        @raylib.Color::new(188, 236, 252, 255),
      )
      @raylib.draw_text(
        "Capture every anchor and hold control for 10 seconds.",
        250,
        286,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Enemy waves scale and enemy anchors can fire back.",
        266,
        330,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Move: WASD / Arrows   Fire: J / Space",
        320,
        388,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Capture Boost: H   Dash: K   Pulse: L",
        332,
        430,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Touch controls are shown for mobile play.",
        344,
        470,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Press Enter or tap to begin",
        444,
        552,
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
        "ANCHORS STABILIZED",
        320,
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
        "Best Combo: \{player.best_combo}   Wave: \{wave}",
        418,
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
        "RAID FAILED",
        432,
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
        "Owned Anchors: \{count_owned_anchors(anchors, 1)}/\{count_total_anchors(anchors)}",
        350,
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
