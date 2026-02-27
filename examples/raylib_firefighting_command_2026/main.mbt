///|
let sw : Int = 1120

///|
let sh : Int = 740

///|
let cols : Int = 5

///|
let rows : Int = 3

///|
fn cell_x(c : Int) -> Float {
  150.0 + Float::from_int(c) * 180.0
}

///|
fn cell_y(r : Int) -> Float {
  200.0 + Float::from_int(r) * 170.0
}

///|
struct Zone {
  mut fire : Float
  mut has_house : Bool
}

///|
fn idx(c : Int, r : Int) -> Int {
  r * cols + c
}

///|
fn reset_zones(zones : Array[Zone]) -> Unit {
  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let i = idx(c, r)
      zones[i].fire = 0.0
      zones[i].has_house = true
    }
  }

  for _k = 0; _k < 2; _k = _k + 1 {
    let c = @raylib.get_random_value(0, cols - 1)
    let r = @raylib.get_random_value(0, rows - 1)
    zones[idx(c, r)].fire = Float::from_int(@raylib.get_random_value(28, 46))
  }
}

///|
fn active_fire_count(zones : Array[Zone]) -> Int {
  let mut n = 0
  for i = 0; i < zones.length(); i = i + 1 {
    if zones[i].fire > 0.0 {
      n = n + 1
    }
  }
  n
}

