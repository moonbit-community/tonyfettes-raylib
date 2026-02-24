///|
fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
fn clear_raiders(game : Game) -> Unit {
  for i in 0..<game.raiders.length() {
    game.raiders[i] = Raider::new()
  }
}

///|
fn clear_flames(game : Game) -> Unit {
  for i in 0..<game.flames.length() {
    game.flames[i] = Flame::new()
  }
}

///|
fn clear_breaches(game : Game) -> Unit {
  for i in 0..<game.breaches.length() {
    game.breaches[i].severity = 0.0
    game.breaches[i].raider_cd = randf(0.8, 1.6)
    game.breaches[i].ember_cd = randf(0.7, 1.4)
  }
}

///|
fn reset_keeper(game : Game) -> Unit {
  game.keeper.room = vault_room
  game.keeper.x = chamber_center_x()
  game.keeper.y = chamber_center_y()
  game.keeper.facing_x = 1.0
  game.keeper.facing_y = 0.0
  game.keeper.stamina = keeper_stamina_max
  game.keeper.extinguisher_mode = false
  game.keeper.action_cd = 0.0
  game.keeper.shield_cd = 0.0
  game.keeper.shield_t = 0.0
  game.keeper.ink_shields = ink_shield_stock_start
}

///|
fn raise_breach(game : Game, room : Int, amount : Float) -> Unit {
  let idx = clampi(room, 0, chamber_count - 1)
  game.breaches[idx].severity = clampf(
    game.breaches[idx].severity + amount,
    0.0,
    breach_severity_max,
  )

  if game.breaches[idx].raider_cd <= 0.1 {
    game.breaches[idx].raider_cd = randf(0.25, 0.95)
  }
  if game.breaches[idx].ember_cd <= 0.1 {
    game.breaches[idx].ember_cd = randf(0.35, 1.10)
  }
}

///|
fn start_new_run(game : Game) -> Unit {
  clear_breaches(game)
  clear_raiders(game)
  clear_flames(game)
  reset_keeper(game)

  game.state = state_playing
  game.wave = 1
  game.wave_t = 0.0
  game.wave_goal_t = wave_duration(1)
  game.breach_event_cd = 1.4
  game.scroll_integrity = scroll_integrity_max
  game.seal_charges = seal_charges_start
  game.score = 0
  game.raiders_defeated = 0
  game.flames_cleared = 0
  game.seals_done = 0
  set_message(
    game, "Wave 1 begins. Seal breaches before the archive burns.", 2.4,
  )

  raise_breach(game, vault_room, 26.0)
  raise_breach(game, randi(0, chamber_count - 1), 20.0)
}

///|
fn return_to_title(game : Game) -> Unit {
  clear_breaches(game)
  clear_raiders(game)
  clear_flames(game)
  reset_keeper(game)

  game.state = state_title
  game.wave = 1
  game.wave_t = 0.0
  game.wave_goal_t = wave_duration(1)
  game.breach_event_cd = 1.4
  game.scroll_integrity = scroll_integrity_max
  game.seal_charges = seal_charges_start
  set_message(game, "Press J to begin guarding the dragon scroll vault.", 99.0)
}

///|
fn enter_game_over(game : Game, reason : String) -> Unit {
  if game.state == state_game_over {
    return
  }

  game.state = state_game_over
  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_message(game, reason + " Press J or R to restart.", 99.0)
}

