///|
let sw : Int = 1160

///|
let sh : Int = 740

///|
struct Torpedo {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
}

///|
struct Enemy {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Int
  mut shoot_cd : Float
  mut stealth : Bool
}

///|
fn spawn_torpedo(ts : Array[Torpedo], x : Float, y : Float, vx : Float) -> Unit {
  for ts_elem in ts {
    if not(ts_elem.alive) {
      ts_elem.alive = true
      ts_elem.x = x
      ts_elem.y = y
      ts_elem.vx = vx
      break
    }
  }
}

///|
fn spawn_enemy(es : Array[Enemy]) -> Unit {
  for es_elem in es {
    if not(es_elem.alive) {
      es_elem.alive = true
      es_elem.x = Float::from_int(sw + 80)
      es_elem.y = Float::from_int(@raylib.get_random_value(190, sh - 70))
      es_elem.vx = Float::from_int(@raylib.get_random_value(-150, -90))
      es_elem.hp = if @raylib.get_random_value(0, 99) < 25 { 2 } else { 1 }
      es_elem.shoot_cd = Float::from_int(@raylib.get_random_value(1, 3))
      es_elem.stealth = @raylib.get_random_value(0, 99) < 45
      break
    }
  }
}

///|
fn reset_torpedoes(ts : Array[Torpedo]) -> Unit {
  for ts_elem in ts {
    ts_elem.alive = false
  }
}

///|
fn reset_enemies(es : Array[Enemy]) -> Unit {
  for es_elem in es {
    es_elem.alive = false
  }
}

