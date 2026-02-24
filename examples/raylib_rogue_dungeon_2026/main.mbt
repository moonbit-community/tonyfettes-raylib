///|
let map_w : Int = 21

///|
let map_h : Int = 15

///|
let tile_sz : Int = 36

///|
let view_x : Int = 34

///|
let view_y : Int = 86

///|
let screen_w : Int = view_x * 2 + map_w * tile_sz

///|
let screen_h : Int = 720

///|
struct Mob {
  mut alive : Bool
  mut x : Int
  mut y : Int
  mut hp : Int
}

///|
fn mindex(x : Int, y : Int) -> Int {
  y * map_w + x
}

///|
fn inside(x : Int, y : Int) -> Bool {
  x >= 0 && x < map_w && y >= 0 && y < map_h
}

///|
fn gen_level() -> Array[Int] {
  let arr : Array[Int] = Array::make(map_w * map_h, 0)
  for y = 0; y < map_h; y = y + 1 {
    for x = 0; x < map_w; x = x + 1 {
      let mut v = 0
      if x == 0 || y == 0 || x == map_w - 1 || y == map_h - 1 {
        v = 1
      }
      if v == 0 && @raylib.get_random_value(0, 99) < 22 {
        v = 1
      }
      arr[mindex(x, y)] = v
    }
  }

  // carve center corridor
  let cy = map_h / 2
  for x = 1; x < map_w - 1; x = x + 1 {
    arr[mindex(x, cy)] = 0
  }

  // ensure start area open
  arr[mindex(1, 1)] = 0
  arr[mindex(2, 1)] = 0
  arr[mindex(1, 2)] = 0
  arr
}

///|
fn mob_at(mobs : Array[Mob], x : Int, y : Int) -> Int {
  for i = 0; i < mobs.length(); i = i + 1 {
    if mobs[i].alive && mobs[i].x == x && mobs[i].y == y {
      return i
    }
  }
  -1
}

///|
fn passable(level : Array[Int], mobs : Array[Mob], x : Int, y : Int) -> Bool {
  if not(inside(x, y)) {
    return false
  }
  if level[mindex(x, y)] != 0 {
    return false
  }
  mob_at(mobs, x, y) < 0
}

///|
fn step_toward(ax : Int, ay : Int, bx : Int, by : Int) -> (Int, Int) {
  let dx = bx - ax
  let dy = by - ay
  if dx.abs() > dy.abs() {
    (if dx > 0 { 1 } else { -1 }, 0)
  } else if dy != 0 {
    (0, if dy > 0 { 1 } else { -1 })
  } else {
    (0, 0)
  }
}

///|
fn draw_board(level : Array[Int]) -> Unit {
  for y = 0; y < map_h; y = y + 1 {
    for x = 0; x < map_w; x = x + 1 {
      let px = view_x + x * tile_sz
      let py = view_y + y * tile_sz
      if level[mindex(x, y)] == 0 {
        @raylib.draw_rectangle(px, py, tile_sz, tile_sz, @raylib.Color::new(36, 36, 46, 255))
        @raylib.draw_rectangle_lines(px, py, tile_sz, tile_sz, @raylib.Color::new(24, 24, 30, 255))
      } else {
        @raylib.draw_rectangle(px, py, tile_sz, tile_sz, @raylib.Color::new(88, 88, 102, 255))
      }
    }
  }
}

///|
fn draw_unit(x : Int, y : Int, color : @raylib.Color, glyph : String) -> Unit {
  let px = view_x + x * tile_sz
  let py = view_y + y * tile_sz
  @raylib.draw_rectangle(px + 6, py + 6, tile_sz - 12, tile_sz - 12, color)
  @raylib.draw_text(glyph, px + 12, py + 8, 20, @raylib.black)
}

