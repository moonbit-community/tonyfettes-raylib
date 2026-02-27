///|
let sw : Int = 1120

///|
let sh : Int = 740

///|
struct Shot {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut from_enemy : Bool
}

///|
struct Bot {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut hp : Int
  mut fire_cd : Float
  mut dir_x : Float
  mut dir_y : Float
}

///|
fn spawn_shot(
  shots : Array[Shot],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  from_enemy : Bool,
) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    if not(shots[i].alive) {
      shots[i].alive = true
      shots[i].x = x
      shots[i].y = y
      shots[i].vx = vx
      shots[i].vy = vy
      shots[i].from_enemy = from_enemy
      break
    }
  }
}

///|
fn spawn_bot(bots : Array[Bot], wave : Int) -> Unit {
  for i = 0; i < bots.length(); i = i + 1 {
    if not(bots[i].alive) {
      bots[i].alive = true
      bots[i].x = Float::from_int(@raylib.get_random_value(200, sw - 100))
      bots[i].y = Float::from_int(@raylib.get_random_value(140, sh - 120))
      bots[i].hp = 20 + wave * 2
      bots[i].fire_cd = Float::from_int(@raylib.get_random_value(1, 2))
      bots[i].dir_x = Float::from_int(@raylib.get_random_value(-100, 100)) /
        100.0
      bots[i].dir_y = Float::from_int(@raylib.get_random_value(-100, 100)) /
        100.0
      break
    }
  }
}

///|
fn reset_bots(bots : Array[Bot]) -> Unit {
  for i = 0; i < bots.length(); i = i + 1 {
    bots[i].alive = false
  }
}

