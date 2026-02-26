///|
let sw : Int = 1000

///|
let sh : Int = 700

///|
struct Enemy {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut hp : Int
  mut speed : Float
}

///|
struct Shot {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Int
  mut ttl : Float
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
fn spawn_enemy(enemies : Array[Enemy], t : Float) -> Unit {
  let edge = @raylib.get_random_value(0, 3)
  let mut x : Float = 0.0
  let mut y : Float = 0.0
  match edge {
    0 => {
      x = 4.0
      y = Float::from_int(@raylib.get_random_value(0, sh - 1))
    }
    1 => {
      x = Float::from_int(sw - 4)
      y = Float::from_int(@raylib.get_random_value(0, sh - 1))
    }
    2 => {
      x = Float::from_int(@raylib.get_random_value(0, sw - 1))
      y = 4.0
    }
    _ => {
      x = Float::from_int(@raylib.get_random_value(0, sw - 1))
      y = Float::from_int(sh - 4)
    }
  }

  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].alive) {
      enemies[i].alive = true
      enemies[i].x = x
      enemies[i].y = y
      enemies[i].hp = 8 + @raylib.get_random_value(0, 8)
      enemies[i].speed = 52.0 + t * 1.5 + Float::from_int(@raylib.get_random_value(0, 12))
      return
    }
  }
}

