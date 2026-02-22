///|
let sw = 1366

///|
let sh = 768

///|
let cols = 10

///|
let rows = 7

///|
let board_x = 26

///|
let board_y = 90

///|
let cell_sz = 84

///|
let board_w : Int = cols * cell_sz

///|
let board_h : Int = rows * cell_sz

///|
let panel_x = 900

///|
let panel_w = 440

///|
let max_pulses = 340

///|
let max_cells : Int = cols * rows

///|
struct Cell {
  mut kind : Int // 0 empty, 1 straight, 2 corner, 3 tee, 4 cross, 5 source, 6 sink
  mut rot : Int
  mut health : Float
  mut fault_t : Float
  mut charge : Float
  mut demand : Int
  mut stored : Int
  mut pulse : Float
  mut label : String
}

///|
struct Pulse {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * cols + x
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < cols && y >= 0 && y < rows
}

///|
fn opposite(dir : Int) -> Int {
  if dir == 0 {
    2
  } else if dir == 1 {
    3
  } else if dir == 2 {
    0
  } else {
    1
  }
}

///|
fn dir_dx(dir : Int) -> Int {
  if dir == 0 {
    0
  } else if dir == 1 {
    1
  } else if dir == 2 {
    0
  } else {
    -1
  }
}

///|
fn dir_dy(dir : Int) -> Int {
  if dir == 0 {
    -1
  } else if dir == 1 {
    0
  } else if dir == 2 {
    1
  } else {
    0
  }
}

///|
fn cell_px(x : Int) -> Int {
  board_x + x * cell_sz
}

///|
fn cell_py(y : Int) -> Int {
  board_y + y * cell_sz
}

///|
fn cell_cx(x : Int) -> Float {
  Float::from_int(cell_px(x) + cell_sz / 2)
}

///|
fn cell_cy(y : Int) -> Float {
  Float::from_int(cell_py(y) + cell_sz / 2)
}

///|
fn board_contains(px : Float, py : Float) -> Bool {
  px >= Float::from_int(board_x) &&
  px < Float::from_int(board_x + board_w) &&
  py >= Float::from_int(board_y) &&
  py < Float::from_int(board_y + board_h)
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn pick_cell(px : Float, py : Float) -> Int {
  if not(board_contains(px, py)) {
    return -1
  }

  let gx : Int = ((px - Float::from_int(board_x)) / Float::from_int(cell_sz)).to_int()
  let gy : Int = ((py - Float::from_int(board_y)) / Float::from_int(cell_sz)).to_int()

  if in_bounds(gx, gy) {
    idx(gx, gy)
  } else {
    -1
  }
}

///|
fn wire_name(kind : Int) -> String {
  if kind == 1 {
    "STRAIGHT"
  } else if kind == 2 {
    "CORNER"
  } else if kind == 3 {
    "TEE"
  } else if kind == 4 {
    "CROSS"
  } else if kind == 5 {
    "SOURCE"
  } else if kind == 6 {
    "SINK"
  } else {
    "VOID"
  }
}

///|
fn rand_wire_kind() -> Int {
  let r : Int = @raylib.get_random_value(0, 99)
  if r < 34 {
    1
  } else if r < 62 {
    2
  } else if r < 84 {
    3
  } else {
    4
  }
}

///|
fn has_port(kind : Int, rot : Int, dir : Int) -> Bool {
  if kind == 0 {
    false
  } else if kind == 1 {
    // straight
    if rot % 2 == 0 {
      dir == 0 || dir == 2
    } else {
      dir == 1 || dir == 3
    }
  } else if kind == 2 {
    // corner
    let r : Int = (rot % 4 + 4) % 4
    if r == 0 {
      dir == 0 || dir == 1
    } else if r == 1 {
      dir == 1 || dir == 2
    } else if r == 2 {
      dir == 2 || dir == 3
    } else {
      dir == 3 || dir == 0
    }
  } else if kind == 3 {
    // tee
    let r : Int = (rot % 4 + 4) % 4
    if r == 0 {
      dir != 2
    } else if r == 1 {
      dir != 3
    } else if r == 2 {
      dir != 0
    } else {
      dir != 1
    }
  } else {
    // cross + source + sink use all directions for flow compatibility
    true
  }
}

///|
fn clear_pulses(ps : Array[Pulse]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].life = 0.0
    ps[i].size = 0.0
    ps[i].kind = 0
  }
}

///|
fn add_pulse(ps : Array[Pulse], x : Float, y : Float, kind : Int) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(40.0, 210.0)
      ps[i].vx = @math.cosf(a) * s
      ps[i].vy = @math.sinf(a) * s
      ps[i].life = randf(0.2, 0.8)
      ps[i].size = randf(2.0, 8.0)
      ps[i].kind = kind
      return
    }
  }
}

///|
fn burst_pulses(
  ps : Array[Pulse],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_pulse(ps, x, y, kind)
  }
}

///|
fn update_pulses(ps : Array[Pulse], dt : Float) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    if not(ps[i].active) {
      continue
    }

    ps[i].life = ps[i].life - dt
    if ps[i].life <= 0.0 {
      ps[i].active = false
      continue
    }

    ps[i].x = ps[i].x + ps[i].vx * dt
    ps[i].y = ps[i].y + ps[i].vy * dt
    ps[i].vx = ps[i].vx * (1.0 - dt * 2.2)
    ps[i].vy = ps[i].vy * (1.0 - dt * 2.0) + 12.0 * dt
  }
}

