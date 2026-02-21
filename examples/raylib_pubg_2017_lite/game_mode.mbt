///|
let rules_profile : Int = 6

///|
let rules_seed : Int = 61

///|
let rules_title : String = "Blitz Elimination"

///|
let rules_base_required : Bool = false

///|
fn mode_set_tile(game : Game, tx : Int, ty : Int, tile : Int, hp : Int) -> Unit {
  if not(in_tile_bounds(tx, ty)) {
    return
  }
  if get_tile(game, tx, ty) == tile_base {
    return
  }
  set_tile(game, tx, ty, tile, hp)
}

///|
fn mode_reinforce_base_ring(game : Game, steel : Bool) -> Unit {
  for i = 0; i < base_ring_count; i = i + 1 {
    let tx = base_ring_x[i]
    let ty = base_ring_y[i]
    let tile = get_tile(game, tx, ty)
    if tile == tile_base {
      continue i + 1
    }
    if steel {
      mode_set_tile(game, tx, ty, tile_steel, 999)
    } else {
      mode_set_tile(game, tx, ty, tile_brick, 1)
    }
  }
}

///|
fn mode_nearest_core_index(game : Game, x : Float, y : Float) -> Int {
  let mut best = -1
  let mut best_d = Float::from_int(1000000000)
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    let d = distance_sq(x, y, game.cores[i].x, game.cores[i].y)
    if d < best_d {
      best_d = d
      best = i
    }
  }
  best
}

///|
fn mode_stage_map_post(game : Game, stage : Int) -> Unit {
  let wave = stage + 1
  let center_x = map_tiles_w / 2
  let center_y = map_tiles_h / 2

  if rules_profile == 1 {
    mode_reinforce_base_ring(game, true)
    game.hazard_intensity = clampf(game.hazard_intensity + 0.24, 0.2, 3.4)

    for tx = 2; tx < map_tiles_w - 2; tx = tx + 1 {
      if tx % 6 != 0 {
        mode_set_tile(game, tx, 3, tile_brick, 1)
        mode_set_tile(game, tx, map_tiles_h - 4, tile_brick, 1)
      }
    }
  } else if rules_profile == 2 {
    for ty = 4; ty < map_tiles_h - 4; ty = ty + 4 {
      for tx = 3; tx < map_tiles_w - 3; tx = tx + 7 {
        if (tx + ty + rules_seed + wave) % 3 == 0 {
          mode_set_tile(game, tx, ty, tile_steel, 999)
        }
      }
    }
  } else if rules_profile == 3 {
    for ty = 2; ty < map_tiles_h - 2; ty = ty + 1 {
      for tx = 2; tx < map_tiles_w - 2; tx = tx + 1 {
        if get_tile(game, tx, ty) == tile_brick &&
          (tx * 11 + ty * 7 + rules_seed + wave) % 19 == 0 {
          mode_set_tile(game, tx, ty, tile_empty, 0)
        }
      }
    }
  } else if rules_profile == 4 {
    for tx = 1; tx < map_tiles_w - 1; tx = tx + 1 {
      for dy = -1; dy <= 1; dy = dy + 1 {
        mode_set_tile(game, tx, center_y + dy, tile_empty, 0)
      }
      if tx % 7 == 0 {
        mode_set_tile(game, tx, center_y - 3, tile_steel, 999)
        mode_set_tile(game, tx, center_y + 3, tile_steel, 999)
      }
    }
  } else if rules_profile == 5 {
    mode_reinforce_base_ring(game, true)
    game.hazard_intensity = clampf(game.hazard_intensity + 0.16, 0.2, 2.8)

    for tx = base_tile_x - 4; tx <= base_tile_x + 5; tx = tx + 1 {
      if tx == base_tile_x || tx == base_tile_x + 1 {
        mode_set_tile(game, tx, base_tile_y - 3, tile_empty, 0)
      } else {
        mode_set_tile(game, tx, base_tile_y - 3, tile_water, 1)
      }
    }
  } else if rules_profile == 6 {
    for tx = 1; tx < map_tiles_w - 1; tx = tx + 1 {
      mode_set_tile(game, tx, center_y, tile_empty, 0)
      if tx % 4 == 0 {
        mode_set_tile(game, tx, center_y - 2, tile_ice, 1)
        mode_set_tile(game, tx, center_y + 2, tile_ice, 1)
      }
    }
    for ty = 1; ty < map_tiles_h - 1; ty = ty + 1 {
      mode_set_tile(game, center_x, ty, tile_empty, 0)
    }
  } else if rules_profile == 7 {
    game.hazard_intensity = clampf(game.hazard_intensity + 0.35, 0.4, 3.8)

    for ty = 4; ty < map_tiles_h - 4; ty = ty + 5 {
      for tx = 3; tx < map_tiles_w - 3; tx = tx + 6 {
        if (tx + ty + rules_seed + wave) % 3 != 0 {
          mode_set_tile(game, tx, ty, tile_water, 1)
        }
      }
    }

    for ty = 2; ty < map_tiles_h - 2; ty = ty + 1 {
      if ty % 4 == 0 {
        mode_set_tile(game, center_x - 1, ty, tile_empty, 0)
        mode_set_tile(game, center_x + 1, ty, tile_empty, 0)
      }
    }
  } else if rules_profile == 8 {
    for ty = 2; ty < map_tiles_h - 2; ty = ty + 1 {
      for tx = 2; tx < map_tiles_w - 2; tx = tx + 1 {
        let r = (tx * 13 + ty * 7 + rules_seed + wave) % 41
        if r == 0 {
          mode_set_tile(game, tx, ty, tile_bush, 1)
        } else if r == 1 {
          mode_set_tile(game, tx, ty, tile_ice, 1)
        }
      }
    }
  } else if rules_profile == 9 {
    let left = map_tiles_w / 3
    let right = map_tiles_w - left - 1

    for ty = 2; ty < map_tiles_h - 2; ty = ty + 1 {
      if ty % 5 != 2 {
        mode_set_tile(game, left, ty, tile_steel, 999)
        mode_set_tile(game, right, ty, tile_steel, 999)
      }
    }

    for tx = center_x - 3; tx <= center_x + 3; tx = tx + 1 {
      if tx % 2 == 0 {
        mode_set_tile(game, tx, 5, tile_brick, 1)
        mode_set_tile(game, tx, map_tiles_h - 6, tile_brick, 1)
      }
    }
  }
}

