///|
let sw : Int = 1080

///|
let sh : Int = 720

///|
let lane_count : Int = 5

///|
fn lane_x(lane : Int) -> Float {
  160.0 + Float::from_int(lane) * 185.0
}

///|
struct Drop {
  mut alive : Bool
  mut lane : Int
  mut x : Float
  mut y : Float
  mut kind : Int // 0 tomato, 1 beef, 2 fish, 3 lettuce, 4 trash
  mut vy : Float
}

///|
fn ingredient_name(kind : Int) -> String {
  if kind == 0 {
    "Tomato"
  } else if kind == 1 {
    "Beef"
  } else if kind == 2 {
    "Fish"
  } else if kind == 3 {
    "Lettuce"
  } else {
    "Trash"
  }
}

///|
fn ingredient_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.red
  } else if kind == 1 {
    @raylib.brown
  } else if kind == 2 {
    @raylib.skyblue
  } else if kind == 3 {
    @raylib.lime
  } else {
    @raylib.darkgray
  }
}

///|
fn reset_drops(drops : Array[Drop]) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    drops[i].alive = false
  }
}

///|
fn spawn_drop(
  drops : Array[Drop],
  lane : Int,
  kind : Int,
  speed : Float,
) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].alive) {
      drops[i].alive = true
      drops[i].lane = lane
      drops[i].x = lane_x(lane)
      drops[i].y = -30.0
      drops[i].kind = kind
      drops[i].vy = speed
      break
    }
  }
}

///|
fn next_order() -> (Int, Int) {
  (@raylib.get_random_value(0, 3), @raylib.get_random_value(2, 4))
}

