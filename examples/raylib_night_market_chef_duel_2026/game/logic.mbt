///|
fn clear_order(order : @types.Order) -> Unit {
  order.active = false
  order.dish = @types.Skewers
  order.patience = 0.0
  order.patience_max = 0.0
  order.reward = 0
  order.ticket_no = 0
}

///|
fn clear_cooking(game : @types.Game) -> Unit {
  game.cooking.active = false
  game.cooking.dish = @types.DishNone
  game.cooking.lane = @types.Grill
  game.cooking.stage = @types.Prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
}

///|
fn clear_round_entities(game : @types.Game) -> Unit {
  for order in game.orders {
    clear_order(order)
  }
  clear_cooking(game)
  game.ready_dish = @types.DishNone
  game.ready_quality = 0.0
  game.selected_order = -1
  game.cursor = @types.node_prep
}

///|
fn init_game(game : @types.Game) -> Unit {
  game.state = @types.Title
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
fn start_round(game : @types.Game) -> Unit {
  let keep_best = game.best_score
  init_game(game)
  game.best_score = keep_best
  game.state = @types.Play
  spawn_order(game)
  spawn_order(game)
}

///|
fn choose_dish_for_wave(elapsed_t : Float) -> @types.Dish {
  let r = @types.randi(0, 999)
  let late = @types.clampf(elapsed_t / 95.0, 0.0, 1.0)
  let easy_band = 350 - (late * 120.0).to_int()
  let mid_band = easy_band + 260
  let hard_band = mid_band + 220

  if r < easy_band {
    @types.Skewers
  } else if r < mid_band {
    @types.Noodles
  } else if r < hard_band {
    @types.FriedRice
  } else {
    @types.Squid
  }
}

///|
fn base_patience(game : @types.Game, dish : @types.Dish) -> Float {
  let rush = Float::from_int(game.served_orders + game.failed_orders) * 0.1
  let lane_bias : Float = match dish {
    @types.Squid => -0.8
    @types.Noodles => 0.5
    _ => 0.0
  }

  @types.maxf(
    @types.patience_floor,
    @types.patience_base - rush + lane_bias + @types.randf(-1.0, 1.3),
  )
}

///|
fn find_free_order_slot(game : @types.Game) -> Int {
  for i in 0..<game.orders.length() {
    if not(game.orders[i].active) {
      return i
    }
  }
  -1
}

///|
fn next_spawn_interval(game : @types.Game) -> Float {
  let pressure = Float::from_int(game.served_orders + game.failed_orders) * 0.07
  let base = @types.maxf(
    @types.spawn_interval_min,
    @types.spawn_interval_start - pressure,
  )
  @types.clampf(
    base + @types.randf(-0.22, 0.35),
    @types.spawn_interval_min,
    @types.spawn_interval_start,
  )
}

///|
fn spawn_order(game : @types.Game) -> Unit {
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
  game.orders[slot].reward = @types.dish_base_reward(dish)
  game.orders[slot].ticket_no = game.next_order_id

  game.next_order_id = game.next_order_id + 1
  game.spawn_t = next_spawn_interval(game)
}

///|
fn selected_is_valid(game : @types.Game) -> Bool {
  game.selected_order >= 0 &&
  game.selected_order < @types.max_orders &&
  game.orders[game.selected_order].active
}

///|
fn ensure_selected_order(game : @types.Game) -> Unit {
  if not(selected_is_valid(game)) {
    game.selected_order = -1
  }
}

///|
fn choose_target_order(game : @types.Game) -> Int {
  ensure_selected_order(game)
  if game.selected_order >= 0 {
    return game.selected_order
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i in 0..<game.orders.length() {
    if game.orders[i].active && game.orders[i].patience < best_patience {
      best_patience = game.orders[i].patience
      best = i
    }
  }
  best
}

///|
fn register_failure(game : @types.Game) -> Unit {
  game.failed_orders = game.failed_orders + 1
  game.combo = 0
  game.combo_timer = 0.0
  game.flash_t = @types.maxf(game.flash_t, 0.36)
  game.shake_t = @types.maxf(game.shake_t, 0.32)

  if game.failed_orders >= @types.fail_limit {
    game.state = @types.GameOver
    game.best_score = @types.maxi(game.best_score, game.score)
  }
}

///|
fn update_orders(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.orders.length() {
    if game.orders[i].active {
      game.orders[i].patience = game.orders[i].patience - dt
      if game.orders[i].patience <= 0.0 {
        clear_order(game.orders[i])
        if game.selected_order == i {
          game.selected_order = -1
        }
        if game.state == @types.Play {
          register_failure(game)
        }
      }
    }
  }
}

///|
fn find_matching_order(game : @types.Game, dish : @types.Dish) -> Int {
  ensure_selected_order(game)

  if game.selected_order >= 0 {
    let selected = game.selected_order
    if game.orders[selected].active && game.orders[selected].dish == dish {
      return selected
    }
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i in 0..<game.orders.length() {
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
fn boost_multiplier(game : @types.Game) -> Float {
  if game.boost_t > 0.0 {
    1.7
  } else {
    1.0
  }
}

///|
fn finish_cooking_if_ready(game : @types.Game) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != @types.Heat {
    return
  }

  let need = @types.dish_cook_need(game.cooking.dish)
  if game.cooking.cook_progress >= need && game.ready_dish == @types.DishNone {
    let overflow = game.cooking.cook_progress - need
    game.ready_dish = game.cooking.dish
    game.ready_quality = @types.clampf(1.0 - overflow * 0.18, 0.58, 1.15)
    clear_cooking(game)
    game.flash_t = @types.maxf(game.flash_t, 0.2)
  }
}

///|
fn apply_press_j_at_prep(game : @types.Game) -> Unit {
  if game.cooking.active {
    if game.cooking.stage == @types.Prep {
      game.cooking.prep_progress = game.cooking.prep_progress +
        @types.prep_press_gain * boost_multiplier(game)
      let need = @types.dish_prep_need(game.cooking.dish)
      if game.cooking.prep_progress >= need {
        game.cooking.prep_progress = need
        game.cooking.stage = @types.Heat
      }
    }
    return
  }

  if game.ready_dish != @types.DishNone {
    return
  }

  let target = choose_target_order(game)
  if target < 0 {
    return
  }

  let dish = game.orders[target].dish
  game.cooking.active = true
  game.cooking.dish = dish
  game.cooking.lane = @types.dish_lane(dish)
  game.cooking.stage = @types.Prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
  game.selected_order = target
  game.flash_t = @types.maxf(game.flash_t, 0.1)
}

///|
fn apply_press_j_at_heat(game : @types.Game, lane : @types.Lane) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != @types.Heat {
    return
  }

  if game.cooking.lane != lane {
    game.combo = 0
    game.combo_timer = 0.0
    game.flash_t = @types.maxf(game.flash_t, 0.12)
    return
  }

  game.cooking.cook_progress = game.cooking.cook_progress +
    @types.heat_press_gain * boost_multiplier(game)
  finish_cooking_if_ready(game)
}

///|
fn try_serve_ready_dish(game : @types.Game) -> Unit {
  if game.ready_dish == @types.DishNone {
    return
  }

  let matched_order = find_matching_order(game, game.ready_dish)
  if matched_order < 0 {
    game.ready_dish = @types.DishNone
    game.ready_quality = 0.0
    register_failure(game)
    return
  }

  let base = game.orders[matched_order].reward
  let patience_ratio : Float = if game.orders[matched_order].patience_max <=
    0.01 {
    0.0
  } else {
    @types.clampf(
      game.orders[matched_order].patience /
      game.orders[matched_order].patience_max,
      0.0,
      1.0,
    )
  }

  let patience_bonus = (Float::from_int(base) * patience_ratio * 0.45).to_int()
  let quality_bonus = (Float::from_int(base) * (game.ready_quality - 0.5) * 0.34).to_int()
  let combo_bonus = game.combo * 18

  let gained = @types.maxi(
    18,
    base + patience_bonus + quality_bonus + combo_bonus,
  )
  game.score = game.score + gained
  game.best_score = @types.maxi(game.best_score, game.score)

  game.served_orders = game.served_orders + 1
  game.combo = @types.clampi(game.combo + 1, 0, 99)
  game.combo_timer = @types.combo_window

  clear_order(game.orders[matched_order])
  if game.selected_order == matched_order {
    game.selected_order = -1
  }

  game.ready_dish = @types.DishNone
  game.ready_quality = 0.0
  game.flash_t = @types.maxf(game.flash_t, 0.22)
}

///|
fn apply_press_j(game : @types.Game) -> Unit {
  if game.cursor < @types.max_orders {
    if game.orders[game.cursor].active {
      game.selected_order = game.cursor
    }
    return
  }

  if game.cursor == @types.node_prep {
    apply_press_j_at_prep(game)
  } else if game.cursor == @types.node_grill {
    apply_press_j_at_heat(game, @types.Grill)
  } else if game.cursor == @types.node_wok {
    apply_press_j_at_heat(game, @types.Wok)
  }
}

///|
fn apply_press_k(game : @types.Game) -> Unit {
  if game.cursor == @types.node_pass {
    try_serve_ready_dish(game)
    return
  }

  if game.cursor < @types.max_orders {
    if game.selected_order == game.cursor {
      game.selected_order = -1
      game.flash_t = @types.maxf(game.flash_t, 0.08)
    }
    return
  }

  if (
      game.cursor == @types.node_prep ||
      game.cursor == @types.node_grill ||
      game.cursor == @types.node_wok
    ) &&
    game.cooking.active {
    clear_cooking(game)
    game.combo = 0
    game.combo_timer = 0.0
    game.flash_t = @types.maxf(game.flash_t, 0.16)
  }
}

///|
fn move_cursor(game : @types.Game, dir_x : Int, dir_y : Int) -> Unit {
  if dir_x == 0 && dir_y == 0 {
    return
  }

  let cur = @types.node_pos(game.cursor)
  let mut best = game.cursor
  let mut best_score : Float = 1000000.0

  for i in 0..<@types.node_count {
    if i != game.cursor {
      let p = @types.node_pos(i)
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
        let forward : Float = if dir_x != 0 {
          @types.absf(vx)
        } else {
          @types.absf(vy)
        }
        let side : Float = if dir_x != 0 {
          @types.absf(vy)
        } else {
          @types.absf(vx)
        }
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
fn activate_boost(game : @types.Game) -> Unit {
  if game.boost_cd <= 0.0 {
    game.boost_t = @types.boost_time
    game.boost_cd = @types.boost_cooldown
    game.flash_t = @types.maxf(game.flash_t, 0.14)
  }
}

///|
fn update_boost(game : @types.Game, dt : Float) -> Unit {
  game.boost_t = @types.maxf(0.0, game.boost_t - dt)
  game.boost_cd = @types.maxf(0.0, game.boost_cd - dt)
}

///|
fn update_cooking_passive(game : @types.Game, dt : Float) -> Unit {
  if not(game.cooking.active) {
    return
  }

  if game.boost_t > 0.0 {
    if game.cooking.stage == @types.Prep {
      game.cooking.prep_progress = game.cooking.prep_progress +
        dt * @types.boost_prep_rate
      let need = @types.dish_prep_need(game.cooking.dish)
      if game.cooking.prep_progress >= need {
        game.cooking.prep_progress = need
        game.cooking.stage = @types.Heat
      }
    } else if game.cooking.stage == @types.Heat {
      let on_lane = (
          game.cursor == @types.node_grill && game.cooking.lane == @types.Grill
        ) ||
        (game.cursor == @types.node_wok && game.cooking.lane == @types.Wok)
      if on_lane {
        game.cooking.cook_progress = game.cooking.cook_progress +
          dt * @types.boost_heat_rate
      }
    }
  }

  finish_cooking_if_ready(game)
}

///|
fn update_ready_dish(game : @types.Game, dt : Float) -> Unit {
  if game.ready_dish != @types.DishNone {
    game.ready_quality = @types.maxf(0.55, game.ready_quality - dt * 0.045)
  }
}

///|
fn update_combo_timer(game : @types.Game, dt : Float) -> Unit {
  if game.combo > 0 {
    game.combo_timer = game.combo_timer - dt
    if game.combo_timer <= 0.0 {
      game.combo = 0
      game.combo_timer = 0.0
    }
  }
}

///|
fn update_spawn(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    spawn_order(game)
  }
}

///|
fn update_effects(game : @types.Game, dt : Float) -> Unit {
  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)
}

///|
fn update_title(game : @types.Game) -> Unit {
  if game.input.press_start ||
    game.input.press_restart ||
    game.input.press_space {
    start_round(game)
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if game.input.press_restart {
    start_round(game)
  } else if game.input.press_pause || game.input.press_start {
    game.state = @types.Play
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_round(game)
  }
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_restart {
    start_round(game)
    return
  }

  if game.input.press_pause {
    game.state = @types.Paused
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

  if game.state == @types.Play {
    update_ready_dish(game, dt)
    update_spawn(game, dt)
    update_combo_timer(game, dt)
    ensure_selected_order(game)
    game.elapsed_t = game.elapsed_t + dt
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  capture_input(game)
  let frame_dt = @types.clampf(dt, 0.0, 0.05)

  match game.state {
    @types.Title => update_title(game)
    @types.Play => update_play(game, frame_dt)
    @types.Paused => update_paused(game)
    @types.GameOver => update_game_over(game)
  }

  update_effects(game, frame_dt)
}
