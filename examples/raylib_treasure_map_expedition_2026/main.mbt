///|
let sw : Int = 1120

///|
let sh : Int = 760

///|
let gw : Int = 18

///|
let gh : Int = 12

///|
let cell : Int = 48

///|
let ox : Int = 120

///|
let oy : Int = 110

///|
struct Relic {
  x : Int
  y : Int
  mut taken : Bool
  value : Int
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * gw + x
}

///|
fn reset_map(blocked : Array[Bool], seen : Array[Bool]) -> Unit {
  for i = 0; i < blocked.length(); i = i + 1 {
    blocked[i] = false
    seen[i] = false
  }

  for x = 0; x < gw; x = x + 1 {
    blocked[idx(x, 0)] = true
    blocked[idx(x, gh - 1)] = true
  }
  for y = 0; y < gh; y = y + 1 {
    blocked[idx(0, y)] = true
    blocked[idx(gw - 1, y)] = true
  }

  // Jungle obstacles
  blocked[idx(4, 2)] = true
  blocked[idx(5, 2)] = true
  blocked[idx(6, 2)] = true
  blocked[idx(9, 3)] = true
  blocked[idx(9, 4)] = true
  blocked[idx(9, 5)] = true
  blocked[idx(12, 6)] = true
  blocked[idx(12, 7)] = true
  blocked[idx(13, 7)] = true
  blocked[idx(3, 8)] = true
  blocked[idx(4, 8)] = true
  blocked[idx(5, 8)] = true
  blocked[idx(7, 9)] = true
}

///|
fn reset_relics(relics : Array[Relic]) -> Unit {
  relics[0] = { x: 2, y: 9, taken: false, value: 80 }
  relics[1] = { x: 15, y: 2, taken: false, value: 120 }
  relics[2] = { x: 14, y: 9, taken: false, value: 160 }
  relics[3] = { x: 8, y: 6, taken: false, value: 210 }
}

