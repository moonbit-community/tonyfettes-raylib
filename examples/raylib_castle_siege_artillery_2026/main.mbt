///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let ground_y : Int = 640

///|
let gravity : Float = 360.0

///|
let castle_w : Int = 120

///|
let castle_h : Int = 130

///|
let player_x : Int = 90

///|
let enemy_x : Int = sw - 210

///|
let mountain_x : Int = sw / 2 - 72

///|
let mountain_w : Int = 144

///|
let mountain_h : Int = 220

///|
fn absf(x : Float) -> Float {
  if x < 0.0 {
    -x
  } else {
    x
  }
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn deg2rad(angle : Float) -> Double {
  angle.to_double() * 0.017453292519943295
}

///|
fn sinf_deg(angle : Float) -> Float {
  Float::from_double(@math.sin(deg2rad(angle)))
}

///|
fn cosf_deg(angle : Float) -> Float {
  Float::from_double(@math.cos(deg2rad(angle)))
}

///|
fn random_wind() -> Float {
  Float::from_int(@raylib.get_random_value(-130, 130))
}

///|
fn launch(from_left : Bool, ox : Float, oy : Float, angle : Float, power : Float) -> (Float, Float, Float, Float) {
  let cs = cosf_deg(angle)
  let sn = sinf_deg(angle)
  let vx = if from_left {
    cs * power
  } else {
    -cs * power
  }
  let vy = -sn * power
  (ox, oy, vx, vy)
}

///|
fn blast_damage(ex : Float, ey : Float, cx : Float, cy : Float) -> Int {
  let dx = ex - cx
  let dy = ey - cy
  let d = (dx * dx + dy * dy).sqrt()
  if d > 134.0 {
    0
  } else {
    ((Float::from_int(134) - d) * 0.34).to_int() + 6
  }
}

///|
fn estimate_enemy_power(distance : Float, angle : Float, wind : Float) -> Float {
  let sin2 = sinf_deg(angle * 2.0)
  let mut p : Float = 560.0
  if absf(sin2) > 0.2 {
    let calc = (distance * gravity / sin2).abs()
    p = calc.sqrt()
  }
  p = p - wind * 0.45 + Float::from_int(@raylib.get_random_value(-28, 28))
  clampf(p, 300.0, 720.0)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Castle Siege Artillery 2026")
  @raylib.set_target_fps(60)

  let player_center_x = Float::from_int(player_x + castle_w / 2)
  let enemy_center_x = Float::from_int(enemy_x + castle_w / 2)
  let center_y = Float::from_int(ground_y - castle_h / 2)

  let mut player_hp = 240
  let mut enemy_hp = 240

  let mut player_angle : Float = 47.0
  let mut player_power : Float = 560.0
  let mut enemy_angle : Float = 45.0
  let mut enemy_power : Float = 560.0

  let mut wind = random_wind()
  let mut round = 1

  let mut player_turn = true
  let mut enemy_wait : Float = 0.0

  let mut shot_active = false
  let mut shot_x : Float = 0.0
  let mut shot_y : Float = 0.0
  let mut shot_vx : Float = 0.0
  let mut shot_vy : Float = 0.0
  let mut shot_owner = 0

  let mut blast_t : Float = 0.0
  let mut blast_x : Float = 0.0
  let mut blast_y : Float = 0.0

  let mut over = false
  let mut msg = "A/D adjust angle, W/S adjust power, Space fire."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_hp = 240
      enemy_hp = 240
      player_angle = 47.0
      player_power = 560.0
      enemy_angle = 45.0
      enemy_power = 560.0
      wind = random_wind()
      round = 1
      player_turn = true
      enemy_wait = 0.0
      shot_active = false
      shot_x = 0.0
      shot_y = 0.0
      shot_vx = 0.0
      shot_vy = 0.0
      shot_owner = 0
      blast_t = 0.0
      blast_x = 0.0
      blast_y = 0.0
      over = false
      msg = "Battle restarted."
    }

    if blast_t > 0.0 {
      blast_t = blast_t - dt
      if blast_t < 0.0 {
        blast_t = 0.0
      }
    }

    if not(over) {
      if shot_active {
        shot_vx = shot_vx + wind * dt * 0.20
        shot_vy = shot_vy + gravity * dt
        shot_x = shot_x + shot_vx * dt
        shot_y = shot_y + shot_vy * dt

        let mut impact = false
        let ix = shot_x
        let mut iy = shot_y

        if shot_x < -80.0 || shot_x > Float::from_int(sw + 80) || shot_y > Float::from_int(sh + 60) {
          impact = true
          iy = Float::from_int(ground_y)
        }

        if not(impact) && shot_y >= Float::from_int(ground_y) {
          impact = true
          iy = Float::from_int(ground_y)
        }

        if not(impact) && inside_rect(shot_x, shot_y, mountain_x, ground_y - mountain_h, mountain_w, mountain_h) {
          impact = true
        }

        if not(impact) && inside_rect(shot_x, shot_y, player_x, ground_y - castle_h, castle_w, castle_h) {
          impact = true
        }

        if not(impact) && inside_rect(shot_x, shot_y, enemy_x, ground_y - castle_h, castle_w, castle_h) {
          impact = true
        }

        if impact {
          shot_active = false
          blast_t = 0.45
          blast_x = ix
          blast_y = iy

          let pdmg = blast_damage(ix, iy, player_center_x, center_y)
          let edmg = blast_damage(ix, iy, enemy_center_x, center_y)

          if pdmg > 0 {
            player_hp = player_hp - pdmg
            if player_hp < 0 {
              player_hp = 0
            }
          }
          if edmg > 0 {
            enemy_hp = enemy_hp - edmg
            if enemy_hp < 0 {
              enemy_hp = 0
            }
          }

          if pdmg > 0 || edmg > 0 {
            msg = "Explosion dealt P:\{pdmg}  E:\{edmg}."
          } else {
            msg = "Shot missed both castles."
          }

          if player_hp <= 0 || enemy_hp <= 0 {
            over = true
            if player_hp <= 0 && enemy_hp <= 0 {
              msg = "Draw battle. Press R for rematch."
            } else if enemy_hp <= 0 {
              msg = "Victory! Your siege wins. Press R for rematch."
            } else {
              msg = "Defeat. Enemy artillery wins. Press R for rematch."
            }
          } else {
            if shot_owner == 0 {
              player_turn = false
              enemy_wait = 0.95
              msg = "Enemy is calculating trajectory..."
            } else {
              player_turn = true
              round = round + 1
              msg = "Your turn. Adjust and fire."
            }
            wind = random_wind()
          }
        }
      } else {
        if player_turn {
          let mut fired = false

          if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
            player_angle = player_angle - 44.0 * dt
          }
          if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
            player_angle = player_angle + 44.0 * dt
          }
          if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
            player_power = player_power + 210.0 * dt
          }
          if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
            player_power = player_power - 210.0 * dt
          }

          let base_x = 24
          let base_y = sh - 188
          let m = @raylib.get_mouse_position()
          if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
            if inside_rect(m.x, m.y, base_x, base_y, 86, 52) {
              player_angle = player_angle - 3.5
            }
            if inside_rect(m.x, m.y, base_x + 94, base_y, 86, 52) {
              player_angle = player_angle + 3.5
            }
            if inside_rect(m.x, m.y, base_x, base_y + 60, 86, 52) {
              player_power = player_power - 24.0
            }
            if inside_rect(m.x, m.y, base_x + 94, base_y + 60, 86, 52) {
              player_power = player_power + 24.0
            }
            if inside_rect(m.x, m.y, base_x, base_y + 120, 180, 56) {
              fired = true
            }
          }

          player_angle = clampf(player_angle, 16.0, 82.0)
          player_power = clampf(player_power, 260.0, 740.0)

          if @raylib.is_key_pressed(@raylib.KeySpace) {
            fired = true
          }

          if fired {
            let ox = Float::from_int(player_x + castle_w - 10)
            let oy = Float::from_int(ground_y - castle_h + 24)
            let (sx, sy, svx, svy) = launch(true, ox, oy, player_angle, player_power)
            shot_x = sx
            shot_y = sy
            shot_vx = svx
            shot_vy = svy
            shot_active = true
            shot_owner = 0
            msg = "Projectile launched."
          }
        } else {
          enemy_wait = enemy_wait - dt
          if enemy_wait <= 0.0 {
            enemy_angle = Float::from_int(@raylib.get_random_value(30, 60))
            let d = Float::from_int((enemy_x + castle_w / 2) - (player_x + castle_w / 2))
            enemy_power = estimate_enemy_power(d, enemy_angle, wind)

            let ox = Float::from_int(enemy_x + 10)
            let oy = Float::from_int(ground_y - castle_h + 24)
            let (sx, sy, svx, svy) = launch(false, ox, oy, enemy_angle, enemy_power)
            shot_x = sx
            shot_y = sy
            shot_vx = svx
            shot_vy = svy
            shot_active = true
            shot_owner = 1
            msg = "Enemy fired!"
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(16, 22, 34, 255))

    @raylib.draw_rectangle(0, 0, sw, ground_y - 130, @raylib.Color::new(82, 126, 188, 255))
    @raylib.draw_rectangle(0, ground_y - 130, sw, 130, @raylib.Color::new(204, 166, 104, 255))
    @raylib.draw_rectangle(0, ground_y, sw, sh - ground_y, @raylib.Color::new(106, 78, 52, 255))

    @raylib.draw_circle(sw / 2 + 220, 118, 52.0, @raylib.Color::new(250, 236, 170, 255))

    @raylib.draw_rectangle(mountain_x, ground_y - mountain_h, mountain_w, mountain_h, @raylib.Color::new(102, 82, 68, 255))
    @raylib.draw_triangle(
      @raylib.Vector2::new(Float::from_int(mountain_x), Float::from_int(ground_y - mountain_h)),
      @raylib.Vector2::new(Float::from_int(mountain_x + mountain_w), Float::from_int(ground_y - mountain_h)),
      @raylib.Vector2::new(Float::from_int(sw / 2), Float::from_int(ground_y - mountain_h - 70)),
      @raylib.Color::new(134, 112, 88, 255),
    )

    @raylib.draw_rectangle(player_x, ground_y - castle_h, castle_w, castle_h, @raylib.Color::new(116, 124, 148, 255))
    @raylib.draw_rectangle(player_x + 18, ground_y - castle_h - 36, 28, 36, @raylib.Color::new(140, 148, 174, 255))
    @raylib.draw_rectangle(player_x + 74, ground_y - castle_h - 42, 30, 42, @raylib.Color::new(140, 148, 174, 255))

    @raylib.draw_rectangle(enemy_x, ground_y - castle_h, castle_w, castle_h, @raylib.Color::new(148, 108, 108, 255))
    @raylib.draw_rectangle(enemy_x + 16, ground_y - castle_h - 40, 28, 40, @raylib.Color::new(172, 132, 132, 255))
    @raylib.draw_rectangle(enemy_x + 76, ground_y - castle_h - 30, 26, 30, @raylib.Color::new(172, 132, 132, 255))

    let wind_mid_x = sw / 2
    let wind_end_x = wind_mid_x + (wind * 0.9).to_int()
    @raylib.draw_line(wind_mid_x, 44, wind_end_x, 44, @raylib.white)
    @raylib.draw_circle(wind_end_x, 44, 5.0, @raylib.white)
    @raylib.draw_text("WIND", wind_mid_x - 40, 18, 22, @raylib.white)
    @raylib.draw_text("\{wind.to_int()}", wind_mid_x + 60, 18, 24, @raylib.Color::new(246, 224, 122, 255))

    @raylib.draw_rectangle(20, 16, 320, 24, @raylib.Color::new(28, 34, 46, 255))
    @raylib.draw_rectangle(20, 16, (player_hp * 320 / 240), 24, @raylib.Color::new(88, 228, 112, 255))
    @raylib.draw_text("PLAYER HP \{player_hp}", 28, 44, 24, @raylib.Color::new(220, 236, 248, 255))

    @raylib.draw_rectangle(sw - 340, 16, 320, 24, @raylib.Color::new(28, 34, 46, 255))
    @raylib.draw_rectangle(sw - 340, 16, (enemy_hp * 320 / 240), 24, @raylib.Color::new(240, 108, 108, 255))
    @raylib.draw_text("ENEMY HP \{enemy_hp}", sw - 284, 44, 24, @raylib.Color::new(220, 236, 248, 255))

    @raylib.draw_text("CASTLE SIEGE ARTILLERY 2026", 360, 76, 34, @raylib.Color::new(238, 244, 250, 255))
    @raylib.draw_text("Round \{round}", 592, 112, 26, @raylib.Color::new(252, 228, 140, 255))

    if player_turn && not(shot_active) && not(over) {
      let ox = Float::from_int(player_x + castle_w - 10)
      let oy = Float::from_int(ground_y - castle_h + 24)
      let cs = cosf_deg(player_angle)
      let sn = sinf_deg(player_angle)
      let ivx = cs * player_power
      let ivy = -sn * player_power
      let ax = wind * 0.20
      let ay = gravity

      for i = 1; i <= 24; i = i + 1 {
        let t = Float::from_int(i) * 0.11
        let tx = ox + ivx * t + 0.5 * ax * t * t
        let ty = oy + ivy * t + 0.5 * ay * t * t
        if tx >= 0.0 && tx <= Float::from_int(sw) && ty >= 0.0 && ty <= Float::from_int(sh) {
          @raylib.draw_circle(tx.to_int(), ty.to_int(), 3.0, @raylib.Color::new(248, 244, 186, 210))
        }
      }

      @raylib.draw_text("Angle \{player_angle.to_int()}", 24, 114, 24, @raylib.Color::new(242, 246, 252, 255))
      @raylib.draw_text("Power \{player_power.to_int()}", 24, 142, 24, @raylib.Color::new(242, 246, 252, 255))
    }

    if shot_active {
      @raylib.draw_circle(shot_x.to_int(), shot_y.to_int(), 7.0, @raylib.Color::new(30, 30, 36, 255))
      @raylib.draw_circle(shot_x.to_int(), shot_y.to_int(), 3.0, @raylib.Color::new(236, 236, 236, 255))
    }

    if blast_t > 0.0 {
      let f = blast_t / 0.45
      let radius : Float = 26.0 + (Float::from_int(1) - f) * 74.0
      @raylib.draw_circle(blast_x.to_int(), blast_y.to_int(), radius, @raylib.Color::new(250, 142, 66, 150))
      @raylib.draw_circle(blast_x.to_int(), blast_y.to_int(), radius * 0.55, @raylib.Color::new(254, 216, 118, 210))
    }

    let base_x = 24
    let base_y = sh - 188
    @raylib.draw_rectangle(14, sh - 202, 198, 192, @raylib.Color::new(14, 20, 30, 220))
    @raylib.draw_text("Touch", 82, sh - 198, 20, @raylib.white)

    @raylib.draw_rectangle(base_x, base_y, 86, 52, @raylib.Color::new(42, 58, 82, 255))
    @raylib.draw_text("ANG-", base_x + 16, base_y + 16, 22, @raylib.white)
    @raylib.draw_rectangle(base_x + 94, base_y, 86, 52, @raylib.Color::new(42, 58, 82, 255))
    @raylib.draw_text("ANG+", base_x + 110, base_y + 16, 22, @raylib.white)

    @raylib.draw_rectangle(base_x, base_y + 60, 86, 52, @raylib.Color::new(42, 58, 82, 255))
    @raylib.draw_text("POW-", base_x + 15, base_y + 76, 22, @raylib.white)
    @raylib.draw_rectangle(base_x + 94, base_y + 60, 86, 52, @raylib.Color::new(42, 58, 82, 255))
    @raylib.draw_text("POW+", base_x + 109, base_y + 76, 22, @raylib.white)

    @raylib.draw_rectangle(base_x, base_y + 120, 180, 56, @raylib.Color::new(180, 70, 64, 255))
    @raylib.draw_text("FIRE", base_x + 62, base_y + 138, 26, @raylib.white)

    @raylib.draw_rectangle(236, sh - 64, sw - 252, 42, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text(msg, 248, sh - 54, 24, @raylib.Color::new(232, 238, 246, 255))

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      @raylib.draw_rectangle(sw / 2 - 320, sh / 2 - 98, 640, 196, @raylib.Color::new(18, 28, 44, 242))
      @raylib.draw_text("BATTLE OVER", sw / 2 - 132, sh / 2 - 40, 48, @raylib.Color::new(248, 226, 136, 255))
      @raylib.draw_text("Press R to restart", sw / 2 - 118, sh / 2 + 22, 30, @raylib.Color::new(228, 238, 250, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