///|
fn draw_pulses(ps : Array[Pulse]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    if not(ps[i].active) {
      continue
    }

    let c = if ps[i].kind == 0 {
      @raylib.Color::new(248, 238, 136, 240)
    } else if ps[i].kind == 1 {
      @raylib.Color::new(128, 210, 250, 240)
    } else if ps[i].kind == 2 {
      @raylib.Color::new(128, 240, 160, 240)
    } else {
      @raylib.Color::new(250, 130, 146, 240)
    }

    @raylib.draw_circle(
      ps[i].x.to_int(),
      ps[i].y.to_int(),
      ps[i].size * ps[i].life * 2.0,
      c,
    )
  }
}

///|
fn clear_grid(cells : Array[Cell]) -> Unit {
  for i = 0; i < cells.length(); i = i + 1 {
    cells[i].kind = 0
    cells[i].rot = 0
    cells[i].health = 100.0
    cells[i].fault_t = 0.0
    cells[i].charge = 0.0
    cells[i].demand = 0
    cells[i].stored = 0
    cells[i].pulse = 0.0
    cells[i].label = ""
  }
}

///|
fn setup_grid(cells : Array[Cell]) -> Unit {
  clear_grid(cells)

  for y = 0; y < rows; y = y + 1 {
    for x = 0; x < cols; x = x + 1 {
      let i : Int = idx(x, y)
      cells[i].kind = rand_wire_kind()
      cells[i].rot = @raylib.get_random_value(0, 3)
      cells[i].health = randf(84.0, 100.0)
      cells[i].fault_t = 0.0
      cells[i].charge = 0.0
      cells[i].demand = 0
      cells[i].stored = 0
      cells[i].pulse = randf(0.0, 10.0)
      cells[i].label = ""
    }
  }

  // sources on left edge
  let src_ys : Array[Int] = [1, 3, 5]
  for i = 0; i < src_ys.length(); i = i + 1 {
    let y : Int = src_ys[i]
    let id : Int = idx(0, y)
    cells[id].kind = 5
    cells[id].rot = 1
    cells[id].health = 100.0
    cells[id].label = "SRC\{i + 1}"
    cells[id].fault_t = 0.0
  }

  // sinks on right edge
  let sink_ys : Array[Int] = [1, 3, 5]
  for i = 0; i < sink_ys.length(); i = i + 1 {
    let y : Int = sink_ys[i]
    let id : Int = idx(cols - 1, y)
    cells[id].kind = 6
    cells[id].rot = 3
    cells[id].health = 100.0
    cells[id].demand = 4 + i
    cells[id].stored = 0
    cells[id].label = "SNK\{i + 1}"
    cells[id].fault_t = 0.0
  }

  // fixed hubs
  let hub_xy : Array[(Int, Int)] = [
    (2, 2),
    (4, 1),
    (5, 3),
    (3, 5),
    (7, 2),
    (7, 4),
  ]
  for i = 0; i < hub_xy.length(); i = i + 1 {
    let (hx, hy) = hub_xy[i]
    let id : Int = idx(hx, hy)
    cells[id].kind = 4
    cells[id].rot = 0
    cells[id].health = 100.0
  }

  // a few void spots force rerouting puzzles
  let void_xy : Array[(Int, Int)] = [
    (1, 0),
    (2, 6),
    (6, 0),
    (8, 6),
    (4, 6),
    (1, 6),
  ]
  for i = 0; i < void_xy.length(); i = i + 1 {
    let (vx, vy) = void_xy[i]
    let id : Int = idx(vx, vy)
    cells[id].kind = 0
    cells[id].rot = 0
    cells[id].health = 0.0
  }
}

///|
fn reroll_row(cells : Array[Cell], y : Int) -> Unit {
  for x = 1; x < cols - 1; x = x + 1 {
    let id : Int = idx(x, y)
    if cells[id].kind == 0 || cells[id].kind == 5 || cells[id].kind == 6 {
      continue
    }
    cells[id].kind = rand_wire_kind()
    cells[id].rot = @raylib.get_random_value(0, 3)
    cells[id].fault_t = 0.0
    cells[id].charge = 0.0
    cells[id].pulse = randf(0.0, 8.0)
  }
}

///|
fn count_faults(cells : Array[Cell]) -> Int {
  let mut n : Int = 0
  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i].kind != 0 && cells[i].fault_t > 0.0 {
      n = n + 1
    }
  }
  n
}

///|
fn patch_faults(cells : Array[Cell], amount : Float) -> Int {
  let mut patched : Int = 0
  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i].fault_t > 0.0 {
      cells[i].fault_t = cells[i].fault_t - amount
      if cells[i].fault_t < 0.0 {
        cells[i].fault_t = 0.0
      }
      cells[i].health = clampf(cells[i].health + amount * 2.0, 0.0, 100.0)
      patched = patched + 1
    }
  }
  patched
}

///|
fn induce_faults(cells : Array[Cell], count : Int, tier : Int) -> Int {
  let mut made : Int = 0
  let mut tries : Int = 0

  while made < count && tries < 800 {
    tries = tries + 1
    let i : Int = @raylib.get_random_value(0, cells.length() - 1)
    if cells[i].kind <= 0 || cells[i].kind == 5 {
      continue
    }
    if cells[i].fault_t > 0.0 {
      continue
    }

    cells[i].fault_t = randf(4.5, 9.0) + Float::from_int(tier) * 0.35
    let damage : Float = randf(6.0, 14.0)
    cells[i].health = cells[i].health - damage
    if cells[i].health < 15.0 {
      cells[i].health = 15.0
    }
    made = made + 1
  }

  made
}

