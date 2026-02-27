///|
let sw : Int = 1100

///|
let sh : Int = 720

///|
struct Fish {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut kind : Int // 0 common, 1 silver, 2 golden
  mut size : Float
}

///|
fn fish_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.lime
  } else if kind == 1 {
    @raylib.skyblue
  } else {
    @raylib.gold
  }
}

///|
fn fish_value(kind : Int) -> Int {
  if kind == 0 {
    18
  } else if kind == 1 {
    42
  } else {
    88
  }
}

///|
fn spawn_fish(fishes : Array[Fish], rare_bonus : Int) -> Unit {
  for i = 0; i < fishes.length(); i = i + 1 {
    if not(fishes[i].alive) {
      let roll = @raylib.get_random_value(0, 99)
      let kind = if roll < 62 - rare_bonus {
        0
      } else if roll < 92 {
        1
      } else {
        2
      }

      let from_left = @raylib.get_random_value(0, 1) == 0
      fishes[i].alive = true
      fishes[i].kind = kind
      fishes[i].size = if kind == 0 {
        16.0
      } else if kind == 1 {
        22.0
      } else {
        28.0
      }
      fishes[i].x = if from_left { -40.0 } else { Float::from_int(sw + 40) }
      fishes[i].y = Float::from_int(@raylib.get_random_value(220, sh - 70))
      let speed = Float::from_int(@raylib.get_random_value(60, 130))
      fishes[i].vx = if from_left { speed } else { -speed }
      break
    }
  }
}