///|
fn stage_score(game : Game) -> Int {
  clampi(game.score_total - game.mode_score_anchor, 0, 9999999)
}

///|
fn configure_mode_stage(game : Game, stage : Int) -> Unit {
  let wave = stage + 1

  game.mode_name = rules_title
  game.mode_base_required = rules_base_required
  game.mode_timer = 0.0
  game.mode_goal = 0
  game.mode_goal_b = 0
  game.mode_progress = 0
  game.mode_score_anchor = game.score_total

  if rules_profile == 0 {
    game.mode_goal = clampi(game.enemies_to_spawn + rules_seed % 14, 20, 96)
    game.enemies_to_spawn = game.mode_goal
    game.mode_goal_b = clampi(2 + wave / 4 + rules_seed % 2, 1, 8)
    if game.cores_goal < game.mode_goal_b {
      game.cores_goal = game.mode_goal_b
    }
    game.mode_hint = "Destroy all hostiles and secure core sites."
  } else if rules_profile == 1 {
    game.mode_goal = clampi(45 + wave * 2 + rules_seed % 14, 45, 130)
    game.mode_goal_b = clampi(3 + rules_seed % 5, 2, 7)
    game.enemies_to_spawn = clampi(150 + wave * 8 + rules_seed % 20, 90, 260)
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Survive the pressure window."
  } else if rules_profile == 2 {
    game.mode_goal = clampi(2 + wave / 3 + rules_seed % 3, 2, 11)
    game.mode_goal_b = clampi(6 + rules_seed % 4, 4, 10)
    game.enemies_to_spawn = clampi(
      game.enemies_to_spawn + 18 + rules_seed % 10,
      28,
      120,
    )
    game.mutator_enemy_hp_bonus += 2 + rules_seed % 3
    game.mutator_enemy_speed_scale +=
      Float::from_int(rules_seed % 3) * Float::from_double(0.02)
    if game.cores_goal > 2 {
      game.cores_goal = 2
    }
    game.mode_hint = "Hunt elite commanders."
  } else if rules_profile == 3 {
    game.mode_goal = 1800 + wave * 160 + (rules_seed % 9) * 75
    game.mode_goal_b = clampi(80 + wave * 3 + rules_seed % 40, 70, 170)
    game.enemies_to_spawn = clampi(130 + wave * 7 + rules_seed % 16, 80, 220)
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Reach the score threshold quickly."
  } else if rules_profile == 4 {
    game.mode_goal = clampi(2 + wave / 4 + rules_seed % 2, 2, 8)
    game.mode_goal_b = 14 + rules_seed % 7
    game.enemies_to_spawn = clampi(
      game.enemies_to_spawn + 8 + rules_seed % 8,
      24,
      100,
    )
    if game.cores_goal < game.mode_goal {
      game.cores_goal = game.mode_goal
    }
    game.mode_hint = "Destroy relay cores then extract."
  } else if rules_profile == 5 {
    game.mode_goal = clampi(52 + wave * 2 + rules_seed % 12, 55, 130)
    game.mode_goal_b = clampi(2 + rules_seed % 4, 2, 8)
    game.enemies_to_spawn = clampi(160 + wave * 9 + rules_seed % 18, 120, 280)
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Hold the base under sustained siege."
  } else if rules_profile == 6 {
    game.mode_goal = clampi(42 + wave + rules_seed % 10, 40, 90)
    game.mode_goal_b = 0
    game.enemies_to_spawn = clampi(
      game.enemies_to_spawn + 4 + rules_seed % 6,
      18,
      72,
    )
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Clear the wave before timeout."
  } else if rules_profile == 7 {
    game.mode_goal = clampi(46 + wave * 2 + rules_seed % 10, 46, 120)
    game.mode_goal_b = clampi(3 + rules_seed % 4 + wave / 10, 3, 10)
    game.enemies_to_spawn = clampi(140 + wave * 8 + rules_seed % 20, 100, 240)
    game.hazard_intensity = clampf(game.hazard_intensity + 0.35, 0.5, 3.8)
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Control hazard damage while pushing forward."
  } else if rules_profile == 8 {
    game.mode_goal = clampi(2 + wave / 4 + rules_seed % 3, 2, 9)
    game.mode_goal_b = clampi(3 + wave / 5 + rules_seed % 2, 3, 10)
    game.enemies_to_spawn = clampi(120 + wave * 6 + rules_seed % 20, 80, 220)
    if game.cores_goal < game.mode_goal {
      game.cores_goal = game.mode_goal
    }
    game.mode_hint = "Destroy cores and defeat elite guards."
  } else {
    game.mode_goal = clampi(2 + wave / 5 + rules_seed % 3, 2, 8)
    game.mode_goal_b = 1200 + wave * 120 + (rules_seed % 7) * 60
    game.enemies_to_spawn = clampi(125 + wave * 7 + rules_seed % 18, 90, 230)
    game.cores_goal = 0
    clear_cores(game)
    game.mode_hint = "Stack score and elite kills."
  }
}

