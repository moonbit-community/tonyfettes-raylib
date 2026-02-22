///|
fn clear_order(order : Order) -> Unit {
  order.active = false
  order.dish = dish_skewers
  order.patience = 0.0
  order.patience_max = 0.0
  order.reward = 0
  order.ticket_no = 0
}

///|
fn clear_cooking(game : Game) -> Unit {
  game.cooking.active = false
  game.cooking.dish = dish_none
  game.cooking.lane = lane_grill
  game.cooking.stage = cook_stage_prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
}

///|
fn clear_round_entities(game : Game) -> Unit {
  for i = 0; i < game.orders.length(); i = i + 1 {
    clear_order(game.orders[i])
  }
  clear_cooking(game)
  game.ready_dish = dish_none
  game.ready_quality = 0.0
  game.selected_order = -1
  game.cursor = node_prep
}

///|
fn init_game(game : Game) -> Unit {
  game.state = state_title
  game.score = 0
  game.combo = 0
  game.combo_timer = 0.0
  game.served_orders = 0
  game.failed_orders = 0
  game.next_order_id = 1
  game.spawn_t = 0.6
  game.elapsed_t = 0.0
  game.boost_t = 0.0
  game.boost_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  clear_round_entities(game)
}

///|
fn start_round(game : Game) -> Unit {
  let keep_best = game.best_score
  init_game(game)
  game.best_score = keep_best
  game.state = state_play
  spawn_order(game)
  spawn_order(game)
}

///|
fn choose_dish_for_wave(elapsed_t : Float) -> Int {
  let r = randi(0, 999)
  let late = clampf(elapsed_t / 95.0, 0.0, 1.0)
  let easy_band = 350 - (late * 120.0).to_int()
  let mid_band = easy_band + 260
  let hard_band = mid_band + 220

  if r < easy_band {
    dish_skewers
  } else if r < mid_band {
    dish_noodles
  } else if r < hard_band {
    dish_fried_rice
  } else {
    dish_squid
  }
}

///|
fn base_patience(game : Game, dish : Int) -> Float {
  let rush = Float::from_int(game.served_orders + game.failed_orders) * 0.1
  let lane_bias : Float = if dish == dish_squid {
    -0.8
  } else if dish == dish_noodles {
    0.5
  } else {
    0.0
  }

  maxf(patience_floor, patience_base - rush + lane_bias + randf(-1.0, 1.3))
}

///|
fn find_free_order_slot(game : Game) -> Int {
  for i = 0; i < game.orders.length(); i = i + 1 {
    if not(game.orders[i].active) {
      return i
    }
  }
  -1
}

///|
fn next_spawn_interval(game : Game) -> Float {
  let pressure = Float::from_int(game.served_orders + game.failed_orders) * 0.07
  let base = maxf(spawn_interval_min, spawn_interval_start - pressure)
  clampf(base + randf(-0.22, 0.35), spawn_interval_min, spawn_interval_start)
}

///|
fn spawn_order(game : Game) -> Unit {
  let slot = find_free_order_slot(game)
  if slot < 0 {
    game.spawn_t = 0.45
    return
  }

  let dish = choose_dish_for_wave(game.elapsed_t)
  let patience = base_patience(game, dish)

  game.orders[slot].active = true
  game.orders[slot].dish = dish
  game.orders[slot].patience = patience
  game.orders[slot].patience_max = patience
  game.orders[slot].reward = dish_base_reward(dish)
  game.orders[slot].ticket_no = game.next_order_id

  game.next_order_id = game.next_order_id + 1
  game.spawn_t = next_spawn_interval(game)
}

///|
fn selected_is_valid(game : Game) -> Bool {
  game.selected_order >= 0 &&
  game.selected_order < max_orders &&
  game.orders[game.selected_order].active
}

///|
fn ensure_selected_order(game : Game) -> Unit {
  if not(selected_is_valid(game)) {
    game.selected_order = -1
  }
}

