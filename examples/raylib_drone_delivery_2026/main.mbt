///|
let sw : Int = 1120

///|
let sh : Int = 740

///|
struct Orb {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
}

///|
fn spawn_orb(orbs : Array[Orb], cx : Float, cy : Float) -> Unit {
  for i = 0; i < orbs.length(); i = i + 1 {
    if not(orbs[i].alive) {
      orbs[i].alive = true
      orbs[i].x = cx
      orbs[i].y = cy
      orbs[i].vx = Float::from_int(@raylib.get_random_value(-180, 180))
      orbs[i].vy = Float::from_int(@raylib.get_random_value(-180, 180))
      break
    }
  }
}

///|
fn reset_orbs(orbs : Array[Orb]) -> Unit {
  for i = 0; i < orbs.length(); i = i + 1 {
    orbs[i].alive = false
  }
}

///|
fn random_point(margin : Int) -> (Float, Float) {
  (
    Float::from_int(@raylib.get_random_value(margin, sw - margin)),
    Float::from_int(@raylib.get_random_value(margin + 60, sh - margin)),
  )
}

///|
fn dist_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn main {
  @raylib.init_window(sw, sh, "Drone Delivery 2026")
  @raylib.set_target_fps(60)

  let orbs : Array[Orb] = Array::makei(110, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0 }
  })

  let mut drone_x : Float = Float::from_int(sw / 2)
  let mut drone_y : Float = Float::from_int(sh / 2)
  let mut battery : Float = 100.0
  let mut heat : Float = 0.0

  let mut has_package = false
  let mut pick_x : Float = 0.0
  let mut pick_y : Float = 0.0
  let mut drop_x : Float = 0.0
  let mut drop_y : Float = 0.0

  let mut timer : Float = 90.0
  let mut score = 0
  let mut deliveries = 0
  let mut combo = 0
  let mut over = false
  let mut msg = "WASD/Arrows move, avoid shock orbs, pick P and deliver D"

  let (px0, py0) = random_point(120)
  pick_x = px0
  pick_y = py0
  let (dx0, dy0) = random_point(120)
  drop_x = dx0
  drop_y = dy0

  let mut orb_spawn_tick : Float = 0.0

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      drone_x = Float::from_int(sw / 2)
      drone_y = Float::from_int(sh / 2)
      battery = 100.0
      heat = 0.0
      has_package = false
      let (p1x, p1y) = random_point(120)
      pick_x = p1x
      pick_y = p1y
      let (d1x, d1y) = random_point(120)
      drop_x = d1x
      drop_y = d1y
      timer = 90.0
      score = 0
      deliveries = 0
      combo = 0
      over = false
      msg = "Route reset."
      reset_orbs(orbs)
      orb_spawn_tick = 0.0
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Shift ended."
      }

      let mut mx : Float = (0.0 : Float)
      let mut my : Float = (0.0 : Float)
      if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
        mx = mx - (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
        mx = mx + (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        my = my - (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
        my = my + (1.0 : Float)
      }

      let turbo = @raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyJ)
      let spd : Float =
        if turbo { (370.0 : Float) } else { (250.0 : Float) }
      drone_x = drone_x + mx * spd * dt
      drone_y = drone_y + my * spd * dt

      if drone_x < 40.0 {
        drone_x = 40.0
      }
      if drone_x > Float::from_int(sw - 40) {
        drone_x = Float::from_int(sw - 40)
      }
      if drone_y < 80.0 {
        drone_y = 80.0
      }
      if drone_y > Float::from_int(sh - 40) {
        drone_y = Float::from_int(sh - 40)
      }

      let drain : Float =
        if turbo { (17.0 : Float) } else { (8.0 : Float) }
      battery = battery - dt * drain
      let heat_gain : Float =
        if turbo { (18.0 : Float) } else { (7.5 : Float) }
      heat = heat + dt * heat_gain
      heat = heat - dt * (9.0 : Float)
      if heat < 0.0 {
        heat = 0.0
      }

      if battery <= 0.0 {
        battery = 0.0
        over = true
        msg = "Battery depleted."
      }
      if heat >= 100.0 {
        heat = 100.0
        over = true
        msg = "Drone overheated."
      }

      orb_spawn_tick = orb_spawn_tick + dt
      if orb_spawn_tick >= 0.55 {
        orb_spawn_tick = orb_spawn_tick - 0.55
        let ox = Float::from_int(@raylib.get_random_value(80, sw - 80))
        let oy = Float::from_int(@raylib.get_random_value(100, sh - 80))
        spawn_orb(orbs, ox, oy)
      }

      for i = 0; i < orbs.length(); i = i + 1 {
        if not(orbs[i].alive) {
          continue
        }

        orbs[i].x = orbs[i].x + orbs[i].vx * dt
        orbs[i].y = orbs[i].y + orbs[i].vy * dt

        if orbs[i].x < 20.0 || orbs[i].x > Float::from_int(sw - 20) {
          orbs[i].vx = -orbs[i].vx
        }
        if orbs[i].y < 70.0 || orbs[i].y > Float::from_int(sh - 20) {
          orbs[i].vy = -orbs[i].vy
        }

        if dist_sq(drone_x, drone_y, orbs[i].x, orbs[i].y) < 26.0 * 26.0 {
          orbs[i].alive = false
          combo = 0
          score = score - 40
          battery = battery - 9.0
          heat = heat + 20.0
          msg = "Shock hit!"
        }
      }

      if not(has_package) {
        if dist_sq(drone_x, drone_y, pick_x, pick_y) < 28.0 * 28.0 {
          has_package = true
          timer = timer + 7.0
          if timer > 99.0 {
            timer = 99.0
          }
          msg = "Package picked. Deliver to D."
        }
      } else {
        if dist_sq(drone_x, drone_y, drop_x, drop_y) < 28.0 * 28.0 {
          has_package = false
          deliveries = deliveries + 1
          combo = combo + 1
          let gain = 120 + combo * 20
          score = score + gain
          timer = timer + 4.0
          if timer > 99.0 {
            timer = 99.0
          }
          msg = "Delivery complete +\{gain}."

          let (pnx, pny) = random_point(120)
          pick_x = pnx
          pick_y = pny
          let (dnx, dny) = random_point(120)
          drop_x = dnx
          drop_y = dny
        }
      }

      // Passive score over distance flown
      score = score + (spd * dt * (0.02 : Float)).to_int()
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 21, 32, 255))

    // City blocks
    for gx = 0; gx < 7; gx = gx + 1 {
      for gy = 0; gy < 4; gy = gy + 1 {
        let bx = 42 + gx * 155
        let by = 90 + gy * 155
        @raylib.draw_rectangle(bx, by, 110, 110, @raylib.Color::new(33, 38, 50, 255))
        @raylib.draw_rectangle_lines(bx, by, 110, 110, @raylib.Color::new(55, 63, 83, 255))
      }
    }

    if not(has_package) {
      @raylib.draw_circle(pick_x.to_int(), pick_y.to_int(), 16.0, @raylib.lime)
      @raylib.draw_text("P", (pick_x - 6.0).to_int(), (pick_y - 11.0).to_int(), 24, @raylib.black)
    } else {
      @raylib.draw_circle(drop_x.to_int(), drop_y.to_int(), 16.0, @raylib.orange)
      @raylib.draw_text("D", (drop_x - 7.0).to_int(), (drop_y - 11.0).to_int(), 24, @raylib.black)
    }

    for i = 0; i < orbs.length(); i = i + 1 {
      if orbs[i].alive {
        @raylib.draw_circle(orbs[i].x.to_int(), orbs[i].y.to_int(), 11.0, @raylib.skyblue)
        @raylib.draw_circle_lines(orbs[i].x.to_int(), orbs[i].y.to_int(), 11.0, @raylib.white)
      }
    }

    let body = if has_package { @raylib.gold } else { @raylib.raywhite }
    @raylib.draw_circle(drone_x.to_int(), drone_y.to_int(), 14.0, body)
    @raylib.draw_line((drone_x - 22.0).to_int(), drone_y.to_int(), (drone_x + 22.0).to_int(), drone_y.to_int(), @raylib.gray)
    @raylib.draw_line(drone_x.to_int(), (drone_y - 22.0).to_int(), drone_x.to_int(), (drone_y + 22.0).to_int(), @raylib.gray)

    @raylib.draw_text("DRONE DELIVERY 2026", 20, 16, 40, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 64, 30, @raylib.white)
    @raylib.draw_text("Deliveries \{deliveries}", 220, 64, 30, @raylib.lime)
    @raylib.draw_text("Combo x\{combo}", 460, 64, 30, @raylib.yellow)

    let t = timer.to_int()
    @raylib.draw_text("Time \{t}s", 660, 64, 30, if t < 20 { @raylib.red } else { @raylib.orange })

    @raylib.draw_text("Battery", 20, 104, 24, @raylib.green)
    @raylib.draw_rectangle(110, 110, 230, 14, @raylib.Color::new(20, 38, 24, 255))
    @raylib.draw_rectangle(110, 110, (battery * 2.3).to_int(), 14, @raylib.green)

    @raylib.draw_text("Heat", 360, 104, 24, @raylib.red)
    @raylib.draw_rectangle(430, 110, 230, 14, @raylib.Color::new(45, 20, 20, 255))
    @raylib.draw_rectangle(430, 110, (heat * 2.3).to_int(), 14, @raylib.red)

    @raylib.draw_rectangle(20, 694, sw - 40, 30, @raylib.Color::new(8, 10, 16, 220))
    @raylib.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(290, 250, 540, 180, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("SHIFT OVER", 430, 308, 50, @raylib.orange)
      @raylib.draw_text("Press R to restart", 430, 366, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
