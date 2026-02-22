///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let lane_count : Int = 4

///|
let lane_w : Int = 170

///|
let track_x : Int = (sw - lane_w * lane_count) / 2

///|
let track_y : Int = 88

///|
let track_h : Int = 610

///|
let hit_y : Float = 588.0

///|
let scroll_speed : Float = 390.0

///|
let max_notes : Int = 920

///|
let max_particles : Int = 680

///|
struct Note {
  mut active : Bool
  mut lane : Int
  mut time : Float
  mut kind : Int
  mut end_time : Float
  mut state : Int
  mut hold_ratio : Float
  mut pop_t : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut t : Float
  mut life : Float
  mut kind : Int
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let x0 : Float = Float::from_int(x)
  let y0 : Float = Float::from_int(y)
  let x1 : Float = Float::from_int(x + w)
  let y1 : Float = Float::from_int(y + h)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn lane_x(i : Int) -> Int {
  track_x + i * lane_w
}

///|
fn lane_center(i : Int) -> Float {
  Float::from_int(lane_x(i) + lane_w / 2)
}

///|
fn note_y(note_t : Float, song_t : Float) -> Float {
  hit_y - (note_t - song_t) * scroll_speed
}

///|
fn clear_notes(notes : Array[Note]) -> Unit {
  for i = 0; i < notes.length(); i = i + 1 {
    notes[i].active = false
    notes[i].lane = 0
    notes[i].time = 0.0
    notes[i].kind = 0
    notes[i].end_time = 0.0
    notes[i].state = 0
    notes[i].hold_ratio = 0.0
    notes[i].pop_t = 0.0
  }
}

///|
fn clear_particles(ps : Array[Particle]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].size = 0.0
    ps[i].t = 0.0
    ps[i].life = 0.0
    ps[i].kind = 0
  }
}