///|
fn choose_target_order(game : Game) -> Int {
  ensure_selected_order(game)
  if game.selected_order >= 0 {
    return game.selected_order
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i = 0; i < game.orders.length(); i = i + 1 {
    if game.orders[i].active && game.orders[i].patience < best_patience {
      best_patience = game.orders[i].patience
      best = i
    }
  }
  best
}

///|
fn register_failure(game : Game) -> Unit {
  game.failed_orders = game.failed_orders + 1
  game.combo = 0
  game.combo_timer = 0.0
  game.flash_t = maxf(game.flash_t, 0.36)
  game.shake_t = maxf(game.shake_t, 0.32)

  if game.failed_orders >= fail_limit {
    game.state = state_game_over
    game.best_score = maxi(game.best_score, game.score)
  }
}

///|
fn update_orders(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.orders.length(); i = i + 1 {
    if game.orders[i].active {
      game.orders[i].patience = game.orders[i].patience - dt
      if game.orders[i].patience <= 0.0 {
        clear_order(game.orders[i])
        if game.selected_order == i {
          game.selected_order = -1
        }
        if game.state == state_play {
          register_failure(game)
        }
      }
    }
  }
}

///|
fn find_matching_order(game : Game, dish : Int) -> Int {
  ensure_selected_order(game)

  if game.selected_order >= 0 {
    let selected = game.selected_order
    if game.orders[selected].active && game.orders[selected].dish == dish {
      return selected
    }
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i = 0; i < game.orders.length(); i = i + 1 {
    if game.orders[i].active &&
      game.orders[i].dish == dish &&
      game.orders[i].patience < best_patience {
      best_patience = game.orders[i].patience
      best = i
    }
  }
  best
}

///|
fn boost_multiplier(game : Game) -> Float {
  if game.boost_t > 0.0 {
    1.7
  } else {
    1.0
  }
}

///|
fn finish_cooking_if_ready(game : Game) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != cook_stage_heat {
    return
  }

  let need = dish_cook_need(game.cooking.dish)
  if game.cooking.cook_progress >= need && game.ready_dish == dish_none {
    let overflow = game.cooking.cook_progress - need
    game.ready_dish = game.cooking.dish
    game.ready_quality = clampf(1.0 - overflow * 0.18, 0.58, 1.15)
    clear_cooking(game)
    game.flash_t = maxf(game.flash_t, 0.2)
  }
}

///|
fn apply_press_j_at_prep(game : Game) -> Unit {
  if game.cooking.active {
    if game.cooking.stage == cook_stage_prep {
      game.cooking.prep_progress = game.cooking.prep_progress +
        prep_press_gain * boost_multiplier(game)
      let need = dish_prep_need(game.cooking.dish)
      if game.cooking.prep_progress >= need {
        game.cooking.prep_progress = need
        game.cooking.stage = cook_stage_heat
      }
    }
    return
  }

  if game.ready_dish != dish_none {
    return
  }

  let target = choose_target_order(game)
  if target < 0 {
    return
  }

  let dish = game.orders[target].dish
  game.cooking.active = true
  game.cooking.dish = dish
  game.cooking.lane = dish_lane(dish)
  game.cooking.stage = cook_stage_prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
  game.selected_order = target
  game.flash_t = maxf(game.flash_t, 0.1)
}

///|
fn apply_press_j_at_heat(game : Game, lane : Int) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != cook_stage_heat {
    return
  }

  if game.cooking.lane != lane {
    game.combo = 0
    game.combo_timer = 0.0
    game.flash_t = maxf(game.flash_t, 0.12)
    return
  }

  game.cooking.cook_progress = game.cooking.cook_progress +
    heat_press_gain * boost_multiplier(game)
  finish_cooking_if_ready(game)
}

///|
fn try_serve_ready_dish(game : Game) -> Unit {
  if game.ready_dish == dish_none {
    return
  }

  let matched_order = find_matching_order(game, game.ready_dish)
  if matched_order < 0 {
    game.ready_dish = dish_none
    game.ready_quality = 0.0
    register_failure(game)
    return
  }

  let base = game.orders[matched_order].reward
  let patience_ratio : Float = if game.orders[matched_order].patience_max <=
    0.01 {
    0.0
  } else {
    clampf(
      game.orders[matched_order].patience /
      game.orders[matched_order].patience_max,
      0.0,
      1.0,
    )
  }

  let patience_bonus = (Float::from_int(base) * patience_ratio * 0.45).to_int()
  let quality_bonus = (Float::from_int(base) * (game.ready_quality - 0.5) * 0.34).to_int()
  let combo_bonus = game.combo * 18

  let gained = maxi(18, base + patience_bonus + quality_bonus + combo_bonus)
  game.score = game.score + gained
  game.best_score = maxi(game.best_score, game.score)

  game.served_orders = game.served_orders + 1
  game.combo = clampi(game.combo + 1, 0, 99)
  game.combo_timer = combo_window

  clear_order(game.orders[matched_order])
  if game.selected_order == matched_order {
    game.selected_order = -1
  }

  game.ready_dish = dish_none
  game.ready_quality = 0.0
  game.flash_t = maxf(game.flash_t, 0.22)
}

///|
fn apply_press_j(game : Game) -> Unit {
  if game.cursor < max_orders {
    if game.orders[game.cursor].active {
      game.selected_order = game.cursor
    }
    return
  }

  if game.cursor == node_prep {
    apply_press_j_at_prep(game)
  } else if game.cursor == node_grill {
    apply_press_j_at_heat(game, lane_grill)
  } else if game.cursor == node_wok {
    apply_press_j_at_heat(game, lane_wok)
  }
}

///|
fn apply_press_k(game : Game) -> Unit {
  if game.cursor == node_pass {
    try_serve_ready_dish(game)
    return
  }

  if game.cursor < max_orders {
    if game.selected_order == game.cursor {
      game.selected_order = -1
      game.flash_t = maxf(game.flash_t, 0.08)
    }
    return
  }

  if (
      game.cursor == node_prep ||
      game.cursor == node_grill ||
      game.cursor == node_wok
    ) &&
    game.cooking.active {
    clear_cooking(game)
    game.combo = 0
    game.combo_timer = 0.0
    game.flash_t = maxf(game.flash_t, 0.16)
  }
}

