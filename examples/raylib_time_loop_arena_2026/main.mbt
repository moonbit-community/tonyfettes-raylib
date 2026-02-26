///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let arena_l : Float = 96.0

///|
let arena_t : Float = 88.0

///|
let arena_r : Float = 1184.0

///|
let arena_b : Float = 672.0

///|
let center_x : Float = (arena_l + arena_r) * 0.5

///|
let center_y : Float = (arena_t + arena_b) * 0.5

///|
let loop_seconds : Float = 20.0

///|
let max_frames : Int = 1300

///|
let max_loops : Int = 4

///|
let max_ghosts : Int = 4

///|
let max_enemies : Int = 140

///|
let max_bullets : Int = 640

///|
let max_cores : Int = 120

///|
let max_particles : Int = 1000

///|
let bit_up : Int = 1

///|
let bit_down : Int = 2

///|
let bit_left : Int = 4

///|
let bit_right : Int = 8

///|
let bit_shoot : Int = 16

///|
let bit_dash : Int = 32

///|
let bit_bomb : Int = 64

///|
struct Pilot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut angle : Float
  mut hp : Float
  mut energy : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut bomb_cd : Float
  mut flash_t : Float
  mut score : Int
  mut combo : Int
  mut loops_cleared : Int
}

///|
struct Ghost {
  mut active : Bool
  mut slot : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut angle : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut flash_t : Float
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
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut life : Float
  mut team : Int
}