///|
fn reveal(seen : Array[Bool], cx : Int, cy : Int, rad : Int) -> Unit {
  for y = cy - rad; y <= cy + rad; y = y + 1 {
    for x = cx - rad; x <= cx + rad; x = x + 1 {
      if x >= 0 && x < gw && y >= 0 && y < gh {
        seen[idx(x, y)] = true
      }
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Treasure Map Expedition 2026")
  @raylib.set_target_fps(60)

  let blocked : Array[Bool] = Array::make(gw * gh, false)
  let seen : Array[Bool] = Array::make(gw * gh, false)
  let relics : Array[Relic] = Array::makei(4, fn(_i) {
    { x: 1, y: 1, taken: false, value: 40 }
  })

  reset_map(blocked, seen)
  reset_relics(relics)

  let camp_x = 1
  let camp_y = 1

  let mut px = camp_x
  let mut py = camp_y
  let mut stamina = 100
  let mut steps = 0
  let mut bag_value = 0
  let mut bank = 0
  let mut timer : Float = 240.0
  let mut over = false
  let mut msg = "WASD move. Return to camp to bank relics and restore stamina."

  reveal(seen, px, py, 2)

  while not(@raylib.window_should_close()) {
    let dt = @raylib.get_frame_time()

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_map(blocked, seen)
      reset_relics(relics)
      px = camp_x
      py = camp_y
      stamina = 100
      steps = 0
      bag_value = 0
      bank = 0
      timer = 240.0
      over = false
      msg = "Expedition restarted."
      reveal(seen, px, py, 2)
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Storm arrived."
      }

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
        if nx >= 0 && nx < gw && ny >= 0 && ny < gh && not(blocked[idx(nx, ny)]) {
          px = nx
          py = ny
          steps = steps + 1
          stamina = stamina - 2
          reveal(seen, px, py, 2)
        } else {
          msg = "Cannot move there."
        }
      }

      if px == camp_x && py == camp_y {
        if bag_value > 0 {
          bank = bank + bag_value
          msg = "Artifacts banked +\{bag_value}."
          bag_value = 0
        }
        stamina = stamina + 2
        if stamina > 100 {
          stamina = 100
        }
      }

      for i = 0; i < relics.length(); i = i + 1 {
        if not(relics[i].taken) && relics[i].x == px && relics[i].y == py {
          relics[i].taken = true
          bag_value = bag_value + relics[i].value
          msg = "Relic found +\{relics[i].value}."
        }
      }

      if stamina <= 0 {
        stamina = 0
        over = true
        msg = "Exhausted in the wild."
      }

      let mut all_taken = true
      for i = 0; i < relics.length(); i = i + 1 {
        if not(relics[i].taken) {
          all_taken = false
        }
      }
      if all_taken && px == camp_x && py == camp_y && bag_value == 0 {
        over = true
        msg = "Expedition complete."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 24, 18, 255))

    @raylib.draw_rectangle(0, 0, sw, 96, @raylib.Color::new(34, 48, 34, 255))

    for y = 0; y < gh; y = y + 1 {
      for x = 0; x < gw; x = x + 1 {
        let rx = ox + x * cell
        let ry = oy + y * cell

        if not(seen[idx(x, y)]) {
          @raylib.draw_rectangle(
            rx,
            ry,
            cell - 1,
            cell - 1,
            @raylib.Color::new(10, 14, 10, 255),
          )
          continue
        }

        let base = if blocked[idx(x, y)] {
          @raylib.Color::new(46, 64, 46, 255)
        } else {
          @raylib.Color::new(76, 112, 70, 255)
        }
        @raylib.draw_rectangle(rx, ry, cell - 1, cell - 1, base)

        if x == camp_x && y == camp_y {
          @raylib.draw_rectangle(
            rx + 8,
            ry + 8,
            cell - 17,
            cell - 17,
            @raylib.Color::new(190, 170, 110, 255),
          )
          @raylib.draw_text("C", rx + 16, ry + 10, 26, @raylib.black)
        }
      }
    }

    for i = 0; i < relics.length(); i = i + 1 {
      if not(relics[i].taken) && seen[idx(relics[i].x, relics[i].y)] {
        let rx = ox + relics[i].x * cell + cell / 2
        let ry = oy + relics[i].y * cell + cell / 2
        @raylib.draw_circle(rx, ry, 10.0, @raylib.gold)
        @raylib.draw_circle_lines(rx, ry, 10.0, @raylib.yellow)
      }
    }

    let pxs = ox + px * cell + cell / 2
    let pys = oy + py * cell + cell / 2
    @raylib.draw_circle(pxs, pys, 14.0, @raylib.skyblue)
    @raylib.draw_circle_lines(pxs, pys, 14.0, @raylib.white)

    @raylib.draw_text(
      "TREASURE MAP EXPEDITION 2026", 20, 16, 34, @raylib.skyblue,
    )
    @raylib.draw_text("Bank \{bank}", 20, 56, 26, @raylib.lime)
    @raylib.draw_text("Bag \{bag_value}", 180, 56, 26, @raylib.gold)
    @raylib.draw_text("Steps \{steps}", 340, 56, 26, @raylib.white)

    let t = timer.to_int()
    @raylib.draw_text(
      "Time \{t}s",
      500,
      56,
      26,
      if t < 35 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )

    @raylib.draw_text("Stamina", 680, 56, 24, @raylib.raywhite)
    @raylib.draw_rectangle(
      770,
      62,
      220,
      14,
      @raylib.Color::new(24, 34, 24, 255),
    )
    @raylib.draw_rectangle(770, 62, stamina * 220 / 100, 14, @raylib.skyblue)

    @raylib.draw_text(
      "Find relics in fog and return to camp to secure them.", 20, 694, 22, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      724,
      sw - 40,
      24,
      @raylib.Color::new(8, 12, 8, 220),
    )
    @raylib.draw_text(msg, 26, 727, 18, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("EXPEDITION END", 360, 320, 56, @raylib.orange)
      @raylib.draw_text("Press R to restart", 450, 386, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
