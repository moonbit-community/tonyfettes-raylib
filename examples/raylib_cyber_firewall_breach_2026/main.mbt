///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let arena_x : Int = 210

///|
let arena_y : Int = 118

///|
let arena_w : Int = 1020

///|
let arena_h : Int = 628

///|
let core_x : Float = 150.0

///|
let player_x : Float = 132.0

///|
let max_enemies : Int = 84

///|
let max_shots : Int = 180

///|
let max_parts : Int = 220

///|
struct Enemy {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut kind : Int
  mut active : Bool
}

///|
struct Shot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut ttl : Float
  mut active : Bool
}

///|
struct Part {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut kind : Int
  mut active : Bool
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn enemy_hp(kind : Int) -> Int {
  if kind == 0 {
    1
  } else if kind == 1 {
    2
  } else {
    4
  }
}

///|
fn enemy_damage(kind : Int) -> Int {
  if kind == 0 {
    8
  } else if kind == 1 {
    14
  } else {
    22
  }
}

///|
fn enemy_score(kind : Int) -> Int {
  if kind == 0 {
    26
  } else if kind == 1 {
    46
  } else {
    90
  }
}

///|
fn enemy_r(kind : Int) -> Float {
  if kind == 0 {
    11.0
  } else if kind == 1 {
    16.0
  } else {
    22.0
  }
}

///|
fn clear_enemies(enemies : Array[Enemy]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].x = 0.0
    enemies[i].y = 0.0
    enemies[i].vx = 0.0
    enemies[i].vy = 0.0
    enemies[i].hp = 0
    enemies[i].kind = 0
    enemies[i].active = false
  }
}

///|
fn clear_shots(shots : Array[Shot]) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    shots[i].x = 0.0
    shots[i].y = 0.0
    shots[i].vx = 0.0
    shots[i].ttl = 0.0
    shots[i].active = false
  }
}

///|
fn clear_parts(parts : Array[Part]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].ttl = 0.0
    parts[i].kind = 0
    parts[i].active = false
  }
}

///|
fn spawn_part(parts : Array[Part], x : Float, y : Float, speed_scale : Float, kind : Int) -> Unit {
  let mut done = false
  for i = 0; i < parts.length(); i = i + 1 {
    if done {
      continue
    }
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-220, 220)) * speed_scale
      parts[i].vy = Float::from_int(@raylib.get_random_value(-220, 220)) * speed_scale
      parts[i].ttl = Float::from_int(@raylib.get_random_value(18, 56)) / Float::from_int(100)
      parts[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(parts : Array[Part], x : Float, y : Float, n : Int, speed_scale : Float, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_part(parts, x, y, speed_scale, kind)
  }
}

///|
fn spawn_shot(shots : Array[Shot], x : Float, y : Float) -> Unit {
  let mut done = false
  for i = 0; i < shots.length(); i = i + 1 {
    if done {
      continue
    }
    if not(shots[i].active) {
      shots[i].active = true
      shots[i].x = x
      shots[i].y = y
      shots[i].vx = 700.0
      shots[i].ttl = 1.7
      done = true
    }
  }
}

///|
fn spawn_enemy(enemies : Array[Enemy], sector : Int) -> Unit {
  let kind_roll = @raylib.get_random_value(0, 99)
  let kind = if kind_roll < 56 {
    0
  } else if kind_roll < 86 {
    1
  } else {
    2
  }

  let mut done = false
  for i = 0; i < enemies.length(); i = i + 1 {
    if done {
      continue
    }
    if not(enemies[i].active) {
      enemies[i].active = true
      enemies[i].x = Float::from_int(sw + 40 + @raylib.get_random_value(0, 120))
      enemies[i].y = Float::from_int(@raylib.get_random_value(arena_y + 24, arena_y + arena_h - 24))

      let mut spd : Float = 0.0
      if kind == 0 {
        spd = Float::from_int(140 + sector * 20)
      } else if kind == 1 {
        spd = Float::from_int(114 + sector * 18)
      } else {
        spd = Float::from_int(92 + sector * 16)
      }

      enemies[i].vx = -spd
      enemies[i].vy = Float::from_int(@raylib.get_random_value(-68, 68))
      enemies[i].kind = kind
      enemies[i].hp = enemy_hp(kind)
      done = true
    }
  }
}

