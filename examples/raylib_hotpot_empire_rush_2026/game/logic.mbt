///|
fn clear_hand(game : @types.Game) -> Unit {
  game.hand.kind = @types.ingredient_none
  game.hand.flavor = 0
  game.hand.prepped = false
}

///|
fn clear_prep(game : @types.Game) -> Unit {
  game.prep.active = false
  game.prep.kind = @types.ingredient_none
  game.prep.flavor = 0
  game.prep.progress = 0.0
  game.prep.target = @types.prep_target_base
  game.prep.output_ready = false
  game.prep.out_kind = @types.ingredient_none
  game.prep.out_flavor = 0
}

///|
fn clear_pot(game : @types.Game) -> Unit {
  game.pot.broth = -1
  game.pot.protein = -1
  game.pot.veg = -1
  game.pot.spice = 0
  game.pot.cooking = false
  game.pot.progress = 0.0
  game.pot.target = @types.cook_target_base
  game.pot.ready = false
}

///|
fn clear_orders(game : @types.Game) -> Unit {
  for i in 0..<@types.max_orders {
    game.orders[i].active = false
    game.orders[i].id = i + 1
    game.orders[i].broth = 0
    game.orders[i].protein = 0
    game.orders[i].veg = 0
    game.orders[i].spice = 0
    game.orders[i].patience = 0.0
    game.orders[i].max_patience = 0.0
    game.orders[i].pulse = 0.0
  }
}

