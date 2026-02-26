///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let map_w : Int = 20

///|
let map_h : Int = 12

///|
let tile : Int = 52

///|
let map_x : Int = 120

///|
let map_y : Int = 72

///|
let max_crates : Int = 20

///|
let max_plates : Int = 10

///|
let max_relics : Int = 18

///|
let max_enemies : Int = 42

///|
let max_spikes : Int = 30

///|
let max_particles : Int = 900

///|
struct Player {
  mut gx : Int
  mut gy : Int
  mut hp : Float
  mut stamina : Float
  mut slash_cd : Float
  mut dash_cd : Float
  mut bomb_cd : Float
  mut hurt_t : Float
  mut face_x : Int
  mut face_y : Int
  mut score : Int
  mut combo : Int
}

///|
struct Crate {
  mut active : Bool
  mut gx : Int
  mut gy : Int
}

///|
struct Plate {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut pressed : Bool
}

///|
struct Relic {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut taken : Bool
}

///|
struct Enemy {
  mut active : Bool
  mut kind : Int
  mut gx : Int
  mut gy : Int
  mut hp : Float
  mut move_cd : Float
  mut atk_cd : Float
  mut stun_t : Float
  mut hurt_cd : Float
}

///|
struct Spike {
  mut active : Bool
  mut gx : Int
  mut gy : Int
  mut t : Float
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
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absi(v : Int) -> Int {
  if v < 0 {
    -v
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
fn idx(gx : Int, gy : Int) -> Int {
  gy * map_w + gx
}

///|
fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < map_w && gy < map_h
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
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn cell_center_x(gx : Int) -> Float {
  Float::from_int(map_x + gx * tile + tile / 2)
}

///|
fn cell_center_y(gy : Int) -> Float {
  Float::from_int(map_y + gy * tile + tile / 2)
}

///|
fn clear_crates(crates : Array[Crate]) -> Unit {
  for i = 0; i < crates.length(); i = i + 1 {
    crates[i].active = false
    crates[i].gx = 0
    crates[i].gy = 0
  }
}

///|
fn clear_plates(plates : Array[Plate]) -> Unit {
  for i = 0; i < plates.length(); i = i + 1 {
    plates[i].active = false
    plates[i].gx = 0
    plates[i].gy = 0
    plates[i].pressed = false
  }
}

///|
fn clear_relics(relics : Array[Relic]) -> Unit {
  for i = 0; i < relics.length(); i = i + 1 {
    relics[i].active = false
    relics[i].gx = 0
    relics[i].gy = 0
    relics[i].taken = false
  }
}

///|
fn clear_enemies(enemies : Array[Enemy]) -> Unit {
  for i = 0; i < enemies.length(); i = i + 1 {
    enemies[i].active = false
    enemies[i].kind = 0
    enemies[i].gx = 0
    enemies[i].gy = 0
    enemies[i].hp = 0.0
    enemies[i].move_cd = 0.0
    enemies[i].atk_cd = 0.0
    enemies[i].stun_t = 0.0
    enemies[i].hurt_cd = 0.0
  }
}

///|
fn clear_spikes(spikes : Array[Spike]) -> Unit {
  for i = 0; i < spikes.length(); i = i + 1 {
    spikes[i].active = false
    spikes[i].gx = 0
    spikes[i].gy = 0
    spikes[i].t = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].t = 0.0
    parts[i].life = 0.0
    parts[i].kind = 0
  }
}

///|
fn crate_at(crates : Array[Crate], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < crates.length(); i = i + 1 {
    if crates[i].active && crates[i].gx == gx && crates[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn enemy_at(enemies : Array[Enemy], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < enemies.length(); i = i + 1 {
    if enemies[i].active && enemies[i].gx == gx && enemies[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn relic_at(relics : Array[Relic], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < relics.length(); i = i + 1 {
    if relics[i].active &&
      not(relics[i].taken) &&
      relics[i].gx == gx &&
      relics[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn spike_at(spikes : Array[Spike], gx : Int, gy : Int) -> Int {
  let mut found : Int = -1
  for i = 0; i < spikes.length(); i = i + 1 {
    if spikes[i].active && spikes[i].gx == gx && spikes[i].gy == gy {
      found = i
      break
    }
  }
  found
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut left = n
  for i = 0; i < parts.length(); i = i + 1 {
    if left <= 0 {
      break
    }
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(14, 72)) / 100.0
      parts[i].kind = kind
      left = left - 1
    }
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Temple Relic Run 2026")
  @raylib.set_target_fps(60)

  let tiles : Array[Int] = Array::makei(map_w * map_h, fn(_i) { 0 })

  let crates : Array[Crate] = Array::makei(max_crates, fn(_i) {
    { active: false, gx: 0, gy: 0 }
  })

  let plates : Array[Plate] = Array::makei(max_plates, fn(_i) {
    { active: false, gx: 0, gy: 0, pressed: false }
  })

  let relics : Array[Relic] = Array::makei(max_relics, fn(_i) {
    { active: false, gx: 0, gy: 0, taken: false }
  })

  let enemies : Array[Enemy] = Array::makei(max_enemies, fn(_i) {
    {
      active: false,
      kind: 0,
      gx: 0,
      gy: 0,
      hp: 0.0,
      move_cd: 0.0,
      atk_cd: 0.0,
      stun_t: 0.0,
      hurt_cd: 0.0,
    }
  })

  let spikes : Array[Spike] = Array::makei(max_spikes, fn(_i) {
    { active: false, gx: 0, gy: 0, t: 0.0 }
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

  let player : Player = {
    gx: 1,
    gy: map_h - 2,
    hp: 100.0,
    stamina: 100.0,
    slash_cd: 0.0,
    dash_cd: 0.0,
    bomb_cd: 0.0,
    hurt_t: 0.0,
    face_x: 1,
    face_y: 0,
    score: 0,
    combo: 0,
  }

  let mut state : Int = 0
  let mut stage : Int = 1
  let max_stage : Int = 5
  let mut total_time : Float = 420.0
  let mut stage_time : Float = 96.0

  let mut relic_left : Int = 0
  let mut plate_goal : Int = 0
  let mut plates_pressed : Int = 0
  let mut exit_x : Int = map_w - 2
  let mut exit_y : Int = 1
  let mut exit_open : Bool = false
  let mut losses : Int = 0

  let mut msg : String = "Find relics, solve plates, reach the gate"
  let mut msg_t : Float = 3.0
  let mut move_repeat_t : Float = 0.0

  let can_walk = fn(gx : Int, gy : Int) -> Bool {
    if not(in_bounds(gx, gy)) {
      false
    } else if tiles[idx(gx, gy)] == 1 {
      false
    } else {
      true
    }
  }

  let cell_free_for_spawn = fn(gx : Int, gy : Int, min_dist : Int) -> Bool {
    if not(can_walk(gx, gy)) {
      false
    } else if absi(gx - player.gx) + absi(gy - player.gy) < min_dist {
      false
    } else if gx == exit_x && gy == exit_y {
      false
    } else if crate_at(crates, gx, gy) >= 0 {
      false
    } else if enemy_at(enemies, gx, gy) >= 0 {
      false
    } else if relic_at(relics, gx, gy) >= 0 {
      false
    } else {
      let mut has_plate = false
      for i = 0; i < plates.length(); i = i + 1 {
        if plates[i].active && plates[i].gx == gx && plates[i].gy == gy {
          has_plate = true
          break
        }
      }

      if has_plate {
        false
      } else {
        true
      }
    }
  }

  let setup_stage = fn(stage_i : Int) {
    for y = 0; y < map_h; y = y + 1 {
      for x = 0; x < map_w; x = x + 1 {
        if x == 0 || y == 0 || x == map_w - 1 || y == map_h - 1 {
          tiles[idx(x, y)] = 1
        } else {
          tiles[idx(x, y)] = 0
        }
      }
    }

    clear_crates(crates)
    clear_plates(plates)
    clear_relics(relics)
    clear_enemies(enemies)
    clear_spikes(spikes)
    clear_particles(particles)

    player.gx = 1
    player.gy = map_h - 2
    player.face_x = 1
    player.face_y = 0
    player.slash_cd = 0.0
    player.dash_cd = 0.0
    player.bomb_cd = 0.0
    player.hurt_t = 0.0

    exit_x = map_w - 2
    exit_y = 1
    exit_open = false

    // Interior stone blocks.
    let stone_count : Int = 10 + stage_i * 6
    for i = 0; i < stone_count; i = i + 1 {
      ignore(i)
      let mut placed = false
      for _a = 0; _a < 120; _a = _a + 1 {
        let gx = @raylib.get_random_value(2, map_w - 3)
        let gy = @raylib.get_random_value(2, map_h - 3)

        if absi(gx - player.gx) + absi(gy - player.gy) > 3 &&
          absi(gx - exit_x) + absi(gy - exit_y) > 3 {
          if tiles[idx(gx, gy)] == 0 {
            tiles[idx(gx, gy)] = 1
            placed = true
            break
          }
        }
      }
      if not(placed) {
        ignore(())
      }
    }

    tiles[idx(player.gx, player.gy)] = 0
    tiles[idx(exit_x, exit_y)] = 0

    plate_goal = clampi(2 + stage_i, 2, 6)

    for i = 0; i < plate_goal; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 200; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 4) {
          let mut slot : Int = -1
          for k = 0; k < plates.length(); k = k + 1 {
            if not(plates[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            plates[slot].active = true
            plates[slot].gx = gx
            plates[slot].gy = gy
            plates[slot].pressed = false
          }
          break
        }
      }
    }

    let crate_count : Int = clampi(plate_goal + 1, 3, 8)
    for i = 0; i < crate_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 220; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 3) {
          let mut slot : Int = -1
          for k = 0; k < crates.length(); k = k + 1 {
            if not(crates[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            crates[slot].active = true
            crates[slot].gx = gx
            crates[slot].gy = gy
          }
          break
        }
      }
    }

    relic_left = clampi(4 + stage_i * 2, 4, 14)
    for i = 0; i < relic_left; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 220; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 5) {
          let mut slot : Int = -1
          for k = 0; k < relics.length(); k = k + 1 {
            if not(relics[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            relics[slot].active = true
            relics[slot].gx = gx
            relics[slot].gy = gy
            relics[slot].taken = false
          }
          break
        }
      }
    }

    let enemy_count : Int = clampi(4 + stage_i * 3, 4, 28)
    for i = 0; i < enemy_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 220; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if cell_free_for_spawn(gx, gy, 6) {
          let mut slot : Int = -1
          for k = 0; k < enemies.length(); k = k + 1 {
            if not(enemies[k].active) {
              slot = k
              break
            }
          }
          if slot >= 0 {
            let kind = @raylib.get_random_value(0, 2)
            enemies[slot].active = true
            enemies[slot].kind = kind
            enemies[slot].gx = gx
            enemies[slot].gy = gy
            enemies[slot].hp = 18.0 +
              Float::from_int(kind) * 12.0 +
              Float::from_int(stage_i) * 2.0
            enemies[slot].move_cd = randf(0.18, 0.40)
            enemies[slot].atk_cd = 0.0
            enemies[slot].stun_t = 0.0
            enemies[slot].hurt_cd = 0.0
          }
          break
        }
      }
    }

    let spike_count : Int = clampi(3 + stage_i * 2, 3, 18)
    for i = 0; i < spike_count; i = i + 1 {
      ignore(i)
      for _a = 0; _a < 220; _a = _a + 1 {
        let gx = @raylib.get_random_value(1, map_w - 2)
        let gy = @raylib.get_random_value(1, map_h - 2)
        if can_walk(gx, gy) &&
          crate_at(crates, gx, gy) < 0 &&
          enemy_at(enemies, gx, gy) < 0 &&
          relic_at(relics, gx, gy) < 0 {
          if absi(gx - player.gx) + absi(gy - player.gy) >= 5 &&
            absi(gx - exit_x) + absi(gy - exit_y) >= 5 {
            let mut exists = false
            for k = 0; k < spikes.length(); k = k + 1 {
              if spikes[k].active && spikes[k].gx == gx && spikes[k].gy == gy {
                exists = true
                break
              }
            }
            if not(exists) {
              let mut slot : Int = -1
              for k = 0; k < spikes.length(); k = k + 1 {
                if not(spikes[k].active) {
                  slot = k
                  break
                }
              }
              if slot >= 0 {
                spikes[slot].active = true
                spikes[slot].gx = gx
                spikes[slot].gy = gy
                spikes[slot].t = randf(0.0, 2.0)
              }
              break
            }
          }
        }
      }
    }

    stage_time = 94.0 + Float::from_int(stage_i) * 7.0
    msg = "Stage \{stage_i}: secure relics and open the gate"
    msg_t = 2.0
  }

  let reset_run = fn() {
    stage = 1
    total_time = 420.0
    losses = 0

    player.hp = 100.0
    player.stamina = 100.0
    player.score = 0
    player.combo = 0

    setup_stage(stage)
  }

  let spike_is_up = fn(spike : Spike) -> Bool {
    let phase = (spike.t * 2.0).to_int() % 4
    phase <= 1
  }

  let update_plate_state = fn() {
    plates_pressed = 0
    for i = 0; i < plates.length(); i = i + 1 {
      if not(plates[i].active) {
        continue
      }

      let on_player = player.gx == plates[i].gx && player.gy == plates[i].gy
      let on_crate = crate_at(crates, plates[i].gx, plates[i].gy) >= 0
      plates[i].pressed = on_player || on_crate
      if plates[i].pressed {
        plates_pressed = plates_pressed + 1
      }
    }

    exit_open = relic_left <= 0 && plates_pressed >= plate_goal
  }

  let damage_player = fn(amount : Float, reason : String) {
    if player.hurt_t > 0.0 {
      ignore(())
    } else {
      player.hp = player.hp - amount
      player.hurt_t = 0.48
      player.combo = 0
      losses = losses + 1
      msg = reason
      msg_t = 0.65
      burst(
        particles,
        cell_center_x(player.gx),
        cell_center_y(player.gy),
        14,
        0.18,
        3,
      )
    }
  }

  let kill_enemy = fn(slot : Int, bonus : Int) {
    enemies[slot].active = false
    player.combo = player.combo + 1
    player.score = player.score + bonus + player.combo * 4 + stage * 3
    burst(
      particles,
      cell_center_x(enemies[slot].gx),
      cell_center_y(enemies[slot].gy),
      12,
      0.17,
      1,
    )
  }

  let attempt_move = fn(dx : Int, dy : Int) {
    if dx == 0 && dy == 0 {
      ignore(())
    } else {
      player.face_x = dx
      player.face_y = dy

      let nx = player.gx + dx
      let ny = player.gy + dy
      if not(can_walk(nx, ny)) {
        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          3,
          0.08,
          0,
        )
      } else if enemy_at(enemies, nx, ny) >= 0 {
        msg = "Enemy blocking"
        msg_t = 0.35
      } else {
        let crate_slot = crate_at(crates, nx, ny)
        if crate_slot >= 0 {
          let bx = nx + dx
          let by = ny + dy
          if can_walk(bx, by) &&
            crate_at(crates, bx, by) < 0 &&
            enemy_at(enemies, bx, by) < 0 &&
            not(exit_open && bx == exit_x && by == exit_y) {
            crates[crate_slot].gx = bx
            crates[crate_slot].gy = by
            player.gx = nx
            player.gy = ny
            burst(particles, cell_center_x(nx), cell_center_y(ny), 4, 0.07, 0)
          } else {
            msg = "Crate jammed"
            msg_t = 0.32
          }
        } else {
          player.gx = nx
          player.gy = ny
        }
      }
    }
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

    let mouse = @raylib.get_mouse_position()
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let pressed : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if player.hurt_t > 0.0 {
      player.hurt_t = player.hurt_t - dt
      if player.hurt_t < 0.0 {
        player.hurt_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      total_time = total_time - dt
      stage_time = stage_time - dt

      if stage_time <= 0.0 {
        damage_player(8.0, "Temple pressure rising")
        stage_time = 8.0
      }

      player.stamina = player.stamina + dt * 18.0
      if player.stamina > 100.0 {
        player.stamina = 100.0
      }

      player.slash_cd = player.slash_cd - dt
      if player.slash_cd < 0.0 {
        player.slash_cd = 0.0
      }

      player.dash_cd = player.dash_cd - dt
      if player.dash_cd < 0.0 {
        player.dash_cd = 0.0
      }

      player.bomb_cd = player.bomb_cd - dt
      if player.bomb_cd < 0.0 {
        player.bomb_cd = 0.0
      }

      for i = 0; i < spikes.length(); i = i + 1 {
        if spikes[i].active {
          spikes[i].t = spikes[i].t + dt
        }
      }

      let pad_x = 24
      let pad_y = sh - 196
      let btn_x = sw - 298
      let btn_y = sh - 232

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut slash_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut bomb_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 56, 78, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 56, 78, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 112, 78, 58) {
          move_d = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 8, btn_y + 12, 120, 92) {
          slash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 136, btn_y + 12, 120, 92) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 74, btn_y + 116, 148, 100) {
          bomb_press = true
        }
      }

      let mut dx : Int = 0
      let mut dy : Int = 0
      if move_l {
        dx = -1
      } else if move_r {
        dx = 1
      } else if move_u {
        dy = -1
      } else if move_d {
        dy = 1
      }

      let any_dir = dx != 0 || dy != 0
      if move_repeat_t > 0.0 {
        move_repeat_t = move_repeat_t - dt
        if move_repeat_t < 0.0 {
          move_repeat_t = 0.0
        }
      }

      let move_pressed = @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) ||
        @raylib.is_key_pressed(@raylib.KeyRight) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeyDown)

      if any_dir && (move_pressed || move_repeat_t <= 0.0 || touching) {
        attempt_move(dx, dy)
        move_repeat_t = if touching { 0.14 } else { 0.11 }
      }

      if slash_press && player.slash_cd <= 0.0 {
        player.slash_cd = 0.32
        let mut hit_count : Int = 0

        for step = 1; step <= 2; step = step + 1 {
          let tx = player.gx + player.face_x * step
          let ty = player.gy + player.face_y * step
          let e = enemy_at(enemies, tx, ty)
          if e >= 0 {
            enemies[e].hp = enemies[e].hp - (15.0 + Float::from_int(stage))
            enemies[e].stun_t = 0.4
            enemies[e].hurt_cd = 0.2
            hit_count = hit_count + 1
            burst(particles, cell_center_x(tx), cell_center_y(ty), 8, 0.11, 0)
            if enemies[e].hp <= 0.0 {
              kill_enemy(e, 36)
            }
          }
        }

        let lx = player.gx - player.face_y
        let ly = player.gy - player.face_x
        let rx = player.gx + player.face_y
        let ry = player.gy + player.face_x

        let le = enemy_at(enemies, lx, ly)
        if le >= 0 {
          enemies[le].hp = enemies[le].hp - 12.0
          enemies[le].stun_t = 0.25
          enemies[le].hurt_cd = 0.2
          hit_count = hit_count + 1
          if enemies[le].hp <= 0.0 {
            kill_enemy(le, 28)
          }
        }

        let re = enemy_at(enemies, rx, ry)
        if re >= 0 {
          enemies[re].hp = enemies[re].hp - 12.0
          enemies[re].stun_t = 0.25
          enemies[re].hurt_cd = 0.2
          hit_count = hit_count + 1
          if enemies[re].hp <= 0.0 {
            kill_enemy(re, 28)
          }
        }

        if hit_count <= 0 {
          player.combo = 0
        }

        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          6,
          0.09,
          0,
        )
      }

      if dash_press && player.dash_cd <= 0.0 && player.stamina >= 24.0 {
        player.dash_cd = 1.35
        player.stamina = player.stamina - 24.0

        let mut nx = player.gx
        let mut ny = player.gy
        for step = 1; step <= 2; step = step + 1 {
          let tx = player.gx + player.face_x * step
          let ty = player.gy + player.face_y * step

          if can_walk(tx, ty) && crate_at(crates, tx, ty) < 0 {
            nx = tx
            ny = ty
            let e = enemy_at(enemies, tx, ty)
            if e >= 0 {
              enemies[e].hp = enemies[e].hp - 18.0
              enemies[e].stun_t = 0.6
              enemies[e].hurt_cd = 0.5
              if enemies[e].hp <= 0.0 {
                kill_enemy(e, 44)
              }
            }
          }
        }

        player.gx = nx
        player.gy = ny
        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          16,
          0.17,
          2,
        )
      }

      if bomb_press && player.bomb_cd <= 0.0 && player.stamina >= 40.0 {
        player.bomb_cd = 5.4
        player.stamina = player.stamina - 40.0

        let mut bomb_hits : Int = 0
        for i = 0; i < enemies.length(); i = i + 1 {
          if enemies[i].active {
            let dxi = absi(enemies[i].gx - player.gx)
            let dyi = absi(enemies[i].gy - player.gy)
            if dxi <= 2 && dyi <= 2 {
              enemies[i].hp = enemies[i].hp - 42.0
              enemies[i].stun_t = 0.8
              enemies[i].hurt_cd = 0.6
              bomb_hits = bomb_hits + 1
              if enemies[i].hp <= 0.0 {
                kill_enemy(i, 64)
              }
            }
          }
        }

        for y = player.gy - 1; y <= player.gy + 1; y = y + 1 {
          for x = player.gx - 1; x <= player.gx + 1; x = x + 1 {
            if in_bounds(x, y) &&
              not(x == 0 || y == 0 || x == map_w - 1 || y == map_h - 1) {
              if tiles[idx(x, y)] == 1 {
                tiles[idx(x, y)] = 0
              }
            }
          }
        }

        if bomb_hits > 0 {
          msg = "Relic charge x\{bomb_hits}"
          msg_t = 0.72
        } else {
          msg = "Stone walls shattered"
          msg_t = 0.62
        }

        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          28,
          0.22,
          1,
        )
      }

      for i = 0; i < enemies.length(); i = i + 1 {
        if not(enemies[i].active) {
          continue
        }

        enemies[i].move_cd = enemies[i].move_cd - dt
        enemies[i].atk_cd = enemies[i].atk_cd - dt
        enemies[i].stun_t = enemies[i].stun_t - dt
        enemies[i].hurt_cd = enemies[i].hurt_cd - dt
        if enemies[i].atk_cd < 0.0 {
          enemies[i].atk_cd = 0.0
        }
        if enemies[i].stun_t < 0.0 {
          enemies[i].stun_t = 0.0
        }
        if enemies[i].hurt_cd < 0.0 {
          enemies[i].hurt_cd = 0.0
        }

        let sp = spike_at(spikes, enemies[i].gx, enemies[i].gy)
        if sp >= 0 && spike_is_up(spikes[sp]) && enemies[i].hurt_cd <= 0.0 {
          enemies[i].hp = enemies[i].hp - 8.0
          enemies[i].hurt_cd = 0.56
          if enemies[i].hp <= 0.0 {
            kill_enemy(i, 24)
            continue
          }
        }

        if enemies[i].stun_t > 0.0 {
          continue
        }

        let dist = absi(enemies[i].gx - player.gx) +
          absi(enemies[i].gy - player.gy)
        if dist == 1 && enemies[i].atk_cd <= 0.0 {
          enemies[i].atk_cd = 0.9 - Float::from_int(enemies[i].kind) * 0.12
          if enemies[i].atk_cd < 0.38 {
            enemies[i].atk_cd = 0.38
          }
          damage_player(
            10.0 + Float::from_int(enemies[i].kind) * 3.0,
            "Mummy strike",
          )
        }

        if enemies[i].move_cd <= 0.0 {
          enemies[i].move_cd = 0.26 +
            Float::from_int(@raylib.get_random_value(0, 14)) / 100.0

          let mut dxm = 0
          let mut dym = 0
          let dxp = player.gx - enemies[i].gx
          let dyp = player.gy - enemies[i].gy

          if absi(dxp) > absi(dyp) {
            dxm = if dxp < 0 { -1 } else if dxp > 0 { 1 } else { 0 }
          } else {
            dym = if dyp < 0 { -1 } else if dyp > 0 { 1 } else { 0 }
          }

          let mut tx = enemies[i].gx + dxm
          let mut ty = enemies[i].gy + dym
          if not(can_walk(tx, ty)) ||
            crate_at(crates, tx, ty) >= 0 ||
            enemy_at(enemies, tx, ty) >= 0 ||
            (tx == player.gx && ty == player.gy) {
            // Try orthogonal fallback.
            if dxm != 0 {
              dxm = 0
              dym = if dyp < 0 { -1 } else if dyp > 0 { 1 } else { 0 }
            } else if dym != 0 {
              dym = 0
              dxm = if dxp < 0 { -1 } else if dxp > 0 { 1 } else { 0 }
            }

            tx = enemies[i].gx + dxm
            ty = enemies[i].gy + dym
          }

          if can_walk(tx, ty) &&
            crate_at(crates, tx, ty) < 0 &&
            enemy_at(enemies, tx, ty) < 0 &&
            not(tx == player.gx && ty == player.gy) {
            enemies[i].gx = tx
            enemies[i].gy = ty
          }
        }
      }

      let sp = spike_at(spikes, player.gx, player.gy)
      if sp >= 0 && spike_is_up(spikes[sp]) {
        damage_player(7.0, "Spike trap")
      }

      let rel = relic_at(relics, player.gx, player.gy)
      if rel >= 0 {
        relics[rel].taken = true
        relic_left = relic_left - 1
        player.score = player.score + 90 + stage * 12
        player.combo = player.combo + 1
        msg = "Relic recovered"
        msg_t = 0.6
        burst(
          particles,
          cell_center_x(player.gx),
          cell_center_y(player.gy),
          12,
          0.16,
          2,
        )
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
          particles[i].vx = particles[i].vx * (1.0 - dt * 2.0)
          particles[i].vy = particles[i].vy + 250.0 * dt
        }
      }

