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
let max_guards : Int = 220

///|
let max_bullets : Int = 1200

///|
let max_cameras : Int = 18

///|
let max_terminals : Int = 8

///|
let max_vaults : Int = 8

///|
let max_loot : Int = 360

///|
let max_walls : Int = 80

///|
let max_particles : Int = 1800

///|
let extraction_x : Float = world_r - 80.0

///|
let extraction_y : Float = world_t + 80.0

///|
let extraction_r : Float = 72.0

///|
let loot_goal : Int = 42

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
  mut emp_cd : Float
  mut loot : Int
  mut delivered : Int
  mut score : Int
  mut combo : Int
  mut best_combo : Int
}

///|
struct Guard {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut fire_cd : Float
  mut state : Int
  mut home_x : Float
  mut home_y : Float
  mut target_x : Float
  mut target_y : Float
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
struct CameraUnit {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut base : Float
  mut sweep : Float
  mut speed : Float
  mut range : Float
  mut gain : Float
  mut hp : Float
  mut disabled_t : Float
  mut t : Float
}

///|
struct Terminal {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut hacked : Bool
  mut progress : Float
}

///|
struct Vault {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut open : Bool
  mut spawned : Bool
}

///|
struct Loot {
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
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
fn guard_radius(kind : Int) -> Float {
  if kind == 0 {
    15.0
  } else if kind == 1 {
    20.0
  } else {
    26.0
  }
}

///|
fn guard_hp(kind : Int, wave : Int) -> Float {
  if kind == 0 {
    26.0 + Float::from_int(wave) * 2.8
  } else if kind == 1 {
    44.0 + Float::from_int(wave) * 4.2
  } else {
    108.0 + Float::from_int(wave) * 8.4
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
fn bounce_from_walls(
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  r : Float,
  walls : Array[Wall],
) -> (Float, Float, Float, Float) {
  let mut nx : Float = x
  let mut ny : Float = y
  let mut nvx : Float = vx
  let mut nvy : Float = vy

  for i = 0; i < walls.length(); i = i + 1 {
    if not(walls[i].active) {
      continue
    }

    if circle_rect_hit(
        nx,
        ny,
        r,
        walls[i].x,
        walls[i].y,
        walls[i].w,
        walls[i].h,
      ) {
      if absf(vx) > absf(vy) {
        nx = nx - vx * 0.05
        nvx = -vx * 0.26
      } else {
        ny = ny - vy * 0.05
        nvy = -vy * 0.26
      }
    }
  }

  (nx, ny, nvx, nvy)
}

///|
fn clear_guards(guards : Array[Guard]) -> Unit {
  for i = 0; i < guards.length(); i = i + 1 {
    guards[i].active = false
    guards[i].kind = 0
    guards[i].x = 0.0
    guards[i].y = 0.0
    guards[i].vx = 0.0
    guards[i].vy = 0.0
    guards[i].hp = 0.0
    guards[i].fire_cd = 0.0
    guards[i].state = 0
    guards[i].home_x = 0.0
    guards[i].home_y = 0.0
    guards[i].target_x = 0.0
    guards[i].target_y = 0.0
    guards[i].stun_t = 0.0
    guards[i].t = 0.0
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
    bullets[i].r = 0.0
    bullets[i].life = 0.0
  }
}

///|
fn clear_cameras(cameras : Array[CameraUnit]) -> Unit {
  for i = 0; i < cameras.length(); i = i + 1 {
    cameras[i].active = false
    cameras[i].x = 0.0
    cameras[i].y = 0.0
    cameras[i].base = 0.0
    cameras[i].sweep = 0.0
    cameras[i].speed = 0.0
    cameras[i].range = 0.0
    cameras[i].gain = 0.0
    cameras[i].hp = 0.0
    cameras[i].disabled_t = 0.0
    cameras[i].t = 0.0
  }
}

///|
fn clear_terminals(terminals : Array[Terminal]) -> Unit {
  for i = 0; i < terminals.length(); i = i + 1 {
    terminals[i].active = false
    terminals[i].x = 0.0
    terminals[i].y = 0.0
    terminals[i].hacked = false
    terminals[i].progress = 0.0
  }
}

///|
fn clear_vaults(vaults : Array[Vault]) -> Unit {
  for i = 0; i < vaults.length(); i = i + 1 {
    vaults[i].active = false
    vaults[i].x = 0.0
    vaults[i].y = 0.0
    vaults[i].open = false
    vaults[i].spawned = false
  }
}

///|
fn clear_loot(loot : Array[Loot]) -> Unit {
  for i = 0; i < loot.length(); i = i + 1 {
    loot[i].active = false
    loot[i].kind = 0
    loot[i].x = 0.0
    loot[i].y = 0.0
    loot[i].vx = 0.0
    loot[i].vy = 0.0
    loot[i].value = 0
    loot[i].life = 0.0
    loot[i].t = 0.0
  }
}

///|
fn clear_walls(walls : Array[Wall]) -> Unit {
  for i = 0; i < walls.length(); i = i + 1 {
    walls[i].active = false
    walls[i].x = 0.0
    walls[i].y = 0.0
    walls[i].w = 0.0
    walls[i].h = 0.0
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
fn add_guard(
  guards : Array[Guard],
  kind : Int,
  x : Float,
  y : Float,
  home_x : Float,
  home_y : Float,
  wave : Int,
) -> Bool {
  for i = 0; i < guards.length(); i = i + 1 {
    if not(guards[i].active) {
      guards[i].active = true
      guards[i].kind = kind
      guards[i].x = x
      guards[i].y = y
      guards[i].vx = randf(-24.0, 24.0)
      guards[i].vy = randf(-24.0, 24.0)
      guards[i].hp = guard_hp(kind, wave)
      guards[i].fire_cd = randf(0.8, 1.8)
      guards[i].state = 0
      guards[i].home_x = home_x
      guards[i].home_y = home_y
      guards[i].target_x = home_x
      guards[i].target_y = home_y
      guards[i].stun_t = 0.0
      guards[i].t = randf(0.0, 30.0)
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
      bullets[i].r = r
      bullets[i].life = life
      return true
    }
  }
  false
}

///|
fn add_camera(
  cameras : Array[CameraUnit],
  x : Float,
  y : Float,
  base : Float,
  sweep : Float,
  speed : Float,
  range : Float,
  gain : Float,
) -> Bool {
  for i = 0; i < cameras.length(); i = i + 1 {
    if not(cameras[i].active) {
      cameras[i].active = true
      cameras[i].x = x
      cameras[i].y = y
      cameras[i].base = base
      cameras[i].sweep = sweep
      cameras[i].speed = speed
      cameras[i].range = range
      cameras[i].gain = gain
      cameras[i].hp = 80.0
      cameras[i].disabled_t = 0.0
      cameras[i].t = randf(0.0, 20.0)
      return true
    }
  }
  false
}

///|
fn add_terminal(terminals : Array[Terminal], x : Float, y : Float) -> Bool {
  for i = 0; i < terminals.length(); i = i + 1 {
    if not(terminals[i].active) {
      terminals[i].active = true
      terminals[i].x = x
      terminals[i].y = y
      terminals[i].hacked = false
      terminals[i].progress = 0.0
      return true
    }
  }
  false
}

///|
fn add_vault(vaults : Array[Vault], x : Float, y : Float) -> Bool {
  for i = 0; i < vaults.length(); i = i + 1 {
    if not(vaults[i].active) {
      vaults[i].active = true
      vaults[i].x = x
      vaults[i].y = y
      vaults[i].open = false
      vaults[i].spawned = false
      return true
    }
  }
  false
}

///|
fn add_loot(
  loot : Array[Loot],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  value : Int,
  life : Float,
) -> Bool {
  for i = 0; i < loot.length(); i = i + 1 {
    if not(loot[i].active) {
      loot[i].active = true
      loot[i].kind = kind
      loot[i].x = x
      loot[i].y = y
      loot[i].vx = vx
      loot[i].vy = vy
      loot[i].value = value
      loot[i].life = life
      loot[i].t = randf(0.0, 20.0)
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
  for i = 0; i < walls.length(); i = i + 1 {
    if not(walls[i].active) {
      walls[i].active = true
      walls[i].x = x
      walls[i].y = y
      walls[i].w = w
      walls[i].h = h
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
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  scale : Float,
  kind : Int,
) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
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
fn count_hacked(terminals : Array[Terminal]) -> Int {
  let mut n : Int = 0
  for i = 0; i < terminals.length(); i = i + 1 {
    if terminals[i].active && terminals[i].hacked {
      n = n + 1
    }
  }
  n
}

///|
fn count_terminals(terminals : Array[Terminal]) -> Int {
  let mut n : Int = 0
  for i = 0; i < terminals.length(); i = i + 1 {
    if terminals[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn count_active_guards(guards : Array[Guard]) -> Int {
  let mut n : Int = 0
  for i = 0; i < guards.length(); i = i + 1 {
    if guards[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn setup_map(
  walls : Array[Wall],
  terminals : Array[Terminal],
  vaults : Array[Vault],
  cameras : Array[CameraUnit],
) -> Unit {
  clear_walls(walls)
  clear_terminals(terminals)
  clear_vaults(vaults)
  clear_cameras(cameras)

  // perimeter blockers
  ignore(add_wall(walls, world_l, world_t, world_r - world_l, 14.0))
  ignore(add_wall(walls, world_l, world_b - 14.0, world_r - world_l, 14.0))
  ignore(add_wall(walls, world_l, world_t, 14.0, world_b - world_t))
  ignore(add_wall(walls, world_r - 14.0, world_t, 14.0, world_b - world_t))

  // central blocks and corridors
  ignore(add_wall(walls, 300.0, 250.0, 160.0, 26.0))
  ignore(add_wall(walls, 300.0, 250.0, 26.0, 190.0))
  ignore(add_wall(walls, 430.0, 414.0, 230.0, 26.0))
  ignore(add_wall(walls, 560.0, 250.0, 26.0, 190.0))

  ignore(add_wall(walls, 830.0, 220.0, 170.0, 26.0))
  ignore(add_wall(walls, 974.0, 220.0, 26.0, 220.0))
  ignore(add_wall(walls, 746.0, 414.0, 254.0, 26.0))

  ignore(add_wall(walls, 170.0, 520.0, 220.0, 24.0))
  ignore(add_wall(walls, 890.0, 520.0, 224.0, 24.0))

  ignore(add_wall(walls, 584.0, 154.0, 110.0, 18.0))
  ignore(add_wall(walls, 584.0, 592.0, 110.0, 18.0))

  // terminals
  ignore(add_terminal(terminals, 154.0, 158.0))
  ignore(add_terminal(terminals, 1120.0, 168.0))
  ignore(add_terminal(terminals, 1140.0, 600.0))

  // vaults
  ignore(add_vault(vaults, 212.0, 606.0))
  ignore(add_vault(vaults, 636.0, 300.0))
  ignore(add_vault(vaults, 1028.0, 590.0))

  // cameras
  ignore(add_camera(cameras, 260.0, 124.0, 1.2, 0.92, 1.2, 330.0, 13.0))
  ignore(add_camera(cameras, 1020.0, 124.0, 1.86, 0.98, 1.08, 340.0, 14.0))
  ignore(add_camera(cameras, 122.0, 392.0, 0.1, 0.62, 1.32, 290.0, 11.0))
  ignore(add_camera(cameras, 1160.0, 392.0, 3.14, 0.62, 1.24, 290.0, 11.0))
  ignore(add_camera(cameras, 640.0, 360.0, -1.57, 1.36, 0.9, 360.0, 15.0))
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
      "HACK",
      btn_x + 186,
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
      "EMP",
      btn_x + 196,
      btn_y + 146,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] neon heist extraction 2026")
  @raylib.set_target_fps(60)

  let walls : Array[Wall] = Array::makei(max_walls, fn(_i) {
    { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0 }
  })

  let guards : Array[Guard] = Array::makei(max_guards, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      hp: 0.0,
      fire_cd: 0.0,
      state: 0,
      home_x: 0.0,
      home_y: 0.0,
      target_x: 0.0,
      target_y: 0.0,
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

  let cameras : Array[CameraUnit] = Array::makei(max_cameras, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      base: 0.0,
      sweep: 0.0,
      speed: 0.0,
      range: 0.0,
      gain: 0.0,
      hp: 0.0,
      disabled_t: 0.0,
      t: 0.0,
    }
  })

  let terminals : Array[Terminal] = Array::makei(max_terminals, fn(_i) {
    { active: false, x: 0.0, y: 0.0, hacked: false, progress: 0.0 }
  })

  let vaults : Array[Vault] = Array::makei(max_vaults, fn(_i) {
    { active: false, x: 0.0, y: 0.0, open: false, spawned: false }
  })

  let loot : Array[Loot] = Array::makei(max_loot, fn(_i) {
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
    emp_cd: 0.0,
    loot: 0,
    delivered: 0,
    score: 0,
    combo: 0,
    best_combo: 0,
  }

  let mut state : Int = 0

  let mut timer : Float = 430.0
  let mut alarm : Float = 0.0
  let mut reinforce_cd : Float = 2.0
  let mut wave : Int = 1

  let mut msg : String = "Hack all terminals and extract loot"
  let mut msg_t : Float = 3.0

  let mut stars_t : Float = 0.0

  let reset_run = fn() {
    setup_map(walls, terminals, vaults, cameras)

    clear_guards(guards)
    clear_bullets(bullets)
    clear_loot(loot)
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
    player.emp_cd = 0.0
    player.loot = 0
    player.delivered = 0
    player.score = 0
    player.combo = 0
    player.best_combo = 0

    timer = 430.0
    alarm = 0.0
    reinforce_cd = 2.0
    wave = 1

    msg = "Stay unseen and hack terminals"
    msg_t = 2.2

    ignore(add_guard(guards, 0, 330.0, 180.0, 330.0, 180.0, wave))
    ignore(add_guard(guards, 0, 918.0, 176.0, 918.0, 176.0, wave))
    ignore(add_guard(guards, 1, 638.0, 340.0, 638.0, 340.0, wave))
    ignore(add_guard(guards, 0, 1090.0, 570.0, 1090.0, 570.0, wave))
  }

  let on_player_hit = fn(dmg : Float, reason : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut dealt : Float = dmg
      if player.dash_t > 0.0 {
        dealt = dealt * 0.55
      }
      player.hp = player.hp - dealt
      if player.hp < 0.0 {
        player.hp = 0.0
      }
      player.inv_t = 0.42
      player.combo = 0
      msg = reason
      msg_t = 0.72
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

      player.emp_cd = player.emp_cd - dt
      if player.emp_cd < 0.0 {
        player.emp_cd = 0.0
      }

      player.energy = player.energy + dt * 10.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      player.heat = player.heat - dt * 36.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      // Alarm dynamics.
      let decay : Float = if count_active_guards(guards) > 0 {
        3.2
      } else {
        4.2
      }
      alarm = alarm - decay * dt
      if alarm < 0.0 {
        alarm = 0.0
      }
      if alarm > 100.0 {
        alarm = 100.0
      }

      if alarm >= 35.0 {
        reinforce_cd = reinforce_cd - dt
        if reinforce_cd <= 0.0 {
          reinforce_cd = clampf(2.8 - Float::from_int(wave) * 0.22, 1.0, 2.8)
          wave = wave + 1

          let edge : Int = @raylib.get_random_value(0, 3)
          let mut gx : Float = 0.0
          let mut gy : Float = 0.0
          if edge == 0 {
            gx = randf(world_l + 20.0, world_r - 20.0)
            gy = world_t + 20.0
          } else if edge == 1 {
            gx = world_r - 20.0
            gy = randf(world_t + 20.0, world_b - 20.0)
          } else if edge == 2 {
            gx = randf(world_l + 20.0, world_r - 20.0)
            gy = world_b - 20.0
          } else {
            gx = world_l + 20.0
            gy = randf(world_t + 20.0, world_b - 20.0)
          }

          let roll : Int = @raylib.get_random_value(0, 99)
          let mut kind : Int = 0
          if wave >= 4 && roll >= 45 {
            kind = 1
          }
          if wave >= 8 && roll >= 82 {
            kind = 2
          }

          ignore(add_guard(guards, kind, gx, gy, gx, gy, wave))
          msg = "Reinforcement arrived"
          msg_t = 0.64
        }
      } else {
        reinforce_cd = clampf(reinforce_cd + dt * 0.6, 0.0, 3.2)
      }

      // Input processing.
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
      let mut hack_hold : Bool = @raylib.is_key_down(@raylib.KeyK)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyRightShift)
      let mut emp_press : Bool = @raylib.is_key_pressed(@raylib.KeyO)

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
          hack_hold = true
        }
      }

      if touch_press {
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 112, 138, 90) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 158, btn_y + 112, 138, 90) {
          emp_press = true
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

      let mouse_in_arena : Bool = mouse.x >= world_l &&
        mouse.x <= world_r &&
        mouse.y >= world_t &&
        mouse.y <= world_b
      if mouse_in_arena {
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

      let accel : Float = if player.dash_t > 0.0 { 1700.0 } else { 980.0 }
      player.vx = player.vx + inp_x * accel * dt
      player.vy = player.vy + inp_y * accel * dt

      let drag : Float = if player.dash_t > 0.0 { 2.2 } else { 5.4 }
      player.vx = player.vx * (1.0 - drag * dt)
      player.vy = player.vy * (1.0 - drag * dt)

      let max_spd : Float = if player.dash_t > 0.0 { 470.0 } else { 310.0 }
      let sp2 : Float = player.vx * player.vx + player.vy * player.vy
      if sp2 > max_spd * max_spd {
        let invs : Float = max_spd / sp2.sqrt()
        player.vx = player.vx * invs
        player.vy = player.vy * invs
      }

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 20.0 {
        player.dash_cd = 1.16
        player.dash_t = 0.22
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

        burst(particles, player.x, player.y, 14, 0.16, 0)
      }

      if emp_press && player.emp_cd <= 0.0 && player.energy >= 40.0 {
        player.emp_cd = 6.0
        player.energy = player.energy - 40.0
        alarm = clampf(alarm - 26.0, 0.0, 100.0)
        msg = "EMP pulse"
        msg_t = 0.54

        burst(particles, player.x, player.y, 80, 0.34, 3)

        for i = 0; i < cameras.length(); i = i + 1 {
          if not(cameras[i].active) {
            continue
          }
          if dist2(player.x, player.y, cameras[i].x, cameras[i].y) <=
            330.0 * 330.0 {
            cameras[i].disabled_t = clampf(
              cameras[i].disabled_t + 5.2,
              0.0,
              8.0,
            )
          }
        }

        for i = 0; i < guards.length(); i = i + 1 {
          if not(guards[i].active) {
            continue
          }
          if dist2(player.x, player.y, guards[i].x, guards[i].y) <=
            260.0 * 260.0 {
            guards[i].stun_t = clampf(guards[i].stun_t + 1.9, 0.0, 3.2)
            guards[i].state = 0
            guards[i].vx = guards[i].vx * 0.2
            guards[i].vy = guards[i].vy * 0.2
          }
        }

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            bullets[i].team == 2 &&
            dist2(player.x, player.y, bullets[i].x, bullets[i].y) <=
            280.0 * 280.0 {
            bullets[i].active = false
          }
        }
      }

      player.x = clampf(
        player.x + player.vx * dt,
        world_l + 16.0,
        world_r - 16.0,
      )
      player.y = clampf(
        player.y + player.vy * dt,
        world_t + 16.0,
        world_b - 16.0,
      )

      let (px, py, pvx, pvy) = bounce_from_walls(
        player.x,
        player.y,
        player.vx,
        player.vy,
        16.0,
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

      // hacking
      let mut hacked_this_frame : Bool = false
      if hack_hold {
        for i = 0; i < terminals.length(); i = i + 1 {
          if not(terminals[i].active) || terminals[i].hacked {
            continue
          }
          if dist2(player.x, player.y, terminals[i].x, terminals[i].y) <=
            62.0 * 62.0 {
            terminals[i].progress = terminals[i].progress + dt * 38.0
            hacked_this_frame = true
            if terminals[i].progress >= 100.0 {
              terminals[i].progress = 100.0
              terminals[i].hacked = true
              alarm = clampf(alarm - 16.0, 0.0, 100.0)
              player.score = player.score + 180
              msg = "Terminal hacked"
              msg_t = 0.8
              burst(particles, terminals[i].x, terminals[i].y, 22, 0.2, 0)
            }
          }
        }
      }

      if not(hacked_this_frame) {
        for i = 0; i < terminals.length(); i = i + 1 {
          if terminals[i].active && not(terminals[i].hacked) {
            terminals[i].progress = clampf(
              terminals[i].progress - dt * 10.0,
              0.0,
              100.0,
            )
          }
        }
      }

      // unlock vaults when all terminals hacked
      if count_hacked(terminals) == count_terminals(terminals) {
        for i = 0; i < vaults.length(); i = i + 1 {
          if vaults[i].active {
            vaults[i].open = true
          }
        }
      }

      // vault spawn
      for i = 0; i < vaults.length(); i = i + 1 {
        if not(vaults[i].active) || not(vaults[i].open) || vaults[i].spawned {
          continue
        }
        if dist2(player.x, player.y, vaults[i].x, vaults[i].y) <= 100.0 * 100.0 {
          vaults[i].spawned = true
          for k = 0; k < 14; k = k + 1 {
            ignore(
              add_loot(
                loot,
                @raylib.get_random_value(0, 2),
                vaults[i].x,
                vaults[i].y,
                randf(-120.0, 120.0),
                randf(-120.0, 120.0),
                1 + @raylib.get_random_value(0, 2),
                randf(80.0, 140.0),
              ),
            )
          }
          msg = "Vault opened"
          msg_t = 0.76
          burst(particles, vaults[i].x, vaults[i].y, 28, 0.24, 3)
        }
      }

      // camera update/detection
      for i = 0; i < cameras.length(); i = i + 1 {
        if not(cameras[i].active) {
          continue
        }

        cameras[i].t = cameras[i].t + dt

        cameras[i].disabled_t = cameras[i].disabled_t - dt
        if cameras[i].disabled_t < 0.0 {
          cameras[i].disabled_t = 0.0
        }

        if cameras[i].disabled_t <= 0.0 {
          let ang : Float = cameras[i].base +
            @math.sinf(cameras[i].t * cameras[i].speed) * cameras[i].sweep
          let fx : Float = @math.cosf(ang)
          let fy : Float = @math.sinf(ang)

          let dx : Float = player.x - cameras[i].x
          let dy : Float = player.y - cameras[i].y
          let d2 : Float = dx * dx + dy * dy
          if d2 <= cameras[i].range * cameras[i].range {
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let nx : Float = dx / d
            let ny : Float = dy / d
            let dot : Float = nx * fx + ny * fy
            if dot >= 0.85 {
              alarm = clampf(alarm + cameras[i].gain * dt, 0.0, 100.0)
              if msg_t < 0.14 {
                msg = "Camera detection"
                msg_t = 0.2
              }
            }
          }
        }
      }

      // guards update
      for i = 0; i < guards.length(); i = i + 1 {
        if not(guards[i].active) {
          continue
        }

        guards[i].t = guards[i].t + dt
        guards[i].fire_cd = guards[i].fire_cd - dt
        guards[i].stun_t = guards[i].stun_t - dt
        if guards[i].stun_t < 0.0 {
          guards[i].stun_t = 0.0
        }

        let player_d2 : Float = dist2(
          guards[i].x,
          guards[i].y,
          player.x,
          player.y,
        )
        let mut sees_player : Bool = false
        let see_range : Float = if guards[i].kind == 2 { 360.0 } else { 280.0 }
        if player_d2 <= see_range * see_range {
          sees_player = true
        }

        if alarm >= 38.0 {
          sees_player = true
        }

        if guards[i].stun_t > 0.0 {
          guards[i].vx = guards[i].vx * (1.0 - dt * 6.0)
          guards[i].vy = guards[i].vy * (1.0 - dt * 6.0)
        } else {
          if sees_player {
            guards[i].state = 1
            guards[i].target_x = player.x
            guards[i].target_y = player.y
          } else {
            guards[i].state = 0
            if dist2(
                guards[i].x,
                guards[i].y,
                guards[i].target_x,
                guards[i].target_y,
              ) <=
              40.0 * 40.0 {
              guards[i].target_x = guards[i].home_x + randf(-120.0, 120.0)
              guards[i].target_y = guards[i].home_y + randf(-100.0, 100.0)
              guards[i].target_x = clampf(
                guards[i].target_x,
                world_l + 40.0,
                world_r - 40.0,
              )
              guards[i].target_y = clampf(
                guards[i].target_y,
                world_t + 40.0,
                world_b - 40.0,
              )
            }
          }

          let tx : Float = guards[i].target_x - guards[i].x
          let ty : Float = guards[i].target_y - guards[i].y
          let mut inv : Float = 0.0
          let l2 : Float = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }

          if guards[i].state == 1 {
            let acc : Float = if guards[i].kind == 2 { 130.0 } else { 170.0 }
            guards[i].vx = guards[i].vx + tx * inv * acc * dt
            guards[i].vy = guards[i].vy + ty * inv * acc * dt
          } else {
            guards[i].vx = guards[i].vx +
              tx * inv * 90.0 * dt +
              @math.sinf(guards[i].t * 1.2) * 10.0 * dt
            guards[i].vy = guards[i].vy +
              ty * inv * 90.0 * dt +
              @math.cosf(guards[i].t * 1.4) * 10.0 * dt
          }

          if guards[i].state == 1 &&
            guards[i].fire_cd <= 0.0 &&
            player_d2 <= 360.0 * 360.0 {
            let mut iv : Float = 0.0
            if player_d2 > 0.01 {
              iv = 1.0 / player_d2.sqrt()
            }

            if guards[i].kind == 0 {
              guards[i].fire_cd = randf(1.2, 2.1)
              ignore(
                add_bullet(
                  bullets,
                  2,
                  0,
                  guards[i].x,
                  guards[i].y,
                  (player.x - guards[i].x) * iv * 300.0,
                  (player.y - guards[i].y) * iv * 300.0,
                  8.0,
                  5.0,
                  2.8,
                ),
              )
            } else if guards[i].kind == 1 {
              guards[i].fire_cd = randf(0.9, 1.5)
              let sx : Float = -(player.y - guards[i].y) * iv
              let sy : Float = (player.x - guards[i].x) * iv
              ignore(
                add_bullet(
                  bullets,
                  2,
                  0,
                  guards[i].x,
                  guards[i].y,
                  (player.x - guards[i].x) * iv * 290.0 + sx * 68.0,
                  (player.y - guards[i].y) * iv * 290.0 + sy * 68.0,
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
                  guards[i].x,
                  guards[i].y,
                  (player.x - guards[i].x) * iv * 290.0 - sx * 68.0,
                  (player.y - guards[i].y) * iv * 290.0 - sy * 68.0,
                  7.0,
                  4.0,
                  2.8,
                ),
              )
            } else {
              guards[i].fire_cd = randf(1.5, 2.3)
              ignore(
                add_bullet(
                  bullets,
                  2,
                  1,
                  guards[i].x,
                  guards[i].y,
                  (player.x - guards[i].x) * iv * 250.0,
                  (player.y - guards[i].y) * iv * 250.0,
                  12.0,
                  6.0,
                  3.2,
                ),
              )
            }
          }
        }

        let max_spd : Float = if guards[i].kind == 2 {
          170.0
        } else {
          230.0 + Float::from_int(wave) * 3.0
        }
        let sp2 : Float = guards[i].vx * guards[i].vx +
          guards[i].vy * guards[i].vy
        if sp2 > max_spd * max_spd {
          let invs : Float = max_spd / sp2.sqrt()
          guards[i].vx = guards[i].vx * invs
          guards[i].vy = guards[i].vy * invs
        }

        guards[i].x = clampf(
          guards[i].x + guards[i].vx * dt,
          world_l + 16.0,
          world_r - 16.0,
        )
        guards[i].y = clampf(
          guards[i].y + guards[i].vy * dt,
          world_t + 16.0,
          world_b - 16.0,
        )

        let (gx, gy, gvx, gvy) = bounce_from_walls(
          guards[i].x,
          guards[i].y,
          guards[i].vx,
          guards[i].vy,
          guard_radius(guards[i].kind),
          walls,
        )
        guards[i].x = gx
        guards[i].y = gy
        guards[i].vx = gvx
        guards[i].vy = gvy

        if dist2(guards[i].x, guards[i].y, player.x, player.y) <=
          (guard_radius(guards[i].kind) + 16.0) *
          (guard_radius(guards[i].kind) + 16.0) {
          on_player_hit(
            7.0 + Float::from_int(guards[i].kind) * 2.0,
            "Guard collision",
          )
          guards[i].vx = -guards[i].vx
          guards[i].vy = -guards[i].vy
        }

        if guards[i].hp <= 0.0 {
          let reward : Int = 54 + guards[i].kind * 28 + player.combo * 2
          player.score = player.score + reward
          player.combo = player.combo + 1
          if player.combo > player.best_combo {
            player.best_combo = player.combo
          }

          let drops : Int = 1 + @raylib.get_random_value(0, 2)
          for d = 0; d < drops; d = d + 1 {
            ignore(
              add_loot(
                loot,
                @raylib.get_random_value(0, 2),
                guards[i].x,
                guards[i].y,
                randf(-120.0, 120.0),
                randf(-120.0, 120.0),
                1 + @raylib.get_random_value(0, 2),
                randf(34.0, 72.0),
              ),
            )
          }

          burst(particles, guards[i].x, guards[i].y, 20, 0.2, 0)
          guards[i].active = false
        }
      }

      // loot update
      for i = 0; i < loot.length(); i = i + 1 {
        if not(loot[i].active) {
          continue
        }

        loot[i].life = loot[i].life - dt
        if loot[i].life <= 0.0 {
          loot[i].active = false
          continue
        }

        loot[i].t = loot[i].t + dt
        loot[i].x = loot[i].x + loot[i].vx * dt
        loot[i].y = loot[i].y + loot[i].vy * dt
        loot[i].vx = loot[i].vx * (1.0 - dt * 1.6)
        loot[i].vy = loot[i].vy * (1.0 - dt * 1.6)

        loot[i].x = clampf(loot[i].x, world_l + 8.0, world_r - 8.0)
        loot[i].y = clampf(loot[i].y, world_t + 8.0, world_b - 8.0)

        if dist2(player.x, player.y, loot[i].x, loot[i].y) <= 26.0 * 26.0 {
          player.loot = player.loot + loot[i].value
          player.score = player.score + loot[i].value * 8
          loot[i].active = false
          burst(particles, player.x, player.y, 8, 0.12, 0)
        }
      }

      // extraction deposit
      if dist2(player.x, player.y, extraction_x, extraction_y) <=
        extraction_r * extraction_r &&
        player.loot > 0 &&
        count_hacked(terminals) == count_terminals(terminals) {
        let deposit_n : Int = player.loot
        player.delivered = player.delivered + deposit_n
        player.score = player.score + deposit_n * 18
        player.loot = 0
        msg = "Loot secured: \{player.delivered}/\{loot_goal}"
        msg_t = 0.74
        burst(particles, extraction_x, extraction_y, 26, 0.2, 3)
      }

      // bullet update + collisions
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

        if bullets[i].x < world_l - 50.0 ||
          bullets[i].x > world_r + 50.0 ||
          bullets[i].y < world_t - 50.0 ||
          bullets[i].y > world_b + 50.0 {
          bullets[i].active = false
          continue
        }

        // wall hit
        let mut blocked : Bool = false
        for w = 0; w < walls.length(); w = w + 1 {
          if not(walls[w].active) {
            continue
          }
          if circle_rect_hit(
              bullets[i].x,
              bullets[i].y,
              bullets[i].r,
              walls[w].x,
              walls[w].y,
              walls[w].w,
              walls[w].h,
            ) {
            bullets[i].active = false
            blocked = true
            break
          }
        }
        if blocked {
          continue
        }

        if bullets[i].team == 1 {
          let mut consumed : Bool = false

          for g = 0; g < guards.length(); g = g + 1 {
            if consumed {
              continue
            }
            if not(guards[g].active) {
              continue
            }
            let rr : Float = bullets[i].r + guard_radius(guards[g].kind)
            if dist2(bullets[i].x, bullets[i].y, guards[g].x, guards[g].y) <=
              rr * rr {
              guards[g].hp = guards[g].hp - bullets[i].dmg
              bullets[i].active = false
              consumed = true
              burst(particles, bullets[i].x, bullets[i].y, 4, 0.1, 1)
            }
          }

          if bullets[i].active {
            for c = 0; c < cameras.length(); c = c + 1 {
              if not(cameras[c].active) {
                continue
              }
              if dist2(bullets[i].x, bullets[i].y, cameras[c].x, cameras[c].y) <=
                (bullets[i].r + 14.0) * (bullets[i].r + 14.0) {
                cameras[c].hp = cameras[c].hp - bullets[i].dmg * 0.66
                bullets[i].active = false
                if cameras[c].hp <= 0.0 {
                  cameras[c].hp = 80.0
                  cameras[c].disabled_t = 9.0
                  burst(particles, cameras[c].x, cameras[c].y, 18, 0.18, 3)
                }
                break
              }
            }
          }
        } else if dist2(bullets[i].x, bullets[i].y, player.x, player.y) <=
          (bullets[i].r + 16.0) * (bullets[i].r + 16.0) {
          on_player_hit(bullets[i].dmg, "Guard fire")
          bullets[i].active = false
          continue
        }
      }

      // particle update
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
        particles[i].vx = particles[i].vx * (1.0 - dt * 1.9)
        particles[i].vy = particles[i].vy * (1.0 - dt * 1.9)
      }

      // lose/win checks
      if timer <= 0.0 {
        state = 3
        msg = "Time expired"
        msg_t = 2.4
      }
      if player.hp <= 0.0 {
        state = 3
        msg = "Caught in action"
        msg_t = 2.4
      }
      if alarm >= 100.0 {
        state = 3
        msg = "Alarm maxed out"
        msg_t = 2.4
      }
      if player.delivered >= loot_goal {
        state = 2
        msg = "Extraction complete"
        msg_t = 2.2
      }
    } else if @raylib.is_key_pressed(@raylib.KeyR) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      touch_press {
      state = 1
      reset_run()
    }

    // Render.
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

    for gy = 0; gy < 15; gy = gy + 1 {
      let y : Int = 90 + gy * 44
      @raylib.draw_line(0, y, sw, y, @raylib.Color::new(22, 30, 46, 122))
    }
    for gx = 0; gx < 26; gx = gx + 1 {
      let x : Int = gx * 50
      @raylib.draw_line(x, 90, x, sh, @raylib.Color::new(22, 30, 46, 102))
    }

    for i = 0; i < 170; i = i + 1 {
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

    // playable zone
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

    // extraction zone
    @raylib.draw_circle(
      extraction_x.to_int(),
      extraction_y.to_int(),
      extraction_r,
      @raylib.Color::new(40, 134, 182, 66),
    )
    @raylib.draw_circle_lines(
      extraction_x.to_int(),
      extraction_y.to_int(),
      extraction_r,
      @raylib.Color::new(134, 228, 255, 220),
    )
    @raylib.draw_text(
      "EXTRACT",
      (extraction_x - 42.0).to_int(),
      (extraction_y - 12.0).to_int(),
      18,
      @raylib.Color::new(198, 236, 252, 242),
    )

    // walls
    for i = 0; i < walls.length(); i = i + 1 {
      if not(walls[i].active) {
        continue
      }
      @raylib.draw_rectangle(
        walls[i].x.to_int(),
        walls[i].y.to_int(),
        walls[i].w.to_int(),
        walls[i].h.to_int(),
        @raylib.Color::new(66, 76, 98, 236),
      )
      @raylib.draw_rectangle_lines(
        walls[i].x.to_int(),
        walls[i].y.to_int(),
        walls[i].w.to_int(),
        walls[i].h.to_int(),
        @raylib.Color::new(168, 188, 216, 124),
      )
    }

    // terminals
    for i = 0; i < terminals.length(); i = i + 1 {
      if not(terminals[i].active) {
        continue
      }
      let col = if terminals[i].hacked {
        @raylib.Color::new(108, 220, 168, 244)
      } else {
        @raylib.Color::new(228, 166, 90, 242)
      }
      @raylib.draw_rectangle(
        (terminals[i].x - 16.0).to_int(),
        (terminals[i].y - 16.0).to_int(),
        32,
        32,
        col,
      )
      @raylib.draw_rectangle_lines(
        (terminals[i].x - 20.0).to_int(),
        (terminals[i].y - 20.0).to_int(),
        40,
        40,
        @raylib.Color::new(232, 240, 250, 180),
      )

      if not(terminals[i].hacked) {
        let prog_fill : Int = (clampf(terminals[i].progress / 100.0, 0.0, 1.0) *
        40.0).to_int()
        @raylib.draw_rectangle(
          (terminals[i].x - 20.0).to_int(),
          (terminals[i].y + 24.0).to_int(),
          40,
          6,
          @raylib.Color::new(24, 30, 42, 255),
        )
        @raylib.draw_rectangle(
          (terminals[i].x - 20.0).to_int(),
          (terminals[i].y + 24.0).to_int(),
          prog_fill,
          6,
          @raylib.Color::new(128, 214, 246, 255),
        )
      }
    }

    // vaults
    for i = 0; i < vaults.length(); i = i + 1 {
      if not(vaults[i].active) {
        continue
      }
      let col = if vaults[i].open {
        @raylib.Color::new(96, 140, 186, 236)
      } else {
        @raylib.Color::new(124, 74, 92, 236)
      }
      @raylib.draw_rectangle(
        (vaults[i].x - 24.0).to_int(),
        (vaults[i].y - 20.0).to_int(),
        48,
        40,
        col,
      )
      @raylib.draw_rectangle_lines(
        (vaults[i].x - 28.0).to_int(),
        (vaults[i].y - 24.0).to_int(),
        56,
        48,
        @raylib.Color::new(226, 236, 250, 174),
      )
    }

    // cameras + view cone
    for i = 0; i < cameras.length(); i = i + 1 {
      if not(cameras[i].active) {
        continue
      }

      let ang : Float = cameras[i].base +
        @math.sinf(cameras[i].t * cameras[i].speed) * cameras[i].sweep
      let fx : Float = @math.cosf(ang)
      let fy : Float = @math.sinf(ang)

      let cone_col = if cameras[i].disabled_t > 0.0 {
        @raylib.Color::new(140, 140, 156, 78)
      } else {
        @raylib.Color::new(248, 130, 138, 72)
      }

      @raylib.draw_line(
        cameras[i].x.to_int(),
        cameras[i].y.to_int(),
        (cameras[i].x + fx * cameras[i].range).to_int(),
        (cameras[i].y + fy * cameras[i].range).to_int(),
        cone_col,
      )
      @raylib.draw_line(
        cameras[i].x.to_int(),
        cameras[i].y.to_int(),
        (cameras[i].x + (fx * 0.84 - fy * 0.54) * cameras[i].range).to_int(),
        (cameras[i].y + (fy * 0.84 + fx * 0.54) * cameras[i].range).to_int(),
        cone_col,
      )
      @raylib.draw_line(
        cameras[i].x.to_int(),
        cameras[i].y.to_int(),
        (cameras[i].x + (fx * 0.84 + fy * 0.54) * cameras[i].range).to_int(),
        (cameras[i].y + (fy * 0.84 - fx * 0.54) * cameras[i].range).to_int(),
        cone_col,
      )

      let cam_col = if cameras[i].disabled_t > 0.0 {
        @raylib.Color::new(132, 144, 162, 244)
      } else {
        @raylib.Color::new(224, 108, 120, 244)
      }
      @raylib.draw_circle(
        cameras[i].x.to_int(),
        cameras[i].y.to_int(),
        13.0,
        cam_col,
      )
      @raylib.draw_circle_lines(
        cameras[i].x.to_int(),
        cameras[i].y.to_int(),
        16.0,
        @raylib.Color::new(244, 220, 228, 170),
      )
    }

    // loot
    for i = 0; i < loot.length(); i = i + 1 {
      if not(loot[i].active) {
        continue
      }
      let col = if loot[i].kind == 0 {
        @raylib.Color::new(112, 236, 196, 236)
      } else if loot[i].kind == 1 {
        @raylib.Color::new(112, 198, 252, 236)
      } else {
        @raylib.Color::new(252, 216, 118, 236)
      }
      @raylib.draw_circle(
        loot[i].x.to_int(),
        loot[i].y.to_int(),
        6.0 + Float::from_int(loot[i].value),
        col,
      )
    }

    // guards
    for i = 0; i < guards.length(); i = i + 1 {
      if not(guards[i].active) {
        continue
      }
      if guards[i].kind == 0 {
        @raylib.draw_circle(
          guards[i].x.to_int(),
          guards[i].y.to_int(),
          15.0,
          @raylib.Color::new(230, 106, 116, 242),
        )
      } else if guards[i].kind == 1 {
        @raylib.draw_rectangle(
          (guards[i].x - 18.0).to_int(),
          (guards[i].y - 14.0).to_int(),
          36,
          28,
          @raylib.Color::new(238, 152, 82, 242),
        )
      } else {
        @raylib.draw_rectangle(
          (guards[i].x - 24.0).to_int(),
          (guards[i].y - 20.0).to_int(),
          48,
          40,
          @raylib.Color::new(168, 100, 194, 240),
        )
      }
      @raylib.draw_circle_lines(
        guards[i].x.to_int(),
        guards[i].y.to_int(),
        guard_radius(guards[i].kind) + 4.0,
        @raylib.Color::new(252, 218, 224, 152),
      )
      if guards[i].stun_t > 0.0 {
        @raylib.draw_circle_lines(
          guards[i].x.to_int(),
          guards[i].y.to_int(),
          guard_radius(guards[i].kind) + 10.0,
          @raylib.Color::new(132, 220, 254, 188),
        )
      }
    }

    // bullets
    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      let col = if bullets[i].team == 1 {
        @raylib.Color::new(248, 246, 152, 248)
      } else if bullets[i].kind == 1 {
        @raylib.Color::new(248, 128, 234, 246)
      } else {
        @raylib.Color::new(252, 132, 142, 242)
      }
      @raylib.draw_circle(
        bullets[i].x.to_int(),
        bullets[i].y.to_int(),
        bullets[i].r,
        col,
      )
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
    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let alpha : Int = (clampf(particles[i].life / 0.84, 0.0, 1.0) * 255.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(114, 224, 252, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 236, 148, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(252, 132, 132, alpha)
      } else {
        @raylib.Color::new(232, 168, 252, alpha)
      }
      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    // HUD
    @raylib.draw_rectangle(0, 0, sw, 86, @raylib.Color::new(8, 12, 20, 232))
    @raylib.draw_text(
      "Neon Heist Extraction 2026",
      16,
      10,
      30,
      @raylib.Color::new(210, 236, 252, 248),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      20,
      48,
      22,
      @raylib.Color::new(246, 228, 170, 252),
    )
    @raylib.draw_text(
      "Loot \{player.loot}",
      204,
      48,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Delivered \{player.delivered}/\{loot_goal}",
      350,
      48,
      22,
      @raylib.Color::new(170, 236, 194, 250),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      616,
      48,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      776,
      48,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      950,
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

    let hp_fill : Int = (clampf(player.hp / 100.0, 0.0, 1.0) * 230.0).to_int()
    let en_fill : Int = (clampf(player.energy / 100.0, 0.0, 1.0) * 230.0).to_int()
    let heat_fill : Int = (clampf(player.heat / 100.0, 0.0, 1.0) * 230.0).to_int()
    let alarm_fill : Int = (clampf(alarm / 100.0, 0.0, 1.0) * 290.0).to_int()

    @raylib.draw_rectangle(16, 94, 290, 12, @raylib.Color::new(22, 28, 40, 255))
    @raylib.draw_rectangle(
      16,
      94,
      alarm_fill,
      12,
      @raylib.Color::new(238, 104, 122, 255),
    )
    @raylib.draw_text(
      "ALARM",
      16,
      110,
      16,
      @raylib.Color::new(238, 208, 218, 255),
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
      "Hack [K]  Dash [L] \{(player.dash_cd * 10.0).to_int()}  EMP [O] \{(player.emp_cd * 10.0).to_int()}",
      332,
      100,
      20,
      @raylib.Color::new(224, 236, 250, 244),
    )
    @raylib.draw_text(
      "Terminals \{count_hacked(terminals)} / \{count_terminals(terminals)}   Guards \{count_active_guards(guards)}",
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
        "NEON HEIST EXTRACTION 2026",
        186,
        186,
        54,
        @raylib.Color::new(188, 236, 252, 255),
      )
      @raylib.draw_text(
        "Hack terminals, crack vaults, and extract 42 loot units.",
        232,
        284,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Avoid cameras and keep alarm under 100.",
        352,
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
        "Hack: K   Dash: L   EMP: O",
        438,
        430,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Touch controls are shown on screen for mobile.",
        322,
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
        "EXTRACTION SUCCESS",
        330,
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
        "Delivered: \{player.delivered}   Best Combo: \{player.best_combo}",
        380,
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
        "HEIST FAILED",
        430,
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
        "Loot Delivered: \{player.delivered}/\{loot_goal}",
        404,
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