///|
fn main {
  @raylib.init_window(sw, sh, "Firefighting Command 2026")
  @raylib.set_target_fps(60)

  let zones : Array[Zone] = Array::makei(cols * rows, fn(_i) {
    { fire: 0.0, has_house: true }
  })
  reset_zones(zones)

  let mut truck_c = 2
  let mut truck_r = 1
  let mut truck_x : Float = cell_x(truck_c)
  let mut truck_y : Float = cell_y(truck_r)

  let mut water : Float = 100.0
  let mut spread_tick : Float = 0.0
  let mut spawn_tick : Float = 0.0
  let mut budget = 0
  let mut saved = 0
  let mut lost = 0
  let mut lives = 4
  let mut over = false
  let mut msg = "WASD/Arrows move, Space spray, R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_zones(zones)
      truck_c = 2
      truck_r = 1
      truck_x = cell_x(truck_c)
      truck_y = cell_y(truck_r)
      water = 100.0
      spread_tick = 0.0
      spawn_tick = 0.0
      budget = 0
      saved = 0
      lost = 0
      lives = 4
      over = false
      msg = "City response restarted."
    }

    if not(over) {
      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        if truck_c > 0 {
          truck_c = truck_c - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        if truck_c < cols - 1 {
          truck_c = truck_c + 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        if truck_r > 0 {
          truck_r = truck_r - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        if truck_r < rows - 1 {
          truck_r = truck_r + 1
        }
      }
      truck_x = cell_x(truck_c)
      truck_y = cell_y(truck_r)

      let at = idx(truck_c, truck_r)
      if zones[at].fire <= 0.0 {
        water = water + dt * 14.0
      }
      if water > 100.0 {
        water = 100.0
      }

      if (
          @raylib.is_key_down(@raylib.KeySpace) ||
          @raylib.is_key_down(@raylib.KeyJ)
        ) &&
        water > 0.0 {
        if zones[at].fire > 0.0 {
          zones[at].fire = zones[at].fire - dt * 48.0
          water = water - dt * 24.0
          if zones[at].fire <= 0.0 {
            zones[at].fire = 0.0
            saved = saved + 1
            budget = budget + 30
            msg = "Fire extinguished."
          }
        }
      }

      spread_tick = spread_tick + dt
      if spread_tick >= 1.0 {
        spread_tick = spread_tick - 1.0

        for r = 0; r < rows; r = r + 1 {
          for c = 0; c < cols; c = c + 1 {
            let i = idx(c, r)
            if zones[i].fire > 0.0 {
              zones[i].fire = zones[i].fire + 7.0

              if zones[i].fire >= 100.0 {
                zones[i].fire = 0.0
                zones[i].has_house = false
                lives = lives - 1
                lost = lost + 1
                msg = "A building burned down."
              } else {
                let mut target = -1
                let mut tries = 0
                while tries < 6 && target < 0 {
                  let dir = @raylib.get_random_value(0, 3)
                  let nc = if dir == 0 {
                    c + 1
                  } else if dir == 1 {
                    c - 1
                  } else {
                    c
                  }
                  let nr = if dir == 2 {
                    r + 1
                  } else if dir == 3 {
                    r - 1
                  } else {
                    r
                  }
                  if nc >= 0 && nc < cols && nr >= 0 && nr < rows {
                    let ni = idx(nc, nr)
                    if zones[ni].has_house && zones[ni].fire <= 0.0 {
                      target = ni
                    }
                  }
                  tries = tries + 1
                }
                if target >= 0 {
                  zones[target].fire = zones[target].fire + 18.0
                }
              }
            }
          }
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 4.6 {
        spawn_tick = spawn_tick - 4.6
        let c = @raylib.get_random_value(0, cols - 1)
        let r = @raylib.get_random_value(0, rows - 1)
        let i = idx(c, r)
        if zones[i].has_house && zones[i].fire <= 0.0 {
          zones[i].fire = Float::from_int(@raylib.get_random_value(24, 42))
          msg = "New fire reported."
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "City overwhelmed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(28, 34, 42, 255))

    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(42, 52, 66, 255))

    for r = 0; r < rows; r = r + 1 {
      for c = 0; c < cols; c = c + 1 {
        let i = idx(c, r)
        let x = cell_x(c)
        let y = cell_y(r)
        let house_color = if zones[i].has_house {
          @raylib.Color::new(196, 210, 224, 255)
        } else {
          @raylib.Color::new(66, 66, 66, 255)
        }
        @raylib.draw_rectangle(
          (x - 64.0).to_int(),
          (y - 56.0).to_int(),
          128,
          108,
          house_color,
        )
        @raylib.draw_rectangle_lines(
          (x - 64.0).to_int(),
          (y - 56.0).to_int(),
          128,
          108,
          @raylib.darkgray,
        )

        if zones[i].fire > 0.0 {
          let f = zones[i].fire
          @raylib.draw_circle(
            (x - 20.0).to_int(),
            (y - 18.0).to_int(),
            12.0 + f * 0.09,
            @raylib.orange,
          )
          @raylib.draw_circle(
            (x + 16.0).to_int(),
            (y - 6.0).to_int(),
            10.0 + f * 0.08,
            @raylib.red,
          )
          @raylib.draw_text(
            "\{f.to_int()}%",
            (x - 22.0).to_int(),
            (y + 30.0).to_int(),
            18,
            @raylib.black,
          )
        }
      }
    }

    @raylib.draw_rectangle(
      (truck_x - 30.0).to_int(),
      (truck_y + 58.0).to_int(),
      60,
      26,
      @raylib.red,
    )
    @raylib.draw_rectangle(
      (truck_x - 18.0).to_int(),
      (truck_y + 45.0).to_int(),
      36,
      13,
      @raylib.white,
    )
    @raylib.draw_circle(
      (truck_x - 18.0).to_int(),
      (truck_y + 85.0).to_int(),
      6.0,
      @raylib.black,
    )
    @raylib.draw_circle(
      (truck_x + 18.0).to_int(),
      (truck_y + 85.0).to_int(),
      6.0,
      @raylib.black,
    )

    @raylib.draw_text("FIREFIGHTING COMMAND 2026", 20, 18, 38, @raylib.skyblue)
    @raylib.draw_text("Budget \{budget}", 20, 64, 28, @raylib.white)
    @raylib.draw_text("Saved \{saved}", 220, 64, 28, @raylib.lime)
    @raylib.draw_text("Lost \{lost}", 380, 64, 28, @raylib.orange)
    @raylib.draw_text(
      "Lives \{lives}",
      520,
      64,
      28,
      if lives <= 1 {
        @raylib.red
      } else {
        @raylib.yellow
      },
    )

    @raylib.draw_text("Water", 740, 60, 24, @raylib.skyblue)
    @raylib.draw_rectangle(
      810,
      64,
      250,
      16,
      @raylib.Color::new(30, 40, 58, 255),
    )
    @raylib.draw_rectangle(810, 64, (water * 2.5).to_int(), 16, @raylib.skyblue)

    let active = active_fire_count(zones)
    @raylib.draw_text("Active Fires: \{active}", 20, 650, 24, @raylib.raywhite)
    @raylib.draw_rectangle(
      20,
      688,
      sw - 40,
      30,
      @raylib.Color::new(12, 17, 24, 220),
    )
    @raylib.draw_text(msg, 28, 693, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        520,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @raylib.draw_text("CITY LOST", 455, 312, 52, @raylib.red)
      @raylib.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
