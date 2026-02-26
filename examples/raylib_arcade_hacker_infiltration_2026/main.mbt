///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let map_w : Int = 22

///|
let map_h : Int = 13

///|
let tile : Int = 48

///|
let map_x : Int = 112

///|
let map_y : Int = 72

///|
let max_terminals : Int = 20

///|
let max_guards : Int = 64

///|
let max_cameras : Int = 30

///|
let max_pickups : Int = 30

///|
let max_particles : Int = 960

///|
struct Player {
  mut gx : Int
  mut gy : Int
  mut hp : Float
  mut energy : Float
  mut hack_cd : Float
  mut emp_cd : Float
  mut cloak_cd : Float
  mut cloak_t : Float
  mut hurt_cd : Float
  mut face_x : Int
  mut face_y : Int
  mut score : Int
  mut combo : Int
  mut hacked_total : Int
}

///|
struct Terminal {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut hacked : Bool
}

///|
struct Guard {
  mut active : Bool
  mut kind : Int
  mut gx : Int
  mut gy : Int
  mut hp : Float
  mut move_cd : Float
  mut atk_cd : Float
  mut stun_t : Float
  mut alert_t : Float
  mut patrol_dir : Int
}

///|
struct Camera {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut dir : Int
  mut rot_t : Float
  mut disable_t : Float
}

///|
struct Pickup {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut kind : Int
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut t : Float
  mut life : Float
  mut kind : Int
}

///|
fn idx(gx : Int, gy : Int) -> Int {
  gy * map_w + gx
}