///|
fn degrade_faults(cells : Array[Cell], dt : Float) -> Unit {
  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i].kind == 0 {
      continue
    }

    cells[i].pulse = cells[i].pulse + dt
    if cells[i].pulse > 1000.0 {
      cells[i].pulse = cells[i].pulse - 1000.0
    }

    if cells[i].fault_t > 0.0 {
      cells[i].fault_t = cells[i].fault_t - dt
      if cells[i].fault_t < 0.0 {
        cells[i].fault_t = 0.0
      }
      cells[i].health = cells[i].health - dt * 0.45
      if cells[i].health < 0.0 {
        cells[i].health = 0.0
      }
    } else {
      cells[i].health = clampf(cells[i].health + dt * 0.09, 0.0, 100.0)
    }

    cells[i].charge = cells[i].charge * (1.0 - dt * 1.8)
    if cells[i].charge < 0.0 {
      cells[i].charge = 0.0
    }
  }
}

///|
fn run_network_step(
  cells : Array[Cell],
  q : Array[Int],
  seen : Array[Int],
  seen_mark : Int,
  tier : Int,
  overclock_t : Float,
) -> (Int, Int, Int) {
  let mut head : Int = 0
  let mut tail : Int = 0

  let src_boost : Float = if overclock_t > 0.0 { 1.55 } else { 1.0 }

  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i].kind == 5 && cells[i].fault_t <= 0.0 {
      seen[i] = seen_mark
      q[tail] = i
      tail = tail + 1
      cells[i].charge = 1.0 * src_boost
    }
  }

  while head < tail {
    let cur : Int = q[head]
    head = head + 1

    if cells[cur].kind == 0 || cells[cur].fault_t > 0.0 {
      continue
    }

    let cx : Int = cur % cols
    let cy : Int = cur / cols
    let cur_charge : Float = cells[cur].charge

    for dir = 0; dir < 4; dir = dir + 1 {
      if not(has_port(cells[cur].kind, cells[cur].rot, dir)) {
        continue
      }

      let nx : Int = cx + dir_dx(dir)
      let ny : Int = cy + dir_dy(dir)
      if not(in_bounds(nx, ny)) {
        continue
      }

      let ni : Int = idx(nx, ny)
      if cells[ni].kind == 0 || cells[ni].fault_t > 0.0 {
        continue
      }

      if not(has_port(cells[ni].kind, cells[ni].rot, opposite(dir))) {
        continue
      }

      let ncharge : Float = cur_charge * 0.9
      if ncharge > cells[ni].charge + 0.02 {
        cells[ni].charge = ncharge
      }

      if seen[ni] != seen_mark {
        seen[ni] = seen_mark
        q[tail] = ni
        tail = tail + 1
      }
    }
  }

  let mut gain : Int = 0
  let mut miss : Int = 0
  let mut powered_sinks : Int = 0

  for i = 0; i < cells.length(); i = i + 1 {
    if cells[i].kind != 6 {
      continue
    }

    let need : Int = clampi(cells[i].demand + tier / 2, 1, 30)

    if cells[i].fault_t > 0.0 {
      miss = miss + need
      continue
    }

    if cells[i].charge > 0.25 {
      powered_sinks = powered_sinks + 1
      let delivered : Int = clampi(
        (cells[i].charge * Float::from_int(need)).to_int(),
        1,
        need + 3,
      )
      cells[i].stored = cells[i].stored + delivered
      gain = gain + delivered

      let threshold : Int = 60 + tier * 10
      while cells[i].stored >= threshold {
        cells[i].stored = cells[i].stored - threshold
        cells[i].demand = cells[i].demand + 1
        if cells[i].demand > 16 {
          cells[i].demand = 16
        }
      }
    } else {
      miss = miss + need
    }
  }

  (gain, miss, powered_sinks)
}

///|
fn draw_port_glyph(
  kind : Int,
  cx : Float,
  cy : Float,
  r : Float,
  col : @raylib.Color,
) -> Unit {
  if kind == 5 {
    @raylib.draw_circle(cx.to_int(), cy.to_int(), r + 2.0, col)
    @raylib.draw_circle(
      cx.to_int(),
      cy.to_int(),
      r - 6.0,
      @raylib.Color::new(24, 30, 42, 240),
    )
    @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, col)
  } else if kind == 6 {
    @raylib.draw_rectangle(
      (cx - r + 2.0).to_int(),
      (cy - r + 2.0).to_int(),
      (r * 2.0 - 4.0).to_int(),
      (r * 2.0 - 4.0).to_int(),
      col,
    )
    @raylib.draw_rectangle(
      (cx - r + 8.0).to_int(),
      (cy - r + 8.0).to_int(),
      (r * 2.0 - 16.0).to_int(),
      (r * 2.0 - 16.0).to_int(),
      @raylib.Color::new(24, 30, 42, 240),
    )
  }
}

///|
fn draw_cell_wires(
  kind : Int,
  rot : Int,
  gx : Int,
  gy : Int,
  charged : Bool,
) -> Unit {
  let cx : Float = Float::from_int(gx + cell_sz / 2)
  let cy : Float = Float::from_int(gy + cell_sz / 2)
  let seg : Float = Float::from_int(cell_sz / 2 - 10)

  let wire_col = if charged {
    @raylib.Color::new(248, 232, 142, 250)
  } else {
    @raylib.Color::new(166, 190, 232, 236)
  }

  for dir = 0; dir < 4; dir = dir + 1 {
    if not(has_port(kind, rot, dir)) {
      continue
    }

    let tx : Float = cx + Float::from_int(dir_dx(dir)) * seg
    let ty : Float = cy + Float::from_int(dir_dy(dir)) * seg
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(tx, ty),
      9.0,
      wire_col,
    )
  }

  @raylib.draw_circle(cx.to_int(), cy.to_int(), 10.0, wire_col)
}

