///|
let sw : Int = 1200

///|
let sh : Int = 740

///|
let ground_y : Float = 640.0

///|
struct Arrow {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
}

///|
struct Target {
  mut alive : Bool
  mut x : Float
  y : Float
  r : Float
  mut vx : Float
  points : Int
}

///|
fn reset_targets(ts : Array[Target]) -> Unit {
  ts[0] = { alive: true, x: 920.0, y: 430.0, r: 34.0, vx: 90.0, points: 30 }
  ts[1] = { alive: true, x: 1040.0, y: 360.0, r: 26.0, vx: -120.0, points: 45 }
  ts[2] = { alive: true, x: 860.0, y: 300.0, r: 20.0, vx: 70.0, points: 60 }
  ts[3] = { alive: true, x: 980.0, y: 250.0, r: 16.0, vx: -95.0, points: 75 }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Archery Tournament 2026")
  @raylib.set_target_fps(60)

  let arrow : Arrow = {
    alive: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
  }

  let targets : Array[Target] = Array::makei(4, fn(_i) {
    {
      alive: true,
      x: 0.0,
      y: 0.0,
      r: 20.0,
      vx: 0.0,
      points: 20,
    }
  })
  reset_targets(targets)

  let archer_x : Float = 110.0
  let archer_y : Float = ground_y

  let mut arc_power : Float = 500.0
  let mut arc_lift : Float = 280.0
  let mut wind : Float = 0.0
  let mut wind_tick : Float = 0.0

  let mut arrows_left = 18
  let mut score = 0
  let mut combo = 0
  let mut best_hit = 0
  let mut msg = "A/D power  W/S arc  Space shoot  R restart"
  let mut over = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      arrow.alive = false
      reset_targets(targets)
      arc_power = 500.0
      arc_lift = 280.0
      wind = 0.0
      wind_tick = 0.0
      arrows_left = 18
      score = 0
      combo = 0
      best_hit = 0
      over = false
      msg = "Tournament restarted."
    }

    if not(over) {
      if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
        arc_power = arc_power - 220.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
        arc_power = arc_power + 220.0 * dt
      }
      if arc_power < 260.0 {
        arc_power = 260.0
      }
      if arc_power > 760.0 {
        arc_power = 760.0
      }

      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        arc_lift = arc_lift + 180.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
        arc_lift = arc_lift - 180.0 * dt
      }
      if arc_lift < 120.0 {
        arc_lift = 120.0
      }
      if arc_lift > 460.0 {
        arc_lift = 460.0
      }

      wind_tick = wind_tick + dt
      if wind_tick >= 2.8 {
        wind_tick = wind_tick - 2.8
        wind = Float::from_int(@raylib.get_random_value(-90, 90))
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) && not(arrow.alive) && arrows_left > 0 {
        arrow.alive = true
        arrow.x = archer_x + 26.0
        arrow.y = archer_y - 32.0
        arrow.vx = arc_power
        arrow.vy = -arc_lift
        arrows_left = arrows_left - 1
      }

      for i = 0; i < targets.length(); i = i + 1 {
        if targets[i].alive {
          targets[i].x = targets[i].x + targets[i].vx * dt
          if targets[i].x < 760.0 {
            targets[i].x = 760.0
            targets[i].vx = targets[i].vx.abs()
          }
          if targets[i].x > Float::from_int(sw - 80) {
            targets[i].x = Float::from_int(sw - 80)
            targets[i].vx = -targets[i].vx.abs()
          }
        }
      }

      if arrow.alive {
        arrow.vx = arrow.vx + wind * dt * 0.28
        arrow.vy = arrow.vy + 620.0 * dt
        arrow.x = arrow.x + arrow.vx * dt
        arrow.y = arrow.y + arrow.vy * dt

        for i = 0; i < targets.length(); i = i + 1 {
          if not(targets[i].alive) {
            continue
          }
          let dx = targets[i].x - arrow.x
          let dy = targets[i].y - arrow.y
          if dx * dx + dy * dy <= targets[i].r * targets[i].r {
            let gain = targets[i].points + combo * 6
            score = score + gain
            combo = combo + 1
            if gain > best_hit {
              best_hit = gain
            }
            targets[i].alive = false
            arrow.alive = false
            msg = "Bullseye +\{gain}!"
            break
          }
        }

        if arrow.x > Float::from_int(sw + 20) || arrow.y > ground_y || arrow.y < 40.0 {
          arrow.alive = false
          combo = 0
          if arrows_left > 0 {
            msg = "Missed shot."
          }
        }
      }

      let mut alive_count = 0
      for i = 0; i < targets.length(); i = i + 1 {
        if targets[i].alive {
          alive_count = alive_count + 1
        }
      }
      if alive_count == 0 {
        reset_targets(targets)
        score = score + 50
        msg = "Wave cleared +50."
      }

      if arrows_left <= 0 && not(arrow.alive) {
        over = true
        msg = "Tournament ended."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(196, 228, 255, 255))

    @raylib.draw_rectangle(0, ground_y.to_int(), sw, sh - ground_y.to_int(), @raylib.Color::new(88, 138, 82, 255))

    // Archer
    @raylib.draw_circle(archer_x.to_int(), (archer_y - 52.0).to_int(), 16.0, @raylib.orange)
    @raylib.draw_rectangle((archer_x - 12.0).to_int(), (archer_y - 36.0).to_int(), 24, 34, @raylib.darkbrown)
    @raylib.draw_line((archer_x + 12.0).to_int(), (archer_y - 28.0).to_int(), (archer_x + 34.0).to_int(), (archer_y - 28.0).to_int(), @raylib.brown)
    @raylib.draw_circle_lines((archer_x + 40.0).to_int(), (archer_y - 28.0).to_int(), 14.0, @raylib.darkbrown)

    for i = 0; i < targets.length(); i = i + 1 {
      if targets[i].alive {
        @raylib.draw_circle(targets[i].x.to_int(), targets[i].y.to_int(), targets[i].r, @raylib.red)
        @raylib.draw_circle(targets[i].x.to_int(), targets[i].y.to_int(), targets[i].r * 0.68, @raylib.white)
        @raylib.draw_circle(targets[i].x.to_int(), targets[i].y.to_int(), targets[i].r * 0.36, @raylib.blue)
        @raylib.draw_text("\{targets[i].points}", (targets[i].x - 14.0).to_int(), (targets[i].y - 10.0).to_int(), 18, @raylib.black)
      }
    }

    if arrow.alive {
      @raylib.draw_line(
        (arrow.x - 18.0).to_int(),
        arrow.y.to_int(),
        (arrow.x + 18.0).to_int(),
        arrow.y.to_int(),
        @raylib.darkbrown,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(arrow.x + 18.0, arrow.y),
        @raylib.Vector2::new(arrow.x + 10.0, arrow.y - 4.0),
        @raylib.Vector2::new(arrow.x + 10.0, arrow.y + 4.0),
        @raylib.gray,
      )
    }

    @raylib.draw_text("ARCHERY TOURNAMENT 2026", 20, 18, 40, @raylib.darkblue)
    @raylib.draw_text("Score \{score}", 20, 66, 30, @raylib.black)
    @raylib.draw_text("Arrows \{arrows_left}", 220, 66, 30, @raylib.maroon)
    @raylib.draw_text("Combo x\{combo}", 430, 66, 30, @raylib.orange)
    @raylib.draw_text("Best Hit \{best_hit}", 620, 66, 30, @raylib.lime)

    @raylib.draw_text("Power \{arc_power.to_int()}", 20, 108, 26, @raylib.raywhite)
    @raylib.draw_rectangle(160, 114, 220, 14, @raylib.Color::new(40, 40, 40, 255))
    @raylib.draw_rectangle(160, 114, ((arc_power - 260.0) * 0.44).to_int(), 14, @raylib.blue)

    @raylib.draw_text("Arc \{arc_lift.to_int()}", 410, 108, 26, @raylib.raywhite)
    @raylib.draw_rectangle(510, 114, 220, 14, @raylib.Color::new(40, 40, 40, 255))
    @raylib.draw_rectangle(510, 114, ((arc_lift - 120.0) * 0.64).to_int(), 14, @raylib.green)

    @raylib.draw_text("Wind \{wind.to_int()}", 760, 108, 26, if wind > 0.0 { @raylib.red } else if wind < 0.0 { @raylib.blue } else { @raylib.gray })

    @raylib.draw_rectangle(20, 694, sw - 40, 30, @raylib.Color::new(18, 24, 30, 220))
    @raylib.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 560, 190, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("TOURNAMENT OVER", 360, 320, 56, @raylib.orange)
      @raylib.draw_text("Press R to restart", 450, 384, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
