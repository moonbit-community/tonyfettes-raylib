///|
let sw : Int = 1140

///|
let sh : Int = 720

///|
let lane_count : Int = 4

///|
fn lane_y(lane : Int) -> Float {
  220.0 + Float::from_int(lane) * 105.0
}

///|
struct Package {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut lane : Int
  mut code : Int // 0..3 destination
  mut speed : Float
}

///|
fn reset_packages(ps : Array[Package]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].alive = false
  }
}

///|
fn spawn_package(ps : Array[Package]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    if not(ps[i].alive) {
      let lane = @raylib.get_random_value(0, lane_count - 1)
      ps[i].alive = true
      ps[i].x = 80.0
      ps[i].lane = lane
      ps[i].y = lane_y(lane)
      ps[i].code = @raylib.get_random_value(0, 3)
      ps[i].speed = Float::from_int(@raylib.get_random_value(140, 230))
      break
    }
  }
}

///|
fn code_color(code : Int) -> @raylib.Color {
  if code == 0 {
    @raylib.red
  } else if code == 1 {
    @raylib.skyblue
  } else if code == 2 {
    @raylib.lime
  } else {
    @raylib.gold
  }
}

///|
fn code_label(code : Int) -> String {
  if code == 0 {
    "A"
  } else if code == 1 {
    "B"
  } else if code == 2 {
    "C"
  } else {
    "D"
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Post Office Sorter 2026")
  @raylib.set_target_fps(60)

  let packages : Array[Package] = Array::makei(120, fn(_i) {
    {
      alive: false,
      x: 0.0,
      y: 0.0,
      lane: 0,
      code: 0,
      speed: 180.0,
    }
  })

  let mut sorter_lane = 1
  let mut sorter_x : Float = 560.0
  let sorter_width : Float = 120.0

  let mut chute_map : Array[Int] = [0, 1, 2, 3] // lane->code

  let mut spawn_tick : Float = 0.0
  let mut score = 0
  let mut correct = 0
  let mut wrong = 0
  let mut missed = 0
  let mut lives = 5
  let mut over = false
  let mut msg = "W/S move sorter lane, A/D switch sorter position, 1-4 remap lane"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      sorter_lane = 1
      sorter_x = 560.0
      chute_map = [0, 1, 2, 3]
      spawn_tick = 0.0
      score = 0
      correct = 0
      wrong = 0
      missed = 0
      lives = 5
      over = false
      msg = "Sorting shift restarted."
      reset_packages(packages)
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyW) || @raylib.is_key_pressed(@raylib.KeyUp) {
        if sorter_lane > 0 {
          sorter_lane = sorter_lane - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyS) || @raylib.is_key_pressed(@raylib.KeyDown) {
        if sorter_lane < lane_count - 1 {
          sorter_lane = sorter_lane + 1
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        sorter_x = sorter_x - 44.0
      }
      if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        sorter_x = sorter_x + 44.0
      }
      if sorter_x < 320.0 {
        sorter_x = 320.0
      }
      if sorter_x > 760.0 {
        sorter_x = 760.0
      }

      if @raylib.is_key_pressed(@raylib.KeyOne) {
        chute_map[sorter_lane] = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        chute_map[sorter_lane] = 1
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        chute_map[sorter_lane] = 2
      }
      if @raylib.is_key_pressed(@raylib.KeyFour) {
        chute_map[sorter_lane] = 3
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.33 {
        spawn_tick = spawn_tick - 0.33
        spawn_package(packages)
      }

      for i = 0; i < packages.length(); i = i + 1 {
        if not(packages[i].alive) {
          continue
        }

        packages[i].x = packages[i].x + packages[i].speed * dt

        if packages[i].x >= sorter_x - sorter_width / 2.0 && packages[i].x <= sorter_x + sorter_width / 2.0 {
          if packages[i].lane == sorter_lane {
            // Divert to selected lane mapping
            let out_code = chute_map[sorter_lane]
            if out_code == packages[i].code {
              score = score + 28
              correct = correct + 1
              msg = "Correct sort."
            } else {
              score = score - 18
              wrong = wrong + 1
              lives = lives - 1
              msg = "Wrong destination mapping."
            }
            packages[i].alive = false
            continue
          }
        }

        if packages[i].x > Float::from_int(sw - 70) {
          packages[i].alive = false
          missed = missed + 1
          score = score - 12
          lives = lives - 1
          msg = "Package missed the sorter."
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Sorting line shut down."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(26, 30, 36, 255))

    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(44, 52, 66, 255))
    @raylib.draw_rectangle(40, 170, sw - 80, 500, @raylib.Color::new(220, 226, 232, 255))

    for l = 0; l < lane_count; l = l + 1 {
      let y = lane_y(l)
      @raylib.draw_line(60, y.to_int(), sw - 60, y.to_int(), @raylib.gray)
      @raylib.draw_line(60, y.to_int() + 8, sw - 60, y.to_int() + 8, @raylib.darkgray)

      let code = chute_map[l]
      let col = code_color(code)
      @raylib.draw_rectangle(sw - 120, y.to_int() - 20, 52, 34, col)
      @raylib.draw_text(code_label(code), sw - 102, y.to_int() - 14, 24, @raylib.black)

      if l == sorter_lane {
        @raylib.draw_rectangle_lines(54, y.to_int() - 24, sw - 108, 44, @raylib.orange)
      }
    }

    // Sorter gate
    let sy = lane_y(sorter_lane)
    @raylib.draw_rectangle(
      (sorter_x - sorter_width / 2.0).to_int(),
      (sy - 26.0).to_int(),
      sorter_width.to_int(),
      22,
      @raylib.blue,
    )
    @raylib.draw_text("GATE", (sorter_x - 28.0).to_int(), (sy - 22.0).to_int(), 18, @raylib.white)

    for i = 0; i < packages.length(); i = i + 1 {
      if packages[i].alive {
        let col = code_color(packages[i].code)
        @raylib.draw_rectangle((packages[i].x - 16.0).to_int(), (packages[i].y - 16.0).to_int(), 32, 24, col)
        @raylib.draw_rectangle_lines((packages[i].x - 16.0).to_int(), (packages[i].y - 16.0).to_int(), 32, 24, @raylib.black)
        @raylib.draw_text(code_label(packages[i].code), (packages[i].x - 6.0).to_int(), (packages[i].y - 13.0).to_int(), 18, @raylib.black)
      }
    }

    @raylib.draw_text("POST OFFICE SORTER 2026", 20, 18, 38, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 62, 28, @raylib.white)
    @raylib.draw_text("Correct \{correct}", 190, 62, 28, @raylib.lime)
    @raylib.draw_text("Wrong \{wrong}", 390, 62, 28, @raylib.orange)
    @raylib.draw_text("Missed \{missed}", 560, 62, 28, @raylib.orange)
    @raylib.draw_text("Lives \{lives}", 760, 62, 28, if lives <= 1 { @raylib.red } else { @raylib.yellow })

    @raylib.draw_text("Lane Mapping Keys: on selected lane, press 1=A 2=B 3=C 4=D", 20, 652, 24, @raylib.darkblue)
    @raylib.draw_rectangle(20, 688, sw - 40, 30, @raylib.Color::new(15, 20, 28, 220))
    @raylib.draw_text(msg, 28, 693, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 540, 180, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("LINE STOPPED", 430, 312, 52, @raylib.red)
      @raylib.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
