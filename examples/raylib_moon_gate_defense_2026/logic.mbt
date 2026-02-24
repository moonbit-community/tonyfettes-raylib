///|
fn set_status(game : Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn clear_nodes(game : Game) -> Unit {
  for i in 0..<game.nodes.length() {
    game.nodes[i] = Node::new()
  }
}

///|
fn clear_enemies(game : Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = Enemy::new()
  }
}

///|
fn clear_bolts(game : Game) -> Unit {
  for i in 0..<game.bolts.length() {
    game.bolts[i] = Bolt::new()
  }
}

///|
fn clear_pulses(game : Game) -> Unit {
  for i in 0..<game.pulses.length() {
    game.pulses[i] = PulseFx::new()
  }
}

///|
fn alloc_node(game : Game) -> Int {
  for i in 0..<game.nodes.length() {
    if not(game.nodes[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_bolt(game : Game) -> Int {
  for i in 0..<game.bolts.length() {
    if not(game.bolts[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_pulse(game : Game) -> Int {
  for i in 0..<game.pulses.length() {
    if not(game.pulses[i].active) {
      return i
    }
  }
  -1
}

///|
fn emit_pulse(
  game : Game,
  x : Float,
  y : Float,
  start_radius : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_pulse(game)
  if i < 0 {
    return
  }

  game.pulses[i] = {
    active: true,
    x,
    y,
    radius: start_radius,
    life,
    max_life: life,
    kind,
  }
}

///|
fn active_enemy_count(game : Game) -> Int {
  let mut count = 0
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active {
      count = count + 1
    }
  }
  count
}

///|
fn begin_next_wave(game : Game) -> Unit {
  game.wave = game.wave + 1
  game.pending_spawns = wave_spawn_count(game.wave)
  game.spawn_cd = 0.35
  game.wave_delay = wave_intro_delay
  game.energy = minf(
    energy_max,
    game.energy + wave_energy_bonus + Float::from_int(game.wave) * 1.5,
  )
  set_status(game, "Wave " + game.wave.to_string() + " incoming", 1.5)
}

///|
fn start_new_run(game : Game) -> Unit {
  clear_nodes(game)
  clear_enemies(game)
  clear_bolts(game)
  clear_pulses(game)

  game.state = state_playing
  game.score = 0
  game.kills = 0
  game.wave = 0
  game.pending_spawns = 0
  game.spawn_cd = 0.0
  game.wave_delay = 0.0
  game.gate_hp = gate_hp_max
  game.energy = energy_start
  game.barrier_charge = 0.0
  game.barrier_flash = 0.0
  game.combo = 0
  game.combo_timer = 0.0
  game.shake_t = 0.0
  game.cursor_x = gate_gx + 1
  game.cursor_y = gate_gy
  game.cursor_dir = dir_left

  set_status(game, "Deploy guardians and hold the moon gate", 1.7)
  begin_next_wave(game)
}

///|
fn enter_game_over(game : Game) -> Unit {
  if game.state == state_game_over {
    return
  }

  game.state = state_game_over
  game.pending_spawns = 0
  game.spawn_cd = 0.0
  game.wave_delay = 0.0
  game.combo = 0
  game.combo_timer = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_status(game, "The moon gate has fallen", 2.0)
}

///|
fn find_node_at(game : Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.nodes.length() {
    if game.nodes[i].active && game.nodes[i].gx == gx && game.nodes[i].gy == gy {
      return i
    }
  }
  -1
}

///|
fn move_cursor(game : Game) -> Unit {
  if game.input_move_x < 0 {
    game.cursor_x = clampi(game.cursor_x - 1, 0, grid_cols - 1)
    game.cursor_dir = dir_left
  } else if game.input_move_x > 0 {
    game.cursor_x = clampi(game.cursor_x + 1, 0, grid_cols - 1)
    game.cursor_dir = dir_right
  }

  if game.input_move_y < 0 {
    game.cursor_y = clampi(game.cursor_y - 1, 0, grid_rows - 1)
    game.cursor_dir = dir_up
  } else if game.input_move_y > 0 {
    game.cursor_y = clampi(game.cursor_y + 1, 0, grid_rows - 1)
    game.cursor_dir = dir_down
  }
}

///|
fn try_build_or_upgrade(game : Game) -> Unit {
  let gx = game.cursor_x
  let gy = game.cursor_y

  if is_gate_cell(gx, gy) {
    set_status(game, "Gate tile reserved", 0.5)
    return
  }

  let node_index = find_node_at(game, gx, gy)
  if node_index < 0 {
    if game.energy < node_build_cost {
      set_status(game, "Not enough energy", 0.6)
      return
    }

    let slot = alloc_node(game)
    if slot < 0 {
      return
    }

    game.nodes[slot] = {
      active: true,
      gx,
      gy,
      level: 1,
      facing: game.cursor_dir,
      cooldown: 0.2,
      pulse: 1.0,
    }

    game.energy = game.energy - node_build_cost
    emit_pulse(game, cell_center_x(gx), cell_center_y(gy), 14.0, 0.38, 0)
    set_status(game, "Guardian deployed", 0.5)
    return
  }

  if game.nodes[node_index].facing != game.cursor_dir {
    game.nodes[node_index].facing = game.cursor_dir
    game.nodes[node_index].pulse = 0.6
    emit_pulse(game, cell_center_x(gx), cell_center_y(gy), 12.0, 0.24, 0)
    return
  }

  if game.nodes[node_index].level < node_max_level {
    let next_level = game.nodes[node_index].level + 1
    let upgrade_cost = node_upgrade_cost(next_level)

    if game.energy < upgrade_cost {
      set_status(
        game,
        "Need " + upgrade_cost.to_int().to_string() + " energy",
        0.6,
      )
      return
    }

    game.energy = game.energy - upgrade_cost
    game.nodes[node_index].level = next_level
    game.nodes[node_index].pulse = 1.2
    game.nodes[node_index].cooldown = minf(game.nodes[node_index].cooldown, 0.1)
    emit_pulse(game, cell_center_x(gx), cell_center_y(gy), 16.0, 0.42, 1)
    set_status(game, "Node upgraded to L" + next_level.to_string(), 0.7)
    return
  }

  game.nodes[node_index].facing = (game.nodes[node_index].facing + 1) % 4
  game.nodes[node_index].pulse = 0.45
}

///|
fn try_sell_node(game : Game) -> Unit {
  let node_index = find_node_at(game, game.cursor_x, game.cursor_y)
  if node_index < 0 {
    set_status(game, "No node on this tile", 0.5)
    return
  }

  let refund = node_sell_refund(game.nodes[node_index].level)
  game.energy = minf(energy_max, game.energy + refund)
  game.nodes[node_index] = Node::new()

  emit_pulse(
    game,
    cell_center_x(game.cursor_x),
    cell_center_y(game.cursor_y),
    20.0,
    0.45,
    2,
  )
  set_status(game, "Salvaged +" + refund.to_int().to_string(), 0.55)
}

///|
fn spawn_enemy(game : Game) -> Bool {
  let slot = alloc_enemy(game)
  if slot < 0 {
    return false
  }

  let side = randi(0, 3)
  let mut x : Float = 0.0
  let mut y : Float = 0.0
  if side == 0 {
    x = randf(board_left() + 10.0, board_right() - 10.0)
    y = board_top() - 42.0
  } else if side == 1 {
    x = board_right() + 42.0
    y = randf(board_top() + 10.0, board_bottom() - 10.0)
  } else if side == 2 {
    x = randf(board_left() + 10.0, board_right() - 10.0)
    y = board_bottom() + 42.0
  } else {
    x = board_left() - 42.0
    y = randf(board_top() + 10.0, board_bottom() - 10.0)
  }

  let mut kind = enemy_kind_skitter
  let roll = randi(0, 99)
  let heavy_cut = 12 + mini(26, game.wave * 3)
  let wraith_cut = 72 - mini(22, game.wave * 2)

  if roll < heavy_cut {
    kind = enemy_kind_carapace
  } else if roll >= wraith_cut {
    kind = enemy_kind_wraith
  }

  let wavef = Float::from_int(game.wave - 1)
  let base_hp = enemy_base_hp + wavef * enemy_hp_per_wave + randf(-2.0, 4.0)
  let base_speed = enemy_base_speed + minf(100.0, wavef * enemy_speed_per_wave)

  let mut hp = base_hp
  let mut speed = base_speed
  let mut radius : Float = 12.0
  let mut reward = 8 + game.wave / 2
  let mut gate_damage = enemy_contact_damage_base +
    wavef * enemy_contact_damage_wave

  if kind == enemy_kind_carapace {
    hp = base_hp * 1.85
    speed = base_speed * 0.78
    radius = 17.0
    reward = 14 + game.wave
    gate_damage = enemy_contact_damage_base * 1.45 +
      wavef * enemy_contact_damage_wave
  } else if kind == enemy_kind_wraith {
    hp = base_hp * 1.15
    speed = base_speed * 1.08
    radius = 13.0
    reward = 11 + game.wave
    gate_damage = enemy_contact_damage_base * 1.05 +
      wavef * enemy_contact_damage_wave * 0.9
  } else {
    hp = base_hp * 0.84
    speed = base_speed * 1.28
    radius = 10.0
    reward = 8 + game.wave / 2
    gate_damage = enemy_contact_damage_base * 0.75 +
      wavef * enemy_contact_damage_wave * 0.7
  }

  game.enemies[slot] = {
    active: true,
    kind,
    x,
    y,
    vx: 0.0,
    vy: 0.0,
    hp,
    max_hp: hp,
    speed,
    radius,
    reward,
    gate_damage,
    phase: randf(0.0, 6.283),
  }

  true
}

///|
fn update_wave_spawner(game : Game, dt : Float) -> Unit {
  if game.wave_delay > 0.0 {
    game.wave_delay = maxf(0.0, game.wave_delay - dt)
  }

  if game.pending_spawns > 0 {
    if game.wave_delay > 0.0 {
      return
    }

    game.spawn_cd = game.spawn_cd - dt
    if game.spawn_cd <= 0.0 {
      if spawn_enemy(game) {
        game.pending_spawns = game.pending_spawns - 1
      }
      game.spawn_cd = wave_spawn_cd(game.wave)
    }
    return
  }

  if active_enemy_count(game) == 0 {
    begin_next_wave(game)
  }
}

///|
fn spawn_bolt(
  game : Game,
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  dmg : Float,
) -> Unit {
  let slot = alloc_bolt(game)
  if slot < 0 {
    return
  }

  let dx = tx - x
  let dy = ty - y
  let d2 = dx * dx + dy * dy
  if d2 <= 0.0001 {
    return
  }

  let inv = Float::from_int(1) / sqrtf(d2)
  game.bolts[slot] = {
    active: true,
    x,
    y,
    vx: dx * inv * node_projectile_speed,
    vy: dy * inv * node_projectile_speed,
    life: bolt_life,
    dmg,
  }
}

///|
fn kill_enemy(game : Game, enemy_index : Int, by_barrier : Bool) -> Unit {
  if enemy_index < 0 || not(game.enemies[enemy_index].active) {
    return
  }

  let reward = game.enemies[enemy_index].reward
  let hit_x = game.enemies[enemy_index].x
  let hit_y = game.enemies[enemy_index].y
  let hit_r = game.enemies[enemy_index].radius

  game.enemies[enemy_index].active = false
  game.kills = game.kills + 1

  if game.combo_timer > 0.0 {
    game.combo = game.combo + 1
  } else {
    game.combo = 1
  }
  game.combo_timer = combo_window

  let combo_mult = 1 + (game.combo - 1) / combo_score_step
  game.score = game.score + reward * combo_mult

  game.energy = minf(energy_max, game.energy + Float::from_int(reward) * 0.85)

  let combo_for_charge = mini(game.combo, barrier_charge_combo_cap)
  game.barrier_charge = minf(
    barrier_charge_goal,
    game.barrier_charge +
    barrier_charge_kill +
    Float::from_int(combo_for_charge) * barrier_charge_combo,
  )

  emit_pulse(game, hit_x, hit_y, hit_r + 4.0, 0.42, 1)
  if by_barrier {
    emit_pulse(game, hit_x, hit_y, hit_r + 12.0, 0.48, 2)
  }

  if game.combo > 0 && game.combo % 6 == 0 {
    set_status(game, "Combo x" + game.combo.to_string(), 0.5)
  }
}

///|
fn update_nodes(game : Game, dt : Float) -> Unit {
  for i in 0..<game.nodes.length() {
    if not(game.nodes[i].active) {
      continue
    }

    game.nodes[i].pulse = maxf(0.0, game.nodes[i].pulse - dt * 2.8)

    if game.nodes[i].cooldown > 0.0 {
      game.nodes[i].cooldown = game.nodes[i].cooldown - dt
    }
    if game.nodes[i].cooldown > 0.0 {
      continue
    }

    let x = cell_center_x(game.nodes[i].gx)
    let y = cell_center_y(game.nodes[i].gy)
    let range = node_range(game.nodes[i].level)
    let range2 = range * range
    let fx = dir_vec_x(game.nodes[i].facing)
    let fy = dir_vec_y(game.nodes[i].facing)

    let mut best = -1
    let mut best_d2 = range2
    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let dx = game.enemies[j].x - x
      let dy = game.enemies[j].y - y
      let d2 = dx * dx + dy * dy
      if d2 > range2 {
        continue
      }

      let dot = dx * fx + dy * fy
      if dot <= 0.0 {
        continue
      }

      if dot * dot < d2 * node_cone_dot_sq {
        continue
      }

      if d2 < best_d2 {
        best = j
        best_d2 = d2
      }
    }

    if best >= 0 {
      spawn_bolt(
        game,
        x,
        y,
        game.enemies[best].x,
        game.enemies[best].y,
        node_damage(game.nodes[i].level),
      )
      game.nodes[i].cooldown = node_fire_cd(game.nodes[i].level)
      game.nodes[i].pulse = maxf(game.nodes[i].pulse, 0.72)
    }
  }
}

///|
fn update_bolts(game : Game, dt : Float) -> Unit {
  for i in 0..<game.bolts.length() {
    if not(game.bolts[i].active) {
      continue
    }

    game.bolts[i].life = game.bolts[i].life - dt
    if game.bolts[i].life <= 0.0 {
      game.bolts[i].active = false
      continue
    }

    game.bolts[i].x = game.bolts[i].x + game.bolts[i].vx * dt
    game.bolts[i].y = game.bolts[i].y + game.bolts[i].vy * dt

    if game.bolts[i].x < board_left() - 110.0 ||
      game.bolts[i].x > board_right() + 110.0 ||
      game.bolts[i].y < board_top() - 110.0 ||
      game.bolts[i].y > board_bottom() + 110.0 {
      game.bolts[i].active = false
      continue
    }

    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let hit_r = game.enemies[j].radius + bolt_hit_radius
      let hit_r2 = hit_r * hit_r
      if dist2(
          game.bolts[i].x,
          game.bolts[i].y,
          game.enemies[j].x,
          game.enemies[j].y,
        ) <=
        hit_r2 {
        game.enemies[j].hp = game.enemies[j].hp - game.bolts[i].dmg
        game.bolts[i].active = false
        emit_pulse(game, game.bolts[i].x, game.bolts[i].y, 7.0, 0.22, 0)

        if game.enemies[j].hp <= 0.0 {
          kill_enemy(game, j, false)
        }
        break
      }
    }
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  let gx = gate_x()
  let gy = gate_y()

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].phase = game.enemies[i].phase +
      dt * (1.2 + Float::from_int(game.enemies[i].kind) * 0.35)

    let wobble : Float = if game.enemies[i].kind == enemy_kind_wraith {
      28.0
    } else if game.enemies[i].kind == enemy_kind_carapace {
      10.0
    } else {
      16.0
    }

    let tx = gx +
      sinf(game.enemies[i].phase * 1.6 + Float::from_int(i) * 0.13) * wobble
    let ty = gy +
      cosf(game.enemies[i].phase * 1.3 + Float::from_int(i) * 0.11) * wobble

    let dx = tx - game.enemies[i].x
    let dy = ty - game.enemies[i].y
    let d2 = dx * dx + dy * dy

    if d2 > 1.0 {
      let inv = Float::from_int(1) / sqrtf(d2)
      game.enemies[i].vx = dx * inv * game.enemies[i].speed
      game.enemies[i].vy = dy * inv * game.enemies[i].speed
    }

    game.enemies[i].x = game.enemies[i].x + game.enemies[i].vx * dt
    game.enemies[i].y = game.enemies[i].y + game.enemies[i].vy * dt

    let hit_r = gate_hit_radius + game.enemies[i].radius
    if dist2(game.enemies[i].x, game.enemies[i].y, gx, gy) <= hit_r * hit_r {
      game.gate_hp = maxf(0.0, game.gate_hp - game.enemies[i].gate_damage)
      game.enemies[i].active = false
      game.combo = 0
      game.combo_timer = 0.0
      game.shake_t = maxf(game.shake_t, shake_time_hit)
      emit_pulse(game, gx, gy, gate_radius + 18.0, 0.48, 2)

      if game.gate_hp <= 0.0 {
        enter_game_over(game)
        return
      }
    }
  }
}

///|
fn trigger_barrier(game : Game) -> Unit {
  if game.barrier_charge < barrier_charge_goal {
    set_status(game, "Barrier not charged", 0.5)
    return
  }

  game.barrier_charge = 0.0
  game.barrier_flash = barrier_flash_time
  game.shake_t = maxf(game.shake_t, 0.32)

  let gx = gate_x()
  let gy = gate_y()
  let radius2 = barrier_radius * barrier_radius

  emit_pulse(game, gx, gy, gate_radius + 14.0, 0.58, 2)

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let dx = game.enemies[i].x - gx
    let dy = game.enemies[i].y - gy
    let d2 = dx * dx + dy * dy
    if d2 > radius2 {
      continue
    }

    game.enemies[i].hp = game.enemies[i].hp - barrier_damage
    if game.enemies[i].hp <= 0.0 {
      kill_enemy(game, i, true)
      continue
    }

    if d2 > 1.0 {
      let inv = Float::from_int(1) / sqrtf(d2)
      game.enemies[i].x = game.enemies[i].x + dx * inv * barrier_push
      game.enemies[i].y = game.enemies[i].y + dy * inv * barrier_push
      game.enemies[i].vx = game.enemies[i].vx + dx * inv * 80.0
      game.enemies[i].vy = game.enemies[i].vy + dy * inv * 80.0
    }
  }

  set_status(game, "Barrier burst released", 0.7)
}

///|
fn update_pulses(game : Game, dt : Float) -> Unit {
  for i in 0..<game.pulses.length() {
    if not(game.pulses[i].active) {
      continue
    }

    game.pulses[i].life = game.pulses[i].life - dt
    if game.pulses[i].life <= 0.0 {
      game.pulses[i].active = false
      continue
    }

    let speed : Float = if game.pulses[i].kind == 0 {
      66.0
    } else if game.pulses[i].kind == 1 {
      92.0
    } else {
      120.0
    }
    game.pulses[i].radius = game.pulses[i].radius + dt * speed
  }
}

///|
fn decay_overlay_timers(game : Game, dt : Float) -> Unit {
  if game.status_t > 0.0 {
    game.status_t = maxf(0.0, game.status_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - dt)
  }
  if game.barrier_flash > 0.0 {
    game.barrier_flash = maxf(0.0, game.barrier_flash - dt)
  }
}

///|
fn update_title_state(game : Game) -> Unit {
  if game.input_place_press ||
    game.input_barrier_press ||
    game.input_restart_press {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = state_paused
    set_status(game, "Paused", 0.4)
    return
  }

  move_cursor(game)

  if game.input_place_press {
    try_build_or_upgrade(game)
  }
  if game.input_cancel_press {
    try_sell_node(game)
  }
  if game.input_barrier_press {
    trigger_barrier(game)
  }

  game.energy = minf(
    energy_max,
    game.energy + (energy_regen + Float::from_int(game.wave) * 0.22) * dt,
  )

  if game.combo_timer > 0.0 {
    game.combo_timer = game.combo_timer - dt
    if game.combo_timer <= 0.0 {
      game.combo_timer = 0.0
      game.combo = 0
    }
  }

  update_wave_spawner(game, dt)
  update_nodes(game, dt)
  update_bolts(game, dt)
  update_enemies(game, dt)
  update_pulses(game, dt)
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input_pause_press || game.input_cancel_press {
    game.state = state_playing
    set_status(game, "Defense resumed", 0.5)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input_place_press || game.input_restart_press {
    start_new_run(game)
    return
  }

  if game.input_cancel_press {
    clear_enemies(game)
    clear_bolts(game)
    clear_pulses(game)
    game.state = state_title
    game.gate_hp = gate_hp_max
    game.energy = energy_start
    game.barrier_charge = 0.0
    set_status(game, "Press J to begin defense", 0.0)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt

  if game.input_restart_press {
    start_new_run(game)
    return
  }

  if game.state == state_title {
    decay_overlay_timers(game, dt)
    update_pulses(game, dt)
    update_title_state(game)
  } else if game.state == state_playing {
    decay_overlay_timers(game, dt)
    update_playing_state(game, dt)
  } else if game.state == state_paused {
    update_paused_state(game)
  } else {
    decay_overlay_timers(game, dt)
    update_pulses(game, dt)
    update_game_over_state(game)
  }
}
