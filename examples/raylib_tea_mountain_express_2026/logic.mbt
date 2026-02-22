///|
fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
fn clear_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i].active = false
    game.hazards[i].lane = 0
    game.hazards[i].y = 0.0
    game.hazards[i].speed = 0.0
    game.hazards[i].size = 0.0
    game.hazards[i].kind = hazard_rock
    game.hazards[i].near_miss_awarded = false
  }
}

///|
fn reset_run(game : Game) -> Unit {
  clear_hazards(game)

  game.state = state_playing
  game.lane = lane_count / 2
  game.tilt = 0.0
  game.speed = speed_base
  game.distance = 0.0
  game.next_checkpoint_distance = checkpoint_segment_distance(1)
  game.checkpoint_index = 1
  game.schedule_s = checkpoint_time_limit(1)
  game.cargo_quality = 100.0
  game.durability = 100.0
  game.reputation = 100.0
  game.multiplier = 1
  game.score = 0
  game.successful_deliveries = 0
  game.failed_deliveries = 0
  game.boost_cd = 0.0
  game.boost_heat = 0.0
  game.boost_timer = 0.0
  game.hazard_spawn_t = 0.75
  game.world_t = 0.0
  game.near_miss_combo = 0

  game.lane_x = lane_center_x(game.world_t, game.lane, cart_y)

  set_message(
    game, "Caravan dispatched. Keep cargo steady across the pass.", 2.2,
  )
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

  set_message(game, reason, 4.5)
}

///|
fn alloc_hazard_slot(game : Game) -> Int {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut farthest_y = game.hazards[0].y
  for i = 1; i < game.hazards.length(); i = i + 1 {
    if game.hazards[i].y > farthest_y {
      farthest_y = game.hazards[i].y
      best = i
    }
  }
  best
}

///|
fn spawn_hazard(game : Game) -> Unit {
  let slot = alloc_hazard_slot(game)
  let roll = randi(0, 99)
  let kind = if roll < 45 {
    hazard_rock
  } else if roll < 79 {
    hazard_landslide
  } else {
    hazard_crosswind
  }

  let mut lane = randi(0, lane_count - 1)
  if randi(0, 99) < 34 {
    let lane_offset = randi(0, 2) - 1
    lane = clampi(game.lane + lane_offset, 0, lane_count - 1)
  }

  let difficulty = Float::from_int(game.checkpoint_index - 1)
  game.hazards[slot].active = true
  game.hazards[slot].lane = lane
  game.hazards[slot].y = Float::from_int(road_top_y_i) - randf(90.0, 280.0)
  game.hazards[slot].speed = randf(210.0, 340.0) + difficulty * 13.0
  game.hazards[slot].size = if kind == hazard_rock {
    randf(26.0, 40.0)
  } else if kind == hazard_landslide {
    randf(30.0, 46.0)
  } else {
    randf(22.0, 34.0)
  }
  game.hazards[slot].kind = kind
  game.hazards[slot].near_miss_awarded = false
}

///|
fn handle_hazard_collision(game : Game, i : Int) -> Unit {
  let kind = game.hazards[i].kind
  let tilt_gap = absf(game.tilt - hazard_tilt_bias(kind))

  let tilt_scale : Float = if tilt_gap < 0.36 {
    0.64
  } else if tilt_gap < 0.72 {
    0.9
  } else {
    1.24
  }

  let stabilize_scale : Float = if game.input_stabilize_hold {
    0.76
  } else {
    1.0
  }
  let heat_scale : Float = 1.0 + maxf(0.0, game.boost_heat - 70.0) * 0.01

  let durability_loss = hazard_durability_hit(kind) *
    tilt_scale *
    stabilize_scale *
    heat_scale
  let cargo_loss = hazard_cargo_hit(kind) *
    tilt_scale *
    stabilize_scale *
    heat_scale

  game.durability = game.durability - durability_loss
  game.cargo_quality = game.cargo_quality - cargo_loss
  game.reputation = game.reputation - (1.4 + durability_loss * 0.16)

  let penalty = (durability_loss * 4.0 + cargo_loss * 3.0).to_int()
  game.score = clampi(game.score - penalty, 0, 2000000000)
  game.near_miss_combo = 0

  game.hazards[i].active = false

  set_message(
    game,
    "Impact from " + hazard_name(kind) + ". Use K and tilt to absorb shock.",
    1.5,
  )
}

