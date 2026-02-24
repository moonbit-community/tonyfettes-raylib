///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let world_h : Float = 760.0

///|
let base_x : Float = 640.0

///|
let base_y : Float = 372.0

///|
let max_zombies : Int = 220

///|
let max_bullets : Int = 560

///|
let max_scraps : Int = 180

///|
let max_particles : Int = 900

///|
struct Survivor {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut stamina : Float
  mut ammo : Int
  mut max_ammo : Int
  mut fire_cd : Float
  mut reload_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut flash_t : Float
  mut aim_x : Float
  mut aim_y : Float
  mut harvest_t : Float
}

///|
struct Safehouse {
  mut hp : Float
  mut max_hp : Float
  mut shield : Float
  mut level : Int
  mut turret_cd : Float
  mut repair_cd : Float
}

///|
struct Zombie {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut speed : Float
  mut atk_cd : Float
  mut stun_t : Float
  mut burn_t : Float
  mut flash_t : Float
}

///|
struct Bullet {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut life : Float
}

///|
struct Scrap {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut value : Int
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
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx : Float = ax - bx
  let dy : Float = ay - by
  dx * dx + dy * dy
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
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn safe_len2(v2 : Float) -> Float {
  if v2 < Float::from_int(1) {
    Float::from_int(1)
  } else {
    v2.sqrt()
  }
}

///|
fn clear_zombies(zs : Array[Zombie]) -> Unit {
  for i = 0; i < zs.length(); i = i + 1 {
    zs[i].active = false
    zs[i].kind = 0
    zs[i].x = 0.0
    zs[i].y = 0.0
    zs[i].vx = 0.0
    zs[i].vy = 0.0
    zs[i].hp = 0.0
    zs[i].speed = 0.0
    zs[i].atk_cd = 0.0
    zs[i].stun_t = 0.0
    zs[i].burn_t = 0.0
    zs[i].flash_t = 0.0
  }
}

///|
fn clear_bullets(bs : Array[Bullet]) -> Unit {
  for i = 0; i < bs.length(); i = i + 1 {
    bs[i].active = false
    bs[i].kind = 0
    bs[i].x = 0.0
    bs[i].y = 0.0
    bs[i].vx = 0.0
    bs[i].vy = 0.0
    bs[i].dmg = 0.0
    bs[i].life = 0.0
  }
}

///|
fn clear_scraps(ss : Array[Scrap]) -> Unit {
  for i = 0; i < ss.length(); i = i + 1 {
    ss[i].active = false
    ss[i].x = 0.0
    ss[i].y = 0.0
    ss[i].value = 0
    ss[i].t = 0.0
    ss[i].life = 0.0
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
  let mut done : Bool = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }

    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      ps[i].vx = Float::from_int(@raylib.get_random_value(-280, 280)) * speed
      ps[i].vy = Float::from_int(@raylib.get_random_value(-280, 280)) * speed
      ps[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      ps[i].t = 0.0
      ps[i].life = Float::from_int(@raylib.get_random_value(18, 70)) / 100.0
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
    ignore(i)
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn spawn_bullet(
  bs : Array[Bullet],
  x : Float,
  y : Float,
  dx : Float,
  dy : Float,
  speed : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let mut done : Bool = false
  for i = 0; i < bs.length(); i = i + 1 {
    if done {
      continue
    }

    if not(bs[i].active) {
      bs[i].active = true
      bs[i].kind = kind
      bs[i].x = x
      bs[i].y = y
      bs[i].vx = dx * speed
      bs[i].vy = dy * speed
      bs[i].dmg = dmg
      bs[i].life = if kind == 2 { 0.74 } else { 0.54 }
      done = true
    }
  }
}

///|
fn spawn_zombie(zs : Array[Zombie], wave : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < zs.length(); i = i + 1 {
    if slot < 0 && not(zs[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let side = @raylib.get_random_value(0, 3)

    let mut x : Float = 0.0
    let mut y : Float = 0.0
    if side == 0 {
      x = -30.0
      y = randf(20.0, world_h - 20.0)
    } else if side == 1 {
      x = world_w + 30.0
      y = randf(20.0, world_h - 20.0)
    } else if side == 2 {
      x = randf(20.0, world_w - 20.0)
      y = -30.0
    } else {
      x = randf(20.0, world_w - 20.0)
      y = world_h + 30.0
    }

    let mut kind : Int = 0
    let roll = @raylib.get_random_value(0, 99)
    if roll > 84 {
      kind = 2
    } else if roll > 55 {
      kind = 1
    }

    let wave_scale : Float = Float::from_int(wave - 1)
    let hp_base : Float = 42.0 + wave_scale * 6.0
    let speed_base : Float = 68.0 + wave_scale * 4.0

    zs[slot].active = true
    zs[slot].kind = kind
    zs[slot].x = x
    zs[slot].y = y
    zs[slot].vx = 0.0
    zs[slot].vy = 0.0
    zs[slot].hp = if kind == 0 {
      hp_base
    } else if kind == 1 {
      hp_base * 1.45
    } else {
      hp_base * 0.78
    }
    zs[slot].speed = if kind == 0 {
      speed_base
    } else if kind == 1 {
      speed_base * 0.72
    } else {
      speed_base * 1.34
    }
    zs[slot].atk_cd = randf(0.2, 0.8)
    zs[slot].stun_t = 0.0
    zs[slot].burn_t = 0.0
    zs[slot].flash_t = 0.0
    true
  }
}

///|
fn spawn_scrap(ss : Array[Scrap], x : Float, y : Float, value : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < ss.length(); i = i + 1 {
    if slot < 0 && not(ss[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    ss[slot].active = true
    ss[slot].x = x
    ss[slot].y = y
    ss[slot].value = value
    ss[slot].t = 0.0
    ss[slot].life = randf(18.0, 30.0)
    true
  }
}

///|
fn seed_day_scraps(ss : Array[Scrap], wave : Int) -> Unit {
  clear_scraps(ss)
  let total : Int = 42 + wave * 4
  for i = 0; i < total; i = i + 1 {
    ignore(i)
    let x = randf(60.0, world_w - 60.0)
    let y = randf(94.0, world_h - 56.0)
    let d2 = dist2(x, y, base_x, base_y)
    if d2 > 140.0 * 140.0 {
      let bonus = @raylib.get_random_value(0, 100)
      let value = if bonus > 92 { 5 } else if bonus > 66 { 3 } else { 1 }
      ignore(spawn_scrap(ss, x, y, value))
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Zombie Safehouse Siege 2026")
  @raylib.set_target_fps(60)

  let zombies : Array[Zombie] = Array::makei(max_zombies, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      hp: 0.0,
      speed: 0.0,
      atk_cd: 0.0,
      stun_t: 0.0,
      burn_t: 0.0,
      flash_t: 0.0,
    }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      dmg: 0.0,
      life: 0.0,
    }
  })

  let scraps : Array[Scrap] = Array::makei(max_scraps, fn(_i) {
    { active: false, x: 0.0, y: 0.0, value: 0, t: 0.0, life: 0.0 }
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

  let player : Survivor = {
    x: 620.0,
    y: 520.0,
    vx: 0.0,
    vy: 0.0,
    hp: 230.0,
    stamina: 100.0,
    ammo: 18,
    max_ammo: 18,
    fire_cd: 0.0,
    reload_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    flash_t: 0.0,
    aim_x: 1.0,
    aim_y: 0.0,
    harvest_t: 0.0,
  }

  let home : Safehouse = {
    hp: 420.0,
    max_hp: 420.0,
    shield: 80.0,
    level: 1,
    turret_cd: 0.0,
    repair_cd: 0.0,
  }

  clear_zombies(zombies)
  clear_bullets(bullets)
  clear_particles(particles)
  clear_scraps(scraps)

  let mut state : Int = 0
  let mut phase : Int = 0 // 0 day, 1 night
  let mut wave : Int = 1

  let mut phase_t : Float = 45.0
  let mut spawn_cd : Float = 0.4
  let mut night_budget : Float = 0.0
  let mut score : Int = 0
  let mut scrap_bank : Int = 0
  let mut combo : Int = 0
  let mut day_collected : Int = 0
  let mut rescued : Int = 0

  let mut msg : String = "Collect scrap by day, survive the siege by night"
  let mut msg_t : Float = 4.0

  let mut thunder_t : Float = 0.0

  let reset_run = fn() {
    player.x = 620.0
    player.y = 520.0
    player.vx = 0.0
    player.vy = 0.0
    player.hp = 230.0
    player.stamina = 100.0
    player.ammo = player.max_ammo
    player.fire_cd = 0.0
    player.reload_cd = 0.0
    player.dash_cd = 0.0
    player.dash_t = 0.0
    player.flash_t = 0.0
    player.aim_x = 1.0
    player.aim_y = 0.0
    player.harvest_t = 0.0

    home.hp = 420.0
    home.max_hp = 420.0
    home.shield = 80.0
    home.level = 1
    home.turret_cd = 0.0
    home.repair_cd = 0.0

    phase = 0
    wave = 1
    phase_t = 45.0
    spawn_cd = 0.4
    night_budget = 0.0
    score = 0
    scrap_bank = 0
    combo = 0
    day_collected = 0
    rescued = 0

    msg = "Day 1: scavenging started"
    msg_t = 3.0

    thunder_t = 0.0

    clear_zombies(zombies)
    clear_bullets(bullets)
    clear_particles(particles)
    seed_day_scraps(scraps, wave)
  }

  let start_night = fn() {
    phase = 1
    phase_t = 58.0 + Float::from_int(wave - 1) * 3.0
    if phase_t > 84.0 {
      phase_t = 84.0
    }
    spawn_cd = 0.4
    night_budget = 34.0 + Float::from_int(wave - 1) * 16.0

    msg = "Night \{wave}: hold the line"
    msg_t = 2.8

    burst(particles, base_x, base_y, 56, 0.55, 1)
    thunder_t = 0.42
  }

  let start_day = fn() {
    phase = 0
    phase_t = 44.0
    if wave > 3 {
      phase_t = 40.0
    }
    if wave > 6 {
      phase_t = 36.0
    }

    day_collected = 0
    combo = 0
    seed_day_scraps(scraps, wave)

    msg = "Day \{wave}: scavenge, repair, upgrade"
    msg_t = 3.2

    burst(particles, base_x, base_y, 34, 0.30, 0)
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if player.flash_t > 0.0 {
      player.flash_t = player.flash_t - dt
      if player.flash_t < 0.0 {
        player.flash_t = 0.0
      }
    }
    if thunder_t > 0.0 {
      thunder_t = thunder_t - dt
      if thunder_t < 0.0 {
        thunder_t = 0.0
      }
    }

    let mouse = @raylib.get_mouse_position()
    let touching = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let pressed = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyRight)
    let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
      @raylib.is_key_down(@raylib.KeyUp)
    let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
      @raylib.is_key_down(@raylib.KeyDown)

    let mut fire_down : Bool = @raylib.is_key_down(@raylib.KeyJ)
    let mut fire_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)
    let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
    let mut action_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
      @raylib.is_key_pressed(@raylib.KeyR)

    let pad_x : Int = 26
    let pad_y : Int = sh - 194
    let btn_x : Int = sw - 238
    let btn_y : Int = sh - 224

    if touching {
      if inside_rect(mouse.x, mouse.y, pad_x + 78, pad_y, 72, 56) {
        move_u = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 78, pad_y + 112, 72, 56) {
        move_d = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 56, 72, 56) {
        move_l = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 156, pad_y + 56, 72, 56) {
        move_r = true
      }

      if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 10, 102, 78) {
        fire_down = true
      }
    }

    if pressed {
      if inside_rect(mouse.x, mouse.y, btn_x + 112, btn_y + 10, 102, 78) {
        dash_press = true
      }
      if inside_rect(mouse.x, mouse.y, btn_x + 56, btn_y + 98, 148, 104) {
        action_press = true
      }
      if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 10, 102, 78) {
        fire_press = true
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        state = 0
      }

      phase_t = phase_t - dt

      player.fire_cd = player.fire_cd - dt
      if player.fire_cd < 0.0 {
        player.fire_cd = 0.0
      }
      player.reload_cd = player.reload_cd - dt
      if player.reload_cd < 0.0 {
        player.reload_cd = 0.0
      }
      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }
      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }
      player.harvest_t = player.harvest_t - dt
      if player.harvest_t < 0.0 {
        player.harvest_t = 0.0
      }

      home.turret_cd = home.turret_cd - dt
      if home.turret_cd < 0.0 {
        home.turret_cd = 0.0
      }
      home.repair_cd = home.repair_cd - dt
      if home.repair_cd < 0.0 {
        home.repair_cd = 0.0
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0
      if move_l {
        ax = ax - 640.0
      }
      if move_r {
        ax = ax + 640.0
      }
      if move_u {
        ay = ay - 640.0
      }
      if move_d {
        ay = ay + 640.0
      }

      if player.dash_t > 0.0 {
        ax = ax * 1.5
        ay = ay * 1.5
      }

      player.vx = player.vx + ax * dt
      player.vy = player.vy + ay * dt

      player.vx = player.vx * (Float::from_int(1) - dt * 2.8)
      player.vy = player.vy * (Float::from_int(1) - dt * 2.8)

      let max_speed : Float = if player.dash_t > 0.0 { 420.0 } else { 265.0 }
      player.vx = clampf(player.vx, -max_speed, max_speed)
      player.vy = clampf(player.vy, -max_speed, max_speed)

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      player.x = clampf(player.x, 26.0, world_w - 26.0)
      player.y = clampf(player.y, 76.0, world_h - 26.0)

      if ax != 0.0 || ay != 0.0 {
        let n2 = ax * ax + ay * ay
        let n = safe_len2(n2)
        player.aim_x = ax / n
        player.aim_y = ay / n
      }

      player.stamina = player.stamina + 24.0 * dt
      if player.stamina > 100.0 {
        player.stamina = 100.0
      }

      if dash_press && player.dash_cd <= 0.0 && player.stamina >= 28.0 {
        player.dash_t = 0.22
        player.dash_cd = 1.4
        player.stamina = player.stamina - 28.0
        burst(particles, player.x, player.y, 16, 0.42, 0)
      }

      if (fire_down || fire_press) && player.reload_cd <= 0.0 {
        if player.ammo <= 0 {
          player.reload_cd = 0.9
          player.ammo = player.max_ammo
          msg = "Reload"
          msg_t = 0.8
        } else if player.fire_cd <= 0.0 {
          player.fire_cd = 0.09
          player.ammo = player.ammo - 1

          let mx = mouse.x - player.x
          let my = mouse.y - player.y
          let mut dx = player.aim_x
          let mut dy = player.aim_y
          if absf(mx) > 2.0 || absf(my) > 2.0 {
            let n2 = mx * mx + my * my
            let n = safe_len2(n2)
            dx = mx / n
            dy = my / n
            player.aim_x = dx
            player.aim_y = dy
          }

          spawn_bullet(
            bullets,
            player.x + dx * 20.0,
            player.y + dy * 20.0,
            dx,
            dy,
            690.0,
            28.0 + Float::from_int(home.level - 1) * 3.0,
            0,
          )
          burst(
            particles,
            player.x + dx * 16.0,
            player.y + dy * 16.0,
            4,
            0.20,
            2,
          )
        }
      }

      let near_base : Bool = dist2(player.x, player.y, base_x, base_y) <=
        134.0 * 134.0

      if action_press && near_base {
        if phase == 0 {
          if scrap_bank >= 8 && home.hp < home.max_hp && home.repair_cd <= 0.0 {
            scrap_bank = scrap_bank - 8
            home.hp = home.hp + 70.0
            if home.hp > home.max_hp {
              home.hp = home.max_hp
            }
            home.repair_cd = 0.36
            msg = "Safehouse repaired"
            msg_t = 1.0
            burst(particles, base_x, base_y, 18, 0.22, 1)
          } else if scrap_bank >= 14 && home.level < 5 {
            scrap_bank = scrap_bank - 14
            home.level = home.level + 1
            home.max_hp = home.max_hp + 52.0
            home.hp = home.hp + 62.0
            if home.hp > home.max_hp {
              home.hp = home.max_hp
            }
            player.max_ammo = player.max_ammo + 3
            player.ammo = player.max_ammo
            msg = "Upgraded to tier \{home.level}"
            msg_t = 1.4
            burst(particles, base_x, base_y, 26, 0.28, 0)
          } else if scrap_bank >= 4 && player.hp < 230.0 {
            scrap_bank = scrap_bank - 4
            player.hp = player.hp + 36.0
            if player.hp > 230.0 {
              player.hp = 230.0
            }
            msg = "Patched wounds"
            msg_t = 0.9
            burst(particles, player.x, player.y, 12, 0.24, 1)
          }
        } else if scrap_bank >= 10 && home.shield < 120.0 {
          scrap_bank = scrap_bank - 10
          home.shield = home.shield + 34.0
          if home.shield > 120.0 {
            home.shield = 120.0
          }
          msg = "Shield reinforced"
          msg_t = 1.0
          burst(particles, base_x, base_y, 16, 0.22, 0)
        }
      }

      if phase == 0 {
        for i = 0; i < scraps.length(); i = i + 1 {
          if not(scraps[i].active) {
            continue
          }

          scraps[i].t = scraps[i].t + dt
          scraps[i].life = scraps[i].life - dt
          if scraps[i].life <= 0.0 {
            scraps[i].active = false
            continue
          }

          if dist2(player.x, player.y, scraps[i].x, scraps[i].y) <= 26.0 * 26.0 {
            if player.harvest_t <= 0.0 {
              player.harvest_t = 0.06
              scrap_bank = scrap_bank + scraps[i].value
              day_collected = day_collected + scraps[i].value
              score = score + scraps[i].value * 14
              scraps[i].active = false
              burst(particles, player.x, player.y, 6, 0.20, 0)
            }
          }
        }

        if phase_t <= 0.0 {
          clear_scraps(scraps)
          clear_zombies(zombies)
          clear_bullets(bullets)
          start_night()
        }
      } else {
        spawn_cd = spawn_cd - dt
        if spawn_cd <= 0.0 && night_budget > 0.0 {
          let mut n : Int = 1
          if wave > 4 {
            n = 2
          }
          if wave > 8 {
            n = 3
          }
          for i = 0; i < n; i = i + 1 {
            ignore(i)
            if night_budget > 0.0 {
              if spawn_zombie(zombies, wave) {
                night_budget = night_budget - 1.0
              }
            }
          }

          let jitter = Float::from_int(@raylib.get_random_value(62, 120)) /
            100.0
          spawn_cd = (0.44 - Float::from_int(wave - 1) * 0.02) * jitter
          if spawn_cd < 0.12 {
            spawn_cd = 0.12
          }
        }
      }

      for i = 0; i < zombies.length(); i = i + 1 {
        if not(zombies[i].active) {
          continue
        }

        zombies[i].atk_cd = zombies[i].atk_cd - dt
        if zombies[i].atk_cd < 0.0 {
          zombies[i].atk_cd = 0.0
        }
        zombies[i].stun_t = zombies[i].stun_t - dt
        if zombies[i].stun_t < 0.0 {
          zombies[i].stun_t = 0.0
        }
        zombies[i].burn_t = zombies[i].burn_t - dt
        if zombies[i].burn_t < 0.0 {
          zombies[i].burn_t = 0.0
        }
        zombies[i].flash_t = zombies[i].flash_t - dt
        if zombies[i].flash_t < 0.0 {
          zombies[i].flash_t = 0.0
        }

        if zombies[i].burn_t > 0.0 {
          zombies[i].hp = zombies[i].hp - dt * 7.2
        }

        if zombies[i].hp <= 0.0 {
          let drop_roll = @raylib.get_random_value(0, 99)
          let drop_val = if drop_roll > 88 {
            5
          } else if drop_roll > 54 {
            3
          } else {
            1
          }
          ignore(spawn_scrap(scraps, zombies[i].x, zombies[i].y, drop_val))
          score = score + 35 + combo
          combo = combo + 1
          rescued = rescued + 1
          burst(particles, zombies[i].x, zombies[i].y, 14, 0.28, 2)
          zombies[i].active = false
          continue
        }

        if zombies[i].stun_t > 0.0 {
          zombies[i].vx = zombies[i].vx * (Float::from_int(1) - dt * 8.0)
          zombies[i].vy = zombies[i].vy * (Float::from_int(1) - dt * 8.0)
        } else {
          let mut tx : Float = base_x
          let mut ty : Float = base_y

          let d_player = dist2(zombies[i].x, zombies[i].y, player.x, player.y)
          let d_base = dist2(zombies[i].x, zombies[i].y, base_x, base_y)

          if d_player < d_base * 0.72 {
            tx = player.x
            ty = player.y
          }

          let dx = tx - zombies[i].x
          let dy = ty - zombies[i].y
          let n2 = dx * dx + dy * dy
          let n = safe_len2(n2)
          let chase = zombies[i].speed *
            (if zombies[i].kind == 2 { 1.14 } else { 1.0 })

          zombies[i].vx = zombies[i].vx * (Float::from_int(1) - dt * 2.6) +
            dx / n * chase * dt * 2.6
          zombies[i].vy = zombies[i].vy * (Float::from_int(1) - dt * 2.6) +
            dy / n * chase * dt * 2.6
        }

        zombies[i].x = zombies[i].x + zombies[i].vx * dt
        zombies[i].y = zombies[i].y + zombies[i].vy * dt

        if zombies[i].x < -46.0 {
          zombies[i].x = -46.0
        }
        if zombies[i].x > world_w + 46.0 {
          zombies[i].x = world_w + 46.0
        }
        if zombies[i].y < -46.0 {
          zombies[i].y = -46.0
        }
        if zombies[i].y > world_h + 46.0 {
          zombies[i].y = world_h + 46.0
        }

        let zrad : Float = if zombies[i].kind == 1 {
          22.0
        } else if zombies[i].kind == 2 {
          14.0
        } else {
          18.0
        }

        if dist2(zombies[i].x, zombies[i].y, player.x, player.y) <=
          (zrad + 14.0) * (zrad + 14.0) {
          if zombies[i].atk_cd <= 0.0 {
            zombies[i].atk_cd = if zombies[i].kind == 2 { 0.45 } else { 0.72 }
            let bite_dmg : Float = if zombies[i].kind == 1 {
              18.0
            } else if zombies[i].kind == 2 {
              10.0
            } else {
              13.0
            }
            player.hp = player.hp - bite_dmg
            player.flash_t = 0.18
            burst(particles, player.x, player.y, 8, 0.24, 3)
            combo = 0
          }
        }

        if dist2(zombies[i].x, zombies[i].y, base_x, base_y) <=
          (zrad + 82.0) * (zrad + 82.0) {
          if zombies[i].atk_cd <= 0.0 {
            zombies[i].atk_cd = if zombies[i].kind == 2 { 0.56 } else { 0.78 }
            let dmg : Float = if zombies[i].kind == 1 {
              21.0
            } else if zombies[i].kind == 2 {
              10.0
            } else {
              14.0
            }
            if home.shield > 0.0 {
              home.shield = home.shield - dmg
              if home.shield < 0.0 {
                home.hp = home.hp + home.shield
                home.shield = 0.0
              }
            } else {
              home.hp = home.hp - dmg
            }
            burst(
              particles,
              base_x + randf(-22.0, 22.0),
              base_y + randf(-22.0, 22.0),
              9,
              0.22,
              3,
            )
            combo = 0
          }
        }
      }

      for i = 0; i < bullets.length(); i = i + 1 {
        if not(bullets[i].active) {
          continue
        }

        bullets[i].life = bullets[i].life - dt
        if bullets[i].life <= 0.0 {
          bullets[i].active = false
          continue
        }

        bullets[i].x = bullets[i].x + bullets[i].vx * dt
        bullets[i].y = bullets[i].y + bullets[i].vy * dt

        if bullets[i].x < -40.0 ||
          bullets[i].x > world_w + 40.0 ||
          bullets[i].y < -40.0 ||
          bullets[i].y > world_h + 40.0 {
          bullets[i].active = false
          continue
        }

        for j = 0; j < zombies.length(); j = j + 1 {
          if not(zombies[j].active) {
            continue
          }

          let zrad : Float = if zombies[j].kind == 1 {
            22.0
          } else if zombies[j].kind == 2 {
            14.0
          } else {
            18.0
          }
          if dist2(bullets[i].x, bullets[i].y, zombies[j].x, zombies[j].y) <=
            zrad * zrad {
            zombies[j].hp = zombies[j].hp - bullets[i].dmg
            zombies[j].flash_t = 0.14

            if bullets[i].kind == 2 {
              zombies[j].burn_t = 1.8
            }

            let dx = zombies[j].x - player.x
            let dy = zombies[j].y - player.y
            let n2 = dx * dx + dy * dy
            let n = safe_len2(n2)
            zombies[j].vx = zombies[j].vx + dx / n * 112.0
            zombies[j].vy = zombies[j].vy + dy / n * 112.0
            zombies[j].stun_t = 0.12

            burst(particles, bullets[i].x, bullets[i].y, 6, 0.18, 2)
            bullets[i].active = false
            break
          }
        }
      }

      if phase == 1 && home.level >= 2 && home.turret_cd <= 0.0 {
        let mut target : Int = -1
        let mut best_d2 : Float = 99999999.0

        for i = 0; i < zombies.length(); i = i + 1 {
          if not(zombies[i].active) {
            continue
          }

          let d2 = dist2(zombies[i].x, zombies[i].y, base_x, base_y)
          if d2 < best_d2 &&
            d2 <=
            (320.0 + Float::from_int(home.level) * 24.0) *
            (320.0 + Float::from_int(home.level) * 24.0) {
            best_d2 = d2
            target = i
          }
        }

        if target >= 0 {
          let dx = zombies[target].x - base_x
          let dy = zombies[target].y - base_y
          let n2 = dx * dx + dy * dy
          let n = safe_len2(n2)
          spawn_bullet(
            bullets,
            base_x + dx / n * 58.0,
            base_y + dy / n * 58.0,
            dx / n,
            dy / n,
            520.0,
            18.0 + Float::from_int(home.level) * 4.0,
            2,
          )
          home.turret_cd = 0.52 - Float::from_int(home.level - 1) * 0.04
          if home.turret_cd < 0.22 {
            home.turret_cd = 0.22
          }
          burst(
            particles,
            base_x + dx / n * 60.0,
            base_y + dy / n * 60.0,
            5,
            0.18,
            1,
          )
        }
      }

      for i = 0; i < scraps.length(); i = i + 1 {
        if not(scraps[i].active) {
          continue
        }
        scraps[i].t = scraps[i].t + dt
        scraps[i].life = scraps[i].life - dt
        if scraps[i].life <= 0.0 {
          scraps[i].active = false
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
          particles[i].vx = particles[i].vx * (Float::from_int(1) - dt * 2.0)
          particles[i].vy = particles[i].vy + 320.0 * dt
        }
      }

      let mut alive_zombies : Int = 0
      for i = 0; i < zombies.length(); i = i + 1 {
        if zombies[i].active {
          alive_zombies = alive_zombies + 1
        }
      }

      if phase == 1 &&
        phase_t <= 0.0 &&
        alive_zombies == 0 &&
        night_budget <= 0.0 {
        wave = wave + 1
        score = score + 280 + day_collected * 4

        if wave > 12 {
          msg = "You saved the district"
          msg_t = 4.0
          state = 2
        } else {
          start_day()
        }
      }

      if player.hp <= 0.0 || home.hp <= 0.0 {
        state = 3
        msg = if player.hp <= 0.0 {
          "You were overwhelmed"
        } else {
          "Safehouse destroyed"
        }
        msg_t = 4.0
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }

    @raylib.begin_drawing()

    let sky_phase = if phase == 0 { 1.0 } else { 0.0 }
    let mut bg_r : Int = (22.0 + sky_phase * 24.0).to_int()
    let mut bg_g : Int = (26.0 + sky_phase * 30.0).to_int()
    let mut bg_b : Int = (34.0 + sky_phase * 42.0).to_int()

    if thunder_t > 0.0 {
      bg_r = bg_r + 80
      bg_g = bg_g + 80
      bg_b = bg_b + 90
    }
    if bg_r > 255 {
      bg_r = 255
    }
    if bg_g > 255 {
      bg_g = 255
    }
    if bg_b > 255 {
      bg_b = 255
    }

    @raylib.clear_background(@raylib.Color::new(bg_r, bg_g, bg_b, 255))

    for i = 0; i < 22; i = i + 1 {
      let y = i * 36
      let c = 16 + i * 2 + (if phase == 0 { 12 } else { 0 })
      @raylib.draw_rectangle(
        0,
        y,
        sw,
        2,
        @raylib.Color::new(c, c + 8, c + 14, 118),
      )
    }

    for i = 0; i < 28; i = i + 1 {
      let x = i * 46
      let c = 12 + i * 3 % 28
      @raylib.draw_rectangle(
        x,
        72,
        2,
        sh - 72,
        @raylib.Color::new(c, c + 10, c + 16, 84),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 70, @raylib.Color::new(8, 10, 16, 226))

    @raylib.draw_circle(
      base_x.to_int(),
      base_y.to_int(),
      92.0,
      @raylib.Color::new(54, 68, 90, 255),
    )
    @raylib.draw_circle(
      base_x.to_int(),
      base_y.to_int(),
      74.0,
      @raylib.Color::new(26, 36, 52, 255),
    )

    let shield_alpha : Int = (home.shield / 120.0 * 190.0).to_int()
    @raylib.draw_circle_lines(
      base_x.to_int(),
      base_y.to_int(),
      97.0,
      @raylib.Color::new(102, 204, 248, shield_alpha),
    )
    @raylib.draw_circle_lines(
      base_x.to_int(),
      base_y.to_int(),
      102.0,
      @raylib.Color::new(142, 224, 255, shield_alpha / 2),
    )

    @raylib.draw_rectangle(
      (base_x - 72.0).to_int(),
      (base_y - 12.0).to_int(),
      144,
      24,
      @raylib.Color::new(82, 102, 128, 255),
    )
    @raylib.draw_rectangle(
      (base_x - 56.0).to_int(),
      (base_y - 46.0).to_int(),
      112,
      28,
      @raylib.Color::new(138, 162, 188, 255),
    )

    if home.level >= 2 {
      @raylib.draw_circle(
        (base_x + 0.0).to_int(),
        (base_y - 62.0).to_int(),
        12.0,
        @raylib.Color::new(234, 190, 112, 255),
      )
    }

    for i = 0; i < scraps.length(); i = i + 1 {
      if not(scraps[i].active) {
        continue
      }

      let bob_phase : Int = (scraps[i].t * 8.0).to_int() % 4
      let bob : Float = if bob_phase < 2 { 2.0 } else { -2.0 }
      let mut col = @raylib.Color::new(218, 198, 112, 255)
      if scraps[i].value >= 3 {
        col = @raylib.Color::new(108, 222, 198, 255)
      }
      if scraps[i].value >= 5 {
        col = @raylib.Color::new(236, 140, 244, 255)
      }
      @raylib.draw_rectangle(
        (scraps[i].x - 8.0).to_int(),
        (scraps[i].y - 8.0 + bob).to_int(),
        16,
        16,
        col,
      )
      @raylib.draw_rectangle(
        (scraps[i].x - 4.0).to_int(),
        (scraps[i].y - 4.0 + bob).to_int(),
        8,
        8,
        @raylib.Color::new(24, 32, 44, 220),
      )
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }

      let col = if bullets[i].kind == 2 {
        @raylib.Color::new(252, 160, 92, 255)
      } else {
        @raylib.Color::new(156, 228, 252, 255)
      }
      let brad : Float = if bullets[i].kind == 2 { 5.0 } else { 4.0 }
      @raylib.draw_circle(
        bullets[i].x.to_int(),
        bullets[i].y.to_int(),
        brad,
        col,
      )
    }

    for i = 0; i < zombies.length(); i = i + 1 {
      if not(zombies[i].active) {
        continue
      }

      let rad : Float = if zombies[i].kind == 1 {
        22.0
      } else if zombies[i].kind == 2 {
        14.0
      } else {
        18.0
      }
      let mut col = @raylib.Color::new(98, 182, 104, 255)
      if zombies[i].kind == 1 {
        col = @raylib.Color::new(124, 98, 78, 255)
      } else if zombies[i].kind == 2 {
        col = @raylib.Color::new(172, 220, 106, 255)
      }

      if zombies[i].burn_t > 0.0 {
        col = @raylib.Color::new(238, 124, 72, 255)
      }
      if zombies[i].flash_t > 0.0 {
        col = @raylib.Color::new(255, 235, 210, 255)
      }

      @raylib.draw_circle(
        zombies[i].x.to_int(),
        zombies[i].y.to_int(),
        rad,
        col,
      )
      @raylib.draw_circle(
        (zombies[i].x - rad * 0.34).to_int(),
        (zombies[i].y - rad * 0.2).to_int(),
        3.0,
        @raylib.Color::new(20, 28, 22, 255),
      )
      @raylib.draw_circle(
        (zombies[i].x + rad * 0.34).to_int(),
        (zombies[i].y - rad * 0.2).to_int(),
        3.0,
        @raylib.Color::new(20, 28, 22, 255),
      )

      let hp_ratio = zombies[i].hp /
        (if zombies[i].kind == 1 {
          70.0 + Float::from_int(wave) * 8.0
        } else if zombies[i].kind == 2 {
          36.0 + Float::from_int(wave) * 4.0
        } else {
          44.0 + Float::from_int(wave) * 6.0
        })
      let hpw = (clampf(hp_ratio, 0.0, 1.0) * rad * 2.0).to_int()
      @raylib.draw_rectangle(
        (zombies[i].x - rad).to_int(),
        (zombies[i].y - rad - 12.0).to_int(),
        (rad * 2.0).to_int(),
        4,
        @raylib.Color::new(20, 24, 20, 180),
      )
      @raylib.draw_rectangle(
        (zombies[i].x - rad).to_int(),
        (zombies[i].y - rad - 12.0).to_int(),
        hpw,
        4,
        @raylib.Color::new(234, 86, 94, 214),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let k = particles[i].t / particles[i].life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(126, 228, 248, a)
      if particles[i].kind == 1 {
        c = @raylib.Color::new(152, 244, 188, a)
      } else if particles[i].kind == 2 {
        c = @raylib.Color::new(252, 166, 98, a)
      } else if particles[i].kind == 3 {
        c = @raylib.Color::new(234, 88, 102, a)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        c,
      )
    }

    let mut player_col = @raylib.Color::new(142, 212, 255, 255)
    if player.flash_t > 0.0 {
      player_col = @raylib.Color::new(255, 228, 204, 255)
    }

    @raylib.draw_circle(player.x.to_int(), player.y.to_int(), 15.0, player_col)
    @raylib.draw_circle(
      (player.x + player.aim_x * 14.0).to_int(),
      (player.y + player.aim_y * 14.0).to_int(),
      5.0,
      @raylib.Color::new(36, 52, 78, 255),
    )

    if player.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        player.x.to_int(),
        player.y.to_int(),
        24.0,
        @raylib.Color::new(164, 236, 255, 220),
      )
    }

    @raylib.draw_text(
      "ZOMBIE SAFEHOUSE SIEGE 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 242, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  J fire  K dash  L/R action",
      22,
      48,
      18,
      @raylib.Color::new(178, 204, 236, 255),
    )

    @raylib.draw_text(
      "WAVE \{wave}",
      588,
      16,
      26,
      @raylib.Color::new(255, 224, 140, 255),
    )
    let phase_label : String = if phase == 0 { "DAY" } else { "NIGHT" }
    let phase_col = if phase == 0 {
      @raylib.Color::new(126, 222, 174, 255)
    } else {
      @raylib.Color::new(240, 144, 156, 255)
    }
    @raylib.draw_text(phase_label, 696, 16, 26, phase_col)
    @raylib.draw_text(
      "TIME \{phase_t.to_int()}s",
      786,
      16,
      26,
      @raylib.Color::new(216, 224, 236, 255),
    )

    @raylib.draw_text(
      "SCRAP \{scrap_bank}",
      972,
      14,
      28,
      @raylib.Color::new(246, 214, 118, 255),
    )
    @raylib.draw_text(
      "SCORE \{score}",
      972,
      44,
      24,
      @raylib.Color::new(182, 238, 206, 255),
    )

    @raylib.draw_rectangle(20, 80, 206, 12, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      80,
      (player.hp / 230.0 * 206.0).to_int(),
      12,
      @raylib.Color::new(104, 222, 154, 255),
    )
    @raylib.draw_text(
      "PLAYER",
      20,
      94,
      16,
      @raylib.Color::new(186, 208, 230, 255),
    )

    @raylib.draw_rectangle(
      242,
      80,
      248,
      12,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      242,
      80,
      (home.hp / home.max_hp * 248.0).to_int(),
      12,
      @raylib.Color::new(104, 186, 240, 255),
    )
    @raylib.draw_text(
      "SAFEHOUSE T\{home.level}",
      242,
      94,
      16,
      @raylib.Color::new(186, 208, 230, 255),
    )

    @raylib.draw_rectangle(
      506,
      80,
      190,
      12,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      506,
      80,
      (home.shield / 120.0 * 190.0).to_int(),
      12,
      @raylib.Color::new(118, 224, 252, 255),
    )
    @raylib.draw_text(
      "SHIELD",
      506,
      94,
      16,
      @raylib.Color::new(186, 208, 230, 255),
    )

    @raylib.draw_rectangle(
      712,
      80,
      190,
      12,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      712,
      80,
      (player.stamina / 100.0 * 190.0).to_int(),
      12,
      @raylib.Color::new(248, 190, 104, 255),
    )
    @raylib.draw_text(
      "STAMINA",
      712,
      94,
      16,
      @raylib.Color::new(186, 208, 230, 255),
    )

    @raylib.draw_text(
      "AMMO \{player.ammo}/\{player.max_ammo}",
      922,
      82,
      22,
      @raylib.Color::new(246, 232, 176, 255),
    )
    @raylib.draw_text(
      "Kills \{rescued}",
      1140,
      82,
      22,
      @raylib.Color::new(182, 228, 182, 255),
    )

    @raylib.draw_rectangle(
      14,
      sh - 216,
      236,
      206,
      @raylib.Color::new(8, 12, 20, 212),
    )
    @raylib.draw_rectangle(
      pad_x + 78,
      pad_y,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "U",
      pad_x + 104,
      pad_y + 16,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      pad_x,
      pad_y + 56,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "L",
      pad_x + 28,
      pad_y + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      pad_x + 156,
      pad_y + 56,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "R",
      pad_x + 184,
      pad_y + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      pad_x + 78,
      pad_y + 112,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "D",
      pad_x + 104,
      pad_y + 128,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )

    @raylib.draw_rectangle(
      btn_x - 10,
      sh - 238,
      228,
      220,
      @raylib.Color::new(8, 12, 20, 212),
    )
    @raylib.draw_rectangle(
      btn_x,
      btn_y + 10,
      102,
      78,
      @raylib.Color::new(208, 92, 86, 255),
    )
    @raylib.draw_text(
      "FIRE",
      btn_x + 22,
      btn_y + 36,
      26,
      @raylib.Color::new(248, 236, 228, 255),
    )
    @raylib.draw_rectangle(
      btn_x + 112,
      btn_y + 10,
      102,
      78,
      @raylib.Color::new(96, 156, 222, 255),
    )
    @raylib.draw_text(
      "DASH",
      btn_x + 128,
      btn_y + 36,
      26,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      btn_x + 56,
      btn_y + 98,
      148,
      104,
      @raylib.Color::new(112, 174, 122, 255),
    )
    @raylib.draw_text(
      "ACTION",
      btn_x + 82,
      btn_y + 138,
      28,
      @raylib.Color::new(236, 246, 240, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 324,
      sh - 54,
      648,
      40,
      @raylib.Color::new(8, 10, 16, 216),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 304,
      sh - 44,
      24,
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 166 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 138))
      @raylib.draw_rectangle(
        sw / 2 - 440,
        sh / 2 - 210,
        880,
        420,
        @raylib.Color::new(14, 20, 32, 242),
      )
      @raylib.draw_text(
        "ZOMBIE SAFEHOUSE SIEGE",
        sw / 2 - 292,
        sh / 2 - 150,
        58,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Day: collect scrap and upgrade the base",
        sw / 2 - 238,
        sh / 2 - 56,
        30,
        @raylib.Color::new(174, 214, 246, 255),
      )
      @raylib.draw_text(
        "Night: survive waves, defend safehouse, use turret",
        sw / 2 - 268,
        sh / 2 - 14,
        30,
        @raylib.Color::new(174, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad move, right buttons fire/dash/action",
        sw / 2 - 318,
        sh / 2 + 28,
        28,
        @raylib.Color::new(174, 214, 246, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 166,
        sh / 2 + 116,
        40,
        @raylib.Color::new(255, 208, 122, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 152))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "DISTRICT SAVED",
        sw / 2 - 194,
        sh / 2 - 130,
        58,
        @raylib.Color::new(246, 238, 188, 255),
      )
      @raylib.draw_text(
        "Final score: \{score}",
        sw / 2 - 168,
        sh / 2 - 42,
        42,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Scrap collected: \{day_collected}",
        sw / 2 - 196,
        sh / 2 + 8,
        34,
        @raylib.Color::new(172, 222, 192, 255),
      )
      @raylib.draw_text(
        "Kills: \{rescued}",
        sw / 2 - 112,
        sh / 2 + 52,
        34,
        @raylib.Color::new(182, 228, 236, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 176,
        sh / 2 + 118,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 164))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "SIEGE FAILED",
        sw / 2 - 194,
        sh / 2 - 130,
        58,
        @raylib.Color::new(246, 132, 142, 255),
      )
      @raylib.draw_text(
        msg,
        sw / 2 - 198,
        sh / 2 - 40,
        40,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Score: \{score}   Wave: \{wave}",
        sw / 2 - 180,
        sh / 2 + 14,
        34,
        @raylib.Color::new(182, 228, 236, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 176,
        sh / 2 + 118,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }
  }

  @raylib.close_window()
}
