///|
let sw : Int = 1120

///|
let sh : Int = 760

///|
let gw : Int = 12

///|
let gh : Int = 9

///|
let cell : Int = 64

///|
let ox : Int = 170

///|
let oy : Int = 120

///|
struct Pos {
  mut x : Int
  mut y : Int
}

///|
fn gidx(x : Int, y : Int) -> Int {
  y * gw + x
}

///|
fn is_wall(walls : Array[Bool], x : Int, y : Int) -> Bool {
  if x < 0 || x >= gw || y < 0 || y >= gh {
    true
  } else {
    walls[gidx(x, y)]
  }
}

///|
fn crate_at(crates : Array[Pos], x : Int, y : Int) -> Int {
  for i = 0; i < crates.length(); i = i + 1 {
    if crates[i].x == x && crates[i].y == y {
      return i
    }
  }
  -1
}

///|
fn is_target(targets : Array[Pos], x : Int, y : Int) -> Bool {
  for i = 0; i < targets.length(); i = i + 1 {
    if targets[i].x == x && targets[i].y == y {
      return true
    }
  }
  false
}

///|
fn all_delivered(crates : Array[Pos], targets : Array[Pos]) -> Bool {
  for i = 0; i < crates.length(); i = i + 1 {
    if not(is_target(targets, crates[i].x, crates[i].y)) {
      return false
    }
  }
  true
}

