///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let world_h : Float = 760.0

///|
let harbor_y : Float = 632.0

///|
let max_enemies : Int = 120

///|
let max_boats : Int = 42

///|
let max_projectiles : Int = 520

///|
let max_pickups : Int = 92

///|
let max_particles : Int = 980

///|
struct Cannon {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut heat : Float
  mut fire_cd : Float
  mut bomb_cd : Float
  mut shield_cd : Float
  mut shield_t : Float
  mut overheated : Bool
  mut score : Int
  mut kills : Int
  mut combo : Int
}

///|
struct EnemyShip {
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
struct CivilianBoat {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut value : Int
  mut panic_t : Float
}

///|
struct Projectile {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut life : Float
  mut from_enemy : Bool
  mut kind : Int
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vy : Float
  mut kind : Int
  mut t : Float
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
fn clear_enemies(enemies : Array[EnemyShip]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].active = false
    enemies[i].kind = 0
    enemies[i].x = 0.0
    enemies[i].y = 0.0
    enemies[i].vx = 0.0
    enemies[i].vy = 0.0
    enemies[i].hp = 0.0
    enemies[i].fire_cd = 0.0
    enemies[i].t = 0.0
  }
}

///|
fn clear_boats(boats : Array[CivilianBoat]) -> Unit {
  for i = 0; i < boats.length(); i = i + 1 {
    boats[i].active = false
    boats[i].x = 0.0
    boats[i].y = 0.0
    boats[i].vx = 0.0
    boats[i].hp = 0.0
    boats[i].value = 0
    boats[i].panic_t = 0.0
  }
}

///|
fn clear_projectiles(projectiles : Array[Projectile]) -> Unit {
  for i = 0; i < projectiles.length(); i = i + 1 {
    projectiles[i].active = false
    projectiles[i].x = 0.0
    projectiles[i].y = 0.0
    projectiles[i].vx = 0.0
    projectiles[i].vy = 0.0
    projectiles[i].dmg = 0.0
    projectiles[i].life = 0.0
    projectiles[i].from_enemy = false
    projectiles[i].kind = 0
  }
}

