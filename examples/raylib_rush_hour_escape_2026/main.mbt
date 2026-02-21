///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let gw : Int = 6

///|
let gh : Int = 6

///|
let cell : Int = 90

///|
let ox : Int = 370

///|
let oy : Int = 126

///|
let exit_row : Int = 2

///|
let max_cars : Int = 14

///|
struct Car {
  mut x : Int
  mut y : Int
  len : Int
  horizontal : Bool
  player : Bool
  color : Int
  active : Bool
}

///|
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn clear_cars(cars : Array[Car]) -> Unit {
  for i = 0; i < cars.length(); i = i + 1 {
    cars[i] = {
      x: 0,
      y: 0,
      len: 2,
      horizontal: true,
      player: false,
      color: 0,
      active: false,
    }
  }
}

///|
fn put_car(
  cars : Array[Car],
  i : Int,
  x : Int,
  y : Int,
  len : Int,
  horizontal : Bool,
  player : Bool,
  color : Int,
) -> Unit {
  cars[i] = {
    x: x,
    y: y,
    len: len,
    horizontal: horizontal,
    player: player,
    color: color,
    active: true,
  }
}

///|
fn setup_level(level : Int, cars : Array[Car]) -> (Int, Int) {
  clear_cars(cars)

  if level == 1 {
    put_car(cars, 0, 1, exit_row, 2, true, true, 0)
    put_car(cars, 1, 0, 0, 3, false, false, 1)
    put_car(cars, 2, 3, 1, 3, false, false, 2)
    put_car(cars, 3, 5, 0, 3, false, false, 3)
    put_car(cars, 4, 4, 2, 2, false, false, 4)
    put_car(cars, 5, 0, 3, 2, true, false, 5)
    put_car(cars, 6, 1, 4, 3, true, false, 6)
    put_car(cars, 7, 0, 5, 2, true, false, 7)
    put_car(cars, 8, 2, 5, 2, true, false, 8)
    (9, 12)
  } else if level == 2 {
    put_car(cars, 0, 0, exit_row, 2, true, true, 0)
    put_car(cars, 1, 2, 0, 3, false, false, 1)
    put_car(cars, 2, 3, 2, 3, false, false, 2)
    put_car(cars, 3, 5, 0, 3, false, false, 3)
    put_car(cars, 4, 0, 0, 2, true, false, 4)
    put_car(cars, 5, 1, 4, 2, true, false, 5)
    put_car(cars, 6, 4, 3, 2, false, false, 6)
    put_car(cars, 7, 0, 5, 3, true, false, 7)
    put_car(cars, 8, 1, 1, 2, false, false, 8)
    put_car(cars, 9, 3, 1, 2, true, false, 9)
    (10, 16)
  } else {
    put_car(cars, 0, 1, exit_row, 2, true, true, 0)
    put_car(cars, 1, 3, 0, 3, false, false, 1)
    put_car(cars, 2, 4, 1, 2, false, false, 2)
    put_car(cars, 3, 5, 0, 3, false, false, 3)
    put_car(cars, 4, 0, 0, 2, true, false, 4)
    put_car(cars, 5, 0, 1, 2, false, false, 5)
    put_car(cars, 6, 1, 4, 2, true, false, 6)
    put_car(cars, 7, 2, 4, 2, false, false, 7)
    put_car(cars, 8, 0, 5, 3, true, false, 8)
    put_car(cars, 9, 2, 0, 2, false, false, 9)
    put_car(cars, 10, 4, 4, 2, true, false, 10)
    (11, 19)
  }
}

///|
fn color_for(color : Int) -> @raylib.Color {
  if color == 0 {
    @raylib.Color::new(238, 96, 92, 255)
  } else if color % 8 == 1 {
    @raylib.Color::new(88, 178, 236, 255)
  } else if color % 8 == 2 {
    @raylib.Color::new(106, 212, 132, 255)
  } else if color % 8 == 3 {
    @raylib.Color::new(244, 194, 92, 255)
  } else if color % 8 == 4 {
    @raylib.Color::new(214, 126, 228, 255)
  } else if color % 8 == 5 {
    @raylib.Color::new(98, 214, 220, 255)
  } else if color % 8 == 6 {
    @raylib.Color::new(234, 132, 116, 255)
  } else {
    @raylib.Color::new(178, 176, 244, 255)
  }
}

