///|
fn reset_stage_runtime_counters(game : Game) -> Unit {
  game.stage_timer = 0.0
  game.stage_deaths = 0
  game.stage_base_losses = 0
  game.stage_elite_kills = 0
  game.stage_hazard_hits = 0
  game.contracts_completed_stage = 0
}

///|
fn mutator_param_index(stage : Int) -> Int {
  stage % mutator_name_bank.length()
}

///|
fn assign_stage_briefing(game : Game, stage : Int) -> Unit {
  game.mission_title = mission_title_for_stage(stage)
  game.mission_brief = mission_brief_for_stage(stage)
  game.mutator_name = mutator_name_for_stage(stage)
  game.mutator_desc = mutator_desc_for_stage(stage)
}

///|
fn mutator_spawn_scale_from_index(idx : Int) -> Float {
  if idx == 0 {
    1.00
  } else if idx == 1 {
    0.94
  } else if idx == 2 {
    0.86
  } else if idx == 3 {
    0.92
  } else if idx == 4 {
    0.88
  } else if idx == 5 {
    0.98
  } else if idx == 6 {
    0.90
  } else if idx == 7 {
    0.95
  } else if idx == 8 {
    0.91
  } else if idx == 9 {
    0.93
  } else if idx == 10 {
    0.89
  } else if idx == 11 {
    0.97
  } else if idx == 12 {
    0.84
  } else if idx == 13 {
    0.90
  } else if idx == 14 {
    0.92
  } else {
    0.87
  }
}

///|
fn mutator_enemy_hp_bonus_from_index(idx : Int, stage : Int) -> Int {
  let depth = clampi(stage / 6, 0, 7)
  if idx == 0 {
    depth
  } else if idx == 1 {
    1 + depth
  } else if idx == 2 {
    depth
  } else if idx == 3 {
    2 + depth
  } else if idx == 4 {
    1 + depth
  } else if idx == 5 {
    2 + depth
  } else if idx == 6 {
    1 + depth
  } else if idx == 7 {
    depth
  } else if idx == 8 {
    3 + depth
  } else if idx == 9 {
    depth
  } else if idx == 10 {
    2 + depth
  } else if idx == 11 {
    1 + depth
  } else if idx == 12 {
    2 + depth
  } else if idx == 13 {
    2 + depth
  } else if idx == 14 {
    1 + depth
  } else {
    3 + depth
  }
}

///|
fn mutator_enemy_speed_scale_from_index(idx : Int, stage : Int) -> Float {
  let depth = Float::from_int(clampi(stage / 16, 0, 4)) * 0.02
  if idx == 0 {
    1.0 + depth
  } else if idx == 1 {
    1.05 + depth
  } else if idx == 2 {
    1.12 + depth
  } else if idx == 3 {
    1.02 + depth
  } else if idx == 4 {
    1.09 + depth
  } else if idx == 5 {
    0.98 + depth
  } else if idx == 6 {
    1.07 + depth
  } else if idx == 7 {
    1.06 + depth
  } else if idx == 8 {
    0.96 + depth
  } else if idx == 9 {
    1.03 + depth
  } else if idx == 10 {
    1.08 + depth
  } else if idx == 11 {
    1.02 + depth
  } else if idx == 12 {
    1.10 + depth
  } else if idx == 13 {
    1.11 + depth
  } else if idx == 14 {
    1.04 + depth
  } else {
    1.13 + depth
  }
}

///|
fn mutator_score_scale_from_index(idx : Int) -> Float {
  if idx == 0 {
    1.00
  } else if idx == 1 {
    1.08
  } else if idx == 2 {
    1.14
  } else if idx == 3 {
    1.10
  } else if idx == 4 {
    1.12
  } else if idx == 5 {
    1.06
  } else if idx == 6 {
    1.11
  } else if idx == 7 {
    1.09
  } else if idx == 8 {
    1.15
  } else if idx == 9 {
    1.13
  } else if idx == 10 {
    1.12
  } else if idx == 11 {
    1.08
  } else if idx == 12 {
    1.17
  } else if idx == 13 {
    1.16
  } else if idx == 14 {
    1.14
  } else {
    1.19
  }
}

