///|
let sw : Int = 1366

///|
let sh : Int = 768

///|
let world_w : Float = 3600.0

///|
let world_h : Float = 2600.0

///|
let max_drones : Int = 240

///|
let max_bullets : Int = 980

///|
let max_scrap : Int = 360

///|
let max_mines : Int = 220

///|
let max_particles : Int = 1700

///|
let max_wrecks : Int = 120

///|
let player_radius : Float = 18.0

///|
let target_salvage : Int = 120

///|
let beacon_x : Float = world_w - 260.0

///|
let beacon_y : Float = 250.0

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut face_x : Float
  mut face_y : Float
  mut hp : Float
  mut energy : Float
  mut heat : Float
  mut inv_t : Float
  mut fire_cd : Float
  mut pulse_cd : Float
  mut boost_cd : Float
  mut boost_t : Float
  mut cargo : Int
  mut deposited : Int
  mut score : Int
  mut combo : Int
  mut best_combo : Int
  mut tractor_on : Bool
}

///|
struct Drone {
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
  mut radius : Float
  mut life : Float
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
  mut t : Float
  mut magnet : Bool
}

///|
struct Mine {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut arm_t : Float
  mut life : Float
}

///|
struct Wreck {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
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
struct Boss {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut max_hp : Float
  mut fire_cd : Float
  mut spawn_cd : Float
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
fn drone_radius(kind : Int) -> Float {
  if kind == 0 {
    16.0
  } else if kind == 1 {
    21.0
  } else {
    28.0
  }
}

///|
fn drone_hp(kind : Int, level : Int) -> Float {
  if kind == 0 {
    38.0 + Float::from_int(level) * 3.0
  } else if kind == 1 {
    56.0 + Float::from_int(level) * 4.4
  } else {
    120.0 + Float::from_int(level) * 7.0
  }
}

///|
fn clear_drones(drones : Array[Drone]) -> Unit {
  for i = 0; i < drones.length(); i = i + 1 {
    drones[i].active = false
    drones[i].kind = 0
    drones[i].x = 0.0
    drones[i].y = 0.0
    drones[i].vx = 0.0
    drones[i].vy = 0.0
    drones[i].hp = 0.0
    drones[i].fire_cd = 0.0
    drones[i].t = 0.0
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
fn clear_scrap(scraps : Array[Scrap]) -> Unit {
  for i = 0; i < scraps.length(); i = i + 1 {
    scraps[i].active = false
    scraps[i].kind = 0
    scraps[i].x = 0.0
    scraps[i].y = 0.0
    scraps[i].vx = 0.0
    scraps[i].vy = 0.0
    scraps[i].value = 0
    scraps[i].t = 0.0
    scraps[i].magnet = false
  }
}

///|
fn clear_mines(mines : Array[Mine]) -> Unit {
  for i = 0; i < mines.length(); i = i + 1 {
    mines[i].active = false
    mines[i].x = 0.0
    mines[i].y = 0.0
    mines[i].vx = 0.0
    mines[i].vy = 0.0
    mines[i].radius = 0.0
    mines[i].arm_t = 0.0
    mines[i].life = 0.0
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
fn clear_wrecks(wrecks : Array[Wreck]) -> Unit {
  for i = 0; i < wrecks.length(); i = i + 1 {
    wrecks[i].active = false
    wrecks[i].x = 0.0
    wrecks[i].y = 0.0
    wrecks[i].radius = 0.0
  }
}

///|
fn add_drone(
  drones : Array[Drone],
  kind : Int,
  x : Float,
  y : Float,
  level : Int,
) -> Bool {
  for i = 0; i < drones.length(); i = i + 1 {
    if not(drones[i].active) {
      drones[i].active = true
      drones[i].kind = kind
      drones[i].x = x
      drones[i].y = y
      drones[i].vx = randf(-40.0, 40.0)
      drones[i].vy = randf(-40.0, 40.0)
      drones[i].hp = drone_hp(kind, level)
      drones[i].t = randf(0.0, 999.0)
      if kind == 0 {
        drones[i].fire_cd = randf(1.0, 1.8)
      } else if kind == 1 {
        drones[i].fire_cd = randf(0.76, 1.3)
      } else {
        drones[i].fire_cd = randf(1.2, 2.1)
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
fn add_scrap(
  scraps : Array[Scrap],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  value : Int,
) -> Bool {
  for i = 0; i < scraps.length(); i = i + 1 {
    if not(scraps[i].active) {
      scraps[i].active = true
      scraps[i].kind = kind
      scraps[i].x = x
      scraps[i].y = y
      scraps[i].vx = vx
      scraps[i].vy = vy
      scraps[i].value = value
      scraps[i].t = randf(0.0, 10.0)
      scraps[i].magnet = false
      return true
    }
  }
  false
}

///|
fn add_mine(
  mines : Array[Mine],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  r : Float,
) -> Bool {
  for i = 0; i < mines.length(); i = i + 1 {
    if not(mines[i].active) {
      mines[i].active = true
      mines[i].x = x
      mines[i].y = y
      mines[i].vx = vx
      mines[i].vy = vy
      mines[i].radius = r
      mines[i].arm_t = randf(0.7, 1.7)
      mines[i].life = randf(16.0, 26.0)
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
    let spd : Float = randf(60.0, 320.0) * scale
    ignore(
      add_particle(
        parts,
        kind,
        x,
        y,
        @math.cosf(ang) * spd,
        @math.sinf(ang) * spd,
        randf(2.0, 5.4) * scale,
        randf(0.2, 0.8),
      ),
    )
  }
}

///|
fn push_from_center(
  x : Float,
  y : Float,
  cx : Float,
  cy : Float,
  force : Float,
) -> (Float, Float) {
  let dx : Float = x - cx
  let dy : Float = y - cy
  let mut d2 : Float = dx * dx + dy * dy
  if d2 < 1.0 {
    d2 = 1.0
  }
  let inv : Float = force / d2.sqrt()
  (dx * inv, dy * inv)
}

///|
fn spawn_map_wrecks(wrecks : Array[Wreck]) -> Unit {
  clear_wrecks(wrecks)
  for i = 0; i < wrecks.length(); i = i + 1 {
    let mut px : Float = randf(120.0, world_w - 120.0)
    let mut py : Float = randf(120.0, world_h - 120.0)
    let mut rr : Float = randf(24.0, 72.0)

    if dist2(px, py, world_w * 0.5, world_h * 0.5) < 440.0 * 440.0 {
      px = randf(120.0, 520.0)
      py = randf(120.0, world_h - 120.0)
    }
    if dist2(px, py, beacon_x, beacon_y) < 290.0 * 290.0 {
      px = randf(120.0, world_w - 600.0)
      py = randf(360.0, world_h - 120.0)
      rr = randf(22.0, 54.0)
    }

    wrecks[i].active = true
    wrecks[i].x = px
    wrecks[i].y = py
    wrecks[i].radius = rr
  }
}

///|
fn draw_touch_ui(state : Int) -> Unit {
  if state != 1 {
    ignore(())
  } else {
    let pad_x : Int = 24
    let pad_y : Int = sh - 228

    let btn_x : Int = sw - 340
    let btn_y : Int = sh - 238

    @raylib.draw_rectangle(
      pad_x,
      pad_y,
      224,
      204,
      @raylib.Color::new(6, 12, 24, 100),
    )
    @raylib.draw_rectangle_lines(
      pad_x,
      pad_y,
      224,
      204,
      @raylib.Color::new(74, 134, 186, 176),
    )

    @raylib.draw_rectangle(
      pad_x + 14,
      pad_y + 74,
      58,
      58,
      @raylib.Color::new(22, 40, 58, 184),
    )
    @raylib.draw_rectangle(
      pad_x + 152,
      pad_y + 74,
      58,
      58,
      @raylib.Color::new(22, 40, 58, 184),
    )
    @raylib.draw_rectangle(
      pad_x + 84,
      pad_y + 12,
      58,
      58,
      @raylib.Color::new(22, 40, 58, 184),
    )
    @raylib.draw_rectangle(
      pad_x + 84,
      pad_y + 136,
      58,
      58,
      @raylib.Color::new(22, 40, 58, 184),
    )

    @raylib.draw_text(
      "L",
      pad_x + 38,
      pad_y + 86,
      28,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "R",
      pad_x + 176,
      pad_y + 86,
      28,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "U",
      pad_x + 106,
      pad_y + 24,
      28,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "D",
      pad_x + 105,
      pad_y + 148,
      28,
      @raylib.Color::new(214, 236, 252, 246),
    )

    @raylib.draw_rectangle(
      btn_x,
      btn_y,
      304,
      210,
      @raylib.Color::new(8, 12, 22, 106),
    )
    @raylib.draw_rectangle_lines(
      btn_x,
      btn_y,
      304,
      210,
      @raylib.Color::new(104, 158, 210, 174),
    )

    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 12,
      136,
      88,
      @raylib.Color::new(24, 52, 70, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 156,
      btn_y + 12,
      136,
      88,
      @raylib.Color::new(24, 52, 70, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 108,
      136,
      88,
      @raylib.Color::new(24, 52, 70, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 156,
      btn_y + 108,
      136,
      88,
      @raylib.Color::new(24, 52, 70, 196),
    )

    @raylib.draw_text(
      "FIRE",
      btn_x + 42,
      btn_y + 46,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "TRACT",
      btn_x + 178,
      btn_y + 46,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "BOOST",
      btn_x + 36,
      btn_y + 142,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "PULSE",
      btn_x + 180,
      btn_y + 142,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] orbital salvage ops 2026")
  @raylib.set_target_fps(60)

  let player : Player = {
    x: world_w * 0.5,
    y: world_h * 0.5,
    vx: 0.0,
    vy: 0.0,
    face_x: 0.0,
    face_y: -1.0,
    hp: 100.0,
    energy: 100.0,
    heat: 0.0,
    inv_t: 0.0,
    fire_cd: 0.0,
    pulse_cd: 0.0,
    boost_cd: 0.0,
    boost_t: 0.0,
    cargo: 0,
    deposited: 0,
    score: 0,
    combo: 0,
    best_combo: 0,
    tractor_on: false,
  }

  let drones : Array[Drone] = Array::makei(max_drones, fn(_i) {
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
      radius: 0.0,
      life: 0.0,
    }
  })

  let scraps : Array[Scrap] = Array::makei(max_scrap, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      value: 0,
      t: 0.0,
      magnet: false,
    }
  })

  let mines : Array[Mine] = Array::makei(max_mines, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      arm_t: 0.0,
      life: 0.0,
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

  let wrecks : Array[Wreck] = Array::makei(max_wrecks, fn(_i) {
    { active: false, x: 0.0, y: 0.0, radius: 0.0 }
  })

  let boss : Boss = {
    active: false,
    x: world_w * 0.5,
    y: 380.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    max_hp: 0.0,
    fire_cd: 0.0,
    spawn_cd: 0.0,
    t: 0.0,
  }

  let mut state : Int = 0
  let mut cam_x : Float = 0.0
  let mut cam_y : Float = 0.0
  let mut timer : Float = 420.0

  let mut drone_cd : Float = 0.8
  let mut mine_cd : Float = 2.2
  let mut scrap_cd : Float = 2.9
  let mut deposit_cd : Float = 0.04

  let mut msg : String = "Collect salvage and deposit at extraction beacon"
  let mut msg_t : Float = 3.2

  let mut stars_t : Float = 0.0
  let mut boss_seen : Bool = false
  let mut boss_defeated : Bool = false

  let reset_run = fn() {
    player.x = world_w * 0.5
    player.y = world_h * 0.5
    player.vx = 0.0
    player.vy = 0.0
    player.face_x = 0.0
    player.face_y = -1.0
    player.hp = 100.0
    player.energy = 100.0
    player.heat = 0.0
    player.inv_t = 0.0
    player.fire_cd = 0.0
    player.pulse_cd = 0.0
    player.boost_cd = 0.0
    player.boost_t = 0.0
    player.cargo = 0
    player.deposited = 0
    player.score = 0
    player.combo = 0
    player.best_combo = 0
    player.tractor_on = false

    timer = 420.0

    drone_cd = 0.8
    mine_cd = 2.2
    scrap_cd = 2.9
    deposit_cd = 0.04

    msg = "Find salvage fields"
    msg_t = 1.9

    boss_seen = false
    boss_defeated = false
    boss.active = false
    boss.x = world_w * 0.5
    boss.y = 380.0
    boss.vx = 0.0
    boss.vy = 0.0
    boss.hp = 0.0
    boss.max_hp = 0.0
    boss.fire_cd = 0.0
    boss.spawn_cd = 0.0
    boss.t = 0.0

    clear_drones(drones)
    clear_bullets(bullets)
    clear_scrap(scraps)
    clear_mines(mines)
    clear_particles(particles)
    spawn_map_wrecks(wrecks)

    for i = 0; i < 44; i = i + 1 {
      let sx = randf(100.0, world_w - 100.0)
      let sy = randf(100.0, world_h - 100.0)
      if dist2(sx, sy, player.x, player.y) > 220.0 * 220.0 &&
        dist2(sx, sy, beacon_x, beacon_y) > 230.0 * 230.0 {
        ignore(
          add_scrap(
            scraps,
            @raylib.get_random_value(0, 2),
            sx,
            sy,
            randf(-24.0, 24.0),
            randf(-24.0, 24.0),
            1 + @raylib.get_random_value(0, 2),
          ),
        )
      }
    }

    cam_x = clampf(
      player.x - Float::from_int(sw) * 0.5,
      0.0,
      world_w - Float::from_int(sw),
    )
    cam_y = clampf(
      player.y - Float::from_int(sh) * 0.5,
      0.0,
      world_h - Float::from_int(sh),
    )
  }

  let on_player_hit = fn(dmg : Float, text : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut dealt : Float = dmg
      if player.boost_t > 0.0 {
        dealt = dealt * 0.78
      }
      player.hp = player.hp - dealt
      if player.hp < 0.0 {
        player.hp = 0.0
      }
      player.inv_t = 0.4
      player.combo = 0
      msg = text
      msg_t = 0.74
      burst(particles, player.x, player.y, 18, 0.24, 2)
    }
  }

  let pop_mine = fn(m : Mine, team : Int) {
    if not(m.active) {
      ignore(())
    } else {
      m.active = false
      burst(particles, m.x, m.y, 26, 0.28, 2)

      for bi = 0; bi < bullets.length(); bi = bi + 1 {
        if not(bullets[bi].active) {
          continue
        }
        if dist2(bullets[bi].x, bullets[bi].y, m.x, m.y) <=
          (m.radius + 52.0) * (m.radius + 52.0) {
          bullets[bi].active = false
        }
      }

      for di = 0; di < drones.length(); di = di + 1 {
        if not(drones[di].active) {
          continue
        }
        if dist2(drones[di].x, drones[di].y, m.x, m.y) <=
          (m.radius + drone_radius(drones[di].kind) + 40.0) *
          (m.radius + drone_radius(drones[di].kind) + 40.0) {
          drones[di].hp = drones[di].hp - 50.0
          let (knx, kny) = push_from_center(
            drones[di].x,
            drones[di].y,
            m.x,
            m.y,
            280.0,
          )
          drones[di].vx = drones[di].vx + knx
          drones[di].vy = drones[di].vy + kny
          if drones[di].hp <= 0.0 {
            drones[di].active = false
            ignore(
              add_scrap(
                scraps,
                @raylib.get_random_value(0, 2),
                drones[di].x,
                drones[di].y,
                randf(-80.0, 80.0),
                randf(-80.0, 80.0),
                2 + @raylib.get_random_value(0, 2),
              ),
            )
            if team == 1 {
              player.score = player.score + 52
              player.combo = player.combo + 1
            }
          }
        }
      }

      if dist2(player.x, player.y, m.x, m.y) <=
        (m.radius + player_radius + 48.0) * (m.radius + player_radius + 48.0) {
        on_player_hit(20.0, "Mine blast")
        let (pkx, pky) = push_from_center(player.x, player.y, m.x, m.y, 440.0)
        player.vx = player.vx + pkx
        player.vy = player.vy + pky
      }

      if boss.active &&
        dist2(boss.x, boss.y, m.x, m.y) <=
        (58.0 + m.radius + 46.0) * (58.0 + m.radius + 46.0) {
        boss.hp = boss.hp - 70.0
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

    stars_t = stars_t + dt * 20.0
    while stars_t >= 10000.0 {
      stars_t = stars_t - 10000.0
    }

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
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      let elapsed : Float = Float::from_int(420) - timer
      let level : Int = player.deposited / 14 + elapsed.to_int() / 42 + 1

      player.inv_t = player.inv_t - dt
      if player.inv_t < 0.0 {
        player.inv_t = 0.0
      }

      player.fire_cd = player.fire_cd - dt
      if player.fire_cd < 0.0 {
        player.fire_cd = 0.0
      }

      player.pulse_cd = player.pulse_cd - dt
      if player.pulse_cd < 0.0 {
        player.pulse_cd = 0.0
      }

      player.boost_cd = player.boost_cd - dt
      if player.boost_cd < 0.0 {
        player.boost_cd = 0.0
      }

      player.boost_t = player.boost_t - dt
      if player.boost_t < 0.0 {
        player.boost_t = 0.0
      }

      player.heat = player.heat - dt * 36.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      player.energy = player.energy + dt * 9.0
      if player.energy > 100.0 {
        player.energy = 100.0
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
      let mut tractor_hold : Bool = @raylib.is_key_down(@raylib.KeyK)
      let mut boost_hold : Bool = @raylib.is_key_down(@raylib.KeyRightShift)
      let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_x : Int = 24
      let pad_y : Int = sh - 228
      let btn_x : Int = sw - 340
      let btn_y : Int = sh - 238

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x + 14, pad_y + 74, 58, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 152, pad_y + 74, 58, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 12, 58, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 136, 58, 58) {
          move_d = true
        }

        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 12, 136, 88) {
          fire_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 156, btn_y + 12, 136, 88) {
          tractor_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 108, 136, 88) {
          boost_hold = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 156, btn_y + 108, 136, 88) {
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

      if inp_x * inp_x + inp_y * inp_y > 0.01 {
        let inv : Float = 1.0 / (inp_x * inp_x + inp_y * inp_y).sqrt()
        player.face_x = inp_x * inv
        player.face_y = inp_y * inv
      }

      let mut accel : Float = 720.0
      if player.boost_t > 0.0 {
        accel = 1220.0
      }

      if boost_hold && player.boost_cd <= 0.0 && player.energy >= 16.0 {
        player.boost_t = 0.36
        player.boost_cd = 1.46
        player.energy = player.energy - 16.0
        burst(particles, player.x, player.y, 14, 0.18, 0)
      }

      player.vx = player.vx + inp_x * accel * dt
      player.vy = player.vy + inp_y * accel * dt

      let drag : Float = if player.boost_t > 0.0 { 1.9 } else { 3.6 }
      player.vx = player.vx * (1.0 - drag * dt)
      player.vy = player.vy * (1.0 - drag * dt)

      let max_spd : Float = if player.boost_t > 0.0 { 460.0 } else { 320.0 }
      let spd2 : Float = player.vx * player.vx + player.vy * player.vy
      if spd2 > max_spd * max_spd {
        let invs : Float = max_spd / spd2.sqrt()
        player.vx = player.vx * invs
        player.vy = player.vy * invs
      }

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      player.x = clampf(player.x, 30.0, world_w - 30.0)
      player.y = clampf(player.y, 30.0, world_h - 30.0)

      // Wreck collisions
      for i = 0; i < wrecks.length(); i = i + 1 {
        if not(wrecks[i].active) {
          continue
        }

        let rr : Float = wrecks[i].radius + player_radius
        let d2 : Float = dist2(player.x, player.y, wrecks[i].x, wrecks[i].y)
        if d2 < rr * rr {
          let mut d : Float = d2.sqrt()
          let mut nx : Float = 0.0
          let mut ny : Float = -1.0
          if d > 0.001 {
            nx = (player.x - wrecks[i].x) / d
            ny = (player.y - wrecks[i].y) / d
          } else {
            d = 0.001
          }

          let push : Float = rr - d
          player.x = player.x + nx * push
          player.y = player.y + ny * push

          let vn : Float = player.vx * nx + player.vy * ny
          if vn < 0.0 {
            player.vx = player.vx - vn * nx * 1.4
            player.vy = player.vy - vn * ny * 1.4
          }

          on_player_hit(5.0, "Hull scrape")
        }
      }

      // Tractor beam
      player.tractor_on = false
      if tractor_hold && player.energy > 0.0 {
        player.tractor_on = true
        player.energy = player.energy - dt * 16.0
        if player.energy < 0.0 {
          player.energy = 0.0
          player.tractor_on = false
        }
      }

      if player.tractor_on {
        for i = 0; i < scraps.length(); i = i + 1 {
          if not(scraps[i].active) {
            continue
          }

          let dx : Float = player.x - scraps[i].x
          let dy : Float = player.y - scraps[i].y
          let d2 : Float = dx * dx + dy * dy

          scraps[i].magnet = false
          if d2 <= 320.0 * 320.0 {
            scraps[i].magnet = true
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let inv : Float = 1.0 / d
            let pull : Float = clampf(340.0 - d * 0.7, 60.0, 340.0)
            scraps[i].vx = scraps[i].vx + dx * inv * pull * dt
            scraps[i].vy = scraps[i].vy + dy * inv * pull * dt
          }
        }
      }

      if pulse_press && player.pulse_cd <= 0.0 && player.energy >= 42.0 {
        player.pulse_cd = 6.4
        player.energy = player.energy - 42.0
        msg = "EMP pulse"
        msg_t = 0.64

        burst(particles, player.x, player.y, 84, 0.36, 3)

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            bullets[i].team == 2 &&
            dist2(player.x, player.y, bullets[i].x, bullets[i].y) <=
            300.0 * 300.0 {
            bullets[i].active = false
          }
        }

        for i = 0; i < drones.length(); i = i + 1 {
          if not(drones[i].active) {
            continue
          }
          if dist2(player.x, player.y, drones[i].x, drones[i].y) <=
            340.0 * 340.0 {
            drones[i].hp = drones[i].hp - 42.0
            let (kx, ky) = push_from_center(
              drones[i].x,
              drones[i].y,
              player.x,
              player.y,
              420.0,
            )
            drones[i].vx = drones[i].vx + kx
            drones[i].vy = drones[i].vy + ky
          }
        }

        for i = 0; i < mines.length(); i = i + 1 {
          if not(mines[i].active) {
            continue
          }
          if dist2(player.x, player.y, mines[i].x, mines[i].y) <= 280.0 * 280.0 {
            pop_mine(mines[i], 1)
          }
        }

        if boss.active &&
          dist2(player.x, player.y, boss.x, boss.y) <= 360.0 * 360.0 {
          boss.hp = boss.hp - 64.0
        }
      }

      if fire_hold && player.fire_cd <= 0.0 && player.heat <= 92.0 {
        let mut aim_x : Float = player.face_x
        let mut aim_y : Float = player.face_y

        let mut best_d2 : Float = 999999999.0
        for i = 0; i < drones.length(); i = i + 1 {
          if not(drones[i].active) {
            continue
          }
          let d2 : Float = dist2(player.x, player.y, drones[i].x, drones[i].y)
          if d2 < best_d2 {
            best_d2 = d2
            let dx : Float = drones[i].x - player.x
            let dy : Float = drones[i].y - player.y
            let mut l2 : Float = dx * dx + dy * dy
            if l2 < 1.0 {
              l2 = 1.0
            }
            let inv : Float = 1.0 / l2.sqrt()
            aim_x = dx * inv
            aim_y = dy * inv
          }
        }

        if boss.active {
          let d2 : Float = dist2(player.x, player.y, boss.x, boss.y)
          if d2 < best_d2 {
            best_d2 = d2
            let dx : Float = boss.x - player.x
            let dy : Float = boss.y - player.y
            let mut l2 : Float = dx * dx + dy * dy
            if l2 < 1.0 {
              l2 = 1.0
            }
            let inv : Float = 1.0 / l2.sqrt()
            aim_x = dx * inv
            aim_y = dy * inv
          }
        }

        player.face_x = aim_x
        player.face_y = aim_y

        player.fire_cd = clampf(
          0.12 - Float::from_int(level) * 0.002,
          0.072,
          0.12,
        )
        player.heat = player.heat + 7.0

        ignore(
          add_bullet(
            bullets,
            1,
            0,
            player.x + aim_x * 22.0,
            player.y + aim_y * 22.0,
            aim_x * 730.0,
            aim_y * 730.0,
            16.0,
            4.0,
            1.2,
          ),
        )

        if level >= 5 {
          let sx : Float = -aim_y
          let sy : Float = aim_x
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + aim_x * 20.0 + sx * 10.0,
              player.y + aim_y * 20.0 + sy * 10.0,
              (aim_x + sx * 0.1) * 700.0,
              (aim_y + sy * 0.1) * 700.0,
              12.0,
              3.0,
              1.15,
            ),
          )
          ignore(
            add_bullet(
              bullets,
              1,
              0,
              player.x + aim_x * 20.0 - sx * 10.0,
              player.y + aim_y * 20.0 - sy * 10.0,
              (aim_x - sx * 0.1) * 700.0,
              (aim_y - sy * 0.1) * 700.0,
              12.0,
              3.0,
              1.15,
            ),
          )
        }

        burst(
          particles,
          player.x + aim_x * 20.0,
          player.y + aim_y * 20.0,
          8,
          0.14,
          1,
        )
      }

      if dist2(player.x, player.y, beacon_x, beacon_y) <= 78.0 * 78.0 &&
        player.cargo > 0 {
        deposit_cd = deposit_cd - dt
        if deposit_cd <= 0.0 {
          deposit_cd = 0.038
          player.cargo = player.cargo - 1
          player.deposited = player.deposited + 1
          player.score = player.score + 30 + player.combo
          player.energy = clampf(player.energy + 0.8, 0.0, 100.0)

          if player.deposited % 10 == 0 {
            msg = "Salvage delivered \{player.deposited}/\{target_salvage}"
            msg_t = 0.7
          }
        }
      } else {
        deposit_cd = 0.038
      }

      // Dynamic spawning.
      drone_cd = drone_cd - dt
      if drone_cd <= 0.0 {
        let mut kind : Int = 0
        let roll = @raylib.get_random_value(0, 99)
        if level >= 3 && roll > 48 {
          kind = 1
        }
        if level >= 6 && roll > 78 {
          kind = 2
        }

        let edge = @raylib.get_random_value(0, 3)
        let mut sx : Float = 0.0
        let mut sy : Float = 0.0
        if edge == 0 {
          sx = randf(30.0, world_w - 30.0)
          sy = -40.0
        } else if edge == 1 {
          sx = world_w + 40.0
          sy = randf(30.0, world_h - 30.0)
        } else if edge == 2 {
          sx = randf(30.0, world_w - 30.0)
          sy = world_h + 40.0
        } else {
          sx = -40.0
          sy = randf(30.0, world_h - 30.0)
        }

        ignore(add_drone(drones, kind, sx, sy, level))

        let base_cd : Float = 1.24 - Float::from_int(level) * 0.06
        drone_cd = clampf(base_cd + randf(-0.2, 0.28), 0.34, 1.24)
      }

      mine_cd = mine_cd - dt
      if mine_cd <= 0.0 {
        mine_cd = clampf(
          3.1 - Float::from_int(level) * 0.12 + randf(-0.2, 0.4),
          1.0,
          3.3,
        )
        let px = randf(40.0, world_w - 40.0)
        let py = randf(40.0, world_h - 40.0)
        if dist2(px, py, player.x, player.y) > 300.0 * 300.0 &&
          dist2(px, py, beacon_x, beacon_y) > 200.0 * 200.0 {
          ignore(
            add_mine(
              mines,
              px,
              py,
              randf(-32.0, 32.0),
              randf(-32.0, 32.0),
              randf(16.0, 30.0),
            ),
          )
        }
      }

      scrap_cd = scrap_cd - dt
      if scrap_cd <= 0.0 {
        scrap_cd = randf(2.6, 5.6)
        ignore(
          add_scrap(
            scraps,
            @raylib.get_random_value(0, 2),
            randf(60.0, world_w - 60.0),
            randf(60.0, world_h - 60.0),
            randf(-20.0, 20.0),
            randf(-20.0, 20.0),
            1 + @raylib.get_random_value(0, 2),
          ),
        )
      }

      if not(boss_seen) && player.deposited >= 80 {
        boss_seen = true
        boss.active = true
        boss.x = world_w * 0.5
        boss.y = 220.0
        boss.vx = 0.0
        boss.vy = 0.0
        boss.max_hp = 2200.0
        boss.hp = boss.max_hp
        boss.fire_cd = 1.2
        boss.spawn_cd = 2.6
        boss.t = 0.0
        msg = "Boss incoming: Null Reclaimer"
        msg_t = 2.1
      }

      // Update mines.
      for i = 0; i < mines.length(); i = i + 1 {
        if not(mines[i].active) {
          continue
        }

        mines[i].life = mines[i].life - dt
        mines[i].arm_t = mines[i].arm_t - dt

        mines[i].x = mines[i].x + mines[i].vx * dt
        mines[i].y = mines[i].y + mines[i].vy * dt
        mines[i].vx = mines[i].vx * (1.0 - dt * 0.8)
        mines[i].vy = mines[i].vy * (1.0 - dt * 0.8)

        if mines[i].x < mines[i].radius {
          mines[i].x = mines[i].radius
          mines[i].vx = absf(mines[i].vx)
        }
        if mines[i].x > world_w - mines[i].radius {
          mines[i].x = world_w - mines[i].radius
          mines[i].vx = -absf(mines[i].vx)
        }
        if mines[i].y < mines[i].radius {
          mines[i].y = mines[i].radius
          mines[i].vy = absf(mines[i].vy)
        }
        if mines[i].y > world_h - mines[i].radius {
          mines[i].y = world_h - mines[i].radius
          mines[i].vy = -absf(mines[i].vy)
        }

        if mines[i].life <= 0.0 {
          mines[i].active = false
          continue
        }

        if mines[i].arm_t <= 0.0 {
          if dist2(mines[i].x, mines[i].y, player.x, player.y) <=
            (mines[i].radius + 26.0) * (mines[i].radius + 26.0) {
            pop_mine(mines[i], 2)
            continue
          }

          let mut detonated : Bool = false
          for di = 0; di < drones.length(); di = di + 1 {
            if not(drones[di].active) {
              continue
            }
            if dist2(mines[i].x, mines[i].y, drones[di].x, drones[di].y) <=
              (mines[i].radius + drone_radius(drones[di].kind)) *
              (mines[i].radius + drone_radius(drones[di].kind)) {
              pop_mine(mines[i], 0)
              detonated = true
              break
            }
          }
          if detonated {
            continue
          }

          if boss.active &&
            dist2(mines[i].x, mines[i].y, boss.x, boss.y) <=
            (mines[i].radius + 54.0) * (mines[i].radius + 54.0) {
            pop_mine(mines[i], 0)
            continue
          }
        }
      }

      // Update drones.
      for i = 0; i < drones.length(); i = i + 1 {
        if not(drones[i].active) {
          continue
        }

        drones[i].t = drones[i].t + dt
        drones[i].fire_cd = drones[i].fire_cd - dt

        let tx : Float = player.x - drones[i].x
        let ty : Float = player.y - drones[i].y
        let mut inv : Float = 0.0
        let l2 : Float = tx * tx + ty * ty
        if l2 > 0.01 {
          inv = 1.0 / l2.sqrt()
        }

        if drones[i].kind == 0 {
          let acc : Float = 160.0 + Float::from_int(level) * 8.0
          drones[i].vx = drones[i].vx + tx * inv * acc * dt
          drones[i].vy = drones[i].vy + ty * inv * acc * dt
        } else if drones[i].kind == 1 {
          let ideal : Float = 280.0
          let mut dist : Float = 0.0
          if l2 > 0.01 {
            dist = l2.sqrt()
          }
          let acc : Float = 140.0 + Float::from_int(level) * 7.0
          let err : Float = dist - ideal
          drones[i].vx = drones[i].vx +
            tx * inv * err * 0.7 * dt +
            @math.sinf(drones[i].t * 2.4) * 18.0 * dt
          drones[i].vy = drones[i].vy +
            ty * inv * err * 0.7 * dt +
            @math.cosf(drones[i].t * 2.1) * 18.0 * dt
          ignore(acc)
        } else {
          let acc : Float = 90.0 + Float::from_int(level) * 4.0
          drones[i].vx = drones[i].vx +
            tx * inv * acc * dt +
            @math.sinf(drones[i].t) * 14.0 * dt
          drones[i].vy = drones[i].vy +
            ty * inv * acc * dt +
            @math.cosf(drones[i].t * 1.2) * 14.0 * dt
        }

        // Simple avoidance from nearest wreck.
        for wi = 0; wi < wrecks.length(); wi = wi + 1 {
          if not(wrecks[wi].active) {
            continue
          }
          let rr = drone_radius(drones[i].kind) + wrecks[wi].radius + 20.0
          let d2 = dist2(drones[i].x, drones[i].y, wrecks[wi].x, wrecks[wi].y)
          if d2 < rr * rr {
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let nx : Float = (drones[i].x - wrecks[wi].x) / d
            let ny : Float = (drones[i].y - wrecks[wi].y) / d
            drones[i].vx = drones[i].vx + nx * 120.0 * dt
            drones[i].vy = drones[i].vy + ny * 120.0 * dt
          }
        }

        let maxv : Float = if drones[i].kind == 2 {
          180.0
        } else {
          240.0 + Float::from_int(level) * 5.0
        }
        let v2 : Float = drones[i].vx * drones[i].vx +
          drones[i].vy * drones[i].vy
        if v2 > maxv * maxv {
          let invs : Float = maxv / v2.sqrt()
          drones[i].vx = drones[i].vx * invs
          drones[i].vy = drones[i].vy * invs
        }

        drones[i].x = drones[i].x + drones[i].vx * dt
        drones[i].y = drones[i].y + drones[i].vy * dt

        drones[i].x = clampf(drones[i].x, 10.0, world_w - 10.0)
        drones[i].y = clampf(drones[i].y, 10.0, world_h - 10.0)

        if drones[i].fire_cd <= 0.0 {
          if drones[i].kind == 0 {
            drones[i].fire_cd = randf(1.2, 1.9)
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 280.0,
                ty * inv * 280.0,
                9.0,
                5.0,
                3.2,
              ),
            )
          } else if drones[i].kind == 1 {
            drones[i].fire_cd = randf(0.92, 1.4)
            let sx : Float = -ty * inv
            let sy : Float = tx * inv
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 280.0 + sx * 70.0,
                ty * inv * 280.0 + sy * 70.0,
                8.0,
                4.0,
                3.0,
              ),
            )
            ignore(
              add_bullet(
                bullets,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 280.0 - sx * 70.0,
                ty * inv * 280.0 - sy * 70.0,
                8.0,
                4.0,
                3.0,
              ),
            )
          } else {
            drones[i].fire_cd = randf(1.4, 2.2)
            ignore(
              add_bullet(
                bullets,
                2,
                1,
                drones[i].x,
                drones[i].y,
                tx * inv * 230.0,
                ty * inv * 230.0,
                14.0,
                7.0,
                3.5,
              ),
            )
          }
        }

        if dist2(drones[i].x, drones[i].y, player.x, player.y) <=
          (drone_radius(drones[i].kind) + player_radius) *
          (drone_radius(drones[i].kind) + player_radius) {
          on_player_hit(
            8.0 + Float::from_int(drones[i].kind) * 2.6,
            "Drone collision",
          )
          let (kx, ky) = push_from_center(
            player.x,
            player.y,
            drones[i].x,
            drones[i].y,
            280.0,
          )
          player.vx = player.vx + kx
          player.vy = player.vy + ky
          drones[i].vx = drones[i].vx - kx
          drones[i].vy = drones[i].vy - ky
        }
      }

      if boss.active {
        boss.t = boss.t + dt
        boss.fire_cd = boss.fire_cd - dt
        boss.spawn_cd = boss.spawn_cd - dt

        let bx_goal : Float = world_w * 0.5 + @math.sinf(boss.t * 0.55) * 760.0
        let by_goal : Float = 320.0 + @math.cosf(boss.t * 0.38) * 170.0

        boss.vx = boss.vx + clampf(bx_goal - boss.x, -260.0, 260.0) * dt * 1.8
        boss.vy = boss.vy + clampf(by_goal - boss.y, -190.0, 190.0) * dt * 1.8
        boss.vx = boss.vx * (1.0 - dt * 1.8)
        boss.vy = boss.vy * (1.0 - dt * 1.8)

        boss.x = clampf(boss.x + boss.vx * dt, 90.0, world_w - 90.0)
        boss.y = clampf(boss.y + boss.vy * dt, 110.0, world_h - 380.0)

        if boss.fire_cd <= 0.0 {
          boss.fire_cd = randf(0.44, 0.86)
          let tx : Float = player.x - boss.x
          let ty : Float = player.y - boss.y
          let mut inv : Float = 0.0
          let l2 : Float = tx * tx + ty * ty
          if l2 > 0.01 {
            inv = 1.0 / l2.sqrt()
          }
          let sx : Float = -ty * inv
          let sy : Float = tx * inv

          for k = -2; k <= 2; k = k + 1 {
            let drift : Float = Float::from_int(k) * 70.0
            ignore(
              add_bullet(
                bullets,
                2,
                1,
                boss.x,
                boss.y,
                tx * inv * 300.0 + sx * drift,
                ty * inv * 300.0 + sy * drift,
                10.0,
                6.0,
                4.2,
              ),
            )
          }
        }

        if boss.spawn_cd <= 0.0 {
          boss.spawn_cd = randf(2.2, 3.4)
          ignore(
            add_drone(
              drones,
              1 + @raylib.get_random_value(0, 1),
              boss.x + randf(-140.0, 140.0),
              boss.y + randf(-80.0, 80.0),
              level + 4,
            ),
          )
        }

        if dist2(player.x, player.y, boss.x, boss.y) <=
          (player_radius + 58.0) * (player_radius + 58.0) {
          on_player_hit(24.0, "Boss collision")
          let (pkx, pky) = push_from_center(
            player.x,
            player.y,
            boss.x,
            boss.y,
            460.0,
          )
          player.vx = player.vx + pkx
          player.vy = player.vy + pky
        }

        if boss.hp <= 0.0 {
          boss.active = false
          boss_defeated = true
          player.score = player.score + 2200
          msg = "Null Reclaimer destroyed"
          msg_t = 1.8
          burst(particles, boss.x, boss.y, 180, 0.48, 3)
        }
      }

      // Update bullets and resolve collisions.
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

        if bullets[i].x < -80.0 ||
          bullets[i].x > world_w + 80.0 ||
          bullets[i].y < -80.0 ||
          bullets[i].y > world_h + 80.0 {
          bullets[i].active = false
          continue
        }

        // Wreck block.
        let mut blocked : Bool = false
        for wi = 0; wi < wrecks.length(); wi = wi + 1 {
          if not(wrecks[wi].active) {
            continue
          }
          let rr : Float = bullets[i].radius + wrecks[wi].radius
          if dist2(bullets[i].x, bullets[i].y, wrecks[wi].x, wrecks[wi].y) <=
            rr * rr {
            bullets[i].active = false
            blocked = true
            break
          }
        }
        if blocked {
          continue
        }

        if bullets[i].team == 1 {
          let mut hit_done : Bool = false

          for di = 0; di < drones.length(); di = di + 1 {
            if hit_done {
              continue
            }
            if not(drones[di].active) {
              continue
            }

            let rr : Float = bullets[i].radius + drone_radius(drones[di].kind)
            if dist2(bullets[i].x, bullets[i].y, drones[di].x, drones[di].y) <=
              rr * rr {
              drones[di].hp = drones[di].hp - bullets[i].dmg
              bullets[i].active = false
              hit_done = true

              burst(particles, drones[di].x, drones[di].y, 8, 0.12, 1)

              if drones[di].hp <= 0.0 {
                let reward = 72 + drones[di].kind * 28 + player.combo * 3
                player.score = player.score + reward
                player.combo = player.combo + 1
                if player.combo > player.best_combo {
                  player.best_combo = player.combo
                }

                if @raylib.get_random_value(0, 99) < 66 {
                  ignore(
                    add_scrap(
                      scraps,
                      @raylib.get_random_value(0, 2),
                      drones[di].x,
                      drones[di].y,
                      randf(-96.0, 96.0),
                      randf(-96.0, 96.0),
                      2 + @raylib.get_random_value(0, 3),
                    ),
                  )
                }

                drones[di].active = false
                burst(particles, drones[di].x, drones[di].y, 24, 0.22, 0)
              }
            }
          }

          if bullets[i].active && boss.active {
            let rr : Float = bullets[i].radius + 58.0
            if dist2(bullets[i].x, bullets[i].y, boss.x, boss.y) <= rr * rr {
              bullets[i].active = false
              boss.hp = boss.hp - bullets[i].dmg
              player.score = player.score + 12
              burst(particles, bullets[i].x, bullets[i].y, 6, 0.11, 3)
            }
          }

          if bullets[i].active {
            for mi = 0; mi < mines.length(); mi = mi + 1 {
              if not(mines[mi].active) {
                continue
              }
              let rr : Float = bullets[i].radius + mines[mi].radius
              if dist2(bullets[i].x, bullets[i].y, mines[mi].x, mines[mi].y) <=
                rr * rr {
                bullets[i].active = false
                pop_mine(mines[mi], 1)
                break
              }
            }
          }
        } else {
          let rr : Float = bullets[i].radius + player_radius
          if dist2(bullets[i].x, bullets[i].y, player.x, player.y) <= rr * rr {
            on_player_hit(bullets[i].dmg, "Hit by enemy fire")
            bullets[i].active = false
          }
        }
      }

      // Update scrap.
      for i = 0; i < scraps.length(); i = i + 1 {
        if not(scraps[i].active) {
          continue
        }

        scraps[i].t = scraps[i].t + dt

        scraps[i].x = scraps[i].x + scraps[i].vx * dt
        scraps[i].y = scraps[i].y + scraps[i].vy * dt
        scraps[i].vx = scraps[i].vx * (1.0 - dt * 1.5)
        scraps[i].vy = scraps[i].vy * (1.0 - dt * 1.5)

        if scraps[i].x < 20.0 {
          scraps[i].x = 20.0
          scraps[i].vx = absf(scraps[i].vx)
        }
        if scraps[i].x > world_w - 20.0 {
          scraps[i].x = world_w - 20.0
          scraps[i].vx = -absf(scraps[i].vx)
        }
        if scraps[i].y < 20.0 {
          scraps[i].y = 20.0
          scraps[i].vy = absf(scraps[i].vy)
        }
        if scraps[i].y > world_h - 20.0 {
          scraps[i].y = world_h - 20.0
          scraps[i].vy = -absf(scraps[i].vy)
        }

        if dist2(player.x, player.y, scraps[i].x, scraps[i].y) <=
          (player_radius + 12.0) * (player_radius + 12.0) {
          player.cargo = player.cargo + scraps[i].value
          player.score = player.score + scraps[i].value * 10
          scraps[i].active = false
          burst(particles, player.x, player.y, 10, 0.14, 0)
        }
      }

      // Update particles.
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

        particles[i].vx = particles[i].vx * (1.0 - dt * 2.0)
        particles[i].vy = particles[i].vy * (1.0 - dt * 2.0)
      }

      // Win/lose checks.
      if timer <= 0.0 {
        state = 3
        msg = "Time expired"
        msg_t = 2.2
      }

      if player.hp <= 0.0 {
        state = 3
        msg = "Ship destroyed"
        msg_t = 2.2
      }

      if player.deposited >= target_salvage {
        if not(boss_seen) || boss_defeated {
          state = 2
          msg = "Mission completed"
          msg_t = 2.4
        } else if boss.active {
          msg = "Destroy Null Reclaimer to secure route"
          msg_t = 0.4
        } else {
          state = 2
          msg = "Mission completed"
          msg_t = 2.4
        }
      }

      // Camera.
      cam_x = clampf(
        player.x - Float::from_int(sw) * 0.5,
        0.0,
        world_w - Float::from_int(sw),
      )
      cam_y = clampf(
        player.y - Float::from_int(sh) * 0.5,
        0.0,
        world_h - Float::from_int(sh),
      )
    } else if @raylib.is_key_pressed(@raylib.KeyR) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      pressed {
      state = 1
      reset_run()
    }

    // Render.
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(4, 8, 16, 255))

    // Space starfield.
    for i = 0; i < 240; i = i + 1 {
      let fi : Float = Float::from_int(i)
      let sx = ((fi * 193.0 + stars_t * (0.2 + Float::from_int(i % 5) * 0.12)) %
      Float::from_int(sw)).to_int()
      let sy = ((fi * 127.0 + stars_t * (0.14 + Float::from_int(i % 7) * 0.07)) %
      Float::from_int(sh)).to_int()
      let br : Int = 88 + i % 12 * 12
      @raylib.draw_circle(
        sx,
        sy,
        if i % 3 == 0 {
          1.8
        } else {
          1.2
        },
        @raylib.Color::new(br, br + 12, br + 36, 220),
      )
    }

    // Sector border.
    @raylib.draw_rectangle(
      (-cam_x).to_int(),
      (-cam_y).to_int(),
      world_w.to_int(),
      world_h.to_int(),
      @raylib.Color::new(8, 16, 30, 110),
    )

    @raylib.draw_rectangle_lines(
      (-cam_x).to_int(),
      (-cam_y).to_int(),
      world_w.to_int(),
      world_h.to_int(),
      @raylib.Color::new(62, 96, 132, 130),
    )

    // Beacon.
    @raylib.draw_circle(
      (beacon_x - cam_x).to_int(),
      (beacon_y - cam_y).to_int(),
      74.0,
      @raylib.Color::new(32, 130, 176, 66),
    )
    @raylib.draw_circle_lines(
      (beacon_x - cam_x).to_int(),
      (beacon_y - cam_y).to_int(),
      74.0,
      @raylib.Color::new(118, 210, 252, 216),
    )
    @raylib.draw_circle(
      (beacon_x - cam_x).to_int(),
      (beacon_y - cam_y).to_int(),
      24.0,
      @raylib.Color::new(156, 242, 252, 210),
    )

    // Wrecks.
    for i = 0; i < wrecks.length(); i = i + 1 {
      if not(wrecks[i].active) {
        continue
      }
      let wx = (wrecks[i].x - cam_x).to_int()
      let wy = (wrecks[i].y - cam_y).to_int()
      @raylib.draw_circle(
        wx,
        wy,
        wrecks[i].radius,
        @raylib.Color::new(44, 52, 66, 230),
      )
      @raylib.draw_circle_lines(
        wx,
        wy,
        wrecks[i].radius,
        @raylib.Color::new(112, 132, 160, 190),
      )
      @raylib.draw_circle(
        wx,
        wy,
        wrecks[i].radius * 0.35,
        @raylib.Color::new(30, 36, 48, 210),
      )
    }

    // Mines.
    for i = 0; i < mines.length(); i = i + 1 {
      if not(mines[i].active) {
        continue
      }
      let mx = (mines[i].x - cam_x).to_int()
      let my = (mines[i].y - cam_y).to_int()

      let armed : Bool = mines[i].arm_t <= 0.0
      let col = if armed {
        @raylib.Color::new(214, 88, 94, 232)
      } else {
        @raylib.Color::new(132, 132, 154, 216)
      }
      let mine_top : Int = (mines[i].y - cam_y - mines[i].radius - 7.0).to_int()
      let mine_bottom : Int = (mines[i].y - cam_y + mines[i].radius + 7.0).to_int()
      let mine_left : Int = (mines[i].x - cam_x - mines[i].radius - 7.0).to_int()
      let mine_right : Int = (mines[i].x - cam_x + mines[i].radius + 7.0).to_int()

      @raylib.draw_circle(mx, my, mines[i].radius, col)
      @raylib.draw_circle_lines(
        mx,
        my,
        mines[i].radius + 5.0,
        @raylib.Color::new(242, 198, 198, 170),
      )
      @raylib.draw_line(
        mx,
        mine_top,
        mx,
        mine_bottom,
        @raylib.Color::new(244, 208, 186, 200),
      )
      @raylib.draw_line(
        mine_left,
        my,
        mine_right,
        my,
        @raylib.Color::new(244, 208, 186, 200),
      )
    }

    // Scrap.
    for i = 0; i < scraps.length(); i = i + 1 {
      if not(scraps[i].active) {
        continue
      }
      let sx = (scraps[i].x - cam_x).to_int()
      let sy = (scraps[i].y - cam_y).to_int()

      let col = if scraps[i].kind == 0 {
        @raylib.Color::new(112, 234, 194, 236)
      } else if scraps[i].kind == 1 {
        @raylib.Color::new(118, 192, 252, 236)
      } else {
        @raylib.Color::new(252, 212, 116, 236)
      }

      @raylib.draw_circle(sx, sy, 9.0 + Float::from_int(scraps[i].value), col)
      if scraps[i].magnet {
        @raylib.draw_circle_lines(
          sx,
          sy,
          15.0,
          @raylib.Color::new(210, 246, 255, 214),
        )
      }
    }

    // Drones.
    for i = 0; i < drones.length(); i = i + 1 {
      if not(drones[i].active) {
        continue
      }

      let dx = (drones[i].x - cam_x).to_int()
      let dy = (drones[i].y - cam_y).to_int()

      if drones[i].kind == 0 {
        @raylib.draw_circle(dx, dy, 16.0, @raylib.Color::new(220, 96, 102, 244))
        @raylib.draw_circle_lines(
          dx,
          dy,
          20.0,
          @raylib.Color::new(248, 212, 214, 186),
        )
      } else if drones[i].kind == 1 {
        @raylib.draw_rectangle(
          dx - 18,
          dy - 14,
          36,
          28,
          @raylib.Color::new(238, 144, 72, 242),
        )
        @raylib.draw_rectangle_lines(
          dx - 22,
          dy - 18,
          44,
          36,
          @raylib.Color::new(252, 226, 188, 184),
        )
      } else {
        @raylib.draw_rectangle(
          dx - 24,
          dy - 20,
          48,
          40,
          @raylib.Color::new(168, 96, 186, 240),
        )
        @raylib.draw_circle(
          dx,
          dy - 4,
          12.0,
          @raylib.Color::new(236, 190, 252, 214),
        )
      }
    }

    // Boss.
    if boss.active {
      @raylib.draw_rectangle(
        (boss.x - cam_x - 80.0).to_int(),
        (boss.y - cam_y - 44.0).to_int(),
        160,
        88,
        @raylib.Color::new(126, 64, 168, 246),
      )
      @raylib.draw_rectangle_lines(
        (boss.x - cam_x - 92.0).to_int(),
        (boss.y - cam_y - 56.0).to_int(),
        184,
        112,
        @raylib.Color::new(234, 202, 252, 194),
      )
      @raylib.draw_circle(
        (boss.x - cam_x).to_int(),
        (boss.y - cam_y).to_int(),
        26.0,
        @raylib.Color::new(210, 166, 246, 226),
      )
      @raylib.draw_circle_lines(
        (boss.x - cam_x).to_int(),
        (boss.y - cam_y).to_int(),
        62.0,
        @raylib.Color::new(186, 112, 220, 180),
      )
    }

    // Bullets.
    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      let bx = (bullets[i].x - cam_x).to_int()
      let by = (bullets[i].y - cam_y).to_int()

      let col = if bullets[i].team == 1 {
        if bullets[i].kind == 1 {
          @raylib.Color::new(106, 236, 255, 250)
        } else {
          @raylib.Color::new(246, 244, 140, 250)
        }
      } else if bullets[i].kind == 1 {
        @raylib.Color::new(250, 122, 232, 246)
      } else {
        @raylib.Color::new(252, 132, 136, 242)
      }

      @raylib.draw_circle(bx, by, bullets[i].radius, col)
    }

    // Player and tractor visual.
    let px = (player.x - cam_x).to_int()
    let py = (player.y - cam_y).to_int()

    let pcol = if player.inv_t > 0.0 {
      @raylib.Color::new(252, 252, 252, 240)
    } else {
      @raylib.Color::new(94, 188, 246, 248)
    }

    @raylib.draw_rectangle(px - 16, py - 12, 32, 24, pcol)
    @raylib.draw_circle(
      px,
      py - 14,
      8.0,
      @raylib.Color::new(214, 242, 255, 252),
    )

    @raylib.draw_line(
      px,
      py,
      (player.x - cam_x + player.face_x * 28.0).to_int(),
      (player.y - cam_y + player.face_y * 28.0).to_int(),
      @raylib.Color::new(188, 232, 252, 220),
    )

    if player.tractor_on {
      @raylib.draw_circle_lines(
        px,
        py,
        320.0,
        @raylib.Color::new(102, 222, 248, 116),
      )
      for i = 0; i < scraps.length(); i = i + 1 {
        if not(scraps[i].active) || not(scraps[i].magnet) {
          continue
        }
        @raylib.draw_line(
          px,
          py,
          (scraps[i].x - cam_x).to_int(),
          (scraps[i].y - cam_y).to_int(),
          @raylib.Color::new(122, 234, 252, 104),
        )
      }
    }

    if player.boost_t > 0.0 {
      @raylib.draw_circle_lines(
        px,
        py,
        30.0,
        @raylib.Color::new(124, 218, 252, 210),
      )
    }

    // Particles.
    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let a : Int = (clampf(particles[i].life / 0.8, 0.0, 1.0) * 255.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(112, 224, 250, a)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(254, 238, 150, a)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(252, 128, 128, a)
      } else {
        @raylib.Color::new(226, 150, 252, a)
      }
      @raylib.draw_circle(
        (particles[i].x - cam_x).to_int(),
        (particles[i].y - cam_y).to_int(),
        particles[i].size,
        col,
      )
    }