///|
fn update_hazards(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    game.hazards[i].y = game.hazards[i].y +
      (game.hazards[i].speed + game.speed * 0.72) * dt

    if game.hazards[i].y > Float::from_int(screen_h) + 130.0 {
      game.hazards[i].active = false
      continue
    }

    if game.hazards[i].lane == game.lane &&
      not(game.hazards[i].near_miss_awarded) &&
      game.hazards[i].y > cart_y + hazard_pass_window {
      game.hazards[i].near_miss_awarded = true
      game.near_miss_combo = game.near_miss_combo + 1
      game.score = game.score + (8 + game.near_miss_combo * 3) * game.multiplier
    }

    if game.hazards[i].lane == game.lane &&
      absf(game.hazards[i].y - cart_y) <= hazard_collision_window {
      handle_hazard_collision(game, i)
    }
  }
}

///|
fn resolve_checkpoint(game : Game) -> Unit {
  let on_time = game.schedule_s > 0.0
  let quality_ready = game.cargo_quality >= delivery_quality_floor
  let durability_ready = game.durability >= delivery_durability_floor

  if on_time && quality_ready && durability_ready {
    game.successful_deliveries = game.successful_deliveries + 1
    game.multiplier = clampi(game.multiplier + 1, 1, delivery_multiplier_max)

    let schedule_bonus = clamp01(
      game.schedule_s / checkpoint_time_limit(game.checkpoint_index),
    )
    let quality_bonus = clamp01(game.cargo_quality / 100.0)
    let durability_bonus = clamp01(game.durability / 100.0)

    let base_points = Float::from_int(delivery_score_base) +
      schedule_bonus * 130.0 +
      quality_bonus * 105.0 +
      durability_bonus * 70.0

    game.score = game.score + base_points.to_int() * game.multiplier
    game.reputation = minf(
      100.0,
      game.reputation + delivery_reputation_gain + schedule_bonus * 2.8,
    )

    set_message(
      game,
      "Delivery secured. Multiplier x" + game.multiplier.to_string() + ".",
      2.0,
    )
  } else {
    game.failed_deliveries = game.failed_deliveries + 1
    game.multiplier = 1

    let mut rep_loss = delivery_reputation_loss_base
    if not(on_time) {
      rep_loss = rep_loss + delivery_reputation_loss_late
    }
    if not(quality_ready) {
      rep_loss = rep_loss + delivery_reputation_loss_quality
    }
    if not(durability_ready) {
      rep_loss = rep_loss + delivery_reputation_loss_durability
    }

    game.reputation = game.reputation - rep_loss
    game.score = clampi(game.score - 120, 0, 2000000000)
    game.near_miss_combo = 0

    let mut reason = "Contract penalty:"
    if not(on_time) {
      reason = reason + " late"
    }
    if not(quality_ready) {
      reason = reason + " poor tea"
    }
    if not(durability_ready) {
      reason = reason + " damaged cart"
    }

    set_message(game, reason, 2.3)
  }

  game.checkpoint_index = game.checkpoint_index + 1
  game.next_checkpoint_distance = game.next_checkpoint_distance +
    checkpoint_segment_distance(game.checkpoint_index)
  game.schedule_s = checkpoint_time_limit(game.checkpoint_index)

  game.cargo_quality = game.cargo_quality - 2.2
  game.durability = game.durability - 1.6
}

