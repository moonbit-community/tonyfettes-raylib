///|
fn set_status(game : @types.Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn clear_nodes(game : @types.Game) -> Unit {
  for i in 0..<game.nodes.length() {
    game.nodes[i] = @types.Node::new()
  }
}

///|
fn clear_enemies(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Enemy::new()
  }
}

///|
fn clear_bolts(game : @types.Game) -> Unit {
  for i in 0..<game.bolts.length() {
    game.bolts[i] = @types.Bolt::new()
  }
}

///|
fn clear_pulses(game : @types.Game) -> Unit {
  for i in 0..<game.pulses.length() {
    game.pulses[i] = @types.PulseFx::new()
  }
}

///|
fn alloc_node(game : @types.Game) -> Int {
  for i in 0..<game.nodes.length() {
    if not(game.nodes[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_enemy(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_bolt(game : @types.Game) -> Int {
  for i in 0..<game.bolts.length() {
    if not(game.bolts[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_pulse(game : @types.Game) -> Int {
  for i in 0..<game.pulses.length() {
    if not(game.pulses[i].active) {
      return i
    }
  }
  -1
}

///|
fn emit_pulse(
  game : @types.Game,
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
fn active_enemy_count(game : @types.Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count = count + 1
    }
  }
  count
}

///|
fn begin_next_wave(game : @types.Game) -> Unit {
  game.wave = game.wave + 1
  game.pending_spawns = @types.wave_spawn_count(game.wave)
  game.spawn_cd = 0.35
  game.wave_delay = @types.wave_intro_delay
  game.energy = @types.minf(
    @types.energy_max,
    game.energy + @types.wave_energy_bonus + Float::from_int(game.wave) * 1.5,
  )
  set_status(game, "Wave " + game.wave.to_string() + " incoming", 1.5)
}

///|
fn start_new_run(game : @types.Game) -> Unit {
  clear_nodes(game)
  clear_enemies(game)
  clear_bolts(game)
  clear_pulses(game)

  game.state = @types.state_playing
  game.score = 0
  game.kills = 0
  game.wave = 0
  game.pending_spawns = 0
  game.spawn_cd = 0.0
  game.wave_delay = 0.0
  game.gate_hp = @types.gate_hp_max
  game.energy = @types.energy_start
  game.barrier_charge = 0.0
  game.barrier_flash = 0.0
  game.combo = 0
  game.combo_timer = 0.0
  game.shake_t = 0.0
  game.cursor_x = @types.gate_gx + 1
  game.cursor_y = @types.gate_gy
  game.cursor_dir = @types.dir_left

  set_status(game, "Deploy guardians and hold the moon gate", 1.7)
  begin_next_wave(game)
}

///|
fn enter_game_over(game : @types.Game) -> Unit {
  if game.state == @types.state_game_over {
    return
  }

  game.state = @types.state_game_over
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
fn find_node_at(game : @types.Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.nodes.length() {
    if game.nodes[i].active && game.nodes[i].gx == gx && game.nodes[i].gy == gy {
      return i
    }
  }
  -1
}

///|
fn move_cursor(game : @types.Game) -> Unit {
  if game.input_move_x < 0 {
    game.cursor_x = @types.clampi(game.cursor_x - 1, 0, @types.grid_cols - 1)
    game.cursor_dir = @types.dir_left
  } else if game.input_move_x > 0 {
    game.cursor_x = @types.clampi(game.cursor_x + 1, 0, @types.grid_cols - 1)
    game.cursor_dir = @types.dir_right
  }

  if game.input_move_y < 0 {
    game.cursor_y = @types.clampi(game.cursor_y - 1, 0, @types.grid_rows - 1)
    game.cursor_dir = @types.dir_up
  } else if game.input_move_y > 0 {
    game.cursor_y = @types.clampi(game.cursor_y + 1, 0, @types.grid_rows - 1)
    game.cursor_dir = @types.dir_down
  }
}

///|
fn try_build_or_upgrade(game : @types.Game) -> Unit {
  let gx = game.cursor_x
  let gy = game.cursor_y

  if @types.is_gate_cell(gx, gy) {
    set_status(game, "Gate tile reserved", 0.5)
    return
  }

  let node_index = find_node_at(game, gx, gy)
  if node_index < 0 {
    if game.energy < @types.node_build_cost {
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

    game.energy = game.energy - @types.node_build_cost
    emit_pulse(
      game,
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      14.0,
      0.38,
      0,
    )
    set_status(game, "Guardian deployed", 0.5)
    return
  }

  if game.nodes[node_index].facing != game.cursor_dir {
    game.nodes[node_index].facing = game.cursor_dir
    game.nodes[node_index].pulse = 0.6
    emit_pulse(
      game,
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      12.0,
      0.24,
      0,
    )
    return
  }

  if game.nodes[node_index].level < @types.node_max_level {
    let next_level = game.nodes[node_index].level + 1
    let upgrade_cost = @types.node_upgrade_cost(next_level)

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
    game.nodes[node_index].cooldown = @types.minf(
      game.nodes[node_index].cooldown,
      0.1,
    )
    emit_pulse(
      game,
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      16.0,
      0.42,
      1,
    )
    set_status(game, "Node upgraded to L" + next_level.to_string(), 0.7)
    return
  }

  game.nodes[node_index].facing = (game.nodes[node_index].facing + 1) % 4
  game.nodes[node_index].pulse = 0.45
}

///|
fn try_sell_node(game : @types.Game) -> Unit {
  let node_index = find_node_at(game, game.cursor_x, game.cursor_y)
  if node_index < 0 {
    set_status(game, "No node on this tile", 0.5)
    return
  }

  let refund = @types.node_sell_refund(game.nodes[node_index].level)
  game.energy = @types.minf(@types.energy_max, game.energy + refund)
  game.nodes[node_index] = @types.Node::new()

  emit_pulse(
    game,
    @types.cell_center_x(game.cursor_x),
    @types.cell_center_y(game.cursor_y),
    20.0,
    0.45,
    2,
  )
  set_status(game, "Salvaged +" + refund.to_int().to_string(), 0.55)
}

///|
fn spawn_enemy(game : @types.Game) -> Bool {
  let slot = alloc_enemy(game)
  if slot < 0 {
    return false
  }

  let side = @types.randi(0, 3)
  let mut x : Float = 0.0
  let mut y : Float = 0.0
  if side == 0 {
    x = @types.randf(@types.board_left() + 10.0, @types.board_right() - 10.0)
    y = @types.board_top() - 42.0
  } else if side == 1 {
    x = @types.board_right() + 42.0
    y = @types.randf(@types.board_top() + 10.0, @types.board_bottom() - 10.0)
  } else if side == 2 {
    x = @types.randf(@types.board_left() + 10.0, @types.board_right() - 10.0)
    y = @types.board_bottom() + 42.0
  } else {
    x = @types.board_left() - 42.0
    y = @types.randf(@types.board_top() + 10.0, @types.board_bottom() - 10.0)
  }

  let mut kind = @types.enemy_kind_skitter
  let roll = @types.randi(0, 99)
  let heavy_cut = 12 + @types.mini(26, game.wave * 3)
  let wraith_cut = 72 - @types.mini(22, game.wave * 2)

  if roll < heavy_cut {
    kind = @types.enemy_kind_carapace
  } else if roll >= wraith_cut {
    kind = @types.enemy_kind_wraith
  }

  let wavef = Float::from_int(game.wave - 1)
  let base_hp = @types.enemy_base_hp +
    wavef * @types.enemy_hp_per_wave +
    @types.randf(-2.0, 4.0)
  let base_speed = @types.enemy_base_speed +
    @types.minf(100.0, wavef * @types.enemy_speed_per_wave)

  let mut hp = base_hp
  let mut speed = base_speed
  let mut radius : Float = 12.0
  let mut reward = 8 + game.wave / 2
  let mut gate_damage = @types.enemy_contact_damage_base +
    wavef * @types.enemy_contact_damage_wave

  if kind == @types.enemy_kind_carapace {
    hp = base_hp * 1.85
    speed = base_speed * 0.78
    radius = 17.0
    reward = 14 + game.wave
    gate_damage = @types.enemy_contact_damage_base * 1.45 +
      wavef * @types.enemy_contact_damage_wave
  } else if kind == @types.enemy_kind_wraith {
    hp = base_hp * 1.15
    speed = base_speed * 1.08
    radius = 13.0
    reward = 11 + game.wave
    gate_damage = @types.enemy_contact_damage_base * 1.05 +
      wavef * @types.enemy_contact_damage_wave * 0.9
  } else {
    hp = base_hp * 0.84
    speed = base_speed * 1.28
    radius = 10.0
    reward = 8 + game.wave / 2
    gate_damage = @types.enemy_contact_damage_base * 0.75 +
      wavef * @types.enemy_contact_damage_wave * 0.7
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
    phase: @types.randf(0.0, 6.283),
  }

  true
}

///|
fn update_wave_spawner(game : @types.Game, dt : Float) -> Unit {
  if game.wave_delay > 0.0 {
    game.wave_delay = @types.maxf(0.0, game.wave_delay - dt)
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
      game.spawn_cd = @types.wave_spawn_cd(game.wave)
    }
    return
  }

  if active_enemy_count(game) == 0 {
    begin_next_wave(game)
  }
}

///|
fn spawn_bolt(
  game : @types.Game,
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

  let inv = Float::from_int(1) / @types.sqrtf(d2)
  game.bolts[slot] = {
    active: true,
    x,
    y,
    vx: dx * inv * @types.node_projectile_speed,
    vy: dy * inv * @types.node_projectile_speed,
    life: @types.bolt_life,
    dmg,
  }
}

///|
fn kill_enemy(game : @types.Game, enemy_index : Int, by_barrier : Bool) -> Unit {
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
  game.combo_timer = @types.combo_window

  let combo_mult = 1 + (game.combo - 1) / @types.combo_score_step
  game.score = game.score + reward * combo_mult

  game.energy = @types.minf(
    @types.energy_max,
    game.energy + Float::from_int(reward) * 0.85,
  )

  let combo_for_charge = @types.mini(
    game.combo,
    @types.barrier_charge_combo_cap,
  )
  game.barrier_charge = @types.minf(
    @types.barrier_charge_goal,
    game.barrier_charge +
    @types.barrier_charge_kill +
    Float::from_int(combo_for_charge) * @types.barrier_charge_combo,
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
fn update_nodes(game : @types.Game, dt : Float) -> Unit {
  for node in game.nodes {
    if not(node.active) {
      continue
    }

    node.pulse = @types.maxf(0.0, node.pulse - dt * 2.8)

    if node.cooldown > 0.0 {
      node.cooldown = node.cooldown - dt
    }
    if node.cooldown > 0.0 {
      continue
    }

    let x = @types.cell_center_x(node.gx)
    let y = @types.cell_center_y(node.gy)
    let range = @types.node_range(node.level)
    let range2 = range * range
    let fx = @types.dir_vec_x(node.facing)
    let fy = @types.dir_vec_y(node.facing)

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

      if dot * dot < d2 * @types.node_cone_dot_sq {
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
        @types.node_damage(node.level),
      )
      node.cooldown = @types.node_fire_cd(node.level)
      node.pulse = @types.maxf(node.pulse, 0.72)
    }
  }
}

///|
fn update_bolts(game : @types.Game, dt : Float) -> Unit {
  for bolt in game.bolts {
    if not(bolt.active) {
      continue
    }

    bolt.life = bolt.life - dt
    if bolt.life <= 0.0 {
      bolt.active = false
      continue
    }

    bolt.x = bolt.x + bolt.vx * dt
    bolt.y = bolt.y + bolt.vy * dt

    if bolt.x < @types.board_left() - 110.0 ||
      bolt.x > @types.board_right() + 110.0 ||
      bolt.y < @types.board_top() - 110.0 ||
      bolt.y > @types.board_bottom() + 110.0 {
      bolt.active = false
      continue
    }

    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let hit_r = game.enemies[j].radius + @types.bolt_hit_radius
      let hit_r2 = hit_r * hit_r
      if @types.dist2(bolt.x, bolt.y, game.enemies[j].x, game.enemies[j].y) <=
        hit_r2 {
        game.enemies[j].hp = game.enemies[j].hp - bolt.dmg
        bolt.active = false
        emit_pulse(game, bolt.x, bolt.y, 7.0, 0.22, 0)

        if game.enemies[j].hp <= 0.0 {
          kill_enemy(game, j, false)
        }
        break
      }
    }
  }
}

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let gx = @types.gate_x()
  let gy = @types.gate_y()

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].phase = game.enemies[i].phase +
      dt * (1.2 + Float::from_int(game.enemies[i].kind) * 0.35)

    let wobble : Float = if game.enemies[i].kind == @types.enemy_kind_wraith {
      28.0
    } else if game.enemies[i].kind == @types.enemy_kind_carapace {
      10.0
    } else {
      16.0
    }

    let tx = gx +
      @types.sinf(game.enemies[i].phase * 1.6 + Float::from_int(i) * 0.13) *
      wobble
    let ty = gy +
      @types.cosf(game.enemies[i].phase * 1.3 + Float::from_int(i) * 0.11) *
      wobble

    let dx = tx - game.enemies[i].x
    let dy = ty - game.enemies[i].y
    let d2 = dx * dx + dy * dy

    if d2 > 1.0 {
      let inv = Float::from_int(1) / @types.sqrtf(d2)
      game.enemies[i].vx = dx * inv * game.enemies[i].speed
      game.enemies[i].vy = dy * inv * game.enemies[i].speed
    }

    game.enemies[i].x = game.enemies[i].x + game.enemies[i].vx * dt
    game.enemies[i].y = game.enemies[i].y + game.enemies[i].vy * dt

    let hit_r = @types.gate_hit_radius + game.enemies[i].radius
    if @types.dist2(game.enemies[i].x, game.enemies[i].y, gx, gy) <=
      hit_r * hit_r {
      game.gate_hp = @types.maxf(
        0.0,
        game.gate_hp - game.enemies[i].gate_damage,
      )
      game.enemies[i].active = false
      game.combo = 0
      game.combo_timer = 0.0
      game.shake_t = @types.maxf(game.shake_t, @types.shake_time_hit)
      emit_pulse(game, gx, gy, @types.gate_radius + 18.0, 0.48, 2)

      if game.gate_hp <= 0.0 {
        enter_game_over(game)
        return
      }
    }
  }
}

///|
fn trigger_barrier(game : @types.Game) -> Unit {
  if game.barrier_charge < @types.barrier_charge_goal {
    set_status(game, "Barrier not charged", 0.5)
    return
  }

  game.barrier_charge = 0.0
  game.barrier_flash = @types.barrier_flash_time
  game.shake_t = @types.maxf(game.shake_t, 0.32)

  let gx = @types.gate_x()
  let gy = @types.gate_y()
  let radius2 = @types.barrier_radius * @types.barrier_radius

  emit_pulse(game, gx, gy, @types.gate_radius + 14.0, 0.58, 2)

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

    game.enemies[i].hp = game.enemies[i].hp - @types.barrier_damage
    if game.enemies[i].hp <= 0.0 {
      kill_enemy(game, i, true)
      continue
    }

    if d2 > 1.0 {
      let inv = Float::from_int(1) / @types.sqrtf(d2)
      game.enemies[i].x = game.enemies[i].x + dx * inv * @types.barrier_push
      game.enemies[i].y = game.enemies[i].y + dy * inv * @types.barrier_push
      game.enemies[i].vx = game.enemies[i].vx + dx * inv * 80.0
      game.enemies[i].vy = game.enemies[i].vy + dy * inv * 80.0
    }
  }

  set_status(game, "Barrier burst released", 0.7)
}

///|
fn update_pulses(game : @types.Game, dt : Float) -> Unit {
  for pulse in game.pulses {
    if not(pulse.active) {
      continue
    }

    pulse.life = pulse.life - dt
    if pulse.life <= 0.0 {
      pulse.active = false
      continue
    }

    let speed : Float = if pulse.kind == 0 {
      66.0
    } else if pulse.kind == 1 {
      92.0
    } else {
      120.0
    }
    pulse.radius = pulse.radius + dt * speed
  }
}

///|
fn decay_overlay_timers(game : @types.Game, dt : Float) -> Unit {
  if game.status_t > 0.0 {
    game.status_t = @types.maxf(0.0, game.status_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - dt)
  }
  if game.barrier_flash > 0.0 {
    game.barrier_flash = @types.maxf(0.0, game.barrier_flash - dt)
  }
}

///|
fn update_title_state(game : @types.Game) -> Unit {
  if game.input_place_press ||
    game.input_barrier_press ||
    game.input_restart_press {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = @types.state_paused
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

  game.energy = @types.minf(
    @types.energy_max,
    game.energy + (@types.energy_regen + Float::from_int(game.wave) * 0.22) * dt,
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
fn update_paused_state(game : @types.Game) -> Unit {
  if game.input_pause_press || game.input_cancel_press {
    game.state = @types.state_playing
    set_status(game, "Defense resumed", 0.5)
  }
}

///|
fn update_game_over_state(game : @types.Game) -> Unit {
  if game.input_place_press || game.input_restart_press {
    start_new_run(game)
    return
  }

  if game.input_cancel_press {
    clear_enemies(game)
    clear_bolts(game)
    clear_pulses(game)
    game.state = @types.state_title
    game.gate_hp = @types.gate_hp_max
    game.energy = @types.energy_start
    game.barrier_charge = 0.0
    set_status(game, "Press J to begin defense", 0.0)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)
  game.time_s = game.time_s + dt

  if game.input_restart_press {
    start_new_run(game)
    return
  }

  if game.state == @types.state_title {
    decay_overlay_timers(game, dt)
    update_pulses(game, dt)
    update_title_state(game)
  } else if game.state == @types.state_playing {
    decay_overlay_timers(game, dt)
    update_playing_state(game, dt)
  } else if game.state == @types.state_paused {
    update_paused_state(game)
  } else {
    decay_overlay_timers(game, dt)
    update_pulses(game, dt)
    update_game_over_state(game)
  }
}
