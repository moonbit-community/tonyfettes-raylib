///|
let sw : Int = 1100

///|
let sh : Int = 720

///|
let river_half_width : Float = 180.0

///|
struct Bullet {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vy : Float
}

///|
struct Enemy {
  mut alive : Bool
  mut kind : Int // 0 drone, 1 gunboat, 2 fuel crate
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
}

///|
fn river_center_at(y : Int, center : Float, curve : Float) -> Float {
  let yf = Float::from_int(y)
  center + curve * (yf / Float::from_int(sh) - 0.5)
}

///|
fn left_bank(y : Int, center : Float, curve : Float) -> Float {
  river_center_at(y, center, curve) - river_half_width
}

///|
fn right_bank(y : Int, center : Float, curve : Float) -> Float {
  river_center_at(y, center, curve) + river_half_width
}

///|
fn spawn_bullet(bullets : Array[Bullet], x : Float, y : Float) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    if not(bullets[i].alive) {
      bullets[i].alive = true
      bullets[i].x = x
      bullets[i].y = y
      bullets[i].vy = -620.0
      break
    }
  }
}

///|
fn spawn_enemy(enemies : Array[Enemy], kind : Int, x : Float, y : Float) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    if not(enemies[i].alive) {
      enemies[i].alive = true
      enemies[i].kind = kind
      enemies[i].x = x
      enemies[i].y = y
      enemies[i].vx = if kind == 0 {
        Float::from_int(@raylib.get_random_value(-40, 40))
      } else {
        0.0
      }
      enemies[i].vy = if kind == 0 {
        90.0
      } else if kind == 1 {
        70.0
      } else {
        40.0
      }
      enemies[i].hp = if kind == 1 { 2 } else { 1 }
      break
    }
  }
}

///|
fn reset_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].alive = false
  }
}