///|
fn start_run(game : @types.Game) -> Unit {
  game.state = @types.state_playing
  game.cursor_x = 1
  game.cursor_y = 1

  game.score = 0
  game.combo = 0
  game.combo_t = 0.0
  game.reputation = @types.reputation_start
  game.boost_meter = @types.boost_meter_max
  game.boost_t = 0.0
  game.rush_cd = 0.0
  game.spawn_cd = 0.9
  game.order_serial = 1
  game.elapsed = 0.0
  game.served = 0
  game.failed = 0
  game.next_protein_pick = @raylib.get_random_value(0, @types.protein_count - 1)
  game.next_veg_pick = @raylib.get_random_value(0, @types.veg_count - 1)
  game.flash_t = 0.0

  clear_hand(game)
  clear_prep(game)
  clear_pot(game)
  clear_orders(game)
  ignore(spawn_order(game))
  ignore(spawn_order(game))

  @types.set_message(game, "Kitchen open. Build orders from the queue head.")
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn spawn_interval(elapsed : Float) -> Float {
  @types.clampf(4.3 - elapsed * 0.045, 1.1, 4.3)
}

///|
fn spawn_patience(elapsed : Float) -> Float {
  let base : Float = 26.0 - @types.minf(11.0, elapsed * 0.24)
  @types.clampf(base + randf(-2.2, 2.8), 11.0, 30.0)
}

///|
fn active_order_count(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<@types.max_orders {
    if game.orders[i].active {
      count = count + 1
    }
  }
  count
}

///|
fn remove_order_at(game : @types.Game, idx : Int) -> Unit {
  if idx < 0 || idx >= @types.max_orders {
    return
  }

  let mut i = idx
  while i < @types.max_orders - 1 {
    game.orders[i].active = game.orders[i + 1].active
    game.orders[i].id = game.orders[i + 1].id
    game.orders[i].broth = game.orders[i + 1].broth
    game.orders[i].protein = game.orders[i + 1].protein
    game.orders[i].veg = game.orders[i + 1].veg
    game.orders[i].spice = game.orders[i + 1].spice
    game.orders[i].patience = game.orders[i + 1].patience
    game.orders[i].max_patience = game.orders[i + 1].max_patience
    game.orders[i].pulse = game.orders[i + 1].pulse
    i = i + 1
  }

  let tail = @types.max_orders - 1
  game.orders[tail].active = false
  game.orders[tail].id = game.order_serial + tail
  game.orders[tail].broth = 0
  game.orders[tail].protein = 0
  game.orders[tail].veg = 0
  game.orders[tail].spice = 0
  game.orders[tail].patience = 0.0
  game.orders[tail].max_patience = 0.0
  game.orders[tail].pulse = 0.0
}

///|
fn spawn_order(game : @types.Game) -> Bool {
  let mut slot = -1
  for i in 0..<@types.max_orders {
    if not(game.orders[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  let spice_cap = if game.elapsed >= 70.0 {
    2
  } else if game.elapsed >= 25.0 {
    1
  } else {
    0
  }

  game.orders[slot].active = true
  game.orders[slot].id = game.order_serial
  game.orders[slot].broth = @raylib.get_random_value(0, @types.broth_count - 1)
  game.orders[slot].protein = @raylib.get_random_value(
    0,
    @types.protein_count - 1,
  )
  game.orders[slot].veg = @raylib.get_random_value(0, @types.veg_count - 1)
  game.orders[slot].spice = @raylib.get_random_value(0, spice_cap)
  game.orders[slot].max_patience = spawn_patience(game.elapsed)
  game.orders[slot].patience = game.orders[slot].max_patience
  game.orders[slot].pulse = randf(0.0, 6.28)

  game.order_serial = game.order_serial + 1
  true
}

///|
fn move_cursor(game : @types.Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = @types.clampi(game.cursor_x + dx, 0, @types.station_cols - 1)
  game.cursor_y = @types.clampi(game.cursor_y + dy, 0, @types.station_rows - 1)
  @types.set_message(
    game,
    @types.station_name(@types.station_at(game.cursor_x, game.cursor_y)),
  )
}

///|
fn pot_has_core(game : @types.Game) -> Bool {
  game.pot.broth >= 0 && game.pot.protein >= 0 && game.pot.veg >= 0
}

///|
fn pot_has_anything(game : @types.Game) -> Bool {
  game.pot.broth >= 0 ||
  game.pot.protein >= 0 ||
  game.pot.veg >= 0 ||
  game.pot.cooking ||
  game.pot.ready
}

///|
fn interact_broth(game : @types.Game) -> Unit {
  if game.pot.ready || game.pot.cooking {
    @types.set_message(game, "Pot is locked while cooking/ready.")
    return
  }

  if game.pot.broth < 0 {
    game.pot.broth = 0
  } else {
    game.pot.broth = (game.pot.broth + 1) % @types.broth_count
  }

  @types.set_message(game, "Broth set: \{@types.broth_name(game.pot.broth)}")
}

///|
fn interact_protein(game : @types.Game) -> Unit {
  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Hands full. Drop with K or trash station.")
    return
  }

  game.hand.kind = @types.ingredient_protein
  game.hand.flavor = game.next_protein_pick
  game.hand.prepped = false
  game.next_protein_pick = (game.next_protein_pick + 1) % @types.protein_count

  @types.set_message(
    game,
    "Picked raw \{@types.protein_name(game.hand.flavor)}",
  )
}

///|
fn interact_veg(game : @types.Game) -> Unit {
  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Hands full. Drop with K or trash station.")
    return
  }

  game.hand.kind = @types.ingredient_veg
  game.hand.flavor = game.next_veg_pick
  game.hand.prepped = false
  game.next_veg_pick = (game.next_veg_pick + 1) % @types.veg_count

  @types.set_message(game, "Picked raw \{@types.veg_name(game.hand.flavor)}")
}

///|
fn interact_spice(game : @types.Game) -> Unit {
  if game.pot.ready || game.pot.cooking {
    @types.set_message(game, "Spice can only be adjusted before cooking.")
    return
  }

  game.pot.spice = (game.pot.spice + 1) % @types.spice_levels
  @types.set_message(game, "Spice level: \{@types.spice_name(game.pot.spice)}")
}

///|
fn interact_prep(game : @types.Game) -> Unit {
  if game.prep.active {
    let percent = @types.clampi(
      (game.prep.progress / @types.maxf(game.prep.target, 0.01) * 100.0).to_int(),
      0,
      100,
    )
    @types.set_message(game, "Prep in progress \{percent}%")
    return
  }

  if game.prep.output_ready {
    if game.hand.kind != @types.ingredient_none {
      @types.set_message(game, "Hands full. Cannot collect prepped ingredient.")
      return
    }

    game.hand.kind = game.prep.out_kind
    game.hand.flavor = game.prep.out_flavor
    game.hand.prepped = true
    game.prep.output_ready = false
    game.prep.out_kind = @types.ingredient_none
    game.prep.out_flavor = 0

    if game.hand.kind == @types.ingredient_protein {
      @types.set_message(
        game,
        "Collected sliced \{@types.protein_name(game.hand.flavor)}",
      )
    } else {
      @types.set_message(
        game,
        "Collected cleaned \{@types.veg_name(game.hand.flavor)}",
      )
    }
    return
  }

  if game.hand.kind == @types.ingredient_none {
    @types.set_message(game, "Bring raw protein/veg to prep.")
    return
  }

  if game.hand.prepped {
    @types.set_message(game, "Already prepped. Move item to pot.")
    return
  }

  if game.hand.kind != @types.ingredient_protein &&
    game.hand.kind != @types.ingredient_veg {
    @types.set_message(game, "Only protein or veg can be prepped.")
    return
  }

  game.prep.active = true
  game.prep.kind = game.hand.kind
  game.prep.flavor = game.hand.flavor
  game.prep.progress = 0.0
  game.prep.target = @types.prep_target_base +
    Float::from_int(game.hand.flavor) * 0.28

  clear_hand(game)
  @types.set_message(game, "Prep started.")
}

///|
fn interact_pot(game : @types.Game) -> Unit {
  if game.pot.ready {
    @types.set_message(game, "Hotpot ready. Serve it with K at counter.")
    return
  }

  if game.hand.kind == @types.ingredient_protein && game.hand.prepped {
    if game.pot.protein >= 0 {
      @types.set_message(game, "Protein already loaded in pot.")
      return
    }
    game.pot.protein = game.hand.flavor
    clear_hand(game)
    @types.set_message(game, "Protein loaded into pot.")
    return
  }

  if game.hand.kind == @types.ingredient_veg && game.hand.prepped {
    if game.pot.veg >= 0 {
      @types.set_message(game, "Veg already loaded in pot.")
      return
    }
    game.pot.veg = game.hand.flavor
    clear_hand(game)
    @types.set_message(game, "Veg loaded into pot.")
    return
  }

  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Only prepped protein/veg can enter the pot.")
    return
  }

  if game.pot.cooking {
    @types.set_message(game, "Pot is simmering.")
    return
  }

  if not(pot_has_core(game)) {
    @types.set_message(
      game,
      "Pot requires broth + protein + veg before cooking.",
    )
    return
  }

  game.pot.cooking = true
  game.pot.progress = 0.0
  game.pot.target = @types.maxf(
    2.7,
    @types.cook_target_base - Float::from_int(game.pot.spice) * 0.55,
  )

  @types.set_message(game, "Cooking started. Wait for full simmer.")
}

///|
fn interact_rush(game : @types.Game) -> Unit {
  if game.rush_cd > 0.0 {
    let wait_s = game.rush_cd.to_int() + 1
    @types.set_message(game, "Rush bell cooling down \{wait_s}s")
    return
  }

  game.boost_meter = @types.clampf(
    game.boost_meter + 24.0,
    0.0,
    @types.boost_meter_max,
  )
  game.rush_cd = @types.rush_cooldown
  @types.set_message(game, "Rush bell rang. Boost meter refilled.")
}

///|
fn interact_trash(game : @types.Game) -> Unit {
  if game.hand.kind == @types.ingredient_none {
    @types.set_message(game, "Nothing in hand to trash.")
    return
  }

  clear_hand(game)
  @types.set_message(game, "Ingredient discarded.")
}

///|
fn interact_queue(game : @types.Game) -> Unit {
  if game.orders[0].active {
    @types.set_message(
      game,
      "Queue head wants \{@types.broth_name(game.orders[0].broth)} / \{@types.protein_name(game.orders[0].protein)} / \{@types.veg_name(game.orders[0].veg)} / \{@types.spice_name(game.orders[0].spice)}",
    )
  } else {
    @types.set_message(game, "No active customer right now.")
  }
}

///|
fn interact_storage(game : @types.Game) -> Unit {
  game.next_protein_pick = @raylib.get_random_value(
    0,
    @types.protein_count - 1,
  )
  game.next_veg_pick = @raylib.get_random_value(0, @types.veg_count - 1)
  @types.set_message(game, "Storage shuffled upcoming ingredients.")
}

///|
fn handle_interact(game : @types.Game) -> Unit {
  let station = @types.station_at(game.cursor_x, game.cursor_y)

  if station == @types.station_broth {
    interact_broth(game)
  } else if station == @types.station_protein {
    interact_protein(game)
  } else if station == @types.station_veg {
    interact_veg(game)
  } else if station == @types.station_spice {
    interact_spice(game)
  } else if station == @types.station_prep {
    interact_prep(game)
  } else if station == @types.station_pot {
    interact_pot(game)
  } else if station == @types.station_rush {
    interact_rush(game)
  } else if station == @types.station_trash {
    interact_trash(game)
  } else if station == @types.station_queue {
    interact_queue(game)
  } else if station == @types.station_reputation {
    @types.set_message(
      game,
      "Reputation controls game over. Keep orders flowing.",
    )
  } else if station == @types.station_storage {
    interact_storage(game)
  } else {
    @types.set_message(game, "No interaction at this station.")
  }
}

///|
fn serve_matches_head(game : @types.Game) -> Bool {
  if not(game.orders[0].active) {
    return false
  }

  game.pot.broth == game.orders[0].broth &&
  game.pot.protein == game.orders[0].protein &&
  game.pot.veg == game.orders[0].veg &&
  game.pot.spice == game.orders[0].spice
}

///|
fn serve_head_order(game : @types.Game) -> Unit {
  if not(game.pot.ready) {
    @types.set_message(game, "No finished pot to serve.")
    return
  }

  if not(game.orders[0].active) {
    game.combo = 0
    game.combo_t = 0.0
    game.failed = game.failed + 1
    game.reputation = @types.clampf(
      game.reputation - @types.rep_loss_wrong_serve * 0.55,
      0.0,
      @types.reputation_max,
    )
    clear_pot(game)
    game.flash_t = 0.35
    @types.set_message(game, "Served with no queue head. Reputation down.")
    return
  }

  if serve_matches_head(game) {
    let patience_ratio = @types.clampf(
      game.orders[0].patience /
      @types.maxf(game.orders[0].max_patience, 0.01),
      0.0,
      1.0,
    )
    let patience_bonus = (patience_ratio * 90.0).to_int()

    game.combo = game.combo + 1
    game.combo_t = @types.combo_keep_time

    let combo_bonus = game.combo * 20
    let gain = @types.score_base_serve + patience_bonus + combo_bonus

    game.score = game.score + gain
    if game.score > game.best_score {
      game.best_score = game.score
    }

    game.reputation = @types.clampf(
      game.reputation + @types.rep_gain_served,
      0.0,
      @types.reputation_max,
    )

    game.served = game.served + 1
    remove_order_at(game, 0)
    clear_pot(game)
    game.flash_t = 0.14
    @types.set_message(game, "Serve success +\{gain} (combo x\{game.combo})")
    return
  }

  game.combo = 0
  game.combo_t = 0.0
  game.failed = game.failed + 1
  game.reputation = @types.clampf(
    game.reputation - @types.rep_loss_wrong_serve,
    0.0,
    @types.reputation_max,
  )
  clear_pot(game)
  game.flash_t = 0.42
  @types.set_message(game, "Wrong order served! Combo broken.")
}

///|
fn handle_serve_cancel(game : @types.Game) -> Unit {
  let station = @types.station_at(game.cursor_x, game.cursor_y)

  if station == @types.station_serve {
    serve_head_order(game)
    return
  }

  if station == @types.station_pot {
    if pot_has_anything(game) {
      clear_pot(game)
      game.combo = 0
      game.combo_t = 0.0
      game.reputation = @types.clampf(
        game.reputation - @types.rep_loss_discard_pot,
        0.0,
        @types.reputation_max,
      )
      game.flash_t = 0.2
      @types.set_message(game, "Pot discarded. Reputation down.")
    } else {
      @types.set_message(game, "Pot is already empty.")
    }
    return
  }

  if station == @types.station_prep {
    if game.prep.active || game.prep.output_ready {
      clear_prep(game)
      @types.set_message(game, "Prep canceled.")
      return
    }
  }

  if game.hand.kind != @types.ingredient_none {
    clear_hand(game)
    @types.set_message(game, "Held item canceled.")
    return
  }

  @types.set_message(game, "Nothing to cancel here.")
}

///|
fn trigger_boost(game : @types.Game) -> Unit {
  if game.boost_t > 0.0 {
    @types.set_message(game, "Boost already active.")
    return
  }

  if game.boost_meter < @types.boost_cost {
    @types.set_message(game, "Not enough boost meter.")
    return
  }

  game.boost_meter = @types.clampf(
    game.boost_meter - @types.boost_cost,
    0.0,
    @types.boost_meter_max,
  )
  game.boost_t = @types.boost_duration
  @types.set_message(game, "Boost active: prep and cook speed doubled.")
}

///|
fn boost_multiplier(game : @types.Game) -> Float {
  if game.boost_t > 0.0 {
    @types.boost_speed_mult
  } else {
    1.0
  }
}

///|
fn update_play_timers(game : @types.Game, dt : Float) -> Unit {
  game.elapsed = game.elapsed + dt

  game.boost_meter = @types.clampf(
    game.boost_meter + dt * @types.boost_charge_per_s,
    0.0,
    @types.boost_meter_max,
  )

  if game.boost_t > 0.0 {
    game.boost_t = @types.maxf(0.0, game.boost_t - dt)
  }

  if game.rush_cd > 0.0 {
    game.rush_cd = @types.maxf(0.0, game.rush_cd - dt)
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo_t = 0.0
      game.combo = 0
    }
  }

  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }
}