    // HUD.
    @raylib.draw_rectangle(0, 0, sw, 84, @raylib.Color::new(8, 12, 20, 236))
    @raylib.draw_text(
      "Orbital Salvage Ops 2026",
      16,
      10,
      30,
      @raylib.Color::new(206, 236, 250, 248),
    )

    @raylib.draw_text(
      "Score \{player.score}",
      18,
      46,
      22,
      @raylib.Color::new(252, 226, 166, 252),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      220,
      46,
      22,
      @raylib.Color::new(166, 236, 188, 250),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      402,
      46,
      22,
      @raylib.Color::new(170, 214, 252, 250),
    )

    @raylib.draw_text(
      "Cargo \{player.cargo}",
      572,
      46,
      22,
      @raylib.Color::new(220, 236, 252, 248),
    )
    @raylib.draw_text(
      "Deposited \{player.deposited}/\{target_salvage}",
      716,
      46,
      22,
      @raylib.Color::new(220, 236, 252, 248),
    )

    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      1048,
      46,
      22,
      @raylib.Color::new(242, 208, 172, 252),
    )

    @raylib.draw_rectangle(16, 92, 260, 12, @raylib.Color::new(24, 28, 42, 255))
    @raylib.draw_rectangle(
      16,
      92,
      (clampf(player.hp / 100.0, 0.0, 1.0) * 260.0).to_int(),
      12,
      @raylib.Color::new(224, 98, 116, 255),
    )
    @raylib.draw_text("HP", 16, 108, 17, @raylib.Color::new(236, 204, 212, 255))

