///|
let lanes : Int = 5

///|
let slots : Int = 8

///|
let lane_h : Int = 100

///|
let grid_x : Int = 80

///|
let grid_y : Int = 90

///|
let cell_w : Int = 90

///|
let screen_w : Int = 980

///|
let screen_h : Int = 650

///|
struct Enemy {
  mut alive : Bool
  mut lane : Int
  mut x : Float
  mut hp : Float
  mut speed : Float
}

///|
struct Tower {
  mut built : Bool
  lane : Int
  slot : Int
  mut cooldown : Float
}

///|
fn tower_index(l : Int, s : Int) -> Int {
  l * slots + s
}

///|
fn enemy_color(hp_ratio : Float) -> @raylib.Color {
  if hp_ratio > 0.66 {
    @raylib.red
  } else if hp_ratio > 0.33 {
    @raylib.orange
  } else {
    @raylib.gold
  }
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Tower Defense Frontier 2026")
  @raylib.set_target_fps(60)

  let towers : Array[Tower] = Array::makei(lanes * slots, fn(i) {
    {
      built: false,
      lane: i / slots,
      slot: i % slots,
      cooldown: 0.0,
    }
  })

  let enemies : Array[Enemy] = Array::makei(240, fn(_i) {
    { alive: false, lane: 0, x: 0.0, hp: 0.0, speed: 0.0 }
  })

  let mut lives = 20
  let mut gold = 120
  let mut score = 0
  let mut wave = 1

  let mut wave_spawn_left = 8
  let mut wave_spawn_timer : Float = 1.0
  let mut between_wave_timer : Float = 2.0
  let mut paused_between_wave = false
  let mut game_over = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      for i = 0; i < towers.length(); i = i + 1 {
        towers[i].built = false
        towers[i].cooldown = 0.0
      }
      for i = 0; i < enemies.length(); i = i + 1 {
        enemies[i].alive = false
      }
      lives = 20
      gold = 120
      score = 0
      wave = 1
      wave_spawn_left = 8
      wave_spawn_timer = 1.0
      between_wave_timer = 2.0
      paused_between_wave = false
      game_over = false
    }

    if not(game_over) {
      // Mouse tower placement
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        let mx = @raylib.get_mouse_x()
        let my = @raylib.get_mouse_y()
        let lane = (my - grid_y) / lane_h
        let slot = (mx - grid_x) / cell_w
        if lane >= 0 && lane < lanes && slot >= 0 && slot < slots {
          let id = tower_index(lane, slot)
          if not(towers[id].built) && gold >= 40 {
            towers[id].built = true
            towers[id].cooldown = 0.0
            gold = gold - 40
          }
        }
      }

      // Spawning waves
      if paused_between_wave {
        between_wave_timer = between_wave_timer - dt
        if between_wave_timer <= 0.0 {
          paused_between_wave = false
          wave = wave + 1
          wave_spawn_left = 8 + wave * 2
          wave_spawn_timer = 0.8
        }
      } else if wave_spawn_left > 0 {
        wave_spawn_timer = wave_spawn_timer - dt
        if wave_spawn_timer <= 0.0 {
          wave_spawn_timer = 0.75
          let lane = @raylib.get_random_value(0, lanes - 1)
          for i = 0; i < enemies.length(); i = i + 1 {
            if not(enemies[i].alive) {
              enemies[i].alive = true
              enemies[i].lane = lane
              enemies[i].x = Float::from_int(screen_w - 30)
              enemies[i].hp = Float::from_int(20 + wave * 7)
              enemies[i].speed = Float::from_int(42 + wave * 3)
              wave_spawn_left = wave_spawn_left - 1
              break
            }
          }
        }
      }

      // Update enemies and count alive
      let mut active_enemies = 0
      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].alive) {
          continue
        }
        active_enemies = active_enemies + 1
        enemies[i].x = enemies[i].x - enemies[i].speed * dt
        if enemies[i].x < Float::from_int(grid_x - 16) {
          enemies[i].alive = false
          lives = lives - 1
          if lives <= 0 {
            game_over = true
          }
        }
      }

      // Towers attack nearest enemy ahead in same lane
      for t = 0; t < towers.length(); t = t + 1 {
        if not(towers[t].built) {
          continue
        }
        towers[t].cooldown = towers[t].cooldown - dt
        if towers[t].cooldown > 0.0 {
          continue
        }

        let lane = towers[t].lane
        let tx = Float::from_int(grid_x + towers[t].slot * cell_w + cell_w / 2)
        let mut best = -1
        let mut best_x : Float = 1_000_000_000.0
        for i = 0; i < enemies.length(); i = i + 1 {
          if not(enemies[i].alive) || enemies[i].lane != lane {
            continue
          }
          let d = enemies[i].x - tx
          if d >= 0.0 && d <= 260.0 && enemies[i].x < best_x {
            best_x = enemies[i].x
            best = i
          }
        }

        if best >= 0 {
          towers[t].cooldown = 0.58
          let damage = Float::from_int(8 + wave)
          enemies[best].hp = enemies[best].hp - damage
          if enemies[best].hp <= 0.0 {
            enemies[best].alive = false
            gold = gold + 12
            score = score + 25
          }
        }
      }

      // Next wave trigger
      if not(paused_between_wave) && wave_spawn_left == 0 {
        let mut any_alive = false
        for i = 0; i < enemies.length(); i = i + 1 {
          if enemies[i].alive {
            any_alive = true
          }
        }
        if not(any_alive) {
          paused_between_wave = true
          between_wave_timer = 2.5
          gold = gold + 30
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 15, 20, 255))

    // Lanes and slots
    for l = 0; l < lanes; l = l + 1 {
      let y = grid_y + l * lane_h
      @raylib.draw_rectangle(grid_x - 10, y + 15, slots * cell_w + 20, lane_h - 30, @raylib.Color::new(44, 50, 58, 255))
      @raylib.draw_line(grid_x - 20, y + lane_h / 2, screen_w - 30, y + lane_h / 2, @raylib.darkgreen)
      for s = 0; s < slots; s = s + 1 {
        let x = grid_x + s * cell_w
        @raylib.draw_rectangle_lines(x, y + 10, cell_w, lane_h - 20, @raylib.Color::new(60, 68, 76, 255))
        let id = tower_index(l, s)
        if towers[id].built {
          @raylib.draw_rectangle(x + 22, y + 34, cell_w - 44, lane_h - 68, @raylib.skyblue)
          @raylib.draw_rectangle(x + 36, y + 26, 16, 12, @raylib.lightgray)
        }
      }
    }

    // Enemies
    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].alive {
        let lane = enemies[i].lane
        let y = grid_y + lane * lane_h + lane_h / 2
        let max_hp = Float::from_int(20 + wave * 7)
        let ratio : Float =
          if max_hp <= (0.0 : Float) { (0.0 : Float) } else {
            enemies[i].hp / max_hp
          }
        @raylib.draw_circle(enemies[i].x.to_int(), y, 14.0, enemy_color(ratio))
      }
    }

    @raylib.draw_text("TOWER DEFENSE FRONTIER 2026", 20, 20, 32, @raylib.yellow)
    @raylib.draw_text("Lives: \{lives}", 26, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Gold: \{gold}", 170, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Score: \{score}", 310, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Wave: \{wave}", 480, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Click slot to build tower (40)", 680, 24, 22, @raylib.gray)
    @raylib.draw_text("R restart", 820, 56, 20, @raylib.gray)

    if paused_between_wave && not(game_over) {
      @raylib.draw_text("NEXT WAVE IN \{between_wave_timer.to_int() + 1}", 365, 610, 28, @raylib.lime)
    }

    if game_over {
      @raylib.draw_rectangle(320, 270, 350, 120, @raylib.fade(@raylib.black, 0.78))
      @raylib.draw_text("FRONTIER LOST", 370, 306, 42, @raylib.red)
      @raylib.draw_text("Press R to restart", 390, 350, 24, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