///|
fn update_prep_and_pot(game : @types.Game, dt : Float) -> Unit {
  let speed = boost_multiplier(game)

  if game.prep.active {
    game.prep.progress = game.prep.progress + dt * speed
    if game.prep.progress >= game.prep.target {
      game.prep.active = false
      game.prep.output_ready = true
      game.prep.out_kind = game.prep.kind
      game.prep.out_flavor = game.prep.flavor
      @types.set_message(game, "Prep finished. Collect with J.")
    }
  }

  if game.pot.cooking {
    game.pot.progress = game.pot.progress + dt * speed
    if game.pot.progress >= game.pot.target {
      game.pot.progress = game.pot.target
      game.pot.cooking = false
      game.pot.ready = true
      @types.set_message(game, "Pot done. Move to Serve Counter and press K.")
    }
  }
}

///|
fn update_order_patience(game : @types.Game, dt : Float) -> Unit {
  let mut i = 0
  while i < @types.max_orders {
    if not(game.orders[i].active) {
      i = i + 1
      continue
    }

    game.orders[i].pulse = game.orders[i].pulse + dt
    game.orders[i].patience = game.orders[i].patience - dt

    if game.orders[i].patience <= 0.0 {
      game.combo = 0
      game.combo_t = 0.0
      game.failed = game.failed + 1
      game.reputation = @types.clampf(
        game.reputation - @types.rep_loss_timeout,
        0.0,
        @types.reputation_max,
      )
      game.flash_t = 0.36
      @types.set_message(game, "A customer rage-quit from the queue.")
      remove_order_at(game, i)
      continue
    }

    i = i + 1
  }
}