///|
fn reset_fishes(fishes : Array[Fish]) -> Unit {
  for i = 0; i < fishes.length(); i = i + 1 {
    fishes[i].alive = false
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Fishing Tycoon 2026")
  @raylib.set_target_fps(60)

  let fishes : Array[Fish] = Array::makei(90, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, kind: 0, size: 16.0 }
  })

  let boat_y : Float = 150.0
  let mut boat_x : Float = Float::from_int(sw / 2)

  let mut hook_x : Float = boat_x
  let mut hook_y : Float = boat_y + 20.0
  let mut hook_state = 0 // 0 idle, 1 dropping, 2 rising
  let mut max_depth : Float = 560.0
  let mut reel_speed : Float = 280.0
  let mut drop_speed : Float = 240.0

  let mut captured_idx = -1
  let mut spawn_tick : Float = 0.0
  let mut day_timer : Float = 180.0

  let mut money = 120
  let mut total_catch = 0
  let mut total_gold = 0

  let mut rare_bonus = 0
  let mut over = false
  let mut msg = "A/D move boat, Space/J cast hook, 1/2/3 buy upgrades"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      boat_x = Float::from_int(sw / 2)
      hook_x = boat_x
      hook_y = boat_y + 20.0
      hook_state = 0
      max_depth = 560.0
      reel_speed = 280.0
      drop_speed = 240.0
      captured_idx = -1
      reset_fishes(fishes)
      spawn_tick = 0.0
      day_timer = 180.0
      money = 120
      total_catch = 0
      total_gold = 0
      rare_bonus = 0
      over = false
      msg = "New fishing day started."
    }

    if not(over) {
      day_timer = day_timer - dt
      if day_timer <= 0.0 {
        day_timer = 0.0
        over = true
        msg = "Market closed for the day."
      }

      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        boat_x = boat_x - 260.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        boat_x = boat_x + 260.0 * dt
      }

      if boat_x < 80.0 {
        boat_x = 80.0
      }
      if boat_x > Float::from_int(sw - 80) {
        boat_x = Float::from_int(sw - 80)
      }

      if hook_state == 0 {
        hook_x = boat_x
        hook_y = boat_y + 20.0
        if @raylib.is_key_pressed(@raylib.KeySpace) ||
          @raylib.is_key_pressed(@raylib.KeyJ) {
          hook_state = 1
          captured_idx = -1
          msg = "Line cast."
        }
      }

      if hook_state == 1 {
        hook_y = hook_y + drop_speed * dt
        if hook_y >= max_depth {
          hook_state = 2
        }
      }

      if hook_state == 2 {
        hook_y = hook_y - reel_speed * dt
        if hook_y <= boat_y + 20.0 {
          hook_y = boat_y + 20.0
          hook_state = 0
          if captured_idx >= 0 {
            let gain = fish_value(fishes[captured_idx].kind)
            money = money + gain
            total_gold = total_gold + gain
            total_catch = total_catch + 1
            msg = "Sold catch for \{gain} coins."
            fishes[captured_idx].alive = false
            captured_idx = -1
          }
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyOne) {
        let cost = 90
        if money >= cost {
          money = money - cost
          reel_speed = reel_speed + 45.0
          msg = "Upgrade bought: faster reel."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        let cost = 120
        if money >= cost {
          money = money - cost
          max_depth = max_depth + 48.0
          if max_depth > Float::from_int(sh - 30) {
            max_depth = Float::from_int(sh - 30)
          }
          msg = "Upgrade bought: deeper line."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        let cost = 160
        if money >= cost {
          money = money - cost
          rare_bonus = rare_bonus + 8
          if rare_bonus > 34 {
            rare_bonus = 34
          }
          msg = "Upgrade bought: better bait."
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.42 {
        spawn_tick = spawn_tick - 0.42
        spawn_fish(fishes, rare_bonus)
      }

      for i = 0; i < fishes.length(); i = i + 1 {
        if not(fishes[i].alive) {
          continue
        }

        if captured_idx == i {
          fishes[i].x = hook_x
          fishes[i].y = hook_y + 10.0
          continue
        }

        fishes[i].x = fishes[i].x + fishes[i].vx * dt

        if fishes[i].x < -60.0 || fishes[i].x > Float::from_int(sw + 60) {
          fishes[i].alive = false
        }

        if captured_idx < 0 && hook_state != 0 {
          let dx = fishes[i].x - hook_x
          let dy = fishes[i].y - hook_y
          let r = fishes[i].size * 0.8
          if dx * dx + dy * dy <= r * r {
            captured_idx = i
            hook_state = 2
            msg = "Fish hooked! Reel it in."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 24, 42, 255))

    @raylib.draw_rectangle(
      0,
      0,
      sw,
      boat_y.to_int() + 30,
      @raylib.Color::new(35, 78, 122, 255),
    )
    @raylib.draw_rectangle(
      0,
      boat_y.to_int() + 30,
      sw,
      sh - (boat_y.to_int() + 30),
      @raylib.Color::new(18, 92, 148, 255),
    )

    @raylib.draw_rectangle(
      (boat_x - 48.0).to_int(),
      (boat_y - 14.0).to_int(),
      96,
      24,
      @raylib.brown,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(boat_x - 10.0, boat_y - 16.0),
      @raylib.Vector2::new(boat_x - 10.0, boat_y - 70.0),
      @raylib.Vector2::new(boat_x + 24.0, boat_y - 40.0),
      @raylib.white,
    )

    @raylib.draw_line_ex(
      @raylib.Vector2::new(boat_x, boat_y),
      @raylib.Vector2::new(hook_x, hook_y),
      2.0,
      @raylib.lightgray,
    )
    @raylib.draw_circle(hook_x.to_int(), hook_y.to_int(), 5.0, @raylib.white)

    for i = 0; i < fishes.length(); i = i + 1 {
      if fishes[i].alive {
        let c = fish_color(fishes[i].kind)
        @raylib.draw_ellipse(
          fishes[i].x.to_int(),
          fishes[i].y.to_int(),
          fishes[i].size,
          fishes[i].size * 0.62,
          c,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(fishes[i].x - fishes[i].size, fishes[i].y),
          @raylib.Vector2::new(
            fishes[i].x - fishes[i].size - 11.0,
            fishes[i].y - 8.0,
          ),
          @raylib.Vector2::new(
            fishes[i].x - fishes[i].size - 11.0,
            fishes[i].y + 8.0,
          ),
          c,
        )
        @raylib.draw_circle(
          (fishes[i].x + fishes[i].size * 0.35).to_int(),
          (fishes[i].y - 2.0).to_int(),
          2.5,
          @raylib.black,
        )
      }
    }

    @raylib.draw_text("FISHING TYCOON 2026", 20, 18, 42, @raylib.skyblue)
    @raylib.draw_text("Money \{money}", 20, 66, 30, @raylib.gold)
    @raylib.draw_text("Catch \{total_catch}", 220, 66, 30, @raylib.white)
    @raylib.draw_text("Sales \{total_gold}", 380, 66, 30, @raylib.white)

    let tsec = day_timer.to_int()
    @raylib.draw_text(
      "Time \{tsec}s",
      560,
      66,
      30,
      if tsec < 30 {
        @raylib.red
      } else {
        @raylib.lime
      },
    )

    @raylib.draw_text(
      "1 Reel+ (90)  2 Depth+ (120)  3 Bait+ (160)", 20, 618, 28, @raylib.raywhite,
    )
    @raylib.draw_text(
      "Reel \{reel_speed.to_int()}  Depth \{max_depth.to_int()}  Bait bonus \{rare_bonus}",
      20,
      650,
      26,
      @raylib.lightgray,
    )

    @raylib.draw_rectangle(
      20,
      678,
      sw - 40,
      30,
      @raylib.Color::new(8, 12, 18, 220),
    )
    @raylib.draw_text(msg, 28, 684, 20, @raylib.white)

    if over {
      @raylib.draw_rectangle(
        290,
        250,
        520,
        170,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("DAY OVER", 455, 298, 52, @raylib.orange)
      @raylib.draw_text("Press R for next day", 430, 360, 32, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
