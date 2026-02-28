///|
let sw : Int = 1160

///|
let sh : Int = 760

///|
let surface_y : Float = 116.0

///|
struct Relic {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut size : Float
  mut value : Int
}

///|
struct Mine {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut r : Float
}

///|
fn spawn_relic(rs : Array[Relic]) -> Unit {
  for rs_elem in rs {
    if not(rs_elem.alive) {
      rs_elem.alive = true
      rs_elem.x = Float::from_int(@raylib.get_random_value(110, sw - 110))
      rs_elem.y = Float::from_int(@raylib.get_random_value(220, sh - 70))
      rs_elem.size = Float::from_int(@raylib.get_random_value(12, 22))
      rs_elem.value = @raylib.get_random_value(20, 90)
      break
    }
  }
}

///|
fn spawn_mine(ms : Array[Mine]) -> Unit {
  for ms_elem in ms {
    if not(ms_elem.alive) {
      ms_elem.alive = true
      ms_elem.x = Float::from_int(@raylib.get_random_value(120, sw - 120))
      ms_elem.y = Float::from_int(@raylib.get_random_value(200, sh - 80))
      ms_elem.vx = Float::from_int(@raylib.get_random_value(-70, 70))
      ms_elem.r = Float::from_int(@raylib.get_random_value(12, 20))
      break
    }
  }
}

///|
fn reset_relics(rs : Array[Relic]) -> Unit {
  for rs_elem in rs {
    rs_elem.alive = false
  }
}

