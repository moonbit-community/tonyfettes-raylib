///|
let sw : Int = 1120

///|
let sh : Int = 720

///|
let lane_count : Int = 3

///|
fn lane_y(lane : Int) -> Float {
  250.0 + Float::from_int(lane) * 140.0
}

///|
struct Hazard {
  mut alive : Bool
  mut x : Float
  mut lane : Int
  mut kind : Int // 0 low rock, 1 high wall, 2 coin
}

///|
fn reset_hazards(hazards : Array[Hazard]) -> Unit {
  for i = 0; i < hazards.length(); i = i + 1 {
    hazards[i].alive = false
  }
}

///|
fn spawn_hazard(hazards : Array[Hazard], lane : Int, kind : Int) -> Unit {
  for i = 0; i < hazards.length(); i = i + 1 {
    if not(hazards[i].alive) {
      hazards[i].alive = true
      hazards[i].x = Float::from_int(sw + 60)
      hazards[i].lane = lane
      hazards[i].kind = kind
      break
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Mine Cart Mayhem 2026")
  @raylib.set_target_fps(60)

  let hazards : Array[Hazard] = Array::makei(120, fn(_i) {
    { alive: false, x: 0.0, lane: 0, kind: 0 }
  })

  let cart_x : Float = 220.0
  let mut cart_lane = 1

  let mut jump_y : Float = 0.0
  let mut jump_v : Float = 0.0

  let mut speed : Float = 280.0
  let mut spawn_tick : Float = 0.0
  let mut score = 0
  let mut coins = 0
  let mut lives = 3
  let mut distance = 0

  let mut over = false
  let mut msg = "W/S or Up/Down switch rails, Space/J jump, R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_hazards(hazards)
      cart_lane = 1
      jump_y = 0.0
      jump_v = 0.0
      speed = 280.0
      spawn_tick = 0.0
      score = 0
      coins = 0
      lives = 3
      distance = 0
      over = false
      msg = "Run restarted."
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        if cart_lane > 0 {
          cart_lane = cart_lane - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        if cart_lane < lane_count - 1 {
          cart_lane = cart_lane + 1
        }
      }

      if (
          @raylib.is_key_pressed(@raylib.KeySpace) ||
          @raylib.is_key_pressed(@raylib.KeyJ)
        ) &&
        jump_y <= 0.0 {
        jump_v = 520.0
      }

      if jump_y > 0.0 || jump_v > 0.0 {
        jump_v = jump_v - 980.0 * dt
        jump_y = jump_y + jump_v * dt
        if jump_y < 0.0 {
          jump_y = 0.0
          jump_v = 0.0
        }
      }

      speed = speed + dt * 8.0
      distance = distance + (speed * dt).to_int()
      score = score + (speed * dt * 0.15).to_int()

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.36 {
        spawn_tick = spawn_tick - 0.36
        let lane = @raylib.get_random_value(0, lane_count - 1)
        let roll = @raylib.get_random_value(0, 99)
        if roll < 16 {
          spawn_hazard(hazards, lane, 2)
        } else if roll < 58 {
          spawn_hazard(hazards, lane, 0)
        } else {
          spawn_hazard(hazards, lane, 1)
        }
      }

      for i = 0; i < hazards.length(); i = i + 1 {
        if not(hazards[i].alive) {
          continue
        }

        hazards[i].x = hazards[i].x - speed * dt

        if hazards[i].x < -80.0 {
          hazards[i].alive = false
          continue
        }

        if hazards[i].lane != cart_lane {
          continue
        }

        let dx = (hazards[i].x - cart_x).abs()
        if dx < 34.0 {
          if hazards[i].kind == 2 {
            hazards[i].alive = false
            coins = coins + 1
            score = score + 35
            msg = "Coin collected."
          } else if hazards[i].kind == 0 {
            if jump_y < 24.0 {
              hazards[i].alive = false
              lives = lives - 1
              score = score - 18
              msg = "Hit by rock."
            }
          } else if jump_y < 72.0 {
            hazards[i].alive = false
            lives = lives - 1
            score = score - 28
            msg = "Slammed into wall."
          }
        }
      }

      if lives <= 0 {
        over = true
        msg = "Cart destroyed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(21, 18, 16, 255))

    for l = 0; l < lane_count; l = l + 1 {
      let y = lane_y(l)
      @raylib.draw_line(30, y.to_int(), sw - 20, y.to_int(), @raylib.darkgray)
      @raylib.draw_line(
        30,
        y.to_int() + 8,
        sw - 20,
        y.to_int() + 8,
        @raylib.gray,
      )
      @raylib.draw_rectangle(
        0,
        y.to_int() - 30,
        sw,
        22,
        @raylib.Color::new(43, 35, 28, 255),
      )
    }

    for i = 0; i < hazards.length(); i = i + 1 {
      if hazards[i].alive {
        let y = lane_y(hazards[i].lane)
        if hazards[i].kind == 0 {
          @raylib.draw_rectangle(
            (hazards[i].x - 18.0).to_int(),
            (y - 16.0).to_int(),
            36,
            20,
            @raylib.brown,
          )
          @raylib.draw_rectangle_lines(
            (hazards[i].x - 18.0).to_int(),
            (y - 16.0).to_int(),
            36,
            20,
            @raylib.black,
          )
        } else if hazards[i].kind == 1 {
          @raylib.draw_rectangle(
            (hazards[i].x - 16.0).to_int(),
            (y - 56.0).to_int(),
            32,
            56,
            @raylib.maroon,
          )
          @raylib.draw_rectangle_lines(
            (hazards[i].x - 16.0).to_int(),
            (y - 56.0).to_int(),
            32,
            56,
            @raylib.black,
          )
        } else {
          @raylib.draw_circle(
            hazards[i].x.to_int(),
            (y - 36.0).to_int(),
            10.0,
            @raylib.gold,
          )
          @raylib.draw_circle_lines(
            hazards[i].x.to_int(),
            (y - 36.0).to_int(),
            10.0,
            @raylib.yellow,
          )
        }
      }
    }

    let base_y = lane_y(cart_lane)
    let cart_y = base_y - jump_y
    @raylib.draw_rectangle(
      (cart_x - 28.0).to_int(),
      (cart_y - 22.0).to_int(),
      56,
      22,
      @raylib.skyblue,
    )
    @raylib.draw_rectangle(
      (cart_x - 24.0).to_int(),
      (cart_y - 30.0).to_int(),
      48,
      8,
      @raylib.blue,
    )
    @raylib.draw_circle(
      (cart_x - 16.0).to_int(),
      (cart_y + 2.0).to_int(),
      6.0,
      @raylib.black,
    )
    @raylib.draw_circle(
      (cart_x + 16.0).to_int(),
      (cart_y + 2.0).to_int(),
      6.0,
      @raylib.black,
    )

    @raylib.draw_text("MINE CART MAYHEM 2026", 20, 14, 40, @raylib.orange)
    @raylib.draw_text("Score \{score}", 20, 62, 30, @raylib.white)
    @raylib.draw_text("Distance \{distance}m", 220, 62, 30, @raylib.white)
    @raylib.draw_text("Coins \{coins}", 460, 62, 30, @raylib.gold)
    @raylib.draw_text(
      "Lives \{lives}",
      640,
      62,
      30,
      if lives == 1 {
        @raylib.red
      } else {
        @raylib.lime
      },
    )

    @raylib.draw_text(
      "Low rocks need jump. High walls need lane switch or high jump timing.", 20,
      620, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      670,
      sw - 40,
      34,
      @raylib.Color::new(8, 7, 6, 220),
    )
    @raylib.draw_text(msg, 30, 676, 22, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        290,
        250,
        550,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("RUN OVER", 470, 305, 54, @raylib.red)
      @raylib.draw_text("Press R to restart", 450, 368, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