///|
fn spawn_particle(
  ps : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }
    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      ps[i].vx = Float::from_int(@raylib.get_random_value(-240, 240)) * speed
      ps[i].vy = Float::from_int(@raylib.get_random_value(-260, 90)) * speed
      ps[i].size = Float::from_int(@raylib.get_random_value(3, 7))
      ps[i].t = 0.0
      ps[i].life = Float::from_int(@raylib.get_random_value(20, 56)) / 100.0
      ps[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  ps : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn build_chart(notes : Array[Note]) -> (Int, Float) {
  clear_notes(notes)

  let mut n : Int = 0
  let mut t : Float = 1.45

  for i = 0; i < 430; i = i + 1 {
    let lane : Int = (i * 7 + i / 5 * 3 + i / 23 * 2) % lane_count
    let mut kind : Int = 0
    let mut hold_len : Float = 0.0

    if i % 29 == 10 || i % 37 == 4 || (i % 41 == 0 && i > 30) {
      kind = 1
      hold_len = 0.60 + Float::from_int(i % 4) * 0.22
    }

    if n < notes.length() {
      notes[n].active = true
      notes[n].lane = lane
      notes[n].time = t
      notes[n].kind = kind
      notes[n].end_time = if kind == 1 { t + hold_len } else { t }
      notes[n].state = 0
      notes[n].hold_ratio = 0.0
      notes[n].pop_t = 0.0
      n = n + 1
    }

    if i % 11 == 6 || i % 17 == 8 {
      let lane2 : Int = (lane + 1 + i / 13 % 3) % lane_count
      if n < notes.length() {
        notes[n].active = true
        notes[n].lane = lane2
        notes[n].time = t + 0.05
        notes[n].kind = 0
        notes[n].end_time = t + 0.05
        notes[n].state = 0
        notes[n].hold_ratio = 0.0
        notes[n].pop_t = 0.0
        n = n + 1
      }
    }

    let phase : Int = i / 56 % 4
    let mut step : Float = 0.28
    if phase == 1 {
      step = 0.24
    } else if phase == 2 {
      step = 0.20
    } else if phase == 3 {
      step = 0.17
    }

    if i % 8 == 0 {
      t = t + step + 0.09
    } else if i % 3 == 0 {
      t = t + step + 0.03
    } else {
      t = t + step
    }
  }

  (n, t + 3.5)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Rhythm Street Beats 2026")
  @raylib.set_target_fps(60)

  let notes : Array[Note] = Array::makei(max_notes, fn(_i) {
    {
      active: false,
      lane: 0,
      time: 0.0,
      kind: 0,
      end_time: 0.0,
      state: 0,
      hold_ratio: 0.0,
      pop_t: 0.0,
    }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      t: 0.0,
      life: 0.0,
      kind: 0,
    }
  })

  let lane_down : Array[Bool] = Array::make(lane_count, false)
  let lane_press : Array[Bool] = Array::make(lane_count, false)
  let lane_touch_prev : Array[Bool] = Array::make(lane_count, false)

  let mut state : Int = 0
  let mut note_count : Int = 0
  let mut song_end : Float = 0.0
  let mut song_t : Float = 0.0

  let mut score : Int = 0
  let mut combo : Int = 0
  let mut best_combo : Int = 0
  let mut perfect : Int = 0
  let mut great : Int = 0
  let mut good : Int = 0
  let mut miss : Int = 0
  let mut life : Float = 100.0

  let mut fever : Float = 0.0
  let mut fever_meter : Float = 0.0

  let mut judge_text : String = ""
  let mut judge_t : Float = 0.0
  let mut judge_kind : Int = 0

  let mut pulse : Float = 0.0
  let mut camera_shake : Float = 0.0
  let mut hold_spark_cd : Float = 0.0

  let reset_game = fn() {
    let (count, end_t) = build_chart(notes)
    note_count = count
    song_end = end_t
    song_t = -2.8

    score = 0
    combo = 0
    best_combo = 0
    perfect = 0
    great = 0
    good = 0
    miss = 0
    life = 100.0
    fever = 0.0
    fever_meter = 0.0

    judge_text = ""
    judge_t = 0.0
    judge_kind = 0
    pulse = 0.0
    camera_shake = 0.0
    hold_spark_cd = 0.0

    clear_particles(particles)

    for i = 0; i < lane_touch_prev.length(); i = i + 1 {
      lane_touch_prev[i] = false
      lane_down[i] = false
      lane_press[i] = false
    }
  }

  let mark_miss = fn(x : Float, y : Float, reason : String) {
    combo = 0
    miss = miss + 1
    life = life - 8.5
    if life < 0.0 {
      life = 0.0
    }

    judge_text = reason
    judge_t = 0.52
    judge_kind = 3

    burst(particles, x, y, 12, 0.36, 3)
    camera_shake = camera_shake + 0.12
  }

  let mark_hit = fn(base : Int, quality : Int, x : Float, y : Float) {
    combo = combo + 1
    if combo > best_combo {
      best_combo = combo
    }

    let mut mult : Float = 1.0 + Float::from_int(combo / 22) * 0.12
    if mult > 2.9 {
      mult = 2.9
    }
    if fever > 0.0 {
      mult = mult + 1.1
    }

    score = score + (Float::from_int(base) * mult).to_int()
    life = clampf(life + 1.8, 0.0, 100.0)

    if quality == 0 {
      perfect = perfect + 1
      judge_text = "PERFECT"
      judge_kind = 0
      fever_meter = fever_meter + 5.2
    } else if quality == 1 {
      great = great + 1
      judge_text = "GREAT"
      judge_kind = 1
      fever_meter = fever_meter + 3.8
    } else {
      good = good + 1
      judge_text = "GOOD"
      judge_kind = 2
      fever_meter = fever_meter + 2.6
    }
    if fever_meter > 100.0 {
      fever_meter = 100.0
    }

    judge_t = 0.44
    burst(particles, x, y, 10 + quality * 2, 0.34, quality)
    pulse = pulse + 0.22
  }

  reset_game()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    pulse = pulse - dt * 0.7
    if pulse < 0.0 {
      pulse = 0.0
    }

    judge_t = judge_t - dt
    if judge_t < 0.0 {
      judge_t = 0.0
    }

    camera_shake = camera_shake - dt * 1.8
    if camera_shake < 0.0 {
      camera_shake = 0.0
    }

    let mouse = @raylib.get_mouse_position()
    let mouse_down : Bool = @raylib.is_mouse_button_down(
      @raylib.MouseButtonLeft,
    )
    let mouse_press : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    let mut shake_x : Float = 0.0
    let mut shake_y : Float = 0.0
    if camera_shake > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-6, 6)) * camera_shake
      shake_y = Float::from_int(@raylib.get_random_value(-5, 5)) * camera_shake
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || mouse_press {
        reset_game()
        state = 1
      }
    } else if state == 1 {
      song_t = song_t + dt

      if fever > 0.0 {
        fever = fever - dt
        if fever < 0.0 {
          fever = 0.0
        }
      }

      hold_spark_cd = hold_spark_cd - dt
      if hold_spark_cd < 0.0 {
        hold_spark_cd = 0.0
      }

      let mut fever_press : Bool = @raylib.is_key_pressed(@raylib.KeySpace)
      let fever_x : Int = track_x + lane_w * lane_count + 26
      let fever_y : Int = sh - 198
      let fever_w : Int = 176
      let fever_h : Int = 126

      if mouse_press &&
        inside_rect(mouse.x, mouse.y, fever_x, fever_y, fever_w, fever_h) {
        fever_press = true
      }

      if fever_press && fever_meter >= 100.0 && fever <= 0.0 && song_t > 0.0 {
        fever = 8.2
        fever_meter = 0.0
        judge_text = "FEVER MODE"
        judge_t = 0.66
        judge_kind = 0
        burst(particles, Float::from_int(sw / 2), hit_y, 60, 0.48, 0)
      }

      for lane = 0; lane < lane_count; lane = lane + 1 {
        let x = lane_x(lane)
        let touch_area_y : Int = sh - 170
        let touch_area_h : Int = 165

        let mut key_d : Bool = false
        let mut key_p : Bool = false

        if lane == 0 {
          key_d = @raylib.is_key_down(@raylib.KeyD) ||
            @raylib.is_key_down(@raylib.KeyLeft)
          key_p = @raylib.is_key_pressed(@raylib.KeyD) ||
            @raylib.is_key_pressed(@raylib.KeyLeft)
        } else if lane == 1 {
          key_d = @raylib.is_key_down(@raylib.KeyF) ||
            @raylib.is_key_down(@raylib.KeyUp)
          key_p = @raylib.is_key_pressed(@raylib.KeyF) ||
            @raylib.is_key_pressed(@raylib.KeyUp)
        } else if lane == 2 {
          key_d = @raylib.is_key_down(@raylib.KeyJ) ||
            @raylib.is_key_down(@raylib.KeyDown)
          key_p = @raylib.is_key_pressed(@raylib.KeyJ) ||
            @raylib.is_key_pressed(@raylib.KeyDown)
        } else {
          key_d = @raylib.is_key_down(@raylib.KeyK) ||
            @raylib.is_key_down(@raylib.KeyRight)
          key_p = @raylib.is_key_pressed(@raylib.KeyK) ||
            @raylib.is_key_pressed(@raylib.KeyRight)
        }

        let touch_down : Bool = mouse_down &&
          inside_rect(mouse.x, mouse.y, x, touch_area_y, lane_w, touch_area_h)
        let touch_press : Bool = touch_down && not(lane_touch_prev[lane])

        lane_down[lane] = key_d || touch_down
        lane_press[lane] = key_p || touch_press
        lane_touch_prev[lane] = touch_down
      }

      if song_t >= -0.25 {
        for lane = 0; lane < lane_count; lane = lane + 1 {
          if not(lane_press[lane]) {
            continue
          }

          let mut best : Int = -1
          let mut best_dist : Float = 99.0
          for i = 0; i < note_count; i = i + 1 {
            if not(notes[i].active) {
              continue
            }
            if notes[i].lane != lane {
              continue
            }
            if notes[i].state != 0 {
              continue
            }

            let dist : Float = absf(song_t - notes[i].time)
            if dist < best_dist {
              best_dist = dist
              best = i
            }
          }

          if best >= 0 && best_dist <= 0.18 {
            let hitx : Float = lane_center(lane)
            let hity : Float = hit_y

            if notes[best].kind == 1 {
              notes[best].state = 1
              notes[best].hold_ratio = 0.0
              notes[best].pop_t = 0.0

              judge_text = "HOLD"
              judge_t = 0.32
              judge_kind = 1
              burst(particles, hitx, hity, 7, 0.28, 1)
            } else {
              notes[best].state = 2
              notes[best].pop_t = 0.22

              if best_dist <= 0.05 {
                mark_hit(1050, 0, hitx, hity)
              } else if best_dist <= 0.10 {
                mark_hit(760, 1, hitx, hity)
              } else {
                mark_hit(480, 2, hitx, hity)
              }
            }
          } else {
            mark_miss(lane_center(lane), hit_y, "MISS")
          }
        }

        for i = 0; i < note_count; i = i + 1 {
          if not(notes[i].active) {
            continue
          }

          if notes[i].state == 0 {
            if song_t > notes[i].time + 0.18 {
              notes[i].state = 3
              notes[i].pop_t = 0.36
              mark_miss(lane_center(notes[i].lane), hit_y - 12.0, "MISS")
            }
          } else if notes[i].state == 1 {
            let lane : Int = notes[i].lane
            let hold_len : Float = notes[i].end_time - notes[i].time
            if hold_len > 0.03 {
              notes[i].hold_ratio = notes[i].hold_ratio + dt / hold_len
              if notes[i].hold_ratio > 1.0 {
                notes[i].hold_ratio = 1.0
              }
            }

            if lane_down[lane] && hold_spark_cd <= 0.0 {
              hold_spark_cd = 0.04
              spawn_particle(particles, lane_center(lane), hit_y + 4.0, 0.20, 0)
            }

            if not(lane_down[lane]) &&
              song_t > notes[i].time + 0.05 &&
              song_t < notes[i].end_time - 0.03 {
              notes[i].state = 3
              notes[i].pop_t = 0.42
              mark_miss(lane_center(lane), hit_y - 20.0, "HOLD BREAK")
            } else if song_t >= notes[i].end_time {
              notes[i].state = 2
              notes[i].pop_t = 0.3

              if notes[i].hold_ratio >= 0.9 {
                mark_hit(1320, 0, lane_center(lane), hit_y - 28.0)
              } else if notes[i].hold_ratio >= 0.75 {
                mark_hit(980, 1, lane_center(lane), hit_y - 22.0)
              } else if notes[i].hold_ratio >= 0.58 {
                mark_hit(620, 2, lane_center(lane), hit_y - 16.0)
              } else {
                notes[i].state = 3
                mark_miss(lane_center(lane), hit_y - 14.0, "HOLD MISS")
              }
            }
          }

          if notes[i].pop_t > 0.0 {
            notes[i].pop_t = notes[i].pop_t - dt
            if notes[i].pop_t < 0.0 {
              notes[i].pop_t = 0.0
            }
          }
        }
      }

      if song_t > song_end || life <= 0.0 {
        state = 2
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        reset_game()
        state = 1
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      particles[i].t = particles[i].t + dt
      if particles[i].t >= particles[i].life {
        particles[i].active = false
      } else {
        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vx = particles[i].vx * (Float::from_int(1) - dt * 1.8)
        particles[i].vy = particles[i].vy + 560.0 * dt
      }
    }

    @raylib.begin_drawing()

    let glow : Int = (pulse * 120.0).to_int()
    let mut b0 : Int = 18 + glow / 8
    let mut b1 : Int = 28 + glow / 6
    let mut b2 : Int = 46 + glow / 4

    if fever > 0.0 {
      b0 = b0 + 16
      b1 = b1 + 8
      b2 = b2 + 22
    }

    if b0 > 255 {
      b0 = 255
    }
    if b1 > 255 {
      b1 = 255
    }
    if b2 > 255 {
      b2 = 255
    }

    @raylib.clear_background(@raylib.Color::new(b0, b1, b2, 255))

    for i = 0; i < 24; i = i + 1 {
      let y = i * 36 + (song_t * 60.0).to_int() % 36
      let c = 16 + i * 3 % 26 + glow / 12
      @raylib.draw_rectangle(
        0,
        y,
        sw,
        2,
        @raylib.Color::new(c, c + 16, c + 36, 145),
      )
    }

    for i = 0; i < 18; i = i + 1 {
      let x = i * 74 + (song_t * 40.0).to_int() % 74
      let c = 14 + i * 5 % 28 + glow / 16
      @raylib.draw_rectangle(
        x,
        0,
        2,
        sh,
        @raylib.Color::new(c, c + 12, c + 24, 120),
      )
    }

    @raylib.draw_rectangle(
      track_x - 36 + shake_x.to_int(),
      track_y + shake_y.to_int(),
      lane_w * lane_count + 72,
      track_h,
      @raylib.Color::new(8, 12, 22, 224),
    )

    for lane = 0; lane < lane_count; lane = lane + 1 {
      let lx = lane_x(lane) + shake_x.to_int()
      let mut band = 44 + lane * 22
      if lane_down[lane] && state == 1 {
        band = band + 46
      }
      if fever > 0.0 {
        band = band + 18
      }
      if band > 255 {
        band = 255
      }

      @raylib.draw_rectangle(
        lx,
        track_y,
        lane_w - 2,
        track_h,
        @raylib.Color::new(20, band, 92 + lane * 16, 192),
      )
      @raylib.draw_rectangle(
        lx + 3,
        track_y + 3,
        lane_w - 8,
        track_h - 6,
        @raylib.Color::new(10, 16, 26, 220),
      )
    }

    let mut hit_w : Int = lane_w * lane_count + 16
    if state == 1 {
      hit_w = hit_w + glow / 8
    }
    @raylib.draw_rectangle(
      track_x - 8 + shake_x.to_int(),
      (hit_y - 8.0 + shake_y).to_int(),
      hit_w,
      16,
      @raylib.Color::new(246, 204, 92, 236),
    )
    @raylib.draw_rectangle(
      track_x - 8 + shake_x.to_int(),
      (hit_y - 2.0 + shake_y).to_int(),
      hit_w,
      4,
      @raylib.Color::new(255, 255, 255, 224),
    )

    for i = 0; i < note_count; i = i + 1 {
      if not(notes[i].active) {
        continue
      }

      if notes[i].state == 2 && notes[i].kind == 0 && notes[i].pop_t <= 0.0 {
        continue
      }
      if notes[i].state == 3 && notes[i].pop_t <= 0.0 {
        continue
      }

      let lane = notes[i].lane
      let lx : Int = lane_x(lane) + shake_x.to_int()

      let y0 : Float = note_y(notes[i].time, song_t) + shake_y
      let y1 : Float = note_y(notes[i].end_time, song_t) + shake_y

      if notes[i].kind == 1 {
        let top : Float = minf(y0, y1)
        let bot : Float = maxf(y0, y1)

        if bot >= -90.0 && top <= Float::from_int(sh + 90) {
          let mut tail_col = @raylib.Color::new(106, 236, 210, 184)
          if notes[i].state == 1 {
            tail_col = @raylib.Color::new(168, 252, 234, 214)
          }
          if notes[i].state == 3 {
            tail_col = @raylib.Color::new(218, 80, 92, 158)
          }

          let h : Int = (bot - top).to_int()
          @raylib.draw_rectangle(
            lx + 56,
            top.to_int(),
            lane_w - 112,
            h,
            tail_col,
          )

          if notes[i].state == 1 {
            let fill_h = (Float::from_int(h) * notes[i].hold_ratio).to_int()
            @raylib.draw_rectangle(
              lx + 62,
              (bot - Float::from_int(fill_h)).to_int(),
              lane_w - 124,
              fill_h,
              @raylib.Color::new(248, 248, 255, 218),
            )
          }
        }
      }

      if y0 >= -100.0 && y0 <= Float::from_int(sh + 100) {
        let mut note_col = @raylib.Color::new(98, 206, 248, 248)
        if lane == 1 {
          note_col = @raylib.Color::new(134, 246, 186, 246)
        } else if lane == 2 {
          note_col = @raylib.Color::new(248, 168, 108, 246)
        } else if lane == 3 {
          note_col = @raylib.Color::new(206, 144, 246, 246)
        }

        if notes[i].kind == 1 {
          note_col = @raylib.Color::new(252, 222, 124, 248)
        }

        if notes[i].state == 3 {
          note_col = @raylib.Color::new(212, 78, 98, 210)
        }

        let mut pop : Int = 0
        if notes[i].pop_t > 0.0 {
          pop = (notes[i].pop_t * 24.0).to_int()
        }

        let w : Int = lane_w - 62 + pop
        let h : Int = 24 + pop / 2
        let x : Int = lx + (lane_w - w) / 2
        let y : Int = y0.to_int() - h / 2

        @raylib.draw_rectangle(x, y, w, h, note_col)
        @raylib.draw_rectangle(
          x + 4,
          y + 4,
          w - 8,
          h - 8,
          @raylib.Color::new(16, 20, 30, 180),
        )
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let life_k = particles[i].t / particles[i].life
      let alpha : Int = ((Float::from_int(1) - life_k) * 230.0).to_int()
      let mut col = @raylib.Color::new(116, 220, 252, alpha)
      if particles[i].kind == 1 {
        col = @raylib.Color::new(136, 246, 176, alpha)
      } else if particles[i].kind == 2 {
        col = @raylib.Color::new(250, 188, 98, alpha)
      } else if particles[i].kind == 3 {
        col = @raylib.Color::new(232, 82, 104, alpha)
      }

      @raylib.draw_circle(
        (particles[i].x + shake_x).to_int(),
        (particles[i].y + shake_y).to_int(),
        particles[i].size,
        col,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 80, @raylib.Color::new(8, 10, 16, 232))
    @raylib.draw_text(
      "RHYTHM STREET BEATS 2026",
      26,
      16,
      30,
      @raylib.Color::new(232, 240, 255, 255),
    )
    @raylib.draw_text(
      "D F J K / Arrow Keys | Touch lane pads",
      26,
      50,
      18,
      @raylib.Color::new(162, 188, 222, 255),
    )

    let total_hit : Int = perfect + great + good
    let mut acc : Float = 100.0
    let total_judged : Int = total_hit + miss
    if total_judged > 0 {
      let weighted = Float::from_int(perfect) +
        Float::from_int(great) * 0.82 +
        Float::from_int(good) * 0.55
      acc = weighted / Float::from_int(total_judged) * 100.0
    }

    @raylib.draw_text(
      "SCORE \{score}",
      700,
      16,
      28,
      @raylib.Color::new(255, 246, 186, 255),
    )
    @raylib.draw_text(
      "COMBO \{combo}",
      700,
      48,
      20,
      @raylib.Color::new(168, 246, 214, 255),
    )
    @raylib.draw_text(
      "BEST \{best_combo}",
      880,
      48,
      20,
      @raylib.Color::new(184, 206, 246, 255),
    )
    @raylib.draw_text(
      "ACC \{acc.to_int()}%",
      1038,
      48,
      20,
      @raylib.Color::new(252, 198, 132, 255),
    )

    @raylib.draw_rectangle(
      700,
      74,
      220,
      10,
      @raylib.Color::new(22, 28, 36, 255),
    )
    @raylib.draw_rectangle(
      700,
      74,
      (life * 2.2).to_int(),
      10,
      @raylib.Color::new(104, 230, 148, 255),
    )
    @raylib.draw_text(
      "LIFE",
      642,
      70,
      18,
      @raylib.Color::new(182, 210, 236, 255),
    )

    @raylib.draw_rectangle(
      978,
      74,
      220,
      10,
      @raylib.Color::new(22, 28, 36, 255),
    )
    @raylib.draw_rectangle(
      978,
      74,
      (fever_meter * 2.2).to_int(),
      10,
      @raylib.Color::new(246, 172, 74, 255),
    )
    @raylib.draw_text(
      "FEVER",
      914,
      70,
      18,
      @raylib.Color::new(240, 208, 140, 255),
    )

    @raylib.draw_rectangle(
      track_x + lane_w * lane_count + 20,
      sh - 204,
      188,
      134,
      @raylib.Color::new(16, 22, 34, 220),
    )
    let mut fever_btn_col = @raylib.Color::new(96, 116, 148, 255)
    if fever_meter >= 100.0 && state == 1 {
      fever_btn_col = @raylib.Color::new(244, 162, 68, 255)
    }
    if fever > 0.0 {
      fever_btn_col = @raylib.Color::new(255, 210, 92, 255)
    }
    @raylib.draw_rectangle(
      track_x + lane_w * lane_count + 30,
      sh - 194,
      168,
      114,
      fever_btn_col,
    )
    @raylib.draw_text(
      "SPACE",
      track_x + lane_w * lane_count + 72,
      sh - 174,
      28,
      @raylib.Color::new(16, 20, 28, 255),
    )
    @raylib.draw_text(
      "FEVER",
      track_x + lane_w * lane_count + 72,
      sh - 138,
      28,
      @raylib.Color::new(16, 20, 28, 255),
    )

    for lane = 0; lane < lane_count; lane = lane + 1 {
      let x = lane_x(lane)
      let y = sh - 164
      let mut c = @raylib.Color::new(58, 76, 108, 228)
      if lane_down[lane] {
        c = @raylib.Color::new(124, 192, 246, 242)
      }

      @raylib.draw_rectangle(x + 8, y, lane_w - 16, 144, c)
      let label = if lane == 0 {
        "D"
      } else if lane == 1 {
        "F"
      } else if lane == 2 {
        "J"
      } else {
        "K"
      }
      @raylib.draw_text(
        label,
        x + lane_w / 2 - 10,
        y + 54,
        42,
        @raylib.Color::new(12, 16, 24, 255),
      )
    }

    if state == 1 {
      let mut time_left : Float = song_end - song_t
      if time_left < 0.0 {
        time_left = 0.0
      }
      @raylib.draw_text(
        "TIME \{time_left.to_int()}s",
        26,
        sh - 62,
        30,
        @raylib.Color::new(242, 238, 250, 255),
      )

      if song_t < 0.0 {
        let countdown = (-song_t).to_int() + 1
        @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 130))
        @raylib.draw_text(
          "GET READY",
          sw / 2 - 146,
          sh / 2 - 90,
          48,
          @raylib.Color::new(244, 236, 252, 255),
        )
        @raylib.draw_text(
          "\{countdown}",
          sw / 2 - 24,
          sh / 2 - 20,
          88,
          @raylib.Color::new(255, 194, 96, 255),
        )
      }
    }

    if judge_t > 0.0 {
      let mut c = @raylib.Color::new(118, 236, 252, 255)
      if judge_kind == 1 {
        c = @raylib.Color::new(146, 248, 178, 255)
      } else if judge_kind == 2 {
        c = @raylib.Color::new(252, 186, 98, 255)
      } else if judge_kind == 3 {
        c = @raylib.Color::new(236, 82, 108, 255)
      }

      let y = sh / 2 - 140 + (judge_t * 36.0).to_int()
      @raylib.draw_text(judge_text, sw / 2 - 124, y, 54, c)
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 136))
      @raylib.draw_rectangle(
        sw / 2 - 410,
        sh / 2 - 190,
        820,
        380,
        @raylib.Color::new(12, 18, 30, 238),
      )
      @raylib.draw_text(
        "RHYTHM STREET BEATS",
        sw / 2 - 266,
        sh / 2 - 130,
        52,
        @raylib.Color::new(238, 244, 255, 255),
      )
      @raylib.draw_text(
        "Hit notes on the yellow line. Build combo and trigger FEVER.",
        sw / 2 - 260,
        sh / 2 - 44,
        28,
        @raylib.Color::new(176, 208, 242, 255),
      )
      @raylib.draw_text(
        "Tap lane pads on mobile. Hold notes until they end.",
        sw / 2 - 236,
        sh / 2 + 0,
        26,
        @raylib.Color::new(176, 208, 242, 255),
      )
      @raylib.draw_text(
        "ENTER or click to start",
        sw / 2 - 162,
        sh / 2 + 92,
        34,
        @raylib.Color::new(255, 202, 112, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 164))
      @raylib.draw_rectangle(
        sw / 2 - 450,
        sh / 2 - 220,
        900,
        440,
        @raylib.Color::new(12, 18, 30, 244),
      )

      let mut grade = "C"
      if acc >= 97.0 {
        grade = "SS"
      } else if acc >= 93.0 {
        grade = "S"
      } else if acc >= 87.0 {
        grade = "A"
      } else if acc >= 80.0 {
        grade = "B"
      }

      let title = if life <= 0.0 { "TRACK FAILED" } else { "TRACK CLEAR" }
      @raylib.draw_text(
        title,
        sw / 2 - 174,
        sh / 2 - 158,
        54,
        @raylib.Color::new(248, 242, 255, 255),
      )
      @raylib.draw_text(
        "GRADE \{grade}",
        sw / 2 - 128,
        sh / 2 - 86,
        48,
        @raylib.Color::new(255, 202, 112, 255),
      )

      @raylib.draw_text(
        "SCORE: \{score}",
        sw / 2 - 360,
        sh / 2 - 12,
        36,
        @raylib.Color::new(236, 244, 252, 255),
      )
      @raylib.draw_text(
        "BEST COMBO: \{best_combo}",
        sw / 2 - 360,
        sh / 2 + 34,
        34,
        @raylib.Color::new(166, 236, 210, 255),
      )
      @raylib.draw_text(
        "PERFECT \{perfect}  GREAT \{great}  GOOD \{good}  MISS \{miss}",
        sw / 2 - 360,
        sh / 2 + 80,
        30,
        @raylib.Color::new(188, 206, 236, 255),
      )
      @raylib.draw_text(
        "ACC \{acc.to_int()}%",
        sw / 2 + 170,
        sh / 2 - 12,
        38,
        @raylib.Color::new(252, 192, 98, 255),
      )

      @raylib.draw_text(
        "ENTER: menu    R: replay",
        sw / 2 - 182,
        sh / 2 + 154,
        34,
        @raylib.Color::new(250, 218, 132, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
