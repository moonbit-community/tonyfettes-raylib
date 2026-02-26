///|
let cols : Int = 15

///|
let rows : Int = 13

///|
let tile : Int = 46

///|
let off_x : Int = 38

///|
let off_y : Int = 70

///|
let screen_w : Int = off_x * 2 + cols * tile

///|
let screen_h : Int = off_y + rows * tile + 70

///|
struct Enemy {
  mut alive : Bool
  mut x : Int
  mut y : Int
  mut step_timer : Float
}

///|
struct Bomb {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut fuse : Float
  mut blast : Float
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * cols + x
}

///|
fn in_grid(x : Int, y : Int) -> Bool {
  x >= 0 && x < cols && y >= 0 && y < rows
}

///|
fn init_map() -> Array[Int] {
  let map : Array[Int] = Array::make(cols * rows, 0)
  for y = 0; y < rows; y = y + 1 {
    for x = 0; x < cols; x = x + 1 {
      let mut v = 0
      if x == 0 || y == 0 || x == cols - 1 || y == rows - 1 {
        v = 1
      }
      if x % 2 == 0 && y % 2 == 0 {
        v = 1
      }
      if v == 0 && @raylib.get_random_value(0, 99) < 58 {
        v = 2
      }
      map[idx(x, y)] = v
    }
  }

  // Player and enemy spawn clear zones.
  let clear_cells : Array[(Int, Int)] = [
    (1, 1),
    (1, 2),
    (2, 1),
    (cols - 2, rows - 2),
    (cols - 3, rows - 2),
    (cols - 2, rows - 3),
  ]
  for i = 0; i < clear_cells.length(); i = i + 1 {
    let (x, y) = clear_cells[i]
    map[idx(x, y)] = 0
  }

  map
}

///|
fn is_walkable(map : Array[Int], x : Int, y : Int, bomb : Bomb) -> Bool {
  if not(in_grid(x, y)) {
    return false
  }
  if map[idx(x, y)] != 0 {
    return false
  }
  if bomb.active && bomb.blast <= 0.0 && bomb.x == x && bomb.y == y {
    return false
  }
  true
}

///|
fn fire_hits(map : Array[Int], bomb : Bomb, tx : Int, ty : Int) -> Bool {
  if not(bomb.active) || bomb.blast <= 0.0 {
    return false
  }
  if tx == bomb.x && ty == bomb.y {
    return true
  }

  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for i = 0; i < dirs.length(); i = i + 1 {
    let (dx, dy) = dirs[i]
    let mut x = bomb.x
    let mut y = bomb.y
    for _step = 0; _step < 3; _step = _step + 1 {
      x = x + dx
      y = y + dy
      if not(in_grid(x, y)) {
        break
      }
      let cell = map[idx(x, y)]
      if cell == 1 {
        break
      }
      if tx == x && ty == y {
        return true
      }
      if cell == 2 {
        break
      }
    }
  }
  false
}

///|
fn apply_explosion(map : Array[Int], bomb : Bomb) -> Int {
  if not(bomb.active) || bomb.blast <= 0.0 {
    return 0
  }

  let mut destroyed = 0
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for i = 0; i < dirs.length(); i = i + 1 {
    let (dx, dy) = dirs[i]
    let mut x = bomb.x
    let mut y = bomb.y
    for _step = 0; _step < 3; _step = _step + 1 {
      x = x + dx
      y = y + dy
      if not(in_grid(x, y)) {
        break
      }
      let id = idx(x, y)
      if map[id] == 1 {
        break
      }
      if map[id] == 2 {
        map[id] = 0
        destroyed = destroyed + 1
        break
      }
    }
  }
  destroyed
}

