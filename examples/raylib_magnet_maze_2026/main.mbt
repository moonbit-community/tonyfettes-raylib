///|
let sw : Int = 1220

///|
let sh : Int = 820

///|
let gw : Int = 14

///|
let gh : Int = 10

///|
let cell : Int = 64

///|
let ox : Int = 162

///|
let oy : Int = 104

///|
let max_orbs : Int = 4

///|
struct Orb {
  mut x : Int
  mut y : Int
  active : Bool
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * gw + x
}

///|
fn absi(x : Int) -> Int {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
fn signi(x : Int) -> Int {
  if x < 0 {
    -1
  } else if x > 0 {
    1
  } else {
    0
  }
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < gw && y >= 0 && y < gh
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
fn clear_walls(walls : Array[Bool]) -> Unit {
  for i = 0; i < walls.length(); i = i + 1 {
    walls[i] = false
  }
}

///|
fn clear_orbs(orbs : Array[Orb]) -> Unit {
  for i = 0; i < orbs.length(); i = i + 1 {
    orbs[i] = { x: 0, y: 0, active: false }
  }
}

///|
fn set_orb(orbs : Array[Orb], i : Int, x : Int, y : Int) -> Unit {
  orbs[i] = { x, y, active: true }
}

///|
fn set_goal(
  goals_x : Array[Int],
  goals_y : Array[Int],
  i : Int,
  x : Int,
  y : Int,
) -> Unit {
  goals_x[i] = x
  goals_y[i] = y
}

///|
fn is_wall(walls : Array[Bool], x : Int, y : Int) -> Bool {
  if not(in_bounds(x, y)) {
    true
  } else {
    walls[idx(x, y)]
  }
}

///|
fn orb_at(orbs : Array[Orb], skip : Int, x : Int, y : Int) -> Bool {
  let mut found = false
  for i = 0; i < orbs.length(); i = i + 1 {
    if i == skip || not(orbs[i].active) {
      continue
    }
    if orbs[i].x == x && orbs[i].y == y {
      found = true
    }
  }
  found
}

///|
fn goal_at(
  goals_x : Array[Int],
  goals_y : Array[Int],
  x : Int,
  y : Int,
) -> Bool {
  let mut found = false
  for i = 0; i < goals_x.length(); i = i + 1 {
    if goals_x[i] == x && goals_y[i] == y {
      found = true
    }
  }
  found
}

///|
fn goals_completed(
  orbs : Array[Orb],
  goals_x : Array[Int],
  goals_y : Array[Int],
) -> Int {
  let mut c = 0
  for i = 0; i < orbs.length(); i = i + 1 {
    if orbs[i].active && goal_at(goals_x, goals_y, orbs[i].x, orbs[i].y) {
      c = c + 1
    }
  }
  c
}

///|
fn all_orbs_on_goals(
  orbs : Array[Orb],
  goals_x : Array[Int],
  goals_y : Array[Int],
) -> Bool {
  goals_completed(orbs, goals_x, goals_y) == orbs.length()
}

///|
fn setup_level(
  level : Int,
  walls : Array[Bool],
  orbs : Array[Orb],
  goals_x : Array[Int],
  goals_y : Array[Int],
) -> (Int, Int, Int) {
  clear_walls(walls)
  clear_orbs(orbs)

  for x = 0; x < gw; x = x + 1 {
    walls[idx(x, 0)] = true
    walls[idx(x, gh - 1)] = true
  }
  for y = 0; y < gh; y = y + 1 {
    walls[idx(0, y)] = true
    walls[idx(gw - 1, y)] = true
  }

  if level == 1 {
    walls[idx(4, 2)] = true
    walls[idx(4, 3)] = true
    walls[idx(4, 4)] = true
    walls[idx(8, 5)] = true
    walls[idx(8, 6)] = true
    walls[idx(8, 7)] = true
    walls[idx(6, 3)] = true
    walls[idx(6, 6)] = true

    set_orb(orbs, 0, 3, 2)
    set_orb(orbs, 1, 10, 2)
    set_orb(orbs, 2, 3, 7)
    set_orb(orbs, 3, 10, 7)

    set_goal(goals_x, goals_y, 0, 6, 2)
    set_goal(goals_x, goals_y, 1, 7, 2)
    set_goal(goals_x, goals_y, 2, 6, 7)
    set_goal(goals_x, goals_y, 3, 7, 7)

    (2, 5, 30)
  } else if level == 2 {
    walls[idx(3, 2)] = true
    walls[idx(4, 2)] = true
    walls[idx(9, 2)] = true
    walls[idx(10, 2)] = true
    walls[idx(6, 3)] = true
    walls[idx(7, 3)] = true
    walls[idx(6, 6)] = true
    walls[idx(7, 6)] = true
    walls[idx(3, 7)] = true
    walls[idx(4, 7)] = true
    walls[idx(9, 7)] = true
    walls[idx(10, 7)] = true

    set_orb(orbs, 0, 2, 2)
    set_orb(orbs, 1, 11, 2)
    set_orb(orbs, 2, 2, 7)
    set_orb(orbs, 3, 11, 7)

    set_goal(goals_x, goals_y, 0, 5, 4)
    set_goal(goals_x, goals_y, 1, 8, 4)
    set_goal(goals_x, goals_y, 2, 5, 5)
    set_goal(goals_x, goals_y, 3, 8, 5)

    (6, 1, 34)
  } else {
    walls[idx(3, 2)] = true
    walls[idx(4, 2)] = true
    walls[idx(5, 2)] = true
    walls[idx(8, 2)] = true
    walls[idx(9, 2)] = true
    walls[idx(10, 2)] = true

    walls[idx(3, 7)] = true
    walls[idx(4, 7)] = true
    walls[idx(5, 7)] = true
    walls[idx(8, 7)] = true
    walls[idx(9, 7)] = true
    walls[idx(10, 7)] = true

    walls[idx(6, 4)] = true
    walls[idx(7, 4)] = true
    walls[idx(6, 5)] = true
    walls[idx(7, 5)] = true

    set_orb(orbs, 0, 2, 3)
    set_orb(orbs, 1, 11, 3)
    set_orb(orbs, 2, 2, 6)
    set_orb(orbs, 3, 11, 6)

    set_goal(goals_x, goals_y, 0, 5, 1)
    set_goal(goals_x, goals_y, 1, 8, 1)
    set_goal(goals_x, goals_y, 2, 5, 8)
    set_goal(goals_x, goals_y, 3, 8, 8)

    (6, 8, 38)
  }
}

///|
fn try_move_player(
  walls : Array[Bool],
  orbs : Array[Orb],
  px : Int,
  py : Int,
  dx : Int,
  dy : Int,
) -> (Int, Int, Bool) {
  let nx = px + dx
  let ny = py + dy
  if not(in_bounds(nx, ny)) ||
    is_wall(walls, nx, ny) ||
    orb_at(orbs, -1, nx, ny) {
    (px, py, false)
  } else {
    (nx, ny, true)
  }
}

///|
fn apply_pulse(
  orbs : Array[Orb],
  walls : Array[Bool],
  px : Int,
  py : Int,
  attract : Bool,
) -> Int {
  let mut moved = 0

  for i = 0; i < orbs.length(); i = i + 1 {
    if not(orbs[i].active) {
      continue
    }

    let dx = px - orbs[i].x
    let dy = py - orbs[i].y
    if dx == 0 && dy == 0 {
      continue
    }

    let adx = absi(dx)
    let ady = absi(dy)

    let mut sx = 0
    let mut sy = 0

    if adx >= ady {
      sx = signi(dx)
    } else {
      sy = signi(dy)
    }

    if not(attract) {
      sx = -sx
      sy = -sy
    }

    let nx = orbs[i].x + sx
    let ny = orbs[i].y + sy

    if in_bounds(nx, ny) &&
      not(is_wall(walls, nx, ny)) &&
      not(orb_at(orbs, i, nx, ny)) &&
      not(nx == px && ny == py) {
      orbs[i].x = nx
      orbs[i].y = ny
      moved = moved + 1
    }
  }

  moved
}

///|
fn main {
  @raylib.init_window(sw, sh, "Magnet Maze 2026")
  @raylib.set_target_fps(60)

  let walls : Array[Bool] = Array::make(gw * gh, false)
  let orbs : Array[Orb] = Array::makei(max_orbs, fn(_i) {
    { x: 0, y: 0, active: false }
  })
  let goals_x : Array[Int] = Array::make(max_orbs, 0)
  let goals_y : Array[Int] = Array::make(max_orbs, 0)

  let mut level = 1
  let mut px = 0
  let mut py = 0
  let mut turns_left = 0
  let (sx, sy, st) = setup_level(level, walls, orbs, goals_x, goals_y)
  px = sx
  py = sy
  turns_left = st

  let mut attract_mode = true
  let mut moves = 0
  let mut pulses = 0
  let mut score = 0
  let mut stars = 0

  let mut over = false
  let mut won = false
  let mut transition_t : Float = 0.0
  let mut msg = "Move with arrows/WASD, Space pulse, Tab toggles mode."

  while not(@raylib.window_should_close()) {
    let dt = @raylib.get_frame_time()

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rx, ry, rt) = setup_level(level, walls, orbs, goals_x, goals_y)
      px = rx
      py = ry
      turns_left = rt
      attract_mode = true
      moves = 0
      pulses = 0
      score = 0
      stars = 0
      over = false
      won = false
      transition_t = 0.0
      msg = "Maze reset."
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nx, ny, nt) = setup_level(level, walls, orbs, goals_x, goals_y)
          px = nx
          py = ny
          turns_left = nt
          attract_mode = true
          moves = 0
          pulses = 0
          msg = "Level \{level}."
        } else {
          over = true
          won = true
          msg = "All sectors solved."
        }
      }
    }

    if not(over) && transition_t <= 0.0 {
      if @raylib.is_key_pressed(@raylib.KeyTab) ||
        @raylib.is_key_pressed(@raylib.KeyT) {
        attract_mode = not(attract_mode)
        msg = if attract_mode { "Mode: ATTRACT" } else { "Mode: REPEL" }
      }

      let mut action = false
      let mut dx = 0
      let mut dy = 0
      let mut pulse = false

      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        dx = -1
        action = true
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        dx = 1
        action = true
      }
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        dy = -1
        action = true
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        dy = 1
        action = true
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeyJ) {
        pulse = true
        action = true
      }

      let m = @raylib.get_mouse_position()
      let ctl_x = 26
      let ctl_y = sh - 188
      let pulse_x = sw - 214
      let pulse_y = sh - 164
      let mode_x = sw - 214
      let mode_y = sh - 264

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x + 84, ctl_y, 76, 52) {
          dy = -1
          action = true
        } else if inside_rect(m.x, m.y, ctl_x, ctl_y + 58, 76, 52) {
          dx = -1
          action = true
        } else if inside_rect(m.x, m.y, ctl_x + 84, ctl_y + 58, 76, 52) {
          dx = 1
          action = true
        } else if inside_rect(m.x, m.y, ctl_x + 84, ctl_y + 116, 76, 52) {
          dy = 1
          action = true
        } else if inside_rect(m.x, m.y, pulse_x, pulse_y, 184, 126) {
          pulse = true
          action = true
        } else if inside_rect(m.x, m.y, mode_x, mode_y, 184, 88) {
          attract_mode = not(attract_mode)
          msg = if attract_mode { "Mode: ATTRACT" } else { "Mode: REPEL" }
        }
      }

      if action {
        let mut consumed_turn = false

        if pulse {
          let moved = apply_pulse(orbs, walls, px, py, attract_mode)
          pulses = pulses + 1
          consumed_turn = true
          msg = if moved > 0 {
            if attract_mode {
              "Pulse attract moved \{moved}."
            } else {
              "Pulse repel moved \{moved}."
            }
          } else {
            "Pulse had no effect."
          }
        } else {
          let (nx, ny, moved) = try_move_player(walls, orbs, px, py, dx, dy)
          px = nx
          py = ny
          if moved {
            moves = moves + 1
            consumed_turn = true
            msg = "Moved."
          } else {
            msg = "Blocked."
          }
        }

        if consumed_turn {
          turns_left = turns_left - 1

          if all_orbs_on_goals(orbs, goals_x, goals_y) {
            let mut bonus = turns_left * 12 + 150
            if bonus < 80 {
              bonus = 80
            }
            score = score + bonus

            if turns_left >= 10 {
              stars = stars + 3
            } else if turns_left >= 5 {
              stars = stars + 2
            } else {
              stars = stars + 1
            }

            transition_t = 1.0
            msg = "Level solved."
          } else if turns_left <= 0 {
            turns_left = 0
            over = true
            won = false
            msg = "No turns left. Press R to retry."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 18, 28, 255))

    @raylib.draw_rectangle(0, 0, sw, 104, @raylib.Color::new(8, 12, 20, 230))
    @raylib.draw_text(
      "MAGNET MAZE 2026",
      18,
      22,
      36,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @raylib.draw_text(
      "Level \{level}/3",
      420,
      34,
      30,
      @raylib.Color::new(246, 226, 134, 255),
    )
    @raylib.draw_text(
      "Turns \{turns_left}",
      604,
      34,
      30,
      @raylib.Color::new(218, 234, 250, 255),
    )
    @raylib.draw_text(
      "Goals \{goals_completed(orbs, goals_x, goals_y)}/\{max_orbs}",
      800,
      34,
      30,
      @raylib.Color::new(198, 228, 252, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      1050,
      34,
      30,
      @raylib.Color::new(198, 228, 252, 255),
    )

    @raylib.draw_rectangle(
      ox - 20,
      oy - 20,
      gw * cell + 40,
      gh * cell + 40,
      @raylib.Color::new(44, 54, 68, 255),
    )

    for y = 0; y < gh; y = y + 1 {
      for x = 0; x < gw; x = x + 1 {
        let px0 = ox + x * cell
        let py0 = oy + y * cell

        let c = if is_wall(walls, x, y) {
          @raylib.Color::new(54, 64, 82, 255)
        } else {
          @raylib.Color::new(30, 38, 52, 255)
        }

        @raylib.draw_rectangle(px0, py0, cell, cell, c)
        @raylib.draw_rectangle_lines(
          px0,
          py0,
          cell,
          cell,
          @raylib.Color::new(74, 88, 112, 180),
        )

        if goal_at(goals_x, goals_y, x, y) {
          @raylib.draw_circle(
            px0 + cell / 2,
            py0 + cell / 2,
            16.0,
            @raylib.Color::new(250, 228, 126, 255),
          )
          @raylib.draw_circle(
            px0 + cell / 2,
            py0 + cell / 2,
            8.0,
            @raylib.Color::new(134, 110, 42, 255),
          )
        }
      }
    }

    for i = 0; i < orbs.length(); i = i + 1 {
      if not(orbs[i].active) {
        continue
      }
      let x = ox + orbs[i].x * cell + cell / 2
      let y = oy + orbs[i].y * cell + cell / 2
      @raylib.draw_circle(x, y, 18.0, @raylib.Color::new(198, 214, 234, 255))
      @raylib.draw_circle(
        x - 5,
        y - 5,
        7.0,
        @raylib.Color::new(240, 246, 252, 255),
      )
      @raylib.draw_circle_lines(x, y, 18.0, @raylib.Color::new(46, 58, 78, 255))
    }

    let mx = ox + px * cell + cell / 2
    let my = oy + py * cell + cell / 2
    let magnet_color = if attract_mode {
      @raylib.Color::new(92, 220, 144, 255)
    } else {
      @raylib.Color::new(246, 112, 112, 255)
    }

    @raylib.draw_circle(mx, my, 20.0, magnet_color)
    @raylib.draw_rectangle(
      mx - 12,
      my - 6,
      24,
      12,
      @raylib.Color::new(22, 28, 36, 255),
    )
    @raylib.draw_rectangle_lines(mx - 14, my - 8, 28, 16, @raylib.white)

    if transition_t > 0.0 {
      @raylib.draw_rectangle(
        ox,
        oy,
        gw * cell,
        gh * cell,
        @raylib.Color::new(8, 14, 24, 140),
      )
      @raylib.draw_text(
        "SECTOR CLEAR",
        ox + 166,
        oy + gh * cell / 2 - 26,
        52,
        @raylib.Color::new(248, 236, 146, 255),
      )
    }

    let ctl_x = 26
    let ctl_y = sh - 188
    @raylib.draw_rectangle(
      10,
      sh - 202,
      166,
      186,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text("Touch", 62, sh - 198, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x + 84,
      ctl_y,
      76,
      52,
      @raylib.Color::new(46, 64, 88, 255),
    )
    @raylib.draw_text("UP", ctl_x + 108, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x,
      ctl_y + 58,
      76,
      52,
      @raylib.Color::new(46, 64, 88, 255),
    )
    @raylib.draw_text("LEFT", ctl_x + 10, ctl_y + 74, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 84,
      ctl_y + 58,
      76,
      52,
      @raylib.Color::new(46, 64, 88, 255),
    )
    @raylib.draw_text("RIGHT", ctl_x + 90, ctl_y + 74, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 84,
      ctl_y + 116,
      76,
      52,
      @raylib.Color::new(46, 64, 88, 255),
    )
    @raylib.draw_text("DOWN", ctl_x + 90, ctl_y + 132, 20, @raylib.white)

    let mode_x = sw - 214
    let mode_y = sh - 264
    let mode_color = if attract_mode {
      @raylib.Color::new(72, 136, 90, 255)
    } else {
      @raylib.Color::new(146, 72, 72, 255)
    }
    @raylib.draw_rectangle(mode_x, mode_y, 184, 88, mode_color)
    @raylib.draw_text(
      if attract_mode {
        "ATTRACT"
      } else {
        "REPEL"
      },
      mode_x + 34,
      mode_y + 28,
      30,
      @raylib.white,
    )

    let pulse_x = sw - 214
    let pulse_y = sh - 164
    @raylib.draw_rectangle(
      pulse_x,
      pulse_y,
      184,
      126,
      @raylib.Color::new(70, 102, 182, 255),
    )
    @raylib.draw_text("PULSE", pulse_x + 44, pulse_y + 46, 40, @raylib.white)

    @raylib.draw_rectangle(
      188,
      sh - 52,
      sw - 206,
      36,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text(
      msg,
      198,
      sh - 46,
      22,
      @raylib.Color::new(224, 236, 246, 255),
    )

    @raylib.draw_text(
      "Moves \{moves}  Pulses \{pulses}",
      26,
      114,
      24,
      @raylib.Color::new(212, 228, 246, 255),
    )
    @raylib.draw_text(
      "Stars \{stars}",
      26,
      144,
      24,
      @raylib.Color::new(250, 226, 130, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(
        sw / 2 - 320,
        sh / 2 - 96,
        640,
        192,
        @raylib.Color::new(16, 24, 40, 242),
      )
      @raylib.draw_text(
        if won {
          "MAGNET MASTER"
        } else {
          "NO CHARGES LEFT"
        },
        sw / 2 - 250,
        sh / 2 - 34,
        54,
        if won {
          @raylib.Color::new(248, 236, 142, 255)
        } else {
          @raylib.Color::new(250, 132, 132, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 40,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