///|
fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < gw && y >= 0 && y < gh
}

///|
fn occupied_by(cars : Array[Car], count : Int, skip : Int, gx : Int, gy : Int) -> Bool {
  let mut occ = false
  for i = 0; i < count; i = i + 1 {
    if i == skip || not(cars[i].active) {
      continue
    }
    if cars[i].horizontal {
      if gy == cars[i].y && gx >= cars[i].x && gx < cars[i].x + cars[i].len {
        occ = true
      }
    } else {
      if gx == cars[i].x && gy >= cars[i].y && gy < cars[i].y + cars[i].len {
        occ = true
      }
    }
  }
  occ
}

///|
fn find_car_at(cars : Array[Car], count : Int, gx : Int, gy : Int) -> Int {
  let mut found = -1
  for i = 0; i < count; i = i + 1 {
    if not(cars[i].active) {
      continue
    }
    if cars[i].horizontal {
      if gy == cars[i].y && gx >= cars[i].x && gx < cars[i].x + cars[i].len {
        found = i
      }
    } else {
      if gx == cars[i].x && gy >= cars[i].y && gy < cars[i].y + cars[i].len {
        found = i
      }
    }
  }
  found
}

///|
fn can_move(cars : Array[Car], count : Int, car_id : Int, step : Int) -> Bool {
  if car_id < 0 || car_id >= count || not(cars[car_id].active) {
    return false
  }
  if step == 0 {
    return false
  }

  if cars[car_id].horizontal {
    let target = if step < 0 { cars[car_id].x - 1 } else { cars[car_id].x + cars[car_id].len }
    if not(in_board(target, cars[car_id].y)) {
      return false
    }
    not(occupied_by(cars, count, car_id, target, cars[car_id].y))
  } else {
    let target = if step < 0 { cars[car_id].y - 1 } else { cars[car_id].y + cars[car_id].len }
    if not(in_board(cars[car_id].x, target)) {
      return false
    }
    not(occupied_by(cars, count, car_id, cars[car_id].x, target))
  }
}

///|
fn try_move(cars : Array[Car], count : Int, car_id : Int, step : Int) -> Bool {
  if not(can_move(cars, count, car_id, step)) {
    return false
  }

  if cars[car_id].horizontal {
    cars[car_id].x = cars[car_id].x + step
  } else {
    cars[car_id].y = cars[car_id].y + step
  }
  true
}

///|
fn solved(cars : Array[Car]) -> Bool {
  cars[0].active && cars[0].x + cars[0].len - 1 == gw - 1 && cars[0].y == exit_row
}