///|
fn mutator_hazard_intensity_from_index(idx : Int, stage : Int) -> Float {
  let depth = Float::from_int(clampi(stage / 12, 0, 6)) * 0.05
  if idx == 0 {
    0.72 + depth
  } else if idx == 1 {
    1.04 + depth
  } else if idx == 2 {
    0.94 + depth
  } else if idx == 3 {
    0.82 + depth
  } else if idx == 4 {
    1.08 + depth
  } else if idx == 5 {
    0.88 + depth
  } else if idx == 6 {
    1.18 + depth
  } else if idx == 7 {
    0.91 + depth
  } else if idx == 8 {
    1.12 + depth
  } else if idx == 9 {
    0.98 + depth
  } else if idx == 10 {
    1.03 + depth
  } else if idx == 11 {
    0.86 + depth
  } else if idx == 12 {
    1.21 + depth
  } else if idx == 13 {
    1.16 + depth
  } else if idx == 14 {
    1.07 + depth
  } else {
    1.24 + depth
  }
}

///|
fn setup_stage_mutator(game : Game, stage : Int) -> Unit {
  let idx = mutator_param_index(stage)
  assign_stage_briefing(game, stage)
  game.mutator_spawn_scale = mutator_spawn_scale_from_index(idx)
  game.mutator_enemy_hp_bonus = mutator_enemy_hp_bonus_from_index(idx, stage)
  game.mutator_enemy_speed_scale = mutator_enemy_speed_scale_from_index(idx, stage)
  game.mutator_score_scale = mutator_score_scale_from_index(idx)
  game.hazard_intensity = mutator_hazard_intensity_from_index(idx, stage)
  game.hazard_spawn_timer = hazard_spawn_base * (1.3 - game.hazard_intensity * 0.25)
  if game.hazard_spawn_timer < 2.8 {
    game.hazard_spawn_timer = 2.8
  }
}

///|
fn mutator_stage_spawn_scale(game : Game) -> Float {
  game.profile.spawn_scale * game.mutator_spawn_scale
}

///|
fn mutator_score_value(game : Game, base_points : Int) -> Int {
  let scaled = (Float::from_int(base_points) * game.mutator_score_scale).to_int()
  clampi(scaled, 1, 1000000000)
}

///|
fn mutator_elite_roll_chance(game : Game, stage : Int) -> Int {
  let stage_bonus = clampi(stage / 4, 0, 12) * elite_spawn_stage_bonus
  let intensity_bonus = clampi((game.hazard_intensity * 10.0).to_int(), 0, 6)
  clampi(elite_spawn_base_chance + stage_bonus + intensity_bonus, 8, 78)
}

///|
fn mutator_apply_enemy_stats(game : Game, enemy : Tank, stage : Int) -> Unit {
  let hp_bonus = clampi(game.mutator_enemy_hp_bonus, 0, 18)
  enemy.hp += hp_bonus
  enemy.max_hp = enemy.hp
  enemy.move_speed *= clampf(game.mutator_enemy_speed_scale, 0.85, 1.35)

  let elite_roll = rand_range(game, 0, 99)
  let elite_chance = mutator_elite_roll_chance(game, stage)
  if elite_roll < elite_chance {
    enemy.elite_rank = 1
    enemy.hp += elite_bonus_hp + clampi(stage / 10, 0, 5)
    enemy.max_hp = enemy.hp
    enemy.move_speed *= 1.06
    enemy.reload_delay *= 0.88
  }

  if stage >= 12 && stage % 6 == 0 && rand_range(game, 0, 99) < 9 {
    enemy.elite_rank = 2
    enemy.hp += 8 + clampi(stage / 5, 0, 10)
    enemy.max_hp = enemy.hp
    enemy.move_speed *= 1.08
    enemy.reload_delay *= 0.76
  }

  enemy.overheat = rand_rangef(game, 0.0, 2.8)
}