///|
fn main {
  @raylib.init_window(sw, sh, "Chef Rush 2026")
  @raylib.set_target_fps(60)

  let drops : Array[Drop] = Array::makei(140, fn(_i) {
    { alive: false, lane: 0, x: 0.0, y: 0.0, kind: 0, vy: 200.0 }
  })

  let mut player_lane = 2
  let mut px : Float = lane_x(player_lane)
  let py : Float = Float::from_int(sh - 110)

  let mut timer : Float = 120.0
  let mut lives = 3
  let mut score = 0
  let mut served = 0

  let (ok, on) = next_order()
  let mut order_kind = ok
  let mut order_need = on
  let mut order_have = 0

  let mut spawn_tick : Float = 0.0
  let mut over = false
  let mut msg = "A/D move, catch ingredients, Space serves finished order"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_lane = 2
      px = lane_x(player_lane)
      timer = 120.0
      lives = 3
      score = 0
      served = 0
      let (rk, rn) = next_order()
      order_kind = rk
      order_need = rn
      order_have = 0
      spawn_tick = 0.0
      over = false
      msg = "Kitchen shift restarted."
      reset_drops(drops)
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Shift ended."
      }

      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        if player_lane > 0 {
          player_lane = player_lane - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        if player_lane < lane_count - 1 {
          player_lane = player_lane + 1
        }
      }
      px = lane_x(player_lane)

      if (
          @raylib.is_key_pressed(@raylib.KeySpace) ||
          @raylib.is_key_pressed(@raylib.KeyEnter)
        ) &&
        order_have >= order_need {
        served = served + 1
        let gain = 100 + order_need * 20
        score = score + gain
        timer = timer + 7.0
        if timer > 130.0 {
          timer = 130.0
        }
        let (nk, nn) = next_order()
        order_kind = nk
        order_need = nn
        order_have = 0
        msg = "Order served +\{gain}."
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.30 {
        spawn_tick = spawn_tick - 0.30
        let lane = @raylib.get_random_value(0, lane_count - 1)
        let roll = @raylib.get_random_value(0, 99)
        let kind = if roll < 14 { 4 } else { @raylib.get_random_value(0, 3) }
        let speed = Float::from_int(@raylib.get_random_value(180, 320))
        spawn_drop(drops, lane, kind, speed)
      }

      for i = 0; i < drops.length(); i = i + 1 {
        if not(drops[i].alive) {
          continue
        }

        drops[i].y = drops[i].y + drops[i].vy * dt

        if drops[i].y > Float::from_int(sh + 40) {
          drops[i].alive = false
          if drops[i].kind == order_kind {
            score = score - 8
            msg = "Needed ingredient missed."
          }
          continue
        }

        if drops[i].lane != player_lane {
          continue
        }

        if (drops[i].y - py).abs() < 34.0 {
          if drops[i].kind == 4 {
            drops[i].alive = false
            lives = lives - 1
            score = score - 30
            msg = "Caught trash!"
          } else if drops[i].kind == order_kind {
            drops[i].alive = false
            if order_have < order_need {
              order_have = order_have + 1
              score = score + 18
              msg = "Correct ingredient captured."
            } else {
              score = score + 4
            }
          } else {
            drops[i].alive = false
            score = score - 6
            timer = timer - 1.8
            if timer < 0.0 {
              timer = 0.0
            }
            msg = "Wrong ingredient for current order."
          }
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Kitchen disaster."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(24, 24, 24, 255))

    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(42, 30, 26, 255))
    @raylib.draw_rectangle(
      0,
      130,
      sw,
      sh - 130,
      @raylib.Color::new(232, 220, 196, 255),
    )

    for l = 0; l < lane_count; l = l + 1 {
      let x = lane_x(l)
      @raylib.draw_line(
        x.to_int(),
        130,
        x.to_int(),
        sh,
        @raylib.fade(@raylib.brown, 0.4),
      )
      @raylib.draw_circle(x.to_int(), 110, 16.0, @raylib.darkbrown)
      @raylib.draw_circle(x.to_int(), 116, 6.0, @raylib.black)
    }

    for i = 0; i < drops.length(); i = i + 1 {
      if drops[i].alive {
        let c = ingredient_color(drops[i].kind)
        @raylib.draw_circle(drops[i].x.to_int(), drops[i].y.to_int(), 16.0, c)
        if drops[i].kind == 4 {
          @raylib.draw_text(
            "X",
            (drops[i].x - 6.0).to_int(),
            (drops[i].y - 10.0).to_int(),
            22,
            @raylib.white,
          )
        }
      }
    }

    // Chef
    @raylib.draw_circle(px.to_int(), py.to_int(), 20.0, @raylib.white)
    @raylib.draw_rectangle(
      (px - 20.0).to_int(),
      (py + 20.0).to_int(),
      40,
      26,
      @raylib.blue,
    )
    @raylib.draw_rectangle(
      (px - 28.0).to_int(),
      (py - 32.0).to_int(),
      56,
      8,
      @raylib.white,
    )

    // Order panel
    @raylib.draw_rectangle(
      18,
      16,
      520,
      106,
      @raylib.Color::new(18, 16, 14, 220),
    )
    @raylib.draw_text("CHEF RUSH 2026", 28, 22, 34, @raylib.gold)
    @raylib.draw_text(
      "Order: \{ingredient_name(order_kind)}  \{order_have}/\{order_need}",
      30,
      66,
      28,
      @raylib.raywhite,
    )
    if order_have >= order_need {
      @raylib.draw_text("READY! Press Space to serve", 30, 94, 22, @raylib.lime)
    }

    @raylib.draw_text("Score \{score}", 590, 24, 30, @raylib.white)
    @raylib.draw_text("Served \{served}", 590, 58, 30, @raylib.lime)
    @raylib.draw_text(
      "Lives \{lives}",
      590,
      92,
      30,
      if lives == 1 {
        @raylib.red
      } else {
        @raylib.maroon
      },
    )

    let sec = timer.to_int()
    @raylib.draw_text(
      "Time \{sec}s",
      820,
      24,
      34,
      if sec < 20 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )

    @raylib.draw_text(
      "Avoid trash (X), collect exact ingredient for order", 20, 654, 24, @raylib.darkbrown,
    )
    @raylib.draw_rectangle(
      20,
      684,
      sw - 40,
      28,
      @raylib.Color::new(20, 16, 13, 220),
    )
    @raylib.draw_text(msg, 28, 688, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        280,
        250,
        520,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("SHIFT OVER", 420, 312, 52, @raylib.orange)
      @raylib.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