///|
fn draw_board(
  cells : Array[Cell],
  selected : Int,
  hover : Int,
  grid_t : Float,
) -> Unit {
  @raylib.draw_rectangle(
    board_x - 10,
    board_y - 10,
    board_w + 20,
    board_h + 20,
    @raylib.Color::new(16, 22, 36, 230),
  )
  @raylib.draw_rectangle_lines(
    board_x - 10,
    board_y - 10,
    board_w + 20,
    board_h + 20,
    @raylib.Color::new(170, 194, 238, 238),
  )

  for y = 0; y < rows; y = y + 1 {
    for x = 0; x < cols; x = x + 1 {
      let i : Int = idx(x, y)
      let gx : Int = cell_px(x)
      let gy : Int = cell_py(y)

      let mut base = if cells[i].kind == 0 {
        @raylib.Color::new(24, 28, 42, 230)
      } else if cells[i].kind == 5 {
        @raylib.Color::new(56, 126, 210, 234)
      } else if cells[i].kind == 6 {
        @raylib.Color::new(54, 168, 114, 234)
      } else {
        @raylib.Color::new(48, 58, 84, 236)
      }

      if cells[i].charge > 0.05 {
        let glow : Int = clampi((cells[i].charge * 120.0).to_int(), 0, 130)
        base = @raylib.Color::new(
          clampi(48 + glow / 4, 0, 255),
          clampi(58 + glow / 3, 0, 255),
          clampi(84 + glow / 2, 0, 255),
          240,
        )
      }

      if cells[i].fault_t > 0.0 {
        let flash : Float = @math.sinf(grid_t * 14.0 + Float::from_int(i) * 0.8) *
          0.5 +
          0.5
        let r : Int = 160 + (flash * 70.0).to_int()
        base = @raylib.Color::new(r, 52, 66, 238)
      }

      @raylib.draw_rectangle(gx + 1, gy + 1, cell_sz - 2, cell_sz - 2, base)

      let line_col = if selected == i {
        @raylib.Color::new(252, 242, 156, 252)
      } else if hover == i {
        @raylib.Color::new(208, 228, 252, 246)
      } else {
        @raylib.Color::new(126, 150, 198, 206)
      }
      @raylib.draw_rectangle_lines(
        gx + 1,
        gy + 1,
        cell_sz - 2,
        cell_sz - 2,
        line_col,
      )

      if cells[i].kind > 0 {
        draw_cell_wires(
          cells[i].kind,
          cells[i].rot,
          gx,
          gy,
          cells[i].charge > 0.2,
        )
      }

      let cx : Float = Float::from_int(gx + cell_sz / 2)
      let cy : Float = Float::from_int(gy + cell_sz / 2)

      if cells[i].kind == 5 || cells[i].kind == 6 {
        draw_port_glyph(
          cells[i].kind,
          cx,
          cy,
          18.0,
          @raylib.Color::new(242, 246, 255, 248),
        )
      }

      if cells[i].fault_t > 0.0 {
        @raylib.draw_line(
          gx + 10,
          gy + 10,
          gx + cell_sz - 10,
          gy + cell_sz - 10,
          @raylib.Color::new(252, 220, 224, 250),
        )
        @raylib.draw_line(
          gx + cell_sz - 10,
          gy + 10,
          gx + 10,
          gy + cell_sz - 10,
          @raylib.Color::new(252, 220, 224, 250),
        )
      }

      if cells[i].kind == 6 {
        @raylib.draw_text(
          "D\{cells[i].demand}",
          gx + 6,
          gy + 6,
          20,
          @raylib.Color::new(236, 252, 236, 246),
        )
        @raylib.draw_text(
          "S\{cells[i].stored}",
          gx + 6,
          gy + 28,
          18,
          @raylib.Color::new(198, 236, 214, 244),
        )
      }

      if cells[i].kind == 5 {
        @raylib.draw_text(
          cells[i].label,
          gx + 7,
          gy + 8,
          17,
          @raylib.Color::new(228, 238, 252, 246),
        )
      }

      if cells[i].kind > 0 && cells[i].kind < 5 {
        @raylib.draw_text(
          "\{cells[i].rot}",
          gx + cell_sz - 18,
          gy + 6,
          18,
          @raylib.Color::new(198, 214, 244, 236),
        )
      }

      let hpw : Int = (cells[i].health * Float::from_int(cell_sz - 8) / 100.0).to_int()
      @raylib.draw_rectangle(
        gx + 4,
        gy + cell_sz - 10,
        cell_sz - 8,
        6,
        @raylib.Color::new(24, 30, 44, 230),
      )
      let hp_col = if cells[i].health > 70.0 {
        @raylib.Color::new(132, 232, 166, 236)
      } else if cells[i].health > 35.0 {
        @raylib.Color::new(246, 220, 126, 236)
      } else {
        @raylib.Color::new(244, 126, 138, 236)
      }
      @raylib.draw_rectangle(gx + 4, gy + cell_sz - 10, hpw, 6, hp_col)
    }
  }
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  enabled : Bool,
  hover : Bool,
) -> Unit {
  let fill = if not(enabled) {
    @raylib.Color::new(64, 72, 92, 210)
  } else if hover {
    @raylib.Color::new(114, 162, 238, 246)
  } else {
    @raylib.Color::new(88, 126, 204, 236)
  }

  @raylib.draw_rectangle(x, y, w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(216, 230, 252, 246),
  )

  let tw : Int = @raylib.measure_text(label, 24)
  @raylib.draw_text(
    label,
    x + (w - tw) / 2,
    y + h / 2 - 12,
    24,
    @raylib.Color::new(244, 248, 255, 252),
  )
}

