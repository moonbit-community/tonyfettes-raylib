///|
let sw : Int = 1280

///|
let sh : Int = 800

///|
let world_w : Float = 4600.0

///|
let world_h : Float = 3200.0

///|
let max_cops : Int = 26

///|
let max_pickups : Int = 44

///|
let max_smokes : Int = 12

///|
let max_particles : Int = 1200

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dir_x : Float
  mut dir_y : Float
  mut hp : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut smoke_cd : Float
  mut hit_cd : Float
  mut shake_t : Float
  mut flash_t : Float
  mut drift : Float
  mut cash : Int
  mut combo : Int
}

///|
struct Cop {
  mut active : Bool
  kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut stun_t : Float
  mut reroute_t : Float
  mut agro : Float
}

///|
struct Pickup {
  active : Bool
  x : Float
  y : Float
  value : Int
  mut spin_t : Float
  mut pulse_t : Float
}

///|
struct Smoke {
  mut active : Bool
  x : Float
  y : Float
  mut r : Float
  mut t : Float
  mut life : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  size : Float
  mut t : Float
  life : Float
  kind : Int
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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx : Float = ax - bx
  let dy : Float = ay - by
  dx * dx + dy * dy
}

///|
fn inside_rect(px : Float, py : Float, x : Int, y : Int, w : Int, h : Int) -> Bool {
  let x0 : Float = Float::from_int(x)
  let y0 : Float = Float::from_int(y)
  let x1 : Float = Float::from_int(x + w)
  let y1 : Float = Float::from_int(y + h)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn emit_particle(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  size : Float,
  life : Float,
  kind : Int
) -> Unit {
  for i = 0; i < particles.length(); i = i + 1 {
    if not(particles[i].active) {
      particles[i] = {
        active: true,
        x,
        y,
        vx,
        vy,
        size,
        t: 0.0,
        life,
        kind,
      }
      break
    }
  }
}

///|
fn burst_particles(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  count : Int,
  power : Float,
  kind : Int
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let mut dx : Float = randf(-1.0, 1.0)
    let mut dy : Float = randf(-1.0, 1.0)
    let d2 : Float = dx * dx + dy * dy
    if d2 < 0.0001 {
      dx = 1.0
      dy = 0.0
    } else {
      let inv : Float = 1.0 / d2.sqrt()
      dx = dx * inv
      dy = dy * inv
    }
    let spd : Float = randf(power * 0.35, power)
    emit_particle(
      particles,
      x,
      y,
      dx * spd,
      dy * spd,
      randf(2.0, 6.5),
      randf(0.25, 0.9),
      kind,
    )
  }
}

///|
fn respawn_pickup(pickups : FixedArray[Pickup], idx : Int, level : Int) -> Unit {
  let base_value : Int = 60 + level * 18
  let bonus : Int = @raylib.get_random_value(0, 80 + level * 20)
  pickups[idx] = {
    active: true,
    x: randf(240.0, world_w - 220.0),
    y: randf(220.0, world_h - 220.0),
    value: base_value + bonus,
    spin_t: randf(0.0, 3.0),
    pulse_t: randf(0.0, 1.0),
  }
}

///|
fn init_pickups(pickups : FixedArray[Pickup], level : Int) -> Unit {
  for i = 0; i < pickups.length(); i = i + 1 {
    respawn_pickup(pickups, i, level)
  }
}

///|
fn init_cops(cops : FixedArray[Cop], level : Int) -> Unit {
  let total : Int = clampf(Float::from_int(10 + level * 3), 10.0, Float::from_int(max_cops)).to_int()
  for i = 0; i < cops.length(); i = i + 1 {
    if i < total {
      let kind : Int = if i % 4 == 0 { 1 } else { 0 }
      cops[i] = {
        active: true,
        kind,
        x: randf(280.0, world_w - 280.0),
        y: randf(280.0, world_h - 280.0),
        vx: randf(-60.0, 60.0),
        vy: randf(-60.0, 60.0),
        stun_t: 0.0,
        reroute_t: randf(0.2, 1.4),
        agro: randf(0.65, 1.25),
      }
    } else {
      cops[i].active = false
    }
  }
}