///|
fn dist_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn main {
  @raylib.init_window(sw, sh, "Submarine Hunter 2026")
  @raylib.set_target_fps(60)

  let player_t : Array[Torpedo] = Array::makei(90, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0 }
  })
  let enemy_t : Array[Torpedo] = Array::makei(120, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0 }
  })
  let enemies : Array[Enemy] = Array::makei(80, fn(_i) {
    {
      alive: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      hp: 1,
      shoot_cd: 0.0,
      stealth: false,
    }
  })

  let mut px : Float = 170.0
  let mut py : Float = Float::from_int(sh / 2)
  let mut hp = 100
  let mut score = 0
  let mut kills = 0

  let mut fire_cd : Float = 0.0
  let mut sonar_cd : Float = 0.0
  let mut sonar_active : Float = 0.0
  let mut spawn_tick : Float = 0.0

  let mut over = false
  let mut msg = "WASD/Arrows move, J/Space fire, K sonar ping"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      px = 170.0
      py = Float::from_int(sh / 2)
      hp = 100
      score = 0
      kills = 0
      fire_cd = 0.0
      sonar_cd = 0.0
      sonar_active = 0.0
      spawn_tick = 0.0
      over = false
      msg = "Mission restarted."
      reset_torpedoes(player_t)
      reset_torpedoes(enemy_t)
      reset_enemies(enemies)
    }

    if not(over) {
      let mut mx : Float = 0.0
      let mut my : Float = 0.0
      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        mx = mx - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        mx = mx + 1.0
      }
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        my = my - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        my = my + 1.0
      }

      px = px + mx * 220.0 * dt
      py = py + my * 180.0 * dt
      if px < 40.0 {
        px = 40.0
      }
      if px > Float::from_int(sw / 2) {
        px = Float::from_int(sw / 2)
      }
      if py < 150.0 {
        py = 150.0
      }
      if py > Float::from_int(sh - 40) {
        py = Float::from_int(sh - 40)
      }

      fire_cd = fire_cd - dt
      sonar_cd = sonar_cd - dt
      sonar_active = sonar_active - dt

      if (
          @raylib.is_key_down(@raylib.KeySpace) ||
          @raylib.is_key_down(@raylib.KeyJ)
        ) &&
        fire_cd <= 0.0 {
        spawn_torpedo(player_t, px + 20.0, py, 420.0)
        fire_cd = 0.18
      }

      if @raylib.is_key_pressed(@raylib.KeyK) && sonar_cd <= 0.0 {
        sonar_cd = 4.0
        sonar_active = 1.4
        msg = "Sonar ping active."
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.75 {
        spawn_tick = spawn_tick - 0.75
        spawn_enemy(enemies)
      }

      for enemy in enemies {
        if not(enemy.alive) {
          continue
        }

        enemy.x = enemy.x + enemy.vx * dt

        // Simple drifting depth movement
        let drift = Float::from_int(@raylib.get_random_value(-20, 20)) * dt
        enemy.y = enemy.y + drift
        if enemy.y < 150.0 {
          enemy.y = 150.0
        }
        if enemy.y > Float::from_int(sh - 40) {
          enemy.y = Float::from_int(sh - 40)
        }

        enemy.shoot_cd = enemy.shoot_cd - dt
        if enemy.shoot_cd <= 0.0 {
          enemy.shoot_cd = Float::from_int(@raylib.get_random_value(2, 4))
          spawn_torpedo(enemy_t, enemy.x - 18.0, enemy.y, -300.0)
        }

        if enemy.x < -60.0 {
          enemy.alive = false
          hp = hp - 6
          msg = "Enemy slipped past defense line."
        }
      }

      for player_t_elem in player_t {
        if not(player_t_elem.alive) {
          continue
        }
        player_t_elem.x = player_t_elem.x + player_t_elem.vx * dt
        if player_t_elem.x > Float::from_int(sw + 20) {
          player_t_elem.alive = false
        }
      }

      for enemy_t_elem in enemy_t {
        if not(enemy_t_elem.alive) {
          continue
        }
        enemy_t_elem.x = enemy_t_elem.x + enemy_t_elem.vx * dt
        if enemy_t_elem.x < -20.0 {
          enemy_t_elem.alive = false
        }

        if dist_sq(enemy_t_elem.x, enemy_t_elem.y, px, py) < 20.0 * 20.0 {
          enemy_t_elem.alive = false
          hp = hp - 11
          msg = "Direct hit by enemy torpedo."
        }
      }

      for player_t_elem in player_t {
        if not(player_t_elem.alive) {
          continue
        }
        for enemy in enemies {
          if not(enemy.alive) {
            continue
          }
          if dist_sq(
              player_t_elem.x,
              player_t_elem.y,
              enemy.x,
              enemy.y,
            ) <
            19.0 * 19.0 {
            player_t_elem.alive = false
            enemy.hp = enemy.hp - 1
            if enemy.hp <= 0 {
              enemy.alive = false
              kills = kills + 1
              let bonus = if enemy.stealth { 70 } else { 45 }
              score = score + bonus
              msg = "Enemy submarine destroyed."
            }
            break
          }
        }
      }

      if hp <= 0 {
        hp = 0
        over = true
        msg = "Fleet lost."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 28, 46, 255))

    // Surface and depth bands
    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(35, 72, 120, 255))
    @raylib.draw_rectangle(
      0,
      130,
      sw,
      sh - 130,
      @raylib.Color::new(8, 44, 76, 255),
    )

    for y = 170; y < sh; y = y + 90 {
      @raylib.draw_line(0, y, sw, y, @raylib.fade(@raylib.skyblue, 0.15))
    }

    if sonar_active > 0.0 {
      @raylib.draw_circle_lines(
        px.to_int(),
        py.to_int(),
        70.0 + sonar_active * 50.0,
        @raylib.lime,
      )
      @raylib.draw_circle_lines(
        px.to_int(),
        py.to_int(),
        130.0 + sonar_active * 40.0,
        @raylib.lime,
      )
    }

    for enemy in enemies {
      if enemy.alive {
        let visible = not(enemy.stealth) || sonar_active > 0.0
        let c = if visible {
          @raylib.red
        } else {
          @raylib.fade(@raylib.darkblue, 0.35)
        }
        @raylib.draw_ellipse(
          enemy.x.to_int(),
          enemy.y.to_int(),
          26.0,
          12.0,
          c,
        )
        @raylib.draw_circle(
          (enemy.x + 18.0).to_int(),
          enemy.y.to_int(),
          5.0,
          c,
        )
        if visible {
          @raylib.draw_rectangle(
            (enemy.x - 10.0).to_int(),
            (enemy.y - 20.0).to_int(),
            20,
            5,
            @raylib.maroon,
          )
        }
      }
    }

    for player_t_elem in player_t {
      if player_t_elem.alive {
        @raylib.draw_rectangle(
          (player_t_elem.x - 8.0).to_int(),
          (player_t_elem.y - 2.0).to_int(),
          14,
          4,
          @raylib.yellow,
        )
      }
    }
    for enemy_t_elem in enemy_t {
      if enemy_t_elem.alive {
        @raylib.draw_rectangle(
          (enemy_t_elem.x - 8.0).to_int(),
          (enemy_t_elem.y - 2.0).to_int(),
          14,
          4,
          @raylib.orange,
        )
      }
    }

    @raylib.draw_ellipse(px.to_int(), py.to_int(), 30.0, 14.0, @raylib.skyblue)
    @raylib.draw_circle((px + 20.0).to_int(), py.to_int(), 6.0, @raylib.blue)
    @raylib.draw_rectangle(
      (px - 10.0).to_int(),
      (py - 22.0).to_int(),
      20,
      6,
      @raylib.gray,
    )

    @raylib.draw_text("SUBMARINE HUNTER 2026", 20, 16, 40, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 64, 30, @raylib.white)
    @raylib.draw_text("Kills \{kills}", 220, 64, 30, @raylib.lime)

    @raylib.draw_text("Hull", 420, 66, 24, @raylib.red)
    @raylib.draw_rectangle(
      480,
      72,
      220,
      14,
      @raylib.Color::new(45, 18, 18, 255),
    )
    @raylib.draw_rectangle(480, 72, hp * 220 / 100, 14, @raylib.red)

    @raylib.draw_text("Sonar", 740, 66, 24, @raylib.lime)
    let sonar_val = if sonar_cd > 0.0 { sonar_cd.to_int() } else { 0 }
    @raylib.draw_text("CD \{sonar_val}s", 810, 66, 24, @raylib.raywhite)

    @raylib.draw_rectangle(
      20,
      694,
      sw - 40,
      30,
      @raylib.Color::new(8, 12, 18, 220),
    )
    @raylib.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        540,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("MISSION FAILED", 370, 308, 50, @raylib.red)
      @raylib.draw_text("Press R to relaunch", 420, 366, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
