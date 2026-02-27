///|
let sw : Int = 1200

///|
let sh : Int = 760

///|
let lanes : Int = 4

///|
fn lane_y(lane : Int) -> Float {
  190.0 + Float::from_int(lane) * 120.0
}

///|
struct Train {
  mut alive : Bool
  mut x : Float
  mut lane : Int
  mut dir : Int
  mut speed : Float
  mut cargo : Int // 0 red, 1 blue
  mut gate_mask : Int
}

///|
fn spawn_train(
  trains : Array[Train],
  from_left : Bool,
  lane : Int,
  cargo : Int,
) -> Unit {
  for i = 0; i < trains.length(); i = i + 1 {
    if not(trains[i].alive) {
      trains[i].alive = true
      trains[i].x = if from_left { 80.0 } else { Float::from_int(sw - 80) }
      trains[i].lane = lane
      trains[i].dir = if from_left { 1 } else { -1 }
      trains[i].speed = Float::from_int(@raylib.get_random_value(130, 210))
      trains[i].cargo = cargo
      trains[i].gate_mask = 0
      break
    }
  }
}

///|
fn gate_bit(i : Int) -> Int {
  if i == 0 {
    1
  } else if i == 1 {
    2
  } else {
    4
  }
}

///|
fn apply_gate(train : Train, gate_i : Int, enabled : Bool) -> Unit {
  let bit = gate_bit(gate_i)
  if (train.gate_mask & bit) != 0 {
    return
  }
  train.gate_mask = train.gate_mask | bit

  if not(enabled) {
    return
  }

  if gate_i == 0 {
    if train.lane == 0 {
      train.lane = 1
    } else if train.lane == 1 {
      train.lane = 0
    }
  } else if gate_i == 1 {
    if train.lane == 1 {
      train.lane = 2
    } else if train.lane == 2 {
      train.lane = 1
    }
  } else if train.lane == 2 {
    train.lane = 3
  } else if train.lane == 3 {
    train.lane = 2
  }
}

///|
fn target_lane(dir : Int, cargo : Int) -> Int {
  if dir > 0 {
    if cargo == 0 {
      0
    } else {
      3
    }
  } else if cargo == 0 {
    3
  } else {
    0
  }
}

///|
fn reset_trains(trains : Array[Train]) -> Unit {
  for i = 0; i < trains.length(); i = i + 1 {
    trains[i].alive = false
  }
}