///|
fn clear_pickups(pickups : Array[Pickup]) -> Unit {
  for i = 0; i < pickups.length(); i = i + 1 {
    pickups[i].active = false
    pickups[i].x = 0.0
    pickups[i].y = 0.0
    pickups[i].vy = 0.0
    pickups[i].kind = 0
    pickups[i].t = 0.0
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
fn spawn_enemy(enemies : Array[EnemyShip], wave : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    let kind : Int = @raylib.get_random_value(0, 2)
    let side : Int = @raylib.get_random_value(0, 1)
    let dir : Float = if side == 0 { 1.0 } else { -1.0 }
    let start_x : Float = if side == 0 {
      randf(64.0, 300.0)
    } else {
      randf(980.0, 1216.0)
    }

    enemies[slot].active = true
    enemies[slot].kind = kind
    enemies[slot].x = start_x
    enemies[slot].y = randf(42.0, 180.0)
    enemies[slot].vx = dir * randf(26.0, 58.0)
    enemies[slot].vy = 22.0 +
      Float::from_int(kind) * 6.0 +
      Float::from_int(wave) * 2.8
    enemies[slot].hp = 34.0 +
      Float::from_int(kind) * 24.0 +
      Float::from_int(wave) * 4.8
    enemies[slot].fire_cd = randf(0.8, 1.7)
    enemies[slot].t = randf(0.0, 12.0)
    true
  }
}

///|
fn spawn_boat(boats : Array[CivilianBoat]) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < boats.length(); i = i + 1 {
    if not(boats[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    let from_left : Bool = @raylib.get_random_value(0, 1) == 0
    boats[slot].active = true
    boats[slot].x = if from_left { -36.0 } else { world_w + 36.0 }
    boats[slot].y = randf(harbor_y + 20.0, harbor_y + 56.0)
    boats[slot].vx = if from_left {
      randf(44.0, 78.0)
    } else {
      -randf(44.0, 78.0)
    }
    boats[slot].hp = 62.0
    boats[slot].value = @raylib.get_random_value(36, 64)
    boats[slot].panic_t = 0.0
    true
  }
}

///|
fn spawn_projectile(
  projectiles : Array[Projectile],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  from_enemy : Bool,
  kind : Int,
  life : Float,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < projectiles.length(); i = i + 1 {
    if not(projectiles[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    projectiles[slot].active = true
    projectiles[slot].x = x
    projectiles[slot].y = y
    projectiles[slot].vx = vx
    projectiles[slot].vy = vy
    projectiles[slot].dmg = dmg
    projectiles[slot].life = life
    projectiles[slot].from_enemy = from_enemy
    projectiles[slot].kind = kind
    true
  }
}

///|
fn spawn_pickup(pickups : Array[Pickup], x : Float, y : Float) -> Bool {
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
    pickups[slot].x = x + randf(-18.0, 18.0)
    pickups[slot].y = y
    pickups[slot].vy = randf(48.0, 92.0)
    pickups[slot].kind = @raylib.get_random_value(0, 3)
    pickups[slot].t = 0.0
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
      parts[i].life = Float::from_int(@raylib.get_random_value(16, 72)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn draw_enemy(e : EnemyShip) -> Unit {
  if not(e.active) {
    ignore(())
  } else {
    let body_col = if e.kind == 0 {
      @raylib.Color::new(180, 90, 84, 255)
    } else if e.kind == 1 {
      @raylib.Color::new(152, 70, 66, 255)
    } else {
      @raylib.Color::new(124, 52, 52, 255)
    }

    let deck_col = if e.kind == 2 {
      @raylib.Color::new(236, 132, 122, 255)
    } else {
      @raylib.Color::new(224, 164, 148, 255)
    }

    @raylib.draw_rectangle(
      (e.x - 24.0).to_int(),
      (e.y - 12.0).to_int(),
      48,
      24,
      body_col,
    )
    @raylib.draw_rectangle(
      (e.x - 16.0).to_int(),
      (e.y - 24.0).to_int(),
      32,
      12,
      deck_col,
    )
    @raylib.draw_rectangle(
      (e.x - 6.0).to_int(),
      (e.y - 34.0).to_int(),
      12,
      10,
      @raylib.Color::new(242, 214, 190, 255),
    )

    if e.kind >= 1 {
      @raylib.draw_rectangle(
        (e.x - 30.0).to_int(),
        (e.y - 8.0).to_int(),
        6,
        8,
        @raylib.Color::new(250, 170, 132, 255),
      )
      @raylib.draw_rectangle(
        (e.x + 24.0).to_int(),
        (e.y - 8.0).to_int(),
        6,
        8,
        @raylib.Color::new(250, 170, 132, 255),
      )
    }

    @raylib.draw_rectangle(
      (e.x - 16.0).to_int(),
      (e.y + 12.0).to_int(),
      32,
      3,
      @raylib.Color::new(70, 26, 24, 255),
    )
  }
}

///|
fn draw_boat(boat : CivilianBoat) -> Unit {
  if not(boat.active) {
    ignore(())
  } else {
    let panic_tint : Int = if boat.panic_t > 0.0 { 72 } else { 0 }
    @raylib.draw_rectangle(
      (boat.x - 24.0).to_int(),
      (boat.y - 9.0).to_int(),
      48,
      18,
      @raylib.Color::new(76 + panic_tint, 112, 196, 255),
    )
    @raylib.draw_rectangle(
      (boat.x - 8.0).to_int(),
      (boat.y - 21.0).to_int(),
      16,
      12,
      @raylib.Color::new(208, 230, 252, 255),
    )
    @raylib.draw_rectangle(
      (boat.x - 2.0).to_int(),
      (boat.y - 30.0).to_int(),
      4,
      10,
      @raylib.Color::new(218, 230, 248, 255),
    )
  }
}

///|
fn draw_cannon(c : Cannon) -> Unit {
  @raylib.draw_rectangle(
    (c.x - 44.0).to_int(),
    (c.y - 20.0).to_int(),
    88,
    40,
    @raylib.Color::new(84, 108, 126, 255),
  )
  @raylib.draw_rectangle(
    (c.x - 12.0).to_int(),
    (c.y - 52.0).to_int(),
    24,
    34,
    @raylib.Color::new(118, 146, 166, 255),
  )
  @raylib.draw_rectangle(
    (c.x - 6.0).to_int(),
    (c.y - 84.0).to_int(),
    12,
    34,
    @raylib.Color::new(144, 176, 198, 255),
  )
  @raylib.draw_circle(
    c.x.to_int(),
    (c.y + 20.0).to_int(),
    18.0,
    @raylib.Color::new(62, 82, 98, 255),
  )

  if c.shield_t > 0.0 {
    @raylib.draw_circle_lines(
      c.x.to_int(),
      c.y.to_int(),
      56.0,
      @raylib.Color::new(146, 226, 255, 220),
    )
    @raylib.draw_circle_lines(
      c.x.to_int(),
      c.y.to_int(),
      48.0,
      @raylib.Color::new(110, 204, 242, 220),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Harbor Defense 2026")
  @raylib.set_target_fps(60)

  let cannon : Cannon = {
    x: 640.0,
    y: harbor_y - 8.0,
    vx: 0.0,
    hp: 240.0,
    heat: 0.0,
    fire_cd: 0.0,
    bomb_cd: 0.0,
    shield_cd: 0.0,
    shield_t: 0.0,
    overheated: false,
    score: 0,
    kills: 0,
    combo: 0,
  }

  let enemies : Array[EnemyShip] = Array::makei(max_enemies, fn(_i) {
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

  let boats : Array[CivilianBoat] = Array::makei(max_boats, fn(_i) {
    { active: false, x: 0.0, y: 0.0, vx: 0.0, hp: 0.0, value: 0, panic_t: 0.0 }
  })

  let projectiles : Array[Projectile] = Array::makei(max_projectiles, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0.0,
      life: 0.0,
      from_enemy: false,
      kind: 0,
    }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, x: 0.0, y: 0.0, vy: 0.0, kind: 0, t: 0.0 }
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

  let mut state : Int = 0
  let mut timer : Float = 240.0
  let mut target_kills : Int = 82
  let mut enemy_spawn_cd : Float = 0.55
  let mut boat_spawn_cd : Float = 1.2
  let mut civilians_lost : Int = 0
  let mut civilians_escaped : Int = 0
  let mut wave : Int = 1

  let mut message : String = "Protect civilian boats and repel raiders"
  let mut message_t : Float = 3.6

  let reset_run = fn() {
    cannon.x = 640.0
    cannon.y = harbor_y - 8.0
    cannon.vx = 0.0
    cannon.hp = 240.0
    cannon.heat = 0.0
    cannon.fire_cd = 0.0
    cannon.bomb_cd = 0.0
    cannon.shield_cd = 0.0
    cannon.shield_t = 0.0
    cannon.overheated = false
    cannon.score = 0
    cannon.kills = 0
    cannon.combo = 0

    timer = 240.0
    target_kills = 82
    enemy_spawn_cd = 0.55
    boat_spawn_cd = 1.2
    civilians_lost = 0
    civilians_escaped = 0
    wave = 1

    message = "Raiders incoming"
    message_t = 1.8

    clear_enemies(enemies)
    clear_boats(boats)
    clear_projectiles(projectiles)
    clear_pickups(pickups)
    clear_particles(particles)

    for i = 0; i < 7; i = i + 1 {
      ignore(i)
      ignore(spawn_enemy(enemies, wave))
    }

    for i = 0; i < 3; i = i + 1 {
      ignore(i)
      ignore(spawn_boat(boats))
    }
  }

  let on_harbor_hit = fn(dmg : Float, text : String) {
    let scale : Float = if cannon.shield_t > 0.0 { 0.36 } else { 1.0 }
    cannon.hp = cannon.hp - dmg * scale
    cannon.combo = 0
    message = text
    message_t = 0.68
    burst(particles, cannon.x, cannon.y - 24.0, 14, 0.22, 3)
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

    if message_t > 0.0 {
      message_t = message_t - dt
      if message_t < 0.0 {
        message_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      timer = timer - dt

      cannon.fire_cd = cannon.fire_cd - dt
      if cannon.fire_cd < 0.0 {
        cannon.fire_cd = 0.0
      }

      cannon.bomb_cd = cannon.bomb_cd - dt
      if cannon.bomb_cd < 0.0 {
        cannon.bomb_cd = 0.0
      }

      cannon.shield_cd = cannon.shield_cd - dt
      if cannon.shield_cd < 0.0 {
        cannon.shield_cd = 0.0
      }

      cannon.shield_t = cannon.shield_t - dt
      if cannon.shield_t < 0.0 {
        cannon.shield_t = 0.0
      }

      cannon.heat = cannon.heat - dt * 18.0
      if cannon.heat < 0.0 {
        cannon.heat = 0.0
      }

      if cannon.overheated && cannon.heat <= 36.0 {
        cannon.overheated = false
        message = "Cannons cooled"
        message_t = 0.64
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut fire_down : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut bomb_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut shield_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_y : Int = sh - 154
      let left_x : Int = 22
      let right_x : Int = 142

      let fire_x : Int = sw - 200
      let fire_y : Int = sh - 208
      let bomb_x : Int = sw - 340
      let bomb_y : Int = sh - 144
      let shield_x : Int = sw - 340
      let shield_y : Int = sh - 234

      if touching {
        if inside_rect(mouse.x, mouse.y, left_x, pad_y, 104, 92) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, right_x, pad_y, 104, 92) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, fire_x, fire_y, 168, 176) {
          fire_down = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, bomb_x, bomb_y, 124, 84) {
          bomb_press = true
        }
        if inside_rect(mouse.x, mouse.y, shield_x, shield_y, 124, 84) {
          shield_press = true
        }
      }

      let mut move_axis : Float = 0.0
      if move_l {
        move_axis = move_axis - 1.0
      }
      if move_r {
        move_axis = move_axis + 1.0
      }

      cannon.vx = cannon.vx + move_axis * 620.0 * dt
      cannon.vx = cannon.vx * (1.0 - dt * 4.8)
      cannon.x = cannon.x + cannon.vx * dt
      cannon.x = clampf(cannon.x, 56.0, world_w - 56.0)

      if fire_down && cannon.fire_cd <= 0.0 && not(cannon.overheated) {
        let spread : Float = Float::from_int(@raylib.get_random_value(-7, 7)) /
          100.0
        let mut speed : Float = -560.0
        speed = speed - Float::from_int(cannon.combo) * 2.8
        if speed < -700.0 {
          speed = -700.0
        }

        ignore(
          spawn_projectile(
            projectiles,
            cannon.x,
            cannon.y - 78.0,
            spread * 90.0,
            speed,
            24.0,
            false,
            0,
            2.1,
          ),
        )
        cannon.fire_cd = if cannon.heat >= 78.0 { 0.20 } else { 0.11 }
        cannon.heat = cannon.heat + 8.4
        burst(particles, cannon.x + spread * 8.0, cannon.y - 82.0, 4, 0.10, 0)

        if cannon.heat >= 100.0 {
          cannon.heat = 100.0
          cannon.overheated = true
          message = "OVERHEAT"
          message_t = 0.84
        }
      }

      if bomb_press && cannon.bomb_cd <= 0.0 {
        cannon.bomb_cd = 4.8
        message = "Depth charge"
        message_t = 0.62
        burst(particles, cannon.x, cannon.y - 38.0, 26, 0.24, 2)

        let mut blast_kills : Int = 0
        for i = 0; i < enemies.length(); i = i + 1 {
          if enemies[i].active &&
            dist2(cannon.x, cannon.y - 40.0, enemies[i].x, enemies[i].y) <=
            220.0 * 220.0 {
            enemies[i].active = false
            blast_kills = blast_kills + 1
            cannon.kills = cannon.kills + 1
            cannon.combo = cannon.combo + 1
            cannon.score = cannon.score + 54 + cannon.combo * 3
            burst(particles, enemies[i].x, enemies[i].y, 12, 0.19, 1)
          }
        }

        for i = 0; i < projectiles.length(); i = i + 1 {
          if projectiles[i].active &&
            projectiles[i].from_enemy &&
            dist2(cannon.x, cannon.y - 40.0, projectiles[i].x, projectiles[i].y) <=
            230.0 * 230.0 {
            projectiles[i].active = false
            cannon.score = cannon.score + 2
          }
        }

        if blast_kills >= 4 {
          message = "Depth charge x\{blast_kills}"
          message_t = 0.9
        }
      }

      if shield_press && cannon.shield_cd <= 0.0 {
        cannon.shield_t = 2.4
        cannon.shield_cd = 6.4
        message = "Magnetic shield"
        message_t = 0.7
        burst(particles, cannon.x, cannon.y, 16, 0.14, 2)
      }

      wave = cannon.kills / 10 + 1

      enemy_spawn_cd = enemy_spawn_cd - dt
      if enemy_spawn_cd <= 0.0 {
        ignore(spawn_enemy(enemies, wave))
        let base : Float = 0.96 - Float::from_int(wave) * 0.04
        let lo : Float = clampf(base * 0.56, 0.16, 0.72)
        let hi : Float = clampf(base * 1.08, 0.34, 1.08)
        enemy_spawn_cd = randf(lo, hi)
      }

      boat_spawn_cd = boat_spawn_cd - dt
      if boat_spawn_cd <= 0.0 {
        ignore(spawn_boat(boats))
        boat_spawn_cd = randf(4.0, 6.2)
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        enemies[i].t = enemies[i].t + dt

        let phase_rate : Float = 1.3 + Float::from_int(enemies[i].kind) * 0.5
        let phase = (enemies[i].t * phase_rate).to_int()
        let drift : Float = if phase % 2 == 0 { -1.0 } else { 1.0 }

        enemies[i].x = enemies[i].x +
          enemies[i].vx * dt +
          drift * dt * (14.0 + Float::from_int(wave) * 0.5)
        enemies[i].y = enemies[i].y + enemies[i].vy * dt
        enemies[i].x = clampf(enemies[i].x, 28.0, world_w - 28.0)

        enemies[i].fire_cd = enemies[i].fire_cd - dt
        if enemies[i].fire_cd <= 0.0 &&
          absf(enemies[i].x - cannon.x) < 360.0 &&
          enemies[i].y < harbor_y - 40.0 {
          let dx : Float = cannon.x - enemies[i].x + randf(-20.0, 20.0)
          let dy : Float = cannon.y - enemies[i].y
          let inv : Float = 1.0 / clampf(absf(dx) + absf(dy), 32.0, 2000.0)
          let speed : Float = 220.0 +
            Float::from_int(enemies[i].kind) * 42.0 +
            Float::from_int(wave) * 6.0
          ignore(
            spawn_projectile(
              projectiles,
              enemies[i].x,
              enemies[i].y + 14.0,
              dx * inv * speed,
              dy * inv * speed,
              11.0 + Float::from_int(enemies[i].kind) * 5.0,
              true,
              enemies[i].kind,
              4.0,
            ),
          )
          enemies[i].fire_cd = randf(0.95, 1.92)
        }

        if enemies[i].y > harbor_y {
          enemies[i].active = false
          civilians_lost = civilians_lost + 1
          cannon.combo = 0
          on_harbor_hit(
            9.0 + Float::from_int(wave) * 0.5,
            "Enemy breached harbor",
          )
          burst(particles, enemies[i].x, harbor_y - 8.0, 16, 0.22, 3)
        }
      }

      for i = 0; i < boats.length(); i = i + 1 {
        if not(boats[i].active) {
          continue
        }

        boats[i].x = boats[i].x + boats[i].vx * dt
        boats[i].panic_t = boats[i].panic_t - dt
        if boats[i].panic_t < 0.0 {
          boats[i].panic_t = 0.0
        }

        if boats[i].x < -72.0 || boats[i].x > world_w + 72.0 {
          boats[i].active = false
          civilians_escaped = civilians_escaped + 1
          cannon.score = cannon.score + boats[i].value
          if cannon.score < 0 {
            cannon.score = 0
          }
          continue
        }

        for e = 0; e < enemies.length(); e = e + 1 {
          if enemies[e].active &&
            dist2(boats[i].x, boats[i].y - 8.0, enemies[e].x, enemies[e].y) <=
            36.0 * 36.0 {
            enemies[e].active = false
            boats[i].hp = boats[i].hp - 36.0
            boats[i].panic_t = 1.2
            burst(particles, boats[i].x, boats[i].y - 8.0, 10, 0.18, 3)
          }
        }

        if boats[i].hp <= 0.0 {
          boats[i].active = false
          civilians_lost = civilians_lost + 1
          cannon.combo = 0
          message = "Civilian boat destroyed"
          message_t = 0.72
          burst(particles, boats[i].x, boats[i].y, 16, 0.20, 3)
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

        if projectiles[i].x < -48.0 ||
          projectiles[i].x > world_w + 48.0 ||
          projectiles[i].y < -48.0 ||
          projectiles[i].y > world_h + 48.0 {
          projectiles[i].active = false
          continue
        }

        if projectiles[i].from_enemy {
          if cannon.shield_t > 0.0 &&
            dist2(projectiles[i].x, projectiles[i].y, cannon.x, cannon.y) <=
            58.0 * 58.0 {
            projectiles[i].active = false
            cannon.score = cannon.score + 2
            burst(particles, projectiles[i].x, projectiles[i].y, 5, 0.10, 2)
            continue
          }

          if dist2(
              projectiles[i].x,
              projectiles[i].y,
              cannon.x,
              cannon.y - 22.0,
            ) <=
            30.0 * 30.0 {
            projectiles[i].active = false
            on_harbor_hit(projectiles[i].dmg, "Harbor battery hit")
            continue
          }

          for b = 0; b < boats.length(); b = b + 1 {
            if boats[b].active &&
              dist2(
                projectiles[i].x,
                projectiles[i].y,
                boats[b].x,
                boats[b].y - 8.0,
              ) <=
              20.0 * 20.0 {
              projectiles[i].active = false
              boats[b].hp = boats[b].hp - projectiles[i].dmg * 0.9
              boats[b].panic_t = 1.0
              burst(particles, boats[b].x, boats[b].y - 8.0, 4, 0.12, 3)
              break
            }
          }
        } else {
          let mut hit_enemy = false
          for e = 0; e < enemies.length(); e = e + 1 {
            if enemies[e].active &&
              dist2(
                projectiles[i].x,
                projectiles[i].y,
                enemies[e].x,
                enemies[e].y,
              ) <=
              24.0 * 24.0 {
              projectiles[i].active = false
              enemies[e].hp = enemies[e].hp - projectiles[i].dmg
              burst(particles, projectiles[i].x, projectiles[i].y, 6, 0.10, 0)

              if enemies[e].hp <= 0.0 {
                enemies[e].active = false
                cannon.kills = cannon.kills + 1
                cannon.combo = cannon.combo + 1
                cannon.score = cannon.score + 38 + cannon.combo * 3 + wave * 2
                burst(particles, enemies[e].x, enemies[e].y, 12, 0.18, 1)

                if @raylib.get_random_value(0, 99) < 23 {
                  ignore(spawn_pickup(pickups, enemies[e].x, enemies[e].y))
                }
              }

              hit_enemy = true
              break
            }
          }

          if hit_enemy {
            continue
          }

          for b = 0; b < boats.length(); b = b + 1 {
            if boats[b].active &&
              dist2(
                projectiles[i].x,
                projectiles[i].y,
                boats[b].x,
                boats[b].y - 10.0,
              ) <=
              20.0 * 20.0 {
              projectiles[i].active = false
              boats[b].hp = boats[b].hp - projectiles[i].dmg * 1.5
              boats[b].panic_t = 1.3
              cannon.combo = 0
              cannon.score = cannon.score - 18
              if cannon.score < 0 {
                cannon.score = 0
              }
              message = "Friendly fire"
              message_t = 0.66
              burst(particles, boats[b].x, boats[b].y - 10.0, 6, 0.12, 3)
              break
            }
          }
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }

        pickups[i].t = pickups[i].t + dt
        pickups[i].y = pickups[i].y + pickups[i].vy * dt
        pickups[i].vy = pickups[i].vy + 68.0 * dt

        if pickups[i].y > world_h + 40.0 {
          pickups[i].active = false
          continue
        }

        if dist2(pickups[i].x, pickups[i].y, cannon.x, cannon.y - 20.0) <=
          34.0 * 34.0 {
          if pickups[i].kind == 0 {
            cannon.hp = cannon.hp + 30.0
            if cannon.hp > 240.0 {
              cannon.hp = 240.0
            }
            message = "Repair kit"
          } else if pickups[i].kind == 1 {
            cannon.heat = cannon.heat - 42.0
            if cannon.heat < 0.0 {
              cannon.heat = 0.0
            }
            if cannon.heat <= 36.0 {
              cannon.overheated = false
            }
            message = "Coolant"
          } else if pickups[i].kind == 2 {
            cannon.bomb_cd = cannon.bomb_cd - 2.1
            if cannon.bomb_cd < 0.0 {
              cannon.bomb_cd = 0.0
            }
            message = "Bomb charge"
          } else {
            cannon.score = cannon.score + 120
            message = "Intel crate +120"
          }

          message_t = 0.66
          pickups[i].active = false
          burst(particles, cannon.x, cannon.y - 30.0, 10, 0.16, 2)
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
          particles[i].vx = particles[i].vx * (1.0 - dt * 1.9)
          particles[i].vy = particles[i].vy + 260.0 * dt
        }
      }

      if cannon.kills >= target_kills {
        state = 2
      } else if cannon.hp <= 0.0 || civilians_lost >= 18 || timer <= 0.0 {
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

    @raylib.clear_background(@raylib.Color::new(14, 24, 42, 255))

    @raylib.draw_rectangle(0, 0, sw, 300, @raylib.Color::new(26, 44, 72, 255))
    @raylib.draw_rectangle(0, 300, sw, 224, @raylib.Color::new(22, 58, 96, 255))
    @raylib.draw_rectangle(
      0,
      524,
      sw,
      sh - 524,
      @raylib.Color::new(20, 76, 114, 255),
    )

    for i = 0; i < 24; i = i + 1 {
      let wx = i * 74 + (timer * 30.0).to_int() % 74
      let wy = 536 + i * 17 % 176
      @raylib.draw_rectangle(
        wx,
        wy,
        56,
        2,
        @raylib.Color::new(142, 206, 236, 112),
      )
    }

    for i = 0; i < 18; i = i + 1 {
      let x = i * 80 + 16
      let h = 80 + i * 13 % 180
      @raylib.draw_rectangle(
        x,
        harbor_y.to_int() - h - 42,
        58,
        h,
        @raylib.Color::new(30, 42, 58, 255),
      )
      @raylib.draw_rectangle(
        x + 12,
        harbor_y.to_int() - h - 12,
        10,
        10,
        @raylib.Color::new(116, 188, 244, 170),
      )
    }

    @raylib.draw_rectangle(
      0,
      harbor_y.to_int(),
      sw,
      sh - harbor_y.to_int(),
      @raylib.Color::new(58, 72, 80, 255),
    )
    @raylib.draw_rectangle(
      0,
      harbor_y.to_int() - 8,
      sw,
      8,
      @raylib.Color::new(90, 106, 118, 255),
    )

    for i = 0; i < boats.length(); i = i + 1 {
      if boats[i].active {
        draw_boat(boats[i])
      }
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].active {
        draw_enemy(enemies[i])
      }
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if pickups[i].active {
        let blink = (pickups[i].t * 10.0).to_int() % 2 == 0
        let col = if pickups[i].kind == 0 {
          @raylib.Color::new(134, 246, 176, if blink { 255 } else { 196 })
        } else if pickups[i].kind == 1 {
          @raylib.Color::new(124, 220, 254, if blink { 255 } else { 196 })
        } else if pickups[i].kind == 2 {
          @raylib.Color::new(254, 212, 124, if blink { 255 } else { 196 })
        } else {
          @raylib.Color::new(246, 164, 240, if blink { 255 } else { 196 })
        }

        @raylib.draw_rectangle(
          (pickups[i].x - 12.0).to_int(),
          (pickups[i].y - 12.0).to_int(),
          24,
          24,
          col,
        )
      }
    }

    for i = 0; i < projectiles.length(); i = i + 1 {
      if not(projectiles[i].active) {
        continue
      }

      if projectiles[i].from_enemy {
        let r : Float = 5.0 + Float::from_int(projectiles[i].kind)
        @raylib.draw_circle(
          projectiles[i].x.to_int(),
          projectiles[i].y.to_int(),
          r,
          @raylib.Color::new(252, 126, 116, 255),
        )
      } else {
        @raylib.draw_circle(
          projectiles[i].x.to_int(),
          projectiles[i].y.to_int(),
          4.2,
          @raylib.Color::new(126, 226, 250, 255),
        )
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let life_ratio : Float = 1.0 - particles[i].t / particles[i].life
      let alpha = (life_ratio * 255.0).to_int()
      if alpha <= 0 {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(144, 236, 255, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 178, 142, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(154, 238, 196, alpha)
      } else {
        @raylib.Color::new(252, 124, 128, alpha)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    draw_cannon(cannon)

    @raylib.draw_rectangle(0, 0, sw, 78, @raylib.Color::new(6, 12, 22, 222))
    @raylib.draw_text(
      "HARBOR DEFENSE 2026",
      18,
      14,
      30,
      @raylib.Color::new(236, 244, 255, 255),
    )
    @raylib.draw_text(
      "A/D move  J fire  K depth charge  L shield",
      18,
      48,
      18,
      @raylib.Color::new(176, 208, 236, 255),
    )

    @raylib.draw_text(
      "Score \{cannon.score}",
      572,
      14,
      28,
      @raylib.Color::new(246, 212, 124, 255),
    )
    @raylib.draw_text(
      "Kills \{cannon.kills}/\{target_kills}",
      768,
      14,
      28,
      @raylib.Color::new(172, 238, 202, 255),
    )
    @raylib.draw_text(
      "Wave \{wave}",
      1000,
      14,
      28,
      @raylib.Color::new(166, 222, 252, 255),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      1120,
      14,
      28,
      @raylib.Color::new(252, 188, 132, 255),
    )

    @raylib.draw_rectangle(20, 90, 240, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      90,
      (cannon.hp / 240.0 * 240.0).to_int(),
      10,
      @raylib.Color::new(112, 226, 156, 255),
    )
    @raylib.draw_text("HP", 20, 104, 16, @raylib.Color::new(186, 212, 234, 255))

    @raylib.draw_rectangle(
      280,
      90,
      240,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      280,
      90,
      (cannon.heat / 100.0 * 240.0).to_int(),
      10,
      @raylib.Color::new(246, 154, 128, 255),
    )
    @raylib.draw_text(
      "HEAT",
      280,
      104,
      16,
      @raylib.Color::new(186, 212, 234, 255),
    )

    @raylib.draw_text(
      "Combo \{cannon.combo}",
      544,
      88,
      20,
      @raylib.Color::new(250, 228, 162, 255),
    )
    @raylib.draw_text(
      "Civilians saved \{civilians_escaped}",
      680,
      88,
      20,
      @raylib.Color::new(172, 236, 204, 255),
    )
    @raylib.draw_text(
      "Lost \{civilians_lost}/18",
      940,
      88,
      20,
      @raylib.Color::new(242, 162, 170, 255),
    )

    @raylib.draw_text(
      "Bomb \{cannon.bomb_cd.to_int()}s",
      20,
      126,
      18,
      @raylib.Color::new(220, 198, 138, 255),
    )
    @raylib.draw_text(
      "Shield \{cannon.shield_cd.to_int()}s",
      180,
      126,
      18,
      @raylib.Color::new(170, 216, 252, 255),
    )
    if cannon.overheated {
      @raylib.draw_text(
        "OVERHEATED",
        360,
        126,
        18,
        @raylib.Color::new(252, 132, 126, 255),
      )
    }

    @raylib.draw_rectangle(
      sw / 2 - 320,
      sh - 52,
      640,
      38,
      @raylib.Color::new(8, 12, 18, 210),
    )
    @raylib.draw_text(
      message,
      sw / 2 - 300,
      sh - 44,
      24,
      @raylib.Color::new(236, 244, 255, if message_t > 0.0 { 255 } else { 152 }),
    )

    @raylib.draw_rectangle(
      22,
      sh - 154,
      104,
      92,
      @raylib.Color::new(62, 84, 110, 214),
    )
    @raylib.draw_text(
      "LEFT",
      44,
      sh - 120,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      142,
      sh - 154,
      104,
      92,
      @raylib.Color::new(62, 84, 110, 214),
    )
    @raylib.draw_text(
      "RIGHT",
      154,
      sh - 120,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 200,
      sh - 208,
      168,
      176,
      @raylib.Color::new(94, 146, 208, 214),
    )
    @raylib.draw_text(
      "FIRE",
      sw - 154,
      sh - 132,
      42,
      @raylib.Color::new(238, 246, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 340,
      sh - 234,
      124,
      84,
      @raylib.Color::new(110, 186, 162, 214),
    )
    @raylib.draw_text(
      "SHIELD",
      sw - 326,
      sh - 202,
      24,
      @raylib.Color::new(236, 248, 244, 255),
    )

    @raylib.draw_rectangle(
      sw - 340,
      sh - 144,
      124,
      84,
      @raylib.Color::new(204, 124, 98, 214),
    )
    @raylib.draw_text(
      "BOMB",
      sw - 314,
      sh - 112,
      30,
      @raylib.Color::new(252, 240, 228, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 468,
        sh / 2 - 212,
        936,
        424,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "HARBOR DEFENSE",
        sw / 2 - 284,
        sh / 2 - 136,
        66,
        @raylib.Color::new(238, 246, 255, 255),
      )
      @raylib.draw_text(
        "Repel raiders, protect civilian boats, hold the line.",
        sw / 2 - 314,
        sh / 2 - 24,
        32,
        @raylib.Color::new(180, 216, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left/right + FIRE, tap SHIELD/BOMB for abilities",
        sw / 2 - 364,
        sh / 2 + 18,
        30,
        @raylib.Color::new(180, 216, 246, 255),
      )
      @raylib.draw_text(
        "Win at 82 kills. Lose at 18 civilian losses.",
        sw / 2 - 272,
        sh / 2 + 66,
        32,
        @raylib.Color::new(252, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 186,
        sh / 2 + 126,
        42,
        @raylib.Color::new(255, 208, 118, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 148))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "HARBOR SECURED",
        sw / 2 - 242,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{cannon.score}",
        sw / 2 - 150,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Kills: \{cannon.kills}  Saved: \{civilians_escaped}",
        sw / 2 - 214,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Civilian losses: \{civilians_lost}",
        sw / 2 - 174,
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
        "HARBOR FALLEN",
        sw / 2 - 224,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{cannon.score}",
        sw / 2 - 150,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Kills: \{cannon.kills} / \{target_kills}",
        sw / 2 - 176,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Civilian losses: \{civilians_lost}",
        sw / 2 - 174,
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
