///|
let sw : Int = 1080

///|
let sh : Int = 720

///|
let map_w : Int = 18

///|
let map_h : Int = 12

///|
let tile : Int = 48

///|
let map_x : Int = 108

///|
let map_y : Int = 92

///|
struct Guard {
  mut x : Int
  mut y : Int
  mut dir : Int
  mut stunned : Int
}

///|
struct Card {
  mut x : Int
  mut y : Int
  mut collected : Bool
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * map_w + x
}

///|
fn set_wall(map : Array[Int], x : Int, y : Int) -> Unit {
  map[idx(x, y)] = 1
}

///|
fn is_wall(map : Array[Int], x : Int, y : Int) -> Bool {
  if x < 0 || x >= map_w || y < 0 || y >= map_h {
    true
  } else {
    map[idx(x, y)] == 1
  }
}

///|
fn build_map(map : Array[Int]) -> Unit {
  for i = 0; i < map.length(); i = i + 1 {
    map[i] = 0
  }

  for x = 0; x < map_w; x = x + 1 {
    set_wall(map, x, 0)
    set_wall(map, x, map_h - 1)
  }
  for y = 0; y < map_h; y = y + 1 {
    set_wall(map, 0, y)
    set_wall(map, map_w - 1, y)
  }

  for y = 2; y <= 9; y = y + 1 {
    if y != 5 {
      set_wall(map, 4, y)
    }
  }
  for y = 1; y <= 8; y = y + 1 {
    if y != 3 && y != 7 {
      set_wall(map, 9, y)
    }
  }
  for x = 6; x <= 15; x = x + 1 {
    if x != 12 {
      set_wall(map, x, 6)
    }
  }
  for x = 2; x <= 10; x = x + 1 {
    if x != 7 {
      set_wall(map, x, 9)
    }
  }

  set_wall(map, 13, 3)
  set_wall(map, 14, 3)
  set_wall(map, 14, 4)
  set_wall(map, 14, 8)
  set_wall(map, 13, 8)
  set_wall(map, 3, 3)
}

///|
fn reset_cards(cards : Array[Card]) -> Unit {
  cards[0].x = 2
  cards[0].y = 2
  cards[0].collected = false

  cards[1].x = 12
  cards[1].y = 2
  cards[1].collected = false

  cards[2].x = 7
  cards[2].y = 10
  cards[2].collected = false
}

///|
fn reset_guards(guards : Array[Guard]) -> Unit {
  guards[0] = { x: 6, y: 2, dir: 0, stunned: 0 }
  guards[1] = { x: 11, y: 4, dir: 2, stunned: 0 }
  guards[2] = { x: 15, y: 9, dir: 3, stunned: 0 }
  guards[3] = { x: 3, y: 8, dir: 1, stunned: 0 }
}

///|
fn has_line_of_sight(
  map : Array[Int],
  gx : Int,
  gy : Int,
  px : Int,
  py : Int,
) -> Bool {
  if gx == px {
    let step = if py > gy { 1 } else { -1 }
    let mut y = gy + step
    while y != py {
      if is_wall(map, gx, y) {
        return false
      }
      y = y + step
    }
    true
  } else if gy == py {
    let step = if px > gx { 1 } else { -1 }
    let mut x = gx + step
    while x != px {
      if is_wall(map, x, gy) {
        return false
      }
      x = x + step
    }
    true
  } else {
    false
  }
}

///|
fn try_step(map : Array[Int], x : Int, y : Int, dir : Int) -> (Int, Int, Bool) {
  let mut nx = x
  let mut ny = y
  if dir == 0 {
    nx = nx + 1
  } else if dir == 1 {
    ny = ny + 1
  } else if dir == 2 {
    nx = nx - 1
  } else {
    ny = ny - 1
  }
  if is_wall(map, nx, ny) {
    (x, y, false)
  } else {
    (nx, ny, true)
  }
}