///|
fn spawn_smoke(smokes : FixedArray[Smoke], x : Float, y : Float) -> Unit {
  for i = 0; i < smokes.length(); i = i + 1 {
    if not(smokes[i].active) {
      smokes[i] = {
        active: true,
        x,
        y,
        r: 36.0,
        t: 0.0,
        life: 3.8,
      }
      break
    }
  }
}

///|
fn draw_bar(x : Int, y : Int, w : Int, h : Int, ratio : Float, fg : @raylib.Color, bg : @raylib.Color) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, bg)
  let r : Float = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(x + 2, y + 2, (Float::from_int(w - 4) * r).to_int(), h - 4, fg)
  @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(220, 230, 244, 170))
}

///|
fn draw_touch_controls(show : Bool) -> Unit {
  if not(show) {
    return
  }

  let pad_x : Int = 24
  let pad_y : Int = sh - 224
  let act_x : Int = sw - 214

  @raylib.draw_rectangle(pad_x, pad_y + 62, 78, 78, @raylib.Color::new(70, 94, 128, 88))
  @raylib.draw_text("L", pad_x + 30, pad_y + 88, 30, @raylib.Color::new(240, 244, 252, 220))

  @raylib.draw_rectangle(pad_x + 168, pad_y + 62, 78, 78, @raylib.Color::new(70, 94, 128, 88))
  @raylib.draw_text("R", pad_x + 198, pad_y + 88, 30, @raylib.Color::new(240, 244, 252, 220))

  @raylib.draw_rectangle(pad_x + 84, pad_y, 78, 78, @raylib.Color::new(70, 94, 128, 88))
  @raylib.draw_text("U", pad_x + 112, pad_y + 26, 30, @raylib.Color::new(240, 244, 252, 220))

  @raylib.draw_rectangle(pad_x + 84, pad_y + 124, 78, 78, @raylib.Color::new(70, 94, 128, 88))
  @raylib.draw_text("D", pad_x + 112, pad_y + 150, 30, @raylib.Color::new(240, 244, 252, 220))

  @raylib.draw_rectangle(act_x, pad_y + 16, 174, 78, @raylib.Color::new(196, 118, 98, 94))
  @raylib.draw_text("BOOST", act_x + 42, pad_y + 42, 28, @raylib.Color::new(254, 238, 228, 230))

  @raylib.draw_rectangle(act_x, pad_y + 116, 174, 78, @raylib.Color::new(120, 142, 210, 94))
  @raylib.draw_text("SMOKE", act_x + 44, pad_y + 142, 28, @raylib.Color::new(240, 246, 255, 230))
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [moonbit] example - drift police chase 2026")
  defer @raylib.close_window()

  @raylib.set_target_fps(60)

  let cops = FixedArray::make(max_cops, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    stun_t: 0.0,
    reroute_t: 0.0,
    agro: 1.0,
  })

  let pickups = FixedArray::make(max_pickups, {
    active: false,
    x: 0.0,
    y: 0.0,
    value: 0,
    spin_t: 0.0,
    pulse_t: 0.0,
  })

  let smokes = FixedArray::make(max_smokes, {
    active: false,
    x: 0.0,
    y: 0.0,
    r: 0.0,
    t: 0.0,
    life: 0.0,
  })

  let particles = FixedArray::make(max_particles, {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    size: 0.0,
    t: 0.0,
    life: 0.0,
    kind: 0,
  })

  let player = {
    x: 420.0,
    y: 420.0,
    vx: 0.0,
    vy: 0.0,
    dir_x: 1.0,
    dir_y: 0.0,
    hp: 100.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    smoke_cd: 0.0,
    hit_cd: 0.0,
    shake_t: 0.0,
    flash_t: 0.0,
    drift: 0.0,
    cash: 0,
    combo: 0,
  }

  let mut heat : Float = 10.0
  let mut level : Int = 1
  let mut goal_cash : Int = 1700
  let mut time_left : Float = 178.0
  let mut state : Int = 0
  let mut announce_t : Float = 0.0

  let reset_round = fn(new_level : Int) {
    level = new_level

    goal_cash = 1700 + (level - 1) * 620
    time_left = 184.0 - Float::from_int(level - 1) * 14.0
    if time_left < 98.0 {
      time_left = 98.0
    }

    player.x = 420.0
    player.y = 420.0
    player.vx = 0.0
    player.vy = 0.0
    player.dir_x = 1.0
    player.dir_y = 0.0
    player.hp = 100.0
    player.boost_t = 0.0
    player.boost_cd = 0.0
    player.smoke_cd = 0.0
    player.hit_cd = 0.0
    player.shake_t = 0.0
    player.flash_t = 0.0
    player.drift = 0.0
    player.cash = 0
    player.combo = 0

    heat = 10.0 + Float::from_int(level - 1) * 6.0

    for i = 0; i < smokes.length(); i = i + 1 {
      smokes[i].active = false
    }
    for i = 0; i < particles.length(); i = i + 1 {
      particles[i].active = false
    }

    init_cops(cops, level)
    init_pickups(pickups, level)

    announce_t = 2.8
  }

  reset_round(level)

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
    let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
    let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
    let mut boost_down : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) || @raylib.is_key_down(@raylib.KeySpace)
    let mut smoke_press : Bool = @raylib.is_key_pressed(@raylib.KeyE)

    let pad_x : Int = 24
    let pad_y : Int = sh - 224
    let act_x : Int = sw - 214

    if touching {
      if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 62, 78, 78) {
        move_l = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 62, 78, 78) {
        move_r = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 78, 78) {
        move_u = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 124, 78, 78) {
        move_d = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 16, 174, 78) {
        boost_down = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 116, 174, 78) {
        smoke_press = true
      }
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      state = 1
      reset_round(level)
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
        state = 1
        reset_round(level)
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
        if state == 2 {
          level = level + 1
          if level > 7 {
            level = 7
          }
        }
        state = 1
        reset_round(level)
      }
    } else {
      time_left = time_left - dt
      if time_left < 0.0 {
        time_left = 0.0
      }

      if player.boost_t > 0.0 {
        player.boost_t = player.boost_t - dt
        if player.boost_t < 0.0 {
          player.boost_t = 0.0
        }
      }
      if player.boost_cd > 0.0 {
        player.boost_cd = player.boost_cd - dt
        if player.boost_cd < 0.0 {
          player.boost_cd = 0.0
        }
      }
      if player.smoke_cd > 0.0 {
        player.smoke_cd = player.smoke_cd - dt
        if player.smoke_cd < 0.0 {
          player.smoke_cd = 0.0
        }
      }
      if player.hit_cd > 0.0 {
        player.hit_cd = player.hit_cd - dt
        if player.hit_cd < 0.0 {
          player.hit_cd = 0.0
        }
      }
      if player.shake_t > 0.0 {
        player.shake_t = player.shake_t - dt
        if player.shake_t < 0.0 {
          player.shake_t = 0.0
        }
      }
      if player.flash_t > 0.0 {
        player.flash_t = player.flash_t - dt
        if player.flash_t < 0.0 {
          player.flash_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      if boost_down && player.boost_cd <= 0.0 {
        player.boost_t = 1.2
        player.boost_cd = 3.2
        burst_particles(particles, player.x, player.y, 22, 140.0, 2)
      }

      if smoke_press && player.smoke_cd <= 0.0 {
        player.smoke_cd = 4.6
        spawn_smoke(smokes, player.x - player.dir_x * 18.0, player.y - player.dir_y * 18.0)
        burst_particles(particles, player.x, player.y, 30, 84.0, 1)
      }

      let mut ix : Float = 0.0
      let mut iy : Float = 0.0
      if move_l {
        ix = ix - 1.0
      }
      if move_r {
        ix = ix + 1.0
      }
      if move_u {
        iy = iy - 1.0
      }
      if move_d {
        iy = iy + 1.0
      }

      let mag2 : Float = ix * ix + iy * iy
      if mag2 > 1.0 {
        let inv : Float = 1.0 / mag2.sqrt()
        ix = ix * inv
        iy = iy * inv
      }

      let accel : Float = if player.boost_t > 0.0 { 710.0 } else { 440.0 }
      let max_speed : Float = if player.boost_t > 0.0 { 470.0 } else { 295.0 }
      let drag : Float = if player.boost_t > 0.0 { 1.25 } else { 2.0 }

      player.vx = player.vx + (ix * accel - player.vx * drag) * dt
      player.vy = player.vy + (iy * accel - player.vy * drag) * dt

      let speed2 : Float = player.vx * player.vx + player.vy * player.vy
      let speed : Float = speed2.sqrt()
      if speed > max_speed {
        let inv : Float = max_speed / speed
        player.vx = player.vx * inv
        player.vy = player.vy * inv
      }

      if speed > 8.0 {
        let inv : Float = 1.0 / speed
        player.dir_x = player.vx * inv
        player.dir_y = player.vy * inv
      }

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      if player.x < 48.0 {
        player.x = 48.0
        player.vx = player.vx.abs() * 0.35
        player.hp = player.hp - 7.0 * dt
      }
      if player.x > world_w - 48.0 {
        player.x = world_w - 48.0
        player.vx = -player.vx.abs() * 0.35
        player.hp = player.hp - 7.0 * dt
      }
      if player.y < 48.0 {
        player.y = 48.0
        player.vy = player.vy.abs() * 0.35
        player.hp = player.hp - 7.0 * dt
      }
      if player.y > world_h - 48.0 {
        player.y = world_h - 48.0
        player.vy = -player.vy.abs() * 0.35
        player.hp = player.hp - 7.0 * dt
      }

      player.drift = player.drift + speed * dt * 0.08
      if ix == 0.0 && iy == 0.0 {
        player.drift = player.drift - 24.0 * dt
      }
      player.drift = clampf(player.drift, 0.0, 220.0)

      heat = heat + dt * (0.75 + speed * 0.004)
      if player.boost_t > 0.0 {
        heat = heat + dt * 8.2
      }

      for i = 0; i < smokes.length(); i = i + 1 {
        if not(smokes[i].active) {
          continue
        }
        smokes[i].t = smokes[i].t + dt
        smokes[i].r = smokes[i].r + dt * 96.0
        if smokes[i].r > 280.0 {
          smokes[i].r = 280.0
        }
        smokes[i].life = smokes[i].life - dt
        if smokes[i].life <= 0.0 {
          smokes[i].active = false
          continue
        }

        let d2 : Float = dist2(player.x, player.y, smokes[i].x, smokes[i].y)
        if d2 <= smokes[i].r * smokes[i].r {
          heat = heat - 12.0 * dt
        }
      }

      let mut near_cops : Int = 0
      for i = 0; i < cops.length(); i = i + 1 {
        if not(cops[i].active) {
          continue
        }

        if cops[i].stun_t > 0.0 {
          cops[i].stun_t = cops[i].stun_t - dt
          if cops[i].stun_t < 0.0 {
            cops[i].stun_t = 0.0
          }
        }

        cops[i].reroute_t = cops[i].reroute_t - dt
        if cops[i].reroute_t <= 0.0 {
          cops[i].reroute_t = randf(0.6, 1.6)
          cops[i].agro = randf(0.75, 1.3)
        }

        let lead_x : Float = player.x + player.vx * 0.35 + randf(-40.0, 40.0)
        let lead_y : Float = player.y + player.vy * 0.35 + randf(-40.0, 40.0)

        let dx : Float = lead_x - cops[i].x
        let dy : Float = lead_y - cops[i].y
        let d2 : Float = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        if d < 260.0 {
          near_cops = near_cops + 1
        }

        let mut in_smoke : Bool = false
        for j = 0; j < smokes.length(); j = j + 1 {
          if not(smokes[j].active) {
            continue
          }
          let sd2 : Float = dist2(cops[i].x, cops[i].y, smokes[j].x, smokes[j].y)
          if sd2 <= smokes[j].r * smokes[j].r {
            in_smoke = true
            break
          }
        }

        if in_smoke {
          cops[i].stun_t = 0.85
        }

        if cops[i].stun_t > 0.0 {
          cops[i].vx = cops[i].vx * (1.0 - dt * 2.8)
          cops[i].vy = cops[i].vy * (1.0 - dt * 2.8)
        } else {
          let base_speed : Float = if cops[i].kind == 0 { 228.0 } else { 286.0 }
          let speed_gain : Float = heat * (if cops[i].kind == 0 { 0.56 } else { 0.74 })
          let cop_speed : Float = (base_speed + speed_gain) * cops[i].agro
          let tx : Float = dx / d * cop_speed
          let ty : Float = dy / d * cop_speed
          cops[i].vx = cops[i].vx + (tx - cops[i].vx * 1.65) * dt
          cops[i].vy = cops[i].vy + (ty - cops[i].vy * 1.65) * dt
        }

        cops[i].x = cops[i].x + cops[i].vx * dt
        cops[i].y = cops[i].y + cops[i].vy * dt

        if cops[i].x < 40.0 {
          cops[i].x = 40.0
          cops[i].vx = cops[i].vx.abs()
        }
        if cops[i].x > world_w - 40.0 {
          cops[i].x = world_w - 40.0
          cops[i].vx = -cops[i].vx.abs()
        }
        if cops[i].y < 40.0 {
          cops[i].y = 40.0
          cops[i].vy = cops[i].vy.abs()
        }
        if cops[i].y > world_h - 40.0 {
          cops[i].y = world_h - 40.0
          cops[i].vy = -cops[i].vy.abs()
        }

        let rr : Float = 34.0
        if dist2(player.x, player.y, cops[i].x, cops[i].y) <= rr * rr {
          if player.boost_t > 0.0 && speed > 220.0 {
            cops[i].stun_t = 1.1
            player.cash = player.cash + 26
            heat = heat - 5.0
            burst_particles(particles, cops[i].x, cops[i].y, 16, 94.0, 2)
          } else if player.hit_cd <= 0.0 {
            let dmg : Float = 13.0 + heat * 0.12 + Float::from_int(cops[i].kind) * 3.5
            player.hp = player.hp - dmg
            player.hit_cd = 0.62
            player.flash_t = 0.18
            player.shake_t = 0.24
            player.combo = 0
            heat = heat + 9.0

            let pdx : Float = player.x - cops[i].x
            let pdy : Float = player.y - cops[i].y
            let pd2 : Float = pdx * pdx + pdy * pdy
            let pinv : Float = if pd2 < 1.0 { 0.0 } else { 1.0 / pd2.sqrt() }
            player.vx = player.vx + pdx * pinv * 150.0
            player.vy = player.vy + pdy * pinv * 150.0
            cops[i].vx = cops[i].vx - pdx * pinv * 130.0
            cops[i].vy = cops[i].vy - pdy * pinv * 130.0

            burst_particles(particles, player.x, player.y, 24, 112.0, 2)
          }
        }
      }

      heat = heat + Float::from_int(near_cops) * dt * 0.9
      heat = clampf(heat, 0.0, 120.0)

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }

        pickups[i].spin_t = pickups[i].spin_t + dt * 1.5
        pickups[i].pulse_t = pickups[i].pulse_t + dt
        if pickups[i].pulse_t > 1.2 {
          pickups[i].pulse_t = pickups[i].pulse_t - 1.2
        }

        let grab_r : Float = 34.0
        if dist2(player.x, player.y, pickups[i].x, pickups[i].y) <= grab_r * grab_r {
          let gain : Int = pickups[i].value + player.combo * 5
          player.cash = player.cash + gain
          player.combo = player.combo + 1
          if player.combo > 20 {
            player.combo = 20
          }
          heat = heat + 4.0
          burst_particles(particles, pickups[i].x, pickups[i].y, 20, 76.0, 1)
          respawn_pickup(pickups, i, level)
        }
      }

      if speed > 120.0 {
        emit_particle(
          particles,
          player.x - player.dir_x * 16.0,
          player.y - player.dir_y * 16.0,
          -player.dir_x * randf(30.0, 90.0) + randf(-20.0, 20.0),
          -player.dir_y * randf(30.0, 90.0) + randf(-20.0, 20.0),
          randf(2.0, 4.2),
          randf(0.12, 0.35),
          0,
        )
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }
        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
          continue
        }
        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vx = particles[i].vx * (1.0 - dt * 0.8)
        particles[i].vy = particles[i].vy * (1.0 - dt * 0.8)
      }

      player.hp = clampf(player.hp, 0.0, 100.0)

      if player.cash >= goal_cash {
        player.cash = player.cash + time_left.to_int() * 4 + player.hp.to_int() * 5
        state = 2
      } else if player.hp <= 0.0 || time_left <= 0.0 {
        state = 3
      }
    }

    let mut cam_x : Float = player.x - Float::from_int(sw) * 0.5
    let mut cam_y : Float = player.y - Float::from_int(sh) * 0.5
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_y < 0.0 {
      cam_y = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }
    if cam_y > world_h - Float::from_int(sh) {
      cam_y = world_h - Float::from_int(sh)
    }

    let shake_x : Float = if player.shake_t > 0.0 { randf(-6.0, 6.0) * (player.shake_t * 3.5) } else { 0.0 }
    let shake_y : Float = if player.shake_t > 0.0 { randf(-4.0, 4.0) * (player.shake_t * 3.5) } else { 0.0 }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(10, 16, 28, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 30, 42, 255))

    let mut bx : Float = 120.0
    let mut gx : Int = 0
    while bx < world_w {
      let mut by : Float = 120.0
      let mut gy : Int = 0
      while by < world_h {
        let px : Int = (bx - cam_x + shake_x).to_int()
        let py : Int = (by - cam_y + shake_y).to_int()

        if px > -220 && py > -220 && px < sw + 220 && py < sh + 220 {
          let tone : Int = 34 + ((gx + gy) % 3) * 12
          @raylib.draw_rectangle(px, py, 196, 136, @raylib.Color::new(tone, tone + 10, tone + 20, 255))
          @raylib.draw_rectangle(px + 12, py + 12, 172, 112, @raylib.Color::new(tone + 10, tone + 14, tone + 30, 255))
        }

        by = by + 220.0
        gy = gy + 1
      }

      bx = bx + 260.0
      gx = gx + 1
    }

    let lane_col = @raylib.Color::new(130, 138, 154, 115)
    let mut lx : Float = 0.0
    while lx <= world_w {
      let sx : Int = (lx - cam_x + shake_x).to_int()
      if sx >= -4 && sx <= sw + 4 {
        @raylib.draw_line(sx, 0, sx, sh, lane_col)
      }
      lx = lx + 140.0
    }

    let mut ly : Float = 0.0
    while ly <= world_h {
      let sy : Int = (ly - cam_y + shake_y).to_int()
      if sy >= -4 && sy <= sh + 4 {
        @raylib.draw_line(0, sy, sw, sy, lane_col)
      }
      ly = ly + 140.0
    }

    for i = 0; i < smokes.length(); i = i + 1 {
      if not(smokes[i].active) {
        continue
      }
      let sx : Float = smokes[i].x - cam_x + shake_x
      let sy : Float = smokes[i].y - cam_y + shake_y
      if sx < -320.0 || sy < -320.0 || sx > Float::from_int(sw + 320) || sy > Float::from_int(sh + 320) {
        continue
      }
      let life_ratio : Float = 1.0 - smokes[i].t / smokes[i].life
      let alpha : Int = clampf(110.0 * life_ratio, 0.0, 130.0).to_int()
      @raylib.draw_circle(sx.to_int(), sy.to_int(), smokes[i].r, @raylib.Color::new(136, 152, 164, alpha))
      @raylib.draw_circle(sx.to_int(), sy.to_int(), smokes[i].r * 0.65, @raylib.Color::new(94, 108, 122, alpha + 24))
    }

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }
      let px : Float = pickups[i].x - cam_x + shake_x
      let py : Float = pickups[i].y - cam_y + shake_y
      if px < -32.0 || py < -32.0 || px > Float::from_int(sw + 32) || py > Float::from_int(sh + 32) {
        continue
      }

      let pulse : Float = 1.0 + pickups[i].pulse_t * 0.9
      let glow : Float = 12.0 + pulse * 6.0
      @raylib.draw_circle(px.to_int(), py.to_int(), glow, @raylib.Color::new(248, 210, 116, 96))
      @raylib.draw_rectangle((px - 12.0).to_int(), (py - 10.0).to_int(), 24, 20, @raylib.Color::new(254, 220, 118, 255))
      @raylib.draw_rectangle((px - 7.0).to_int(), (py - 5.0).to_int(), 14, 10, @raylib.Color::new(252, 244, 210, 255))
    }

    for i = 0; i < cops.length(); i = i + 1 {
      if not(cops[i].active) {
        continue
      }

      let cx : Float = cops[i].x - cam_x + shake_x
      let cy : Float = cops[i].y - cam_y + shake_y
      if cx < -80.0 || cy < -80.0 || cx > Float::from_int(sw + 80) || cy > Float::from_int(sh + 80) {
        continue
      }

      let ccol = if cops[i].stun_t > 0.0 {
        @raylib.Color::new(132, 206, 236, 255)
      } else if cops[i].kind == 0 {
        @raylib.Color::new(234, 86, 86, 255)
      } else {
        @raylib.Color::new(252, 132, 72, 255)
      }

      @raylib.draw_rectangle((cx - 16.0).to_int(), (cy - 12.0).to_int(), 32, 24, ccol)
      @raylib.draw_rectangle((cx - 10.0).to_int(), (cy - 8.0).to_int(), 20, 8, @raylib.Color::new(226, 234, 244, 255))

      let cd2 : Float = cops[i].vx * cops[i].vx + cops[i].vy * cops[i].vy
      let inv : Float = if cd2 < 1.0 { 0.0 } else { 1.0 / cd2.sqrt() }
      let fx : Float = if inv == 0.0 { 1.0 } else { cops[i].vx * inv }
      let fy : Float = if inv == 0.0 { 0.0 } else { cops[i].vy * inv }
      @raylib.draw_line(
        cx.to_int(),
        cy.to_int(),
        (cx + fx * 24.0).to_int(),
        (cy + fy * 24.0).to_int(),
        @raylib.Color::new(254, 248, 232, 220),
      )

      let flash_on : Bool = ((time_left.to_int() + i) % 2) == 0
      let light_a = if flash_on { 220 } else { 120 }
      @raylib.draw_rectangle((cx - 14.0).to_int(), (cy - 18.0).to_int(), 12, 5, @raylib.Color::new(242, 82, 82, light_a))
      @raylib.draw_rectangle((cx + 2.0).to_int(), (cy - 18.0).to_int(), 12, 5, @raylib.Color::new(88, 148, 252, light_a))
    }

    let px : Float = player.x - cam_x + shake_x
    let py : Float = player.y - cam_y + shake_y

    let pcol = if player.flash_t > 0.0 {
      @raylib.Color::new(254, 242, 186, 255)
    } else if player.boost_t > 0.0 {
      @raylib.Color::new(130, 236, 202, 255)
    } else {
      @raylib.Color::new(112, 202, 248, 255)
    }

    @raylib.draw_rectangle((px - 18.0).to_int(), (py - 13.0).to_int(), 36, 26, pcol)
    @raylib.draw_rectangle((px - 12.0).to_int(), (py - 8.0).to_int(), 24, 9, @raylib.Color::new(240, 248, 254, 255))
    @raylib.draw_line(
      px.to_int(),
      py.to_int(),
      (px + player.dir_x * 26.0).to_int(),
      (py + player.dir_y * 26.0).to_int(),
      @raylib.Color::new(24, 38, 58, 255),
    )

    let drift_w : Float = clampf(player.drift * 0.14, 0.0, 18.0)
    @raylib.draw_line((px - 18.0).to_int(), (py + 13.0).to_int(), (px - 18.0 - drift_w).to_int(), (py + 13.0).to_int(), @raylib.Color::new(208, 214, 222, 180))
    @raylib.draw_line((px + 18.0).to_int(), (py + 13.0).to_int(), (px + 18.0 + drift_w).to_int(), (py + 13.0).to_int(), @raylib.Color::new(208, 214, 222, 180))

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let vx : Float = particles[i].x - cam_x + shake_x
      let vy : Float = particles[i].y - cam_y + shake_y
      if vx < -20.0 || vy < -20.0 || vx > Float::from_int(sw + 20) || vy > Float::from_int(sh + 20) {
        continue
      }

      let life_ratio : Float = 1.0 - particles[i].t / particles[i].life
      let alpha : Int = clampf(life_ratio * 220.0, 0.0, 220.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(206, 216, 228, alpha)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 182, 112, alpha)
      } else {
        @raylib.Color::new(150, 220, 252, alpha)
      }
      @raylib.draw_circle(vx.to_int(), vy.to_int(), particles[i].size * life_ratio, col)
    }

    @raylib.draw_rectangle(16, 14, 540, 190, @raylib.Color::new(12, 20, 34, 204))
    @raylib.draw_rectangle_lines(16, 14, 540, 190, @raylib.Color::new(220, 232, 246, 138))

    @raylib.draw_text("DRIFT POLICE CHASE 2026", 30, 26, 34, @raylib.Color::new(236, 244, 254, 250))
    @raylib.draw_text("Move: WASD/Arrows  Boost: Shift/Space  Smoke: E", 32, 66, 22, @raylib.Color::new(186, 204, 232, 242))

    draw_bar(30, 98, 220, 20, player.hp / 100.0, @raylib.Color::new(226, 120, 110, 255), @raylib.Color::new(86, 52, 52, 230))
    @raylib.draw_text("Integrity", 256, 96, 22, @raylib.Color::new(216, 230, 244, 242))

    draw_bar(30, 126, 220, 20, 1.0 - heat / 120.0, @raylib.Color::new(108, 212, 170, 255), @raylib.Color::new(60, 80, 68, 230))
    @raylib.draw_text("Heat", 256, 124, 22, @raylib.Color::new(216, 230, 244, 242))

    let boost_ready : Float = if player.boost_cd <= 0.0 { 1.0 } else { 1.0 - player.boost_cd / 3.2 }
    draw_bar(30, 154, 220, 20, boost_ready, @raylib.Color::new(120, 188, 248, 255), @raylib.Color::new(54, 70, 94, 230))
    @raylib.draw_text("Boost", 256, 152, 22, @raylib.Color::new(216, 230, 244, 242))

    @raylib.draw_text(
      "Cash \{player.cash}/\{goal_cash}   Combo x\{player.combo}   Level \{level}",
      32,
      182,
      24,
      @raylib.Color::new(246, 238, 206, 248),
    )

    let heat_col = if heat > 90.0 {
      @raylib.Color::new(252, 130, 110, 255)
    } else if heat > 60.0 {
      @raylib.Color::new(252, 196, 118, 255)
    } else {
      @raylib.Color::new(154, 230, 176, 255)
    }

    @raylib.draw_text("Wanted Heat: \{heat.to_int()}", sw - 356, 22, 34, heat_col)
    @raylib.draw_text("Time: \{time_left.to_int()}s", sw - 356, 60, 30, @raylib.Color::new(242, 244, 250, 248))

    let smoke_txt = if player.smoke_cd <= 0.0 { "Smoke READY" } else { "Smoke CD \{player.smoke_cd.to_int()}" }
    let boost_txt = if player.boost_cd <= 0.0 { "Boost READY" } else { "Boost CD \{player.boost_cd.to_int()}" }
    @raylib.draw_text(boost_txt, sw - 356, 96, 24, @raylib.Color::new(188, 220, 252, 246))
    @raylib.draw_text(smoke_txt, sw - 356, 122, 24, @raylib.Color::new(212, 218, 236, 246))

    if announce_t > 0.0 {
      let alpha : Int = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Collect cash drops and outrun the police net.",
        sw / 2 - 320,
        214,
        36,
        @raylib.Color::new(246, 248, 252, alpha),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 220))
      @raylib.draw_text("DRIFT POLICE CHASE", sw / 2 - 342, sh / 2 - 116, 78, @raylib.Color::new(238, 246, 252, 255))
      @raylib.draw_text("High-speed escape through a neon city dragnet.", sw / 2 - 342, sh / 2 - 12, 34, @raylib.Color::new(188, 214, 240, 246))
      @raylib.draw_text("Boost breaks pursuit. Smoke blinds cops and cools heat.", sw / 2 - 386, sh / 2 + 30, 32, @raylib.Color::new(226, 232, 242, 238))
      @raylib.draw_text("Press ENTER to start", sw / 2 - 188, sh / 2 + 92, 44, @raylib.Color::new(252, 238, 174, 255))
    }

    if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 24, 20, 188))
      @raylib.draw_text("GETAWAY COMPLETE", sw / 2 - 308, sh / 2 - 80, 72, @raylib.Color::new(214, 252, 214, 255))
      @raylib.draw_text("Cash \{player.cash}   HP \{player.hp.to_int()}   Heat \{heat.to_int()}", sw / 2 - 286, sh / 2 + 8, 38, @raylib.Color::new(236, 246, 238, 248))
      @raylib.draw_text("Press ENTER for next chase", sw / 2 - 240, sh / 2 + 68, 40, @raylib.Color::new(252, 238, 176, 255))
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 8, 8, 196))
      @raylib.draw_text("BUSTED", sw / 2 - 132, sh / 2 - 80, 80, @raylib.Color::new(252, 192, 182, 255))
      @raylib.draw_text("Cash \{player.cash}/\{goal_cash}   Time \{time_left.to_int()}s", sw / 2 - 252, sh / 2 + 8, 38, @raylib.Color::new(246, 228, 220, 248))
      @raylib.draw_text("Press ENTER to retry", sw / 2 - 184, sh / 2 + 68, 40, @raylib.Color::new(252, 228, 174, 255))
    }

    draw_touch_controls(true)
  }
}