///|
fn main {
  @raylib.init_window(sw, sh, "Rush Hour Escape 2026")
  @raylib.set_target_fps(60)

  let cars : Array[Car] = Array::makei(max_cars, fn(_i) {
    {
      x: 0,
      y: 0,
      len: 2,
      horizontal: true,
      player: false,
      color: 0,
      active: false,
    }
  })

  let mut level = 1
  let mut car_count = 0
  let mut par = 0
  let (c, p) = setup_level(level, cars)
  car_count = c
  par = p

  let mut moves = 0
  let mut selected = 0
  let mut score = 0
  let mut stars = 0

  let mut over = false
  let mut won = false
  let mut transition_t : Float = 0.0
  let mut msg = "Select a car, then use arrows/WASD to slide."

  while not(@raylib.window_should_close()) {
    let dt = @raylib.get_frame_time()

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rc, rp) = setup_level(level, cars)
      car_count = rc
      par = rp
      moves = 0
      selected = 0
      score = 0
      stars = 0
      over = false
      won = false
      transition_t = 0.0
      msg = "Puzzle reset."
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nc, np) = setup_level(level, cars)
          car_count = nc
          par = np
          moves = 0
          selected = 0
          msg = "Level \{level}."
        } else {
          over = true
          won = true
          msg = "All levels cleared."
        }
      }
    }

    if not(over) && transition_t <= 0.0 {
      let m = @raylib.get_mouse_position()
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ox, oy, gw * cell, gh * cell) {
          let gx = ((m.x - Float::from_int(ox)).to_int()) / cell
          let gy = ((m.y - Float::from_int(oy)).to_int()) / cell
          let f = find_car_at(cars, car_count, gx, gy)
          if f >= 0 {
            selected = f
            if cars[selected].player {
              msg = "Player car selected. Reach the right gate."
            } else {
              msg = "Car \{selected} selected."
            }
          }
        }
      }

      let mut dx = 0
      let mut dy = 0
      let mut acted = false

      if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        dx = -1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        dx = 1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyW) || @raylib.is_key_pressed(@raylib.KeyUp) {
        dy = -1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyS) || @raylib.is_key_pressed(@raylib.KeyDown) {
        dy = 1
        acted = true
      }

      let ctl_x = 24
      let ctl_y = sh - 182
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x, ctl_y + 58, 76, 52) {
          dx = -1
          acted = true
        } else if inside_rect(m.x, m.y, ctl_x + 84, ctl_y + 58, 76, 52) {
          dx = 1
          acted = true
        } else if inside_rect(m.x, m.y, ctl_x + 84, ctl_y, 76, 52) {
          dy = -1
          acted = true
        } else if inside_rect(m.x, m.y, ctl_x + 84, ctl_y + 116, 76, 52) {
          dy = 1
          acted = true
        }
      }

      if acted {
        let mut moved = false
        if cars[selected].horizontal {
          if dx != 0 {
            moved = try_move(cars, car_count, selected, dx)
          } else {
            msg = "This car moves left/right only."
          }
        } else {
          if dy != 0 {
            moved = try_move(cars, car_count, selected, dy)
          } else {
            msg = "This car moves up/down only."
          }
        }

        if moved {
          moves = moves + 1
          msg = "Moves: \{moves}"
        } else if msg == "Moves: \{moves}" {
          msg = "Blocked."
        }

        if solved(cars) {
          let mut bonus = 150
          if moves <= par {
            bonus = 230 + (par - moves) * 12
            stars = stars + 3
          } else if moves <= par + 3 {
            bonus = 170 - (moves - par) * 6
            if bonus < 90 {
              bonus = 90
            }
            stars = stars + 2
          } else {
            bonus = 90 - (moves - par) * 3
            if bonus < 40 {
              bonus = 40
            }
            stars = stars + 1
          }

          score = score + bonus
          transition_t = 1.0
          msg = "Level cleared."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 16, 24, 255))

    @raylib.draw_rectangle(0, 0, sw, 104, @raylib.Color::new(8, 12, 20, 230))
    @raylib.draw_text("RUSH HOUR ESCAPE 2026", 18, 22, 36, @raylib.Color::new(236, 244, 252, 255))
    @raylib.draw_text("Level \{level}/3", 484, 34, 30, @raylib.Color::new(244, 226, 136, 255))
    @raylib.draw_text("Moves \{moves}", 660, 34, 30, @raylib.Color::new(218, 234, 250, 255))
    @raylib.draw_text("Par \{par}", 830, 34, 30, @raylib.Color::new(198, 228, 252, 255))
    @raylib.draw_text("Score \{score}", 980, 34, 30, @raylib.Color::new(198, 228, 252, 255))

    @raylib.draw_rectangle(ox - 24, oy - 24, gw * cell + 48, gh * cell + 48, @raylib.Color::new(74, 58, 44, 255))
    @raylib.draw_rectangle(ox, oy, gw * cell, gh * cell, @raylib.Color::new(224, 214, 196, 255))

    for y = 0; y <= gh; y = y + 1 {
      let ly = oy + y * cell
      @raylib.draw_line(ox, ly, ox + gw * cell, ly, @raylib.Color::new(166, 150, 128, 255))
    }
    for x = 0; x <= gw; x = x + 1 {
      let lx = ox + x * cell
      @raylib.draw_line(lx, oy, lx, oy + gh * cell, @raylib.Color::new(166, 150, 128, 255))
    }

    let gate_y = oy + exit_row * cell + 8
    @raylib.draw_rectangle(ox + gw * cell, gate_y, 18, cell - 16, @raylib.Color::new(246, 110, 110, 255))
    @raylib.draw_text("EXIT", ox + gw * cell + 20, gate_y + 20, 22, @raylib.Color::new(250, 220, 220, 255))

    for i = 0; i < car_count; i = i + 1 {
      if not(cars[i].active) {
        continue
      }

      let x = ox + cars[i].x * cell + 6
      let y = oy + cars[i].y * cell + 6
      let w = if cars[i].horizontal { cars[i].len * cell - 12 } else { cell - 12 }
      let h = if cars[i].horizontal { cell - 12 } else { cars[i].len * cell - 12 }
      let c = color_for(cars[i].color)

      @raylib.draw_rectangle(x, y, w, h, c)
      @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(22, 22, 30, 180))

      let dot_x = if cars[i].horizontal { x + w - 20 } else { x + w / 2 }
      let dot_y = if cars[i].horizontal { y + h / 2 } else { y + h - 20 }
      @raylib.draw_circle(dot_x, dot_y, 6.0, @raylib.Color::new(244, 244, 248, 220))

      if i == selected {
        @raylib.draw_rectangle_lines(x - 3, y - 3, w + 6, h + 6, @raylib.Color::new(250, 236, 120, 255))
      }

      if cars[i].player {
        @raylib.draw_text("P", x + 10, y + 8, 28, @raylib.Color::new(252, 244, 240, 255))
      }
    }

    if transition_t > 0.0 {
      @raylib.draw_rectangle(ox, oy, gw * cell, gh * cell, @raylib.Color::new(20, 30, 48, 120))
      @raylib.draw_text("LEVEL CLEAR", ox + 146, oy + gh * cell / 2 - 24, 50, @raylib.Color::new(246, 236, 150, 255))
    }

    let ctl_x = 24
    let ctl_y = sh - 182
    @raylib.draw_rectangle(10, sh - 196, 166, 182, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text("Touch", 62, sh - 192, 20, @raylib.white)

    @raylib.draw_rectangle(ctl_x + 84, ctl_y, 76, 52, @raylib.Color::new(46, 64, 88, 255))
    @raylib.draw_text("UP", ctl_x + 108, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x, ctl_y + 58, 76, 52, @raylib.Color::new(46, 64, 88, 255))
    @raylib.draw_text("LEFT", ctl_x + 12, ctl_y + 74, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 84, ctl_y + 58, 76, 52, @raylib.Color::new(46, 64, 88, 255))
    @raylib.draw_text("RIGHT", ctl_x + 90, ctl_y + 74, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 84, ctl_y + 116, 76, 52, @raylib.Color::new(46, 64, 88, 255))
    @raylib.draw_text("DOWN", ctl_x + 90, ctl_y + 132, 20, @raylib.white)

    @raylib.draw_rectangle(188, sh - 54, sw - 206, 36, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text(msg, 198, sh - 48, 22, @raylib.Color::new(224, 236, 246, 255))

    @raylib.draw_text("Stars \{stars}", sw - 180, sh - 188, 30, @raylib.Color::new(250, 224, 132, 255))

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(sw / 2 - 300, sh / 2 - 94, 600, 188, @raylib.Color::new(16, 24, 40, 242))
      @raylib.draw_text(
        if won { "TRAFFIC MASTER" } else { "STUCK" },
        sw / 2 - 200,
        sh / 2 - 34,
        54,
        if won { @raylib.Color::new(248, 236, 142, 255) } else { @raylib.Color::new(250, 132, 132, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 40, 32, @raylib.Color::new(226, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