///|
fn reset_level(
  walls : Array[Bool],
  crates : Array[Pos],
  targets : Array[Pos],
) -> (Int, Int) {
  for i = 0; i < walls.length(); i = i + 1 {
    walls[i] = false
  }

  for x = 0; x < gw; x = x + 1 {
    walls[gidx(x, 0)] = true
    walls[gidx(x, gh - 1)] = true
  }
  for y = 0; y < gh; y = y + 1 {
    walls[gidx(0, y)] = true
    walls[gidx(gw - 1, y)] = true
  }

  // Obstacles
  walls[gidx(4, 2)] = true
  walls[gidx(4, 3)] = true
  walls[gidx(4, 4)] = true
  walls[gidx(7, 3)] = true
  walls[gidx(7, 4)] = true
  walls[gidx(7, 5)] = true
  walls[gidx(2, 6)] = true
  walls[gidx(9, 2)] = true

  crates[0].x = 2
  crates[0].y = 2
  crates[1].x = 3
  crates[1].y = 5
  crates[2].x = 8
  crates[2].y = 2
  crates[3].x = 9
  crates[3].y = 6

  targets[0].x = 2
  targets[0].y = 7
  targets[1].x = 3
  targets[1].y = 7
  targets[2].x = 8
  targets[2].y = 7
  targets[3].x = 9
  targets[3].y = 7

  (6, 6)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Warehouse Forklift 2026")
  @raylib.set_target_fps(60)

  let walls : Array[Bool] = Array::make(gw * gh, false)
  let crates : Array[Pos] = Array::makei(4, fn(_i) { { x: 1, y: 1 } })
  let targets : Array[Pos] = Array::makei(4, fn(_i) { { x: 1, y: 1 } })

  let (px0, py0) = reset_level(walls, crates, targets)
  let mut px = px0
  let mut py = py0
  let mut moves = 0
  let mut pushes = 0
  let mut score = 0
  let mut won = false
  let mut msg = "Move with WASD/Arrows. Push crates onto yellow docks."

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      let (sx, sy) = reset_level(walls, crates, targets)
      px = sx
      py = sy
      moves = 0
      pushes = 0
      score = 0
      won = false
      msg = "Level restarted."
    }

    if not(won) {
      let mut dx = 0
      let mut dy = 0
      let mut acted = false

      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        dx = -1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        dx = 1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        dy = -1
        acted = true
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        dy = 1
        acted = true
      }

      if acted {
        let nx = px + dx
        let ny = py + dy
        if is_wall(walls, nx, ny) {
          msg = "Blocked by rack."
        } else {
          let ci = crate_at(crates, nx, ny)
          if ci >= 0 {
            let nnx = nx + dx
            let nny = ny + dy
            if is_wall(walls, nnx, nny) || crate_at(crates, nnx, nny) >= 0 {
              msg = "Cannot push crate there."
            } else {
              crates[ci].x = nnx
              crates[ci].y = nny
              px = nx
              py = ny
              moves = moves + 1
              pushes = pushes + 1
              score = score + 6
              msg = "Crate pushed."
            }
          } else {
            px = nx
            py = ny
            moves = moves + 1
            score = score + 1
          }
        }

        if all_delivered(crates, targets) {
          won = true
          score = score + 200
          msg = "All shipments docked."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(24, 27, 34, 255))

    @raylib.draw_rectangle(0, 0, sw, 100, @raylib.Color::new(42, 48, 62, 255))

    for y = 0; y < gh; y = y + 1 {
      for x = 0; x < gw; x = x + 1 {
        let rx = ox + x * cell
        let ry = oy + y * cell

        if is_wall(walls, x, y) {
          @raylib.draw_rectangle(
            rx,
            ry,
            cell - 2,
            cell - 2,
            @raylib.Color::new(84, 88, 96, 255),
          )
        } else {
          @raylib.draw_rectangle(
            rx,
            ry,
            cell - 2,
            cell - 2,
            @raylib.Color::new(202, 210, 216, 255),
          )
        }

        if is_target(targets, x, y) {
          @raylib.draw_rectangle_lines(
            rx + 8,
            ry + 8,
            cell - 18,
            cell - 18,
            @raylib.gold,
          )
          @raylib.draw_rectangle_lines(
            rx + 10,
            ry + 10,
            cell - 22,
            cell - 22,
            @raylib.orange,
          )
        }
      }
    }

    for i = 0; i < crates.length(); i = i + 1 {
      let cx = ox + crates[i].x * cell
      let cy = oy + crates[i].y * cell
      let docked = is_target(targets, crates[i].x, crates[i].y)
      @raylib.draw_rectangle(
        cx + 10,
        cy + 12,
        cell - 22,
        cell - 24,
        if docked {
          @raylib.lime
        } else {
          @raylib.brown
        },
      )
      @raylib.draw_rectangle_lines(
        cx + 10,
        cy + 12,
        cell - 22,
        cell - 24,
        @raylib.black,
      )
      @raylib.draw_text(
        if docked {
          "OK"
        } else {
          "BOX"
        },
        cx + 16,
        cy + 20,
        16,
        @raylib.black,
      )
    }

    let pxs = ox + px * cell
    let pys = oy + py * cell
    @raylib.draw_rectangle(
      pxs + 8,
      pys + 16,
      cell - 16,
      cell - 22,
      @raylib.orange,
    )
    @raylib.draw_rectangle(pxs + 18, pys + 8, cell - 36, 10, @raylib.yellow)
    @raylib.draw_circle(pxs + 18, pys + cell - 2, 5.0, @raylib.black)
    @raylib.draw_circle(pxs + cell - 18, pys + cell - 2, 5.0, @raylib.black)

    @raylib.draw_text("WAREHOUSE FORKLIFT 2026", 20, 18, 38, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 60, 28, @raylib.white)
    @raylib.draw_text("Moves \{moves}", 220, 60, 28, @raylib.raywhite)
    @raylib.draw_text("Pushes \{pushes}", 390, 60, 28, @raylib.raywhite)

    @raylib.draw_text(
      "Goal: move all crates onto yellow docks", 20, 692, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      724,
      sw - 40,
      28,
      @raylib.Color::new(12, 16, 22, 220),
    )
    @raylib.draw_text(msg, 28, 728, 18, @raylib.raywhite)

    if won {
      @raylib.draw_rectangle(
        280,
        260,
        560,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("SHIPMENT COMPLETE", 340, 322, 52, @raylib.lime)
      @raylib.draw_text("Press R to replay", 450, 382, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
