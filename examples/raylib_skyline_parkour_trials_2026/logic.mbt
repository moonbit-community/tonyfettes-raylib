///|
fn overlap_rect(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
fn clear_stage_data(game : Game) -> Unit {
  game.tile_count = 0
  game.checkpoint_count = 0
}

///|
fn push_tile(
  game : Game,
  kind : Int,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Unit {
  if game.tile_count >= max_tiles {
    return
  }

  let i = game.tile_count
  game.tiles[i].kind = kind
  game.tiles[i].x = x
  game.tiles[i].y = y
  game.tiles[i].w = w
  game.tiles[i].h = h
  game.tile_count = i + 1
}

///|
fn push_solid(game : Game, x : Float, y : Float, w : Float, h : Float) -> Unit {
  push_tile(game, tile_solid, x, y, w, h)
}

///|
fn push_hazard(game : Game, x : Float, y : Float, w : Float, h : Float) -> Unit {
  push_tile(game, tile_hazard, x, y, w, h)
}

///|
fn push_checkpoint(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  bonus_s : Int,
) -> Unit {
  if game.checkpoint_count >= max_checkpoints {
    return
  }

  let i = game.checkpoint_count
  game.checkpoints[i].x = x
  game.checkpoints[i].y = y
  game.checkpoints[i].w = w
  game.checkpoints[i].h = h
  game.checkpoints[i].bonus_s = bonus_s
  game.checkpoints[i].taken = false
  game.checkpoint_count = i + 1
}

///|
fn set_goal(game : Game, x : Float, y : Float, w : Float, h : Float) -> Unit {
  game.goal_x = x
  game.goal_y = y
  game.goal_w = w
  game.goal_h = h
}

///|
fn reset_hero_to_start(game : Game) -> Unit {
  let hero = game.hero
  hero.x = game.start_x
  hero.y = game.start_y
  hero.vx = 0.0
  hero.vy = 0.0
  hero.on_ground = false
  hero.wall_side = 0
  hero.wall_window_t = 0.0
  hero.wall_climb_t = wall_climb_time_max
  hero.coyote_t = 0.0
  hero.jump_buffer_t = 0.0
  hero.facing = 1
}

///|
fn setup_stage_1(game : Game) -> Unit {
  game.stage_width = 2800.0
  game.stage_fail_y = Float::from_int(screen_h) + stage_fail_y_pad
  game.start_x = 96.0
  game.start_y = 568.0

  push_solid(game, 0.0, 622.0, 420.0, 220.0)
  push_solid(game, 520.0, 562.0, 260.0, 280.0)
  push_solid(game, 890.0, 504.0, 220.0, 338.0)
  push_solid(game, 1180.0, 340.0, 38.0, 502.0)
  push_solid(game, 1268.0, 430.0, 220.0, 412.0)
  push_solid(game, 1518.0, 262.0, 36.0, 580.0)
  push_solid(game, 1600.0, 342.0, 250.0, 500.0)
  push_solid(game, 1960.0, 254.0, 280.0, 588.0)
  push_solid(game, 2360.0, 196.0, 310.0, 646.0)

  push_hazard(game, 560.0, 532.0, 100.0, 20.0)
  push_hazard(game, 1660.0, 312.0, 90.0, 18.0)

  push_checkpoint(game, 730.0, 500.0, 36.0, 60.0, 6)
  push_checkpoint(game, 1460.0, 368.0, 36.0, 60.0, 7)

  set_goal(game, 2480.0, 118.0, 100.0, 74.0)
}

///|
fn setup_stage_2(game : Game) -> Unit {
  game.stage_width = 3200.0
  game.stage_fail_y = Float::from_int(screen_h) + stage_fail_y_pad
  game.start_x = 94.0
  game.start_y = 588.0

  push_solid(game, 0.0, 642.0, 360.0, 200.0)
  push_solid(game, 450.0, 586.0, 220.0, 256.0)
  push_solid(game, 730.0, 528.0, 200.0, 314.0)
  push_solid(game, 978.0, 420.0, 36.0, 422.0)
  push_solid(game, 1048.0, 492.0, 200.0, 350.0)
  push_solid(game, 1298.0, 360.0, 36.0, 482.0)
  push_solid(game, 1378.0, 430.0, 200.0, 412.0)
  push_solid(game, 1628.0, 286.0, 36.0, 556.0)
  push_solid(game, 1708.0, 356.0, 210.0, 486.0)
  push_solid(game, 1962.0, 224.0, 36.0, 618.0)
  push_solid(game, 2040.0, 312.0, 220.0, 530.0)
  push_solid(game, 2310.0, 180.0, 36.0, 662.0)
  push_solid(game, 2390.0, 262.0, 220.0, 580.0)
  push_solid(game, 2680.0, 150.0, 300.0, 692.0)

  push_hazard(game, 468.0, 556.0, 94.0, 18.0)
  push_hazard(game, 1738.0, 326.0, 96.0, 18.0)
  push_hazard(game, 2430.0, 232.0, 100.0, 18.0)

  push_checkpoint(game, 900.0, 472.0, 36.0, 56.0, 6)
  push_checkpoint(game, 1778.0, 300.0, 36.0, 56.0, 7)
  push_checkpoint(game, 2550.0, 206.0, 36.0, 56.0, 8)

  set_goal(game, 2780.0, 76.0, 110.0, 78.0)
}

///|
fn setup_stage_3(game : Game) -> Unit {
  game.stage_width = 3600.0
  game.stage_fail_y = Float::from_int(screen_h) + stage_fail_y_pad
  game.start_x = 92.0
  game.start_y = 598.0

  push_solid(game, 0.0, 652.0, 300.0, 220.0)
  push_solid(game, 390.0, 594.0, 180.0, 278.0)
  push_solid(game, 640.0, 536.0, 170.0, 336.0)
  push_solid(game, 850.0, 472.0, 170.0, 400.0)
  push_solid(game, 1038.0, 370.0, 36.0, 502.0)
  push_solid(game, 1112.0, 444.0, 170.0, 428.0)
  push_solid(game, 1362.0, 320.0, 36.0, 552.0)
  push_solid(game, 1438.0, 392.0, 170.0, 480.0)
  push_solid(game, 1686.0, 260.0, 36.0, 612.0)
  push_solid(game, 1762.0, 332.0, 170.0, 540.0)
  push_solid(game, 1998.0, 214.0, 36.0, 658.0)
  push_solid(game, 2074.0, 292.0, 170.0, 580.0)
  push_solid(game, 2308.0, 168.0, 36.0, 704.0)
  push_solid(game, 2382.0, 252.0, 170.0, 620.0)
  push_solid(game, 2614.0, 126.0, 36.0, 746.0)
  push_solid(game, 2688.0, 212.0, 170.0, 660.0)
  push_solid(game, 2928.0, 96.0, 250.0, 776.0)
  push_solid(game, 3236.0, 70.0, 280.0, 802.0)

  push_hazard(game, 408.0, 564.0, 90.0, 18.0)
  push_hazard(game, 1458.0, 362.0, 92.0, 18.0)
  push_hazard(game, 2396.0, 222.0, 100.0, 18.0)
  push_hazard(game, 2960.0, 66.0, 130.0, 18.0)

  push_checkpoint(game, 798.0, 486.0, 36.0, 50.0, 7)
  push_checkpoint(game, 1818.0, 286.0, 36.0, 46.0, 8)
  push_checkpoint(game, 2766.0, 166.0, 36.0, 46.0, 9)

  set_goal(game, 3340.0, 6.0, 120.0, 86.0)
}

///|
fn load_stage(game : Game, stage : Int) -> Unit {
  clear_stage_data(game)
  game.stage = clampi(stage, 1, stage_count)
  game.pending_next_stage = 0
  game.stage_time_s = 0.0
  game.bonus_popup_t = 0.0
  game.bonus_popup_value = 0
  game.lose_reason = lose_none

  if game.stage == 1 {
    setup_stage_1(game)
  } else if game.stage == 2 {
    setup_stage_2(game)
  } else {
    setup_stage_3(game)
  }

  reset_hero_to_start(game)
}

///|
fn init_title_scene(game : Game) -> Unit {
  load_stage(game, 1)
  game.state = state_title
  game.timer_s = stage_initial_time(1)
  game.run_time_s = 0.0
  game.checkpoints_hit = 0
}

///|
fn begin_new_run(game : Game) -> Unit {
  game.timer_s = stage_initial_time(1)
  game.run_time_s = 0.0
  game.checkpoints_hit = 0
  load_stage(game, 1)
  game.state = state_play
}

///|
fn fail_run(game : Game, reason : Int) -> Unit {
  game.lose_reason = reason
  game.state = state_game_over
  game.pending_next_stage = 0
}

///|
fn add_bonus_time(game : Game, amount_s : Int) -> Unit {
  game.timer_s = minf(timer_cap, game.timer_s + Float::from_int(amount_s))
  game.bonus_popup_value = amount_s
  game.bonus_popup_t = 1.1
}

///|
fn hero_hits_hazard(game : Game) -> Bool {
  let hero = game.hero
  for i = 0; i < game.tile_count; i = i + 1 {
    let t = game.tiles[i]
    if t.kind != tile_hazard {
      continue
    }

    if overlap_rect(hero.x, hero.y, player_w, player_h, t.x, t.y, t.w, t.h) {
      return true
    }
  }
  false
}

///|
fn collect_checkpoints(game : Game) -> Unit {
  let hero = game.hero
  for i = 0; i < game.checkpoint_count; i = i + 1 {
    if game.checkpoints[i].taken {
      continue
    }

    let cp = game.checkpoints[i]
    if overlap_rect(hero.x, hero.y, player_w, player_h, cp.x, cp.y, cp.w, cp.h) {
      game.checkpoints[i].taken = true
      game.checkpoints_hit = game.checkpoints_hit + 1
      add_bonus_time(game, cp.bonus_s)
    }
  }
}

///|
fn hero_reached_goal(game : Game) -> Bool {
  let hero = game.hero
  overlap_rect(
    hero.x,
    hero.y,
    player_w,
    player_h,
    game.goal_x,
    game.goal_y,
    game.goal_w,
    game.goal_h,
  )
}

///|
fn move_hero_x(game : Game, dt : Float) -> Unit {
  let hero = game.hero
  hero.wall_side = 0

  hero.x = hero.x + hero.vx * dt

  if hero.x < 0.0 {
    hero.x = 0.0
    hero.vx = 0.0
    hero.wall_side = -1
    hero.wall_window_t = wall_jump_window
  }

  if hero.x + player_w > game.stage_width {
    hero.x = game.stage_width - player_w
    hero.vx = 0.0
    hero.wall_side = 1
    hero.wall_window_t = wall_jump_window
  }

  for i = 0; i < game.tile_count; i = i + 1 {
    let t = game.tiles[i]
    if t.kind != tile_solid {
      continue
    }

    if overlap_rect(hero.x, hero.y, player_w, player_h, t.x, t.y, t.w, t.h) {
      if hero.vx > 0.0 {
        hero.x = t.x - player_w
        hero.vx = 0.0
        hero.wall_side = 1
        hero.wall_window_t = wall_jump_window
      } else if hero.vx < 0.0 {
        hero.x = t.x + t.w
        hero.vx = 0.0
        hero.wall_side = -1
        hero.wall_window_t = wall_jump_window
      }
    }
  }
}

///|
fn move_hero_y(game : Game, dt : Float) -> Unit {
  let hero = game.hero
  hero.on_ground = false
  hero.y = hero.y + hero.vy * dt

  for i = 0; i < game.tile_count; i = i + 1 {
    let t = game.tiles[i]
    if t.kind != tile_solid {
      continue
    }

    if overlap_rect(hero.x, hero.y, player_w, player_h, t.x, t.y, t.w, t.h) {
      if hero.vy > 0.0 {
        hero.y = t.y - player_h
        hero.vy = 0.0
        hero.on_ground = true
        hero.coyote_t = coyote_time
        hero.wall_climb_t = wall_climb_time_max
      } else if hero.vy < 0.0 {
        hero.y = t.y + t.h
        hero.vy = 0.0
      }
    }
  }
}

///|
fn apply_jump_buffer(hero : Player, jump_pressed : Bool, dt : Float) -> Unit {
  hero.jump_buffer_t = maxf(0.0, hero.jump_buffer_t - dt)
  if jump_pressed {
    hero.jump_buffer_t = jump_buffer_time
  }
}

///|
fn update_hero_movement(game : Game, dt : Float) -> Unit {
  let hero = game.hero

  hero.coyote_t = maxf(0.0, hero.coyote_t - dt)
  hero.wall_window_t = maxf(0.0, hero.wall_window_t - dt)

  if hero.on_ground {
    hero.coyote_t = coyote_time
    hero.wall_climb_t = wall_climb_time_max
  } else if hero.wall_side != 0 {
    hero.wall_window_t = wall_jump_window
  }

  apply_jump_buffer(hero, game.input_jump_press, dt)

  let accel = if hero.on_ground { run_accel_ground } else { run_accel_air }
  hero.vx = hero.vx + game.input_x * accel * dt

  if absf(game.input_x) < 0.01 {
    let drag = if hero.on_ground { run_drag_ground } else { run_drag_air }
    hero.vx = approachf(hero.vx, 0.0, drag * dt)
  } else if game.input_x > 0.0 {
    hero.facing = 1
  } else {
    hero.facing = -1
  }

  hero.vx = clampf(hero.vx, -run_max_speed, run_max_speed)

  if not(hero.on_ground) && hero.wall_window_t > 0.0 {
    hero.vy = minf(hero.vy, wall_slide_speed)
    if game.input_climb_hold && hero.wall_climb_t > 0.0 {
      hero.vy = maxf(hero.vy - wall_climb_up_accel * dt, -wall_climb_up_speed)
      hero.wall_climb_t = maxf(0.0, hero.wall_climb_t - dt)
    }
  }

  if hero.jump_buffer_t > 0.0 {
    if hero.coyote_t > 0.0 {
      hero.vy = -jump_speed
      hero.on_ground = false
      hero.coyote_t = 0.0
      hero.jump_buffer_t = 0.0
    } else if hero.wall_window_t > 0.0 && hero.wall_side != 0 {
      hero.vy = -wall_jump_speed
      hero.vx = Float::from_int(-hero.wall_side) * wall_jump_push
      hero.jump_buffer_t = 0.0
      hero.wall_window_t = 0.0
    }
  }

  if not(game.input_jump_hold) && hero.vy < 0.0 {
    hero.vy = hero.vy + jump_cut_gravity * dt
  }

  hero.vy = minf(max_fall_speed, hero.vy + gravity * dt)

  move_hero_x(game, dt)
  move_hero_y(game, dt)
}

///|
fn finish_stage(game : Game) -> Unit {
  if game.stage < stage_count {
    let bonus = stage_clear_bonus(game.stage)
    if bonus > 0 {
      add_bonus_time(game, bonus)
    }
    game.pending_next_stage = game.stage + 1
    game.state = state_stage_clear
  } else {
    game.pending_next_stage = 0
    game.state = state_victory
  }
}

///|
fn update_play_state(game : Game, dt : Float) -> Unit {
  if game.input_restart_press {
    begin_new_run(game)
    return
  }

  game.timer_s = maxf(0.0, game.timer_s - dt)
  game.run_time_s = game.run_time_s + dt
  game.stage_time_s = game.stage_time_s + dt
  game.bonus_popup_t = maxf(0.0, game.bonus_popup_t - dt)

  if game.timer_s <= 0.0 {
    fail_run(game, lose_time)
    return
  }

  update_hero_movement(game, dt)

  if game.hero.y > game.stage_fail_y {
    fail_run(game, lose_fall)
    return
  }

  if hero_hits_hazard(game) {
    fail_run(game, lose_hazard)
    return
  }

  collect_checkpoints(game)

  if hero_reached_goal(game) {
    finish_stage(game)
  }
}

///|
fn update_stage_clear_state(game : Game) -> Unit {
  if game.input_restart_press {
    begin_new_run(game)
    return
  }

  if game.input_next_press {
    if game.pending_next_stage > 0 && game.pending_next_stage <= stage_count {
      let next_stage = game.pending_next_stage
      load_stage(game, next_stage)
      game.state = state_play
    } else {
      game.state = state_victory
    }
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input_restart_press || game.input_next_press {
    begin_new_run(game)
  }
}

///|
fn update_victory_state(game : Game) -> Unit {
  if game.input_next_press || game.input_restart_press {
    init_title_scene(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.state == state_title {
    if game.input_next_press {
      begin_new_run(game)
    }
    return
  }

  if game.state == state_play {
    update_play_state(game, dt)
    return
  }

  game.bonus_popup_t = maxf(0.0, game.bonus_popup_t - dt)

  if game.state == state_stage_clear {
    update_stage_clear_state(game)
  } else if game.state == state_game_over {
    update_game_over_state(game)
  } else {
    update_victory_state(game)
  }
}