///|
fn reset_enemies(enemies : Array[Enemy]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].alive = false
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "River Raid 2026")
  @raylib.set_target_fps(60)

  let bullets : Array[Bullet] = Array::makei(140, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vy: -620.0 }
  })
  let enemies : Array[Enemy] = Array::makei(140, fn(_i) {
    { alive: false, kind: 0, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, hp: 1 }
  })

  let mut player_x : Float = Float::from_int(sw / 2)
  let mut player_y : Float = Float::from_int(sh - 96)
  let mut hp = 100
  let mut fuel : Float = 100.0
  let mut score = 0
  let mut distance = 0

  let mut river_center : Float = Float::from_int(sw / 2)
  let mut river_curve : Float = 0.0
  let mut river_turn_tick : Float = 0.0

  let mut spawn_tick : Float = 0.0
  let mut fire_cd : Float = 0.0
  let mut bank_hit_cd : Float = 0.0

  let mut over = false
  let mut msg = "Arrows/WASD fly, Space/J shoot, collect fuel crates"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_x = Float::from_int(sw / 2)
      player_y = Float::from_int(sh - 96)
      hp = 100
      fuel = 100.0
      score = 0
      distance = 0
      river_center = Float::from_int(sw / 2)
      river_curve = 0.0
      river_turn_tick = 0.0
      spawn_tick = 0.0
      fire_cd = 0.0
      bank_hit_cd = 0.0
      reset_bullets(bullets)
      reset_enemies(enemies)
      over = false
      msg = "Mission restarted. Fly low and survive."
    }

    if not(over) {
      let mut move_x : Float = 0.0
      let mut move_y : Float = 0.0
      if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
        move_x = move_x - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
        move_x = move_x + 1.0
      }
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        move_y = move_y - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
        move_y = move_y + 1.0
      }
      player_x = player_x + move_x * 280.0 * dt
      player_y = player_y + move_y * 230.0 * dt

      if player_y < 420.0 {
        player_y = 420.0
      }
      if player_y > Float::from_int(sh - 44) {
        player_y = Float::from_int(sh - 44)
      }

      river_turn_tick = river_turn_tick + dt
      if river_turn_tick >= 1.15 {
        river_turn_tick = river_turn_tick - 1.15
        river_center = river_center + Float::from_int(@raylib.get_random_value(-60, 60))
        if river_center < 250.0 {
          river_center = 250.0
        }
        if river_center > Float::from_int(sw) - 250.0 {
          river_center = Float::from_int(sw) - 250.0
        }
        river_curve = river_curve + Float::from_int(@raylib.get_random_value(-40, 40))
        if river_curve < -130.0 {
          river_curve = -130.0
        }
        if river_curve > 130.0 {
          river_curve = 130.0
        }
      }

      let lbank = left_bank(player_y.to_int(), river_center, river_curve)
      let rbank = right_bank(player_y.to_int(), river_center, river_curve)
      if player_x < lbank + 16.0 {
        player_x = lbank + 16.0
        if bank_hit_cd <= 0.0 {
          hp = hp - 8
          bank_hit_cd = 0.35
          msg = "Hit river bank!"
        }
      }
      if player_x > rbank - 16.0 {
        player_x = rbank - 16.0
        if bank_hit_cd <= 0.0 {
          hp = hp - 8
          bank_hit_cd = 0.35
          msg = "Hit river bank!"
        }
      }

      let scroll_speed : Float = 160.0 + Float::from_int(distance / 600) * 8.0
      distance = distance + (scroll_speed * dt).to_int()
      fuel = fuel - dt * 7.5

      fire_cd = fire_cd - dt
      bank_hit_cd = bank_hit_cd - dt

      if (@raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyJ)) && fire_cd <= 0.0 {
        spawn_bullet(bullets, player_x, player_y - 18.0)
        fire_cd = 0.11
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.45 {
        spawn_tick = spawn_tick - 0.45
        let top_center = river_center_at(0, river_center, river_curve)
        let spawn_x = top_center + Float::from_int(@raylib.get_random_value(-150, 150))
        let roll = @raylib.get_random_value(0, 99)
        if roll < 58 {
          spawn_enemy(enemies, 0, spawn_x, -28.0)
        } else if roll < 86 {
          spawn_enemy(enemies, 1, spawn_x, -28.0)
        } else {
          spawn_enemy(enemies, 2, spawn_x, -28.0)
        }
      }

      for i = 0; i < bullets.length(); i = i + 1 {
        if not(bullets[i].alive) {
          continue
        }
        bullets[i].y = bullets[i].y + bullets[i].vy * dt
        if bullets[i].y < -30.0 {
          bullets[i].alive = false
        }
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].alive) {
          continue
        }

        if enemies[i].kind == 0 {
          enemies[i].x = enemies[i].x + enemies[i].vx * dt
          if enemies[i].x < left_bank(enemies[i].y.to_int(), river_center, river_curve) + 20.0 {
            enemies[i].vx = enemies[i].vx.abs()
          }
          if enemies[i].x > right_bank(enemies[i].y.to_int(), river_center, river_curve) - 20.0 {
            enemies[i].vx = -enemies[i].vx.abs()
          }
        } else if enemies[i].kind == 1 {
          let chase = player_x - enemies[i].x
          if chase > 6.0 {
            enemies[i].x = enemies[i].x + 58.0 * dt
          } else if chase < -6.0 {
            enemies[i].x = enemies[i].x - 58.0 * dt
          }
        }

        enemies[i].y = enemies[i].y + enemies[i].vy * dt + scroll_speed * dt

        if enemies[i].y > Float::from_int(sh + 40) {
          enemies[i].alive = false
          continue
        }

        let el = left_bank(enemies[i].y.to_int(), river_center, river_curve)
        let er = right_bank(enemies[i].y.to_int(), river_center, river_curve)
        if enemies[i].x < el + 18.0 {
          enemies[i].x = el + 18.0
        }
        if enemies[i].x > er - 18.0 {
          enemies[i].x = er - 18.0
        }
      }

      for bi = 0; bi < bullets.length(); bi = bi + 1 {
        if not(bullets[bi].alive) {
          continue
        }
        for ei = 0; ei < enemies.length(); ei = ei + 1 {
          if not(enemies[ei].alive) {
            continue
          }
          let dx = enemies[ei].x - bullets[bi].x
          let dy = enemies[ei].y - bullets[bi].y
          if dx * dx + dy * dy <= 18.0 * 18.0 {
            bullets[bi].alive = false
            enemies[ei].hp = enemies[ei].hp - 1
            if enemies[ei].hp <= 0 {
              enemies[ei].alive = false
              if enemies[ei].kind == 0 {
                score = score + 30
              } else if enemies[ei].kind == 1 {
                score = score + 55
              } else {
                fuel = fuel + 10.0
                if fuel > 100.0 {
                  fuel = 100.0
                }
                score = score + 20
              }
            }
            break
          }
        }
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].alive) {
          continue
        }
        let dx = enemies[i].x - player_x
        let dy = enemies[i].y - player_y
        if dx * dx + dy * dy <= 26.0 * 26.0 {
          enemies[i].alive = false
          if enemies[i].kind == 2 {
            fuel = fuel + 24.0
            if fuel > 100.0 {
              fuel = 100.0
            }
            score = score + 35
            msg = "Fuel secured. Keep pushing upriver."
          } else {
            hp = hp - 16
            msg = "Enemy collision!"
          }
        }
      }

      if fuel <= 0.0 {
        over = true
        msg = "Out of fuel. Mission failed."
      }
      if hp <= 0 {
        over = true
        msg = "Aircraft destroyed. Mission failed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(26, 33, 19, 255))

    for y = 0; y < sh; y = y + 4 {
      let l = left_bank(y, river_center, river_curve)
      let r = right_bank(y, river_center, river_curve)
      @raylib.draw_rectangle(l.to_int(), y, (r - l).to_int(), 4, @raylib.Color::new(40, 120, 180, 255))
      @raylib.draw_line(l.to_int(), y, l.to_int(), y + 3, @raylib.darkbrown)
      @raylib.draw_line(r.to_int(), y, r.to_int(), y + 3, @raylib.darkbrown)
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].alive {
        if enemies[i].kind == 0 {
          @raylib.draw_triangle(
            @raylib.Vector2::new(enemies[i].x, enemies[i].y - 12.0),
            @raylib.Vector2::new(enemies[i].x - 11.0, enemies[i].y + 10.0),
            @raylib.Vector2::new(enemies[i].x + 11.0, enemies[i].y + 10.0),
            @raylib.red,
          )
        } else if enemies[i].kind == 1 {
          @raylib.draw_rectangle(
            (enemies[i].x - 14.0).to_int(),
            (enemies[i].y - 10.0).to_int(),
            28,
            20,
            @raylib.maroon,
          )
          @raylib.draw_rectangle(
            (enemies[i].x - 5.0).to_int(),
            (enemies[i].y - 16.0).to_int(),
            10,
            8,
            @raylib.gray,
          )
        } else {
          @raylib.draw_rectangle(
            (enemies[i].x - 11.0).to_int(),
            (enemies[i].y - 11.0).to_int(),
            22,
            22,
            @raylib.gold,
          )
          @raylib.draw_text("F", (enemies[i].x - 6.0).to_int(), (enemies[i].y - 8.0).to_int(), 18, @raylib.black)
        }
      }
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if bullets[i].alive {
        @raylib.draw_rectangle(
          (bullets[i].x - 2.0).to_int(),
          (bullets[i].y - 8.0).to_int(),
          4,
          10,
          @raylib.yellow,
        )
      }
    }

    @raylib.draw_triangle(
      @raylib.Vector2::new(player_x, player_y - 16.0),
      @raylib.Vector2::new(player_x - 14.0, player_y + 12.0),
      @raylib.Vector2::new(player_x + 14.0, player_y + 12.0),
      @raylib.skyblue,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(player_x, player_y - 16.0),
      @raylib.Vector2::new(player_x - 14.0, player_y + 12.0),
      @raylib.Vector2::new(player_x + 14.0, player_y + 12.0),
      @raylib.white,
    )

    @raylib.draw_text("RIVER RAID 2026", 20, 16, 38, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 62, 28, @raylib.white)
    @raylib.draw_text("Distance \{distance}m", 240, 62, 28, @raylib.white)

    @raylib.draw_text("HP", 20, 104, 22, @raylib.red)
    @raylib.draw_rectangle(62, 108, 220, 16, @raylib.Color::new(60, 20, 20, 255))
    @raylib.draw_rectangle(62, 108, hp * 220 / 100, 16, @raylib.red)

    @raylib.draw_text("Fuel", 20, 132, 22, @raylib.gold)
    @raylib.draw_rectangle(62, 136, 220, 16, @raylib.Color::new(45, 45, 20, 255))
    @raylib.draw_rectangle(62, 136, (fuel * 2.2).to_int(), 16, @raylib.gold)

    @raylib.draw_rectangle(20, 666, 1060, 36, @raylib.Color::new(15, 19, 22, 220))
    @raylib.draw_text(msg, 30, 674, 22, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 500, 160, @raylib.fade(@raylib.black, 0.8))
      @raylib.draw_text("MISSION FAILED", 410, 290, 42, @raylib.orange)
      @raylib.draw_text("Press R to relaunch", 430, 345, 30, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
