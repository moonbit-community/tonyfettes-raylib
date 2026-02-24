///|
let sw : Int = 1120

///|
let sh : Int = 740

///|
let ward_count : Int = 4

///|
fn ward_x(ward : Int) -> Float {
  170.0 + Float::from_int(ward) * 240.0
}

///|
struct Patient {
  mut alive : Bool
  mut ward : Int
  mut x : Float
  mut y : Float
  mut severity : Int // 0 mild, 1 medium, 2 critical
  mut wait : Float
}

///|
fn reset_patients(ps : Array[Patient]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].alive = false
  }
}

///|
fn spawn_patient(ps : Array[Patient]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    if not(ps[i].alive) {
      let w = @raylib.get_random_value(0, ward_count - 1)
      let r = @raylib.get_random_value(0, 99)
      let sev = if r < 42 {
        0
      } else if r < 82 {
        1
      } else {
        2
      }
      ps[i].alive = true
      ps[i].ward = w
      ps[i].x = ward_x(w)
      ps[i].y = 150.0
      ps[i].severity = sev
      ps[i].wait = 0.0
      break
    }
  }
}

///|
fn treat_time(sev : Int) -> Float {
  if sev == 0 {
    2.2
  } else if sev == 1 {
    3.4
  } else {
    4.8
  }
}

///|
fn treat_score(sev : Int) -> Int {
  if sev == 0 {
    28
  } else if sev == 1 {
    48
  } else {
    92
  }
}

///|
fn severity_color(sev : Int) -> @raylib.Color {
  if sev == 0 {
    @raylib.lime
  } else if sev == 1 {
    @raylib.orange
  } else {
    @raylib.red
  }
}