///|
struct Core {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut t : Float
  mut life : Float
  mut value : Int
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
fn deg2rad(a : Float) -> Double {
  a.to_double() * 0.017453292519943295
}

///|
fn sinf_deg(a : Float) -> Float {
  Float::from_double(@math.sin(deg2rad(a)))
}

///|
fn cosf_deg(a : Float) -> Float {
  Float::from_double(@math.cos(deg2rad(a)))
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
fn encode_input(
  up : Bool,
  down : Bool,
  left : Bool,
  right : Bool,
  shoot : Bool,
  dash : Bool,
  bomb : Bool,
) -> Int {
  let mut m : Int = 0
  if up {
    m = m + bit_up
  }
  if down {
    m = m + bit_down
  }
  if left {
    m = m + bit_left
  }
  if right {
    m = m + bit_right
  }
  if shoot {
    m = m + bit_shoot
  }
  if dash {
    m = m + bit_dash
  }
  if bomb {
    m = m + bit_bomb
  }
  m
}

///|
fn has_flag(mask : Int, flag : Int) -> Bool {
  mask / flag % 2 == 1
}

///|
fn clear_ghosts(ghosts : Array[Ghost]) -> Unit {
  for i = 0; i < ghosts.length(); i = i + 1 {
    ghosts[i].active = false
    ghosts[i].slot = 0
    ghosts[i].x = center_x
    ghosts[i].y = center_y
    ghosts[i].vx = 0.0
    ghosts[i].vy = 0.0
    ghosts[i].angle = 0.0
    ghosts[i].fire_cd = 0.0
    ghosts[i].dash_cd = 0.0
    ghosts[i].flash_t = 0.0
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
    enemies[i].stun_t = 0.0
    enemies[i].t = 0.0
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].active = false
    bullets[i].x = 0.0
    bullets[i].y = 0.0
    bullets[i].vx = 0.0
    bullets[i].vy = 0.0
    bullets[i].dmg = 0.0
    bullets[i].life = 0.0
    bullets[i].team = 0
  }
}

///|
fn clear_cores(cores : Array[Core]) -> Unit {
  for i = 0; i < cores.length(); i = i + 1 {
    cores[i].active = false
    cores[i].x = 0.0
    cores[i].y = 0.0
    cores[i].t = 0.0
    cores[i].life = 0.0
    cores[i].value = 0
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
fn spawn_enemy(enemies : Array[Enemy], level : Int) -> Bool {
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
    let side = @raylib.get_random_value(0, 3)
    let mut x : Float = center_x
    let mut y : Float = center_y

    if side == 0 {
      x = arena_l - 24.0
      y = randf(arena_t + 24.0, arena_b - 24.0)
    } else if side == 1 {
      x = arena_r + 24.0
      y = randf(arena_t + 24.0, arena_b - 24.0)
    } else if side == 2 {
      x = randf(arena_l + 24.0, arena_r - 24.0)
      y = arena_t - 24.0
    } else {
      x = randf(arena_l + 24.0, arena_r - 24.0)
      y = arena_b + 24.0
    }

    let kind = @raylib.get_random_value(0, 2)
    enemies[slot].active = true
    enemies[slot].kind = kind
    enemies[slot].x = x
    enemies[slot].y = y
    enemies[slot].vx = 0.0
    enemies[slot].vy = 0.0
    enemies[slot].hp = 36.0 +
      Float::from_int(kind) * 20.0 +
      Float::from_int(level) * 3.6
    enemies[slot].fire_cd = randf(0.52, 1.30)
    enemies[slot].stun_t = 0.0
    enemies[slot].t = randf(0.0, 5.0)
    true
  }
}

///|
fn spawn_bullet(
  bullets : Array[Bullet],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
  life : Float,
  team : Int,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < bullets.length(); i = i + 1 {
    if not(bullets[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    bullets[slot].active = true
    bullets[slot].x = x
    bullets[slot].y = y
    bullets[slot].vx = vx
    bullets[slot].vy = vy
    bullets[slot].dmg = dmg
    bullets[slot].life = life
    bullets[slot].team = team
    true
  }
}

///|
fn spawn_core(cores : Array[Core], x : Float, y : Float, value : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < cores.length(); i = i + 1 {
    if not(cores[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    false
  } else {
    cores[slot].active = true
    cores[slot].x = x
    cores[slot].y = y
    cores[slot].t = 0.0
    cores[slot].life = randf(7.0, 14.0)
    cores[slot].value = value
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
      parts[i].life = Float::from_int(@raylib.get_random_value(18, 74)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn reset_actor(p : Pilot) -> Unit {
  p.x = center_x
  p.y = center_y
  p.vx = 0.0
  p.vy = 0.0
  p.angle = 0.0
  p.flash_t = 0.0
}

///|
fn rebuild_ghosts(
  ghosts : Array[Ghost],
  recorded_loops : Int,
  current_slot : Int,
) -> Int {
  clear_ghosts(ghosts)

  let available = if recorded_loops < max_loops {
    recorded_loops
  } else {
    max_loops
  }
  let mut gc : Int = 0

  for slot = 0; slot < available; slot = slot + 1 {
    if slot == current_slot {
      continue
    }
    if gc >= ghosts.length() {
      break
    }

    ghosts[gc].active = true
    ghosts[gc].slot = slot
    ghosts[gc].x = center_x
    ghosts[gc].y = center_y
    ghosts[gc].vx = 0.0
    ghosts[gc].vy = 0.0
    ghosts[gc].angle = 0.0
    ghosts[gc].fire_cd = 0.0
    ghosts[gc].dash_cd = 0.0
    ghosts[gc].flash_t = 0.0
    gc = gc + 1
  }

  gc
}

///|
fn main {
  @raylib.init_window(sw, sh, "Time Loop Arena 2026")
  @raylib.set_target_fps(60)

  let pilot : Pilot = {
    x: center_x,
    y: center_y,
    vx: 0.0,
    vy: 0.0,
    angle: 0.0,
    hp: 220.0,
    energy: 100.0,
    fire_cd: 0.0,
    dash_cd: 0.0,
    bomb_cd: 0.0,
    flash_t: 0.0,
    score: 0,
    combo: 0,
    loops_cleared: 0,
  }

  let ghosts : Array[Ghost] = Array::makei(max_ghosts, fn(_i) {
    {
      active: false,
      slot: 0,
      x: center_x,
      y: center_y,
      vx: 0.0,
      vy: 0.0,
      angle: 0.0,
      fire_cd: 0.0,
      dash_cd: 0.0,
      flash_t: 0.0,
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
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0.0,
      life: 0.0,
      team: 0,
    }
  })

  let cores : Array[Core] = Array::makei(max_cores, fn(_i) {
    { active: false, x: 0.0, y: 0.0, t: 0.0, life: 0.0, value: 0 }
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

  let loop_masks : Array[Int] = Array::makei(max_loops * max_frames, fn(_i) {
    0
  })

  let mut state : Int = 0
  let mut mission_time : Float = 240.0
  let mut loop_t : Float = loop_seconds

  let mut recorded_loops : Int = 0
  let mut current_slot : Int = 0
  let mut frame_idx : Int = 0
  let mut ghost_count : Int = 0

  let mut target_score : Int = 3200
  let mut spawn_cd : Float = 0.46
  let mut strike_count : Int = 0

  let mut msg : String = "Record actions, then fight beside your echoes"
  let mut msg_t : Float = 3.0

  let reset_run = fn() {
    mission_time = 240.0
    loop_t = loop_seconds

    recorded_loops = 0
    current_slot = 0
    frame_idx = 0
    ghost_count = 0

    pilot.hp = 220.0
    pilot.energy = 100.0
    pilot.fire_cd = 0.0
    pilot.dash_cd = 0.0
    pilot.bomb_cd = 0.0
    pilot.flash_t = 0.0
    pilot.score = 0
    pilot.combo = 0
    pilot.loops_cleared = 0

    target_score = 3200
    spawn_cd = 0.46
    strike_count = 0

    clear_ghosts(ghosts)
    clear_enemies(enemies)
    clear_bullets(bullets)
    clear_cores(cores)
    clear_particles(particles)

    for i = 0; i < loop_masks.length(); i = i + 1 {
      loop_masks[i] = 0
    }

    reset_actor(pilot)

    msg = "Loop 1 recording"
    msg_t = 1.4

    for i = 0; i < 9; i = i + 1 {
      ignore(i)
      ignore(spawn_enemy(enemies, 1))
    }
  }

  let on_hit = fn(dmg : Float, text : String) {
    pilot.hp = pilot.hp - dmg
    pilot.flash_t = 0.20
    pilot.combo = 0
    strike_count = strike_count + 1
    msg = text
    msg_t = 0.56
    burst(particles, pilot.x, pilot.y, 14, 0.20, 3)
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

    if pilot.flash_t > 0.0 {
      pilot.flash_t = pilot.flash_t - dt
      if pilot.flash_t < 0.0 {
        pilot.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      mission_time = mission_time - dt
      loop_t = loop_t - dt

      let level : Int = pilot.score / 520 + pilot.loops_cleared + 1

      pilot.energy = pilot.energy + dt * 12.0
      if pilot.energy > 100.0 {
        pilot.energy = 100.0
      }

      pilot.fire_cd = pilot.fire_cd - dt
      if pilot.fire_cd < 0.0 {
        pilot.fire_cd = 0.0
      }
      pilot.dash_cd = pilot.dash_cd - dt
      if pilot.dash_cd < 0.0 {
        pilot.dash_cd = 0.0
      }
      pilot.bomb_cd = pilot.bomb_cd - dt
      if pilot.bomb_cd < 0.0 {
        pilot.bomb_cd = 0.0
      }

      let mut up : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut down : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut left : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut right : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)

      let mut shoot_down : Bool = @raylib.is_key_down(@raylib.KeyJ)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut bomb_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_x : Int = 20
      let pad_y : Int = sh - 198
      let btn_x : Int = sw - 296
      let btn_y : Int = sh - 236

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 58, 78, 58) {
          left = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 58, 78, 58) {
          right = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          up = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 116, 78, 58) {
          down = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 74, btn_y + 116, 150, 100) {
          shoot_down = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 8, btn_y + 10, 120, 92) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 136, btn_y + 10, 120, 92) {
          bomb_press = true
        }
      }

      let input_mask = encode_input(
        up, down, left, right, shoot_down, dash_press, bomb_press,
      )
      if frame_idx < max_frames {
        loop_masks[current_slot * max_frames + frame_idx] = input_mask
      }

      // Pilot control.
      let mut ax : Float = 0.0
      let mut ay : Float = 0.0
      if left {
        ax = ax - 520.0
      }
      if right {
        ax = ax + 520.0
      }
      if up {
        ay = ay - 520.0
      }
      if down {
        ay = ay + 520.0
      }

      if pilot.dash_cd > 0.0 {
        ax = ax * 0.82
        ay = ay * 0.82
      }

      pilot.vx = pilot.vx + ax * dt
      pilot.vy = pilot.vy + ay * dt
      pilot.vx = pilot.vx * (1.0 - dt * 2.9)
      pilot.vy = pilot.vy * (1.0 - dt * 2.9)

      let pspd2 = pilot.vx * pilot.vx + pilot.vy * pilot.vy
      if pspd2 > 320.0 * 320.0 {
        let s = pspd2.sqrt()
        let inv : Float = 320.0 / s
        pilot.vx = pilot.vx * inv
        pilot.vy = pilot.vy * inv
      }

      if dash_press && pilot.dash_cd <= 0.0 && pilot.energy >= 16.0 {
        pilot.dash_cd = 1.30
        pilot.energy = pilot.energy - 16.0
        pilot.vx = pilot.vx * 1.62
        pilot.vy = pilot.vy * 1.62
        burst(particles, pilot.x, pilot.y, 16, 0.18, 2)
      }

      if bomb_press && pilot.bomb_cd <= 0.0 && pilot.energy >= 26.0 {
        pilot.bomb_cd = 4.8
        pilot.energy = pilot.energy - 26.0
        msg = "Chrono bomb"
        msg_t = 0.62

        for i = 0; i < enemies.length(); i = i + 1 {
          if enemies[i].active &&
            dist2(pilot.x, pilot.y, enemies[i].x, enemies[i].y) <= 180.0 * 180.0 {
            enemies[i].hp = enemies[i].hp -
              (30.0 + Float::from_int(level) * 1.4)
            enemies[i].stun_t = 1.1
            if enemies[i].hp <= 0.0 {
              let ex = enemies[i].x
              let ey = enemies[i].y
              enemies[i].active = false
              pilot.score = pilot.score + 80 + pilot.combo * 5
              pilot.combo = pilot.combo + 1
              if @raylib.get_random_value(0, 99) < 44 {
                ignore(
                  spawn_core(cores, ex, ey, @raylib.get_random_value(30, 74)),
                )
              }
              burst(particles, ex, ey, 14, 0.18, 1)
            }
          }
        }

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            bullets[i].team == 2 &&
            dist2(pilot.x, pilot.y, bullets[i].x, bullets[i].y) <= 190.0 * 190.0 {
            bullets[i].active = false
          }
        }

        burst(particles, pilot.x, pilot.y, 28, 0.20, 2)
      }

      if shoot_down && pilot.fire_cd <= 0.0 {
        pilot.fire_cd = 0.105
        let aim_x : Float = if absf(ax) + absf(ay) > 0.01 {
          ax
        } else {
          pilot.vx
        }
        let aim_y : Float = if absf(ax) + absf(ay) > 0.01 {
          ay
        } else {
          pilot.vy
        }
        let mut dir_x : Float = 1.0
        let mut dir_y : Float = 0.0
        let l2 = aim_x * aim_x + aim_y * aim_y
        if l2 > 0.01 {
          let inv : Float = 1.0 / l2.sqrt()
          dir_x = aim_x * inv
          dir_y = aim_y * inv
        }
        pilot.angle = Float::from_double(
          @math.atan2(dir_y.to_double(), dir_x.to_double()) * 57.29577951308232,
        )
        ignore(
          spawn_bullet(
            bullets,
            pilot.x + dir_x * 18.0,
            pilot.y + dir_y * 18.0,
            dir_x * 580.0,
            dir_y * 580.0,
            20.0,
            1.3,
            1,
          ),
        )
      }

      pilot.x = pilot.x + pilot.vx * dt
      pilot.y = pilot.y + pilot.vy * dt
      if pilot.x < arena_l + 20.0 {
        pilot.x = arena_l + 20.0
        pilot.vx = absf(pilot.vx) * 0.35
      }
      if pilot.x > arena_r - 20.0 {
        pilot.x = arena_r - 20.0
        pilot.vx = -absf(pilot.vx) * 0.35
      }
      if pilot.y < arena_t + 20.0 {
        pilot.y = arena_t + 20.0
        pilot.vy = absf(pilot.vy) * 0.35
      }
      if pilot.y > arena_b - 20.0 {
        pilot.y = arena_b - 20.0
        pilot.vy = -absf(pilot.vy) * 0.35
      }
      if absf(pilot.vx) + absf(pilot.vy) > 0.2 {
        pilot.angle = Float::from_double(
          @math.atan2(pilot.vy.to_double(), pilot.vx.to_double()) *
          57.29577951308232,
        )
      }

      // Replay ghosts.
      for g = 0; g < ghost_count; g = g + 1 {
        if not(ghosts[g].active) {
          continue
        }

        ghosts[g].fire_cd = ghosts[g].fire_cd - dt
        if ghosts[g].fire_cd < 0.0 {
          ghosts[g].fire_cd = 0.0
        }
        ghosts[g].dash_cd = ghosts[g].dash_cd - dt
        if ghosts[g].dash_cd < 0.0 {
          ghosts[g].dash_cd = 0.0
        }
        ghosts[g].flash_t = ghosts[g].flash_t - dt
        if ghosts[g].flash_t < 0.0 {
          ghosts[g].flash_t = 0.0
        }

        let gmask = loop_masks[ghosts[g].slot * max_frames + frame_idx]

        let mut gx_axis : Float = 0.0
        let mut gy_axis : Float = 0.0
        if has_flag(gmask, bit_left) {
          gx_axis = gx_axis - 440.0
        }
        if has_flag(gmask, bit_right) {
          gx_axis = gx_axis + 440.0
        }
        if has_flag(gmask, bit_up) {
          gy_axis = gy_axis - 440.0
        }
        if has_flag(gmask, bit_down) {
          gy_axis = gy_axis + 440.0
        }

        ghosts[g].vx = ghosts[g].vx + gx_axis * dt
        ghosts[g].vy = ghosts[g].vy + gy_axis * dt
        ghosts[g].vx = ghosts[g].vx * (1.0 - dt * 3.0)
        ghosts[g].vy = ghosts[g].vy * (1.0 - dt * 3.0)

        let gspd2 = ghosts[g].vx * ghosts[g].vx + ghosts[g].vy * ghosts[g].vy
        if gspd2 > 270.0 * 270.0 {
          let inv : Float = 270.0 / gspd2.sqrt()
          ghosts[g].vx = ghosts[g].vx * inv
          ghosts[g].vy = ghosts[g].vy * inv
        }

        if has_flag(gmask, bit_dash) && ghosts[g].dash_cd <= 0.0 {
          ghosts[g].dash_cd = 1.45
          ghosts[g].vx = ghosts[g].vx * 1.55
          ghosts[g].vy = ghosts[g].vy * 1.55
          ghosts[g].flash_t = 0.16
        }

        if has_flag(gmask, bit_shoot) && ghosts[g].fire_cd <= 0.0 {
          ghosts[g].fire_cd = 0.14
          let aim_x = if absf(gx_axis) + absf(gy_axis) > 0.01 {
            gx_axis
          } else {
            ghosts[g].vx
          }
          let aim_y = if absf(gx_axis) + absf(gy_axis) > 0.01 {
            gy_axis
          } else {
            ghosts[g].vy
          }
          let mut dir_x : Float = 1.0
          let mut dir_y : Float = 0.0
          let l2 = aim_x * aim_x + aim_y * aim_y
          if l2 > 0.01 {
            let inv : Float = 1.0 / l2.sqrt()
            dir_x = aim_x * inv
            dir_y = aim_y * inv
          }
          ghosts[g].angle = Float::from_double(
            @math.atan2(dir_y.to_double(), dir_x.to_double()) *
            57.29577951308232,
          )
          ignore(
            spawn_bullet(
              bullets,
              ghosts[g].x + dir_x * 14.0,
              ghosts[g].y + dir_y * 14.0,
              dir_x * 500.0,
              dir_y * 500.0,
              12.0,
              1.1,
              1,
            ),
          )
        }

        ghosts[g].x = ghosts[g].x + ghosts[g].vx * dt
        ghosts[g].y = ghosts[g].y + ghosts[g].vy * dt
        ghosts[g].x = clampf(ghosts[g].x, arena_l + 16.0, arena_r - 16.0)
        ghosts[g].y = clampf(ghosts[g].y, arena_t + 16.0, arena_b - 16.0)
        if absf(ghosts[g].vx) + absf(ghosts[g].vy) > 0.2 {
          ghosts[g].angle = Float::from_double(
            @math.atan2(ghosts[g].vy.to_double(), ghosts[g].vx.to_double()) *
            57.29577951308232,
          )
        }
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        ignore(spawn_enemy(enemies, level))
        let lo = clampf(0.65 - Float::from_int(level) * 0.020, 0.16, 0.65)
        let hi = clampf(1.05 - Float::from_int(level) * 0.018, 0.24, 1.05)
        spawn_cd = randf(lo, hi)
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        enemies[i].t = enemies[i].t + dt
        enemies[i].fire_cd = enemies[i].fire_cd - dt
        enemies[i].stun_t = enemies[i].stun_t - dt
        if enemies[i].fire_cd < 0.0 {
          enemies[i].fire_cd = 0.0
        }
        if enemies[i].stun_t < 0.0 {
          enemies[i].stun_t = 0.0
        }

        // Nearest target among pilot and active ghosts.
        let mut tx = pilot.x
        let mut ty = pilot.y
        let mut best_d2 = dist2(enemies[i].x, enemies[i].y, pilot.x, pilot.y)

        for g = 0; g < ghost_count; g = g + 1 {
          if ghosts[g].active {
            let gd2 = dist2(
              enemies[i].x,
              enemies[i].y,
              ghosts[g].x,
              ghosts[g].y,
            )
            if gd2 < best_d2 {
              best_d2 = gd2
              tx = ghosts[g].x
              ty = ghosts[g].y
            }
          }
        }

        let dx : Float = tx - enemies[i].x
        let dy : Float = ty - enemies[i].y
        let mut inv : Float = 0.0
        let n2 : Float = dx * dx + dy * dy
        if n2 > 0.01 {
          inv = 1.0 / n2.sqrt()
        }

        if enemies[i].stun_t <= 0.0 {
          let accel : Float = 180.0 +
            Float::from_int(enemies[i].kind) * 44.0 +
            Float::from_int(level) * 4.4
          enemies[i].vx = enemies[i].vx + dx * inv * accel * dt
          enemies[i].vy = enemies[i].vy + dy * inv * accel * dt
        }

        let drag : Float = if enemies[i].stun_t > 0.0 { 4.5 } else { 2.3 }
        enemies[i].vx = enemies[i].vx * (1.0 - dt * drag)
        enemies[i].vy = enemies[i].vy * (1.0 - dt * drag)

        let espd2 : Float = enemies[i].vx * enemies[i].vx +
          enemies[i].vy * enemies[i].vy
        let max_spd : Float = 140.0 +
          Float::from_int(enemies[i].kind) * 38.0 +
          Float::from_int(level) * 3.0
        if espd2 > max_spd * max_spd {
          let invs : Float = max_spd / espd2.sqrt()
          enemies[i].vx = enemies[i].vx * invs
          enemies[i].vy = enemies[i].vy * invs
        }

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt
        enemies[i].x = clampf(enemies[i].x, arena_l + 16.0, arena_r - 16.0)
        enemies[i].y = clampf(enemies[i].y, arena_t + 16.0, arena_b - 16.0)

        if enemies[i].fire_cd <= 0.0 && n2 <= 380.0 * 380.0 {
          enemies[i].fire_cd = randf(0.72, 1.58)
          let bspd : Float = 220.0 +
            Float::from_int(enemies[i].kind) * 42.0 +
            Float::from_int(level) * 3.0
          ignore(
            spawn_bullet(
              bullets,
              enemies[i].x,
              enemies[i].y,
              dx * inv * bspd,
              dy * inv * bspd,
              9.0 + Float::from_int(enemies[i].kind) * 2.4,
              2.8,
              2,
            ),
          )
        }

        if dist2(enemies[i].x, enemies[i].y, pilot.x, pilot.y) <= 24.0 * 24.0 {
          on_hit(7.0 + Float::from_int(enemies[i].kind) * 2.2, "Contact hit")
          enemies[i].stun_t = 0.45
          enemies[i].vx = -enemies[i].vx
          enemies[i].vy = -enemies[i].vy
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

        if bullets[i].x < arena_l - 36.0 ||
          bullets[i].x > arena_r + 36.0 ||
          bullets[i].y < arena_t - 36.0 ||
          bullets[i].y > arena_b + 36.0 {
          bullets[i].active = false
          continue
        }

        if bullets[i].team == 1 {
          for e = 0; e < enemies.length(); e = e + 1 {
            if enemies[e].active &&
              dist2(bullets[i].x, bullets[i].y, enemies[e].x, enemies[e].y) <=
              18.0 * 18.0 {
              bullets[i].active = false
              enemies[e].hp = enemies[e].hp - bullets[i].dmg
              enemies[e].stun_t = 0.16
              burst(particles, bullets[i].x, bullets[i].y, 6, 0.10, 0)

              if enemies[e].hp <= 0.0 {
                let ex = enemies[e].x
                let ey = enemies[e].y
                let reward = 34 + enemies[e].kind * 18
                enemies[e].active = false
                pilot.score = pilot.score + reward + pilot.combo * 3
                pilot.combo = pilot.combo + 1
                if @raylib.get_random_value(0, 99) < 42 {
                  ignore(
                    spawn_core(cores, ex, ey, @raylib.get_random_value(24, 80)),
                  )
                }
                burst(particles, ex, ey, 12, 0.17, 1)
              }
              break
            }
          }
        } else if dist2(bullets[i].x, bullets[i].y, pilot.x, pilot.y) <=
          16.0 * 16.0 {
          bullets[i].active = false
          on_hit(bullets[i].dmg, "Pulse shot")
        }
      }

      for i = 0; i < cores.length(); i = i + 1 {
        if not(cores[i].active) {
          continue
        }

        cores[i].t = cores[i].t + dt
        if cores[i].t >= cores[i].life {
          cores[i].active = false
          continue
        }

        if dist2(cores[i].x, cores[i].y, pilot.x, pilot.y) <= 24.0 * 24.0 {
          pilot.score = pilot.score + cores[i].value
          pilot.energy = clampf(
            pilot.energy + Float::from_int(cores[i].value) * 0.22,
            0.0,
            100.0,
          )
          msg = "Data core +\{cores[i].value}"
          msg_t = 0.48
          burst(particles, cores[i].x, cores[i].y, 8, 0.12, 2)
          cores[i].active = false
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

      frame_idx = frame_idx + 1
      if frame_idx >= max_frames || loop_t <= 0.0 {
        recorded_loops = recorded_loops + 1
        pilot.loops_cleared = pilot.loops_cleared + 1

        current_slot = recorded_loops % max_loops
        frame_idx = 0
        loop_t = loop_seconds

        reset_actor(pilot)
        ghost_count = rebuild_ghosts(ghosts, recorded_loops, current_slot)

        msg = "Loop rewind: echoes online (\{ghost_count})"
        msg_t = 1.0
        burst(particles, pilot.x, pilot.y, 24, 0.18, 2)
      }

      if pilot.score >= target_score {
        state = 2
      } else if pilot.hp <= 0.0 || mission_time <= 0.0 {
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
      @raylib.Color::new(14, 24, 24, 255)
    } else if state == 3 {
      @raylib.Color::new(26, 14, 20, 255)
    } else {
      @raylib.Color::new(10, 12, 24, 255)
    }
    @raylib.clear_background(bg_col)

    @raylib.draw_rectangle(0, 0, sw, 180, @raylib.Color::new(18, 28, 54, 255))

    for i = 0; i < 40; i = i + 1 {
      let sx = i * 32 + (mission_time * 22.0).to_int() % 32
      let sy = 14 + i * 19 % 150
      @raylib.draw_circle(sx, sy, 1.8, @raylib.Color::new(168, 208, 252, 166))
    }

    @raylib.draw_rectangle(
      arena_l.to_int(),
      arena_t.to_int(),
      (arena_r - arena_l).to_int(),
      (arena_b - arena_t).to_int(),
      @raylib.Color::new(20, 30, 42, 255),
    )
    @raylib.draw_rectangle_lines(
      arena_l.to_int(),
      arena_t.to_int(),
      (arena_r - arena_l).to_int(),
      (arena_b - arena_t).to_int(),
      @raylib.Color::new(118, 170, 236, 220),
    )

    for i = 0; i < 22; i = i + 1 {
      let x = arena_l.to_int() + i * 50
      @raylib.draw_line(
        x,
        arena_t.to_int(),
        x,
        arena_b.to_int(),
        @raylib.Color::new(44, 60, 86, 88),
      )
    }
    for i = 0; i < 12; i = i + 1 {
      let y = arena_t.to_int() + i * 48
      @raylib.draw_line(
        arena_l.to_int(),
        y,
        arena_r.to_int(),
        y,
        @raylib.Color::new(44, 60, 86, 88),
      )
    }

    for i = 0; i < cores.length(); i = i + 1 {
      if cores[i].active {
        let blink = (cores[i].t * 8.0).to_int() % 2 == 0
        let col = if blink {
          @raylib.Color::new(146, 244, 202, 255)
        } else {
          @raylib.Color::new(108, 212, 170, 220)
        }
        @raylib.draw_circle(cores[i].x.to_int(), cores[i].y.to_int(), 9.0, col)
        @raylib.draw_circle_lines(
          cores[i].x.to_int(),
          cores[i].y.to_int(),
          13.0,
          @raylib.Color::new(36, 64, 62, 220),
        )
      }
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if bullets[i].active {
        if bullets[i].team == 1 {
          @raylib.draw_circle(
            bullets[i].x.to_int(),
            bullets[i].y.to_int(),
            4.2,
            @raylib.Color::new(120, 226, 252, 255),
          )
        } else {
          @raylib.draw_circle(
            bullets[i].x.to_int(),
            bullets[i].y.to_int(),
            4.6,
            @raylib.Color::new(252, 132, 128, 255),
          )
        }
      }
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].active {
        let body_col = if enemies[i].kind == 0 {
          @raylib.Color::new(202, 114, 110, 255)
        } else if enemies[i].kind == 1 {
          @raylib.Color::new(188, 88, 128, 255)
        } else {
          @raylib.Color::new(162, 72, 148, 255)
        }

        @raylib.draw_circle(
          enemies[i].x.to_int(),
          enemies[i].y.to_int(),
          15.0,
          body_col,
        )
        @raylib.draw_circle(
          enemies[i].x.to_int(),
          enemies[i].y.to_int(),
          6.0,
          @raylib.Color::new(252, 228, 188, 255),
        )

        if enemies[i].stun_t > 0.0 {
          @raylib.draw_circle_lines(
            enemies[i].x.to_int(),
            enemies[i].y.to_int(),
            20.0,
            @raylib.Color::new(130, 224, 255, 255),
          )
        }
      }
    }

    for g = 0; g < ghost_count; g = g + 1 {
      if ghosts[g].active {
        let gcol = if ghosts[g].flash_t > 0.0 {
          @raylib.Color::new(178, 250, 214, 255)
        } else {
          @raylib.Color::new(122, 232, 196, 190)
        }
        let gx = cosf_deg(ghosts[g].angle)
        let gy = sinf_deg(ghosts[g].angle)
        @raylib.draw_circle(
          ghosts[g].x.to_int(),
          ghosts[g].y.to_int(),
          12.0,
          gcol,
        )
        @raylib.draw_circle_lines(
          ghosts[g].x.to_int(),
          ghosts[g].y.to_int(),
          16.0,
          @raylib.Color::new(88, 182, 170, 220),
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(ghosts[g].x, ghosts[g].y),
          @raylib.Vector2::new(ghosts[g].x + gx * 16.0, ghosts[g].y + gy * 16.0),
          3.0,
          @raylib.Color::new(208, 254, 236, 214),
        )
      }
    }

    let pilot_col = if pilot.flash_t > 0.0 {
      @raylib.Color::new(252, 146, 146, 255)
    } else {
      @raylib.Color::new(126, 214, 252, 255)
    }
    let px = cosf_deg(pilot.angle)
    let py = sinf_deg(pilot.angle)
    @raylib.draw_circle(pilot.x.to_int(), pilot.y.to_int(), 15.0, pilot_col)
    @raylib.draw_circle(
      pilot.x.to_int(),
      pilot.y.to_int(),
      7.0,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(pilot.x, pilot.y),
      @raylib.Vector2::new(pilot.x + px * 20.0, pilot.y + py * 20.0),
      4.0,
      @raylib.Color::new(236, 248, 255, 224),
    )

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let ratio : Float = 1.0 - particles[i].t / particles[i].life
      let alpha = (ratio * 255.0).to_int()
      if alpha <= 0 {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(146, 232, 252, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 172, 142, alpha)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(148, 244, 200, alpha)
      } else {
        @raylib.Color::new(252, 128, 152, alpha)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 10, 20, 228))
    @raylib.draw_text(
      "TIME LOOP ARENA 2026",
      16,
      12,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  J fire  K dash  L chrono bomb",
      16,
      48,
      18,
      @raylib.Color::new(176, 206, 236, 255),
    )

    @raylib.draw_text(
      "Score \{pilot.score}/\{target_score}",
      500,
      14,
      28,
      @raylib.Color::new(250, 218, 132, 255),
    )
    @raylib.draw_text(
      "Loop \{pilot.loops_cleared + 1}",
      766,
      14,
      28,
      @raylib.Color::new(166, 236, 200, 255),
    )
    @raylib.draw_text(
      "Time \{mission_time.to_int()}s",
      930,
      14,
      28,
      @raylib.Color::new(248, 188, 132, 255),
    )
    @raylib.draw_text(
      "Strikes \{strike_count}",
      1102,
      14,
      28,
      @raylib.Color::new(246, 160, 170, 255),
    )

    @raylib.draw_rectangle(16, 84, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      16,
      84,
      (pilot.hp / 220.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(112, 226, 160, 255),
    )
    @raylib.draw_text("HP", 16, 98, 16, @raylib.Color::new(186, 212, 232, 255))

    @raylib.draw_rectangle(
      252,
      84,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      252,
      84,
      (pilot.energy / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(116, 198, 248, 255),
    )
    @raylib.draw_text(
      "ENERGY",
      252,
      98,
      16,
      @raylib.Color::new(186, 212, 232, 255),
    )

    @raylib.draw_text(
      "Echoes \{ghost_count}",
      500,
      84,
      20,
      @raylib.Color::new(156, 236, 206, 255),
    )
    @raylib.draw_text(
      "Combo \{pilot.combo}",
      620,
      84,
      20,
      @raylib.Color::new(252, 224, 162, 255),
    )
    @raylib.draw_text(
      "Dash \{pilot.dash_cd.to_int()}  Bomb \{pilot.bomb_cd.to_int()}",
      760,
      84,
      20,
      @raylib.Color::new(206, 190, 162, 255),
    )
    @raylib.draw_text(
      "Loop t \{loop_t.to_int()}s",
      1040,
      84,
      20,
      @raylib.Color::new(182, 224, 252, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 340,
      sh - 52,
      680,
      38,
      @raylib.Color::new(8, 12, 18, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 320,
      sh - 44,
      24,
      @raylib.Color::new(236, 244, 255, if msg_t > 0.0 { 255 } else { 148 }),
    )

    // Touch controls.
    @raylib.draw_rectangle(
      20,
      sh - 198,
      238,
      172,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let p0x = 20
    let p0y = sh - 198
    @raylib.draw_rectangle(
      p0x,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "L",
      p0x + 30,
      p0y + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 160,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "R",
      p0x + 190,
      p0y + 74,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "U",
      p0x + 110,
      p0y + 16,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y + 116,
      78,
      58,
      @raylib.Color::new(56, 82, 116, 255),
    )
    @raylib.draw_text(
      "D",
      p0x + 110,
      p0y + 132,
      28,
      @raylib.Color::new(220, 236, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 296,
      sh - 236,
      272,
      224,
      @raylib.Color::new(8, 12, 18, 214),
    )
    let p1x = sw - 296
    let p1y = sh - 236
    @raylib.draw_rectangle(
      p1x + 8,
      p1y + 10,
      120,
      92,
      @raylib.Color::new(214, 118, 102, 255),
    )
    @raylib.draw_text(
      "DASH",
      p1x + 32,
      p1y + 44,
      30,
      @raylib.Color::new(252, 238, 230, 255),
    )
    @raylib.draw_rectangle(
      p1x + 136,
      p1y + 10,
      120,
      92,
      @raylib.Color::new(86, 148, 216, 255),
    )
    @raylib.draw_text(
      "BOMB",
      p1x + 164,
      p1y + 44,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      p1x + 74,
      p1y + 116,
      150,
      100,
      @raylib.Color::new(98, 186, 138, 255),
    )
    @raylib.draw_text(
      "FIRE",
      p1x + 120,
      p1y + 154,
      30,
      @raylib.Color::new(236, 248, 242, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 468,
        sh / 2 - 206,
        936,
        412,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "TIME LOOP ARENA",
        sw / 2 - 278,
        sh / 2 - 132,
        64,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Every 20s the timeline rewinds and your past run becomes an echo ally.",
        sw / 2 - 400,
        sh / 2 - 28,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad movement, right buttons dash/bomb/fire",
        sw / 2 - 342,
        sh / 2 + 16,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Reach 3200 score before HP or time runs out",
        sw / 2 - 272,
        sh / 2 + 60,
        32,
        @raylib.Color::new(252, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 184,
        sh / 2 + 124,
        42,
        @raylib.Color::new(255, 206, 114, 255),
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
        "TIMELINE STABLE",
        sw / 2 - 238,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{pilot.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Loops cleared: \{pilot.loops_cleared}  Strikes: \{strike_count}",
        sw / 2 - 250,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
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
        "TIMELINE COLLAPSED",
        sw / 2 - 294,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{pilot.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Loops: \{pilot.loops_cleared}  Strikes: \{strike_count}",
        sw / 2 - 208,
        sh / 2 + 18,
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