///|
fn fire_shot(
  shots : Array[Shot],
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  speed : Float,
  dmg : Int,
) -> Unit {
  let dx = tx - x
  let dy = ty - y
  let dist2 = dx * dx + dy * dy
  if dist2 <= 0.0001 {
    return
  }
  let d = dist2.sqrt()
  let vx = dx / d * speed
  let vy = dy / d * speed
  for i = 0; i < shots.length(); i = i + 1 {
    if not(shots[i].active) {
      shots[i].active = true
      shots[i].x = x
      shots[i].y = y
      shots[i].vx = vx
      shots[i].vy = vy
      shots[i].dmg = dmg
      shots[i].ttl = 1.2
      return
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Topdown Survivor 2026")
  @raylib.set_target_fps(60)

  let enemies : Array[Enemy] = Array::makei(260, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, hp: 0, speed: 0.0 }
  })
  let shots : Array[Shot] = Array::makei(220, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0,
      ttl: 0.0,
    }
  })

  let mut px : Float = Float::from_int(sw) * 0.5
  let mut py : Float = Float::from_int(sh) * 0.5
  let mut hp = 100
  let mut max_hp = 100
  let mut move_speed : Float = 210.0
  let mut fire_cd : Float = 0.50
  let mut fire_timer : Float = 0.0
  let mut bullet_speed : Float = 430.0
  let mut bullet_dmg = 7

  let mut survive_time : Float = 0.0
  let mut spawn_timer : Float = 0.3
  let mut spawn_rate : Float = 1.1

  let mut xp = 0
  let mut level = 1
  let mut xp_need = 12
  let mut selecting = false
  let mut msg = "Move with WASD/Arrows. Auto fire enabled."
  let mut game_over = false
  let mut won = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      for i = 0; i < enemies.length(); i = i + 1 {
        enemies[i].alive = false
      }
      for i = 0; i < shots.length(); i = i + 1 {
        shots[i].active = false
      }
      px = Float::from_int(sw) * 0.5
      py = Float::from_int(sh) * 0.5
      hp = 100
      max_hp = 100
      move_speed = 210.0
      fire_cd = 0.50
      fire_timer = 0.0
      bullet_speed = 430.0
      bullet_dmg = 7
      survive_time = 0.0
      spawn_timer = 0.3
      spawn_rate = 1.1
      xp = 0
      level = 1
      xp_need = 12
      selecting = false
      msg = "Run restarted."
      game_over = false
      won = false
    }

    if not(game_over) && not(won) {
      if selecting {
        if @raylib.is_key_pressed(@raylib.KeyOne) {
          fire_cd = fire_cd * 0.84
          if fire_cd < 0.12 {
            fire_cd = 0.12
          }
          selecting = false
          msg = "Upgrade: Faster attack speed"
        }
        if @raylib.is_key_pressed(@raylib.KeyTwo) {
          bullet_dmg = bullet_dmg + 3
          selecting = false
          msg = "Upgrade: Stronger bullets"
        }
        if @raylib.is_key_pressed(@raylib.KeyThree) {
          move_speed = move_speed + 26.0
          max_hp = max_hp + 10
          hp = hp + 10
          if hp > max_hp {
            hp = max_hp
          }
          selecting = false
          msg = "Upgrade: Mobility + vitality"
        }
      } else {
        survive_time = survive_time + dt

        let mut mx : Float = 0.0
        let mut my : Float = 0.0
        if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
          mx = mx - 1.0
        }
        if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
          mx = mx + 1.0
        }
        if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
          my = my - 1.0
        }
        if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
          my = my + 1.0
        }

        let len2 = mx * mx + my * my
        if len2 > 0.01 {
          let len = len2.sqrt()
          px = px + mx / len * move_speed * dt
          py = py + my / len * move_speed * dt
        }
        px = clampf(px, 12.0, Float::from_int(sw - 12))
        py = clampf(py, 12.0, Float::from_int(sh - 12))

        spawn_timer = spawn_timer - dt
        if spawn_timer <= 0.0 {
          spawn_enemy(enemies, survive_time)
          spawn_rate = spawn_rate - 0.0025
          if spawn_rate < 0.28 {
            spawn_rate = 0.28
          }
          spawn_timer = spawn_rate
        }

        // Auto fire nearest enemy.
        fire_timer = fire_timer - dt
        if fire_timer <= 0.0 {
          let mut best = -1
          let mut best_d2 : Float = 1_000_000_000_000.0
          for i = 0; i < enemies.length(); i = i + 1 {
            if not(enemies[i].alive) {
              continue
            }
            let dx = enemies[i].x - px
            let dy = enemies[i].y - py
            let d2 = dx * dx + dy * dy
            if d2 < best_d2 {
              best_d2 = d2
              best = i
            }
          }
          if best >= 0 {
            fire_timer = fire_cd
            fire_shot(shots, px, py, enemies[best].x, enemies[best].y, bullet_speed, bullet_dmg)
          }
        }

        for i = 0; i < shots.length(); i = i + 1 {
          if not(shots[i].active) {
            continue
          }
          shots[i].x = shots[i].x + shots[i].vx * dt
          shots[i].y = shots[i].y + shots[i].vy * dt
          shots[i].ttl = shots[i].ttl - dt
          if shots[i].ttl <= 0.0 || shots[i].x < 0.0 || shots[i].x > Float::from_int(sw) ||
            shots[i].y < 0.0 || shots[i].y > Float::from_int(sh) {
            shots[i].active = false
            continue
          }

          for e = 0; e < enemies.length(); e = e + 1 {
            if not(enemies[e].alive) {
              continue
            }
            let dx = shots[i].x - enemies[e].x
            let dy = shots[i].y - enemies[e].y
            if dx * dx + dy * dy <= 14.0 * 14.0 {
              enemies[e].hp = enemies[e].hp - shots[i].dmg
              shots[i].active = false
              if enemies[e].hp <= 0 {
                enemies[e].alive = false
                xp = xp + 1
              }
              break
            }
          }
        }

        for i = 0; i < enemies.length(); i = i + 1 {
          if not(enemies[i].alive) {
            continue
          }
          let dx = px - enemies[i].x
          let dy = py - enemies[i].y
          let d2 = dx * dx + dy * dy
          if d2 > 0.1 {
            let d = d2.sqrt()
            enemies[i].x = enemies[i].x + dx / d * enemies[i].speed * dt
            enemies[i].y = enemies[i].y + dy / d * enemies[i].speed * dt
          }
          if d2 <= 20.0 * 20.0 {
            hp = hp - 1
          }
        }

        if xp >= xp_need {
          xp = xp - xp_need
          level = level + 1
          xp_need = xp_need + 7
          selecting = true
          msg = "Level up! 1:Faster fire  2:More damage  3:Speed+HP"
        }

        if hp <= 0 {
          game_over = true
          msg = "You were overwhelmed."
        }
        if survive_time >= 180.0 {
          won = true
          msg = "You survived 3 minutes."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 24, 18, 255))

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].alive {
        @raylib.draw_circle(enemies[i].x.to_int(), enemies[i].y.to_int(), 10.0, @raylib.red)
      }
    }

    for i = 0; i < shots.length(); i = i + 1 {
      if shots[i].active {
        @raylib.draw_circle(shots[i].x.to_int(), shots[i].y.to_int(), 3.0, @raylib.yellow)
      }
    }

    @raylib.draw_circle(px.to_int(), py.to_int(), 12.0, @raylib.skyblue)

    @raylib.draw_text("TOPDOWN SURVIVOR 2026", 20, 16, 34, @raylib.lime)
    @raylib.draw_text("HP \{hp}/\{max_hp}", 24, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Lvl \{level}", 220, 56, 24, @raylib.raywhite)
    @raylib.draw_text("XP \{xp}/\{xp_need}", 320, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Time \{survive_time.to_int()} / 180", 510, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Move: WASD/Arrows  R restart", 730, 24, 22, @raylib.gray)

    @raylib.draw_rectangle(24, 620, 950, 48, @raylib.Color::new(24, 30, 24, 255))
    @raylib.draw_text(msg, 34, 635, 22, @raylib.raywhite)

    if selecting {
      @raylib.draw_rectangle(240, 230, 530, 140, @raylib.fade(@raylib.black, 0.8))
      @raylib.draw_text("LEVEL UP", 430, 250, 42, @raylib.yellow)
      @raylib.draw_text("1 Faster fire  2 Damage  3 Speed+HP", 286, 308, 30, @raylib.raywhite)
    }

    if won || game_over {
      @raylib.draw_rectangle(300, 250, 400, 120, @raylib.fade(@raylib.black, 0.8))
      @raylib.draw_text(if won { "SURVIVED" } else { "DEFEAT" }, 400, 286, 46, if won { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 380, 334, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