///|
fn train_color(cargo : Int) -> @raylib.Color {
  if cargo == 0 {
    @raylib.red
  } else {
    @raylib.skyblue
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Train Dispatch 2026")
  @raylib.set_target_fps(60)

  let trains : Array[Train] = Array::makei(80, fn(_i) {
    {
      alive: false,
      x: 0.0,
      lane: 0,
      dir: 1,
      speed: 160.0,
      cargo: 0,
      gate_mask: 0,
    }
  })

  let gate_x0 : Float = 430.0
  let gate_x1 : Float = 600.0
  let gate_x2 : Float = 770.0

  let mut gate0 = true
  let mut gate1 = false
  let mut gate2 = true

  let mut spawn_tick : Float = 0.0
  let mut score = 0
  let mut delivered = 0
  let mut missed = 0
  let mut combo = 0
  let mut lives = 5
  let mut over = false
  let mut msg = "Keys 1/2/3 toggle switches, R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_trains(trains)
      gate0 = true
      gate1 = false
      gate2 = true
      spawn_tick = 0.0
      score = 0
      delivered = 0
      missed = 0
      combo = 0
      lives = 5
      over = false
      msg = "Shift restarted. Route red/blue cargo correctly."
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        gate0 = not(gate0)
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        gate1 = not(gate1)
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        gate2 = not(gate2)
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.95 {
        spawn_tick = spawn_tick - 0.95
        let lane = @raylib.get_random_value(0, lanes - 1)
        let cargo = @raylib.get_random_value(0, 1)
        let from_left = @raylib.get_random_value(0, 1) == 0
        spawn_train(trains, from_left, lane, cargo)
      }

      for i = 0; i < trains.length(); i = i + 1 {
        if not(trains[i].alive) {
          continue
        }

        trains[i].x = trains[i].x +
          Float::from_int(trains[i].dir) * trains[i].speed * dt

        if trains[i].dir > 0 {
          if trains[i].x >= gate_x0 {
            apply_gate(trains[i], 0, gate0)
          }
          if trains[i].x >= gate_x1 {
            apply_gate(trains[i], 1, gate1)
          }
          if trains[i].x >= gate_x2 {
            apply_gate(trains[i], 2, gate2)
          }
        } else {
          if trains[i].x <= gate_x2 {
            apply_gate(trains[i], 2, gate2)
          }
          if trains[i].x <= gate_x1 {
            apply_gate(trains[i], 1, gate1)
          }
          if trains[i].x <= gate_x0 {
            apply_gate(trains[i], 0, gate0)
          }
        }

        if trains[i].x < 40.0 || trains[i].x > Float::from_int(sw - 40) {
          let target = target_lane(trains[i].dir, trains[i].cargo)
          if trains[i].lane == target {
            delivered = delivered + 1
            combo = combo + 1
            score = score + 12 + combo * 3
            msg = "Perfect delivery! Combo x\{combo}."
          } else {
            missed = missed + 1
            combo = 0
            lives = lives - 1
            score = score - 8
            msg = "Wrong station lane."
          }
          trains[i].alive = false
        }
      }

      // Collision check
      for i = 0; i < trains.length(); i = i + 1 {
        if not(trains[i].alive) {
          continue
        }
        for j = i + 1; j < trains.length(); j = j + 1 {
          if not(trains[j].alive) {
            continue
          }
          if trains[i].lane == trains[j].lane {
            let dx = (trains[i].x - trains[j].x).abs()
            if dx < 44.0 {
              trains[i].alive = false
              trains[j].alive = false
              lives = lives - 2
              combo = 0
              score = score - 25
              msg = "Crash on lane \{trains[i].lane + 1}!"
            }
          }
        }
      }

      if lives <= 0 {
        over = true
        msg = "Dispatch failure. Press R to restart."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 22, 28, 255))

    for l = 0; l < lanes; l = l + 1 {
      let y = lane_y(l)
      @raylib.draw_line(70, y.to_int(), sw - 70, y.to_int(), @raylib.lightgray)
      @raylib.draw_line(
        70,
        y.to_int() + 6,
        sw - 70,
        y.to_int() + 6,
        @raylib.gray,
      )
      @raylib.draw_rectangle(
        24,
        y.to_int() - 28,
        36,
        48,
        if l == 0 {
          @raylib.red
        } else if l == 3 {
          @raylib.skyblue
        } else {
          @raylib.darkgray
        },
      )
      @raylib.draw_rectangle(
        sw - 60,
        y.to_int() - 28,
        36,
        48,
        if l == 0 {
          @raylib.skyblue
        } else if l == 3 {
          @raylib.red
        } else {
          @raylib.darkgray
        },
      )
    }

    @raylib.draw_line(
      gate_x0.to_int(),
      130,
      gate_x0.to_int(),
      620,
      if gate0 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )
    @raylib.draw_line(
      gate_x1.to_int(),
      130,
      gate_x1.to_int(),
      620,
      if gate1 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )
    @raylib.draw_line(
      gate_x2.to_int(),
      130,
      gate_x2.to_int(),
      620,
      if gate2 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )

    @raylib.draw_text(
      if gate0 {
        "1 ON"
      } else {
        "1 OFF"
      },
      gate_x0.to_int() - 26,
      96,
      20,
      if gate0 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )
    @raylib.draw_text(
      if gate1 {
        "2 ON"
      } else {
        "2 OFF"
      },
      gate_x1.to_int() - 30,
      96,
      20,
      if gate1 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )
    @raylib.draw_text(
      if gate2 {
        "3 ON"
      } else {
        "3 OFF"
      },
      gate_x2.to_int() - 30,
      96,
      20,
      if gate2 {
        @raylib.lime
      } else {
        @raylib.red
      },
    )

    for i = 0; i < trains.length(); i = i + 1 {
      if trains[i].alive {
        let y = lane_y(trains[i].lane)
        let c = train_color(trains[i].cargo)
        @raylib.draw_rectangle(
          (trains[i].x - 20.0).to_int(),
          (y - 16.0).to_int(),
          40,
          24,
          c,
        )
        @raylib.draw_rectangle_lines(
          (trains[i].x - 20.0).to_int(),
          (y - 16.0).to_int(),
          40,
          24,
          @raylib.white,
        )
        @raylib.draw_circle(
          (trains[i].x - 10.0).to_int(),
          (y + 10.0).to_int(),
          4.0,
          @raylib.black,
        )
        @raylib.draw_circle(
          (trains[i].x + 10.0).to_int(),
          (y + 10.0).to_int(),
          4.0,
          @raylib.black,
        )
      }
    }

    @raylib.draw_text("TRAIN DISPATCH 2026", 24, 18, 42, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 24, 68, 28, @raylib.white)
    @raylib.draw_text("Delivered \{delivered}", 220, 68, 28, @raylib.lime)
    @raylib.draw_text("Missed \{missed}", 430, 68, 28, @raylib.orange)
    @raylib.draw_text(
      "Lives \{lives}",
      600,
      68,
      28,
      if lives <= 2 {
        @raylib.red
      } else {
        @raylib.yellow
      },
    )

    @raylib.draw_text(
      "Target: red => top-right / bottom-left, blue => bottom-right / top-left",
      24, 640, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      24,
      676,
      sw - 48,
      38,
      @raylib.Color::new(8, 10, 14, 220),
    )
    @raylib.draw_text(msg, 36, 684, 24, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        330,
        260,
        540,
        170,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("DISPATCH FAILED", 430, 310, 50, @raylib.red)
      @raylib.draw_text("Press R to restart shift", 452, 368, 30, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