///|
fn alive_mobs(mobs : Array[Mob]) -> Int {
  let mut n = 0
  for i = 0; i < mobs.length(); i = i + 1 {
    if mobs[i].alive {
      n = n + 1
    }
  }
  n
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Rogue Dungeon 2026")
  @raylib.set_target_fps(60)

  let level = gen_level()
  let mobs : Array[Mob] = [
    { alive: true, x: map_w - 2, y: 1, hp: 4 },
    { alive: true, x: map_w - 3, y: map_h - 2, hp: 5 },
    { alive: true, x: map_w - 5, y: map_h / 2, hp: 6 },
    { alive: true, x: map_w - 8, y: 3, hp: 4 },
  ]

  let mut hero_x = 1
  let mut hero_y = 1
  let mut hero_hp = 14
  let mut turns = 0
  let mut score = 0
  let mut victory = false
  let mut defeat = false

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      let fresh = gen_level()
      for i = 0; i < level.length(); i = i + 1 {
        level[i] = fresh[i]
      }
      hero_x = 1
      hero_y = 1
      hero_hp = 14
      turns = 0
      score = 0
      victory = false
      defeat = false
      mobs[0] = { alive: true, x: map_w - 2, y: 1, hp: 4 }
      mobs[1] = { alive: true, x: map_w - 3, y: map_h - 2, hp: 5 }
      mobs[2] = { alive: true, x: map_w - 5, y: map_h / 2, hp: 6 }
      mobs[3] = { alive: true, x: map_w - 8, y: 3, hp: 4 }
    }

    if not(victory) && not(defeat) {
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

      if dx != 0 || dy != 0 {
        let tx = hero_x + dx
        let ty = hero_y + dy
        let hit = mob_at(mobs, tx, ty)
        if hit >= 0 {
          mobs[hit].hp = mobs[hit].hp - 3
          if mobs[hit].hp <= 0 {
            mobs[hit].alive = false
            score = score + 100
          } else {
            score = score + 20
          }
        } else if inside(tx, ty) && level[mindex(tx, ty)] == 0 {
          hero_x = tx
          hero_y = ty
          score = score + 2
        }

        // Enemy turn
        for i = 0; i < mobs.length(); i = i + 1 {
          if not(mobs[i].alive) {
            continue
          }
          let dist = (mobs[i].x - hero_x).abs() + (mobs[i].y - hero_y).abs()
          if dist == 1 {
            hero_hp = hero_hp - 2
            continue
          }
          let (sx, sy) = step_toward(mobs[i].x, mobs[i].y, hero_x, hero_y)
          let nx = mobs[i].x + sx
          let ny = mobs[i].y + sy
          if passable(level, mobs, nx, ny) && not(nx == hero_x && ny == hero_y) {
            mobs[i].x = nx
            mobs[i].y = ny
          } else {
            let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            let start = @raylib.get_random_value(0, 3)
            for t = 0; t < 4; t = t + 1 {
              let (rx, ry) = dirs[(start + t) % 4]
              let wx = mobs[i].x + rx
              let wy = mobs[i].y + ry
              if passable(level, mobs, wx, wy) && not(wx == hero_x && wy == hero_y) {
                mobs[i].x = wx
                mobs[i].y = wy
                break
              }
            }
          }
          if (mobs[i].x - hero_x).abs() + (mobs[i].y - hero_y).abs() == 1 {
            hero_hp = hero_hp - 1
          }
        }

        turns = turns + 1
        if hero_hp <= 0 {
          defeat = true
        }
        if alive_mobs(mobs) == 0 {
          victory = true
          score = score + 500
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 16, 22, 255))

    draw_board(level)
    draw_unit(hero_x, hero_y, @raylib.skyblue, "@")

    for i = 0; i < mobs.length(); i = i + 1 {
      if mobs[i].alive {
        draw_unit(mobs[i].x, mobs[i].y, @raylib.red, "M")
      }
    }

    @raylib.draw_text("ROGUE DUNGEON 2026", 20, 20, 34, @raylib.lime)
    @raylib.draw_text("HP: \{hero_hp}", 22, 60, 24, @raylib.raywhite)
    @raylib.draw_text("Score: \{score}", 170, 60, 24, @raylib.raywhite)
    @raylib.draw_text("Turns: \{turns}", 360, 60, 24, @raylib.raywhite)
    @raylib.draw_text("Enemies: \{alive_mobs(mobs)}", 530, 60, 24, @raylib.raywhite)
    @raylib.draw_text("WASD move/attack | R restart", 700, 26, 20, @raylib.gray)

    if victory || defeat {
      @raylib.draw_rectangle(330, 300, 420, 120, @raylib.fade(@raylib.black, 0.76))
      @raylib.draw_text(if victory { "DUNGEON CLEARED" } else { "YOU FELL" }, 380, 334, 42, if victory { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 432, 378, 24, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