///|
fn mode_on_enemy_spawn(game : Game, enemy : Tank, stage : Int) -> Unit {
  let wave = stage + 1

  if rules_profile == 0 {
    enemy.ai_move_timer *= 0.84
    enemy.ai_fire_timer *= 0.82
  } else if rules_profile == 1 {
    enemy.reload_delay *= 0.92
    enemy.move_speed *= 0.93
  } else if rules_profile == 2 {
    if rand_range(game, 0, 99) < clampi(24 + wave / 2, 18, 52) {
      enemy.elite_rank = clampi(enemy.elite_rank + 1, 1, 3)
      enemy.hp += 2 + wave / 6
      enemy.max_hp = enemy.hp
      enemy.reload_delay *= 0.85
      enemy.move_speed *= 1.04
    }
  } else if rules_profile == 3 {
    enemy.reload_delay *= 0.84
  } else if rules_profile == 4 {
    enemy.move_speed *= 1.08
  } else if rules_profile == 5 {
    enemy.hp += 1 + wave / 8
    enemy.max_hp = enemy.hp
    enemy.reload_delay *= 0.90
  } else if rules_profile == 6 {
    enemy.move_speed *= 1.20
    enemy.reload_delay *= 0.82
  } else if rules_profile == 7 {
    enemy.move_speed *= 1.10
    enemy.reload_delay *= 1.06
  } else if rules_profile == 8 {
    enemy.hp += wave / 10
    enemy.max_hp = enemy.hp
    enemy.move_speed *= 0.96
  } else {
    enemy.reload_delay *= 0.90
    if rand_range(game, 0, 99) < 12 {
      enemy.hp += 1
      enemy.max_hp = enemy.hp
    }
  }

  enemy.reload_delay = clampf(enemy.reload_delay, 0.16, 1.8)
  enemy.move_speed = clampf(enemy.move_speed, 55.0, 245.0)
}

