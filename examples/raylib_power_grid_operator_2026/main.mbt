///|
let sw : Int = 1140

///|
let sh : Int = 740

///|
let sector_n : Int = 4

///|
struct Sector {
  mut demand : Int
  mut trend : Int
}

///|
fn clamp_int(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn total_demand(sectors : Array[Sector]) -> Int {
  let mut t = 0
  for i = 0; i < sectors.length(); i = i + 1 {
    t = t + sectors[i].demand
  }
  t
}

///|
fn total_supply(plant_output : Array[Int], emergency_time : Float) -> Int {
  let mut t = 0
  for i = 0; i < plant_output.length(); i = i + 1 {
    t = t + plant_output[i]
  }
  if emergency_time > 0.0 {
    t + 90
  } else {
    t
  }
}

///|
fn reset_sector_values(sectors : Array[Sector]) -> Unit {
  for i = 0; i < sectors.length(); i = i + 1 {
    sectors[i].demand = @raylib.get_random_value(70, 130)
    sectors[i].trend = @raylib.get_random_value(-8, 8)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Power Grid Operator 2026")
  @raylib.set_target_fps(60)

  let sectors : Array[Sector] = Array::makei(sector_n, fn(_i) {
    { demand: 100, trend: 0 }
  })
  reset_sector_values(sectors)

  let mut plant_output : Array[Int] = [110, 100, 90]

  let mut score = 0
  let mut lives = 5
  let mut overheat : Float = 0.0
  let mut outage_acc : Float = 0.0

  let mut tick : Float = 0.0
  let mut emergency_time : Float = 0.0
  let mut emergency_cd : Float = 0.0

  let mut over = false
  let mut msg = "Q/A Plant1  W/S Plant2  E/D Plant3  Space battery reserve"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_sector_values(sectors)
      plant_output = [110, 100, 90]
      score = 0
      lives = 5
      overheat = 0.0
      outage_acc = 0.0
      tick = 0.0
      emergency_time = 0.0
      emergency_cd = 0.0
      over = false
      msg = "Grid shift restarted."
    }

    if not(over) {
      if @raylib.is_key_down(@raylib.KeyQ) {
        plant_output[0] = clamp_int(plant_output[0] + 2, 0, 220)
      }
      if @raylib.is_key_down(@raylib.KeyA) {
        plant_output[0] = clamp_int(plant_output[0] - 2, 0, 220)
      }
      if @raylib.is_key_down(@raylib.KeyW) {
        plant_output[1] = clamp_int(plant_output[1] + 2, 0, 220)
      }
      if @raylib.is_key_down(@raylib.KeyS) {
        plant_output[1] = clamp_int(plant_output[1] - 2, 0, 220)
      }
      if @raylib.is_key_down(@raylib.KeyE) {
        plant_output[2] = clamp_int(plant_output[2] + 2, 0, 220)
      }
      if @raylib.is_key_down(@raylib.KeyD) {
        plant_output[2] = clamp_int(plant_output[2] - 2, 0, 220)
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) && emergency_cd <= 0.0 {
        emergency_time = 6.0
        emergency_cd = 20.0
        msg = "Emergency battery online."
      }

      tick = tick + dt
      if tick >= 1.0 {
        tick = tick - 1.0

        for i = 0; i < sectors.length(); i = i + 1 {
          let noise = @raylib.get_random_value(-5, 5)
          sectors[i].demand = clamp_int(sectors[i].demand + sectors[i].trend + noise, 40, 190)
          if @raylib.get_random_value(0, 99) < 24 {
            sectors[i].trend = clamp_int(sectors[i].trend + @raylib.get_random_value(-3, 3), -12, 12)
          }
        }

        score = score + 6
      }

      let demand = total_demand(sectors)
      let supply = total_supply(plant_output, emergency_time)
      let diff = supply - demand

      if diff < -25 {
        let shortage = -diff - 25
        outage_acc = outage_acc + dt * Float::from_int(shortage) * 0.10
      } else {
        outage_acc = outage_acc - dt * 9.0
      }
      if outage_acc < 0.0 {
        outage_acc = 0.0
      }

      if diff > 35 {
        let excess = diff - 35
        overheat = overheat + dt * Float::from_int(excess) * 0.08
      } else {
        overheat = overheat - dt * 7.0
      }
      if overheat < 0.0 {
        overheat = 0.0
      }

      if outage_acc >= 12.0 {
        lives = lives - 1
        score = score - 35
        outage_acc = 0.0
        msg = "District blackout penalty."
      }

      if overheat >= 100.0 {
        lives = lives - 1
        score = score - 45
        overheat = 28.0
        msg = "Plant overload shutdown."
      }

      if diff >= -15 && diff <= 15 {
        score = score + 1
      }

      emergency_time = emergency_time - dt
      emergency_cd = emergency_cd - dt
      if emergency_time < 0.0 {
        emergency_time = 0.0
      }
      if emergency_cd < 0.0 {
        emergency_cd = 0.0
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Grid collapse."
      }
    }

    let demand = total_demand(sectors)
    let supply = total_supply(plant_output, emergency_time)
    let diff = supply - demand

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(20, 24, 34, 255))

    @raylib.draw_text("POWER GRID OPERATOR 2026", 20, 18, 40, @raylib.skyblue)
    @raylib.draw_text("Score \{score}", 20, 66, 30, @raylib.white)
    @raylib.draw_text("Lives \{lives}", 210, 66, 30, if lives <= 1 { @raylib.red } else { @raylib.yellow })

    @raylib.draw_text("Demand \{demand}", 420, 66, 32, @raylib.orange)
    @raylib.draw_text("Supply \{supply}", 620, 66, 32, @raylib.lime)
    @raylib.draw_text("Balance \{diff}", 820, 66, 32, if diff < 0 { @raylib.red } else { @raylib.lime })

    // Sector demand bars
    for i = 0; i < sectors.length(); i = i + 1 {
      let x = 60 + i * 120
      @raylib.draw_rectangle(x, 150, 86, 220, @raylib.Color::new(38, 44, 54, 255))
      let h = sectors[i].demand
      @raylib.draw_rectangle(x + 8, 360 - h, 70, h, @raylib.orange)
      @raylib.draw_text("S\{i + 1}", x + 26, 378, 24, @raylib.raywhite)
      @raylib.draw_text("\{sectors[i].demand}", x + 20, 330 - h, 20, @raylib.white)
    }

    // Plant output bars
    for i = 0; i < plant_output.length(); i = i + 1 {
      let x = 620 + i * 140
      @raylib.draw_rectangle(x, 150, 96, 260, @raylib.Color::new(38, 44, 54, 255))
      let h = plant_output[i]
      @raylib.draw_rectangle(x + 10, 400 - h, 76, h, @raylib.lime)
      @raylib.draw_text("P\{i + 1}", x + 34, 420, 24, @raylib.raywhite)
      @raylib.draw_text("\{plant_output[i]}", x + 26, 370 - h, 22, @raylib.white)
    }

    // Stress bars
    @raylib.draw_text("Overheat", 60, 470, 24, @raylib.red)
    @raylib.draw_rectangle(170, 476, 320, 18, @raylib.Color::new(50, 22, 22, 255))
    @raylib.draw_rectangle(170, 476, (overheat * 3.2).to_int(), 18, @raylib.red)

    @raylib.draw_text("Outage Risk", 60, 512, 24, @raylib.orange)
    @raylib.draw_rectangle(170, 518, 320, 18, @raylib.Color::new(54, 40, 20, 255))
    @raylib.draw_rectangle(170, 518, (outage_acc * 26.0).to_int(), 18, @raylib.orange)

    let cd = if emergency_cd > 0.0 { emergency_cd.to_int() } else { 0 }
    @raylib.draw_text("Battery Reserve: +90 for 6s (CD \{cd}s)", 620, 470, 24, @raylib.skyblue)
    if emergency_time > 0.0 {
      @raylib.draw_text("BATTERY ACTIVE", 620, 505, 28, @raylib.lime)
    }

    @raylib.draw_text("Q/A Plant1  W/S Plant2  E/D Plant3  Space battery", 20, 652, 24, @raylib.lightgray)
    @raylib.draw_rectangle(20, 686, sw - 40, 30, @raylib.Color::new(10, 14, 20, 220))
    @raylib.draw_text(msg, 28, 691, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(290, 250, 560, 190, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("GRID COLLAPSE", 415, 316, 56, @raylib.red)
      @raylib.draw_text("Press R to restart", 445, 378, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
