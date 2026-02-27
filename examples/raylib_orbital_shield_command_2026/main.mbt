///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let cx : Float = 640.0

///|
let cy : Float = 410.0

///|
let planet_r : Float = 74.0

///|
let shield_r : Float = 148.0

///|
let max_enemies : Int = 96

///|
let max_shots : Int = 180

///|
let max_sparks : Int = 220

///|
struct Enemy {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut kind : Int
  mut active : Bool
}

///|
struct Shot {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut active : Bool
}

///|
struct Spark {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut active : Bool
  mut kind : Int
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
fn deg2rad(a : Float) -> Double {
  a.to_double() * 0.017453292519943295
}

///|
fn sinf_deg(a : Float) -> Float {
  Float::from_double(@math.sin(deg2rad(a)))
}

///|
fn cosf_deg(a : Float) -> Float {
  Float::from_double(@math.cos(deg2rad(a)))
}

///|
fn enemy_radius(kind : Int) -> Float {
  if kind == 0 {
    12.0
  } else if kind == 1 {
    17.0
  } else {
    23.0
  }
}

///|
fn enemy_score(kind : Int) -> Int {
  if kind == 0 {
    24
  } else if kind == 1 {
    42
  } else {
    80
  }
}

///|
fn enemy_damage(kind : Int) -> Int {
  if kind == 0 {
    10
  } else if kind == 1 {
    16
  } else {
    24
  }
}

///|
fn enemy_hp(kind : Int) -> Int {
  if kind == 0 {
    1
  } else if kind == 1 {
    2
  } else {
    4
  }
}

///|
fn clear_shots(shots : Array[Shot]) -> Unit {
  for i = 0; i < shots.length(); i = i + 1 {
    shots[i].x = 0.0
    shots[i].y = 0.0
    shots[i].vx = 0.0
    shots[i].vy = 0.0
    shots[i].ttl = 0.0
    shots[i].active = false
  }
}

///|
fn clear_enemies(enemies : Array[Enemy]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].x = 0.0
    enemies[i].y = 0.0
    enemies[i].vx = 0.0
    enemies[i].vy = 0.0
    enemies[i].hp = 0
    enemies[i].kind = 0
    enemies[i].active = false
  }
}

///|
fn clear_sparks(sparks : Array[Spark]) -> Unit {
  for i = 0; i < sparks.length(); i = i + 1 {
    sparks[i].x = 0.0
    sparks[i].y = 0.0
    sparks[i].vx = 0.0
    sparks[i].vy = 0.0
    sparks[i].ttl = 0.0
    sparks[i].active = false
    sparks[i].kind = 0
  }
}

///|
fn spawn_spark(
  sparks : Array[Spark],
  x : Float,
  y : Float,
  speed_scale : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < sparks.length(); i = i + 1 {
    if done {
      continue
    }
    if not(sparks[i].active) {
      sparks[i].active = true
      sparks[i].x = x
      sparks[i].y = y
      sparks[i].vx = Float::from_int(@raylib.get_random_value(-220, 220)) *
        speed_scale
      sparks[i].vy = Float::from_int(@raylib.get_random_value(-220, 220)) *
        speed_scale
      sparks[i].ttl = Float::from_int(@raylib.get_random_value(16, 55)) /
        Float::from_int(100)
      sparks[i].kind = kind
      done = true
    }
  }
}

///|
fn spawn_burst(
  sparks : Array[Spark],
  x : Float,
  y : Float,
  n : Int,
  speed_scale : Float,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_spark(sparks, x, y, speed_scale, kind)
  }
}

///|
fn spawn_shot(
  shots : Array[Shot],
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
) -> Unit {
  let dx = tx - x
  let dy = ty - y
  let d2 = dx * dx + dy * dy
  if d2 <= 0.001 {
    return
  }
  let d = d2.sqrt()
  let speed : Float = 700.0

  let mut done = false
  for i = 0; i < shots.length(); i = i + 1 {
    if done {
      continue
    }
    if not(shots[i].active) {
      shots[i].active = true
      shots[i].x = x
      shots[i].y = y
      shots[i].vx = dx / d * speed
      shots[i].vy = dy / d * speed
      shots[i].ttl = 1.7
      done = true
    }
  }
}