///|
fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < map_w && gy < map_h
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
fn absi(v : Int) -> Int {
  if v < 0 {
    -v
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
fn cell_center_x(gx : Int) -> Float {
  Float::from_int(map_x + gx * tile + tile / 2)
}

///|
fn cell_center_y(gy : Int) -> Float {
  Float::from_int(map_y + gy * tile + tile / 2)
}

///|
fn clear_terminals(terminals : Array[Terminal]) -> Unit {
  for i = 0; i < terminals.length(); i = i + 1 {
    terminals[i].active = false
    terminals[i].gx = 0
    terminals[i].gy = 0
    terminals[i].hacked = false
  }
}

///|
fn clear_guards(guards : Array[Guard]) -> Unit {
  for i = 0; i < guards.length(); i = i + 1 {
    guards[i].active = false
    guards[i].kind = 0
    guards[i].gx = 0
    guards[i].gy = 0
    guards[i].hp = 0.0
    guards[i].move_cd = 0.0
    guards[i].atk_cd = 0.0
    guards[i].stun_t = 0.0
    guards[i].alert_t = 0.0
    guards[i].patrol_dir = 0
  }
}

///|
fn clear_cameras(cameras : Array[Camera]) -> Unit {
  for i = 0; i < cameras.length(); i = i + 1 {
    cameras[i].active = false
    cameras[i].gx = 0
    cameras[i].gy = 0
    cameras[i].dir = 0
    cameras[i].rot_t = 0.0
    cameras[i].disable_t = 0.0
  }
}

///|
fn clear_pickups(pickups : Array[Pickup]) -> Unit {
  for i = 0; i < pickups.length(); i = i + 1 {
    pickups[i].active = false
    pickups[i].gx = 0
    pickups[i].gy = 0
    pickups[i].kind = 0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].t = 0.0
    parts[i].life = 0.0
    parts[i].kind = 0
  }
}

///|
fn guard_at(guards : Array[Guard], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < guards.length(); i = i + 1 {
    if guards[i].active && guards[i].gx == gx && guards[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn terminal_at(terminals : Array[Terminal], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < terminals.length(); i = i + 1 {
    if terminals[i].active &&
      terminals[i].gx == gx &&
      terminals[i].gy == gy &&
      not(terminals[i].hacked) {
      found = i
      break
    }
  }
  found
}

///|
fn pickup_at(pickups : Array[Pickup], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < pickups.length(); i = i + 1 {
    if pickups[i].active && pickups[i].gx == gx && pickups[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn camera_at(cameras : Array[Camera], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < cameras.length(); i = i + 1 {
    if cameras[i].active && cameras[i].gx == gx && cameras[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn can_walk(tiles : Array[Int], gx : Int, gy : Int) -> Bool {
  in_bounds(gx, gy) && tiles[idx(gx, gy)] == 0
}

///|
fn line_clear(
  tiles : Array[Int],
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  if x0 == x1 {
    let step : Int = if y1 > y0 { 1 } else { -1 }
    let mut y = y0 + step
    let mut clear = true
    while y != y1 {
      if tiles[idx(x0, y)] == 1 {
        clear = false
        break
      }
      y = y + step
    }
    clear
  } else if y0 == y1 {
    let step : Int = if x1 > x0 { 1 } else { -1 }
    let mut x = x0 + step
    let mut clear = true
    while x != x1 {
      if tiles[idx(x, y0)] == 1 {
        clear = false
        break
      }
      x = x + step
    }
    clear
  } else {
    false
  }
}

///|
fn visible_line(
  tiles : Array[Int],
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  max_dist : Int,
) -> Bool {
  if x0 == x1 {
    let dist = absi(y1 - y0)
    dist <= max_dist && line_clear(tiles, x0, y0, x1, y1)
  } else if y0 == y1 {
    let dist = absi(x1 - x0)
    dist <= max_dist && line_clear(tiles, x0, y0, x1, y1)
  } else {
    false
  }
}

///|
fn camera_facing(cam : Camera, tx : Int, ty : Int) -> Bool {
  if cam.dir == 0 {
    tx == cam.gx && ty < cam.gy
  } else if cam.dir == 1 {
    ty == cam.gy && tx > cam.gx
  } else if cam.dir == 2 {
    tx == cam.gx && ty > cam.gy
  } else {
    ty == cam.gy && tx < cam.gx
  }
}

///|
fn spawn_guard(
  guards : Array[Guard],
  gx : Int,
  gy : Int,
  kind : Int,
  stage : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < guards.length(); i = i + 1 {
    if not(guards[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    guards[slot].active = true
    guards[slot].kind = kind
    guards[slot].gx = gx
    guards[slot].gy = gy
    guards[slot].hp = 24.0 +
      Float::from_int(kind) * 12.0 +
      Float::from_int(stage) * 2.0
    guards[slot].move_cd = randf(0.12, 0.36)
    guards[slot].atk_cd = 0.0
    guards[slot].stun_t = 0.0
    guards[slot].alert_t = 0.0
    guards[slot].patrol_dir = @raylib.get_random_value(0, 3)
    true
  }
}

///|
fn spawn_pickup(
  pickups : Array[Pickup],
  gx : Int,
  gy : Int,
  kind : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < pickups.length(); i = i + 1 {
    if not(pickups[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    pickups[slot].active = true
    pickups[slot].gx = gx
    pickups[slot].gy = gy
    pickups[slot].kind = kind
    true
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut left = n
  for i = 0; i < parts.length(); i = i + 1 {
    if left <= 0 {
      break
    }

    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(14, 76)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn draw_guard(g : Guard) -> Unit {
  if not(g.active) {
    ignore(())
  } else {
    let body_col = if g.kind == 0 {
      @raylib.Color::new(214, 106, 106, 255)
    } else if g.kind == 1 {
      @raylib.Color::new(196, 82, 122, 255)
    } else {
      @raylib.Color::new(164, 68, 138, 255)
    }

    let cx = cell_center_x(g.gx)
    let cy = cell_center_y(g.gy)
    @raylib.draw_circle(cx.to_int(), cy.to_int(), 15.0, body_col)
    @raylib.draw_circle(
      cx.to_int(),
      (cy - 18.0).to_int(),
      11.0,
      @raylib.Color::new(252, 224, 214, 255),
    )
    @raylib.draw_circle(
      (cx - 4.0).to_int(),
      (cy - 20.0).to_int(),
      2.6,
      @raylib.Color::new(34, 18, 30, 255),
    )
    @raylib.draw_circle(
      (cx + 4.0).to_int(),
      (cy - 20.0).to_int(),
      2.6,
      @raylib.Color::new(34, 18, 30, 255),
    )

    if g.stun_t > 0.0 {
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        19.0,
        @raylib.Color::new(136, 228, 255, 255),
      )
    }
  }
}

///|
fn draw_camera(c : Camera) -> Unit {
  if not(c.active) {
    ignore(())
  } else {
    let cx = cell_center_x(c.gx)
    let cy = cell_center_y(c.gy)

    let base_col = if c.disable_t > 0.0 {
      @raylib.Color::new(96, 112, 126, 255)
    } else {
      @raylib.Color::new(146, 222, 246, 255)
    }

    @raylib.draw_circle(cx.to_int(), cy.to_int(), 14.0, base_col)
    @raylib.draw_circle_lines(
      cx.to_int(),
      cy.to_int(),
      18.0,
      @raylib.Color::new(30, 38, 58, 255),
    )

    let ax : Float = if c.dir == 1 {
      12.0
    } else if c.dir == 3 {
      -12.0
    } else {
      0.0
    }
    let ay : Float = if c.dir == 2 {
      12.0
    } else if c.dir == 0 {
      -12.0
    } else {
      0.0
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(cx + ax, cy + ay),
      4.0,
      @raylib.Color::new(26, 32, 54, 255),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Arcade Hacker Infiltration 2026")
  @raylib.set_target_fps(60)

  let tiles : Array[Int] = Array::makei(map_w * map_h, fn(_i) { 0 })

  let terminals : Array[Terminal] = Array::makei(max_terminals, fn(_i) {
    { active: false, gx: 0, gy: 0, hacked: false }
  })

  let guards : Array[Guard] = Array::makei(max_guards, fn(_i) {
    {
      active: false,
      kind: 0,
      gx: 0,
      gy: 0,
      hp: 0.0,
      move_cd: 0.0,
      atk_cd: 0.0,
      stun_t: 0.0,
      alert_t: 0.0,
      patrol_dir: 0,
    }
  })

  let cameras : Array[Camera] = Array::makei(max_cameras, fn(_i) {
    { active: false, gx: 0, gy: 0, dir: 0, rot_t: 0.0, disable_t: 0.0 }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, gx: 0, gy: 0, kind: 0 }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      t: 0.0,
      life: 0.0,
      kind: 0,
    }
  })

  let player : Player = {
    gx: 1,
    gy: map_h - 2,
    hp: 100.0,
    energy: 100.0,
    hack_cd: 0.0,
    emp_cd: 0.0,
    cloak_cd: 0.0,
    cloak_t: 0.0,
    hurt_cd: 0.0,
    face_x: 1,
    face_y: 0,
    score: 0,
    combo: 0,
    hacked_total: 0,
  }

  let mut state : Int = 0
  let mut stage : Int = 1
  let max_stage : Int = 4

  let mut mission_time : Float = 420.0
  let mut stage_time : Float = 110.0

  let mut alarm : Float = 0.0
  let mut strikes : Int = 0

  let mut exit_x : Int = map_w - 2
  let mut exit_y : Int = 1
  let mut exit_open : Bool = false

  let mut terminal_total : Int = 0
  let mut terminal_done : Int = 0

  let mut guard_spawn_cd : Float = 7.0
  let mut pickup_spawn_cd : Float = 6.0

  let mut msg : String = "Hack data cores and escape"
  let mut msg_t : Float = 3.0

  let mut move_repeat_t : Float = 0.0

  let cell_free_for_spawn = fn(gx : Int, gy : Int, min_dist : Int) {
    if not(can_walk(tiles, gx, gy)) {
      false
    } else if absi(gx - player.gx) + absi(gy - player.gy) < min_dist {
      false
    } else if gx == exit_x && gy == exit_y {
      false
    } else if guard_at(guards, gx, gy) >= 0 {
      false
    } else if terminal_at(terminals, gx, gy) >= 0 {
      false
    } else if camera_at(cameras, gx, gy) >= 0 {
      false
    } else if pickup_at(pickups, gx, gy) >= 0 {
      false
    } else {
      true
    }
  }

  let count_hacked = fn() {
    let mut done = 0
    for i = 0; i < terminals.length(); i = i + 1 {
      if terminals[i].active && terminals[i].hacked {
        done = done + 1
      }
    }
    done
  }

  let setup_stage = fn(stage_i : Int) {
    for y = 0; y < map_h; y = y + 1 {
      for x = 0; x < map_w; x = x + 1 {
        if x == 0 || y == 0 || x == map_w - 1 || y == map_h - 1 {
          tiles[idx(x, y)] = 1
        } else {
          tiles[idx(x, y)] = 0
        }
      }
    }

    clear_terminals(terminals)
    clear_guards(guards)
    clear_cameras(cameras)
    clear_pickups(pickups)
    clear_particles(particles)

    player.gx = 1
    player.gy = map_h - 2
    player.face_x = 1
    player.face_y = 0
    player.hack_cd = 0.0
    player.emp_cd = 0.0
    player.cloak_cd = 0.0
    player.cloak_t = 0.0
    player.hurt_cd = 0.0

    exit_x = map_w - 2
    exit_y = 1
    exit_open = false

    // Partition walls with several random gates.
    for wi = 0; wi < 3; wi = wi + 1 {
      let wall_x = 5 + wi * 5
      let g1 = @raylib.get_random_value(1, map_h - 2)
      let mut g2 = @raylib.get_random_value(1, map_h - 2)
      if g2 == g1 {
        g2 = clampi(g2 + 2, 1, map_h - 2)
      }
      let g3 = map_h / 2
      for y = 1; y < map_h - 1; y = y + 1 {
        if y == g1 || y == g2 || y == g3 {
          ignore(())
        } else {
          tiles[idx(wall_x, y)] = 1
        }
      }
    }

    for hi = 0; hi < 2; hi = hi + 1 {
      let wall_y = 4 + hi * 4
      let g1 = @raylib.get_random_value(1, map_w - 2)
      let mut g2 = @raylib.get_random_value(1, map_w - 2)
      let mut g3 = @raylib.get_random_value(1, map_w - 2)
      if g2 == g1 {
        g2 = clampi(g2 + 2, 1, map_w - 2)
      }
      if g3 == g1 || g3 == g2 {
        g3 = clampi(g3 + 3, 1, map_w - 2)
      }

      for x = 1; x < map_w - 1; x = x + 1 {
        if x == g1 || x == g2 || x == g3 {
          ignore(())
        } else {
          tiles[idx(x, wall_y)] = 1
        }
      }
    }

    // Ensure spawn/exit corridors.
    tiles[idx(player.gx, player.gy)] = 0
    tiles[idx(player.gx + 1, player.gy)] = 0
    tiles[idx(player.gx, player.gy - 1)] = 0
    tiles[idx(exit_x, exit_y)] = 0
    tiles[idx(exit_x - 1, exit_y)] = 0
    tiles[idx(exit_x, exit_y + 1)] = 0

    terminal_total = clampi(3 + stage_i, 3, 8)
    terminal_done = 0

    for i = 0; i < terminal_total; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 240; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 6) {
          let mut slot : Int = -1
          for k = 0; k < terminals.length(); k = k + 1 {
            if not(terminals[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            terminals[slot].active = true
            terminals[slot].gx = gx
            terminals[slot].gy = gy
            terminals[slot].hacked = false
          }
          break
        }
      }
    }

    let camera_count = clampi(3 + stage_i * 2, 3, 16)
    for i = 0; i < camera_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 240; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 5) {
          let mut slot : Int = -1
          for k = 0; k < cameras.length(); k = k + 1 {
            if not(cameras[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            cameras[slot].active = true
            cameras[slot].gx = gx
            cameras[slot].gy = gy
            cameras[slot].dir = @raylib.get_random_value(0, 3)
            cameras[slot].rot_t = randf(0.6, 1.8)
            cameras[slot].disable_t = 0.0
          }
          break
        }
      }
    }

    let guard_count = clampi(5 + stage_i * 3, 5, 30)
    for i = 0; i < guard_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 260; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 7) {
          let kind = @raylib.get_random_value(0, 2)
          ignore(spawn_guard(guards, gx, gy, kind, stage_i))
          break
        }
      }
    }

    let pickup_count = clampi(4 + stage_i, 4, 10)
    for i = 0; i < pickup_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 200; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 4) {
          ignore(spawn_pickup(pickups, gx, gy, @raylib.get_random_value(0, 3)))
          break
        }
      }
    }

    stage_time = 96.0 + Float::from_int(stage_i) * 18.0
    guard_spawn_cd = randf(6.4, 9.4)
    pickup_spawn_cd = randf(4.8, 7.2)
    alarm = 0.0

    msg = "Stage \{stage_i}: hack \{terminal_total} cores"
    msg_t = 1.8
  }

  let reset_run = fn() {
    stage = 1
    mission_time = 420.0
    stage_time = 110.0

    alarm = 0.0
    strikes = 0

    player.hp = 100.0
    player.energy = 100.0
    player.score = 0
    player.combo = 0
    player.hacked_total = 0

    setup_stage(stage)
  }

  let damage_player = fn(amount : Float, text : String) {
    if player.hurt_cd > 0.0 {
      ignore(())
    } else {
      player.hp = player.hp - amount
      player.hurt_cd = 0.46
      player.combo = 0
      msg = text
      msg_t = 0.60
      burst(
        particles,
        cell_center_x(player.gx),
        cell_center_y(player.gy),
        14,
        0.18,
        3,
      )
    }
  }

  let defeat_guard = fn(slot : Int, pts : Int) {
    let gx = guards[slot].gx
    let gy = guards[slot].gy
    guards[slot].active = false

    player.combo = player.combo + 1
    player.score = player.score + pts + player.combo * 3 + stage * 2
    burst(particles, cell_center_x(gx), cell_center_y(gy), 12, 0.16, 1)

    if @raylib.get_random_value(0, 99) < 20 {
      ignore(spawn_pickup(pickups, gx, gy, @raylib.get_random_value(0, 3)))
    }
  }

  let attempt_move = fn(dx : Int, dy : Int) {
    if dx == 0 && dy == 0 {
      ignore(())
    } else {
      player.face_x = dx
      player.face_y = dy

      let nx = player.gx + dx
      let ny = player.gy + dy
      if not(can_walk(tiles, nx, ny)) {
        msg = "Path blocked"
        msg_t = 0.25
      } else if guard_at(guards, nx, ny) >= 0 {
        msg = "Guard blocking"
        msg_t = 0.25
      } else {
        player.gx = nx
        player.gy = ny
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

    if player.hurt_cd > 0.0 {
      player.hurt_cd = player.hurt_cd - dt
      if player.hurt_cd < 0.0 {
        player.hurt_cd = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      mission_time = mission_time - dt
      stage_time = stage_time - dt

      if stage_time <= 0.0 {
        stage_time = 26.0
        alarm = alarm + 24.0
        msg = "Sector pressure rising"
        msg_t = 0.65
      }

      player.energy = player.energy + dt * 12.0
      if player.energy > 100.0 {
        player.energy = 100.0
      }

      alarm = alarm - dt * (if player.cloak_t > 0.0 { 16.0 } else { 8.0 })
      if alarm < 0.0 {
        alarm = 0.0
      }

      player.hack_cd = player.hack_cd - dt
      if player.hack_cd < 0.0 {
        player.hack_cd = 0.0
      }

      player.emp_cd = player.emp_cd - dt
      if player.emp_cd < 0.0 {
        player.emp_cd = 0.0
      }

      player.cloak_cd = player.cloak_cd - dt
      if player.cloak_cd < 0.0 {
        player.cloak_cd = 0.0
      }

      player.cloak_t = player.cloak_t - dt
      if player.cloak_t < 0.0 {
        player.cloak_t = 0.0
      }

      let pad_x = 24
      let pad_y = sh - 198
      let btn_x = sw - 298
      let btn_y = sh - 236

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut hack_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut emp_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut cloak_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 58, 78, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 58, 78, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 116, 78, 58) {
          move_d = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 8, btn_y + 10, 120, 92) {
          hack_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 136, btn_y + 10, 120, 92) {
          emp_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 72, btn_y + 116, 152, 102) {
          cloak_press = true
        }
      }

      let mut mdx = 0
      let mut mdy = 0
      if move_l {
        mdx = -1
      } else if move_r {
        mdx = 1
      } else if move_u {
        mdy = -1
      } else if move_d {
        mdy = 1
      }

      let move_pressed = @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) ||
        @raylib.is_key_pressed(@raylib.KeyRight) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeyDown)

      if move_repeat_t > 0.0 {
        move_repeat_t = move_repeat_t - dt
        if move_repeat_t < 0.0 {
          move_repeat_t = 0.0
        }
      }

      if (mdx != 0 || mdy != 0) &&
        (move_pressed || move_repeat_t <= 0.0 || touching) {
        attempt_move(mdx, mdy)
        move_repeat_t = if touching { 0.14 } else { 0.11 }
      }

      if hack_press && player.hack_cd <= 0.0 {
        let mut target : Int = -1
        for i = 0; i < terminals.length(); i = i + 1 {
          if terminals[i].active && not(terminals[i].hacked) {
            let d = absi(terminals[i].gx - player.gx) +
              absi(terminals[i].gy - player.gy)
            if d <= 1 {
              target = i
              break
            }
          }
        }

        if target >= 0 {
          if player.energy >= 14.0 {
            player.energy = player.energy - 14.0
            terminals[target].hacked = true
            player.hacked_total = player.hacked_total + 1
            player.combo = player.combo + 1
            player.score = player.score + 96 + player.combo * 6 + stage * 12
            player.hack_cd = 0.42
            msg = "Core hacked"
            msg_t = 0.56
            burst(
              particles,
              cell_center_x(terminals[target].gx),
              cell_center_y(terminals[target].gy),
              14,
              0.16,
              2,
            )
          } else {
            msg = "Need more energy"
            msg_t = 0.42
            player.hack_cd = 0.20
          }
        } else {
          msg = "Move next to a core"
          msg_t = 0.35
          player.hack_cd = 0.18
        }
      }

      if emp_press && player.emp_cd <= 0.0 {
        if player.energy >= 30.0 {
          player.energy = player.energy - 30.0
          player.emp_cd = 6.0
          alarm = alarm - 36.0
          if alarm < 0.0 {
            alarm = 0.0
          }

          let mut disabled = 0
          let mut shocked = 0
          for i = 0; i < cameras.length(); i = i + 1 {
            if cameras[i].active {
              let d = absi(cameras[i].gx - player.gx) +
                absi(cameras[i].gy - player.gy)
              if d <= 6 {
                cameras[i].disable_t = 4.2
                disabled = disabled + 1
              }
            }
          }

          for i = 0; i < guards.length(); i = i + 1 {
            if guards[i].active {
              let d = absi(guards[i].gx - player.gx) +
                absi(guards[i].gy - player.gy)
              if d <= 5 {
                guards[i].stun_t = 2.6
                guards[i].hp = guards[i].hp - 10.0
                shocked = shocked + 1
                if guards[i].hp <= 0.0 {
                  defeat_guard(i, 62)
                }
              }
            }
          }

          msg = "EMP: \{disabled} cams / \{shocked} guards"
          msg_t = 0.68
          burst(
            particles,
            cell_center_x(player.gx),
            cell_center_y(player.gy),
            26,
            0.20,
            2,
          )
        } else {
          msg = "Not enough energy for EMP"
          msg_t = 0.42
        }
      }

      if cloak_press && player.cloak_cd <= 0.0 {
        if player.energy >= 24.0 {
          player.energy = player.energy - 24.0
          player.cloak_cd = 8.0
          player.cloak_t = 4.4
          msg = "Cloak enabled"
          msg_t = 0.58
          burst(
            particles,
            cell_center_x(player.gx),
            cell_center_y(player.gy),
            18,
            0.14,
            2,
          )
        } else {
          msg = "Not enough energy for cloak"
          msg_t = 0.42
        }
      }

      for i = 0; i < cameras.length(); i = i + 1 {
        if not(cameras[i].active) {
          continue
        }

        cameras[i].disable_t = cameras[i].disable_t - dt
        if cameras[i].disable_t < 0.0 {
          cameras[i].disable_t = 0.0
        }

        cameras[i].rot_t = cameras[i].rot_t - dt
        if cameras[i].rot_t <= 0.0 {
          cameras[i].rot_t = 1.5 - Float::from_int(stage) * 0.12
          if cameras[i].rot_t < 0.62 {
            cameras[i].rot_t = 0.62
          }
          cameras[i].dir = (cameras[i].dir + 1) % 4
        }

        if cameras[i].disable_t <= 0.0 && player.cloak_t <= 0.0 {
          if camera_facing(cameras[i], player.gx, player.gy) &&
            visible_line(
              tiles,
              cameras[i].gx,
              cameras[i].gy,
              player.gx,
              player.gy,
              8,
            ) {
            alarm = alarm + dt * 24.0
          }
        }
      }

      for i = 0; i < guards.length(); i = i + 1 {
        if not(guards[i].active) {
          continue
        }

        guards[i].move_cd = guards[i].move_cd - dt
        guards[i].atk_cd = guards[i].atk_cd - dt
        guards[i].stun_t = guards[i].stun_t - dt
        guards[i].alert_t = guards[i].alert_t - dt

        if guards[i].atk_cd < 0.0 {
          guards[i].atk_cd = 0.0
        }
        if guards[i].stun_t < 0.0 {
          guards[i].stun_t = 0.0
        }
        if guards[i].alert_t < 0.0 {
          guards[i].alert_t = 0.0
        }

        if guards[i].stun_t > 0.0 {
          continue
        }

        let sees = player.cloak_t <= 0.0 &&
          visible_line(
            tiles,
            guards[i].gx,
            guards[i].gy,
            player.gx,
            player.gy,
            7,
          )
        if sees {
          guards[i].alert_t = 2.2
          alarm = alarm + dt * (16.0 + Float::from_int(guards[i].kind) * 6.0)

          let dist = if guards[i].gx == player.gx {
            absi(guards[i].gy - player.gy)
          } else if guards[i].gy == player.gy {
            absi(guards[i].gx - player.gx)
          } else {
            99
          }

          if dist <= 5 && guards[i].atk_cd <= 0.0 {
            guards[i].atk_cd = 1.1 - Float::from_int(guards[i].kind) * 0.14
            if guards[i].atk_cd < 0.48 {
              guards[i].atk_cd = 0.48
            }
            damage_player(
              8.0 + Float::from_int(guards[i].kind) * 2.8,
              "Guard laser hit",
            )
          }
        }

        let adj = absi(guards[i].gx - player.gx) +
          absi(guards[i].gy - player.gy)
        if adj <= 1 && guards[i].atk_cd <= 0.0 {
          guards[i].atk_cd = 0.78
          damage_player(
            10.0 + Float::from_int(guards[i].kind) * 3.0,
            "Guard melee",
          )
        }

        if guards[i].move_cd <= 0.0 {
          guards[i].move_cd = 0.34 - Float::from_int(guards[i].kind) * 0.05
          if guards[i].move_cd < 0.14 {
            guards[i].move_cd = 0.14
          }

          let mut dx = 0
          let mut dy = 0

          if sees || guards[i].alert_t > 0.0 || alarm > 42.0 {
            let tx = player.gx - guards[i].gx
            let ty = player.gy - guards[i].gy

            if absi(tx) > absi(ty) {
              dx = if tx < 0 { -1 } else if tx > 0 { 1 } else { 0 }
            } else {
              dy = if ty < 0 { -1 } else if ty > 0 { 1 } else { 0 }
            }
          } else {
            if @raylib.get_random_value(0, 99) < 20 {
              guards[i].patrol_dir = @raylib.get_random_value(0, 3)
            }

            if guards[i].patrol_dir == 0 {
              dy = -1
            } else if guards[i].patrol_dir == 1 {
              dx = 1
            } else if guards[i].patrol_dir == 2 {
              dy = 1
            } else {
              dx = -1
            }
          }

          let mut nx = guards[i].gx + dx
          let mut ny = guards[i].gy + dy

          let bad_step = not(can_walk(tiles, nx, ny)) ||
            guard_at(guards, nx, ny) >= 0 ||
            (nx == player.gx && ny == player.gy)

          if bad_step {
            if dx != 0 {
              dx = 0
              let py = player.gy - guards[i].gy
              dy = if py < 0 { -1 } else if py > 0 { 1 } else { 0 }
            } else if dy != 0 {
              dy = 0
              let px = player.gx - guards[i].gx
              dx = if px < 0 { -1 } else if px > 0 { 1 } else { 0 }
            }

            nx = guards[i].gx + dx
            ny = guards[i].gy + dy
          }

          if can_walk(tiles, nx, ny) &&
            guard_at(guards, nx, ny) < 0 &&
            not(nx == player.gx && ny == player.gy) {
            guards[i].gx = nx
            guards[i].gy = ny
          } else {
            guards[i].patrol_dir = @raylib.get_random_value(0, 3)
          }
        }
      }

      if alarm >= 100.0 {
        alarm = 34.0
        strikes = strikes + 1
        damage_player(9.0 + Float::from_int(stage) * 1.8, "Security lockdown")

        msg = "Security strike \{strikes}/3"
        msg_t = 0.72

        for _r = 0; _r < 2; _r = _r + 1 {
          for _a = 0; _a < 220; _a = _a + 1 {
            let gx = @raylib.get_random_value(1, map_w - 2)
            let gy = @raylib.get_random_value(1, map_h - 2)
            if can_walk(tiles, gx, gy) &&
              guard_at(guards, gx, gy) < 0 &&
              absi(gx - player.gx) + absi(gy - player.gy) >= 6 {
              ignore(
                spawn_guard(
                  guards,
                  gx,
                  gy,
                  @raylib.get_random_value(1, 2),
                  stage,
                ),
              )
              break
            }
          }
        }
      }

      guard_spawn_cd = guard_spawn_cd - dt
      if guard_spawn_cd <= 0.0 {
        guard_spawn_cd = randf(7.0, 11.0)

        for _a = 0; _a < 240; _a = _a + 1 {
          let gx = @raylib.get_random_value(1, map_w - 2)
          let gy = @raylib.get_random_value(1, map_h - 2)
          if can_walk(tiles, gx, gy) &&
            guard_at(guards, gx, gy) < 0 &&
            absi(gx - player.gx) + absi(gy - player.gy) >= 7 {
            ignore(
              spawn_guard(guards, gx, gy, @raylib.get_random_value(0, 2), stage),
            )
            break
          }
        }
      }

      pickup_spawn_cd = pickup_spawn_cd - dt
      if pickup_spawn_cd <= 0.0 {
        pickup_spawn_cd = randf(4.8, 7.4)
        for _a = 0; _a < 220; _a = _a + 1 {
          let gx = @raylib.get_random_value(1, map_w - 2)
          let gy = @raylib.get_random_value(1, map_h - 2)
          if can_walk(tiles, gx, gy) && pickup_at(pickups, gx, gy) < 0 {
            ignore(
              spawn_pickup(pickups, gx, gy, @raylib.get_random_value(0, 3)),
            )
            break
          }
        }
      }

      let pslot = pickup_at(pickups, player.gx, player.gy)
      if pslot >= 0 {
        if pickups[pslot].kind == 0 {
          player.hp = player.hp + 24.0
          if player.hp > 100.0 {
            player.hp = 100.0
          }
          msg = "Med patch"
        } else if pickups[pslot].kind == 1 {
          player.energy = player.energy + 34.0
          if player.energy > 100.0 {
            player.energy = 100.0
          }
          msg = "Battery"
        } else if pickups[pslot].kind == 2 {
          alarm = alarm - 22.0
          if alarm < 0.0 {
            alarm = 0.0
          }
          player.score = player.score + 80
          msg = "Signal jammer"
        } else {
          player.score = player.score + 110
          player.combo = player.combo + 1
          msg = "Data cache +110"
        }

        msg_t = 0.55
        pickups[pslot].active = false
        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          12,
          0.14,
          2,
        )
      }

      terminal_done = count_hacked()
      exit_open = terminal_done >= terminal_total

      if exit_open && player.gx == exit_x && player.gy == exit_y {
        if stage < max_stage {
          stage = stage + 1
          player.score = player.score + 260 + stage * 44
          player.hp = clampf(player.hp + 20.0, 0.0, 100.0)
          player.energy = clampf(player.energy + 28.0, 0.0, 100.0)
          setup_stage(stage)
        } else {
          state = 2
        }
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
        } else {
          particles[i].x = particles[i].x + particles[i].vx * dt
          particles[i].y = particles[i].y + particles[i].vy * dt
          particles[i].vx = particles[i].vx * (1.0 - dt * 2.0)
          particles[i].vy = particles[i].vy + 220.0 * dt
        }
      }

      if strikes >= 3 || player.hp <= 0.0 || mission_time <= 0.0 {
        state = 3
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }

      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }

    @raylib.begin_drawing()

    let bg_col = if state == 2 {
      @raylib.Color::new(14, 24, 22, 255)
    } else if state == 3 {
      @raylib.Color::new(28, 14, 18, 255)
    } else {
      @raylib.Color::new(10, 14, 24, 255)
    }
    @raylib.clear_background(bg_col)

    @raylib.draw_rectangle(
      map_x - 20,
      map_y - 20,
      map_w * tile + 40,
      map_h * tile + 40,
      @raylib.Color::new(18, 24, 40, 255),
    )

    for y = 0; y < map_h; y = y + 1 {
      for x = 0; x < map_w; x = x + 1 {
        let px = map_x + x * tile
        let py = map_y + y * tile
        if tiles[idx(x, y)] == 1 {
          @raylib.draw_rectangle(
            px,
            py,
            tile,
            tile,
            @raylib.Color::new(48, 58, 76, 255),
          )
          @raylib.draw_rectangle(
            px + 8,
            py + 8,
            tile - 16,
            tile - 16,
            @raylib.Color::new(36, 44, 58, 255),
          )
        } else {
          let checker = (x + y) % 2 == 0
          let floor_col = if checker {
            @raylib.Color::new(24, 30, 46, 255)
          } else {
            @raylib.Color::new(20, 26, 40, 255)
          }
          @raylib.draw_rectangle(px, py, tile, tile, floor_col)
        }
      }
    }

    // Camera cone projection.
    for i = 0; i < cameras.length(); i = i + 1 {
      if not(cameras[i].active) || cameras[i].disable_t > 0.0 {
        continue
      }

      for step = 1; step <= 8; step = step + 1 {
        let gx = if cameras[i].dir == 1 {
          cameras[i].gx + step
        } else if cameras[i].dir == 3 {
          cameras[i].gx - step
        } else {
          cameras[i].gx
        }
        let gy = if cameras[i].dir == 2 {
          cameras[i].gy + step
        } else if cameras[i].dir == 0 {
          cameras[i].gy - step
        } else {
          cameras[i].gy
        }
        if not(in_bounds(gx, gy)) || tiles[idx(gx, gy)] == 1 {
          break
        }

        let px = map_x + gx * tile
        let py = map_y + gy * tile
        @raylib.draw_rectangle(
          px + 6,
          py + 6,
          tile - 12,
          tile - 12,
          @raylib.Color::new(86, 168, 210, 32),
        )
      }
    }

    let exit_px = map_x + exit_x * tile
    let exit_py = map_y + exit_y * tile
    let exit_col = if exit_open {
      @raylib.Color::new(92, 224, 154, 255)
    } else {
      @raylib.Color::new(206, 86, 92, 255)
    }
    @raylib.draw_rectangle(
      exit_px + 6,
      exit_py + 6,
      tile - 12,
      tile - 12,
      exit_col,
    )
    if not(exit_open) {
      @raylib.draw_line(
        exit_px + 10,
        exit_py + 10,
        exit_px + tile - 10,
        exit_py + tile - 10,
        @raylib.Color::new(58, 22, 30, 255),
      )
      @raylib.draw_line(
        exit_px + tile - 10,
        exit_py + 10,
        exit_px + 10,
        exit_py + tile - 10,
        @raylib.Color::new(58, 22, 30, 255),
      )
    }

    for i = 0; i < terminals.length(); i = i + 1 {
      if terminals[i].active {
        let cx = cell_center_x(terminals[i].gx)
        let cy = cell_center_y(terminals[i].gy)
        let col = if terminals[i].hacked {
          @raylib.Color::new(112, 240, 186, 255)
        } else {
          @raylib.Color::new(108, 184, 250, 255)
        }
        @raylib.draw_rectangle(
          (cx - 13.0).to_int(),
          (cy - 16.0).to_int(),
          26,
          32,
          col,
        )
        @raylib.draw_rectangle(
          (cx - 9.0).to_int(),
          (cy - 8.0).to_int(),
          18,
          16,
          @raylib.Color::new(22, 34, 52, 255),
        )
      }
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if pickups[i].active {
        let cx = cell_center_x(pickups[i].gx)
        let cy = cell_center_y(pickups[i].gy)
        let col = if pickups[i].kind == 0 {
          @raylib.Color::new(128, 236, 162, 255)
        } else if pickups[i].kind == 1 {
          @raylib.Color::new(128, 214, 250, 255)
        } else if pickups[i].kind == 2 {
          @raylib.Color::new(246, 208, 118, 255)
        } else {
          @raylib.Color::new(232, 148, 250, 255)
        }
        @raylib.draw_circle(cx.to_int(), cy.to_int(), 10.0, col)
      }
    }

    for i = 0; i < cameras.length(); i = i + 1 {
      if cameras[i].active {
        draw_camera(cameras[i])
      }
    }

    for i = 0; i < guards.length(); i = i + 1 {
      if guards[i].active {
        draw_guard(guards[i])
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let ratio : Float = 1.0 - particles[i].t / particles[i].life
      let a = (ratio * 255.0).to_int()
      if a <= 0 {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(142, 226, 252, a)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 160, 138, a)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(142, 244, 198, a)
      } else {
        @raylib.Color::new(252, 124, 142, a)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    let pcx = cell_center_x(player.gx)
    let pcy = cell_center_y(player.gy)
    let body_col = if player.hurt_cd > 0.0 {
      @raylib.Color::new(252, 132, 132, 255)
    } else if player.cloak_t > 0.0 {
      @raylib.Color::new(132, 238, 198, 210)
    } else {
      @raylib.Color::new(132, 206, 252, 255)
    }

    @raylib.draw_circle(pcx.to_int(), pcy.to_int(), 16.0, body_col)
    @raylib.draw_circle(
      pcx.to_int(),
      (pcy - 18.0).to_int(),
      11.0,
      @raylib.Color::new(248, 222, 192, 255),
    )
    @raylib.draw_rectangle(
      (pcx - 5.0 + Float::from_int(player.face_x * 8)).to_int(),
      (pcy - 5.0 + Float::from_int(player.face_y * 8)).to_int(),
      10,
      10,
      @raylib.Color::new(212, 244, 255, 255),
    )

    if player.cloak_t > 0.0 {
      @raylib.draw_circle_lines(
        pcx.to_int(),
        pcy.to_int(),
        24.0,
        @raylib.Color::new(126, 244, 206, 255),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 76, @raylib.Color::new(6, 10, 18, 228))
    @raylib.draw_text(
      "ARCADE HACKER INFILTRATION 2026",
      16,
      12,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  J hack  K EMP  L cloak",
      16,
      48,
      18,
      @raylib.Color::new(176, 204, 236, 255),
    )

    @raylib.draw_text(
      "Stage \{stage}/\{max_stage}",
      560,
      14,
      28,
      @raylib.Color::new(250, 220, 132, 255),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      732,
      14,
      28,
      @raylib.Color::new(170, 238, 202, 255),
    )
    @raylib.draw_text(
      "Time \{mission_time.to_int()}s",
      920,
      14,
      28,
      @raylib.Color::new(168, 224, 252, 255),
    )
    @raylib.draw_text(
      "Strikes \{strikes}/3",
      1110,
      14,
      28,
      @raylib.Color::new(246, 162, 170, 255),
    )

    @raylib.draw_rectangle(20, 86, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      86,
      (player.hp / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(116, 228, 164, 255),
    )
    @raylib.draw_text("HP", 20, 100, 16, @raylib.Color::new(186, 212, 234, 255))

    @raylib.draw_rectangle(
      256,
      86,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      256,
      86,
      (player.energy / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(122, 198, 248, 255),
    )
    @raylib.draw_text(
      "ENERGY",
      256,
      100,
      16,
      @raylib.Color::new(186, 212, 234, 255),
    )

    @raylib.draw_rectangle(
      492,
      86,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      492,
      86,
      (alarm / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(246, 134, 132, 255),
    )
    @raylib.draw_text(
      "ALARM",
      492,
      100,
      16,
      @raylib.Color::new(186, 212, 234, 255),
    )

    @raylib.draw_text(
      "Cores \{terminal_done}/\{terminal_total}",
      732,
      84,
      20,
      @raylib.Color::new(144, 226, 252, 255),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      906,
      84,
      20,
      @raylib.Color::new(246, 220, 156, 255),
    )
    @raylib.draw_text(
      "Hack \{player.hack_cd.to_int()}  EMP \{player.emp_cd.to_int()}  Cloak \{player.cloak_cd.to_int()}",
      1030,
      84,
      20,
      @raylib.Color::new(206, 190, 162, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 320,
      sh - 52,
      640,
      38,
      @raylib.Color::new(8, 12, 18, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 300,
      sh - 44,
      24,
      @raylib.Color::new(236, 244, 255, if msg_t > 0.0 { 255 } else { 150 }),
    )

    @raylib.draw_rectangle(
      24,
      sh - 198,
      238,
      172,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let px0 = 24
    let py0 = sh - 198
    @raylib.draw_rectangle(
      px0,
      py0 + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "L",
      px0 + 30,
      py0 + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      px0 + 160,
      py0 + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "R",
      px0 + 190,
      py0 + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      px0 + 80,
      py0,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "U",
      px0 + 110,
      py0 + 16,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      px0 + 80,
      py0 + 116,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "D",
      px0 + 110,
      py0 + 132,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 298,
      sh - 236,
      274,
      224,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let bx0 = sw - 298
    let by0 = sh - 236
    @raylib.draw_rectangle(
      bx0 + 8,
      by0 + 10,
      120,
      92,
      @raylib.Color::new(88, 146, 212, 255),
    )
    @raylib.draw_text(
      "HACK",
      bx0 + 36,
      by0 + 44,
      32,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      bx0 + 136,
      by0 + 10,
      120,
      92,
      @raylib.Color::new(210, 118, 102, 255),
    )
    @raylib.draw_text(
      "EMP",
      bx0 + 174,
      by0 + 44,
      32,
      @raylib.Color::new(252, 238, 230, 255),
    )
    @raylib.draw_rectangle(
      bx0 + 72,
      by0 + 116,
      152,
      102,
      @raylib.Color::new(102, 184, 136, 255),
    )
    @raylib.draw_text(
      "CLOAK",
      bx0 + 106,
      by0 + 156,
      30,
      @raylib.Color::new(238, 248, 242, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 470,
        sh / 2 - 206,
        940,
        412,
        @raylib.Color::new(12, 18, 30, 246),
      )
      @raylib.draw_text(
        "ARCADE HACKER INFILTRATION",
        sw / 2 - 390,
        sh / 2 - 128,
        60,
        @raylib.Color::new(238, 246, 255, 255),
      )
      @raylib.draw_text(
        "Hack all security cores, avoid detection, reach the extraction gate.",
        sw / 2 - 370,
        sh / 2 - 28,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad move, right buttons hack/EMP/cloak",
        sw / 2 - 334,
        sh / 2 + 14,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "3 strikes from full alarm means mission failed",
        sw / 2 - 258,
        sh / 2 + 58,
        32,
        @raylib.Color::new(252, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 180,
        sh / 2 + 122,
        42,
        @raylib.Color::new(255, 204, 112, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 146))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "MISSION CLEAN",
        sw / 2 - 208,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 150,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Cores hacked: \{player.hacked_total}  Strikes: \{strikes}",
        sw / 2 - 248,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Time left: \{mission_time.to_int()}s",
        sw / 2 - 168,
        sh / 2 + 62,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 124,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 154))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "MISSION BLOWN",
        sw / 2 - 238,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 150,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Stage: \{stage}  Cores hacked: \{player.hacked_total}",
        sw / 2 - 212,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Strikes: \{strikes}  Time left: \{mission_time.to_int()}s",
        sw / 2 - 216,
        sh / 2 + 62,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 124,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }
  }

  @raylib.close_window()
}