      update_plate_state()

      if exit_open && player.gx == exit_x && player.gy == exit_y {
        if stage < max_stage {
          stage = stage + 1
          player.score = player.score + 260 + stage * 40
          player.stamina = 100.0
          player.hp = clampf(player.hp + 18.0, 0.0, 100.0)
          setup_stage(stage)
        } else {
          state = 2
        }
      }

      if player.hp <= 0.0 || total_time <= 0.0 {
        state = 3
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

    @raylib.clear_background(@raylib.Color::new(18, 14, 10, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 18, 12, 255))
    @raylib.draw_rectangle(
      map_x - 16,
      map_y - 16,
      map_w * tile + 32,
      map_h * tile + 32,
      @raylib.Color::new(40, 30, 18, 255),
    )

    for y = 0; y < map_h; y = y + 1 {
      for x = 0; x < map_w; x = x + 1 {
        let px = map_x + x * tile
        let py = map_y + y * tile
        if tiles[idx(x, y)] == 1 {
          @raylib.draw_rectangle(
            px,
            py,
            tile,
            tile,
            @raylib.Color::new(76, 62, 40, 255),
          )
          @raylib.draw_rectangle(
            px + 8,
            py + 8,
            tile - 16,
            tile - 16,
            @raylib.Color::new(58, 46, 28, 255),
          )
        } else {
          let checker = (x + y) % 2 == 0
          let c = if checker {
            @raylib.Color::new(116, 92, 58, 255)
          } else {
            @raylib.Color::new(108, 84, 52, 255)
          }
          @raylib.draw_rectangle(px, py, tile, tile, c)
        }
      }
    }

    for i = 0; i < spikes.length(); i = i + 1 {
      if not(spikes[i].active) {
        continue
      }

      let up = spike_is_up(spikes[i])
      let px = map_x + spikes[i].gx * tile
      let py = map_y + spikes[i].gy * tile
      if up {
        @raylib.draw_triangle(
          @raylib.Vector2::new(
            Float::from_int(px + tile / 2),
            Float::from_int(py + 8),
          ),
          @raylib.Vector2::new(
            Float::from_int(px + 10),
            Float::from_int(py + tile - 8),
          ),
          @raylib.Vector2::new(
            Float::from_int(px + tile - 10),
            Float::from_int(py + tile - 8),
          ),
          @raylib.Color::new(198, 66, 58, 255),
        )
      } else {
        @raylib.draw_rectangle(
          px + 14,
          py + 24,
          tile - 28,
          tile - 20,
          @raylib.Color::new(74, 56, 42, 255),
        )
      }
    }

    for i = 0; i < plates.length(); i = i + 1 {
      if not(plates[i].active) {
        continue
      }
      let cx = cell_center_x(plates[i].gx)
      let cy = cell_center_y(plates[i].gy)
      let col = if plates[i].pressed {
        @raylib.Color::new(132, 218, 146, 255)
      } else {
        @raylib.Color::new(226, 184, 90, 255)
      }
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 15.0, col)
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        20.0,
        @raylib.Color::new(52, 36, 22, 255),
      )
    }

    let exit_px = map_x + exit_x * tile
    let exit_py = map_y + exit_y * tile
    let gate_col = if exit_open {
      @raylib.Color::new(92, 206, 144, 255)
    } else {
      @raylib.Color::new(188, 88, 74, 255)
    }
    @raylib.draw_rectangle(
      exit_px + 8,
      exit_py + 8,
      tile - 16,
      tile - 16,
      gate_col,
    )
    if not(exit_open) {
      @raylib.draw_line(
        exit_px + 10,
        exit_py + 10,
        exit_px + tile - 10,
        exit_py + tile - 10,
        @raylib.Color::new(58, 22, 18, 255),
      )
      @raylib.draw_line(
        exit_px + tile - 10,
        exit_py + 10,
        exit_px + 10,
        exit_py + tile - 10,
        @raylib.Color::new(58, 22, 18, 255),
      )
    }

    for i = 0; i < relics.length(); i = i + 1 {
      if relics[i].active && not(relics[i].taken) {
        let cx = cell_center_x(relics[i].gx)
        let cy = cell_center_y(relics[i].gy)
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy - 14.0),
          @raylib.Vector2::new(cx - 12.0, cy + 6.0),
          @raylib.Vector2::new(cx + 12.0, cy + 6.0),
          @raylib.Color::new(136, 230, 248, 255),
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy + 16.0),
          @raylib.Vector2::new(cx - 12.0, cy + 6.0),
          @raylib.Vector2::new(cx + 12.0, cy + 6.0),
          @raylib.Color::new(78, 178, 236, 255),
        )
      }
    }

    for i = 0; i < crates.length(); i = i + 1 {
      if crates[i].active {
        let px = map_x + crates[i].gx * tile
        let py = map_y + crates[i].gy * tile
        @raylib.draw_rectangle(
          px + 8,
          py + 8,
          tile - 16,
          tile - 16,
          @raylib.Color::new(146, 108, 62, 255),
        )
        @raylib.draw_rectangle_lines(
          px + 8,
          py + 8,
          tile - 16,
          tile - 16,
          @raylib.Color::new(78, 56, 30, 255),
        )
      }
    }

    for i = 0; i < enemies.length(); i = i + 1 {
      if enemies[i].active {
        let cx = cell_center_x(enemies[i].gx)
        let cy = cell_center_y(enemies[i].gy)
        let body_col = if enemies[i].kind == 0 {
          @raylib.Color::new(186, 162, 122, 255)
        } else if enemies[i].kind == 1 {
          @raylib.Color::new(162, 132, 106, 255)
        } else {
          @raylib.Color::new(138, 106, 86, 255)
        }

        @raylib.draw_circle(cx.to_int(), cy.to_int(), 16.0, body_col)
        @raylib.draw_circle(
          cx.to_int(),
          (cy - 18.0).to_int(),
          12.0,
          @raylib.Color::new(216, 194, 148, 255),
        )
        @raylib.draw_circle(
          (cx - 4.0).to_int(),
          (cy - 20.0).to_int(),
          2.8,
          @raylib.Color::new(32, 18, 12, 255),
        )
        @raylib.draw_circle(
          (cx + 4.0).to_int(),
          (cy - 20.0).to_int(),
          2.8,
          @raylib.Color::new(32, 18, 12, 255),
        )
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let ratio : Float = 1.0 - particles[i].t / particles[i].life
      let a = (ratio * 255.0).to_int()
      if a <= 0 {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(152, 236, 248, a)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 166, 118, a)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(140, 236, 184, a)
      } else {
        @raylib.Color::new(252, 112, 120, a)
      }

      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        col,
      )
    }

    let pcx = cell_center_x(player.gx)
    let pcy = cell_center_y(player.gy)
    let player_col = if player.hurt_t > 0.0 {
      @raylib.Color::new(252, 128, 124, 255)
    } else {
      @raylib.Color::new(112, 206, 246, 255)
    }
    @raylib.draw_circle(pcx.to_int(), pcy.to_int(), 17.0, player_col)
    @raylib.draw_circle(
      pcx.to_int(),
      (pcy - 20.0).to_int(),
      12.0,
      @raylib.Color::new(244, 214, 170, 255),
    )
    @raylib.draw_rectangle(
      (pcx - 5.0 + Float::from_int(player.face_x * 8)).to_int(),
      (pcy - 6.0 + Float::from_int(player.face_y * 8)).to_int(),
      10,
      10,
      @raylib.Color::new(218, 244, 255, 255),
    )

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(10, 8, 6, 228))
    @raylib.draw_text(
      "TEMPLE RELIC RUN 2026",
      18,
      14,
      30,
      @raylib.Color::new(246, 236, 206, 255),
    )
    @raylib.draw_text(
      "WASD move  J slash  K dash  L relic charge",
      18,
      48,
      18,
      @raylib.Color::new(206, 188, 152, 255),
    )

    @raylib.draw_text(
      "Stage \{stage}/\{max_stage}",
      520,
      14,
      28,
      @raylib.Color::new(252, 218, 132, 255),
    )
    @raylib.draw_text(
      "Score \{player.score}",
      700,
      14,
      28,
      @raylib.Color::new(176, 236, 196, 255),
    )
    @raylib.draw_text(
      "Timer \{total_time.to_int()}s",
      932,
      14,
      28,
      @raylib.Color::new(168, 220, 252, 255),
    )
    @raylib.draw_text(
      "Losses \{losses}",
      1120,
      14,
      28,
      @raylib.Color::new(246, 166, 164, 255),
    )

    @raylib.draw_rectangle(18, 84, 220, 10, @raylib.Color::new(28, 20, 14, 255))
    @raylib.draw_rectangle(
      18,
      84,
      (player.hp / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(118, 226, 158, 255),
    )
    @raylib.draw_text("HP", 18, 98, 16, @raylib.Color::new(218, 202, 174, 255))

    @raylib.draw_rectangle(
      254,
      84,
      220,
      10,
      @raylib.Color::new(28, 20, 14, 255),
    )
    @raylib.draw_rectangle(
      254,
      84,
      (player.stamina / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(122, 196, 246, 255),
    )
    @raylib.draw_text(
      "STAMINA",
      254,
      98,
      16,
      @raylib.Color::new(218, 202, 174, 255),
    )

    @raylib.draw_text(
      "Relics \{relic_left}",
      500,
      84,
      20,
      @raylib.Color::new(152, 226, 246, 255),
    )
    @raylib.draw_text(
      "Plates \{plates_pressed}/\{plate_goal}",
      610,
      84,
      20,
      @raylib.Color::new(252, 214, 122, 255),
    )
    @raylib.draw_text(
      "Combo \{player.combo}",
      800,
      84,
      20,
      @raylib.Color::new(252, 224, 162, 255),
    )
    @raylib.draw_text(
      "Slash \{player.slash_cd.to_int()}  Dash \{player.dash_cd.to_int()}  Bomb \{player.bomb_cd.to_int()}",
      920,
      84,
      20,
      @raylib.Color::new(202, 186, 156, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 360,
      sh - 52,
      720,
      38,
      @raylib.Color::new(10, 8, 6, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 340,
      sh - 44,
      24,
      @raylib.Color::new(244, 236, 214, if msg_t > 0.0 { 255 } else { 148 }),
    )

    @raylib.draw_rectangle(
      24,
      sh - 196,
      238,
      170,
      @raylib.Color::new(20, 18, 14, 214),
    )
    let px0 = 24
    let py0 = sh - 196
    @raylib.draw_rectangle(
      px0,
      py0 + 56,
      78,
      58,
      @raylib.Color::new(88, 76, 60, 255),
    )
    @raylib.draw_text(
      "L",
      px0 + 30,
      py0 + 72,
      28,
      @raylib.Color::new(234, 224, 202, 255),
    )
    @raylib.draw_rectangle(
      px0 + 160,
      py0 + 56,
      78,
      58,
      @raylib.Color::new(88, 76, 60, 255),
    )
    @raylib.draw_text(
      "R",
      px0 + 190,
      py0 + 72,
      28,
      @raylib.Color::new(234, 224, 202, 255),
    )
    @raylib.draw_rectangle(
      px0 + 80,
      py0,
      78,
      58,
      @raylib.Color::new(88, 76, 60, 255),
    )
    @raylib.draw_text(
      "U",
      px0 + 110,
      py0 + 16,
      28,
      @raylib.Color::new(234, 224, 202, 255),
    )
    @raylib.draw_rectangle(
      px0 + 80,
      py0 + 112,
      78,
      58,
      @raylib.Color::new(88, 76, 60, 255),
    )
    @raylib.draw_text(
      "D",
      px0 + 110,
      py0 + 128,
      28,
      @raylib.Color::new(234, 224, 202, 255),
    )

    @raylib.draw_rectangle(
      sw - 298,
      sh - 232,
      274,
      220,
      @raylib.Color::new(20, 18, 14, 214),
    )
    let bx0 = sw - 298
    let by0 = sh - 232
    @raylib.draw_rectangle(
      bx0 + 8,
      by0 + 12,
      120,
      92,
      @raylib.Color::new(112, 152, 198, 255),
    )
    @raylib.draw_text(
      "SLASH",
      bx0 + 28,
      by0 + 48,
      30,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      bx0 + 136,
      by0 + 12,
      120,
      92,
      @raylib.Color::new(196, 136, 88, 255),
    )
    @raylib.draw_text(
      "DASH",
      bx0 + 166,
      by0 + 48,
      30,
      @raylib.Color::new(252, 240, 226, 255),
    )
    @raylib.draw_rectangle(
      bx0 + 74,
      by0 + 116,
      148,
      100,
      @raylib.Color::new(138, 182, 112, 255),
    )
    @raylib.draw_text(
      "CHARGE",
      bx0 + 94,
      by0 + 154,
      30,
      @raylib.Color::new(240, 246, 236, 255),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 480,
        sh / 2 - 210,
        960,
        420,
        @raylib.Color::new(22, 18, 12, 246),
      )
      @raylib.draw_text(
        "TEMPLE RELIC RUN",
        sw / 2 - 306,
        sh / 2 - 132,
        66,
        @raylib.Color::new(246, 236, 206, 255),
      )
      @raylib.draw_text(
        "Push crates onto plates, recover relics, unlock the gate.",
        sw / 2 - 352,
        sh / 2 - 26,
        32,
        @raylib.Color::new(208, 188, 154, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad moves, right buttons slash/dash/charge",
        sw / 2 - 368,
        sh / 2 + 18,
        30,
        @raylib.Color::new(208, 188, 154, 255),
      )
      @raylib.draw_text(
        "Clear 5 stages before time runs out",
        sw / 2 - 222,
        sh / 2 + 66,
        34,
        @raylib.Color::new(252, 214, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 188,
        sh / 2 + 126,
        42,
        @raylib.Color::new(255, 208, 118, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 148))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(22, 18, 12, 246),
      )
      @raylib.draw_text(
        "TEMPLE MASTERED",
        sw / 2 - 262,
        sh / 2 - 132,
        62,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Losses: \{losses}  Time left: \{total_time.to_int()}s",
        sw / 2 - 220,
        sh / 2 + 20,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 154))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(22, 18, 12, 246),
      )
      @raylib.draw_text(
        "RUN FAILED",
        sw / 2 - 176,
        sh / 2 - 132,
        62,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{player.score}",
        sw / 2 - 148,
        sh / 2 - 34,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Stage: \{stage}  Losses: \{losses}",
        sw / 2 - 166,
        sh / 2 + 20,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
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