///|
fn update_order_spawn(game : @types.Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt
  if game.spawn_cd > 0.0 {
    return
  }

  if active_order_count(game) < @types.max_orders {
    ignore(spawn_order(game))
    game.spawn_cd = spawn_interval(game.elapsed)
  } else {
    game.combo = 0
    game.combo_t = 0.0
    game.reputation = @types.clampf(
      game.reputation - 2.2,
      0.0,
      @types.reputation_max,
    )
    game.flash_t = 0.24
    @types.set_message(game, "Queue overflow pressure. Reputation dropped.")
    game.spawn_cd = 1.3
  }
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.input.press_start {
    start_run(game)
  }
}

///|
fn update_paused(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.input.press_pause || game.input.press_start {
    game.state = @types.state_playing
    @types.set_message(game, "Rush resumed.")
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }

  if game.input.press_start {
    game.state = @types.state_title
    @types.set_message(game, "Press J to start another shift.")
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = @types.state_paused
    @types.set_message(game, "Shift paused.")
    return
  }

  if game.input.move_x != 0 || game.input.move_y != 0 {
    move_cursor(game, game.input.move_x, game.input.move_y)
  }

  if game.input.press_boost {
    trigger_boost(game)
  }

  if game.input.press_interact {
    handle_interact(game)
  }

  if game.input.press_serve_cancel {
    handle_serve_cancel(game)
  }

  update_play_timers(game, dt)
  update_prep_and_pot(game, dt)
  update_order_patience(game, dt)
  update_order_spawn(game, dt)

  if game.reputation <= 0.0 {
    game.state = @types.state_game_over
    game.reputation = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.6
    @types.set_message(game, "Reputation collapsed. Service over.")
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)

  if game.input.press_restart {
    start_run(game)
    return
  }

  if game.state == @types.state_title {
    update_title(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else {
    update_game_over(game, dt)
  }
}