///|
fn severity_name(sev : Int) -> String {
  if sev == 0 {
    "MILD"
  } else if sev == 1 {
    "MED"
  } else {
    "CRIT"
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Hospital Triage 2026")
  @raylib.set_target_fps(60)

  let patients : Array[Patient] = Array::makei(140, fn(_i) {
    {
      alive: false,
      ward: 0,
      x: 0.0,
      y: 0.0,
      severity: 0,
      wait: 0.0,
    }
  })

  let mut nurse_ward = 1
  let mut nx : Float = ward_x(nurse_ward)

  let mut treating = false
  let mut tr_sev = 0
  let mut tr_time_left : Float = 0.0

  let mut spawn_tick : Float = 0.0
  let mut timer : Float = 150.0
  let mut lives = 5
  let mut score = 0
  let mut treated = 0
  let mut failed = 0

  let mut over = false
  let mut msg = "A/D move wards, Space admit first patient in ward"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_patients(patients)
      nurse_ward = 1
      nx = ward_x(nurse_ward)
      treating = false
      tr_sev = 0
      tr_time_left = 0.0
      spawn_tick = 0.0
      timer = 150.0
      lives = 5
      score = 0
      treated = 0
      failed = 0
      over = false
      msg = "Shift restarted."
    }

    if not(over) {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Shift complete."
      }

      if @raylib.is_key_pressed(@raylib.KeyA) || @raylib.is_key_pressed(@raylib.KeyLeft) {
        if nurse_ward > 0 {
          nurse_ward = nurse_ward - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) || @raylib.is_key_pressed(@raylib.KeyRight) {
        if nurse_ward < ward_count - 1 {
          nurse_ward = nurse_ward + 1
        }
      }
      nx = ward_x(nurse_ward)

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.48 {
        spawn_tick = spawn_tick - 0.48
        spawn_patient(patients)
      }

      if treating {
        tr_time_left = tr_time_left - dt
        if tr_time_left <= 0.0 {
          treating = false
          treated = treated + 1
          let gain = treat_score(tr_sev)
          score = score + gain
          timer = timer + 2.6
          if timer > 170.0 {
            timer = 170.0
          }
          msg = "Patient stabilized +\{gain}."
        }
      }

      for i = 0; i < patients.length(); i = i + 1 {
        if not(patients[i].alive) {
          continue
        }

        let spd : Float =
          if patients[i].severity == 2 {
            (55.0 : Float)
          } else if patients[i].severity == 1 {
            (42.0 : Float)
          } else {
            (32.0 : Float)
          }
        patients[i].y = patients[i].y + spd * dt
        patients[i].wait = patients[i].wait + dt

        let panic_time : Float =
          if patients[i].severity == 2 {
            (7.0 : Float)
          } else if patients[i].severity == 1 {
            (10.0 : Float)
          } else {
            (13.0 : Float)
          }
        if patients[i].wait > panic_time {
          patients[i].alive = false
          failed = failed + 1
          let life_loss = if patients[i].severity == 2 { 2 } else { 1 }
          let score_loss = if patients[i].severity == 2 { 36 } else { 20 }
          lives = lives - life_loss
          score = score - score_loss
          msg = "Patient condition worsened untreated."
          continue
        }

        if patients[i].y > Float::from_int(sh - 100) {
          patients[i].alive = false
          failed = failed + 1
          lives = lives - 1
          score = score - 14
          msg = "Patient left without treatment."
        }
      }

      if not(treating) && (@raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_key_pressed(@raylib.KeyEnter)) {
        let mut pick = -1
        let mut best_y : Float = 1_000_000.0
        for i = 0; i < patients.length(); i = i + 1 {
          if patients[i].alive && patients[i].ward == nurse_ward {
            if patients[i].y < best_y {
              best_y = patients[i].y
              pick = i
            }
          }
        }
        if pick >= 0 {
          tr_sev = patients[pick].severity
          tr_time_left = treat_time(tr_sev)
          treating = true
          patients[pick].alive = false
          msg = "Patient admitted to treatment bed."
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Hospital overwhelmed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(230, 236, 242, 255))

    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(188, 214, 236, 255))
    @raylib.draw_rectangle(0, 130, sw, sh - 130, @raylib.Color::new(248, 248, 248, 255))

    for w = 0; w < ward_count; w = w + 1 {
      let x = ward_x(w)
      @raylib.draw_rectangle((x - 75.0).to_int(), 160, 150, 520, @raylib.Color::new(240, 244, 248, 255))
      @raylib.draw_rectangle_lines((x - 75.0).to_int(), 160, 150, 520, @raylib.Color::new(180, 190, 205, 255))
      @raylib.draw_text("WARD \{w + 1}", (x - 56.0).to_int(), 168, 24, @raylib.darkblue)
    }

    for i = 0; i < patients.length(); i = i + 1 {
      if patients[i].alive {
        let c = severity_color(patients[i].severity)
        @raylib.draw_circle(patients[i].x.to_int(), patients[i].y.to_int(), 15.0, c)
        @raylib.draw_text(
          severity_name(patients[i].severity),
          (patients[i].x - 26.0).to_int(),
          (patients[i].y - 30.0).to_int(),
          16,
          @raylib.black,
        )
      }
    }

    // Nurse and treatment bed
    @raylib.draw_circle(nx.to_int(), (sh - 82), 16.0, @raylib.blue)
    @raylib.draw_rectangle((nx - 26.0).to_int(), sh - 64, 52, 10, @raylib.darkblue)

    @raylib.draw_rectangle(sw - 290, 180, 250, 150, @raylib.Color::new(214, 228, 242, 255))
    @raylib.draw_text("TREATMENT", sw - 262, 194, 28, @raylib.darkblue)
    if treating {
      @raylib.draw_text("Patient: \{severity_name(tr_sev)}", sw - 270, 236, 24, severity_color(tr_sev))
      @raylib.draw_text("ETA \{tr_time_left.to_int()}s", sw - 270, 270, 24, @raylib.black)
    } else {
      @raylib.draw_text("Bed Available", sw - 260, 250, 26, @raylib.lime)
    }

    @raylib.draw_rectangle(18, 16, 640, 108, @raylib.Color::new(21, 39, 58, 220))
    @raylib.draw_text("HOSPITAL TRIAGE 2026", 28, 22, 36, @raylib.skyblue)
    @raylib.draw_text("Score \{score}  Treated \{treated}  Failed \{failed}  Lives \{lives}", 28, 66, 28, @raylib.raywhite)

    let t = timer.to_int()
    @raylib.draw_text("Time \{t}s", 710, 28, 36, if t < 20 { @raylib.red } else { @raylib.orange })

    @raylib.draw_text("Critical patients expire faster and cost more lives.", 20, 654, 24, @raylib.darkgray)
    @raylib.draw_rectangle(20, 688, sw - 40, 30, @raylib.Color::new(28, 42, 58, 220))
    @raylib.draw_text(msg, 28, 693, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(300, 250, 520, 180, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text(if lives > 0 { "SHIFT COMPLETE" } else { "SHIFT FAILED" }, 390, 312, 50, if lives > 0 { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