///|
fn update_playing(game : Game, dt : Float) -> Unit {
  if game.input_steer != 0 {
    game.lane = clampi(game.lane + game.input_steer, 0, lane_count - 1)
  }

  let lane_target = lane_center_x(game.world_t, game.lane, cart_y)
  let lane_blend = clamp01(lane_follow_speed * dt)
  game.lane_x = game.lane_x + (lane_target - game.lane_x) * lane_blend

  let tilt_target = Float::from_int(game.input_tilt)
  let tilt_speed = if game.input_stabilize_hold {
    tilt_follow_speed * 1.4
  } else {
    tilt_follow_speed
  }
  game.tilt = game.tilt + (tilt_target - game.tilt) * clamp01(tilt_speed * dt)

  if game.input_stabilize_hold {
    game.tilt = game.tilt * (1.0 - clampf(stabilize_wobble_damp * dt, 0.0, 0.9))
  } else {
    let wobble = sinf(
        game.world_t * 6.4 + Float::from_int(game.checkpoint_index) * 0.67,
      ) *
      route_wobble_strength
    game.tilt = clampf(game.tilt + wobble * dt, -1.25, 1.25)
  }

  if game.input_brake_press {
    game.speed = game.speed - brake_force * dt
    game.boost_timer = 0.0
    game.boost_heat = maxf(0.0, game.boost_heat - 10.0)
    game.schedule_s = game.schedule_s - 0.2
  }

  if game.input_boost_press {
    if game.boost_cd <= 0.0 && game.boost_heat < boost_heat_start_limit {
      game.boost_timer = boost_duration
      game.boost_cd = boost_cooldown
      set_message(game, "Booster fired.", 0.8)
    } else if game.boost_heat >= boost_heat_start_limit {
      set_message(game, "Boost locked: boiler overheated.", 0.9)
    }
  }

  let prev_heat = game.boost_heat

  let mut accel = cruise_accel
  if game.input_stabilize_hold {
    accel = accel - stabilize_speed_penalty
  }

  if game.boost_timer > 0.0 {
    game.boost_timer = maxf(0.0, game.boost_timer - dt)
    accel = accel + boost_accel
    game.boost_heat = game.boost_heat + boost_heat_gain * dt
  } else {
    game.boost_heat = maxf(0.0, game.boost_heat - boost_heat_cool_idle * dt)
  }

  if game.input_stabilize_hold {
    game.boost_heat = maxf(
      0.0,
      game.boost_heat - boost_heat_cool_stabilize * dt,
    )
  }

  if game.boost_cd > 0.0 {
    game.boost_cd = maxf(0.0, game.boost_cd - dt)
  }

  game.speed = game.speed + accel * dt
  game.speed = game.speed - game.speed * natural_drag * dt
  game.speed = clampf(game.speed, speed_min, speed_max + 120.0)

  if game.boost_heat > boost_heat_critical {
    let excess = game.boost_heat - boost_heat_critical
    game.durability = game.durability -
      (overheat_durability_dps + excess * 0.16) * dt
    game.cargo_quality = game.cargo_quality -
      (overheat_cargo_dps + excess * 0.14) * dt
    game.reputation = game.reputation -
      (overheat_reputation_dps + excess * 0.05) * dt
  }

  if prev_heat <= boost_heat_critical && game.boost_heat > boost_heat_critical {
    set_message(game, "Boiler overheat! brake or stabilize now.", 1.2)
  }

  let speed_factor = game.speed / speed_max
  let tilt_factor : Float = 0.65 + absf(game.tilt)

  game.cargo_quality = game.cargo_quality -
    route_wear_cargo_dps * dt * tilt_factor
  game.durability = game.durability -
    route_wear_durability_dps * dt * (0.75 + speed_factor * 0.65)

  if game.input_stabilize_hold {
    game.cargo_quality = game.cargo_quality + 1.0 * dt
  }

  game.schedule_s = game.schedule_s - dt
  if game.schedule_s < 0.0 {
    game.reputation = game.reputation - dt * 1.7
  }

  game.distance = game.distance + game.speed * dt
  game.world_t = game.world_t + dt * (0.42 + speed_factor * 0.78)

  game.hazard_spawn_t = game.hazard_spawn_t - dt
  if game.hazard_spawn_t <= 0.0 {
    spawn_hazard(game)
    let difficulty = Float::from_int(game.checkpoint_index - 1)
    game.hazard_spawn_t = maxf(
        hazard_spawn_floor,
        hazard_spawn_base - difficulty * hazard_spawn_difficulty_step,
      ) +
      randf(-0.08, 0.22)
  }

  update_hazards(game, dt)

  while game.distance >= game.next_checkpoint_distance {
    resolve_checkpoint(game)
  }

  game.cargo_quality = clampf(game.cargo_quality, 0.0, 100.0)
  game.durability = clampf(game.durability, 0.0, 100.0)
  game.reputation = clampf(game.reputation, 0.0, 100.0)
  game.boost_heat = clampf(game.boost_heat, 0.0, 140.0)

  if game.durability <= 0.0 {
    enter_game_over(game, "The caravan broke apart on the descent.")
    return
  }

  if game.cargo_quality <= 0.0 {
    enter_game_over(game, "Tea quality collapsed before delivery.")
    return
  }

  if game.reputation <= 0.0 {
    enter_game_over(game, "Contract reputation is exhausted.")
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  let frame_dt = clampf(dt, 0.0, 0.05)

  game.world_t = game.world_t + frame_dt * 0.15
  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - frame_dt)
  }

  if game.state == state_title {
    if game.input_confirm_press || game.input_restart_press {
      reset_run(game)
    }
    return
  }

  if game.state == state_playing {
    if game.input_restart_press {
      reset_run(game)
      return
    }

    if game.input_pause_press {
      game.state = state_paused
      set_message(game, "Paused", 99.0)
      return
    }

    update_playing(game, frame_dt)
    return
  }

  if game.state == state_paused {
    if game.input_restart_press {
      reset_run(game)
      return
    }

    if game.input_pause_press || game.input_confirm_press {
      game.state = state_playing
      set_message(game, "Caravan rolling.", 1.0)
    }
    return
  }

  if game.input_restart_press || game.input_confirm_press {
    reset_run(game)
  }
}