///|
fn draw_fire_arm(map : Array[Int], bomb : Bomb, dx : Int, dy : Int, color : @raylib.Color) -> Unit {
  let mut x = bomb.x
  let mut y = bomb.y
  for _step = 0; _step < 3; _step = _step + 1 {
    x = x + dx
    y = y + dy
    if not(in_grid(x, y)) {
      break
    }
    let cell = map[idx(x, y)]
    if cell == 1 {
      break
    }
    let px = off_x + x * tile
    let py = off_y + y * tile
    @raylib.draw_rectangle(px + 10, py + 10, tile - 20, tile - 20, color)
    if cell == 2 {
      break
    }
  }
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Bomber Grid 2026")
  @raylib.set_target_fps(60)

  let map = init_map()
  let mut player_x = 1
  let mut player_y = 1
  let mut move_cd : Float = 0.0

  let bomb : Bomb = { active: false, x: 0, y: 0, fuse: 0.0, blast: 0.0 }

  let enemies : Array[Enemy] = [
    { alive: true, x: cols - 2, y: rows - 2, step_timer: 0.0 },
    { alive: true, x: cols - 3, y: rows - 2, step_timer: 0.2 },
  ]

  let mut score = 0
  let mut win = false
  let mut lose = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      let fresh = init_map()
      for i = 0; i < map.length(); i = i + 1 {
        map[i] = fresh[i]
      }
      player_x = 1
      player_y = 1
      move_cd = 0.0
      bomb.active = false
      for i = 0; i < enemies.length(); i = i + 1 {
        enemies[i].alive = true
        enemies[i].x = cols - 2 - i
        enemies[i].y = rows - 2
        enemies[i].step_timer = Float::from_int(i) * 0.15
      }
      score = 0
      win = false
      lose = false
    }

    if not(win) && not(lose) {
      move_cd = move_cd - dt
      if move_cd < 0.0 {
        move_cd = 0.0
      }

      let mut dx = 0
      let mut dy = 0
      if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
        dy = -1
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) || @raylib.is_key_pressed(@raylib.KeyS) {
        dy = 1
      }
      if @raylib.is_key_pressed(@raylib.KeyLeft) || @raylib.is_key_pressed(@raylib.KeyA) {
        dx = -1
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) || @raylib.is_key_pressed(@raylib.KeyD) {
        dx = 1
      }

      if move_cd <= 0.0 {
        let nx = player_x + dx
        let ny = player_y + dy
        if (dx != 0 || dy != 0) && is_walkable(map, nx, ny, bomb) {
          player_x = nx
          player_y = ny
          move_cd = 0.09
        }
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) && not(bomb.active) {
        bomb.active = true
        bomb.x = player_x
        bomb.y = player_y
        bomb.fuse = 2.0
        bomb.blast = 0.0
      }

      if bomb.active {
        if bomb.blast <= 0.0 {
          bomb.fuse = bomb.fuse - dt
          if bomb.fuse <= 0.0 {
            bomb.blast = 0.55
          }
        } else {
          bomb.blast = bomb.blast - dt
          score = score + apply_explosion(map, bomb) * 12
          if bomb.blast <= 0.0 {
            bomb.active = false
          }
        }
      }

      if fire_hits(map, bomb, player_x, player_y) {
        lose = true
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].alive) {
          continue
        }

        if fire_hits(map, bomb, enemies[i].x, enemies[i].y) {
          enemies[i].alive = false
          score = score + 120
          continue
        }

        enemies[i].step_timer = enemies[i].step_timer + dt
        if enemies[i].step_timer >= 0.32 {
          enemies[i].step_timer = enemies[i].step_timer - 0.32
          let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
          let start = @raylib.get_random_value(0, 3)
          for try_i = 0; try_i < dirs.length(); try_i = try_i + 1 {
            let j = (start + try_i) % dirs.length()
            let (ddx, ddy) = dirs[j]
            let nx = enemies[i].x + ddx
            let ny = enemies[i].y + ddy
            if is_walkable(map, nx, ny, bomb) {
              enemies[i].x = nx
              enemies[i].y = ny
              break
            }
          }
        }

        if enemies[i].x == player_x && enemies[i].y == player_y {
          lose = true
        }
      }

      let mut alive_enemy = 0
      for i = 0; i < enemies.length(); i = i + 1 {
        if enemies[i].alive {
          alive_enemy = alive_enemy + 1
        }
      }
      if alive_enemy == 0 {
        win = true
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(16, 16, 24, 255))

    for y = 0; y < rows; y = y + 1 {
      for x = 0; x < cols; x = x + 1 {
        let px = off_x + x * tile
        let py = off_y + y * tile
        match map[idx(x, y)] {
          1 => @raylib.draw_rectangle(px, py, tile, tile, @raylib.darkgray)
          2 => @raylib.draw_rectangle(px + 4, py + 4, tile - 8, tile - 8, @raylib.brown)
          _ => @raylib.draw_rectangle_lines(px, py, tile, tile, @raylib.Color::new(35, 35, 42, 255))
        }
      }
    }

    if bomb.active {
      let bx = off_x + bomb.x * tile
      let by = off_y + bomb.y * tile
      if bomb.blast > 0.0 {
        let fire_col = @raylib.orange
        @raylib.draw_rectangle(bx + 9, by + 9, tile - 18, tile - 18, fire_col)
        draw_fire_arm(map, bomb, -1, 0, fire_col)
        draw_fire_arm(map, bomb, 1, 0, fire_col)
        draw_fire_arm(map, bomb, 0, -1, fire_col)
        draw_fire_arm(map, bomb, 0, 1, fire_col)
      } else {
        @raylib.draw_circle(bx + tile / 2, by + tile / 2, 12.0, @raylib.black)
      }
    }

    let player_px = off_x + player_x * tile
    let player_py = off_y + player_y * tile
    @raylib.draw_rectangle(player_px + 8, player_py + 8, tile - 16, tile - 16, @raylib.skyblue)

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].alive {
        let ex = off_x + enemies[i].x * tile
        let ey = off_y + enemies[i].y * tile
        @raylib.draw_rectangle(ex + 8, ey + 8, tile - 16, tile - 16, @raylib.red)
      }
    }

    @raylib.draw_text("BOMBER GRID 2026", 24, 20, 34, @raylib.yellow)
    @raylib.draw_text("Score: \{score}", 26, 56, 24, @raylib.raywhite)
    @raylib.draw_text("WASD move | SPACE bomb | R restart", 450, 30, 22, @raylib.gray)

    if win || lose {
      @raylib.draw_rectangle(270, 310, 420, 110, @raylib.fade(@raylib.black, 0.76))
      @raylib.draw_text(if win { "YOU WIN" } else { "YOU LOSE" }, 380, 338, 44, if win { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 368, 382, 24, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
