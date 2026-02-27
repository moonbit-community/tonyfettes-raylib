///|
let sw : Int = 1200

///|
let sh : Int = 760

///|
struct Well {
  x : Float
  y : Float
  mass : Float
  r : Float
}

///|
fn set_well(
  wells : Array[Well],
  i : Int,
  x : Float,
  y : Float,
  mass : Float,
  r : Float,
) -> Unit {
  wells[i] = { x, y, mass, r }
}

///|
fn clear_wells(wells : Array[Well]) -> Unit {
  for i = 0; i < wells.length(); i = i + 1 {
    set_well(wells, i, 0.0, 0.0, 0.0, 0.0)
  }
}

///|
fn setup_level(
  level : Int,
  wells : Array[Well],
) -> (Float, Float, Float, Float, Int) {
  clear_wells(wells)
  if level == 1 {
    set_well(wells, 0, 520.0, 360.0, 56000.0, 34.0)
    set_well(wells, 1, 860.0, 260.0, 46000.0, 28.0)
    (130.0, 620.0, 1060.0, 210.0, 8)
  } else if level == 2 {
    set_well(wells, 0, 430.0, 260.0, 62000.0, 32.0)
    set_well(wells, 1, 660.0, 460.0, 78000.0, 42.0)
    set_well(wells, 2, 930.0, 300.0, 54000.0, 30.0)
    (120.0, 160.0, 1040.0, 640.0, 9)
  } else {
    set_well(wells, 0, 360.0, 330.0, 70000.0, 34.0)
    set_well(wells, 1, 610.0, 210.0, 64000.0, 31.0)
    set_well(wells, 2, 810.0, 510.0, 76000.0, 39.0)
    set_well(wells, 3, 1000.0, 270.0, 61000.0, 30.0)
    (140.0, 680.0, 1090.0, 130.0, 10)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Gravity Golf 2026")
  @raylib.set_target_fps(60)

  let wells : Array[Well] = Array::makei(4, fn(_i) {
    { x: 0.0, y: 0.0, mass: 0.0, r: 0.0 }
  })

  let mut level = 1
  let mut sx : Float = 0.0
  let mut sy : Float = 0.0
  let mut hx : Float = 0.0
  let mut hy : Float = 0.0
  let mut shots_left = 0

  let (isx, isy, ihx, ihy, ishots) = setup_level(level, wells)
  sx = isx
  sy = isy
  hx = ihx
  hy = ihy
  shots_left = ishots

  let mut bx = sx
  let mut by = sy
  let mut bvx : Float = 0.0
  let mut bvy : Float = 0.0
  let mut moving = false
  let mut shot_time : Float = 0.0

  let mut power : Float = 500.0
  let mut score = 0
  let mut over = false
  let mut msg = "Mouse aim, W/S power, Space shoot, R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rsx, rsy, rhx, rhy, rshots) = setup_level(level, wells)
      sx = rsx
      sy = rsy
      hx = rhx
      hy = rhy
      shots_left = rshots
      bx = sx
      by = sy
      bvx = 0.0
      bvy = 0.0
      moving = false
      shot_time = 0.0
      power = 500.0
      score = 0
      over = false
      msg = "Course restarted."
    }

    if not(over) {
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        power = power + 260.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        power = power - 260.0 * dt
      }
      if power < 220.0 {
        power = 220.0
      }
      if power > 760.0 {
        power = 760.0
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) &&
        not(moving) &&
        shots_left > 0 {
        let m = @raylib.get_mouse_position()
        let mut dx = m.x - bx
        let mut dy = m.y - by
        let d = (dx * dx + dy * dy).sqrt()
        if d > 0.001 {
          dx = dx / d
          dy = dy / d
          bvx = dx * power
          bvy = dy * power
          shots_left = shots_left - 1
          moving = true
          shot_time = 0.0
        }
      }

      if moving {
        shot_time = shot_time + dt

        for i = 0; i < wells.length(); i = i + 1 {
          if wells[i].mass <= 0.0 {
            continue
          }
          let dx = wells[i].x - bx
          let dy = wells[i].y - by
          let d2 = dx * dx + dy * dy
          let crash_r = wells[i].r + 8.0
          if d2 <= crash_r * crash_r {
            moving = false
            bx = sx
            by = sy
            bvx = 0.0
            bvy = 0.0
            msg = "Ball collapsed into gravity well."
            break
          }
          if d2 > 36.0 {
            let d = d2.sqrt()
            let a = wells[i].mass / d2
            bvx = bvx + dx / d * a * dt
            bvy = bvy + dy / d * a * dt
          }
        }

        if moving {
          bx = bx + bvx * dt
          by = by + bvy * dt

          if bx < 20.0 {
            bx = 20.0
            bvx = -bvx * 0.72
          }
          if bx > Float::from_int(sw - 20) {
            bx = Float::from_int(sw - 20)
            bvx = -bvx * 0.72
          }
          if by < 90.0 {
            by = 90.0
            bvy = -bvy * 0.72
          }
          if by > Float::from_int(sh - 20) {
            by = Float::from_int(sh - 20)
            bvy = -bvy * 0.72
          }

          let spd = (bvx * bvx + bvy * bvy).sqrt()
          if shot_time > 0.9 && spd < 36.0 {
            moving = false
            bvx = 0.0
            bvy = 0.0
            msg = "Ball settled. Re-aim your shot."
          }

          let hdx = hx - bx
          let hdy = hy - by
          if hdx * hdx + hdy * hdy <= 18.0 * 18.0 {
            moving = false
            score = score + shots_left * 20 + 120
            if level < 3 {
              level = level + 1
              let (nsx, nsy, nhx, nhy, nshots) = setup_level(level, wells)
              sx = nsx
              sy = nsy
              hx = nhx
              hy = nhy
              shots_left = nshots
              bx = sx
              by = sy
              bvx = 0.0
              bvy = 0.0
              msg = "Hole cleared. Level \{level}."
            } else {
              over = true
              msg = "Course completed."
            }
          }

          if shots_left <= 0 && not(moving) {
            over = true
            msg = "Out of shots."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 18, 28, 255))

    for i = 0; i < wells.length(); i = i + 1 {
      if wells[i].mass > 0.0 {
        @raylib.draw_circle(
          wells[i].x.to_int(),
          wells[i].y.to_int(),
          wells[i].r + 12.0,
          @raylib.fade(@raylib.darkblue, 0.35),
        )
        @raylib.draw_circle(
          wells[i].x.to_int(),
          wells[i].y.to_int(),
          wells[i].r,
          @raylib.purple,
        )
        @raylib.draw_circle_lines(
          wells[i].x.to_int(),
          wells[i].y.to_int(),
          wells[i].r,
          @raylib.white,
        )
      }
    }

    @raylib.draw_circle(hx.to_int(), hy.to_int(), 18.0, @raylib.green)
    @raylib.draw_circle_lines(hx.to_int(), hy.to_int(), 18.0, @raylib.lime)
    @raylib.draw_circle(hx.to_int(), hy.to_int(), 6.0, @raylib.black)

    let m = @raylib.get_mouse_position()
    if not(moving) && not(over) {
      @raylib.draw_line(
        bx.to_int(),
        by.to_int(),
        m.x.to_int(),
        m.y.to_int(),
        @raylib.yellow,
      )
    }

    @raylib.draw_circle(bx.to_int(), by.to_int(), 8.0, @raylib.raywhite)

    @raylib.draw_text("GRAVITY GOLF 2026", 20, 16, 40, @raylib.skyblue)
    @raylib.draw_text("Level \{level}/3", 20, 62, 28, @raylib.white)
    @raylib.draw_text("Shots \{shots_left}", 180, 62, 28, @raylib.orange)
    @raylib.draw_text("Power \{power.to_int()}", 330, 62, 28, @raylib.raywhite)
    @raylib.draw_text("Score \{score}", 540, 62, 28, @raylib.lime)

    @raylib.draw_text(
      "Aim with mouse. W/S adjust power. Space launches ball.", 20, 694, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      726,
      sw - 40,
      24,
      @raylib.Color::new(8, 10, 14, 220),
    )
    @raylib.draw_text(msg, 26, 729, 18, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("ROUND OVER", 430, 320, 56, @raylib.orange)
      @raylib.draw_text("Press R to restart", 450, 386, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