///|
fn spawn_enemy(enemies : Array[Enemy], sector : Int) -> Unit {
  let side = @raylib.get_random_value(0, 3)
  let kind_roll = @raylib.get_random_value(0, 99)
  let kind = if kind_roll < 56 { 0 } else if kind_roll < 86 { 1 } else { 2 }

  let mut ex : Float = 0.0
  let mut ey : Float = 0.0
  if side == 0 {
    ex = -40.0
    ey = Float::from_int(@raylib.get_random_value(20, sh - 20))
  } else if side == 1 {
    ex = Float::from_int(sw) + 40.0
    ey = Float::from_int(@raylib.get_random_value(20, sh - 20))
  } else if side == 2 {
    ex = Float::from_int(@raylib.get_random_value(20, sw - 20))
    ey = -40.0
  } else {
    ex = Float::from_int(@raylib.get_random_value(20, sw - 20))
    ey = Float::from_int(sh) + 40.0
  }

  let tx = cx + Float::from_int(@raylib.get_random_value(-120, 120))
  let ty = cy + Float::from_int(@raylib.get_random_value(-120, 120))
  let dx = tx - ex
  let dy = ty - ey
  let d = (dx * dx + dy * dy).sqrt()
  if d <= 0.001 {
    return
  }

  let mut base_speed : Float = 0.0
  if kind == 0 {
    base_speed = Float::from_int(110 + sector * 18)
  } else if kind == 1 {
    base_speed = Float::from_int(95 + sector * 16)
  } else {
    base_speed = Float::from_int(78 + sector * 14)
  }

  let mut done = false
  for i = 0; i < enemies.length(); i = i + 1 {
    if done {
      continue
    }
    if not(enemies[i].active) {
      enemies[i].active = true
      enemies[i].x = ex
      enemies[i].y = ey
      enemies[i].vx = dx / d * base_speed
      enemies[i].vy = dy / d * base_speed
      enemies[i].kind = kind
      enemies[i].hp = enemy_hp(kind)
      done = true
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Orbital Shield Command 2026")
  @raylib.set_target_fps(60)

  let enemies : Array[Enemy] = Array::makei(max_enemies, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, hp: 0, kind: 0, active: false }
  })
  let shots : Array[Shot] = Array::makei(max_shots, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, active: false }
  })
  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, active: false, kind: 0 }
  })

  clear_enemies(enemies)
  clear_shots(shots)
  clear_sparks(sparks)

  let mut sector = 1
  let mut sector_timer : Float = 0.0
  let mut score = 0
  let mut planet_hp = 260

  let mut shield_angle : Float = 0.0
  let mut fire_cd : Float = 0.0
  let mut spawn_cd : Float = 0.7

  let mut shake_t : Float = 0.0
  let mut flash_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D rotate shield, Space/J fire. Block enemies before impact."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      clear_enemies(enemies)
      clear_shots(shots)
      clear_sparks(sparks)

      sector = 1
      sector_timer = 0.0
      score = 0
      planet_hp = 260
      shield_angle = 0.0
      fire_cd = 0.0
      spawn_cd = 0.7
      shake_t = 0.0
      flash_t = 0.0
      over = false
      won = false
      msg = "Defense grid restarted."
    }

    if fire_cd > 0.0 {
      fire_cd = fire_cd - dt
      if fire_cd < 0.0 {
        fire_cd = 0.0
      }
    }
    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }
    if flash_t > 0.0 {
      flash_t = flash_t - dt
      if flash_t < 0.0 {
        flash_t = 0.0
      }
    }

    if not(over) {
      sector_timer = sector_timer + dt
      if sector_timer >= 46.0 {
        sector_timer = 0.0
        sector = sector + 1
        if sector > 3 {
          over = true
          won = true
          msg = "Planet secured. Orbit stable."
        } else {
          msg = "Sector \{sector}: enemy velocity increased."
          clear_enemies(enemies)
          clear_shots(shots)
        }
      }

      let mut left_down = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut right_down = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut fire_down = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeyK)

      let ctl_x = 24
      let ctl_y = sh - 176
      let fire_x = sw - 212
      let fire_y = sh - 152
      let m = @raylib.get_mouse_position()
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x, ctl_y, 78, 54) {
          left_down = true
        }
        if inside_rect(m.x, m.y, ctl_x + 86, ctl_y, 78, 54) {
          right_down = true
        }
        if inside_rect(m.x, m.y, fire_x, fire_y, 182, 116) {
          fire_down = true
        }
      }

      let rot_speed : Float = Float::from_int(145 + sector * 10)
      if left_down {
        shield_angle = shield_angle - rot_speed * dt
      }
      if right_down {
        shield_angle = shield_angle + rot_speed * dt
      }

      if shield_angle < -180.0 {
        shield_angle = shield_angle + 360.0
      }
      if shield_angle > 180.0 {
        shield_angle = shield_angle - 360.0
      }

      let shield_dx = cosf_deg(shield_angle)
      let shield_dy = sinf_deg(shield_angle)
      let shield_x = cx + shield_dx * shield_r
      let shield_y = cy + shield_dy * shield_r

      if fire_down && fire_cd <= 0.0 {
        spawn_shot(shots, shield_x, shield_y, m.x, m.y)
        fire_cd = 0.16
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_enemy(enemies, sector)
        let mut next : Float = 0.74 - Float::from_int(sector - 1) * 0.10
        if next < 0.20 {
          next = 0.20
        }
        spawn_cd = next
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }

        shots[i].x = shots[i].x + shots[i].vx * dt
        shots[i].y = shots[i].y + shots[i].vy * dt
        shots[i].ttl = shots[i].ttl - dt

        if shots[i].ttl <= 0.0 ||
          shots[i].x < -32.0 ||
          shots[i].x > Float::from_int(sw + 32) ||
          shots[i].y < -32.0 ||
          shots[i].y > Float::from_int(sh + 32) {
          shots[i].active = false
        }
      }

      let mut planet_hit = 0

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        let dx_c = cx - enemies[i].x
        let dy_c = cy - enemies[i].y
        let d2_c = dx_c * dx_c + dy_c * dy_c
        if d2_c > 0.001 {
          let d_c = d2_c.sqrt()
          let tx = dx_c / d_c
          let ty = dy_c / d_c

          // Mild orbiting drift for heavier enemy kinds.
          let orbit : Float = if enemies[i].kind == 0 {
            0.0
          } else if enemies[i].kind == 1 {
            24.0
          } else {
            38.0
          }
          enemies[i].vx = enemies[i].vx * 0.97 +
            tx * 6.0 * dt +
            -ty * orbit * dt
          enemies[i].vy = enemies[i].vy * 0.97 + ty * 6.0 * dt + tx * orbit * dt
        }

        enemies[i].x = enemies[i].x + enemies[i].vx * dt
        enemies[i].y = enemies[i].y + enemies[i].vy * dt

        let rx = enemies[i].x - cx
        let ry = enemies[i].y - cy
        let dist = (rx * rx + ry * ry).sqrt()
        let er = enemy_radius(enemies[i].kind)

        if dist <= planet_r + er * 0.75 {
          planet_hit = planet_hit + enemy_damage(enemies[i].kind)
          spawn_burst(sparks, enemies[i].x, enemies[i].y, 14, 1.0, 2)
          enemies[i].active = false
          continue
        }

        if dist <= shield_r + er + 6.0 && dist >= shield_r - er - 9.0 {
          if dist > 0.001 {
            let nx = rx / dist
            let ny = ry / dist
            let dot = nx * shield_dx + ny * shield_dy
            if dot >= 0.88 {
              if enemies[i].kind == 2 {
                enemies[i].hp = enemies[i].hp - 1
                if enemies[i].hp <= 0 {
                  enemies[i].active = false
                  score = score + enemy_score(2)
                  spawn_burst(sparks, enemies[i].x, enemies[i].y, 18, 1.1, 1)
                } else {
                  enemies[i].vx = nx * (120.0 + Float::from_int(sector * 26))
                  enemies[i].vy = ny * (120.0 + Float::from_int(sector * 26))
                  spawn_burst(sparks, enemies[i].x, enemies[i].y, 9, 0.9, 0)
                }
              } else {
                enemies[i].active = false
                score = score + enemy_score(enemies[i].kind)
                spawn_burst(sparks, enemies[i].x, enemies[i].y, 12, 1.0, 0)
              }
              continue
            }
          }
        }

        if enemies[i].x < -80.0 ||
          enemies[i].x > Float::from_int(sw + 80) ||
          enemies[i].y < -80.0 ||
          enemies[i].y > Float::from_int(sh + 80) {
          enemies[i].active = false
        }
      }

      if planet_hit > 0 {
        planet_hp = planet_hp - planet_hit
        if planet_hp < 0 {
          planet_hp = 0
        }
        flash_t = 0.24
        shake_t = 0.16
        msg = "Planet impact: -\{planet_hit} HP"
      }

      for i = 0; i < shots.length(); i = i + 1 {
        if not(shots[i].active) {
          continue
        }

        let mut hit = false
        for j = 0; j < enemies.length(); j = j + 1 {
          if hit {
            continue
          }
          if not(enemies[j].active) {
            continue
          }

          let dx = shots[i].x - enemies[j].x
          let dy = shots[i].y - enemies[j].y
          let rr = (enemy_radius(enemies[j].kind) + 5.0) *
            (enemy_radius(enemies[j].kind) + 5.0)
          if dx * dx + dy * dy <= rr {
            shots[i].active = false
            enemies[j].hp = enemies[j].hp - 1
            hit = true

            if enemies[j].hp <= 0 {
              enemies[j].active = false
              score = score + enemy_score(enemies[j].kind)
              spawn_burst(sparks, enemies[j].x, enemies[j].y, 14, 1.0, 1)
            } else {
              spawn_burst(sparks, enemies[j].x, enemies[j].y, 8, 0.7, 0)
            }
          }
        }
      }

      if planet_hp <= 0 {
        over = true
        won = false
        msg = "Core destroyed. Press R to restart defense."
      }
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      sparks[i].x = sparks[i].x + sparks[i].vx * dt
      sparks[i].y = sparks[i].y + sparks[i].vy * dt
      sparks[i].vx = sparks[i].vx * (Float::from_int(1) - dt * 2.4)
      sparks[i].vy = sparks[i].vy * (Float::from_int(1) - dt * 2.4)
      sparks[i].ttl = sparks[i].ttl - dt
      if sparks[i].ttl <= 0.0 {
        sparks[i].active = false
      }
    }

    let shake_x = if shake_t > 0.0 {
      Float::from_int(@raylib.get_random_value(-6, 6)) * shake_t * 8.0
    } else {
      0.0
    }
    let shake_y = if shake_t > 0.0 {
      Float::from_int(@raylib.get_random_value(-6, 6)) * shake_t * 8.0
    } else {
      0.0
    }

    let render_cx = cx + shake_x
    let render_cy = cy + shake_y

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(38, 16, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 24, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 18, 34, 255))
    @raylib.draw_rectangle(0, 0, sw, 260, @raylib.Color::new(18, 32, 58, 255))

    for i = 0; i < 130; i = i + 1 {
      let x = (i * 97 + sector * 53) % sw
      let y = (i * 61 + sector * 37) % sh
      let b = 138 + i * 19 % 108
      @raylib.draw_circle(
        x,
        y,
        1.0 + Float::from_int(i % 2),
        @raylib.Color::new(b, b, b + 10, 255),
      )
    }

    @raylib.draw_circle_lines(
      render_cx.to_int(),
      render_cy.to_int(),
      shield_r - 28.0,
      @raylib.Color::new(54, 90, 148, 120),
    )
    @raylib.draw_circle_lines(
      render_cx.to_int(),
      render_cy.to_int(),
      shield_r + 28.0,
      @raylib.Color::new(54, 90, 148, 120),
    )

    @raylib.draw_circle(
      render_cx.to_int(),
      render_cy.to_int(),
      planet_r + 8.0,
      @raylib.Color::new(44, 88, 170, 255),
    )
    @raylib.draw_circle(
      render_cx.to_int(),
      render_cy.to_int(),
      planet_r - 14.0,
      @raylib.Color::new(26, 58, 124, 255),
    )
    @raylib.draw_circle(
      (render_cx - 20.0).to_int(),
      (render_cy - 18.0).to_int(),
      planet_r * 0.34,
      @raylib.Color::new(110, 166, 232, 180),
    )

    let sdx = cosf_deg(shield_angle)
    let sdy = sinf_deg(shield_angle)

    for i = -7; i <= 7; i = i + 1 {
      let a = shield_angle + Float::from_int(i) * 3.2
      let dx = cosf_deg(a)
      let dy = sinf_deg(a)
      let w : Float = if i == 0 { 10.0 } else { 7.0 }
      let p1 = @raylib.Vector2::new(
        render_cx + dx * (shield_r - 22.0),
        render_cy + dy * (shield_r - 22.0),
      )
      let p2 = @raylib.Vector2::new(
        render_cx + dx * (shield_r + 22.0),
        render_cy + dy * (shield_r + 22.0),
      )
      @raylib.draw_line_ex(p1, p2, w, @raylib.Color::new(102, 234, 246, 230))
    }

    let hx = render_cx + sdx * shield_r
    let hy = render_cy + sdy * shield_r
    @raylib.draw_circle(
      hx.to_int(),
      hy.to_int(),
      12.0,
      @raylib.Color::new(224, 248, 252, 255),
    )

    for i = 0; i < enemies.length(); i = i + 1 {
      if not(enemies[i].active) {
        continue
      }
      let ex = enemies[i].x + shake_x
      let ey = enemies[i].y + shake_y
      if enemies[i].kind == 0 {
        @raylib.draw_circle(
          ex.to_int(),
          ey.to_int(),
          12.0,
          @raylib.Color::new(248, 204, 92, 255),
        )
      } else if enemies[i].kind == 1 {
        @raylib.draw_rectangle(
          (ex - 15.0).to_int(),
          (ey - 12.0).to_int(),
          30,
          24,
          @raylib.Color::new(246, 132, 84, 255),
        )
        @raylib.draw_circle(
          (ex - 16.0).to_int(),
          ey.to_int(),
          6.0,
          @raylib.Color::new(66, 46, 34, 255),
        )
        @raylib.draw_circle(
          (ex + 16.0).to_int(),
          ey.to_int(),
          6.0,
          @raylib.Color::new(66, 46, 34, 255),
        )
      } else {
        @raylib.draw_rectangle(
          (ex - 20.0).to_int(),
          (ey - 16.0).to_int(),
          40,
          32,
          @raylib.Color::new(238, 86, 98, 255),
        )
        @raylib.draw_rectangle(
          (ex - 8.0).to_int(),
          (ey - 21.0).to_int(),
          16,
          8,
          @raylib.Color::new(254, 176, 126, 255),
        )
      }
    }

    for i = 0; i < shots.length(); i = i + 1 {
      if not(shots[i].active) {
        continue
      }
      let sx = shots[i].x + shake_x
      let sy = shots[i].y + shake_y
      @raylib.draw_circle(
        sx.to_int(),
        sy.to_int(),
        4.0,
        @raylib.Color::new(236, 244, 254, 255),
      )
      @raylib.draw_circle(
        (sx - 1.0).to_int(),
        (sy - 1.0).to_int(),
        2.0,
        @raylib.Color::new(124, 198, 252, 255),
      )
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      let a = (sparks[i].ttl * 255.0).to_int()
      if a <= 0 {
        continue
      }
      let c = if sparks[i].kind == 0 {
        @raylib.Color::new(126, 236, 250, a)
      } else if sparks[i].kind == 1 {
        @raylib.Color::new(250, 216, 132, a)
      } else {
        @raylib.Color::new(252, 124, 124, a)
      }
      @raylib.draw_circle(
        (sparks[i].x + shake_x).to_int(),
        (sparks[i].y + shake_y).to_int(),
        2.5,
        c,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 98, @raylib.Color::new(8, 12, 20, 228))
    @raylib.draw_text(
      "ORBITAL SHIELD COMMAND 2026",
      16,
      20,
      34,
      @raylib.Color::new(236, 242, 252, 255),
    )
    @raylib.draw_text(
      "Sector \{sector}/3",
      474,
      28,
      30,
      @raylib.Color::new(246, 228, 136, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      668,
      28,
      30,
      @raylib.Color::new(214, 234, 250, 255),
    )

    @raylib.draw_rectangle(
      860,
      28,
      320,
      20,
      @raylib.Color::new(28, 42, 66, 255),
    )
    @raylib.draw_rectangle(
      860,
      28,
      planet_hp * 320 / 260,
      20,
      @raylib.Color::new(98, 226, 138, 255),
    )
    @raylib.draw_text(
      "Core HP \{planet_hp}",
      976,
      54,
      24,
      @raylib.Color::new(224, 238, 250, 255),
    )

    @raylib.draw_rectangle(20, 76, 300, 12, @raylib.Color::new(26, 36, 56, 255))
    @raylib.draw_rectangle(
      20,
      76,
      (sector_timer / 46.0 * 300.0).to_int(),
      12,
      @raylib.Color::new(112, 198, 252, 255),
    )
    @raylib.draw_text(
      "Sector timer",
      326,
      68,
      20,
      @raylib.Color::new(200, 226, 246, 255),
    )

    let ctl_x = 24
    let ctl_y = sh - 176
    @raylib.draw_rectangle(
      10,
      sh - 190,
      168,
      166,
      @raylib.Color::new(10, 16, 28, 220),
    )
    @raylib.draw_text("Touch", 64, sh - 186, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      78,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @raylib.draw_text("LEFT", ctl_x + 18, ctl_y + 18, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 86,
      ctl_y,
      78,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @raylib.draw_text("RIGHT", ctl_x + 95, ctl_y + 18, 20, @raylib.white)

    let fire_x = sw - 212
    let fire_y = sh - 152
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      182,
      116,
      @raylib.Color::new(186, 82, 76, 255),
    )
    @raylib.draw_text("FIRE", fire_x + 58, fire_y + 42, 36, @raylib.white)

    @raylib.draw_rectangle(
      184,
      sh - 52,
      sw - 398,
      36,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text(
      msg,
      194,
      sh - 46,
      22,
      @raylib.Color::new(224, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 124))
      @raylib.draw_rectangle(
        sw / 2 - 350,
        sh / 2 - 108,
        700,
        216,
        @raylib.Color::new(16, 24, 40, 244),
      )
      @raylib.draw_text(
        if won {
          "PLANET SECURED"
        } else {
          "DEFENSE COLLAPSED"
        },
        sw / 2 - 246,
        sh / 2 - 40,
        56,
        if won {
          @raylib.Color::new(248, 236, 142, 255)
        } else {
          @raylib.Color::new(250, 128, 128, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 38,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