///|
fn alloc_raider(game : Game) -> Int {
  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_flame(game : Game) -> Int {
  for i in 0..<game.flames.length() {
    if not(game.flames[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_raider_from_room(game : Game, room : Int) -> Bool {
  let slot = alloc_raider(game)
  if slot < 0 {
    return false
  }

  let clamped_room = clampi(room, 0, chamber_count - 1)
  let start_x = clampf(
    breach_anchor_x(clamped_room) + randf(-18.0, 18.0),
    chamber_left + 20.0,
    chamber_right() - 20.0,
  )
  let start_y = clampf(
    breach_anchor_y(clamped_room) + randf(-22.0, 22.0),
    chamber_top + 20.0,
    chamber_bottom() - 20.0,
  )
  let wavef = Float::from_int(game.wave - 1)
  let hp = raider_hp_base + wavef * raider_hp_wave_bonus + randf(-6.0, 9.0)

  game.raiders[slot] = {
    active: true,
    room: clamped_room,
    x: start_x,
    y: start_y,
    hp,
    max_hp: hp,
    panic_t: 0.0,
    attack_cd: randf(0.35, 0.95),
  }
  true
}

///|
fn spawn_flame(
  game : Game,
  room : Int,
  x : Float,
  y : Float,
  intensity : Float,
) -> Bool {
  let slot = alloc_flame(game)
  if slot < 0 {
    return false
  }

  let clamped_room = clampi(room, 0, chamber_count - 1)

  game.flames[slot] = {
    active: true,
    room: clamped_room,
    x: clampf(x, chamber_left + 18.0, chamber_right() - 18.0),
    y: clampf(y, chamber_top + 18.0, chamber_bottom() - 18.0),
    intensity: clampf(intensity, 10.0, 120.0),
    spread_cd: randf(0.8, 1.6),
  }
  true
}

///|
fn defeat_raider(game : Game, idx : Int, score_bonus : Int) -> Unit {
  if idx < 0 || idx >= game.raiders.length() || not(game.raiders[idx].active) {
    return
  }

  game.raiders[idx] = Raider::new()
  game.raiders_defeated = game.raiders_defeated + 1
  game.score = game.score + score_bonus
  game.keeper.ink_shields = minf(
    ink_shield_stock_max,
    game.keeper.ink_shields + 0.16,
  )
}

///|
fn nearest_open_breach_index(
  game : Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.breaches.length() {
    if game.breaches[i].room != room || game.breaches[i].severity <= 0.0 {
      continue
    }

    let d2 = dist2(
      x,
      y,
      breach_anchor_x(game.breaches[i].room),
      breach_anchor_y(game.breaches[i].room),
    )
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn nearest_raider_index(
  game : Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) || game.raiders[i].room != room {
      continue
    }

    let d2 = dist2(x, y, game.raiders[i].x, game.raiders[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn nearest_flame_index(
  game : Game,
  room : Int,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.flames.length() {
    if not(game.flames[i].active) || game.flames[i].room != room {
      continue
    }

    let d2 = dist2(x, y, game.flames[i].x, game.flames[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn update_keeper_motion(game : Game, dt : Float) -> Unit {
  let mut speed = keeper_speed
  if game.keeper.extinguisher_mode {
    speed = speed * keeper_mode_speed_scale
  }

  if absf(game.input_x) > 0.01 || absf(game.input_y) > 0.01 {
    game.keeper.facing_x = game.input_x
    game.keeper.facing_y = game.input_y
  }

  let mut next_x = game.keeper.x + game.input_x * speed * dt
  let next_y = clampf(
    game.keeper.y + game.input_y * speed * dt,
    chamber_top + keeper_radius,
    chamber_bottom() - keeper_radius,
  )

  game.keeper.y = next_y

  let left_wall = chamber_left + keeper_radius
  let right_wall = chamber_right() - keeper_radius

  if next_x < left_wall {
    if game.input_x < 0.0 &&
      game.keeper.room > 0 &&
      absf(game.keeper.y - door_center_y) <= door_half_h {
      game.keeper.room = game.keeper.room - 1
      next_x = right_wall - 1.0
      set_message(game, "Entered " + room_name(game.keeper.room), 0.45)
    } else {
      next_x = left_wall
    }
  } else if next_x > right_wall {
    if game.input_x > 0.0 &&
      game.keeper.room < chamber_count - 1 &&
      absf(game.keeper.y - door_center_y) <= door_half_h {
      game.keeper.room = game.keeper.room + 1
      next_x = left_wall + 1.0
      set_message(game, "Entered " + room_name(game.keeper.room), 0.45)
    } else {
      next_x = right_wall
    }
  }

  game.keeper.x = next_x
}

///|
fn update_keeper_timers_and_resources(game : Game, dt : Float) -> Unit {
  if game.keeper.action_cd > 0.0 {
    game.keeper.action_cd = maxf(0.0, game.keeper.action_cd - dt)
  }
  if game.keeper.shield_cd > 0.0 {
    game.keeper.shield_cd = maxf(0.0, game.keeper.shield_cd - dt)
  }
  if game.keeper.shield_t > 0.0 {
    game.keeper.shield_t = maxf(0.0, game.keeper.shield_t - dt)
  }

  let regen = if game.keeper.extinguisher_mode {
    keeper_stamina_regen_mode
  } else {
    keeper_stamina_regen
  }

  game.keeper.stamina = minf(
    keeper_stamina_max,
    game.keeper.stamina + regen * dt,
  )
}

///|
fn toggle_extinguisher_mode(game : Game) -> Unit {
  game.keeper.extinguisher_mode = not(game.keeper.extinguisher_mode)
  if game.keeper.extinguisher_mode {
    set_message(game, "Extinguisher mode active.", 0.7)
  } else {
    set_message(game, "Combat and sealing mode active.", 0.7)
  }
}

///|
fn perform_attack_action(game : Game) -> Unit {
  if game.keeper.stamina < stamina_attack_cost {
    set_message(game, "Stamina too low for a strike.", 0.55)
    return
  }

  let range2 = attack_range * attack_range
  let idx = nearest_raider_index(
    game,
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    set_message(game, "No raider in reach.", 0.45)
    return
  }

  game.keeper.stamina = maxf(0.0, game.keeper.stamina - stamina_attack_cost)
  game.keeper.action_cd = keeper_action_cd

  let damage = attack_damage +
    Float::from_int(game.wave - 1) * attack_damage_wave_bonus
  game.raiders[idx].hp = game.raiders[idx].hp - damage
  game.raiders[idx].panic_t = 0.30
  game.score = game.score + 8

  if game.raiders[idx].hp <= 0.0 {
    defeat_raider(game, idx, 44 + game.wave * 4)
  }
}

///|
fn perform_seal_action(game : Game) -> Unit {
  if game.seal_charges <= 0 {
    set_message(game, "No seal charges left for this wave.", 0.65)
    return
  }
  if game.keeper.stamina < stamina_seal_cost {
    set_message(game, "Stamina too low to inscribe a seal.", 0.6)
    return
  }

  let range2 = attack_range * attack_range
  let idx = nearest_open_breach_index(
    game,
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    set_message(game, "Move closer to a breach to seal it.", 0.5)
    return
  }

  game.seal_charges = game.seal_charges - 1
  game.keeper.stamina = maxf(0.0, game.keeper.stamina - stamina_seal_cost)
  game.keeper.action_cd = keeper_action_cd + 0.05

  let seal_power = breach_seal_power +
    Float::from_int(game.wave - 1) * breach_seal_wave_bonus
  game.breaches[idx].severity = maxf(
    0.0,
    game.breaches[idx].severity - seal_power,
  )
  game.score = game.score + 28

  if game.breaches[idx].severity <= 0.0 {
    game.seals_done = game.seals_done + 1
    game.score = game.score + 90 + game.wave * 10
    game.keeper.ink_shields = minf(
      ink_shield_stock_max,
      game.keeper.ink_shields + 0.45,
    )
    set_message(game, "Breach sealed. Ink shield reserve increased.", 1.0)
  } else {
    set_message(game, "Breach pressure reduced.", 0.55)
  }
}

///|
fn perform_extinguish_action(game : Game) -> Unit {
  if game.keeper.stamina < stamina_extinguish_cost {
    set_message(game, "Stamina too low to use extinguisher.", 0.55)
    return
  }

  let range2 = extinguisher_range * extinguisher_range
  let idx = nearest_flame_index(
    game,
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    range2,
  )

  if idx < 0 {
    set_message(game, "No flame in extinguisher range.", 0.45)
    return
  }

  game.keeper.stamina = maxf(0.0, game.keeper.stamina - stamina_extinguish_cost)
  game.keeper.action_cd = keeper_action_cd
  game.flames[idx].intensity = game.flames[idx].intensity - extinguisher_power
  game.score = game.score + 16

  if game.flames[idx].intensity <= 0.0 {
    game.flames[idx] = Flame::new()
    game.flames_cleared = game.flames_cleared + 1
    game.score = game.score + 36 + game.wave * 3
    set_message(game, "Flame extinguished.", 0.5)
  }
}

///|
fn handle_action_input(game : Game) -> Unit {
  if not(game.input_action_press) || game.keeper.action_cd > 0.0 {
    return
  }

  if game.keeper.extinguisher_mode {
    perform_extinguish_action(game)
    return
  }

  let breach_idx = nearest_open_breach_index(
    game,
    game.keeper.room,
    game.keeper.x,
    game.keeper.y,
    attack_range * attack_range,
  )

  if breach_idx >= 0 && game.seal_charges > 0 {
    perform_seal_action(game)
  } else {
    perform_attack_action(game)
  }
}

///|
fn trigger_ink_shield(game : Game) -> Unit {
  if not(game.input_shield_press) {
    return
  }

  if game.keeper.shield_cd > 0.0 {
    set_message(
      game,
      "Ink burst cooling down " +
      game.keeper.shield_cd.to_int().to_string() +
      "s",
      0.6,
    )
    return
  }

  if game.keeper.ink_shields < 1.0 {
    set_message(game, "No ink shield stock.", 0.5)
    return
  }

  game.keeper.ink_shields = game.keeper.ink_shields - 1.0
  game.keeper.shield_cd = ink_shield_cooldown
  game.keeper.shield_t = ink_shield_duration

  let radius2 = ink_shield_radius * ink_shield_radius
  let mut raider_hits = 0
  let mut flame_hits = 0

  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) || game.raiders[i].room != game.keeper.room {
      continue
    }

    if dist2(game.keeper.x, game.keeper.y, game.raiders[i].x, game.raiders[i].y) >
      radius2 {
      continue
    }

    game.raiders[i].hp = game.raiders[i].hp - ink_shield_damage
    game.raiders[i].panic_t = 1.3
    raider_hits = raider_hits + 1

    if game.raiders[i].hp <= 0.0 {
      defeat_raider(game, i, 30 + game.wave * 3)
    }
  }

  for i in 0..<game.flames.length() {
    if not(game.flames[i].active) || game.flames[i].room != game.keeper.room {
      continue
    }

    if dist2(game.keeper.x, game.keeper.y, game.flames[i].x, game.flames[i].y) >
      radius2 {
      continue
    }

    game.flames[i].intensity = game.flames[i].intensity - ink_shield_fire_quench
    flame_hits = flame_hits + 1

    if game.flames[i].intensity <= 0.0 {
      game.flames[i] = Flame::new()
      game.flames_cleared = game.flames_cleared + 1
      game.score = game.score + 20
    }
  }

  game.scroll_integrity = minf(
    scroll_integrity_max,
    game.scroll_integrity + 3.5,
  )
  game.score = game.score + 18 + raider_hits * 4 + flame_hits * 3
  set_message(game, "Ink shield burst released.", 0.7)
}

///|
fn update_wave_progress(game : Game, dt : Float) -> Unit {
  game.wave_t = game.wave_t + dt

  if game.wave_t < game.wave_goal_t {
    return
  }

  game.wave = game.wave + 1
  game.wave_t = 0.0
  game.wave_goal_t = wave_duration(game.wave)
  game.seal_charges = clampi(
    game.seal_charges + seal_charges_wave_gain,
    0,
    seal_charges_max,
  )
  game.keeper.ink_shields = minf(
    ink_shield_stock_max,
    game.keeper.ink_shields + 1.0,
  )
  game.keeper.stamina = keeper_stamina_max
  game.scroll_integrity = minf(
    scroll_integrity_max,
    game.scroll_integrity + 5.0,
  )
  game.score = game.score +
    140 +
    game.wave * 22 +
    game.scroll_integrity.to_int()

  raise_breach(
    game,
    randi(0, chamber_count - 1),
    34.0 + Float::from_int(game.wave),
  )
  raise_breach(
    game,
    randi(0, chamber_count - 1),
    16.0 + Float::from_int(game.wave),
  )

  set_message(
    game,
    "Wave " + game.wave.to_string() + " surges. Charges replenished.",
    1.4,
  )
}

///|
fn update_breach_system(game : Game, dt : Float) -> Float {
  game.breach_event_cd = game.breach_event_cd - dt

  if game.breach_event_cd <= 0.0 {
    let mut events = 1
    if game.wave >= 6 {
      events = events + 1
    }
    if game.wave >= 12 {
      events = events + 1
    }

    for _i in 0..<events {
      let room = randi(0, chamber_count - 1)
      let pressure = randf(12.0, 25.0) + Float::from_int(game.wave - 1) * 1.6
      raise_breach(game, room, pressure)
    }

    game.breach_event_cd = maxf(
        breach_event_cd_floor,
        breach_event_cd_base - Float::from_int(game.wave - 1) * 0.22,
      ) +
      randf(-0.25, 0.35)
  }

  let mut integrity_loss : Float = 0.0

  for i in 0..<game.breaches.length() {
    let severity = game.breaches[i].severity
    if severity <= 0.0 {
      continue
    }

    let pressure = severity / breach_severity_max
    integrity_loss = integrity_loss + pressure * breach_integrity_drain * dt

    game.breaches[i].severity = clampf(
      severity + Float::from_int(game.wave - 1) * breach_wave_growth * dt,
      0.0,
      breach_severity_max,
    )

    game.breaches[i].raider_cd = game.breaches[i].raider_cd -
      dt * (1.0 + pressure * 0.8)
    if game.breaches[i].raider_cd <= 0.0 {
      ignore(spawn_raider_from_room(game, game.breaches[i].room))
      game.breaches[i].raider_cd = maxf(
        raider_spawn_cd_floor,
        raider_spawn_cd_base -
        Float::from_int(game.wave - 1) * 0.09 -
        pressure * 0.8 +
        randf(-0.08, 0.16),
      )
    }

    game.breaches[i].ember_cd = game.breaches[i].ember_cd -
      dt * (1.0 + pressure * 0.5)
    if game.breaches[i].ember_cd <= 0.0 {
      ignore(
        spawn_flame(
          game,
          game.breaches[i].room,
          breach_anchor_x(game.breaches[i].room) + randf(-26.0, 26.0),
          breach_anchor_y(game.breaches[i].room) + randf(-24.0, 24.0),
          28.0 + pressure * 34.0,
        ),
      )
      game.breaches[i].ember_cd = maxf(
        flame_spawn_cd_floor,
        flame_spawn_cd_base -
        Float::from_int(game.wave - 1) * 0.08 -
        pressure * 0.55 +
        randf(-0.10, 0.20),
      )
    }
  }

  integrity_loss
}

///|
fn update_raiders(game : Game, dt : Float) -> Float {
  let mut integrity_loss : Float = 0.0
  let wavef = Float::from_int(game.wave - 1)
  let speed_base = raider_speed_base + wavef * raider_speed_wave_bonus

  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) {
      continue
    }

    if game.raiders[i].attack_cd > 0.0 {
      game.raiders[i].attack_cd = maxf(0.0, game.raiders[i].attack_cd - dt)
    }
    if game.raiders[i].panic_t > 0.0 {
      game.raiders[i].panic_t = maxf(0.0, game.raiders[i].panic_t - dt)
    }

    let mut goal_x = raider_goal_x(game.raiders[i].room)
    let mut goal_y = raider_goal_y(game.raiders[i].room)
    let mut move_speed = speed_base

    if game.raiders[i].panic_t > 0.0 && game.raiders[i].room == game.keeper.room {
      goal_x = game.raiders[i].x + (game.raiders[i].x - game.keeper.x)
      goal_y = game.raiders[i].y + (game.raiders[i].y - game.keeper.y)
      move_speed = move_speed * 1.25
    }

    let dx = goal_x - game.raiders[i].x
    let dy = goal_y - game.raiders[i].y
    let d2 = dx * dx + dy * dy

    if d2 > 0.01 {
      let inv : Float = Float::from_int(1) / sqrtf(d2)
      game.raiders[i].x = game.raiders[i].x + dx * inv * move_speed * dt
      game.raiders[i].y = game.raiders[i].y + dy * inv * move_speed * dt
    }

    game.raiders[i].x = clampf(
      game.raiders[i].x,
      chamber_left + raider_radius,
      chamber_right() - raider_radius,
    )
    game.raiders[i].y = clampf(
      game.raiders[i].y,
      chamber_top + raider_radius,
      chamber_bottom() - raider_radius,
    )

    if game.raiders[i].room < vault_room &&
      game.raiders[i].x >= chamber_right() - 10.0 &&
      absf(game.raiders[i].y - door_center_y) <= door_half_h {
      game.raiders[i].room = game.raiders[i].room + 1
      game.raiders[i].x = chamber_left + 12.0
    } else if game.raiders[i].room > vault_room &&
      game.raiders[i].x <= chamber_left + 10.0 &&
      absf(game.raiders[i].y - door_center_y) <= door_half_h {
      game.raiders[i].room = game.raiders[i].room - 1
      game.raiders[i].x = chamber_right() - 12.0
    }

    if game.raiders[i].room == vault_room &&
      dist2(
        game.raiders[i].x,
        game.raiders[i].y,
        vault_core_x(),
        vault_core_y(),
      ) <=
      52.0 * 52.0 &&
      game.raiders[i].attack_cd <= 0.0 {
      integrity_loss = integrity_loss + raider_vault_strike + wavef * 0.45
      game.raiders[i].attack_cd = randf(0.68, 1.14)
    }

    if game.raiders[i].room == game.keeper.room &&
      dist2(game.raiders[i].x, game.raiders[i].y, game.keeper.x, game.keeper.y) <=
      (keeper_radius + raider_radius + 4.0) *
      (keeper_radius + raider_radius + 4.0) &&
      game.raiders[i].attack_cd <= 0.0 {
      game.keeper.stamina = maxf(
        0.0,
        game.keeper.stamina - raider_keeper_stamina_hit,
      )
      integrity_loss = integrity_loss + 0.7
      game.raiders[i].attack_cd = 0.9
    }
  }

  integrity_loss
}

///|
fn update_flames(game : Game, dt : Float) -> Float {
  let mut integrity_loss : Float = 0.0

  for i in 0..<game.flames.length() {
    if not(game.flames[i].active) {
      continue
    }

    game.flames[i].intensity = maxf(
      0.0,
      game.flames[i].intensity - flame_decay * dt,
    )
    if game.flames[i].intensity <= 0.5 {
      game.flames[i] = Flame::new()
      continue
    }

    let room = game.flames[i].room
    let room_mul = if room == vault_room {
      flame_integrity_vault_mul
    } else {
      flame_integrity_side_mul
    }
    integrity_loss = integrity_loss + game.flames[i].intensity * room_mul * dt

    game.breaches[room].severity = clampf(
      game.breaches[room].severity +
      game.flames[i].intensity * flame_breach_feed * dt,
      0.0,
      breach_severity_max,
    )

    game.flames[i].spread_cd = game.flames[i].spread_cd -
      dt * (1.0 + Float::from_int(game.wave - 1) * 0.04)

    if game.flames[i].spread_cd <= 0.0 {
      if game.flames[i].intensity >= 16.0 {
        ignore(
          spawn_flame(
            game,
            room,
            game.flames[i].x + randf(-54.0, 54.0),
            game.flames[i].y + randf(-42.0, 42.0),
            game.flames[i].intensity * 0.58,
          ),
        )
      }

      game.flames[i].spread_cd = maxf(
        flame_spread_cd_floor,
        flame_spread_cd_base -
        Float::from_int(game.wave - 1) * 0.08 +
        randf(-0.18, 0.24),
      )
    }
  }

  integrity_loss
}

///|
fn update_title_state(game : Game) -> Unit {
  if game.input_action_press ||
    game.input_shield_press ||
    game.input_restart_press {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = state_paused
    set_message(game, "Paused. P to resume, K for title.", 99.0)
    return
  }

  if game.input_cancel_press {
    toggle_extinguisher_mode(game)
  }

  update_keeper_timers_and_resources(game, dt)
  update_keeper_motion(game, dt)
  trigger_ink_shield(game)
  handle_action_input(game)

  update_wave_progress(game, dt)

  let mut integrity_loss : Float = 0.0
  integrity_loss = integrity_loss + update_breach_system(game, dt)
  integrity_loss = integrity_loss + update_raiders(game, dt)
  integrity_loss = integrity_loss + update_flames(game, dt)

  if game.keeper.shield_t > 0.0 {
    integrity_loss = integrity_loss *
      (Float::from_int(1) - ink_shield_integrity_block)
  }

  game.scroll_integrity = maxf(0.0, game.scroll_integrity - integrity_loss)

  if game.scroll_integrity <= 0.0 {
    enter_game_over(game, "The dragon scroll archive was lost.")
  }
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input_pause_press {
    game.state = state_playing
    set_message(game, "Defense resumed.", 0.8)
    return
  }

  if game.input_cancel_press {
    return_to_title(game)
    return
  }

  if game.input_action_press || game.input_restart_press {
    start_new_run(game)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input_action_press || game.input_restart_press {
    start_new_run(game)
    return
  }

  if game.input_cancel_press {
    return_to_title(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  let step = clampf(dt, 0.0, 0.05)
  game.time_s = game.time_s + step

  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - step)
  }

  if game.state == state_title {
    update_title_state(game)
  } else if game.state == state_playing {
    update_playing_state(game, step)
  } else if game.state == state_paused {
    update_paused_state(game)
  } else {
    update_game_over_state(game)
  }
}
