///|
let sw : Int = 1080

///|
let sh : Int = 720

///|
let lane_count : Int = 5

///|
fn lane_x(lane : Int) -> Float {
  180.0 + Float::from_int(lane) * 180.0
}

///|
struct Obj {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut lane : Int
  mut kind : Int // 0 tree, 1 rock, 2 rescue, 3 boost
}

///|
fn reset_objs(objs : Array[Obj]) -> Unit {
  for i = 0; i < objs.length(); i = i + 1 {
    objs[i].alive = false
  }
}

///|
fn spawn_obj(objs : Array[Obj], lane : Int, kind : Int) -> Unit {
  for i = 0; i < objs.length(); i = i + 1 {
    if not(objs[i].alive) {
      objs[i].alive = true
      objs[i].lane = lane
      objs[i].x = lane_x(lane)
      objs[i].y = -40.0
      objs[i].kind = kind
      break
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Ski Rescue 2026")
  @raylib.set_target_fps(60)

  let objs : Array[Obj] = Array::makei(150, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, lane: 0, kind: 0 }
  })

  let mut player_lane = 2
  let mut player_x : Float = lane_x(player_lane)
  let player_y : Float = Float::from_int(sh - 120)

  let mut speed : Float = 280.0
  let mut spawn_tick : Float = 0.0
  let mut boost_timer : Float = 0.0
  let mut invuln_timer : Float = 0.0

  let mut score = 0
  let mut rescued = 0
  let mut distance = 0
  let mut lives = 3
  let mut over = false
  let mut msg = "A/D or arrows: move lanes, R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_lane = 2
      player_x = lane_x(player_lane)
      speed = 280.0
      spawn_tick = 0.0
      boost_timer = 0.0
      invuln_timer = 0.0
      score = 0
      rescued = 0
      distance = 0
      lives = 3
      over = false
      msg = "Rescue run restarted."
      reset_objs(objs)
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        if player_lane > 0 {
          player_lane = player_lane - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        if player_lane < lane_count - 1 {
          player_lane = player_lane + 1
        }
      }
      player_x = lane_x(player_lane)

      boost_timer = boost_timer - dt
      invuln_timer = invuln_timer - dt

      let run_speed = if boost_timer > 0.0 { speed * 1.45 } else { speed }
      speed = speed + dt * 7.0
      distance = distance + (run_speed * dt).to_int()
      score = score + (run_speed * dt * 0.12).to_int()

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.27 {
        spawn_tick = spawn_tick - 0.27
        let lane = @raylib.get_random_value(0, lane_count - 1)
        let r = @raylib.get_random_value(0, 99)
        if r < 38 {
          spawn_obj(objs, lane, 0)
        } else if r < 63 {
          spawn_obj(objs, lane, 1)
        } else if r < 86 {
          spawn_obj(objs, lane, 2)
        } else {
          spawn_obj(objs, lane, 3)
        }
      }

      for i = 0; i < objs.length(); i = i + 1 {
        if not(objs[i].alive) {
          continue
        }

        objs[i].y = objs[i].y + run_speed * dt

        if objs[i].y > Float::from_int(sh + 60) {
          objs[i].alive = false
          continue
        }

        if objs[i].lane != player_lane {
          continue
        }

        let dy = (objs[i].y - player_y).abs()
        if dy < 36.0 {
          if objs[i].kind == 0 || objs[i].kind == 1 {
            if invuln_timer <= 0.0 {
              lives = lives - 1
              invuln_timer = 1.1
              score = score - 40
              msg = if objs[i].kind == 0 { "Crashed into tree." } else { "Hit a rock." }
            }
            objs[i].alive = false
          } else if objs[i].kind == 2 {
            rescued = rescued + 1
            score = score + 120
            msg = "Civilian rescued!"
            objs[i].alive = false
          } else {
            boost_timer = 3.2
            score = score + 45
            msg = "Speed boost collected."
            objs[i].alive = false
          }
        }
      }

      if lives <= 0 {
        over = true
        msg = "Rescue run failed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(189, 222, 245, 255))

    @raylib.draw_triangle(
      @raylib.Vector2::new(60.0, 0.0),
      @raylib.Vector2::new(360.0, 0.0),
      @raylib.Vector2::new(220.0, 160.0),
      @raylib.Color::new(160, 178, 192, 255),
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(700.0, 0.0),
      @raylib.Vector2::new(1040.0, 0.0),
      @raylib.Vector2::new(860.0, 170.0),
      @raylib.Color::new(168, 188, 203, 255),
    )

    for l = 0; l < lane_count; l = l + 1 {
      let x = lane_x(l)
      @raylib.draw_line((x - 54.0).to_int(), 0, (x + 54.0).to_int(), sh, @raylib.fade(@raylib.gray, 0.35))
      @raylib.draw_line((x + 54.0).to_int(), 0, (x - 54.0).to_int(), sh, @raylib.fade(@raylib.gray, 0.35))
    }

    for i = 0; i < objs.length(); i = i + 1 {
      if objs[i].alive {
        let x = objs[i].x
        let y = objs[i].y
        if objs[i].kind == 0 {
          @raylib.draw_triangle(
            @raylib.Vector2::new(x, y - 26.0),
            @raylib.Vector2::new(x - 22.0, y + 14.0),
            @raylib.Vector2::new(x + 22.0, y + 14.0),
            @raylib.darkgreen,
          )
          @raylib.draw_rectangle((x - 4.0).to_int(), (y + 14.0).to_int(), 8, 10, @raylib.brown)
        } else if objs[i].kind == 1 {
          @raylib.draw_circle(x.to_int(), y.to_int(), 14.0, @raylib.darkgray)
          @raylib.draw_circle_lines(x.to_int(), y.to_int(), 14.0, @raylib.black)
        } else if objs[i].kind == 2 {
          @raylib.draw_circle(x.to_int(), y.to_int(), 13.0, @raylib.orange)
          @raylib.draw_text("!", (x - 4.0).to_int(), (y - 11.0).to_int(), 22, @raylib.white)
        } else {
          @raylib.draw_circle(x.to_int(), y.to_int(), 12.0, @raylib.lime)
          @raylib.draw_text("+", (x - 6.0).to_int(), (y - 11.0).to_int(), 22, @raylib.black)
        }
      }
    }

    let skier_color = if invuln_timer > 0.0 { @raylib.yellow } else { @raylib.red }
    @raylib.draw_circle(player_x.to_int(), player_y.to_int(), 14.0, skier_color)
    @raylib.draw_rectangle((player_x - 18.0).to_int(), (player_y + 13.0).to_int(), 36, 5, @raylib.blue)
    @raylib.draw_rectangle((player_x - 18.0).to_int(), (player_y + 20.0).to_int(), 36, 5, @raylib.blue)

    @raylib.draw_text("SKI RESCUE 2026", 20, 16, 42, @raylib.darkblue)
    @raylib.draw_text("Score \{score}", 20, 66, 30, @raylib.black)
    @raylib.draw_text("Rescued \{rescued}", 210, 66, 30, @raylib.darkgreen)
    @raylib.draw_text("Distance \{distance}m", 430, 66, 30, @raylib.black)
    @raylib.draw_text("Lives \{lives}", 690, 66, 30, if lives == 1 { @raylib.red } else { @raylib.maroon })

    if boost_timer > 0.0 {
      @raylib.draw_text("BOOST", 900, 66, 30, @raylib.lime)
    }

    @raylib.draw_rectangle(20, 670, sw - 40, 34, @raylib.Color::new(22, 38, 56, 230))
    @raylib.draw_text(msg, 28, 676, 22, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 500, 180, @raylib.fade(@raylib.black, 0.8))
      @raylib.draw_text("MISSION FAILED", 380, 310, 52, @raylib.red)
      @raylib.draw_text("Press R to retry", 440, 368, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