///|
fn mode_enemy_ai_tick(game : Game, enemy : Tank, dt : Float) -> Unit {
  if rules_profile == 0 {
    enemy.ai_fire_timer -= dt * 0.15
  } else if rules_profile == 1 {
    let base_x = tile_center_x(base_tile_x)
    let base_y = tile_center_y(base_tile_y)
    if distance_sq(enemy.x, enemy.y, base_x, base_y) < 240.0 * 240.0 {
      enemy.ai_fire_timer -= dt * 0.32
    } else {
      enemy.ai_move_timer += dt * 0.08
    }
  } else if rules_profile == 2 {
    if enemy.elite_rank > 0 {
      enemy.ai_fire_timer -= dt * 0.28
      enemy.ai_move_timer -= dt * 0.16
    }
  } else if rules_profile == 3 {
    let ramp = clampf(game.mode_timer / 90.0, 0.0, 0.32)
    enemy.ai_move_timer -= dt * ramp
    enemy.ai_fire_timer -= dt * ramp
  } else if rules_profile == 4 {
    if absf(enemy.y - Float::from_int(map_pixel_h / 2)) < Float::from_int(tile_size * 2) {
      enemy.dir = if enemy.x < Float::from_int(map_pixel_w / 2) {
        dir_right
      } else {
        dir_left
      }
    }
  } else if rules_profile == 5 {
    let base_x = tile_center_x(base_tile_x)
    let base_y = tile_center_y(base_tile_y)
    if distance_sq(enemy.x, enemy.y, base_x, base_y) < 220.0 * 220.0 {
      enemy.ai_fire_timer -= dt * 0.42
    }
  } else if rules_profile == 6 {
    enemy.ai_move_timer -= dt * 0.45
    enemy.ai_fire_timer -= dt * 0.38
  } else if rules_profile == 7 {
    if rand_range(game, 0, 99) < 4 {
      enemy.dir = rand_range(game, 0, 3)
    }
    enemy.ai_fire_timer += dt * 0.12
  } else if rules_profile == 8 {
    let idx = mode_nearest_core_index(game, enemy.x, enemy.y)
    if idx >= 0 {
      let core = game.cores[idx]
      let dx = core.x - enemy.x
      let dy = core.y - enemy.y
      if absf(dx) > absf(dy) {
        enemy.dir = if dx < 0.0 { dir_left } else { dir_right }
      } else {
        enemy.dir = if dy < 0.0 { dir_up } else { dir_down }
      }
      enemy.ai_move_timer -= dt * 0.22
    }
  } else {
    let cadence = (game.stage_timer.to_int() + rules_seed) % 7
    if cadence == 0 {
      enemy.ai_fire_timer -= dt * 0.30
    } else if cadence < 3 {
      enemy.ai_move_timer -= dt * 0.18
    }
    if rand_range(game, 0, 199) == 0 {
      enemy.dir = enemy_desired_dir(game, enemy)
    }
  }
}

