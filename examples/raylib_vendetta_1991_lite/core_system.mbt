///|
fn clear_cores(game : Game) -> Unit {
  for i = 0; i < game.cores.length(); i = i + 1 {
    game.cores[i] = BioCore::inactive()
  }
  game.cores_goal = 0
  game.cores_destroyed = 0
}

///|
fn alloc_core_slot(game : Game) -> Int {
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_core_entity(game : Game, x : Float, y : Float, hp : Int) -> Bool {
  let slot = alloc_core_slot(game)
  if slot < 0 {
    return false
  }

  let core = game.cores[slot]
  core.active = true
  core.x = x
  core.y = y
  core.hp = clampi(hp, 4, 999)
  core.max_hp = core.hp
  core.pulse = rand_rangef(game, 0.0, 6.2)
  core.flash = 0.0
  true
}

///|
fn core_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  clampi(3 + wave / 4, 3, 8)
}

///|
fn tile_is_core_spawnable(tile : Int) -> Bool {
  tile == tile_empty || tile == tile_bush || tile == tile_ice
}

///|
fn try_spawn_core_at_tile(game : Game, tx : Int, ty : Int, hp : Int) -> Bool {
  if not(in_tile_bounds(tx, ty)) {
    return false
  }
  if absf(Float::from_int(tx - base_tile_x)) <= 2.0 &&
    absf(Float::from_int(ty - base_tile_y)) <= 2.0 {
    return false
  }

  let tile = get_tile(game, tx, ty)
  if not(tile_is_core_spawnable(tile)) {
    return false
  }

  let x = tile_center_x(tx)
  let y = tile_center_y(ty)

  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    if distance_sq(x, y, game.cores[i].x, game.cores[i].y) <= 3000.0 {
      return false
    }
  }

  spawn_core_entity(game, x, y, hp)
}

///|
fn seed_stage_cores(game : Game, stage : Int) -> Unit {
  clear_cores(game)
  let wave = stage + 1
  let hp = core_hp_base + wave * 2
  game.cores_goal = core_goal_for_stage(stage)

  let mut placed = 0
  let mut tries = 0
  while placed < game.cores_goal && tries < 1200 {
    tries += 1
    let tx = rand_range(game, 2, map_tiles_w - 3)
    let ty = rand_range(game, 2, map_tiles_h - 3)
    if try_spawn_core_at_tile(game, tx, ty, hp) {
      placed += 1
    }
  }

  if placed < game.cores_goal {
    for ty = 2; ty < map_tiles_h - 2 && placed < game.cores_goal; ty = ty + 1 {
      for tx = 2; tx < map_tiles_w - 2 && placed < game.cores_goal; tx = tx + 1 {
        if try_spawn_core_at_tile(game, tx, ty, hp) {
          placed += 1
        }
      }
    }
  }

  game.cores_goal = placed
}

///|
fn core_objective_done(game : Game) -> Bool {
  if game.cores_goal <= 0 {
    true
  } else {
    game.cores_destroyed >= game.cores_goal
  }
}

///|
fn damage_core(game : Game, index : Int, team : Int, power : Int) -> Bool {
  if index < 0 || index >= game.cores.length() {
    return false
  }

  let core = game.cores[index]
  if not(core.active) {
    return false
  }

  core.hp -= clampi(power, 1, 8)
  core.flash = 0.14
  spawn_spark_burst(game, core.x, core.y, 8)

  if core.hp <= 0 {
    core.active = false
    game.cores_destroyed += 1

    let bonus = core_score_base + clampi(game.stage_index * 18, 0, 480)
    grant_score(game, team, bonus)
    spawn_explosion(game, core.x, core.y, 1.8)
    push_camera_shake(game, 2.2)
  } else {
    push_camera_shake(game, 0.7)
  }

  true
}

///|
fn update_cores(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    let core = game.cores[i]
    core.pulse += dt * 3.8
    core.flash -= dt
    if core.flash < 0.0 {
      core.flash = 0.0
    }
  }
}