    @raylib.draw_rectangle(
      16,
      132,
      260,
      12,
      @raylib.Color::new(24, 28, 42, 255),
    )
    @raylib.draw_rectangle(
      16,
      132,
      (clampf(player.energy / 100.0, 0.0, 1.0) * 260.0).to_int(),
      12,
      @raylib.Color::new(88, 190, 242, 255),
    )
    @raylib.draw_text("EN", 16, 148, 17, @raylib.Color::new(204, 228, 250, 255))

    @raylib.draw_rectangle(
      16,
      172,
      260,
      12,
      @raylib.Color::new(24, 28, 42, 255),
    )
    @raylib.draw_rectangle(
      16,
      172,
      (clampf(player.heat / 100.0, 0.0, 1.0) * 260.0).to_int(),
      12,
      @raylib.Color::new(246, 170, 96, 255),
    )
    @raylib.draw_text(
      "HEAT",
      16,
      188,
      17,
      @raylib.Color::new(244, 222, 190, 255),
    )

    @raylib.draw_text(
      "Pulse CD \{(player.pulse_cd * 10.0).to_int()}",
      300,
      98,
      20,
      @raylib.Color::new(220, 232, 246, 246),
    )
    @raylib.draw_text(
      "Boost CD \{(player.boost_cd * 10.0).to_int()}",
      300,
      126,
      20,
      @raylib.Color::new(220, 232, 246, 246),
    )

