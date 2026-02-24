///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 5600.0

///|
let floor_y : Float = 680.0

///|
let gravity : Float = 920.0

///|
let max_platforms : Int = 280

///|
let max_gates : Int = 8

///|
let max_cores : Int = 340

///|
let max_boxes : Int = 220

///|
let max_drones : Int = 180

///|
let max_bolts : Int = 1100

///|
let max_particles : Int = 1700

///|
let reactor_x : Float = world_w - 220.0

///|
let reactor_y : Float = floor_y - 100.0

///|
let target_cores : Int = 120

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut face : Int
  mut hp : Float
  mut energy : Float
  mut heat : Float
  mut inv_t : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut jump_buf_t : Float
  mut coyote_t : Float
  mut grounded : Bool
  mut magnet_on : Bool
  mut polarity : Int
  mut score : Int
  mut cargo : Int
  mut delivered : Int
  mut combo : Int
  mut best_combo : Int
}

///|
struct Platform {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut moving : Bool
  mut amp : Float
  mut speed : Float
  mut phase : Float
}

///|
struct Gate {
  mut active : Bool
  mut x : Float
  mut req : Int
  mut open : Bool
}

///|
struct Core {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut value : Int
  mut magnetized : Bool
  mut t : Float
}

///|
struct Box {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut hp : Float
  mut magnetized : Bool
  mut t : Float
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
struct Bolt {
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
fn drone_radius(kind : Int) -> Float {
  if kind == 0 {
    16.0
  } else if kind == 1 {
    21.0
  } else {
    27.0
  }
}

///|
fn drone_hp(kind : Int, level : Int) -> Float {
  if kind == 0 {
    34.0 + Float::from_int(level) * 3.0
  } else if kind == 1 {
    56.0 + Float::from_int(level) * 4.2
  } else {
    108.0 + Float::from_int(level) * 6.8
  }
}

///|
fn clear_platforms(platforms : Array[Platform]) -> Unit {
  for i = 0; i < platforms.length(); i = i + 1 {
    platforms[i].active = false
    platforms[i].x = 0.0
    platforms[i].y = 0.0
    platforms[i].w = 0.0
    platforms[i].h = 0.0
    platforms[i].moving = false
    platforms[i].amp = 0.0
    platforms[i].speed = 0.0
    platforms[i].phase = 0.0
  }
}

///|
fn clear_gates(gates : Array[Gate]) -> Unit {
  for i = 0; i < gates.length(); i = i + 1 {
    gates[i].active = false
    gates[i].x = 0.0
    gates[i].req = 0
    gates[i].open = false
  }
}

///|
fn clear_cores(cores : Array[Core]) -> Unit {
  for i = 0; i < cores.length(); i = i + 1 {
    cores[i].active = false
    cores[i].kind = 0
    cores[i].x = 0.0
    cores[i].y = 0.0
    cores[i].vx = 0.0
    cores[i].vy = 0.0
    cores[i].r = 0.0
    cores[i].value = 0
    cores[i].magnetized = false
    cores[i].t = 0.0
  }
}

///|
fn clear_boxes(boxes : Array[Box]) -> Unit {
  for i = 0; i < boxes.length(); i = i + 1 {
    boxes[i].active = false
    boxes[i].kind = 0
    boxes[i].x = 0.0
    boxes[i].y = 0.0
    boxes[i].vx = 0.0
    boxes[i].vy = 0.0
    boxes[i].r = 0.0
    boxes[i].hp = 0.0
    boxes[i].magnetized = false
    boxes[i].t = 0.0
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
fn clear_bolts(bolts : Array[Bolt]) -> Unit {
  for i = 0; i < bolts.length(); i = i + 1 {
    bolts[i].active = false
    bolts[i].team = 0
    bolts[i].kind = 0
    bolts[i].x = 0.0
    bolts[i].y = 0.0
    bolts[i].vx = 0.0
    bolts[i].vy = 0.0
    bolts[i].dmg = 0.0
    bolts[i].r = 0.0
    bolts[i].life = 0.0
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
fn add_platform(
  platforms : Array[Platform],
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  moving : Bool,
  amp : Float,
  speed : Float,
) -> Bool {
  for i = 0; i < platforms.length(); i = i + 1 {
    if not(platforms[i].active) {
      platforms[i].active = true
      platforms[i].x = x
      platforms[i].y = y
      platforms[i].w = w
      platforms[i].h = h
      platforms[i].moving = moving
      platforms[i].amp = amp
      platforms[i].speed = speed
      platforms[i].phase = randf(0.0, 100.0)
      return true
    }
  }
  false
}

///|
fn add_gate(gates : Array[Gate], x : Float, req : Int) -> Bool {
  for i = 0; i < gates.length(); i = i + 1 {
    if not(gates[i].active) {
      gates[i].active = true
      gates[i].x = x
      gates[i].req = req
      gates[i].open = false
      return true
    }
  }
  false
}

///|
fn add_core(
  cores : Array[Core],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  value : Int,
) -> Bool {
  for i = 0; i < cores.length(); i = i + 1 {
    if not(cores[i].active) {
      cores[i].active = true
      cores[i].kind = kind
      cores[i].x = x
      cores[i].y = y
      cores[i].vx = vx
      cores[i].vy = vy
      if kind == 0 {
        cores[i].r = 11.0
      } else if kind == 1 {
        cores[i].r = 13.0
      } else {
        cores[i].r = 15.0
      }
      cores[i].value = value
      cores[i].magnetized = false
      cores[i].t = randf(0.0, 24.0)
      return true
    }
  }
  false
}

///|
fn add_box(
  boxes : Array[Box],
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
) -> Bool {
  for i = 0; i < boxes.length(); i = i + 1 {
    if not(boxes[i].active) {
      boxes[i].active = true
      boxes[i].kind = kind
      boxes[i].x = x
      boxes[i].y = y
      boxes[i].vx = vx
      boxes[i].vy = vy
      if kind == 0 {
        boxes[i].r = 16.0
      } else {
        boxes[i].r = 20.0
      }
      boxes[i].hp = 120.0 + Float::from_int(kind) * 60.0
      boxes[i].magnetized = false
      boxes[i].t = randf(0.0, 22.0)
      return true
    }
  }
  false
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
      drones[i].vx = randf(-30.0, 30.0)
      drones[i].vy = randf(-30.0, 30.0)
      drones[i].hp = drone_hp(kind, level)
      if kind == 0 {
        drones[i].fire_cd = randf(1.0, 1.6)
      } else if kind == 1 {
        drones[i].fire_cd = randf(0.76, 1.3)
      } else {
        drones[i].fire_cd = randf(1.4, 2.2)
      }
      drones[i].t = randf(0.0, 100.0)
      return true
    }
  }
  false
}

///|
fn add_bolt(
  bolts : Array[Bolt],
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
  for i = 0; i < bolts.length(); i = i + 1 {
    if not(bolts[i].active) {
      bolts[i].active = true
      bolts[i].team = team
      bolts[i].kind = kind
      bolts[i].x = x
      bolts[i].y = y
      bolts[i].vx = vx
      bolts[i].vy = vy
      bolts[i].dmg = dmg
      bolts[i].r = r
      bolts[i].life = life
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
    let spd : Float = randf(60.0, 340.0) * scale
    ignore(
      add_particle(
        parts,
        kind,
        x,
        y,
        @math.cosf(ang) * spd,
        @math.sinf(ang) * spd,
        randf(2.0, 5.4) * scale,
        randf(0.16, 0.82),
      ),
    )
  }
}

///|
fn gate_block_circle(
  gates : Array[Gate],
  x : Float,
  y : Float,
  r : Float,
  vx : Float,
) -> (Float, Float) {
  let mut nx : Float = x
  let mut nvx : Float = vx
  for i = 0; i < gates.length(); i = i + 1 {
    if not(gates[i].active) || gates[i].open {
      continue
    }

    if y < 90.0 {
      continue
    }

    let gx : Float = gates[i].x
    if nx < gx && nx + r > gx - 6.0 && nvx > 0.0 {
      nx = gx - r - 6.0
      nvx = -absf(nvx) * 0.46
    }
    if nx > gx && nx - r < gx + 6.0 && nvx < 0.0 {
      nx = gx + r + 6.0
      nvx = absf(nvx) * 0.46
    }
  }
  (nx, nvx)
}

///|
fn setup_world(
  platforms : Array[Platform],
  gates : Array[Gate],
  cores : Array[Core],
  boxes : Array[Box],
) -> Unit {
  clear_platforms(platforms)
  clear_gates(gates)
  clear_cores(cores)
  clear_boxes(boxes)

  // Static platform layout: each sector has a small pattern.
  for sec = 0; sec < 18; sec = sec + 1 {
    let base_x : Float = 220.0 + Float::from_int(sec) * 300.0

    ignore(
      add_platform(
        platforms,
        base_x + 20.0,
        randf(510.0, 580.0),
        randf(160.0, 240.0),
        18.0,
        false,
        0.0,
        0.0,
      ),
    )

    ignore(
      add_platform(
        platforms,
        base_x + randf(120.0, 240.0),
        randf(390.0, 470.0),
        randf(130.0, 220.0),
        16.0,
        @raylib.get_random_value(0, 99) < 36,
        randf(20.0, 90.0),
        randf(0.4, 1.2),
      ),
    )

    if @raylib.get_random_value(0, 99) < 64 {
      ignore(
        add_platform(
          platforms,
          base_x + randf(130.0, 260.0),
          randf(280.0, 360.0),
          randf(110.0, 170.0),
          14.0,
          @raylib.get_random_value(0, 99) < 52,
          randf(20.0, 66.0),
          randf(0.6, 1.5),
        ),
      )
    }
  }

  ignore(add_gate(gates, 1180.0, 6))
  ignore(add_gate(gates, 2120.0, 18))
  ignore(add_gate(gates, 3080.0, 34))
  ignore(add_gate(gates, 4040.0, 56))
  ignore(add_gate(gates, 4920.0, 82))

  for i = 0; i < 95; i = i + 1 {
    let x : Float = randf(120.0, world_w - 420.0)
    let y : Float = randf(220.0, 620.0)
    let value : Int = 1 + @raylib.get_random_value(0, 2)
    ignore(
      add_core(
        cores,
        @raylib.get_random_value(0, 2),
        x,
        y,
        randf(-40.0, 40.0),
        randf(-20.0, 20.0),
        value,
      ),
    )
  }

  for i = 0; i < 68; i = i + 1 {
    let x : Float = randf(120.0, world_w - 420.0)
    let y : Float = randf(280.0, 640.0)
    ignore(
      add_box(
        boxes,
        @raylib.get_random_value(0, 1),
        x,
        y,
        randf(-18.0, 18.0),
        randf(-12.0, 12.0),
      ),
    )
  }
}

///|
fn draw_touch_ui(state : Int) -> Unit {
  if state != 1 {
    ignore(())
  } else {
    let pad_x : Int = 20
    let pad_y : Int = sh - 208

    let btn_x : Int = sw - 342
    let btn_y : Int = sh - 244

    @raylib.draw_rectangle(
      pad_x,
      pad_y,
      232,
      188,
      @raylib.Color::new(8, 12, 20, 98),
    )
    @raylib.draw_rectangle_lines(
      pad_x,
      pad_y,
      232,
      188,
      @raylib.Color::new(98, 142, 190, 182),
    )

    @raylib.draw_rectangle(
      pad_x + 12,
      pad_y + 66,
      62,
      62,
      @raylib.Color::new(24, 40, 60, 182),
    )
    @raylib.draw_rectangle(
      pad_x + 158,
      pad_y + 66,
      62,
      62,
      @raylib.Color::new(24, 40, 60, 182),
    )
    @raylib.draw_rectangle(
      pad_x + 84,
      pad_y + 4,
      62,
      62,
      @raylib.Color::new(24, 40, 60, 182),
    )

    @raylib.draw_text(
      "L",
      pad_x + 36,
      pad_y + 86,
      28,
      @raylib.Color::new(214, 236, 252, 244),
    )
    @raylib.draw_text(
      "R",
      pad_x + 182,
      pad_y + 86,
      28,
      @raylib.Color::new(214, 236, 252, 244),
    )
    @raylib.draw_text(
      "J",
      pad_x + 107,
      pad_y + 24,
      28,
      @raylib.Color::new(214, 236, 252, 244),
    )

    @raylib.draw_rectangle(
      btn_x,
      btn_y,
      312,
      220,
      @raylib.Color::new(8, 12, 20, 108),
    )
    @raylib.draw_rectangle_lines(
      btn_x,
      btn_y,
      312,
      220,
      @raylib.Color::new(98, 142, 190, 182),
    )

    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 10,
      140,
      90,
      @raylib.Color::new(26, 48, 68, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 160,
      btn_y + 10,
      140,
      90,
      @raylib.Color::new(26, 48, 68, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 12,
      btn_y + 112,
      140,
      96,
      @raylib.Color::new(26, 48, 68, 196),
    )
    @raylib.draw_rectangle(
      btn_x + 160,
      btn_y + 112,
      140,
      96,
      @raylib.Color::new(26, 48, 68, 196),
    )

    @raylib.draw_text(
      "FIRE",
      btn_x + 44,
      btn_y + 44,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "MAG",
      btn_x + 198,
      btn_y + 44,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "DASH",
      btn_x + 40,
      btn_y + 150,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
    @raylib.draw_text(
      "POL",
      btn_x + 210,
      btn_y + 150,
      24,
      @raylib.Color::new(246, 252, 255, 252),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] magnet lab escape 2026")
  @raylib.set_target_fps(60)

  let platforms : Array[Platform] = Array::makei(max_platforms, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      w: 0.0,
      h: 0.0,
      moving: false,
      amp: 0.0,
      speed: 0.0,
      phase: 0.0,
    }
  })

  let gates : Array[Gate] = Array::makei(max_gates, fn(_i) {
    { active: false, x: 0.0, req: 0, open: false }
  })

  let cores : Array[Core] = Array::makei(max_cores, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      r: 0.0,
      value: 0,
      magnetized: false,
      t: 0.0,
    }
  })

  let boxes : Array[Box] = Array::makei(max_boxes, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      r: 0.0,
      hp: 0.0,
      magnetized: false,
      t: 0.0,
    }
  })

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

  let bolts : Array[Bolt] = Array::makei(max_bolts, fn(_i) {
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
    x: 160.0,
    y: 560.0,
    vx: 0.0,
    vy: 0.0,
    face: 1,
    hp: 100.0,
    energy: 100.0,
    heat: 0.0,
    inv_t: 0.0,
    fire_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    jump_buf_t: 0.0,
    coyote_t: 0.0,
    grounded: false,
    magnet_on: false,
    polarity: 1,
    score: 0,
    cargo: 0,
    delivered: 0,
    combo: 0,
    best_combo: 0,
  }

  let mut state : Int = 0
  let mut cam_x : Float = 0.0

  let mut timer : Float = 420.0
  let mut drone_cd : Float = 0.6
  let mut core_cd : Float = 2.8

  let mut msg : String = "Collect and deliver magnetic cores"
  let mut msg_t : Float = 3.0

  let mut stars_t : Float = 0.0

  let reset_run = fn() {
    player.x = 160.0
    player.y = 560.0
    player.vx = 0.0
    player.vy = 0.0
    player.face = 1
    player.hp = 100.0
    player.energy = 100.0
    player.heat = 0.0
    player.inv_t = 0.0
    player.fire_cd = 0.0
    player.dash_cd = 0.0
    player.dash_t = 0.0
    player.jump_buf_t = 0.0
    player.coyote_t = 0.0
    player.grounded = false
    player.magnet_on = false
    player.polarity = 1
    player.score = 0
    player.cargo = 0
    player.delivered = 0
    player.combo = 0
    player.best_combo = 0

    timer = 420.0
    drone_cd = 0.6
    core_cd = 2.8

    msg = "Reach the reactor and deliver 120 cores"
    msg_t = 2.4

    setup_world(platforms, gates, cores, boxes)
    clear_drones(drones)
    clear_bolts(bolts)
    clear_particles(particles)

    cam_x = 0.0
  }

  let on_player_hit = fn(dmg : Float, reason : String) {
    if player.inv_t > 0.0 {
      ignore(())
    } else {
      let mut dealt : Float = dmg
      if player.dash_t > 0.0 {
        dealt = dealt * 0.62
      }
      player.hp = player.hp - dealt
      if player.hp < 0.0 {
        player.hp = 0.0
      }
      player.inv_t = 0.42
      player.combo = 0
      msg = reason
      msg_t = 0.72
      burst(particles, player.x, player.y, 18, 0.22, 2)
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
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      // Gate progression.
      for i = 0; i < gates.length(); i = i + 1 {
        if not(gates[i].active) {
          continue
        }

        let was_open : Bool = gates[i].open
        gates[i].open = player.delivered >= gates[i].req
        if not(was_open) && gates[i].open {
          msg = "Gate unlocked: requirement \{gates[i].req} cores"
          msg_t = 0.86
          burst(particles, gates[i].x, floor_y - 140.0, 36, 0.26, 3)
        }
      }

      let level : Int = player.delivered / 10 +
        (Float::from_int(420) - timer).to_int() / 48 +
        1

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

      player.jump_buf_t = player.jump_buf_t - dt
      if player.jump_buf_t < 0.0 {
        player.jump_buf_t = 0.0
      }

      player.coyote_t = player.coyote_t - dt
      if player.coyote_t < 0.0 {
        player.coyote_t = 0.0
      }

      player.heat = player.heat - dt * 34.0
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      player.energy = player.energy + dt * 10.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut jump_press : Bool = @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut fire_hold : Bool = @raylib.is_key_down(@raylib.KeyL)
      let mut magnet_hold : Bool = @raylib.is_key_down(@raylib.KeyJ)
      let mut polarity_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyRightShift)

      let pad_x : Int = 20
      let pad_y : Int = sh - 208

      let btn_x : Int = sw - 342
      let btn_y : Int = sh - 244

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x + 12, pad_y + 66, 62, 62) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 158, pad_y + 66, 62, 62) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 4, 62, 62) {
          jump_press = true
        }

        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 10, 140, 90) {
          fire_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 160, btn_y + 10, 140, 90) {
          magnet_hold = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 12, btn_y + 112, 140, 96) {
          dash_press = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 160, btn_y + 112, 140, 96) {
          polarity_press = true
        }
      }

      if polarity_press {
        player.polarity = -player.polarity
        msg = if player.polarity > 0 {
          "Magnet polarity: attract"
        } else {
          "Magnet polarity: repel"
        }
        msg_t = 0.52
      }

      if move_l {
        player.face = -1
      }
      if move_r {
        player.face = 1
      }

      if jump_press {
        player.jump_buf_t = 0.14
      }

      let accel : Float = if player.dash_t > 0.0 { 2100.0 } else { 1300.0 }
      if move_l {
        player.vx = player.vx - accel * dt
      }
      if move_r {
        player.vx = player.vx + accel * dt
      }

      if not(move_l) && not(move_r) {
        player.vx = player.vx * (1.0 - dt * 8.6)
      }

      player.vx = clampf(player.vx, -390.0, 390.0)

      if dash_press && player.dash_cd <= 0.0 && player.energy >= 18.0 {
        player.dash_cd = 1.0
        player.dash_t = 0.24
        player.energy = player.energy - 18.0
        player.vx = player.vx + Float::from_int(player.face) * 440.0
        burst(particles, player.x, player.y, 14, 0.16, 0)
      }

      // Update moving platforms.
      for i = 0; i < platforms.length(); i = i + 1 {
        if not(platforms[i].active) {
          continue
        }
        if platforms[i].moving {
          platforms[i].phase = platforms[i].phase + dt * platforms[i].speed
          platforms[i].x = platforms[i].x +
            @math.sinf(platforms[i].phase) * platforms[i].amp * dt
          platforms[i].x = clampf(platforms[i].x, 80.0, world_w - 320.0)
        }
      }

      // Horizontal player movement.
      let pw : Float = 30.0
      let ph : Float = 46.0

      player.x = player.x + player.vx * dt
      player.x = clampf(player.x, pw * 0.5, world_w - pw * 0.5)

      let (gx, gvx) = gate_block_circle(
        gates,
        player.x,
        player.y,
        pw * 0.5,
        player.vx,
      )
      player.x = gx
      player.vx = gvx

      // Vertical movement and jump.
      if player.grounded {
        player.coyote_t = 0.11
      }

      if player.jump_buf_t > 0.0 && (player.grounded || player.coyote_t > 0.0) {
        player.vy = -458.0
        player.grounded = false
        player.coyote_t = 0.0
        player.jump_buf_t = 0.0
        burst(particles, player.x, player.y + ph * 0.5, 8, 0.12, 1)
      }

      let prev_bottom : Float = player.y + ph * 0.5
      player.vy = player.vy + gravity * dt
      player.vy = clampf(player.vy, -720.0, 760.0)
      player.y = player.y + player.vy * dt

      player.grounded = false

      if player.y + ph * 0.5 >= floor_y {
        player.y = floor_y - ph * 0.5
        if player.vy > 0.0 {
          player.vy = 0.0
        }
        player.grounded = true
      }

      for i = 0; i < platforms.length(); i = i + 1 {
        if not(platforms[i].active) {
          continue
        }

        let left : Float = platforms[i].x - platforms[i].w * 0.5
        let right : Float = platforms[i].x + platforms[i].w * 0.5
        let top : Float = platforms[i].y - platforms[i].h * 0.5

        if player.x + pw * 0.45 > left && player.x - pw * 0.45 < right {
          if player.vy >= 0.0 &&
            prev_bottom <= top + 6.0 &&
            player.y + ph * 0.5 >= top {
            player.y = top - ph * 0.5
            player.vy = 0.0
            player.grounded = true
          }
        }
      }

      // Shooting.
      if fire_hold && player.fire_cd <= 0.0 && player.heat <= 94.0 {
        player.fire_cd = clampf(
          0.115 - Float::from_int(level) * 0.002,
          0.068,
          0.115,
        )
        player.heat = player.heat + 8.0

        let dir_x : Float = Float::from_int(player.face)
        let dir_y : Float = if player.grounded { -0.08 } else { -0.14 }

        ignore(
          add_bolt(
            bolts,
            1,
            0,
            player.x + dir_x * 16.0,
            player.y - 8.0,
            dir_x * 620.0,
            dir_y * 620.0,
            16.0,
            4.0,
            1.1,
          ),
        )

        if level >= 6 {
          ignore(
            add_bolt(
              bolts,
              1,
              0,
              player.x + dir_x * 16.0,
              player.y - 6.0,
              dir_x * 590.0,
              -160.0,
              11.0,
              3.0,
              1.0,
            ),
          )
        }

        burst(particles, player.x + dir_x * 16.0, player.y - 8.0, 6, 0.12, 1)
      }

      // Magnet field.
      player.magnet_on = false
      if magnet_hold && player.energy > 0.0 {
        player.magnet_on = true
        player.energy = player.energy - dt * 17.0
        if player.energy < 0.0 {
          player.energy = 0.0
          player.magnet_on = false
        }
      }

      if player.magnet_on {
        let sign : Float = Float::from_int(player.polarity)

        for i = 0; i < cores.length(); i = i + 1 {
          if not(cores[i].active) {
            continue
          }
          let dx : Float = player.x - cores[i].x
          let dy : Float = player.y - 8.0 - cores[i].y
          let d2 : Float = dx * dx + dy * dy
          cores[i].magnetized = false
          if d2 <= 310.0 * 310.0 {
            cores[i].magnetized = true
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let inv : Float = 1.0 / d
            let force : Float = clampf(320.0 - d * 0.7, 80.0, 320.0)
            cores[i].vx = cores[i].vx + dx * inv * force * dt * sign
            cores[i].vy = cores[i].vy + dy * inv * force * dt * sign
          }
        }

        for i = 0; i < boxes.length(); i = i + 1 {
          if not(boxes[i].active) {
            continue
          }
          let dx : Float = player.x - boxes[i].x
          let dy : Float = player.y - 8.0 - boxes[i].y
          let d2 : Float = dx * dx + dy * dy
          boxes[i].magnetized = false
          if d2 <= 290.0 * 290.0 {
            boxes[i].magnetized = true
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let inv : Float = 1.0 / d
            let force : Float = clampf(220.0 - d * 0.58, 46.0, 220.0)
            boxes[i].vx = boxes[i].vx + dx * inv * force * dt * sign
            boxes[i].vy = boxes[i].vy + dy * inv * force * dt * sign
          }
        }

        for i = 0; i < bolts.length(); i = i + 1 {
          if not(bolts[i].active) || bolts[i].team != 2 {
            continue
          }
          let dx : Float = player.x - bolts[i].x
          let dy : Float = player.y - bolts[i].y
          let d2 : Float = dx * dx + dy * dy
          if d2 <= 230.0 * 230.0 {
            let mut d : Float = d2.sqrt()
            if d < 1.0 {
              d = 1.0
            }
            let inv : Float = 1.0 / d
            let force : Float = clampf(210.0 - d * 0.66, 56.0, 210.0)
            bolts[i].vx = bolts[i].vx + dx * inv * force * dt * sign
            bolts[i].vy = bolts[i].vy + dy * inv * force * dt * sign
          }
        }
      }

      // Spawn drones.
      drone_cd = drone_cd - dt
      if drone_cd <= 0.0 {
        let mut frontier : Float = world_w - 260.0
        for i = 0; i < gates.length(); i = i + 1 {
          if gates[i].active && not(gates[i].open) && gates[i].x < frontier {
            frontier = gates[i].x - 80.0
          }
        }

        let mut spawn_x : Float = player.x + randf(-460.0, 460.0)
        spawn_x = clampf(spawn_x, 80.0, frontier)
        let spawn_y : Float = randf(160.0, 560.0)

        let roll : Int = @raylib.get_random_value(0, 99)
        let mut kind : Int = 0
        if level >= 4 && roll >= 48 {
          kind = 1
        }
        if level >= 8 && roll >= 82 {
          kind = 2
        }

        ignore(add_drone(drones, kind, spawn_x, spawn_y, level))

        let base_cd : Float = 1.18 - Float::from_int(level) * 0.05
        drone_cd = clampf(base_cd + randf(-0.14, 0.26), 0.26, 1.24)
      }

      // Spawn extra cores as run continues.
      core_cd = core_cd - dt
      if core_cd <= 0.0 {
        core_cd = randf(2.2, 4.6)
        let mut frontier : Float = world_w - 320.0
        for i = 0; i < gates.length(); i = i + 1 {
          if gates[i].active && not(gates[i].open) && gates[i].x < frontier {
            frontier = gates[i].x - 180.0
          }
        }
        let sx : Float = randf(120.0, clampf(frontier, 140.0, world_w - 420.0))
        let sy : Float = randf(220.0, 600.0)
        ignore(
          add_core(
            cores,
            @raylib.get_random_value(0, 2),
            sx,
            sy,
            randf(-24.0, 24.0),
            randf(-16.0, 16.0),
            1 + @raylib.get_random_value(0, 2),
          ),
        )
      }

      // Update cores.
      for i = 0; i < cores.length(); i = i + 1 {
        if not(cores[i].active) {
          continue
        }

        cores[i].t = cores[i].t + dt
        cores[i].vy = cores[i].vy + gravity * dt * 0.86
        cores[i].vx = cores[i].vx * (1.0 - dt * 1.05)

        let prev_y : Float = cores[i].y
        cores[i].x = cores[i].x + cores[i].vx * dt
        cores[i].y = cores[i].y + cores[i].vy * dt

        // world bounds
        if cores[i].x < cores[i].r {
          cores[i].x = cores[i].r
          cores[i].vx = absf(cores[i].vx) * 0.56
        }
        if cores[i].x > world_w - cores[i].r {
          cores[i].x = world_w - cores[i].r
          cores[i].vx = -absf(cores[i].vx) * 0.56
        }

        let (cx, cvx) = gate_block_circle(
          gates,
          cores[i].x,
          cores[i].y,
          cores[i].r,
          cores[i].vx,
        )
        cores[i].x = cx
        cores[i].vx = cvx

        if cores[i].y + cores[i].r >= floor_y {
          cores[i].y = floor_y - cores[i].r
          if cores[i].vy > 0.0 {
            cores[i].vy = -cores[i].vy * 0.42
          }
          if absf(cores[i].vy) < 24.0 {
            cores[i].vy = 0.0
          }
        }

        for p = 0; p < platforms.length(); p = p + 1 {
          if not(platforms[p].active) {
            continue
          }
          let left : Float = platforms[p].x - platforms[p].w * 0.5
          let right : Float = platforms[p].x + platforms[p].w * 0.5
          let top : Float = platforms[p].y - platforms[p].h * 0.5
          if cores[i].x > left - cores[i].r && cores[i].x < right + cores[i].r {
            if cores[i].vy >= 0.0 &&
              prev_y + cores[i].r <= top + 4.0 &&
              cores[i].y + cores[i].r >= top {
              cores[i].y = top - cores[i].r
              cores[i].vy = -cores[i].vy * 0.36
              if absf(cores[i].vy) < 20.0 {
                cores[i].vy = 0.0
              }
            }
          }
        }

        // Core delivery.
        if dist2(cores[i].x, cores[i].y, reactor_x, reactor_y) <= 80.0 * 80.0 {
          if absf(cores[i].vx) + absf(cores[i].vy) < 210.0 {
            player.delivered = player.delivered + cores[i].value
            player.score = player.score + 28 + cores[i].value * 8 + player.combo
            player.cargo = player.cargo + cores[i].value
            cores[i].active = false
            burst(particles, reactor_x, reactor_y, 10, 0.14, 0)
            continue
          }
        }

        // Core damage vs drones (if moving fast).
        let speed2 : Float = cores[i].vx * cores[i].vx +
          cores[i].vy * cores[i].vy
        if speed2 >= 170.0 * 170.0 {
          for d = 0; d < drones.length(); d = d + 1 {
            if not(drones[d].active) {
              continue
            }
            let rr : Float = cores[i].r + drone_radius(drones[d].kind)
            if dist2(cores[i].x, cores[i].y, drones[d].x, drones[d].y) <=
              rr * rr {
              drones[d].hp = drones[d].hp - 18.0
              let mut dx : Float = drones[d].x - cores[i].x
              let mut dy : Float = drones[d].y - cores[i].y
              let mut l2 : Float = dx * dx + dy * dy
              if l2 < 1.0 {
                l2 = 1.0
                dx = 1.0
                dy = 0.0
              }
              let inv : Float = 1.0 / l2.sqrt()
              drones[d].vx = drones[d].vx + dx * inv * 160.0
              drones[d].vy = drones[d].vy + dy * inv * 160.0
              cores[i].vx = -cores[i].vx * 0.6
              cores[i].vy = -cores[i].vy * 0.5
              break
            }
          }
        }
      }

      // Update boxes.
      for i = 0; i < boxes.length(); i = i + 1 {
        if not(boxes[i].active) {
          continue
        }

        boxes[i].t = boxes[i].t + dt
        boxes[i].vy = boxes[i].vy + gravity * dt * 0.96
        boxes[i].vx = boxes[i].vx * (1.0 - dt * 1.2)

        let prev_y : Float = boxes[i].y
        boxes[i].x = boxes[i].x + boxes[i].vx * dt
        boxes[i].y = boxes[i].y + boxes[i].vy * dt

        if boxes[i].x < boxes[i].r {
          boxes[i].x = boxes[i].r
          boxes[i].vx = absf(boxes[i].vx) * 0.44
        }
        if boxes[i].x > world_w - boxes[i].r {
          boxes[i].x = world_w - boxes[i].r
          boxes[i].vx = -absf(boxes[i].vx) * 0.44
        }

        let (bx, bvx) = gate_block_circle(
          gates,
          boxes[i].x,
          boxes[i].y,
          boxes[i].r,
          boxes[i].vx,
        )
        boxes[i].x = bx
        boxes[i].vx = bvx

        if boxes[i].y + boxes[i].r >= floor_y {
          boxes[i].y = floor_y - boxes[i].r
          if boxes[i].vy > 0.0 {
            boxes[i].vy = -boxes[i].vy * 0.28
          }
          if absf(boxes[i].vy) < 16.0 {
            boxes[i].vy = 0.0
          }
        }

        for p = 0; p < platforms.length(); p = p + 1 {
          if not(platforms[p].active) {
            continue
          }
          let left : Float = platforms[p].x - platforms[p].w * 0.5
          let right : Float = platforms[p].x + platforms[p].w * 0.5
          let top : Float = platforms[p].y - platforms[p].h * 0.5
          if boxes[i].x > left - boxes[i].r && boxes[i].x < right + boxes[i].r {
            if boxes[i].vy >= 0.0 &&
              prev_y + boxes[i].r <= top + 4.0 &&
              boxes[i].y + boxes[i].r >= top {
              boxes[i].y = top - boxes[i].r
              boxes[i].vy = -boxes[i].vy * 0.22
              if absf(boxes[i].vy) < 12.0 {
                boxes[i].vy = 0.0
              }
            }
          }
        }

        // Damage drones when thrown fast.
        let speed2 : Float = boxes[i].vx * boxes[i].vx +
          boxes[i].vy * boxes[i].vy
        if speed2 >= 180.0 * 180.0 {
          for d = 0; d < drones.length(); d = d + 1 {
            if not(drones[d].active) {
              continue
            }
            let rr : Float = boxes[i].r + drone_radius(drones[d].kind)
            if dist2(boxes[i].x, boxes[i].y, drones[d].x, drones[d].y) <=
              rr * rr {
              drones[d].hp = drones[d].hp - 26.0
              boxes[i].hp = boxes[i].hp - 20.0
              boxes[i].vx = -boxes[i].vx * 0.54
              boxes[i].vy = -boxes[i].vy * 0.4
              break
            }
          }
        }

        if boxes[i].hp <= 0.0 {
          boxes[i].active = false
          ignore(
            add_core(
              cores,
              @raylib.get_random_value(0, 2),
              boxes[i].x,
              boxes[i].y,
              randf(-120.0, 120.0),
              randf(-180.0, -40.0),
              2 + @raylib.get_random_value(0, 2),
            ),
          )
          burst(particles, boxes[i].x, boxes[i].y, 18, 0.2, 2)
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
        let ty : Float = player.y - 6.0 - drones[i].y
        let mut inv : Float = 0.0
        let l2 : Float = tx * tx + ty * ty
        if l2 > 0.01 {
          inv = 1.0 / l2.sqrt()
        }

        if drones[i].kind == 0 {
          let acc : Float = 120.0 + Float::from_int(level) * 6.0
          drones[i].vx = drones[i].vx + tx * inv * acc * dt
          drones[i].vy = drones[i].vy + ty * inv * acc * dt
        } else if drones[i].kind == 1 {
          let target : Float = 220.0
          let mut d : Float = 0.0
          if l2 > 0.01 {
            d = l2.sqrt()
          }
          let err : Float = d - target
          drones[i].vx = drones[i].vx +
            tx * inv * err * 0.6 * dt +
            @math.sinf(drones[i].t * 2.2) * 24.0 * dt
          drones[i].vy = drones[i].vy +
            ty * inv * err * 0.6 * dt +
            @math.cosf(drones[i].t * 2.0) * 24.0 * dt
        } else {
          let acc : Float = 78.0 + Float::from_int(level) * 3.2
          drones[i].vx = drones[i].vx + tx * inv * acc * dt
          drones[i].vy = drones[i].vy + ty * inv * acc * dt
        }

        let max_spd : Float = if drones[i].kind == 2 {
          180.0
        } else {
          230.0 + Float::from_int(level) * 4.0
        }
        let sp2 : Float = drones[i].vx * drones[i].vx +
          drones[i].vy * drones[i].vy
        if sp2 > max_spd * max_spd {
          let invs : Float = max_spd / sp2.sqrt()
          drones[i].vx = drones[i].vx * invs
          drones[i].vy = drones[i].vy * invs
        }

        drones[i].x = drones[i].x + drones[i].vx * dt
        drones[i].y = drones[i].y + drones[i].vy * dt

        drones[i].x = clampf(drones[i].x, 20.0, world_w - 20.0)
        drones[i].y = clampf(drones[i].y, 80.0, floor_y - 20.0)

        let (dx, dvx) = gate_block_circle(
          gates,
          drones[i].x,
          drones[i].y,
          drone_radius(drones[i].kind),
          drones[i].vx,
        )
        drones[i].x = dx
        drones[i].vx = dvx

        if drones[i].fire_cd <= 0.0 {
          if drones[i].kind == 0 {
            drones[i].fire_cd = randf(1.0, 1.7)
            ignore(
              add_bolt(
                bolts,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 300.0,
                ty * inv * 300.0,
                8.0,
                5.0,
                3.0,
              ),
            )
          } else if drones[i].kind == 1 {
            drones[i].fire_cd = randf(0.72, 1.25)
            let sx : Float = -ty * inv
            let sy : Float = tx * inv
            ignore(
              add_bolt(
                bolts,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 284.0 + sx * 68.0,
                ty * inv * 284.0 + sy * 68.0,
                7.0,
                4.0,
                2.8,
              ),
            )
            ignore(
              add_bolt(
                bolts,
                2,
                0,
                drones[i].x,
                drones[i].y,
                tx * inv * 284.0 - sx * 68.0,
                ty * inv * 284.0 - sy * 68.0,
                7.0,
                4.0,
                2.8,
              ),
            )
          } else {
            drones[i].fire_cd = randf(1.4, 2.2)
            ignore(
              add_bolt(
                bolts,
                2,
                1,
                drones[i].x,
                drones[i].y,
                tx * inv * 250.0,
                ty * inv * 250.0,
                14.0,
                7.0,
                3.2,
              ),
            )
          }
        }

        // Collision with player.
        let rr : Float = drone_radius(drones[i].kind) + 17.0
        if dist2(drones[i].x, drones[i].y, player.x, player.y) <= rr * rr {
          on_player_hit(
            8.0 + Float::from_int(drones[i].kind) * 2.4,
            "Drone body hit",
          )
          drones[i].vx = -drones[i].vx
          drones[i].vy = -drones[i].vy
        }

        // Destroyed.
        if drones[i].hp <= 0.0 {
          let reward : Int = 60 + drones[i].kind * 34 + player.combo * 3
          player.score = player.score + reward
          player.combo = player.combo + 1
          if player.combo > player.best_combo {
            player.best_combo = player.combo
          }

          if @raylib.get_random_value(0, 99) < 72 {
            ignore(
              add_core(
                cores,
                @raylib.get_random_value(0, 2),
                drones[i].x,
                drones[i].y,
                randf(-110.0, 110.0),
                randf(-180.0, -60.0),
                2 + @raylib.get_random_value(0, 2),
              ),
            )
          }
          if @raylib.get_random_value(0, 99) < 36 {
            ignore(
              add_box(
                boxes,
                @raylib.get_random_value(0, 1),
                drones[i].x,
                drones[i].y,
                randf(-80.0, 80.0),
                randf(-40.0, 40.0),
              ),
            )
          }

          burst(particles, drones[i].x, drones[i].y, 22, 0.2, 0)
          drones[i].active = false
        }
      }

      // Update bolts.
      for i = 0; i < bolts.length(); i = i + 1 {
        if not(bolts[i].active) {
          continue
        }

        bolts[i].life = bolts[i].life - dt
        if bolts[i].life <= 0.0 {
          bolts[i].active = false
          continue
        }

        bolts[i].x = bolts[i].x + bolts[i].vx * dt
        bolts[i].y = bolts[i].y + bolts[i].vy * dt

        if bolts[i].x < -80.0 ||
          bolts[i].x > world_w + 80.0 ||
          bolts[i].y < -80.0 ||
          bolts[i].y > floor_y + 100.0 {
          bolts[i].active = false
          continue
        }

        // Gate / floor block.
        if bolts[i].y + bolts[i].r >= floor_y {
          bolts[i].active = false
          continue
        }

        let (bx, bvx) = gate_block_circle(
          gates,
          bolts[i].x,
          bolts[i].y,
          bolts[i].r,
          bolts[i].vx,
        )
        if bx != bolts[i].x {
          bolts[i].active = false
          continue
        }
        bolts[i].x = bx
        bolts[i].vx = bvx

        for p = 0; p < platforms.length(); p = p + 1 {
          if not(platforms[p].active) {
            continue
          }
          let left : Float = platforms[p].x - platforms[p].w * 0.5
          let right : Float = platforms[p].x + platforms[p].w * 0.5
          let top : Float = platforms[p].y - platforms[p].h * 0.5
          let bottom : Float = platforms[p].y + platforms[p].h * 0.5
          if bolts[i].x + bolts[i].r > left &&
            bolts[i].x - bolts[i].r < right &&
            bolts[i].y + bolts[i].r > top &&
            bolts[i].y - bolts[i].r < bottom {
            bolts[i].active = false
            break
          }
        }

        if not(bolts[i].active) {
          continue
        }

        if bolts[i].team == 1 {
          let mut hit_done : Bool = false
          for d = 0; d < drones.length(); d = d + 1 {
            if hit_done {
              continue
            }
            if not(drones[d].active) {
              continue
            }
            let rr : Float = bolts[i].r + drone_radius(drones[d].kind)
            if dist2(bolts[i].x, bolts[i].y, drones[d].x, drones[d].y) <=
              rr * rr {
              drones[d].hp = drones[d].hp - bolts[i].dmg
              bolts[i].active = false
              hit_done = true
              burst(particles, bolts[i].x, bolts[i].y, 5, 0.1, 1)
            }
          }

          if bolts[i].active {
            for b = 0; b < boxes.length(); b = b + 1 {
              if not(boxes[b].active) {
                continue
              }
              let rr : Float = bolts[i].r + boxes[b].r
              if dist2(bolts[i].x, bolts[i].y, boxes[b].x, boxes[b].y) <=
                rr * rr {
                boxes[b].hp = boxes[b].hp - bolts[i].dmg * 0.8
                bolts[i].active = false
                break
              }
            }
          }
        } else if dist2(bolts[i].x, bolts[i].y, player.x, player.y) <=
          (bolts[i].r + 16.0) * (bolts[i].r + 16.0) {
          on_player_hit(bolts[i].dmg, "Enemy bolt")
          bolts[i].active = false
        }
      }

      // Particle update.
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
        particles[i].vy = particles[i].vy + dt * 80.0
        particles[i].vx = particles[i].vx * (1.0 - dt * 1.8)
      }

      // Win/lose.
      if timer <= 0.0 {
        state = 3
        msg = "Time out"
        msg_t = 2.2
      }

      if player.hp <= 0.0 {
        state = 3
        msg = "System failure"
        msg_t = 2.2
      }

      if player.delivered >= target_cores {
        state = 2
        msg = "Escape complete"
        msg_t = 2.2
      }

      cam_x = clampf(
        player.x - Float::from_int(sw) * 0.5,
        0.0,
        world_w - Float::from_int(sw),
      )
    } else if @raylib.is_key_pressed(@raylib.KeyR) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      pressed {
      state = 1
      reset_run()
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(6, 10, 18, 255))

    // Parallax backdrop.
    for i = 0; i < 120; i = i + 1 {
      let fi : Float = Float::from_int(i)
      let px : Int = ((
        fi * 73.0 +
        stars_t * (0.2 + Float::from_int(i % 5) * 0.1) +
        cam_x * 0.04
      ) %
      Float::from_int(sw)).to_int()
      let py : Int = ((
        fi * 131.0 + stars_t * (0.15 + Float::from_int(i % 7) * 0.08)
      ) %
      Float::from_int(sh)).to_int()
      let br : Int = 96 + i % 8 * 16
      @raylib.draw_circle(
        px,
        py,
        if i % 3 == 0 {
          1.8
        } else {
          1.2
        },
        @raylib.Color::new(br, br, br + 34, 190),
      )
    }

    // Floor and world border.
    @raylib.draw_rectangle(
      0,
      floor_y.to_int(),
      sw,
      sh - floor_y.to_int(),
      @raylib.Color::new(18, 22, 34, 255),
    )
    @raylib.draw_rectangle_lines(
      (-cam_x).to_int(),
      0,
      world_w.to_int(),
      floor_y.to_int(),
      @raylib.Color::new(56, 88, 126, 120),
    )

    // Reactor zone.
    let rx : Int = (reactor_x - cam_x).to_int()
    let ry : Int = reactor_y.to_int()
    @raylib.draw_circle(rx, ry, 94.0, @raylib.Color::new(46, 128, 170, 70))
    @raylib.draw_circle_lines(
      rx,
      ry,
      94.0,
      @raylib.Color::new(128, 222, 254, 220),
    )
    @raylib.draw_circle(rx, ry, 26.0, @raylib.Color::new(186, 248, 255, 216))
    @raylib.draw_text(
      "REACTOR",
      rx - 48,
      ry - 112,
      18,
      @raylib.Color::new(186, 234, 252, 230),
    )

    // Platforms.
    for i = 0; i < platforms.length(); i = i + 1 {
      if not(platforms[i].active) {
        continue
      }

      let x : Int = (platforms[i].x - platforms[i].w * 0.5 - cam_x).to_int()
      let y : Int = (platforms[i].y - platforms[i].h * 0.5).to_int()
      let w : Int = platforms[i].w.to_int()
      let h : Int = platforms[i].h.to_int()

      @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(58, 68, 90, 236))
      @raylib.draw_rectangle_lines(
        x,
        y,
        w,
        h,
        @raylib.Color::new(138, 164, 194, 180),
      )

      for s = 0; s < 5; s = s + 1 {
        let lx0 : Int = x + s * (w / 5)
        let lx1 : Int = lx0 + 10
        @raylib.draw_line(
          lx0,
          y + h - 1,
          lx1,
          y + 2,
          @raylib.Color::new(96, 126, 160, 94),
        )
      }
    }

    // Gates.
    for i = 0; i < gates.length(); i = i + 1 {
      if not(gates[i].active) {
        continue
      }

      let gx : Int = (gates[i].x - cam_x).to_int()
      if gates[i].open {
        @raylib.draw_line(
          gx,
          84,
          gx,
          floor_y.to_int(),
          @raylib.Color::new(90, 170, 124, 88),
        )
        @raylib.draw_text(
          "OPEN",
          gx - 22,
          58,
          16,
          @raylib.Color::new(146, 236, 176, 216),
        )
      } else {
        @raylib.draw_rectangle(
          gx - 10,
          84,
          20,
          floor_y.to_int() - 84,
          @raylib.Color::new(120, 54, 72, 220),
        )
        @raylib.draw_rectangle_lines(
          gx - 10,
          84,
          20,
          floor_y.to_int() - 84,
          @raylib.Color::new(236, 188, 196, 210),
        )
        @raylib.draw_text(
          "\{gates[i].req}",
          gx - 16,
          58,
          18,
          @raylib.Color::new(246, 214, 224, 236),
        )
      }
    }

    // Cores.
    for i = 0; i < cores.length(); i = i + 1 {
      if not(cores[i].active) {
        continue
      }
      let cx : Int = (cores[i].x - cam_x).to_int()
      let cy : Int = cores[i].y.to_int()
      let col = if cores[i].kind == 0 {
        @raylib.Color::new(112, 234, 194, 244)
      } else if cores[i].kind == 1 {
        @raylib.Color::new(114, 196, 252, 244)
      } else {
        @raylib.Color::new(252, 214, 114, 244)
      }
      @raylib.draw_circle(cx, cy, cores[i].r, col)
      if cores[i].magnetized {
        @raylib.draw_circle_lines(
          cx,
          cy,
          cores[i].r + 4.0,
          @raylib.Color::new(224, 250, 255, 220),
        )
      }
    }

    // Boxes.
    for i = 0; i < boxes.length(); i = i + 1 {
      if not(boxes[i].active) {
        continue
      }
      let bx : Int = (boxes[i].x - boxes[i].r - cam_x).to_int()
      let by : Int = (boxes[i].y - boxes[i].r).to_int()
      let bs : Int = (boxes[i].r * 2.0).to_int()
      let col = if boxes[i].kind == 0 {
        @raylib.Color::new(96, 110, 138, 236)
      } else {
        @raylib.Color::new(126, 140, 166, 236)
      }
      @raylib.draw_rectangle(bx, by, bs, bs, col)
      @raylib.draw_rectangle_lines(
        bx,
        by,
        bs,
        bs,
        @raylib.Color::new(184, 206, 232, 170),
      )
      if boxes[i].magnetized {
        @raylib.draw_circle_lines(
          (boxes[i].x - cam_x).to_int(),
          boxes[i].y.to_int(),
          boxes[i].r + 5.0,
          @raylib.Color::new(210, 242, 255, 176),
        )
      }
    }

    // Drones.
    for i = 0; i < drones.length(); i = i + 1 {
      if not(drones[i].active) {
        continue
      }

      let dx : Int = (drones[i].x - cam_x).to_int()
      let dy : Int = drones[i].y.to_int()
      if drones[i].kind == 0 {
        @raylib.draw_circle(
          dx,
          dy,
          16.0,
          @raylib.Color::new(230, 102, 108, 244),
        )
        @raylib.draw_circle_lines(
          dx,
          dy,
          20.0,
          @raylib.Color::new(252, 220, 224, 190),
        )
      } else if drones[i].kind == 1 {
        @raylib.draw_rectangle(
          dx - 18,
          dy - 14,
          36,
          28,
          @raylib.Color::new(240, 152, 78, 242),
        )
        @raylib.draw_rectangle_lines(
          dx - 22,
          dy - 18,
          44,
          36,
          @raylib.Color::new(252, 228, 200, 186),
        )
      } else {
        @raylib.draw_rectangle(
          dx - 24,
          dy - 20,
          48,
          40,
          @raylib.Color::new(166, 96, 190, 240),
        )
        @raylib.draw_circle(
          dx,
          dy - 4,
          12.0,
          @raylib.Color::new(240, 200, 254, 218),
        )
      }
    }

    // Bolts.
    for i = 0; i < bolts.length(); i = i + 1 {
      if not(bolts[i].active) {
        continue
      }
      let bx : Int = (bolts[i].x - cam_x).to_int()
      let by : Int = bolts[i].y.to_int()
      let col = if bolts[i].team == 1 {
        @raylib.Color::new(248, 244, 152, 250)
      } else if bolts[i].kind == 1 {
        @raylib.Color::new(248, 124, 230, 246)
      } else {
        @raylib.Color::new(252, 130, 138, 242)
      }
      @raylib.draw_circle(bx, by, bolts[i].r, col)
    }

    // Player.
    let px : Int = (player.x - cam_x).to_int()
    let py : Int = player.y.to_int()
    let pcol = if player.inv_t > 0.0 {
      @raylib.Color::new(252, 252, 252, 236)
    } else {
      @raylib.Color::new(94, 190, 250, 248)
    }

    @raylib.draw_rectangle(px - 15, py - 23, 30, 46, pcol)
    @raylib.draw_circle(
      px,
      py - 22,
      9.0,
      @raylib.Color::new(210, 242, 255, 252),
    )

    @raylib.draw_line(
      px,
      py - 10,
      (player.x - cam_x + Float::from_int(player.face) * 24.0).to_int(),
      py - 10,
      @raylib.Color::new(194, 232, 252, 224),
    )

    if player.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        px,
        py,
        28.0,
        @raylib.Color::new(124, 218, 252, 212),
      )
    }

    if player.magnet_on {
      @raylib.draw_circle_lines(
        px,
        py - 8,
        310.0,
        @raylib.Color::new(112, 224, 248, 110),
      )
      for i = 0; i < cores.length(); i = i + 1 {
        if not(cores[i].active) || not(cores[i].magnetized) {
          continue
        }
        @raylib.draw_line(
          px,
          py - 8,
          (cores[i].x - cam_x).to_int(),
          cores[i].y.to_int(),
          @raylib.Color::new(126, 232, 252, 116),
        )
      }
      for i = 0; i < boxes.length(); i = i + 1 {
        if not(boxes[i].active) || not(boxes[i].magnetized) {
          continue
        }
        @raylib.draw_line(
          px,
          py - 8,
          (boxes[i].x - cam_x).to_int(),
          boxes[i].y.to_int(),
          @raylib.Color::new(126, 232, 252, 72),
        )
      }
    }

    // Particles.
    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let alpha : Int = (clampf(particles[i].life / 0.82, 0.0, 1.0) * 255.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(112, 224, 252, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 236, 144, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(252, 130, 130, alpha)
      } else {
        @raylib.Color::new(226, 160, 252, alpha)
      }
      @raylib.draw_circle(
        (particles[i].x - cam_x).to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    // HUD top.
    @raylib.draw_rectangle(0, 0, sw, 82, @raylib.Color::new(8, 12, 20, 230))

    @raylib.draw_text(
      "Magnet Lab Escape 2026",
      16,
      10,
      30,
      @raylib.Color::new(208, 236, 250, 248),
    )

    @raylib.draw_text(
      "Score \{player.score}",
      20,
      46,
      22,
      @raylib.Color::new(252, 228, 166, 252),
    )
    @raylib.draw_text(
      "Delivered \{player.delivered}/\{target_cores}",
      206,
      46,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Cargo \{player.cargo}",
      494,
      46,
      22,
      @raylib.Color::new(214, 236, 252, 248),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      634,
      46,
      22,
      @raylib.Color::new(170, 236, 192, 250),
    )
    @raylib.draw_text(
      "Best \{player.best_combo}",
      788,
      46,
      22,
      @raylib.Color::new(170, 210, 252, 250),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      954,
      46,
      22,
      @raylib.Color::new(248, 214, 174, 252),
    )
    @raylib.draw_text(
      "FPS \{@raylib.get_fps()}",
      sw - 116,
      12,
      22,
      @raylib.Color::new(176, 212, 238, 218),
    )

    // Gauges.
    let hp_fill : Int = (clampf(player.hp / 100.0, 0.0, 1.0) * 230.0).to_int()
    let en_fill : Int = (clampf(player.energy / 100.0, 0.0, 1.0) * 230.0).to_int()
    let heat_fill : Int = (clampf(player.heat / 100.0, 0.0, 1.0) * 230.0).to_int()

    @raylib.draw_rectangle(16, 92, 230, 11, @raylib.Color::new(22, 26, 38, 255))
    @raylib.draw_rectangle(
      16,
      92,
      hp_fill,
      11,
      @raylib.Color::new(226, 98, 116, 255),
    )
    @raylib.draw_text("HP", 16, 106, 16, @raylib.Color::new(238, 206, 216, 255))

    @raylib.draw_rectangle(
      16,
      128,
      230,
      11,
      @raylib.Color::new(22, 26, 38, 255),
    )
    @raylib.draw_rectangle(
      16,
      128,
      en_fill,
      11,
      @raylib.Color::new(88, 188, 236, 255),
    )
    @raylib.draw_text("EN", 16, 142, 16, @raylib.Color::new(206, 230, 252, 255))

    @raylib.draw_rectangle(
      16,
      164,
      230,
      11,
      @raylib.Color::new(22, 26, 38, 255),
    )
    @raylib.draw_rectangle(
      16,
      164,
      heat_fill,
      11,
      @raylib.Color::new(244, 170, 96, 255),
    )
    @raylib.draw_text(
      "HEAT",
      16,
      178,
      16,
      @raylib.Color::new(246, 222, 192, 255),
    )

    @raylib.draw_text(
      "Dash \{(player.dash_cd * 10.0).to_int()}",
      272,
      100,
      19,
      @raylib.Color::new(228, 238, 250, 244),
    )
    let polarity_label : String = if player.polarity > 0 { "+" } else { "-" }
    @raylib.draw_text(
      "Polarity \{polarity_label}",
      272,
      128,
      19,
      @raylib.Color::new(228, 238, 250, 244),
    )

    // Navigation strip.
    let nav_x : Int = 446
    let nav_y : Int = 98
    let nav_w : Int = 790
    let nav_h : Int = 28
    @raylib.draw_rectangle(
      nav_x,
      nav_y,
      nav_w,
      nav_h,
      @raylib.Color::new(16, 20, 30, 210),
    )
    @raylib.draw_rectangle_lines(
      nav_x,
      nav_y,
      nav_w,
      nav_h,
      @raylib.Color::new(90, 126, 166, 210),
    )

    let pnx : Int = nav_x +
      (player.x / world_w * Float::from_int(nav_w)).to_int()
    @raylib.draw_circle(
      pnx,
      nav_y + nav_h / 2,
      5.0,
      @raylib.Color::new(128, 214, 252, 252),
    )

    let rnx : Int = nav_x +
      (reactor_x / world_w * Float::from_int(nav_w)).to_int()
    @raylib.draw_circle(
      rnx,
      nav_y + nav_h / 2,
      4.0,
      @raylib.Color::new(160, 246, 255, 246),
    )

    for i = 0; i < gates.length(); i = i + 1 {
      if not(gates[i].active) {
        continue
      }
      let gx : Int = nav_x +
        (gates[i].x / world_w * Float::from_int(nav_w)).to_int()
      let gc = if gates[i].open {
        @raylib.Color::new(112, 224, 166, 236)
      } else {
        @raylib.Color::new(234, 124, 146, 236)
      }
      @raylib.draw_line(gx, nav_y + 4, gx, nav_y + nav_h - 4, gc)
    }

    if msg_t > 0.0 {
      @raylib.draw_rectangle(
        sw / 2 - 340,
        sh - 66,
        680,
        36,
        @raylib.Color::new(12, 18, 30, 210),
      )
      @raylib.draw_text(
        msg,
        sw / 2 - 320,
        sh - 58,
        22,
        @raylib.Color::new(226, 244, 252, 248),
      )
    }

    draw_touch_ui(state)

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 162))
      @raylib.draw_rectangle(
        174,
        126,
        934,
        506,
        @raylib.Color::new(12, 18, 34, 236),
      )
      @raylib.draw_rectangle_lines(
        174,
        126,
        934,
        506,
        @raylib.Color::new(98, 154, 208, 206),
      )

      @raylib.draw_text(
        "MAGNET LAB ESCAPE 2026",
        282,
        188,
        56,
        @raylib.Color::new(188, 236, 252, 255),
      )
      @raylib.draw_text(
        "Deliver 120 cores to the reactor while surviving drone waves.",
        250,
        286,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Closed gates unlock at delivery milestones.",
        360,
        330,
        30,
        @raylib.Color::new(214, 228, 246, 248),
      )
      @raylib.draw_text(
        "Move: A/D or Arrows   Jump: W/Up/Space",
        326,
        388,
        28,
        @raylib.Color::new(194, 220, 242, 246),
      )
      @raylib.draw_text(
        "Magnet: J (hold)   Polarity: K   Fire: L   Dash: RightShift",
        226,
        430,
        28,
        @raylib.Color::new(194, 220, 242, 246),
      )
      @raylib.draw_text(
        "Touch controls are shown on screen for mobile.",
        326,
        472,
        28,
        @raylib.Color::new(194, 220, 242, 246),
      )
      @raylib.draw_text(
        "Press Enter or tap to begin",
        440,
        550,
        34,
        @raylib.Color::new(246, 236, 176, 252),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 176))
      @raylib.draw_rectangle(
        280,
        194,
        720,
        360,
        @raylib.Color::new(14, 28, 36, 242),
      )
      @raylib.draw_rectangle_lines(
        280,
        194,
        720,
        360,
        @raylib.Color::new(106, 220, 188, 214),
      )

      @raylib.draw_text(
        "ESCAPE COMPLETE",
        390,
        244,
        62,
        @raylib.Color::new(164, 246, 206, 254),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        500,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Delivered: \{player.delivered}   Best Combo: \{player.best_combo}",
        372,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to run again",
        420,
        470,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 186))
      @raylib.draw_rectangle(
        280,
        194,
        720,
        360,
        @raylib.Color::new(30, 16, 20, 246),
      )
      @raylib.draw_rectangle_lines(
        280,
        194,
        720,
        360,
        @raylib.Color::new(214, 106, 120, 214),
      )

      @raylib.draw_text(
        "MISSION FAILED",
        420,
        244,
        62,
        @raylib.Color::new(248, 164, 176, 252),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        500,
        338,
        36,
        @raylib.Color::new(236, 246, 252, 252),
      )
      @raylib.draw_text(
        "Delivered: \{player.delivered} / \{target_cores}",
        438,
        388,
        30,
        @raylib.Color::new(214, 236, 252, 246),
      )
      @raylib.draw_text(
        "Press R / Enter / Tap to retry",
        440,
        470,
        32,
        @raylib.Color::new(248, 236, 184, 252),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