///|
fn reset_shots(shots : Array[Shot]) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    shots[i].alive = false
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Mech Arena Duel 2026")
  @raylib.set_target_fps(60)

  let shots : Array[Shot] = Array::makei(260, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, from_enemy: false }
  })

  let bots : Array[Bot] = Array::makei(64, fn(_i) {
    {
      alive: false,
      x: 0.0,
      y: 0.0,
      hp: 20,
      fire_cd: 1.5,
      dir_x: 1.0,
      dir_y: 0.0,
    }
  })

  let mut px : Float = Float::from_int(sw / 2)
  let mut py : Float = Float::from_int(sh / 2)
  let mut php = 120

  let mut fire_cd : Float = 0.0
  let mut dash_cd : Float = 0.0
  let mut overheat : Float = 0.0

  let mut wave = 1
  let mut score = 0
  let mut kills = 0
  let mut wave_bonus = 0

  let mut over = false
  let mut msg = "WASD move, mouse aim, LMB/J shoot, K dash"

  for _i = 0; _i < 4; _i = _i + 1 {
    spawn_bot(bots, wave)
  }

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      px = Float::from_int(sw / 2)
      py = Float::from_int(sh / 2)
      php = 120
      fire_cd = 0.0
      dash_cd = 0.0
      overheat = 0.0
      wave = 1
      score = 0
      kills = 0
      wave_bonus = 0
      over = false
      msg = "Arena reset."
      reset_shots(shots)
      reset_bots(bots)
      for _i = 0; _i < 4; _i = _i + 1 {
        spawn_bot(bots, wave)
      }
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

      let speed : Float = (230.0 : Float)
      px = px + mx * speed * dt
      py = py + my * speed * dt

      if px < 60.0 {
        px = 60.0
      }
      if px > Float::from_int(sw - 60) {
        px = Float::from_int(sw - 60)
      }
      if py < 120.0 {
        py = 120.0
      }
      if py > Float::from_int(sh - 60) {
        py = Float::from_int(sh - 60)
      }

      fire_cd = fire_cd - dt
      dash_cd = dash_cd - dt
      overheat = overheat - dt * 14.0
      if overheat < 0.0 {
        overheat = 0.0
      }

      if @raylib.is_key_pressed(@raylib.KeyK) && dash_cd <= 0.0 {
        px = px + mx * 140.0
        py = py + my * 140.0
        dash_cd = 3.0
      }

      let can_shoot = overheat < 98.0
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
        @raylib.is_key_down(@raylib.KeyJ) {
        if fire_cd <= 0.0 && can_shoot {
          let mpos = @raylib.get_mouse_position()
          let mut dx = mpos.x - px
          let mut dy = mpos.y - py
          let d = (dx * dx + dy * dy).sqrt()
          if d > 0.001 {
            dx = dx / d
            dy = dy / d
            spawn_shot(shots, px, py, dx * 540.0, dy * 540.0, false)
            fire_cd = 0.14
            overheat = overheat + 8.0
          }
        }
      }
      if overheat >= 100.0 {
        msg = "Weapon overheated."
      }

      // AI update
      let mut alive_count = 0
      for i = 0; i < bots.length(); i = i + 1 {
        if not(bots[i].alive) {
          continue
        }
        alive_count = alive_count + 1

        bots[i].x = bots[i].x + bots[i].dir_x * 120.0 * dt
        bots[i].y = bots[i].y + bots[i].dir_y * 120.0 * dt

        if bots[i].x < 120.0 || bots[i].x > Float::from_int(sw - 80) {
          bots[i].dir_x = -bots[i].dir_x
        }
        if bots[i].y < 130.0 || bots[i].y > Float::from_int(sh - 80) {
          bots[i].dir_y = -bots[i].dir_y
        }

        bots[i].fire_cd = bots[i].fire_cd - dt
        if bots[i].fire_cd <= 0.0 {
          bots[i].fire_cd = Float::from_int(@raylib.get_random_value(1, 3))
          let mut dx = px - bots[i].x
          let mut dy = py - bots[i].y
          let d = (dx * dx + dy * dy).sqrt()
          if d > 0.001 {
            dx = dx / d
            dy = dy / d
            spawn_shot(
              shots,
              bots[i].x,
              bots[i].y,
              dx * 340.0,
              dy * 340.0,
              true,
            )
          }
        }

        if (bots[i].x - px).abs() < 30.0 && (bots[i].y - py).abs() < 30.0 {
          php = php - 8
          bots[i].alive = false
          msg = "Bot collision."
        }
      }

      if alive_count == 0 {
        wave_bonus = 70 + wave * 10
        score = score + wave_bonus
        wave = wave + 1
        let spawn_n = 3 + wave
        for _i = 0; _i < spawn_n; _i = _i + 1 {
          spawn_bot(bots, wave)
        }
        msg = "Wave \{wave} begins."
      }

      // Shot update + collision
      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].alive) {
          continue
        }
        shots[i].x = shots[i].x + shots[i].vx * dt
        shots[i].y = shots[i].y + shots[i].vy * dt

        if shots[i].x < 0.0 ||
          shots[i].x > Float::from_int(sw) ||
          shots[i].y < 90.0 ||
          shots[i].y > Float::from_int(sh) {
          shots[i].alive = false
          continue
        }

        if shots[i].from_enemy {
          if (shots[i].x - px).abs() < 16.0 && (shots[i].y - py).abs() < 16.0 {
            shots[i].alive = false
            php = php - 9
            msg = "Mech hit by enemy fire."
          }
        } else {
          for bi = 0; bi < bots.length(); bi = bi + 1 {
            if not(bots[bi].alive) {
              continue
            }
            if (shots[i].x - bots[bi].x).abs() < 18.0 &&
              (shots[i].y - bots[bi].y).abs() < 18.0 {
              shots[i].alive = false
              bots[bi].hp = bots[bi].hp - 12
              if bots[bi].hp <= 0 {
                bots[bi].alive = false
                kills = kills + 1
                score = score + 26 + wave
                msg = "Bot destroyed."
              }
              break
            }
          }
        }
      }

      if php <= 0 {
        php = 0
        over = true
        msg = "Mech disabled."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 20, 24, 255))

    // arena floor
    for y = 120; y < sh; y = y + 40 {
      @raylib.draw_line(60, y, sw - 60, y, @raylib.fade(@raylib.gray, 0.2))
    }
    for x = 80; x < sw; x = x + 40 {
      @raylib.draw_line(x, 120, x, sh - 20, @raylib.fade(@raylib.gray, 0.14))
    }

    for i = 0; i < bots.length(); i = i + 1 {
      if bots[i].alive {
        @raylib.draw_rectangle(
          (bots[i].x - 18.0).to_int(),
          (bots[i].y - 18.0).to_int(),
          36,
          36,
          @raylib.maroon,
        )
        @raylib.draw_rectangle_lines(
          (bots[i].x - 18.0).to_int(),
          (bots[i].y - 18.0).to_int(),
          36,
          36,
          @raylib.white,
        )
        @raylib.draw_text(
          "\{bots[i].hp}",
          (bots[i].x - 10.0).to_int(),
          (bots[i].y - 30.0).to_int(),
          16,
          @raylib.raywhite,
        )
      }
    }

    for i = 0; i < shots.length(); i = i + 1 {
      if shots[i].alive {
        let c = if shots[i].from_enemy {
          @raylib.orange
        } else {
          @raylib.skyblue
        }
        @raylib.draw_circle(shots[i].x.to_int(), shots[i].y.to_int(), 4.0, c)
      }
    }

    @raylib.draw_rectangle(
      (px - 20.0).to_int(),
      (py - 20.0).to_int(),
      40,
      40,
      @raylib.blue,
    )
    @raylib.draw_rectangle_lines(
      (px - 20.0).to_int(),
      (py - 20.0).to_int(),
      40,
      40,
      @raylib.white,
    )

    @raylib.draw_text("MECH ARENA DUEL 2026", 20, 18, 40, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 64, 30, @raylib.white)
    @raylib.draw_text("Kills \{kills}", 220, 64, 30, @raylib.lime)
    @raylib.draw_text("Wave \{wave}", 390, 64, 30, @raylib.orange)

    @raylib.draw_text("HP", 590, 66, 24, @raylib.red)
    @raylib.draw_rectangle(
      640,
      72,
      230,
      14,
      @raylib.Color::new(45, 20, 20, 255),
    )
    @raylib.draw_rectangle(640, 72, php * 230 / 120, 14, @raylib.red)

    @raylib.draw_text("Heat", 900, 66, 24, @raylib.orange)
    @raylib.draw_rectangle(
      950,
      72,
      150,
      14,
      @raylib.Color::new(45, 26, 16, 255),
    )
    @raylib.draw_rectangle(
      950,
      72,
      (overheat * 1.5).to_int(),
      14,
      @raylib.orange,
    )

    if wave_bonus > 0 {
      @raylib.draw_text("Wave bonus +\{wave_bonus}", 820, 106, 24, @raylib.lime)
    }

    @raylib.draw_rectangle(
      20,
      694,
      sw - 40,
      30,
      @raylib.Color::new(10, 12, 16, 220),
    )
    @raylib.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("MECH DOWN", 450, 320, 56, @raylib.red)
      @raylib.draw_text("Press R to restart", 450, 386, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