    @raylib.draw_text(
      "FPS \{@raylib.get_fps()}",
      sw - 120,
      16,
      22,
      @raylib.Color::new(178, 214, 240, 220),
    )

    // Minimap.
    let map_w : Int = 236
    let map_h : Int = 162
    let map_x : Int = sw - map_w - 20
    let map_y : Int = 94

    @raylib.draw_rectangle(
      map_x,
      map_y,
      map_w,
      map_h,
      @raylib.Color::new(10, 16, 26, 206),
    )
    @raylib.draw_rectangle_lines(
      map_x,
      map_y,
      map_w,
      map_h,
      @raylib.Color::new(98, 136, 176, 210),
    )

    let map_fx : Float = Float::from_int(map_w) / world_w
    let map_fy : Float = Float::from_int(map_h) / world_h

    let bmx : Int = map_x + (beacon_x * map_fx).to_int()
    let bmy : Int = map_y + (beacon_y * map_fy).to_int()
    @raylib.draw_circle(bmx, bmy, 4.0, @raylib.Color::new(130, 230, 252, 250))

    for i = 0; i < drones.length(); i = i + 1 {
      if not(drones[i].active) {
        continue
      }
      let ex : Int = map_x + (drones[i].x * map_fx).to_int()
      let ey : Int = map_y + (drones[i].y * map_fy).to_int()
      @raylib.draw_circle(ex, ey, 2.0, @raylib.Color::new(252, 122, 132, 226))
    }