///|
fn move_cursor(game : Game, dir_x : Int, dir_y : Int) -> Unit {
  if dir_x == 0 && dir_y == 0 {
    return
  }

  let cur = node_pos(game.cursor)
  let mut best = game.cursor
  let mut best_score : Float = 1000000.0

  for i = 0; i < node_count; i = i + 1 {
    if i != game.cursor {
      let p = node_pos(i)
      let vx = p.0 - cur.0
      let vy = p.1 - cur.1

      let mut accepted = true
      if dir_x < 0 && vx >= -6.0 {
        accepted = false
      }
      if dir_x > 0 && vx <= 6.0 {
        accepted = false
      }
      if dir_y < 0 && vy >= -6.0 {
        accepted = false
      }
      if dir_y > 0 && vy <= 6.0 {
        accepted = false
      }

      if accepted {
        let forward : Float = if dir_x != 0 { absf(vx) } else { absf(vy) }
        let side : Float = if dir_x != 0 { absf(vy) } else { absf(vx) }
        let score : Float = forward + side * 1.9
        if score < best_score {
          best_score = score
          best = i
        }
      }
    }
  }

  game.cursor = best
}

///|
fn activate_boost(game : Game) -> Unit {
  if game.boost_cd <= 0.0 {
    game.boost_t = boost_time
    game.boost_cd = boost_cooldown
    game.flash_t = maxf(game.flash_t, 0.14)
  }
}

///|
fn update_boost(game : Game, dt : Float) -> Unit {
  game.boost_t = maxf(0.0, game.boost_t - dt)
  game.boost_cd = maxf(0.0, game.boost_cd - dt)
}

///|
fn update_cooking_passive(game : Game, dt : Float) -> Unit {
  if not(game.cooking.active) {
    return
  }

  if game.boost_t > 0.0 {
    if game.cooking.stage == cook_stage_prep {
      game.cooking.prep_progress = game.cooking.prep_progress +
        dt * boost_prep_rate
      let need = dish_prep_need(game.cooking.dish)
      if game.cooking.prep_progress >= need {
        game.cooking.prep_progress = need
        game.cooking.stage = cook_stage_heat
      }
    } else if game.cooking.stage == cook_stage_heat {
      let on_lane = (
          game.cursor == node_grill && game.cooking.lane == lane_grill
        ) ||
        (game.cursor == node_wok && game.cooking.lane == lane_wok)
      if on_lane {
        game.cooking.cook_progress = game.cooking.cook_progress +
          dt * boost_heat_rate
      }
    }
  }

  finish_cooking_if_ready(game)
}

///|
fn update_ready_dish(game : Game, dt : Float) -> Unit {
  if game.ready_dish != dish_none {
    game.ready_quality = maxf(0.55, game.ready_quality - dt * 0.045)
  }
}

///|
fn update_combo_timer(game : Game, dt : Float) -> Unit {
  if game.combo > 0 {
    game.combo_timer = game.combo_timer - dt
    if game.combo_timer <= 0.0 {
      game.combo = 0
      game.combo_timer = 0.0
    }
  }
}

///|
fn update_spawn(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    spawn_order(game)
  }
}

///|
fn update_effects(game : Game, dt : Float) -> Unit {
  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)
}

///|
fn update_title(game : Game) -> Unit {
  if game.input.press_start ||
    game.input.press_restart ||
    game.input.press_space {
    start_round(game)
  }
}

///|
fn update_paused(game : Game) -> Unit {
  if game.input.press_restart {
    start_round(game)
  } else if game.input.press_pause || game.input.press_start {
    game.state = state_play
  }
}

///|
fn update_game_over(game : Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_round(game)
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  if game.input.press_restart {
    start_round(game)
    return
  }

  if game.input.press_pause {
    game.state = state_paused
    return
  }

  if game.input.move_x != 0 || game.input.move_y != 0 {
    move_cursor(game, game.input.move_x, game.input.move_y)
  }

  if game.input.press_space {
    activate_boost(game)
  }

  if game.input.press_j {
    apply_press_j(game)
  }

  if game.input.press_k {
    apply_press_k(game)
  }

  update_boost(game, dt)
  update_cooking_passive(game, dt)
  update_orders(game, dt)

  if game.state == state_play {
    update_ready_dish(game, dt)
    update_spawn(game, dt)
    update_combo_timer(game, dt)
    ensure_selected_order(game)
    game.elapsed_t = game.elapsed_t + dt
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  let frame_dt = clampf(dt, 0.0, 0.05)

  if game.state == state_title {
    update_title(game)
  } else if game.state == state_play {
    update_play(game, frame_dt)
  } else if game.state == state_paused {
    update_paused(game)
  } else {
    update_game_over(game)
  }

  update_effects(game, frame_dt)
}