///|
fn move_guard_toward_player(
  map : Array[Int],
  sentry : Guard,
  px : Int,
  py : Int,
) -> Unit {
  if sentry.x == px {
    let dir = if py > sentry.y { 1 } else { 3 }
    let (nx, ny, ok) = try_step(map, sentry.x, sentry.y, dir)
    if ok {
      sentry.x = nx
      sentry.y = ny
    }
  } else if sentry.y == py {
    let dir = if px > sentry.x { 0 } else { 2 }
    let (nx, ny, ok) = try_step(map, sentry.x, sentry.y, dir)
    if ok {
      sentry.x = nx
      sentry.y = ny
    }
  }
}

///|
fn all_cards_collected(cards : Array[Card]) -> Bool {
  for i = 0; i < cards.length(); i = i + 1 {
    if not(cards[i].collected) {
      return false
    }
  }
  true
}

///|
fn collected_cards(cards : Array[Card]) -> Int {
  let mut count = 0
  for i = 0; i < cards.length(); i = i + 1 {
    if cards[i].collected {
      count = count + 1
    }
  }
  count
}

///|
fn main {
  @raylib.init_window(sw, sh, "Stealth Heist 2026")
  @raylib.set_target_fps(60)

  let map : Array[Int] = Array::make(map_w * map_h, 0)
  build_map(map)

  let guards : Array[Guard] = Array::makei(4, fn(_i) {
    { x: 1, y: 1, dir: 0, stunned: 0 }
  })
  reset_guards(guards)

  let cards : Array[Card] = Array::makei(3, fn(_i) {
    { x: 1, y: 1, collected: false }
  })
  reset_cards(cards)

  let exit_x = 16
  let exit_y = 10

  let mut player_x = 1
  let mut player_y = 1
  let mut smoke = 3
  let mut turns = 0
  let mut alert = 0
  let mut won = false
  let mut lost = false
  let mut msg = "Move with arrows/WASD. Space uses smoke. Reach extraction at E."

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      build_map(map)
      reset_guards(guards)
      reset_cards(cards)
      player_x = 1
      player_y = 1
      smoke = 3
      turns = 0
      alert = 0
      won = false
      lost = false
      msg = "Heist reset. Stay unseen and collect all keycards."
    }

    let mut acted = false

    if not(won) && not(lost) {
      let mut move_dir = -1
      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        move_dir = 2
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        move_dir = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        move_dir = 3
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        move_dir = 1
      }

      if move_dir >= 0 {
        let (nx, ny, ok) = try_step(map, player_x, player_y, move_dir)
        if ok {
          player_x = nx
          player_y = ny
          acted = true
        } else {
          msg = "Blocked by wall."
        }
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) && smoke > 0 {
        smoke = smoke - 1
        for i = 0; i < guards.length(); i = i + 1 {
          let dx = (guards[i].x - player_x).abs()
          let dy = (guards[i].y - player_y).abs()
          if dx + dy <= 4 {
            guards[i].stunned = 3
          }
        }
        acted = true
        msg = "Smoke popped. Nearby guards are stunned."
      }

      for i = 0; i < cards.length(); i = i + 1 {
        if not(cards[i].collected) &&
          cards[i].x == player_x &&
          cards[i].y == player_y {
          cards[i].collected = true
          msg = "Keycard collected (\{i + 1}/3)."
        }
      }

      if acted {
        turns = turns + 1

        let mut seen = false
        for i = 0; i < guards.length(); i = i + 1 {
          if guards[i].stunned > 0 {
            guards[i].stunned = guards[i].stunned - 1
            continue
          }

          if has_line_of_sight(
              map,
              guards[i].x,
              guards[i].y,
              player_x,
              player_y,
            ) {
            seen = true
            move_guard_toward_player(map, guards[i], player_x, player_y)
          } else {
            let mut moved = false
            for _k = 0; _k < 4; _k = _k + 1 {
              let (nx, ny, ok) = try_step(
                map,
                guards[i].x,
                guards[i].y,
                guards[i].dir,
              )
              if ok {
                guards[i].x = nx
                guards[i].y = ny
                moved = true
                break
              }
              guards[i].dir = (guards[i].dir + 1) % 4
            }
            if not(moved) {
              guards[i].dir = (guards[i].dir + 1) % 4
            }
          }
        }

        if seen {
          alert = alert + 1
          msg = "Guard sightline! Alert +1."
        }

        for i = 0; i < guards.length(); i = i + 1 {
          let dx = (guards[i].x - player_x).abs()
          let dy = (guards[i].y - player_y).abs()
          if dx + dy <= 1 {
            lost = true
            msg = "Caught by security."
          }
        }

        if alert >= 5 {
          lost = true
          msg = "Facility fully alerted. Mission failed."
        }

        if all_cards_collected(cards) &&
          player_x == exit_x &&
          player_y == exit_y {
          won = true
          msg = "Extraction complete. Clean heist."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(16, 20, 26, 255))

    for y = 0; y < map_h; y = y + 1 {
      for x = 0; x < map_w; x = x + 1 {
        let px = map_x + x * tile
        let py = map_y + y * tile

        if is_wall(map, x, y) {
          @raylib.draw_rectangle(
            px,
            py,
            tile - 1,
            tile - 1,
            @raylib.Color::new(58, 63, 72, 255),
          )
        } else {
          @raylib.draw_rectangle(
            px,
            py,
            tile - 1,
            tile - 1,
            @raylib.Color::new(26, 32, 40, 255),
          )
        }

        if x == exit_x && y == exit_y {
          @raylib.draw_rectangle(
            px + 8,
            py + 8,
            tile - 17,
            tile - 17,
            @raylib.Color::new(40, 90, 44, 255),
          )
          @raylib.draw_text("E", px + 16, py + 10, 30, @raylib.lime)
        }
      }
    }

    for i = 0; i < cards.length(); i = i + 1 {
      if not(cards[i].collected) {
        let cx = map_x + cards[i].x * tile + tile / 2
        let cy = map_y + cards[i].y * tile + tile / 2
        @raylib.draw_circle(cx, cy, 12.0, @raylib.gold)
        @raylib.draw_circle_lines(cx, cy, 12.0, @raylib.yellow)
      }
    }

    for i = 0; i < guards.length(); i = i + 1 {
      let gx = map_x + guards[i].x * tile + tile / 2
      let gy = map_y + guards[i].y * tile + tile / 2
      @raylib.draw_circle(
        gx,
        gy,
        15.0,
        if guards[i].stunned > 0 {
          @raylib.gray
        } else {
          @raylib.red
        },
      )
      @raylib.draw_circle_lines(gx, gy, 15.0, @raylib.white)
      if guards[i].stunned > 0 {
        @raylib.draw_text("Z", gx - 6, gy - 34, 24, @raylib.lightgray)
      }
    }

    let px = map_x + player_x * tile + tile / 2
    let py = map_y + player_y * tile + tile / 2
    @raylib.draw_circle(px, py, 14.0, @raylib.skyblue)
    @raylib.draw_circle_lines(px, py, 14.0, @raylib.white)

    @raylib.draw_text("STEALTH HEIST 2026", 24, 16, 40, @raylib.skyblue)
    @raylib.draw_text("Turns: \{turns}", 24, 64, 28, @raylib.raywhite)
    @raylib.draw_text("Smoke: \{smoke}", 24, 96, 28, @raylib.raywhite)
    @raylib.draw_text(
      "Alert: \{alert}/5",
      24,
      128,
      28,
      if alert >= 4 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )
    @raylib.draw_text(
      "Cards: \{collected_cards(cards)} / 3",
      24,
      160,
      28,
      @raylib.yellow,
    )

    @raylib.draw_rectangle(
      22,
      664,
      sw - 44,
      36,
      @raylib.Color::new(10, 14, 18, 220),
    )
    @raylib.draw_text(msg, 32, 672, 22, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(
        280,
        258,
        520,
        170,
        @raylib.fade(@raylib.black, 0.8),
      )
      @raylib.draw_text(
        if won {
          "HEIST SUCCESS"
        } else {
          "HEIST FAILED"
        },
        390,
        300,
        46,
        if won {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @raylib.draw_text("Press R to run again", 412, 360, 30, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