///|
fn spawn_split(enemies : Array[Enemy], x : Float, y : Float, sector : Int) -> Unit {
  for _k = 0; _k < 2; _k = _k + 1 {
    let mut done = false
    for i = 0; i < enemies.length(); i = i + 1 {
      if done {
        continue
      }
      if not(enemies[i].active) {
        enemies[i].active = true
        enemies[i].x = x + Float::from_int(@raylib.get_random_value(-10, 10))
        enemies[i].y = y + Float::from_int(@raylib.get_random_value(-10, 10))
        enemies[i].vx = -Float::from_int(190 + sector * 24 + @raylib.get_random_value(0, 30))
        enemies[i].vy = Float::from_int(@raylib.get_random_value(-100, 100))
        enemies[i].kind = 0
        enemies[i].hp = 1
        done = true
      }
    }
  }
}

///|
fn spawn_interval(sector : Int) -> Float {
  let mut lo = 48 - sector * 8
  if lo < 16 {
    lo = 16
  }
  let mut hi = 90 - sector * 10
  if hi < 28 {
    hi = 28
  }
  Float::from_int(@raylib.get_random_value(lo, hi)) / Float::from_int(100)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Cyber Firewall Breach 2026")
  @raylib.set_target_fps(60)

  let enemies : Array[Enemy] = Array::makei(max_enemies, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, hp: 0, kind: 0, active: false }
  })
  let shots : Array[Shot] = Array::makei(max_shots, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, ttl: 0.0, active: false }
  })
  let parts : Array[Part] = Array::makei(max_parts, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, kind: 0, active: false }
  })

  clear_enemies(enemies)
  clear_shots(shots)
  clear_parts(parts)

  let mut sector = 1
  let mut sector_timer : Float = 0.0
  let mut score = 0
  let mut core_hp = 280

  let mut py : Float = Float::from_int(arena_y + arena_h / 2)
  let mut fire_cd : Float = 0.0
  let mut pulse_cd : Float = 0.0
  let mut heat : Float = 0.0
  let mut spawn_cd : Float = 0.6

  let mut shake_t : Float = 0.0
  let mut flash_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "W/S move, Space/J fire, K pulse. Protect core integrity."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      clear_enemies(enemies)
      clear_shots(shots)
      clear_parts(parts)

      sector = 1
      sector_timer = 0.0
      score = 0
      core_hp = 280

      py = Float::from_int(arena_y + arena_h / 2)
      fire_cd = 0.0
      pulse_cd = 0.0
      heat = 0.0
      spawn_cd = 0.6
      shake_t = 0.0
      flash_t = 0.0

      over = false
      won = false
      msg = "Firewall rebooted."
    }

    if fire_cd > 0.0 {
      fire_cd = fire_cd - dt
      if fire_cd < 0.0 {
        fire_cd = 0.0
      }
    }

    if pulse_cd > 0.0 {
      pulse_cd = pulse_cd - dt
      if pulse_cd < 0.0 {
        pulse_cd = 0.0
      }
    }

    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }

    if flash_t > 0.0 {
      flash_t = flash_t - dt
      if flash_t < 0.0 {
        flash_t = 0.0
      }
    }

    if heat > 0.0 {
      heat = heat - 26.0 * dt
      if heat < 0.0 {
        heat = 0.0
      }
    }

    if not(over) {
      sector_timer = sector_timer + dt
      if sector_timer >= 42.0 {
        sector = sector + 1
        if sector > 3 {
          over = true
          won = true
          msg = "Breach contained. Network secured."
        } else {
          sector_timer = 0.0
          msg = "Sector \{sector} started. Malware got faster."
          clear_enemies(enemies)
          clear_shots(shots)
          spawn_cd = 0.5
        }
      }

      let mut up = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut down = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut fire = @raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyJ)
      let mut pulse = @raylib.is_key_pressed(@raylib.KeyK) || @raylib.is_key_pressed(@raylib.KeyL)

      let ctl_x = 22
      let ctl_y = sh - 174
      let fire_x = sw - 208
      let fire_y = sh - 154
      let pulse_x = sw - 208
      let pulse_y = sh - 290
      let m = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x, ctl_y, 76, 54) {
          up = true
        }
        if inside_rect(m.x, m.y, ctl_x, ctl_y + 62, 76, 54) {
          down = true
        }
        if inside_rect(m.x, m.y, fire_x, fire_y, 176, 120) {
          fire = true
        }
      }
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pulse_x, pulse_y, 176, 94) {
          pulse = true
        }
      }

      let speed : Float = Float::from_int(360 + sector * 22)
      if up {
        py = py - speed * dt
      }
      if down {
        py = py + speed * dt
      }
      py = clampf(py, Float::from_int(arena_y + 24), Float::from_int(arena_y + arena_h - 24))

      if fire && fire_cd <= 0.0 && heat <= 96.0 {
        spawn_shot(shots, player_x + 26.0, py)
        fire_cd = 0.10
        heat = heat + 9.0
        if heat > 100.0 {
          heat = 100.0
        }
      }

      if pulse && pulse_cd <= 0.0 && heat <= 70.0 {
        pulse_cd = 2.2
        heat = heat + 22.0
        if heat > 100.0 {
          heat = 100.0
        }

        let px = player_x + 82.0
        let pr : Float = 162.0
        burst(parts, px, py, 42, 1.12, 0)

        for i = 0; i < enemies.length(); i = i + 1 {
          if not(enemies[i].active) {
            continue
          }
          let dx = enemies[i].x - px
          let dy = enemies[i].y - py
          if dx * dx + dy * dy <= pr * pr {
            enemies[i].hp = enemies[i].hp - 2
            if enemies[i].hp <= 0 {
              let k = enemies[i].kind
              enemies[i].active = false
              score = score + enemy_score(k)
              burst(parts, enemies[i].x, enemies[i].y, 12, 1.0, 1)
            }
          }
        }
        msg = "Pulse released."
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, sector)
        spawn_cd = spawn_interval(sector)
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }
        shots[i].x = shots[i].x + shots[i].vx * dt
        shots[i].ttl = shots[i].ttl - dt
        if shots[i].ttl <= 0.0 || shots[i].x > Float::from_int(sw + 24) {
          shots[i].active = false
        }
      }

      let mut core_hit = 0

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt

        if enemies[i].y < Float::from_int(arena_y + 16) {
          enemies[i].y = Float::from_int(arena_y + 16)
          enemies[i].vy = absf(enemies[i].vy)
        }
        if enemies[i].y > Float::from_int(arena_y + arena_h - 16) {
          enemies[i].y = Float::from_int(arena_y + arena_h - 16)
          enemies[i].vy = -absf(enemies[i].vy)
        }

        if enemies[i].x <= core_x + enemy_r(enemies[i].kind) {
          core_hit = core_hit + enemy_damage(enemies[i].kind)
          burst(parts, core_x + 8.0, enemies[i].y, 16, 1.0, 2)
          enemies[i].active = false
        }

        if enemies[i].x < -60.0 {
          enemies[i].active = false
        }
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }

        let mut hit = false
        for j = 0; j < enemies.length(); j = j + 1 {
          if hit {
            continue
          }
          if not(enemies[j].active) {
            continue
          }

          let dx = shots[i].x - enemies[j].x
          let dy = shots[i].y - enemies[j].y
          let rr = enemy_r(enemies[j].kind) + 5.0
          if dx * dx + dy * dy <= rr * rr {
            shots[i].active = false
            enemies[j].hp = enemies[j].hp - 1
            hit = true

            if enemies[j].hp <= 0 {
              let k = enemies[j].kind
              let ex = enemies[j].x
              let ey = enemies[j].y
              enemies[j].active = false
              score = score + enemy_score(k)
              burst(parts, ex, ey, 12, 0.9, 1)

              if k == 2 {
                spawn_split(enemies, ex, ey, sector)
              }
            } else {
              burst(parts, enemies[j].x, enemies[j].y, 6, 0.7, 0)
            }
          }
        }
      }

      if core_hit > 0 {
        core_hp = core_hp - core_hit
        if core_hp < 0 {
          core_hp = 0
        }
        shake_t = 0.16
        flash_t = 0.18
        msg = "Core damaged -\{core_hit}."
      }

      if core_hp <= 0 {
        over = true
        won = false
        msg = "Firewall collapsed. Press R to reboot."
      }
    }

    for i = 0; i < parts.length(); i = i + 1 {
      if not(parts[i].active) {
        continue
      }
      parts[i].x = parts[i].x + parts[i].vx * dt
      parts[i].y = parts[i].y + parts[i].vy * dt
      parts[i].vx = parts[i].vx * (Float::from_int(1) - dt * 2.3)
      parts[i].vy = parts[i].vy * (Float::from_int(1) - dt * 2.3)
      parts[i].ttl = parts[i].ttl - dt
      if parts[i].ttl <= 0.0 {
        parts[i].active = false
      }
    }

    let shake_x = if shake_t > 0.0 {
      Float::from_int(@raylib.get_random_value(-6, 6)) * shake_t * 8.0
    } else {
      0.0
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(40, 16, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 24, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(12, 22, 38, 255))
    @raylib.draw_rectangle(0, 0, sw, 260, @raylib.Color::new(20, 34, 58, 255))

    @raylib.draw_rectangle(arena_x, arena_y, arena_w, arena_h, @raylib.Color::new(18, 28, 46, 255))
    @raylib.draw_rectangle_lines(arena_x, arena_y, arena_w, arena_h, @raylib.Color::new(80, 122, 190, 255))

    for i = 0; i <= 16; i = i + 1 {
      let gx = arena_x + i * (arena_w / 16)
      @raylib.draw_line(gx, arena_y, gx, arena_y + arena_h, @raylib.Color::new(36, 56, 86, 130))
    }
    for i = 0; i <= 10; i = i + 1 {
      let gy = arena_y + i * (arena_h / 10)
      @raylib.draw_line(arena_x, gy, arena_x + arena_w, gy, @raylib.Color::new(36, 56, 86, 130))
    }

    @raylib.draw_rectangle((core_x - 30.0 + shake_x).to_int(), arena_y + arena_h / 2 - 120, 46, 240, @raylib.Color::new(80, 208, 244, 255))
    @raylib.draw_rectangle((core_x - 10.0 + shake_x).to_int(), arena_y + arena_h / 2 - 90, 16, 180, @raylib.Color::new(16, 44, 78, 255))
    @raylib.draw_circle((core_x + 14.0 + shake_x).to_int(), py.to_int(), 24.0, @raylib.Color::new(102, 232, 252, 255))

    @raylib.draw_rectangle((player_x - 16.0 + shake_x).to_int(), (py - 24.0).to_int(), 30, 48, @raylib.Color::new(110, 222, 242, 255))
    @raylib.draw_rectangle((player_x + 12.0 + shake_x).to_int(), (py - 8.0).to_int(), 22, 16, @raylib.Color::new(196, 242, 252, 255))

    for i = 0; i < shots.length(); i = i + 1 {
      if not(shots[i].active) {
        continue
      }
      let sx = shots[i].x + shake_x
      @raylib.draw_rectangle(sx.to_int(), (shots[i].y - 3.0).to_int(), 14, 6, @raylib.Color::new(244, 250, 255, 255))
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if not(enemies[i].active) {
        continue
      }
      let ex = enemies[i].x + shake_x
      let ey = enemies[i].y
      if enemies[i].kind == 0 {
        @raylib.draw_circle(ex.to_int(), ey.to_int(), 11.0, @raylib.Color::new(244, 186, 94, 255))
      } else if enemies[i].kind == 1 {
        @raylib.draw_rectangle((ex - 14.0).to_int(), (ey - 11.0).to_int(), 28, 22, @raylib.Color::new(246, 128, 94, 255))
        @raylib.draw_circle((ex - 15.0).to_int(), ey.to_int(), 6.0, @raylib.Color::new(70, 48, 34, 255))
        @raylib.draw_circle((ex + 15.0).to_int(), ey.to_int(), 6.0, @raylib.Color::new(70, 48, 34, 255))
      } else {
        @raylib.draw_rectangle((ex - 20.0).to_int(), (ey - 15.0).to_int(), 40, 30, @raylib.Color::new(238, 88, 104, 255))
        @raylib.draw_rectangle((ex - 8.0).to_int(), (ey - 22.0).to_int(), 16, 8, @raylib.Color::new(252, 176, 130, 255))
      }
    }

    for i = 0; i < parts.length(); i = i + 1 {
      if not(parts[i].active) {
        continue
      }
      let a = (parts[i].ttl * 255.0).to_int()
      if a <= 0 {
        continue
      }
      let c = if parts[i].kind == 0 {
        @raylib.Color::new(122, 236, 248, a)
      } else if parts[i].kind == 1 {
        @raylib.Color::new(250, 220, 138, a)
      } else {
        @raylib.Color::new(248, 124, 124, a)
      }
      @raylib.draw_circle((parts[i].x + shake_x).to_int(), parts[i].y.to_int(), 2.2, c)
    }

    @raylib.draw_rectangle(0, 0, sw, 98, @raylib.Color::new(8, 12, 20, 230))
    @raylib.draw_text("CYBER FIREWALL BREACH 2026", 16, 20, 34, @raylib.Color::new(236, 244, 252, 255))
    @raylib.draw_text("Sector \{sector}/3", 480, 30, 30, @raylib.Color::new(246, 230, 136, 255))
    @raylib.draw_text("Score \{score}", 684, 30, 30, @raylib.Color::new(214, 236, 252, 255))

    @raylib.draw_rectangle(860, 28, 320, 18, @raylib.Color::new(28, 44, 68, 255))
    @raylib.draw_rectangle(860, 28, core_hp * 320 / 280, 18, @raylib.Color::new(92, 230, 140, 255))
    @raylib.draw_text("Core HP \{core_hp}", 975, 52, 22, @raylib.Color::new(224, 238, 250, 255))

    @raylib.draw_rectangle(20, 74, 300, 12, @raylib.Color::new(26, 38, 58, 255))
    @raylib.draw_rectangle(20, 74, (sector_timer / 42.0 * 300.0).to_int(), 12, @raylib.Color::new(112, 198, 252, 255))
    @raylib.draw_text("Sector timer", 326, 66, 20, @raylib.Color::new(198, 224, 246, 255))

    @raylib.draw_rectangle(20, 96, 220, 10, @raylib.Color::new(34, 22, 22, 255))
    @raylib.draw_rectangle(20, 96, (heat / 100.0 * 220.0).to_int(), 10, @raylib.Color::new(244, 112, 88, 255))
    @raylib.draw_text("Heat \{heat.to_int()}", 246, 90, 18, @raylib.Color::new(246, 206, 186, 255))

    let ctl_x = 22
    let ctl_y = sh - 174
    @raylib.draw_rectangle(10, sh - 188, 174, 178, @raylib.Color::new(10, 16, 28, 220))
    @raylib.draw_text("Touch", 64, sh - 184, 20, @raylib.white)

    @raylib.draw_rectangle(ctl_x, ctl_y, 76, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("UP", ctl_x + 22, ctl_y + 16, 22, @raylib.white)
    @raylib.draw_rectangle(ctl_x, ctl_y + 62, 76, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("DOWN", ctl_x + 8, ctl_y + 78, 22, @raylib.white)

    let pulse_x = sw - 208
    let pulse_y = sh - 290
    @raylib.draw_rectangle(pulse_x, pulse_y, 176, 94, @raylib.Color::new(70, 102, 182, 255))
    @raylib.draw_text("PULSE", pulse_x + 42, pulse_y + 30, 34, @raylib.white)
    if pulse_cd > 0.0 {
      @raylib.draw_text("CD \{pulse_cd.to_int() + 1}", pulse_x + 58, pulse_y - 24, 24, @raylib.Color::new(250, 220, 150, 255))
    }

    let fire_x = sw - 208
    let fire_y = sh - 154
    @raylib.draw_rectangle(fire_x, fire_y, 176, 120, @raylib.Color::new(188, 82, 76, 255))
    @raylib.draw_text("FIRE", fire_x + 56, fire_y + 42, 36, @raylib.white)

    @raylib.draw_rectangle(188, sh - 52, sw - 402, 36, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text(msg, 198, sh - 46, 22, @raylib.Color::new(224, 236, 246, 255))

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 124))
      @raylib.draw_rectangle(sw / 2 - 350, sh / 2 - 106, 700, 212, @raylib.Color::new(16, 24, 40, 244))
      @raylib.draw_text(
        if won { "BREACH STOPPED" } else { "SYSTEM DOWN" },
        sw / 2 - 220,
        sh / 2 - 40,
        58,
        if won { @raylib.Color::new(248, 236, 142, 255) } else { @raylib.Color::new(250, 128, 128, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 40, 32, @raylib.Color::new(226, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
