///|
let sw : Int = 1280

///|
let sh : Int = 800

///|
let ground_y : Int = 642

///|
let max_bullets : Int = 140

///|
let max_drones : Int = 64

///|
let max_bombs : Int = 96

///|
struct Bullet {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut active : Bool
}

///|
struct Drone {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut kind : Int
  mut drop_cd : Float
  mut active : Bool
}

///|
struct Bomb {
  mut x : Float
  mut y : Float
  mut vy : Float
  mut active : Bool
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
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for bullet in bullets {
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.ttl = 0.0
    bullet.active = false
  }
}

///|
fn clear_drones(drones : Array[Drone]) -> Unit {
  for drone in drones {
    drone.x = 0.0
    drone.y = 0.0
    drone.vx = 0.0
    drone.vy = 0.0
    drone.hp = 0
    drone.drop_cd = 0.0
    drone.active = false
  }
}

///|
fn clear_bombs(bombs : Array[Bomb]) -> Unit {
  for bomb in bombs {
    bomb.x = 0.0
    bomb.y = 0.0
    bomb.vy = 0.0
    bomb.active = false
  }
}

///|
fn spawn_bullet(
  bullets : Array[Bullet],
  x : Float,
  y : Float,
  angle : Float,
) -> Unit {
  let vx = cosf_deg(angle) * 660.0
  let vy = -sinf_deg(angle) * 660.0
  let mut done = false
  for bullet in bullets {
    if done {
      continue
    }
    if not(bullet.active) {
      bullet.active = true
      bullet.x = x
      bullet.y = y
      bullet.vx = vx
      bullet.vy = vy
      bullet.ttl = 1.7
      done = true
    }
  }
}

///|
fn spawn_bomb(bombs : Array[Bomb], x : Float, y : Float, sector : Int) -> Unit {
  let mut done = false
  for bomb in bombs {
    if done {
      continue
    }
    if not(bomb.active) {
      bomb.active = true
      bomb.x = x
      bomb.y = y
      bomb.vy = Float::from_int(188 + sector * 24)
      done = true
    }
  }
}

///|
fn spawn_drone(drones : Array[Drone], sector : Int) -> Unit {
  let mut done = false
  for drone in drones {
    if done {
      continue
    }
    if not(drone.active) {
      let side = @raylib.get_random_value(0, 1)
      let kind = @raylib.get_random_value(0, 2)
      let y = Float::from_int(@raylib.get_random_value(78, 290))
      let base = if kind == 0 {
        Float::from_int(146 + sector * 14)
      } else if kind == 1 {
        Float::from_int(118 + sector * 12)
      } else {
        Float::from_int(96 + sector * 10)
      }
      let hp = if kind == 0 { 1 } else if kind == 1 { 2 } else { 3 }

      drone.active = true
      drone.x = if side == 0 { -34.0 } else { Float::from_int(sw) + 34.0 }
      drone.y = y
      drone.vx = if side == 0 { base } else { -base }
      drone.vy = Float::from_int(@raylib.get_random_value(26, 54))
      drone.kind = kind
      drone.hp = hp
      drone.drop_cd = Float::from_int(@raylib.get_random_value(70, 140)) /
        Float::from_int(100)
      done = true
    }
  }
}

///|
fn random_spawn_cd(sector : Int) -> Float {
  let mut lo = 58 - sector * 8
  if lo < 26 {
    lo = 26
  }
  let mut hi = 112 - sector * 10
  if hi < 48 {
    hi = 48
  }
  Float::from_int(@raylib.get_random_value(lo, hi)) / Float::from_int(100)
}

///|
fn convoy_center(progress : Float) -> Float {
  150.0 + progress * 0.95
}

