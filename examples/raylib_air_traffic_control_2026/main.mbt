///|
let sw : Int = 1160

///|
let sh : Int = 740

///|
let runway_count : Int = 3

///|
fn runway_x(idx : Int) -> Float {
  250.0 + Float::from_int(idx) * 330.0
}

///|
struct Plane {
  mut alive : Bool
  mut runway : Int
  mut x : Float
  mut y : Float
  mut vy : Float
  mut fuel : Float
}

///|
fn spawn_plane(planes : Array[Plane]) -> Unit {
  for i = 0; i < planes.length(); i = i + 1 {
    if not(planes[i].alive) {
      let r = @raylib.get_random_value(0, runway_count - 1)
      planes[i].alive = true
      planes[i].runway = r
      planes[i].x = runway_x(r) + Float::from_int(@raylib.get_random_value(-24, 24))
      planes[i].y = -40.0
      planes[i].vy = Float::from_int(@raylib.get_random_value(65, 110))
      planes[i].fuel = Float::from_int(@raylib.get_random_value(16, 26))
      break
    }
  }
}

///|
fn reset_planes(planes : Array[Plane]) -> Unit {
  for i = 0; i < planes.length(); i = i + 1 {
    planes[i].alive = false
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Air Traffic Control 2026")
  @raylib.set_target_fps(60)

  let planes : Array[Plane] = Array::makei(100, fn(_i) {
    {
      alive: false,
      runway: 0,
      x: 0.0,
      y: 0.0,
      vy: 80.0,
      fuel: 20.0,
    }
  })

  let mut runway_open : Array[Bool] = [true, true, true]
  let mut runway_busy : Array[Float] = [0.0, 0.0, 0.0]

  let mut spawn_tick : Float = 0.0
  let mut score = 0
  let mut landed = 0
  let mut missed = 0
  let mut lives = 5
  let mut stress : Float = 0.0
  let mut over = false
  let mut msg = "1/2/3 toggle runway open/close, keep landings safe"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      runway_open = [true, true, true]
      runway_busy = [0.0, 0.0, 0.0]
      spawn_tick = 0.0
      score = 0
      landed = 0
      missed = 0
      lives = 5
      stress = 0.0
      over = false
      msg = "Tower shift restarted."
      reset_planes(planes)
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        runway_open[0] = not(runway_open[0])
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        runway_open[1] = not(runway_open[1])
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        runway_open[2] = not(runway_open[2])
      }

      for r = 0; r < runway_count; r = r + 1 {
        runway_busy[r] = runway_busy[r] - dt
        if runway_busy[r] < 0.0 {
          runway_busy[r] = 0.0
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.70 {
        spawn_tick = spawn_tick - 0.70
        spawn_plane(planes)
      }

      stress = stress - dt * 4.0
      if stress < 0.0 {
        stress = 0.0
      }

      for i = 0; i < planes.length(); i = i + 1 {
        if not(planes[i].alive) {
          continue
        }

        planes[i].y = planes[i].y + planes[i].vy * dt
        planes[i].fuel = planes[i].fuel - dt

        if planes[i].fuel <= 0.0 {
          planes[i].alive = false
          lives = lives - 1
          missed = missed + 1
          stress = stress + 22.0
          msg = "Plane ran out of fuel."
          continue
        }

        let r = planes[i].runway
        if planes[i].y >= 560.0 {
          if runway_open[r] && runway_busy[r] <= 0.0 {
            planes[i].alive = false
            runway_busy[r] = 2.0
            landed = landed + 1
            score = score + 70 + planes[i].fuel.to_int()
            stress = stress + 4.0
            msg = "Runway \{r + 1}: safe landing."
          } else if planes[i].y >= 650.0 {
            planes[i].alive = false
            lives = lives - 1
            missed = missed + 1
            score = score - 45
            stress = stress + 25.0
            msg = "Runway \{r + 1}: crash on approach."
          }
        }
      }

      // Near-collision warning between planes on same runway
      for i = 0; i < planes.length(); i = i + 1 {
        if not(planes[i].alive) {
          continue
        }
        for j = i + 1; j < planes.length(); j = j + 1 {
          if not(planes[j].alive) {
            continue
          }
          if planes[i].runway == planes[j].runway {
            let dy = (planes[i].y - planes[j].y).abs()
            if dy < 48.0 {
              stress = stress + dt * 22.0
            }
          }
        }
      }

      if stress >= 100.0 {
        stress = 100.0
        lives = lives - 1
        msg = "Controller overload penalty."
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Tower closed due to failures."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(120, 178, 230, 255))

    @raylib.draw_rectangle(0, 140, sw, sh - 140, @raylib.Color::new(84, 130, 94, 255))

    for r = 0; r < runway_count; r = r + 1 {
      let x = runway_x(r)
      let state_c = if runway_open[r] { @raylib.lime } else { @raylib.red }

      @raylib.draw_rectangle((x - 54.0).to_int(), 170, 108, 520, @raylib.Color::new(62, 66, 72, 255))
      @raylib.draw_line((x).to_int(), 180, x.to_int(), 680, @raylib.lightgray)
      @raylib.draw_text("RWY \{r + 1}", (x - 42.0).to_int(), 184, 24, @raylib.white)
      @raylib.draw_circle((x + 44.0).to_int(), 184, 8.0, state_c)

      if runway_busy[r] > 0.0 {
        @raylib.draw_rectangle((x - 54.0).to_int(), 620, 108, 70, @raylib.fade(@raylib.orange, 0.6))
      }
    }

    for i = 0; i < planes.length(); i = i + 1 {
      if planes[i].alive {
        let c = if planes[i].fuel < 6.0 { @raylib.red } else { @raylib.white }
        @raylib.draw_triangle(
          @raylib.Vector2::new(planes[i].x, planes[i].y - 12.0),
          @raylib.Vector2::new(planes[i].x - 12.0, planes[i].y + 10.0),
          @raylib.Vector2::new(planes[i].x + 12.0, planes[i].y + 10.0),
          c,
        )
        @raylib.draw_text("\{planes[i].fuel.to_int()}", (planes[i].x + 14.0).to_int(), (planes[i].y - 12.0).to_int(), 18, @raylib.black)
      }
    }

    @raylib.draw_rectangle(16, 14, 600, 110, @raylib.Color::new(12, 18, 30, 220))
    @raylib.draw_text("AIR TRAFFIC CONTROL 2026", 26, 22, 36, @raylib.skyblue)
    @raylib.draw_text("Score \{score}  Landed \{landed}  Missed \{missed}  Lives \{lives}", 28, 66, 28, @raylib.raywhite)

    @raylib.draw_text("Stress", 670, 30, 28, @raylib.darkblue)
    @raylib.draw_rectangle(760, 36, 300, 20, @raylib.Color::new(40, 20, 20, 255))
    @raylib.draw_rectangle(760, 36, (stress * 3.0).to_int(), 20, @raylib.red)

    @raylib.draw_rectangle(20, 694, sw - 40, 30, @raylib.Color::new(12, 18, 30, 220))
    @raylib.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 540, 180, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("SHIFT FAILED", 420, 310, 52, @raylib.red)
      @raylib.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
