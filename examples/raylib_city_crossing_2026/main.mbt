///|
let sw : Int = 1200

///|
let sh : Int = 820

///|
let cols : Int = 11

///|
let rows : Int = 11

///|
let cell : Int = 56

///|
let ox : Int = 292

///|
let oy : Int = 120

///|
struct Car {
  mut x : Float
  row : Int
  w : Int
  speed : Float
  color : Int
}

///|
struct Log {
  mut x : Float
  row : Int
  w : Int
  speed : Float
}

///|
fn absf(x : Float) -> Float {
  if x < 0.0 {
    -x
  } else {
    x
  }
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn set_car(
  cars : Array[Car],
  i : Int,
  x : Float,
  row : Int,
  w : Int,
  speed : Float,
  color : Int,
) -> Unit {
  cars[i] = { x: x, row: row, w: w, speed: speed, color: color }
}

///|
fn set_log(logs : Array[Log], i : Int, x : Float, row : Int, w : Int, speed : Float) -> Unit {
  logs[i] = { x: x, row: row, w: w, speed: speed }
}

///|
fn reset_traffic(cars : Array[Car], logs : Array[Log]) -> Unit {
  set_log(logs, 0, Float::from_int(ox + 20), 1, 3, 88.0)
  set_log(logs, 1, Float::from_int(ox + 280), 1, 2, 88.0)
  set_log(logs, 2, Float::from_int(ox + 520), 1, 3, 88.0)

  set_log(logs, 3, Float::from_int(ox + 640), 2, 2, -106.0)
  set_log(logs, 4, Float::from_int(ox + 370), 2, 3, -106.0)
  set_log(logs, 5, Float::from_int(ox + 60), 2, 2, -106.0)

  set_log(logs, 6, Float::from_int(ox + 10), 3, 4, 124.0)
  set_log(logs, 7, Float::from_int(ox + 350), 3, 2, 124.0)
  set_log(logs, 8, Float::from_int(ox + 590), 3, 3, 124.0)

  set_car(cars, 0, Float::from_int(ox + 40), 5, 2, 160.0, 0)
  set_car(cars, 1, Float::from_int(ox + 280), 5, 2, 160.0, 1)
  set_car(cars, 2, Float::from_int(ox + 520), 5, 2, 160.0, 2)

  set_car(cars, 3, Float::from_int(ox + 120), 6, 1, -210.0, 1)
  set_car(cars, 4, Float::from_int(ox + 310), 6, 1, -210.0, 2)
  set_car(cars, 5, Float::from_int(ox + 500), 6, 1, -210.0, 0)
  set_car(cars, 6, Float::from_int(ox + 690), 6, 1, -210.0, 1)

  set_car(cars, 7, Float::from_int(ox + 30), 7, 3, 124.0, 2)
  set_car(cars, 8, Float::from_int(ox + 420), 7, 3, 124.0, 0)

  set_car(cars, 9, Float::from_int(ox + 80), 9, 2, -246.0, 0)
  set_car(cars, 10, Float::from_int(ox + 320), 9, 2, -246.0, 1)
  set_car(cars, 11, Float::from_int(ox + 560), 9, 2, -246.0, 2)
}

///|
fn reset_homes(homes : Array[Bool]) -> Unit {
  for i = 0; i < homes.length(); i = i + 1 {
    homes[i] = false
  }
}

///|
fn homes_done(homes : Array[Bool]) -> Bool {
  let mut ok = true
  for i = 0; i < homes.length(); i = i + 1 {
    if not(homes[i]) {
      ok = false
    }
  }
  ok
}

///|
fn slot_col(i : Int) -> Int {
  if i == 0 {
    1
  } else if i == 1 {
    3
  } else if i == 2 {
    5
  } else if i == 3 {
    7
  } else {
    9
  }
}

///|
fn slot_center_x(i : Int) -> Float {
  Float::from_int(ox + slot_col(i) * cell + cell / 2)
}

///|
fn row_from_y(y : Float) -> Int {
  ((y - Float::from_int(oy)).to_int()) / cell
}

///|
fn is_river_row(row : Int) -> Bool {
  row >= 1 && row <= 3
}

///|
fn is_road_row(row : Int) -> Bool {
  row == 5 || row == 6 || row == 7 || row == 9
}

///|
fn spawn_pos() -> (Float, Float) {
  (
    Float::from_int(ox + (cols / 2) * cell + cell / 2),
    Float::from_int(oy + (rows - 1) * cell + cell / 2),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "City Crossing 2026")
  @raylib.set_target_fps(60)

  let cars : Array[Car] = Array::makei(12, fn(_i) {
    { x: 0.0, row: 5, w: 1, speed: 0.0, color: 0 }
  })
  let logs : Array[Log] = Array::makei(9, fn(_i) {
    { x: 0.0, row: 1, w: 2, speed: 0.0 }
  })
  let homes : Array[Bool] = Array::make(5, false)

  reset_traffic(cars, logs)
  reset_homes(homes)

  let (sx, sy) = spawn_pos()
  let min_x = Float::from_int(ox + cell / 2)
  let max_x = Float::from_int(ox + (cols - 1) * cell + cell / 2)
  let min_y = Float::from_int(oy + cell / 2)
  let max_y = Float::from_int(oy + (rows - 1) * cell + cell / 2)

  let mut px = sx
  let mut py = sy
  let mut lives = 4
  let mut score = 0
  let mut level = 1
  let mut timer : Float = 55.0
  let mut over = false
  let mut msg = "Arrow/WASD move. Reach all home slots without crashing."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }
    let speed_mul : Float = Float::from_int(1) + Float::from_int(level - 1) * 0.18

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_traffic(cars, logs)
      reset_homes(homes)
      px = sx
      py = sy
      lives = 4
      score = 0
      level = 1
      timer = 55.0
      over = false
      msg = "Crossing restarted."
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 55.0
        lives = lives - 1
        if lives <= 0 {
          lives = 0
          over = true
          msg = "Time up. City traffic wins. Press R to restart."
        } else {
          px = sx
          py = sy
          msg = "Time up. Try another route."
        }
      }

      for i = 0; i < cars.length(); i = i + 1 {
        cars[i].x = cars[i].x + cars[i].speed * speed_mul * dt
        let wpx = Float::from_int(cars[i].w * cell)
        if cars[i].speed > 0.0 && cars[i].x > Float::from_int(ox + cols * cell) + wpx + 30.0 {
          cars[i].x = Float::from_int(ox) - wpx - 30.0
        }
        if cars[i].speed < 0.0 && cars[i].x < Float::from_int(ox) - wpx - 30.0 {
          cars[i].x = Float::from_int(ox + cols * cell) + 30.0
        }
      }

      for i = 0; i < logs.length(); i = i + 1 {
        logs[i].x = logs[i].x + logs[i].speed * speed_mul * dt
        let wpx = Float::from_int(logs[i].w * cell)
        if logs[i].speed > 0.0 && logs[i].x > Float::from_int(ox + cols * cell) + wpx + 34.0 {
          logs[i].x = Float::from_int(ox) - wpx - 34.0
        }
        if logs[i].speed < 0.0 && logs[i].x < Float::from_int(ox) - wpx - 34.0 {
          logs[i].x = Float::from_int(ox + cols * cell) + 34.0
        }
      }

      let mut dx = 0
      let mut dy = 0
      let mut moved = false

      if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        dx = -1
        moved = true
      }
      if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        dx = 1
        moved = true
      }
      if @raylib.is_key_pressed(@raylib.KeyW) || @raylib.is_key_pressed(@raylib.KeyUp) {
        dy = -1
        moved = true
      }
      if @raylib.is_key_pressed(@raylib.KeyS) || @raylib.is_key_pressed(@raylib.KeyDown) {
        dy = 1
        moved = true
      }

      let ctl_x = 38
      let ctl_y = sh - 192
      let m = @raylib.get_mouse_position()
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x + 72, ctl_y, 72, 52) {
          dy = -1
          moved = true
        } else if inside_rect(m.x, m.y, ctl_x + 72, ctl_y + 108, 72, 52) {
          dy = 1
          moved = true
        } else if inside_rect(m.x, m.y, ctl_x, ctl_y + 54, 72, 52) {
          dx = -1
          moved = true
        } else if inside_rect(m.x, m.y, ctl_x + 144, ctl_y + 54, 72, 52) {
          dx = 1
          moved = true
        }
      }

      if moved {
        px = clampf(px + Float::from_int(dx * cell), min_x, max_x)
        py = clampf(py + Float::from_int(dy * cell), min_y, max_y)

        if dy < 0 {
          score = score + 10
        } else if dy > 0 {
          score = score - 2
          if score < 0 {
            score = 0
          }
        }
      }

      let row = row_from_y(py)
      let mut dead = false

      if is_road_row(row) {
        for i = 0; i < cars.length(); i = i + 1 {
          if cars[i].row != row {
            continue
          }
          let left = cars[i].x
          let right = cars[i].x + Float::from_int(cars[i].w * cell)
          if px > left + 5.0 && px < right - 5.0 {
            dead = true
            msg = "Hit by traffic."
            break
          }
        }
      }

      if not(dead) && is_river_row(row) {
        let mut on_log = false
        let mut drift : Float = 0.0
        for i = 0; i < logs.length(); i = i + 1 {
          if logs[i].row != row {
            continue
          }
          let left = logs[i].x
          let right = logs[i].x + Float::from_int(logs[i].w * cell)
          if px > left + 6.0 && px < right - 6.0 {
            on_log = true
            drift = logs[i].speed * speed_mul * dt
            break
          }
        }
        if on_log {
          px = px + drift
          if px < min_x || px > max_x {
            dead = true
            msg = "Drifted into the current."
          }
        } else {
          dead = true
          msg = "Splash. Find a log next time."
        }
      }

      if not(dead) && row == 0 {
        let mut dock = -1
        for i = 0; i < homes.length(); i = i + 1 {
          if absf(px - slot_center_x(i)) <= Float::from_int(cell) * 0.38 {
            dock = i
            break
          }
        }

        if dock < 0 {
          dead = true
          msg = "Missed the dock."
        } else if homes[dock] {
          dead = true
          msg = "This home slot is already filled."
        } else {
          homes[dock] = true
          score = score + 220 + timer.to_int() * 2
          msg = "Home reached."
          px = sx
          py = sy
          timer = 55.0

          if homes_done(homes) {
            level = level + 1
            score = score + 600 + lives * 60
            reset_homes(homes)
            reset_traffic(cars, logs)
            msg = "Level \{level} begins. Traffic speeds up."
          }
        }
      }

      if dead {
        lives = lives - 1
        if lives <= 0 {
          lives = 0
          over = true
          msg = "No lives left. Press R to restart."
        } else {
          px = sx
          py = sy
          timer = 55.0
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 18, 24, 255))

    @raylib.draw_rectangle(0, 0, sw, 90, @raylib.Color::new(26, 32, 44, 255))
    @raylib.draw_text("City Crossing 2026", 24, 20, 34, @raylib.Color::new(234, 244, 248, 255))
    @raylib.draw_text("Lives: \{lives}   Score: \{score}   Level: \{level}   Time: \{timer.to_int()}", 392, 28, 30, @raylib.Color::new(236, 216, 120, 255))

    for row = 0; row < rows; row = row + 1 {
      let y = oy + row * cell
      if row == 0 {
        @raylib.draw_rectangle(ox, y, cols * cell, cell, @raylib.Color::new(30, 70, 40, 255))
      } else if is_river_row(row) {
        @raylib.draw_rectangle(ox, y, cols * cell, cell, @raylib.Color::new(24, 86, 146, 255))
      } else if is_road_row(row) {
        @raylib.draw_rectangle(ox, y, cols * cell, cell, @raylib.Color::new(58, 60, 68, 255))
      } else {
        @raylib.draw_rectangle(ox, y, cols * cell, cell, @raylib.Color::new(36, 98, 52, 255))
      }
    }

    for i = 0; i < homes.length(); i = i + 1 {
      let sx = (slot_center_x(i) - Float::from_int(cell / 2 - 6)).to_int()
      let sy = oy + 8
      let c = if homes[i] {
        @raylib.Color::new(236, 216, 82, 255)
      } else {
        @raylib.Color::new(48, 114, 62, 255)
      }
      @raylib.draw_rectangle(sx, sy, cell - 12, cell - 16, c)
      @raylib.draw_rectangle_lines(sx, sy, cell - 12, cell - 16, @raylib.Color::new(16, 34, 20, 255))
    }

    for i = 0; i <= cols; i = i + 1 {
      let x = ox + i * cell
      @raylib.draw_line(x, oy, x, oy + rows * cell, @raylib.Color::new(24, 30, 34, 180))
    }
    for i = 0; i <= rows; i = i + 1 {
      let y = oy + i * cell
      @raylib.draw_line(ox, y, ox + cols * cell, y, @raylib.Color::new(24, 30, 34, 180))
    }

    for i = 0; i < logs.length(); i = i + 1 {
      let x = logs[i].x.to_int()
      let y = oy + logs[i].row * cell + 10
      let w = logs[i].w * cell
      @raylib.draw_rectangle(x, y, w, cell - 20, @raylib.Color::new(120, 86, 42, 255))
      @raylib.draw_rectangle(x + 6, y + 6, w - 12, 7, @raylib.Color::new(160, 116, 66, 255))
      @raylib.draw_rectangle(x + 6, y + cell - 33, w - 12, 6, @raylib.Color::new(82, 58, 28, 255))
    }

    for i = 0; i < cars.length(); i = i + 1 {
      let x = cars[i].x.to_int()
      let y = oy + cars[i].row * cell + 8
      let w = cars[i].w * cell
      let car_c = if cars[i].color == 0 {
        @raylib.Color::new(236, 92, 84, 255)
      } else if cars[i].color == 1 {
        @raylib.Color::new(76, 180, 246, 255)
      } else {
        @raylib.Color::new(250, 192, 72, 255)
      }
      @raylib.draw_rectangle(x, y, w, cell - 16, car_c)
      @raylib.draw_rectangle(x + 8, y + 8, w - 16, cell - 32, @raylib.Color::new(24, 34, 52, 170))
      @raylib.draw_rectangle(x + 5, y + cell - 20, 11, 8, @raylib.Color::new(20, 20, 20, 255))
      @raylib.draw_rectangle(x + w - 16, y + cell - 20, 11, 8, @raylib.Color::new(20, 20, 20, 255))
    }

    @raylib.draw_circle(px.to_int(), py.to_int(), 18.0, @raylib.Color::new(84, 230, 94, 255))
    @raylib.draw_circle(px.to_int() - 7, py.to_int() - 7, 4.0, @raylib.white)
    @raylib.draw_circle(px.to_int() + 7, py.to_int() - 7, 4.0, @raylib.white)
    @raylib.draw_circle(px.to_int() - 7, py.to_int() - 7, 2.0, @raylib.black)
    @raylib.draw_circle(px.to_int() + 7, py.to_int() - 7, 2.0, @raylib.black)

    let ctl_x = 38
    let ctl_y = sh - 192
    @raylib.draw_rectangle(22, sh - 214, 236, 178, @raylib.Color::new(18, 26, 36, 220))
    @raylib.draw_text("Touch", 104, sh - 208, 22, @raylib.Color::new(220, 228, 238, 255))

    @raylib.draw_rectangle(ctl_x + 72, ctl_y, 72, 52, @raylib.Color::new(42, 56, 78, 255))
    @raylib.draw_text("UP", ctl_x + 93, ctl_y + 14, 22, @raylib.white)
    @raylib.draw_rectangle(ctl_x, ctl_y + 54, 72, 52, @raylib.Color::new(42, 56, 78, 255))
    @raylib.draw_text("LEFT", ctl_x + 10, ctl_y + 68, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 144, ctl_y + 54, 72, 52, @raylib.Color::new(42, 56, 78, 255))
    @raylib.draw_text("RIGHT", ctl_x + 149, ctl_y + 68, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 72, ctl_y + 108, 72, 52, @raylib.Color::new(42, 56, 78, 255))
    @raylib.draw_text("DOWN", ctl_x + 80, ctl_y + 122, 20, @raylib.white)

    @raylib.draw_rectangle(300, sh - 66, sw - 320, 42, @raylib.Color::new(12, 20, 30, 220))
    @raylib.draw_text(msg, 312, sh - 56, 24, @raylib.Color::new(230, 236, 245, 255))

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      @raylib.draw_rectangle(sw / 2 - 280, sh / 2 - 96, 560, 192, @raylib.Color::new(20, 30, 44, 240))
      @raylib.draw_text("City Crossing Over", sw / 2 - 170, sh / 2 - 48, 44, @raylib.Color::new(250, 228, 140, 255))
      @raylib.draw_text("Press R to restart", sw / 2 - 118, sh / 2 + 18, 30, @raylib.Color::new(224, 236, 248, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