///|
fn main {
  @raylib.init_window(sw, sh, "Sky Convoy Defense 2026")
  @raylib.set_target_fps(60)

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, active: false }
  })
  let drones : Array[Drone] = Array::makei(max_drones, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      hp: 0,
      kind: 0,
      drop_cd: 0.0,
      active: false,
    }
  })
  let bombs : Array[Bomb] = Array::makei(max_bombs, fn(_i) {
    { x: 0.0, y: 0.0, vy: 0.0, active: false }
  })

  clear_bullets(bullets)
  clear_drones(drones)
  clear_bombs(bombs)

  let turret_y = Float::from_int(ground_y - 22)

  let mut sector = 1
  let mut score = 0
  let mut convoy_hp = 300
  let mut progress : Float = 0.0
  let target_progress : Float = 1000.0

  let mut turret_x : Float = Float::from_int(sw / 2)
  let mut aim : Float = 86.0
  let mut fire_cd : Float = 0.0
  let mut spawn_cd : Float = 0.9

  let mut hit_flash : Float = 0.0
  let mut blast_t : Float = 0.0
  let mut blast_x : Float = 0.0
  let mut blast_y : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D move, W/S aim, Space/J fire. Protect the convoy."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      sector = 1
      score = 0
      convoy_hp = 300
      progress = 0.0
      turret_x = Float::from_int(sw / 2)
      aim = 86.0
      fire_cd = 0.0
      spawn_cd = 0.9
      hit_flash = 0.0
      blast_t = 0.0
      blast_x = 0.0
      blast_y = 0.0
      over = false
      won = false
      msg = "Escort mission restarted."
      clear_bullets(bullets)
      clear_drones(drones)
      clear_bombs(bombs)
    }

    if hit_flash > 0.0 {
      hit_flash = hit_flash - dt
      if hit_flash < 0.0 {
        hit_flash = 0.0
      }
    }

    if blast_t > 0.0 {
      blast_t = blast_t - dt
      if blast_t < 0.0 {
        blast_t = 0.0
      }
    }

    if not(over) {
      progress = progress + Float::from_int(56 + sector * 12) * dt
      if progress > target_progress {
        progress = target_progress
      }

      let convoy_cx = convoy_center(progress)
      let convoy_left = convoy_cx - 118.0
      let convoy_right = convoy_cx + 118.0
      let convoy_y = Float::from_int(ground_y - 18)

      let mut left_down = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut right_down = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut aim_up = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut aim_down = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)
      let mut fire_down = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeyK)

      let ctl_x = 24
      let ctl_y = sh - 170
      let fire_x = sw - 190
      let fire_y = sh - 146
      let mp = @raylib.get_mouse_position()
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(mp.x, mp.y, ctl_x, ctl_y, 80, 52) {
          left_down = true
        }
        if inside_rect(mp.x, mp.y, ctl_x + 90, ctl_y, 80, 52) {
          right_down = true
        }
        if inside_rect(mp.x, mp.y, ctl_x, ctl_y + 60, 80, 52) {
          aim_down = true
        }
        if inside_rect(mp.x, mp.y, ctl_x + 90, ctl_y + 60, 80, 52) {
          aim_up = true
        }
        if inside_rect(mp.x, mp.y, fire_x, fire_y, 156, 112) {
          fire_down = true
        }
      }

      if left_down {
        turret_x = turret_x - 300.0 * dt
      }
      if right_down {
        turret_x = turret_x + 300.0 * dt
      }
      turret_x = clampf(turret_x, 42.0, Float::from_int(sw - 42))

      if aim_up {
        aim = aim + 96.0 * dt
      }
      if aim_down {
        aim = aim - 96.0 * dt
      }
      aim = clampf(aim, 20.0, 160.0)

      if fire_cd > 0.0 {
        fire_cd = fire_cd - dt
        if fire_cd < 0.0 {
          fire_cd = 0.0
        }
      }

      if fire_down && fire_cd <= 0.0 {
        let tip_x = turret_x + cosf_deg(aim) * 38.0
        let tip_y = turret_y - sinf_deg(aim) * 38.0
        spawn_bullet(bullets, tip_x, tip_y, aim)
        fire_cd = 0.16
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_drone(drones, sector)
        spawn_cd = random_spawn_cd(sector)
      }

      let mut convoy_damage = 0

      for drone in drones {
        if not(drone.active) {
          continue
        }

        let tx = convoy_cx + Float::from_int(@raylib.get_random_value(-90, 90))
        let ty = convoy_y - Float::from_int(120 + drone.kind * 34)

        let dx = tx - drone.x
        let dy = ty - drone.y
        let d2 = dx * dx + dy * dy
        if d2 > 12.0 {
          let d = d2.sqrt()
          let seek : Float = if drone.kind == 0 {
            168.0
          } else if drone.kind == 1 {
            142.0
          } else {
            122.0
          }
          let desired_vx = dx / d * seek
          let desired_vy = dy / d * seek
          drone.vx = drone.vx * 0.90 + desired_vx * 0.10
          drone.vy = drone.vy * 0.90 + desired_vy * 0.10
        }

        drone.x = drone.x + drone.vx * dt
        drone.y = drone.y + drone.vy * dt

        drone.drop_cd = drone.drop_cd - dt
        if drone.drop_cd <= 0.0 {
          spawn_bomb(bombs, drone.x, drone.y + 12.0, sector)
          drone.drop_cd = if drone.kind == 2 {
            Float::from_int(@raylib.get_random_value(45, 95)) /
            Float::from_int(100)
          } else {
            Float::from_int(@raylib.get_random_value(70, 135)) /
            Float::from_int(100)
          }
        }

        if drone.y >= convoy_y - 10.0 &&
          drone.x >= convoy_left &&
          drone.x <= convoy_right {
          let dmg = if drone.kind == 0 {
            16
          } else if drone.kind == 1 {
            24
          } else {
            32
          }
          convoy_damage = convoy_damage + dmg
          drone.active = false
          blast_t = 0.30
          blast_x = drone.x
          blast_y = drone.y
        }

        if drone.x < -80.0 ||
          drone.x > Float::from_int(sw + 80) ||
          drone.y < -70.0 ||
          drone.y > Float::from_int(sh + 40) {
          drone.active = false
        }
      }

      for bomb in bombs {
        if not(bomb.active) {
          continue
        }

        bomb.y = bomb.y + bomb.vy * dt
        bomb.vy = bomb.vy + 62.0 * dt

        if bomb.y >= convoy_y {
          if bomb.x >= convoy_left && bomb.x <= convoy_right {
            let dmg = Float::from_int(@raylib.get_random_value(10, 20)).to_int()
            convoy_damage = convoy_damage + dmg
            hit_flash = 0.18
            blast_t = 0.24
            blast_x = bomb.x
            blast_y = convoy_y
          }
          bomb.active = false
        }

        if bomb.y > Float::from_int(sh + 24) {
          bomb.active = false
        }
      }

      for bullet in bullets {
        if not(bullet.active) {
          continue
        }

        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        bullet.ttl = bullet.ttl - dt

        if bullet.ttl <= 0.0 ||
          bullet.x < -20.0 ||
          bullet.x > Float::from_int(sw + 20) ||
          bullet.y < -30.0 ||
          bullet.y > Float::from_int(sh + 20) {
          bullet.active = false
          continue
        }

        let mut hit = false
        for drone in drones {
          if hit {
            continue
          }
          if not(drone.active) {
            continue
          }

          let r : Float = if drone.kind == 0 {
            15.0
          } else if drone.kind == 1 {
            19.0
          } else {
            23.0
          }

          let dx = bullet.x - drone.x
          let dy = bullet.y - drone.y
          if dx * dx + dy * dy <= r * r {
            bullet.active = false
            drone.hp = drone.hp - 1
            if drone.hp <= 0 {
              drone.active = false
              let gain = if drone.kind == 0 {
                35
              } else if drone.kind == 1 {
                55
              } else {
                85
              }
              score = score + gain
              blast_t = 0.34
              blast_x = drone.x
              blast_y = drone.y
            }
            hit = true
          }
        }
      }

      if convoy_damage > 0 {
        convoy_hp = convoy_hp - convoy_damage
        if convoy_hp < 0 {
          convoy_hp = 0
        }
        hit_flash = 0.20
        msg = "Convoy took \{convoy_damage} damage."
      }

      if convoy_hp <= 0 {
        over = true
        won = false
        msg = "Convoy destroyed. Press R to retry escort."
      }

      if progress >= target_progress {
        sector = sector + 1
        if sector > 3 {
          over = true
          won = true
          msg = "Convoy arrived safely. Mission complete."
        } else {
          progress = 0.0
          convoy_hp = convoy_hp + 60
          if convoy_hp > 320 {
            convoy_hp = 320
          }
          clear_bullets(bullets)
          clear_drones(drones)
          clear_bombs(bombs)
          spawn_cd = 0.8
          msg = "Sector \{sector} started. Air raids intensify."
        }
      }
    }

    let convoy_cx = convoy_center(progress)

    @raylib.begin_drawing()

    if hit_flash > 0.0 {
      @raylib.clear_background(@raylib.Color::new(48, 18, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(16, 24, 40, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, 300, @raylib.Color::new(32, 56, 94, 255))
    @raylib.draw_rectangle(
      0,
      300,
      sw,
      210,
      @raylib.Color::new(52, 86, 128, 255),
    )
    @raylib.draw_circle(
      sw - 160,
      110,
      58.0,
      @raylib.Color::new(242, 228, 170, 255),
    )

    @raylib.draw_triangle(
      @raylib.Vector2::new(60.0, Float::from_int(ground_y)),
      @raylib.Vector2::new(310.0, 360.0),
      @raylib.Vector2::new(560.0, Float::from_int(ground_y)),
      @raylib.Color::new(78, 80, 98, 255),
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(430.0, Float::from_int(ground_y)),
      @raylib.Vector2::new(680.0, 370.0),
      @raylib.Vector2::new(940.0, Float::from_int(ground_y)),
      @raylib.Color::new(88, 88, 106, 255),
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(820.0, Float::from_int(ground_y)),
      @raylib.Vector2::new(1040.0, 346.0),
      @raylib.Vector2::new(1260.0, Float::from_int(ground_y)),
      @raylib.Color::new(74, 76, 92, 255),
    )

    @raylib.draw_rectangle(
      0,
      ground_y - 36,
      sw,
      42,
      @raylib.Color::new(64, 70, 80, 255),
    )
    @raylib.draw_rectangle(
      0,
      ground_y + 6,
      sw,
      sh - ground_y,
      @raylib.Color::new(84, 62, 50, 255),
    )

    for i in 0..<26 {
      let x = i * 62 + 20
      @raylib.draw_rectangle(
        x,
        ground_y - 18,
        30,
        6,
        @raylib.Color::new(188, 180, 122, 255),
      )
    }

    for i in 0..<3 {
      let tx = (convoy_cx - 94.0 + Float::from_int(i * 74)).to_int()
      let ty = ground_y - 62
      @raylib.draw_rectangle(
        tx,
        ty,
        56,
        34,
        @raylib.Color::new(54, 146, 198, 255),
      )
      @raylib.draw_rectangle(
        tx + 8,
        ty + 8,
        22,
        14,
        @raylib.Color::new(206, 224, 238, 255),
      )
      @raylib.draw_rectangle(
        tx + 2,
        ty + 34,
        14,
        10,
        @raylib.Color::new(22, 22, 24, 255),
      )
      @raylib.draw_rectangle(
        tx + 40,
        ty + 34,
        14,
        10,
        @raylib.Color::new(22, 22, 24, 255),
      )
      @raylib.draw_rectangle(
        tx + 56,
        ty + 12,
        8,
        14,
        @raylib.Color::new(250, 196, 96, 255),
      )
    }

    let base_x = turret_x.to_int()
    let base_y = turret_y.to_int()
    @raylib.draw_circle(
      base_x,
      base_y,
      24.0,
      @raylib.Color::new(74, 86, 108, 255),
    )
    @raylib.draw_circle(
      base_x,
      base_y,
      14.0,
      @raylib.Color::new(34, 44, 62, 255),
    )

    let tip_x = turret_x + cosf_deg(aim) * 40.0
    let tip_y = turret_y - sinf_deg(aim) * 40.0
    @raylib.draw_line_ex(
      @raylib.Vector2::new(turret_x, turret_y),
      @raylib.Vector2::new(tip_x, tip_y),
      10.0,
      @raylib.Color::new(102, 120, 150, 255),
    )
    @raylib.draw_circle(
      tip_x.to_int(),
      tip_y.to_int(),
      6.0,
      @raylib.Color::new(228, 232, 238, 255),
    )

    for drone in drones {
      if not(drone.active) {
        continue
      }
      if drone.kind == 0 {
        @raylib.draw_circle(
          drone.x.to_int(),
          drone.y.to_int(),
          11.0,
          @raylib.Color::new(250, 220, 98, 255),
        )
        @raylib.draw_line(
          (drone.x - 16.0).to_int(),
          drone.y.to_int(),
          (drone.x + 16.0).to_int(),
          drone.y.to_int(),
          @raylib.Color::new(96, 76, 26, 255),
        )
      } else if drone.kind == 1 {
        @raylib.draw_rectangle(
          (drone.x - 14.0).to_int(),
          (drone.y - 10.0).to_int(),
          28,
          20,
          @raylib.Color::new(236, 146, 92, 255),
        )
        @raylib.draw_circle(
          (drone.x - 14.0).to_int(),
          drone.y.to_int(),
          6.0,
          @raylib.Color::new(52, 42, 32, 255),
        )
        @raylib.draw_circle(
          (drone.x + 14.0).to_int(),
          drone.y.to_int(),
          6.0,
          @raylib.Color::new(52, 42, 32, 255),
        )
      } else {
        @raylib.draw_rectangle(
          (drone.x - 20.0).to_int(),
          (drone.y - 12.0).to_int(),
          40,
          24,
          @raylib.Color::new(224, 96, 92, 255),
        )
        @raylib.draw_rectangle(
          (drone.x - 8.0).to_int(),
          (drone.y - 18.0).to_int(),
          16,
          6,
          @raylib.Color::new(244, 188, 126, 255),
        )
        @raylib.draw_circle(
          (drone.x - 18.0).to_int(),
          (drone.y + 12.0).to_int(),
          6.0,
          @raylib.Color::new(42, 34, 30, 255),
        )
        @raylib.draw_circle(
          (drone.x + 18.0).to_int(),
          (drone.y + 12.0).to_int(),
          6.0,
          @raylib.Color::new(42, 34, 30, 255),
        )
      }
    }

    for bomb in bombs {
      if not(bomb.active) {
        continue
      }
      @raylib.draw_line(
        bomb.x.to_int(),
        (bomb.y - 16.0).to_int(),
        bomb.x.to_int(),
        bomb.y.to_int(),
        @raylib.Color::new(250, 180, 122, 255),
      )
      @raylib.draw_circle(
        bomb.x.to_int(),
        bomb.y.to_int(),
        5.0,
        @raylib.Color::new(246, 212, 144, 255),
      )
    }

    for bullet in bullets {
      if not(bullet.active) {
        continue
      }
      @raylib.draw_circle(
        bullet.x.to_int(),
        bullet.y.to_int(),
        4.0,
        @raylib.Color::new(236, 240, 250, 255),
      )
      @raylib.draw_circle(
        (bullet.x - 1.0).to_int(),
        (bullet.y - 1.0).to_int(),
        2.0,
        @raylib.Color::new(136, 188, 246, 255),
      )
    }

    if blast_t > 0.0 {
      let t = blast_t / 0.34
      let r : Float = 16.0 + (Float::from_int(1) - t) * 60.0
      @raylib.draw_circle(
        blast_x.to_int(),
        blast_y.to_int(),
        r,
        @raylib.Color::new(250, 136, 84, 164),
      )
      @raylib.draw_circle(
        blast_x.to_int(),
        blast_y.to_int(),
        r * 0.58,
        @raylib.Color::new(254, 224, 144, 236),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 96, @raylib.Color::new(10, 14, 24, 224))
    @raylib.draw_text(
      "SKY CONVOY DEFENSE 2026",
      18,
      20,
      34,
      @raylib.Color::new(236, 242, 252, 255),
    )
    @raylib.draw_text(
      "Sector \{sector}/3",
      458,
      26,
      30,
      @raylib.Color::new(244, 226, 130, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      660,
      26,
      30,
      @raylib.Color::new(222, 236, 250, 255),
    )
    @raylib.draw_text(
      "Aim \{aim.to_int()} deg",
      860,
      26,
      30,
      @raylib.Color::new(192, 220, 250, 255),
    )

    @raylib.draw_rectangle(20, 72, 300, 14, @raylib.Color::new(32, 44, 62, 255))
    @raylib.draw_rectangle(
      20,
      72,
      convoy_hp * 300 / 320,
      14,
      @raylib.Color::new(92, 232, 136, 255),
    )
    @raylib.draw_text(
      "Convoy HP \{convoy_hp}",
      332,
      66,
      22,
      @raylib.Color::new(228, 238, 250, 255),
    )

    @raylib.draw_rectangle(
      540,
      72,
      420,
      14,
      @raylib.Color::new(32, 44, 62, 255),
    )
    @raylib.draw_rectangle(
      540,
      72,
      (progress / target_progress * 420.0).to_int(),
      14,
      @raylib.Color::new(110, 200, 252, 255),
    )
    @raylib.draw_text(
      "Route",
      972,
      66,
      22,
      @raylib.Color::new(228, 238, 250, 255),
    )

    let ctl_x = 24
    let ctl_y = sh - 170
    @raylib.draw_rectangle(
      10,
      sh - 184,
      178,
      160,
      @raylib.Color::new(10, 16, 28, 220),
    )
    @raylib.draw_text("Touch", 68, sh - 180, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      80,
      52,
      @raylib.Color::new(46, 66, 94, 255),
    )
    @raylib.draw_text("LEFT", ctl_x + 16, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 90,
      ctl_y,
      80,
      52,
      @raylib.Color::new(46, 66, 94, 255),
    )
    @raylib.draw_text("RIGHT", ctl_x + 96, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x,
      ctl_y + 60,
      80,
      52,
      @raylib.Color::new(46, 66, 94, 255),
    )
    @raylib.draw_text("AIM-", ctl_x + 16, ctl_y + 76, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 90,
      ctl_y + 60,
      80,
      52,
      @raylib.Color::new(46, 66, 94, 255),
    )
    @raylib.draw_text("AIM+", ctl_x + 105, ctl_y + 76, 20, @raylib.white)

    let fire_x = sw - 190
    let fire_y = sh - 146
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      156,
      112,
      @raylib.Color::new(190, 82, 76, 255),
    )
    @raylib.draw_text("FIRE", fire_x + 45, fire_y + 38, 34, @raylib.white)

    @raylib.draw_rectangle(
      202,
      sh - 54,
      sw - 406,
      34,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text(
      msg,
      212,
      sh - 48,
      21,
      @raylib.Color::new(226, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 124))
      @raylib.draw_rectangle(
        sw / 2 - 340,
        sh / 2 - 104,
        680,
        208,
        @raylib.Color::new(16, 24, 40, 244),
      )
      @raylib.draw_text(
        if won {
          "ESCORT SUCCESS"
        } else {
          "ESCORT FAILED"
        },
        sw / 2 - 196,
        sh / 2 - 38,
        56,
        if won {
          @raylib.Color::new(248, 236, 144, 255)
        } else {
          @raylib.Color::new(250, 126, 126, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 122,
        sh / 2 + 36,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