///|
fn draw_panel(
  timer : Float,
  stability : Float,
  budget : Int,
  delivered : Int,
  goal : Int,
  tier : Int,
  faults : Int,
  overclock_t : Float,
  selected : Int,
  cells : Array[Cell],
  net_rate : Int,
  storm_cd : Float,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    14,
    panel_w,
    740,
    @raylib.Color::new(16, 22, 34, 246),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    14,
    panel_w,
    740,
    @raylib.Color::new(170, 194, 238, 242),
  )

  @raylib.draw_text(
    "CIRCUIT GRID OPERATOR",
    panel_x + 16,
    34,
    36,
    @raylib.Color::new(238, 246, 255, 252),
  )
  @raylib.draw_text(
    "Rotate nodes. Route charge. Survive cascading faults.",
    panel_x + 16,
    76,
    20,
    @raylib.Color::new(190, 214, 252, 236),
  )

  @raylib.draw_text(
    "Time",
    panel_x + 16,
    120,
    24,
    @raylib.Color::new(220, 232, 252, 246),
  )
  @raylib.draw_text(
    "\{timer.to_int()}s",
    panel_x + 116,
    120,
    30,
    @raylib.Color::new(248, 232, 150, 252),
  )

  @raylib.draw_text(
    "Budget",
    panel_x + 240,
    120,
    24,
    @raylib.Color::new(220, 232, 252, 246),
  )
  @raylib.draw_text(
    "$\{budget}",
    panel_x + 346,
    120,
    30,
    @raylib.Color::new(134, 232, 160, 252),
  )

  @raylib.draw_text(
    "Delivered",
    panel_x + 16,
    158,
    24,
    @raylib.Color::new(220, 232, 252, 246),
  )
  @raylib.draw_text(
    "\{delivered}/\{goal}",
    panel_x + 150,
    158,
    30,
    @raylib.Color::new(134, 212, 250, 252),
  )

  @raylib.draw_text(
    "Tier",
    panel_x + 280,
    158,
    24,
    @raylib.Color::new(220, 232, 252, 246),
  )
  @raylib.draw_text(
    "\{tier}",
    panel_x + 346,
    158,
    30,
    @raylib.Color::new(246, 214, 130, 252),
  )

  let st01 : Float = clampf(stability / 100.0, 0.0, 1.0)
  let stw : Int = (Float::from_int(392) * st01).to_int()
  @raylib.draw_rectangle(
    panel_x + 16,
    202,
    392,
    20,
    @raylib.Color::new(24, 30, 46, 255),
  )
  let scol = if stability > 60.0 {
    @raylib.Color::new(134, 232, 160, 250)
  } else if stability > 30.0 {
    @raylib.Color::new(244, 214, 126, 250)
  } else {
    @raylib.Color::new(244, 122, 138, 250)
  }
  @raylib.draw_rectangle(panel_x + 16, 202, stw, 20, scol)
  @raylib.draw_rectangle_lines(
    panel_x + 16,
    202,
    392,
    20,
    @raylib.Color::new(182, 202, 238, 248),
  )
  @raylib.draw_text(
    "Stability \{stability.to_int()}%",
    panel_x + 16,
    228,
    22,
    @raylib.Color::new(224, 236, 252, 246),
  )

  @raylib.draw_text(
    "Faults \{faults}",
    panel_x + 16,
    258,
    22,
    @raylib.Color::new(236, 204, 212, 246),
  )
  @raylib.draw_text(
    "Flow \{net_rate}/tick",
    panel_x + 170,
    258,
    22,
    @raylib.Color::new(196, 226, 252, 246),
  )
  @raylib.draw_text(
    "Fault ETA \{storm_cd.to_int()}s",
    panel_x + 316,
    258,
    22,
    @raylib.Color::new(214, 224, 248, 246),
  )

  if overclock_t > 0.0 {
    @raylib.draw_text(
      "OVERCLOCK ACTIVE \{overclock_t.to_int()}s",
      panel_x + 16,
      286,
      24,
      @raylib.Color::new(252, 226, 142, 252),
    )
  } else {
    @raylib.draw_text(
      "Overclock offline",
      panel_x + 16,
      286,
      22,
      @raylib.Color::new(182, 204, 242, 236),
    )
  }

  @raylib.draw_rectangle(
    panel_x + 16,
    330,
    392,
    190,
    @raylib.Color::new(22, 30, 48, 228),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 16,
    330,
    392,
    190,
    @raylib.Color::new(160, 184, 228, 236),
  )
  @raylib.draw_text(
    "Selection",
    panel_x + 28,
    344,
    28,
    @raylib.Color::new(234, 244, 255, 252),
  )

  if selected >= 0 && selected < cells.length() {
    @raylib.draw_text(
      "Type: \{wire_name(cells[selected].kind)}",
      panel_x + 28,
      384,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "Rotation: \{cells[selected].rot}",
      panel_x + 28,
      416,
      24,
      @raylib.Color::new(214, 230, 252, 246),
    )
    @raylib.draw_text(
      "Health: \{cells[selected].health.to_int()}%",
      panel_x + 28,
      448,
      24,
      @raylib.Color::new(214, 230, 252, 246),
    )
    @raylib.draw_text(
      "Charge: \{(cells[selected].charge * 100.0).to_int()}%",
      panel_x + 220,
      448,
      24,
      @raylib.Color::new(244, 232, 150, 246),
    )
    if cells[selected].kind == 6 {
      @raylib.draw_text(
        "Demand: \{cells[selected].demand}",
        panel_x + 28,
        480,
        24,
        @raylib.Color::new(192, 238, 208, 246),
      )
      @raylib.draw_text(
        "Stored: \{cells[selected].stored}",
        panel_x + 220,
        480,
        24,
        @raylib.Color::new(192, 238, 208, 246),
      )
    } else if cells[selected].kind == 5 {
      @raylib.draw_text(
        "Source node",
        panel_x + 28,
        480,
        24,
        @raylib.Color::new(194, 228, 252, 246),
      )
    }

    if cells[selected].fault_t > 0.0 {
      @raylib.draw_text(
        "Fault time: \{cells[selected].fault_t.to_int()}s",
        panel_x + 28,
        508,
        22,
        @raylib.Color::new(252, 198, 208, 246),
      )
    }
  } else {
    @raylib.draw_text(
      "Tap a tile to inspect and rotate.",
      panel_x + 28,
      386,
      24,
      @raylib.Color::new(212, 228, 252, 246),
    )
  }

  @raylib.draw_text(
    "Mobile",
    panel_x + 16,
    676,
    24,
    @raylib.Color::new(230, 240, 255, 248),
  )
  @raylib.draw_text(
    "Tap tiles + action buttons.",
    panel_x + 100,
    676,
    22,
    @raylib.Color::new(198, 220, 252, 238),
  )
  @raylib.draw_text(
    "No keyboard required.",
    panel_x + 16,
    706,
    22,
    @raylib.Color::new(198, 220, 252, 238),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] circuit grid operator 2026")
  @raylib.set_target_fps(60)

  let cells : Array[Cell] = Array::makei(max_cells, fn(_i) {
    {
      kind: 0,
      rot: 0,
      health: 0.0,
      fault_t: 0.0,
      charge: 0.0,
      demand: 0,
      stored: 0,
      pulse: 0.0,
      label: "",
    }
  })

  let pulses : Array[Pulse] = Array::makei(max_pulses, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  let queue : Array[Int] = Array::make(max_cells, 0)
  let seen : Array[Int] = Array::make(max_cells, 0)

  let mut state : Int = 0 // 0 menu, 1 play, 2 win, 3 lose
  let mut timer : Float = 240.0
  let mut stability : Float = 100.0
  let mut budget : Int = 124
  let mut delivered : Int = 0
  let mut goal : Int = 560
  let mut tier : Int = 1

  let mut selected : Int = -1
  let mut hover : Int = -1

  let mut step_cd : Float = 0.42
  let mut fault_cd : Float = 6.0
  let mut overclock_t : Float = 0.0
  let mut seen_mark : Int = 1

  let mut net_rate : Int = 0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  fn reset_run() -> Unit {
    setup_grid(cells)
    clear_pulses(pulses)

    timer = 240.0
    stability = 100.0
    budget = 124
    delivered = 0
    goal = 560
    tier = 1

    selected = -1
    hover = -1

    step_cd = 0.42
    fault_cd = 6.0
    overclock_t = 0.0
    seen_mark = 1
    net_rate = 0

    msg = "Grid initialized"
    msg_t = 2.0
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    hover = pick_cell(mouse.x, mouse.y)

    scene_t = scene_t + dt
    while scene_t > 10000.0 {
      scene_t = scene_t - 10000.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    update_pulses(pulses, dt)

    if state == 0 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      tier = 1 + delivered / 90
      if tier > 8 {
        tier = 8
      }

      degrade_faults(cells, dt)

      if overclock_t > 0.0 {
        overclock_t = overclock_t - dt
        if overclock_t < 0.0 {
          overclock_t = 0.0
          msg = "Overclock ended"
          msg_t = 0.9
        }
      }

      fault_cd = fault_cd - dt
      if fault_cd <= 0.0 {
        let n : Int = 1 + @raylib.get_random_value(0, tier / 2)
        let made : Int = induce_faults(cells, n, tier)
        if made > 0 {
          msg = "Fault event: \{made} nodes"
          msg_t = 1.2
          for i = 0; i < cells.length(); i = i + 1 {
            if cells[i].fault_t > 0.0 {
              let x : Int = i % cols
              let y : Int = i / cols
              burst_pulses(pulses, cell_cx(x), cell_cy(y), 5, 3)
            }
          }
        }

        let mut next_cd : Float = randf(5.2, 9.0) - Float::from_int(tier) * 0.22
        if next_cd < 2.2 {
          next_cd = 2.2
        }
        fault_cd = next_cd
      }

      step_cd = step_cd - dt
      if step_cd <= 0.0 {
        seen_mark = seen_mark + 1
        if seen_mark > 1000000 {
          seen_mark = 1
          for i = 0; i < seen.length(); i = i + 1 {
            seen[i] = 0
          }
        }

        let (gain, miss, powered) = run_network_step(
          cells, queue, seen, seen_mark, tier, overclock_t,
        )
        net_rate = gain
        delivered = delivered + gain
        budget = budget + gain / 2

        if powered == 0 {
          stability = stability - 2.2
        }

        stability = stability - Float::from_int(miss) * 0.065
        let fault_n : Int = count_faults(cells)
        stability = stability - Float::from_int(fault_n) * 0.03

        if stability > 100.0 {
          stability = 100.0
        }

        if gain > 0 {
          for i = 0; i < cells.length(); i = i + 1 {
            if cells[i].kind == 6 && cells[i].charge > 0.2 {
              let x : Int = i % cols
              let y : Int = i / cols
              burst_pulses(pulses, cell_cx(x), cell_cy(y), 2 + gain / 10, 2)
            }
          }
        }

        let mut next_step : Float = 0.44 - Float::from_int(tier) * 0.016
        if overclock_t > 0.0 {
          next_step = next_step - 0.06
        }
        if next_step < 0.22 {
          next_step = 0.22
        }
        step_cd = next_step
      }

      let b_patch_x = panel_x + 16
      let b_patch_y = 536
      let b_patch_w = 392
      let b_patch_h = 56

      let b_row_x = panel_x + 16
      let b_row_y = 600
      let b_row_w = 392
      let b_row_h = 56

      let b_over_x = panel_x + 16
      let b_over_y = 664
      let b_over_w = 392
      let b_over_h = 56

      let patch_hover = inside_rect(
        mouse.x,
        mouse.y,
        b_patch_x,
        b_patch_y,
        b_patch_w,
        b_patch_h,
      )
      let row_hover = inside_rect(
        mouse.x,
        mouse.y,
        b_row_x,
        b_row_y,
        b_row_w,
        b_row_h,
      )
      let over_hover = inside_rect(
        mouse.x,
        mouse.y,
        b_over_x,
        b_over_y,
        b_over_w,
        b_over_h,
      )

      let patch_cost : Int = 32
      let row_cost : Int = 24
      let over_cost : Int = 42

      let patch_trigger : Bool = @raylib.is_key_pressed(@raylib.KeyF) ||
        (click && patch_hover)
      if patch_trigger {
        if budget >= patch_cost {
          budget = budget - patch_cost
          let patched : Int = patch_faults(cells, 4.0)
          msg = "Patched \{patched} faulted nodes"
          msg_t = 1.0
          if patched > 0 {
            burst_pulses(
              pulses,
              Float::from_int(panel_x + panel_w / 2),
              566.0,
              12,
              1,
            )
          }
        } else {
          msg = "Need $\{patch_cost} for patch"
          msg_t = 0.9
        }
      }

      let row_trigger : Bool = @raylib.is_key_pressed(@raylib.KeyR) ||
        (click && row_hover)
      if row_trigger {
        if budget >= row_cost {
          budget = budget - row_cost
          let y : Int = @raylib.get_random_value(1, rows - 2)
          reroll_row(cells, y)
          msg = "Rerouted row \{y + 1}"
          msg_t = 1.0
          for x = 1; x < cols - 1; x = x + 1 {
            burst_pulses(pulses, cell_cx(x), cell_cy(y), 3, 0)
          }
        } else {
          msg = "Need $\{row_cost} for reroute"
          msg_t = 0.9
        }
      }

      let over_trigger : Bool = @raylib.is_key_pressed(@raylib.KeyO) ||
        (click && over_hover)
      if over_trigger {
        if budget >= over_cost {
          budget = budget - over_cost
          overclock_t = 8.0
          msg = "Overclock engaged"
          msg_t = 1.2
          for y = 0; y < rows; y = y + 1 {
            let i : Int = idx(0, y)
            if cells[i].kind == 5 {
              burst_pulses(pulses, cell_cx(0), cell_cy(y), 8, 0)
            }
          }
        } else {
          msg = "Need $\{over_cost} for overclock"
          msg_t = 0.9
        }
      }

      if click && not(patch_hover) && not(row_hover) && not(over_hover) {
        let ci : Int = pick_cell(mouse.x, mouse.y)
        if ci >= 0 {
          selected = ci
          if cells[ci].kind == 0 {
            if budget >= 14 {
              budget = budget - 14
              cells[ci].kind = rand_wire_kind()
              cells[ci].rot = @raylib.get_random_value(0, 3)
              cells[ci].health = 74.0
              cells[ci].fault_t = 0.0
              cells[ci].charge = 0.0
              msg = "Constructed new wire node"
              msg_t = 0.9
              let x : Int = ci % cols
              let y : Int = ci / cols
              burst_pulses(pulses, cell_cx(x), cell_cy(y), 10, 1)
            } else {
              msg = "Need $14 to construct node"
              msg_t = 0.8
            }
          } else if cells[ci].kind == 5 || cells[ci].kind == 6 {
            msg = "Special node cannot rotate"
            msg_t = 0.7
          } else if cells[ci].fault_t > 0.0 {
            if budget >= 6 {
              budget = budget - 6
              cells[ci].fault_t = cells[ci].fault_t - 2.5
              if cells[ci].fault_t < 0.0 {
                cells[ci].fault_t = 0.0
              }
              cells[ci].health = clampf(cells[ci].health + 4.0, 0.0, 100.0)
              msg = "Manual patch applied"
              msg_t = 0.7
              let x : Int = ci % cols
              let y : Int = ci / cols
              burst_pulses(pulses, cell_cx(x), cell_cy(y), 6, 1)
            } else {
              msg = "Need $6 for local patch"
              msg_t = 0.7
            }
          } else {
            cells[ci].rot = (cells[ci].rot + 1) % 4
            msg = "Rotated \{wire_name(cells[ci].kind)}"
            msg_t = 0.6
          }
        } else {
          selected = -1
        }
      }

      if delivered >= goal {
        state = 2
        msg = "Grid contract completed"
        msg_t = 3.0
        burst_pulses(
          pulses,
          Float::from_int(board_x + board_w / 2),
          Float::from_int(board_y + board_h / 2),
          80,
          2,
        )
      } else if timer <= 0.0 {
        state = 3
        msg = "Time over"
        msg_t = 3.0
      } else if stability <= 0.0 {
        state = 3
        msg = "Cascade blackout"
        msg_t = 3.0
      }

      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        selected = -1
      }
    } else if state == 2 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

    @raylib.draw_rectangle_gradient_v(
      0,
      0,
      sw,
      sh,
      @raylib.Color::new(14, 24, 44, 255),
      @raylib.Color::new(8, 12, 22, 255),
    )

    for i = 0; i < 38; i = i + 1 {
      let fi : Float = Float::from_int(i)
      let x : Int = (fi * 66.0 + scene_t * (14.0 + Float::from_int(i % 6) * 5.0)).to_int() %
        sw
      let y : Int = (fi * 132.0 +
        scene_t * (10.0 + Float::from_int(i % 5) * 6.0)).to_int() %
        sh
      @raylib.draw_circle(
        x,
        y,
        1.0 + Float::from_int(i % 3),
        @raylib.Color::new(108, 146, 220, 112),
      )
    }

    draw_board(cells, selected, hover, scene_t)

    let faults_now : Int = count_faults(cells)
    draw_panel(
      timer, stability, budget, delivered, goal, tier, faults_now, overclock_t, selected,
      cells, net_rate, fault_cd,
    )

    let patch_cost : Int = 32
    let row_cost : Int = 24
    let over_cost : Int = 42

    draw_button(
      panel_x + 16,
      536,
      392,
      56,
      "PATCH ALL [F] ($\{patch_cost})",
      budget >= patch_cost,
      inside_rect(mouse.x, mouse.y, panel_x + 16, 536, 392, 56),
    )
    draw_button(
      panel_x + 16,
      600,
      392,
      56,
      "REROUTE ROW [R] ($\{row_cost})",
      budget >= row_cost,
      inside_rect(mouse.x, mouse.y, panel_x + 16, 600, 392, 56),
    )
    draw_button(
      panel_x + 16,
      664,
      392,
      56,
      "OVERCLOCK [O] ($\{over_cost})",
      budget >= over_cost,
      inside_rect(mouse.x, mouse.y, panel_x + 16, 664, 392, 56),
    )

    draw_pulses(pulses)

    @raylib.draw_text(
      "Tap tiles to rotate / repair / build",
      board_x + 6,
      42,
      28,
      @raylib.Color::new(218, 232, 252, 244),
    )

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = sw / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(10, 16, 26, 226),
      )
      @raylib.draw_rectangle_lines(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(186, 210, 248, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        28,
        30,
        @raylib.Color::new(238, 246, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 22, 208))
      @raylib.draw_text(
        "CIRCUIT GRID OPERATOR",
        sw / 2 - 348,
        152,
        72,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Infrastructure puzzle in real-time",
        sw / 2 - 230,
        244,
        36,
        @raylib.Color::new(198, 220, 252, 252),
      )

      @raylib.draw_rectangle(
        sw / 2 - 476,
        314,
        952,
        248,
        @raylib.Color::new(16, 24, 40, 236),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 476,
        314,
        952,
        248,
        @raylib.Color::new(166, 196, 246, 246),
      )

      @raylib.draw_text(
        "Desktop",
        sw / 2 - 442,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Click tiles to rotate and route flow",
        sw / 2 - 442,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )
      @raylib.draw_text(
        "- F / R / O for global actions",
        sw / 2 - 442,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )
      @raylib.draw_text(
        "- Deliver to all sinks before timeout",
        sw / 2 - 442,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 76,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Tap grid tiles",
        sw / 2 + 76,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )
      @raylib.draw_text(
        "- Tap right-side action buttons",
        sw / 2 + 76,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )
      @raylib.draw_text(
        "- Full touch support",
        sw / 2 + 76,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 246),
      )

      draw_button(
        sw / 2 - 190,
        608,
        380,
        90,
        "START OPERATION",
        true,
        inside_rect(mouse.x, mouse.y, sw / 2 - 190, 608, 380, 90),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 20, 10, 198))
      @raylib.draw_text(
        "GRID STABILIZED",
        sw / 2 - 272,
        182,
        84,
        @raylib.Color::new(162, 246, 178, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{goal}",
        sw / 2 - 170,
        312,
        42,
        @raylib.Color::new(230, 248, 236, 252),
      )
      @raylib.draw_text(
        "Final stability \{stability.to_int()}%",
        sw / 2 - 180,
        364,
        34,
        @raylib.Color::new(244, 230, 158, 252),
      )
      @raylib.draw_text(
        "Tap or press Enter",
        sw / 2 - 132,
        450,
        34,
        @raylib.Color::new(214, 234, 252, 246),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 8, 14, 208))
      @raylib.draw_text(
        "BLACKOUT",
        sw / 2 - 170,
        186,
        90,
        @raylib.Color::new(252, 162, 178, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered}/\{goal}",
        sw / 2 - 170,
        320,
        40,
        @raylib.Color::new(242, 232, 236, 252),
      )
      @raylib.draw_text(
        "Budget $\{budget}  Stability \{stability.to_int()}%",
        sw / 2 - 262,
        372,
        34,
        @raylib.Color::new(244, 222, 154, 246),
      )
      @raylib.draw_text(
        "Tap or Enter to retry",
        sw / 2 - 160,
        454,
        34,
        @raylib.Color::new(218, 234, 252, 246),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