///|
fn reset_mines(ms : Array[Mine]) -> Unit {
  for ms_elem in ms {
    ms_elem.alive = false
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Deep Sea Salvage 2026")
  @raylib.set_target_fps(60)

  let relics : Array[Relic] = Array::makei(90, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, size: 14.0, value: 20 }
  })
  let mines : Array[Mine] = Array::makei(60, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, r: 14.0 }
  })

  let mut px : Float = Float::from_int(sw / 2)
  let mut py : Float = surface_y + 20.0

  let mut hull = 100
  let mut oxygen : Float = 100.0
  let mut fuel : Float = 100.0
  let mut cargo_value = 0
  let mut bank = 0

  let mut timer : Float = 210.0
  let mut relic_tick : Float = 0.0
  let mut mine_tick : Float = 0.0

  let mut over = false
  let mut msg = "WASD/Arrows move, surface to bank cargo and refill oxygen"

  for _i in 0..<8 {
    spawn_relic(relics)
  }
  for _i in 0..<5 {
    spawn_mine(mines)
  }

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      px = Float::from_int(sw / 2)
      py = surface_y + 20.0
      hull = 100
      oxygen = 100.0
      fuel = 100.0
      cargo_value = 0
      bank = 0
      timer = 210.0
      relic_tick = 0.0
      mine_tick = 0.0
      over = false
      msg = "Dive restarted."
      reset_relics(relics)
      reset_mines(mines)
      for _i in 0..<8 {
        spawn_relic(relics)
      }
      for _i in 0..<5 {
        spawn_mine(mines)
      }
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Mission clock expired."
      }

      let mut mx : Float = 0.0
      let mut my : Float = 0.0
      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        mx = mx - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        mx = mx + 1.0
      }
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        my = my - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        my = my + 1.0
      }

      let speed : Float = 210.0
      px = px + mx * speed * dt
      py = py + my * speed * dt

      if px < 60.0 {
        px = 60.0
      }
      if px > Float::from_int(sw - 60) {
        px = Float::from_int(sw - 60)
      }
      if py < 76.0 {
        py = 76.0
      }
      if py > Float::from_int(sh - 40) {
        py = Float::from_int(sh - 40)
      }

      if py > surface_y + 20.0 {
        oxygen = oxygen - dt * 6.0
      } else {
        oxygen = oxygen + dt * 24.0
      }
      fuel = fuel - dt * 2.0
      if oxygen > 100.0 {
        oxygen = 100.0
      }
      if fuel > 100.0 {
        fuel = 100.0
      }

      // Banking and refuel at surface
      if py <= surface_y + 20.0 {
        if cargo_value > 0 {
          bank = bank + cargo_value
          msg = "Cargo banked +\{cargo_value}."
          cargo_value = 0
        }
        fuel = fuel + dt * 20.0
        if fuel > 100.0 {
          fuel = 100.0
        }
      }

      relic_tick = relic_tick + dt
      if relic_tick >= 2.8 {
        relic_tick = relic_tick - 2.8
        spawn_relic(relics)
      }

      mine_tick = mine_tick + dt
      if mine_tick >= 4.6 {
        mine_tick = mine_tick - 4.6
        spawn_mine(mines)
      }

      for mine in mines {
        if not(mine.alive) {
          continue
        }

        mine.x = mine.x + mine.vx * dt
        if mine.x < 80.0 {
          mine.x = 80.0
          mine.vx = mine.vx.abs()
        }
        if mine.x > Float::from_int(sw - 80) {
          mine.x = Float::from_int(sw - 80)
          mine.vx = -mine.vx.abs()
        }

        let dx = mine.x - px
        let dy = mine.y - py
        let rr = mine.r + 12.0
        if dx * dx + dy * dy <= rr * rr {
          hull = hull - 10
          fuel = fuel - 6.0
          mine.alive = false
          msg = "Mine impact!"
        }
      }

      for relic in relics {
        if not(relic.alive) {
          continue
        }
        let dx = relic.x - px
        let dy = relic.y - py
        let rr = relic.size + 12.0
        if dx * dx + dy * dy <= rr * rr {
          relic.alive = false
          cargo_value = cargo_value + relic.value
          msg = "Relic secured +\{relic.value}."
        }
      }

      if oxygen <= 0.0 {
        oxygen = 0.0
        hull = hull - 1
      }
      if fuel <= 0.0 {
        fuel = 0.0
        over = true
        msg = "Out of fuel."
      }
      if hull <= 0 {
        hull = 0
        over = true
        msg = "Hull breached."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 24, 36, 255))

    @raylib.draw_rectangle(
      0,
      0,
      sw,
      surface_y.to_int(),
      @raylib.Color::new(46, 110, 168, 255),
    )
    @raylib.draw_rectangle(
      0,
      surface_y.to_int(),
      sw,
      sh - surface_y.to_int(),
      @raylib.Color::new(12, 56, 86, 255),
    )

    for y = surface_y.to_int() + 30; y < sh; y = y + 60 {
      @raylib.draw_line(0, y, sw, y, @raylib.fade(@raylib.skyblue, 0.12))
    }

    for relic in relics {
      if relic.alive {
        @raylib.draw_circle(
          relic.x.to_int(),
          relic.y.to_int(),
          relic.size,
          @raylib.gold,
        )
        @raylib.draw_circle_lines(
          relic.x.to_int(),
          relic.y.to_int(),
          relic.size,
          @raylib.yellow,
        )
      }
    }

    for mine in mines {
      if mine.alive {
        @raylib.draw_circle(
          mine.x.to_int(),
          mine.y.to_int(),
          mine.r,
          @raylib.maroon,
        )
        @raylib.draw_circle_lines(
          mine.x.to_int(),
          mine.y.to_int(),
          mine.r,
          @raylib.red,
        )
      }
    }

    // submarine
    @raylib.draw_ellipse(px.to_int(), py.to_int(), 28.0, 14.0, @raylib.yellow)
    @raylib.draw_circle((px + 18.0).to_int(), py.to_int(), 6.0, @raylib.orange)
    @raylib.draw_rectangle(
      (px - 10.0).to_int(),
      (py - 18.0).to_int(),
      20,
      6,
      @raylib.gray,
    )

    @raylib.draw_text("DEEP SEA SALVAGE 2026", 20, 16, 40, @raylib.skyblue)
    @raylib.draw_text("Bank \{bank}", 20, 62, 30, @raylib.lime)
    @raylib.draw_text("Cargo \{cargo_value}", 200, 62, 30, @raylib.gold)
    @raylib.draw_text(
      "Hull \{hull}",
      420,
      62,
      30,
      if hull <= 30 {
        @raylib.red
      } else {
        @raylib.raywhite
      },
    )

    let t = timer.to_int()
    @raylib.draw_text(
      "Time \{t}s",
      600,
      62,
      30,
      if t < 30 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )

    @raylib.draw_text("Oxygen", 20, 104, 24, @raylib.skyblue)
    @raylib.draw_rectangle(
      118,
      110,
      220,
      14,
      @raylib.Color::new(22, 34, 56, 255),
    )
    @raylib.draw_rectangle(
      118,
      110,
      (oxygen * 2.2).to_int(),
      14,
      @raylib.skyblue,
    )

    @raylib.draw_text("Fuel", 360, 104, 24, @raylib.orange)
    @raylib.draw_rectangle(
      424,
      110,
      220,
      14,
      @raylib.Color::new(54, 36, 22, 255),
    )
    @raylib.draw_rectangle(424, 110, (fuel * 2.2).to_int(), 14, @raylib.orange)

    @raylib.draw_text(
      "Tip: surface to bank cargo and refill oxygen faster", 20, 684, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      718,
      sw - 40,
      24,
      @raylib.Color::new(8, 14, 20, 220),
    )
    @raylib.draw_text(msg, 26, 721, 18, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("DIVE OVER", 450, 320, 56, @raylib.orange)
      @raylib.draw_text("Press R to restart", 450, 386, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