    let pmx : Int = map_x + (player.x * map_fx).to_int()
    let pmy : Int = map_y + (player.y * map_fy).to_int()
    @raylib.draw_circle(pmx, pmy, 3.0, @raylib.Color::new(120, 206, 252, 248))

    // Message banner.
    if msg_t > 0.0 {
      @raylib.draw_rectangle(
        sw / 2 - 320,
        sh - 68,
        640,
        36,
        @raylib.Color::new(12, 18, 30, 216),
      )
      @raylib.draw_text(
        msg,
        sw / 2 - 300,
        sh - 60,
        22,
        @raylib.Color::new(224, 244, 252, 248),
      )
    }

    draw_touch_ui(state)

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 164))
      @raylib.draw_rectangle(
        180,
        130,
        1006,
        500,
        @raylib.Color::new(12, 18, 34, 236),
      )
      @raylib.draw_rectangle_lines(
        180,
        130,
        1006,
        500,
        @raylib.Color::new(92, 152, 208, 206),
      )

      @raylib.draw_text(
        "ORBITAL SALVAGE OPS 2026",
        270,
        188,
        56,
        @raylib.Color::new(188, 236, 252, 255),
      )
      @raylib.draw_text(
        "Recover 120 salvage units and deliver to extraction beacon.",
        290,
        286,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Enemies scale over time. Mine blasts can damage everyone.",
        292,
        332,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Move: WASD/Arrows   Fire: J/Space   Tractor: K",
        300,
        390,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Boost: RightShift   EMP Pulse: L",
        430,
        432,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Touch controls shown in bottom corners.",
        416,
        472,
        28,
        @raylib.Color::new(196, 220, 242, 246),
      )
      @raylib.draw_text(
        "Press Enter or tap to begin",
        466,
        548,
        34,
        @raylib.Color::new(244, 236, 172, 252),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 176))
      @raylib.draw_rectangle(
        286,
        196,
        794,
        374,
        @raylib.Color::new(14, 28, 36, 242),
      )
      @raylib.draw_rectangle_lines(
        286,
        196,
        794,
        374,
        @raylib.Color::new(104, 220, 188, 214),
      )

      @raylib.draw_text(
        "MISSION SUCCESS",
        452,
        242,
        62,
        @raylib.Color::new(164, 246, 206, 254),
      )
      @raylib.draw_text(
        "Final Score: \{player.score}",
        490,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Delivered: \{player.deposited}   Best Combo: \{player.best_combo}",
        404,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to run again",
        430,
        472,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 186))
      @raylib.draw_rectangle(
        286,
        196,
        794,
        374,
        @raylib.Color::new(30, 16, 20, 246),
      )
      @raylib.draw_rectangle_lines(
        286,
        196,
        794,
        374,
        @raylib.Color::new(214, 106, 120, 214),
      )

      @raylib.draw_text(
        "MISSION FAILED",
        470,
        242,
        62,
        @raylib.Color::new(248, 164, 176, 252),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        560,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Delivered: \{player.deposited} / \{target_salvage}",
        490,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to retry",
        456,
        472,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