///|
fn update_mode(game : Game, dt : Float) -> Unit {
  game.mode_timer += dt

  if rules_profile == 0 {
    game.mode_progress =
      game.enemies_spawned - game.enemies_alive + game.cores_destroyed * 4
    let remaining = clampi(
      game.enemies_to_spawn - game.enemies_spawned + game.enemies_alive,
      0,
      999,
    )
    game.mode_hint =
      "Sweep \{remaining} left | Sites \{game.cores_destroyed}/\{game.cores_goal}"
  } else if rules_profile == 1 {
    game.mode_progress = game.mode_timer.to_int()
    let remain = clampi(game.mode_goal - game.mode_progress, 0, game.mode_goal)
    game.mode_hint = "Survive \{remain}s | Threat \{game.enemies_alive}"
  } else if rules_profile == 2 {
    game.mode_progress = game.stage_elite_kills
    game.mode_hint =
      "Elites \{game.stage_elite_kills}/\{game.mode_goal} | Hostiles \{game.enemies_alive}"
  } else if rules_profile == 3 {
    game.mode_progress = stage_score(game)
    let remain = clampi(game.mode_goal - game.mode_progress, 0, game.mode_goal)
    game.mode_hint = "Score \{game.mode_progress}/\{game.mode_goal} | Need \{remain}"
  } else if rules_profile == 4 {
    game.mode_progress = game.cores_destroyed
    game.mode_hint =
      "Relays \{game.cores_destroyed}/\{game.mode_goal} | Extract after \{game.mode_goal_b}s"
  } else if rules_profile == 5 {
    game.mode_progress = game.mode_timer.to_int()
    let remain = clampi(game.mode_goal - game.mode_progress, 0, game.mode_goal)
    game.mode_hint = "Hold \{remain}s | Siege \{game.enemies_alive}"
  } else if rules_profile == 6 {
    game.mode_progress = game.enemies_spawned - game.enemies_alive
    let remain = clampi(game.mode_goal - game.mode_timer.to_int(), 0, game.mode_goal)
    game.mode_hint = "Blitz \{game.mode_progress}/\{game.enemies_to_spawn} | \{remain}s"
  } else if rules_profile == 7 {
    game.mode_progress = game.mode_timer.to_int()
    game.mode_hint =
      "Hazard hits \{game.stage_hazard_hits}/\{game.mode_goal_b} | Time \{game.mode_progress}/\{game.mode_goal}s"
  } else if rules_profile == 8 {
    game.mode_progress = game.cores_destroyed * 10 + game.stage_elite_kills
    game.mode_hint =
      "Cores \{game.cores_destroyed}/\{game.mode_goal} + Elites \{game.stage_elite_kills}/\{game.mode_goal_b}"
  } else {
    game.mode_progress = game.stage_elite_kills * 100 + stage_score(game)
    game.mode_hint =
      "Elites \{game.stage_elite_kills}/\{game.mode_goal} | Score \{stage_score(game)}/\{game.mode_goal_b}"
  }
}

///|
fn mode_stage_failed(game : Game) -> Bool {
  if game.mode_base_required && not(game.base_alive) {
    return true
  }

  if rules_profile == 6 {
    game.mode_timer > Float::from_int(game.mode_goal)
  } else if rules_profile == 7 {
    game.stage_hazard_hits > game.mode_goal_b
  } else {
    false
  }
}

///|
fn mode_stage_clear(game : Game) -> Bool {
  if rules_profile == 0 {
    game.enemies_spawned >= game.enemies_to_spawn &&
    game.enemies_alive <= 0 &&
    core_objective_done(game)
  } else if rules_profile == 1 {
    game.mode_timer >= Float::from_int(game.mode_goal) &&
    game.enemies_alive <= game.mode_goal_b
  } else if rules_profile == 2 {
    game.stage_elite_kills >= game.mode_goal &&
    game.enemies_alive <= game.mode_goal_b &&
    core_objective_done(game)
  } else if rules_profile == 3 {
    stage_score(game) >= game.mode_goal
  } else if rules_profile == 4 {
    game.cores_destroyed >= game.mode_goal &&
    game.mode_timer >= Float::from_int(game.mode_goal_b) &&
    game.enemies_alive <= 6
  } else if rules_profile == 5 {
    game.mode_timer >= Float::from_int(game.mode_goal) &&
    game.enemies_alive <= game.mode_goal_b &&
    game.base_alive
  } else if rules_profile == 6 {
    game.enemies_spawned >= game.enemies_to_spawn &&
    game.enemies_alive <= 0 &&
    game.mode_timer <= Float::from_int(game.mode_goal)
  } else if rules_profile == 7 {
    game.mode_timer >= Float::from_int(game.mode_goal) &&
    game.stage_hazard_hits <= game.mode_goal_b &&
    game.enemies_alive <= 6
  } else if rules_profile == 8 {
    game.cores_destroyed >= game.mode_goal &&
    game.stage_elite_kills >= game.mode_goal_b
  } else {
    game.stage_elite_kills >= game.mode_goal &&
    stage_score(game) >= game.mode_goal_b
  }
}
