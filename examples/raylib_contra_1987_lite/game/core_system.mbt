///|
fn clear_cores(game : @types.Game) -> Unit {
  for i in 0..<game.cores.length() {
    game.cores[i] = @types.BioCore::inactive()
  }
  game.cores_goal = 0
  game.cores_destroyed = 0
}

///|
fn alloc_core_slot(game : @types.Game) -> Int {
  for i in 0..<game.cores.length() {
    if not(game.cores[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_core_entity(
  game : @types.Game,
  x : Float,
  y : Float,
  hp : Int,
) -> Bool {
  let slot = alloc_core_slot(game)
  if slot < 0 {
    return false
  }

  let core = game.cores[slot]
  core.active = true
  core.x = x
  core.y = y
  core.hp = @types.clampi(hp, 4, 999)
  core.max_hp = core.hp
  core.pulse = @types.rand_rangef(game, 0.0, 6.2)
  core.flash = 0.0
  true
}

///|
fn core_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  @types.clampi(3 + wave / 4, 3, 8)
}

///|
fn tile_is_core_spawnable(tile : @types.Tile) -> Bool {
  match tile {
    Empty | Bush | Ice => true
    Brick | Steel | Water | Base => false
  }
}

///|
fn try_spawn_core_at_tile(
  game : @types.Game,
  tx : Int,
  ty : Int,
  hp : Int,
) -> Bool {
  if not(@types.in_tile_bounds(tx, ty)) {
    return false
  }
  if @types.absf(Float::from_int(tx - @types.base_tile_x)) <= 2.0 &&
    @types.absf(Float::from_int(ty - @types.base_tile_y)) <= 2.0 {
    return false
  }

  let tile = @types.get_tile(game, tx, ty)
  if not(tile_is_core_spawnable(tile)) {
    return false
  }

  let x = @types.tile_center_x(tx)
  let y = @types.tile_center_y(ty)

  for core in game.cores {
    if not(core.active) {
      continue
    }
    if @types.distance_sq(x, y, core.x, core.y) <= 3000.0 {
      return false
    }
  }

  spawn_core_entity(game, x, y, hp)
}

///|
fn seed_stage_cores(game : @types.Game, stage : Int) -> Unit {
  clear_cores(game)
  let wave = stage + 1
  let hp = @types.core_hp_base + wave * 2
  game.cores_goal = core_goal_for_stage(stage)

  let mut placed = 0
  let mut tries = 0
  while placed < game.cores_goal && tries < 1200 {
    tries += 1
    let tx = @types.rand_range(game, 2, @types.map_tiles_w - 3)
    let ty = @types.rand_range(game, 2, @types.map_tiles_h - 3)
    if try_spawn_core_at_tile(game, tx, ty, hp) {
      placed += 1
    }
  }

  if placed < game.cores_goal {
    for ty = 2
        ty < @types.map_tiles_h - 2 && placed < game.cores_goal
        ty = ty + 1 {
      for tx = 2
          tx < @types.map_tiles_w - 2 && placed < game.cores_goal
          tx = tx + 1 {
        if try_spawn_core_at_tile(game, tx, ty, hp) {
          placed += 1
        }
      }
    }
  }

  game.cores_goal = placed
}

///|
fn core_objective_done(game : @types.Game) -> Bool {
  if game.cores_goal <= 0 {
    true
  } else {
    game.cores_destroyed >= game.cores_goal
  }
}

///|
fn damage_core(
  game : @types.Game,
  index : Int,
  team : @types.Team,
  power : Int,
) -> Bool {
  if index < 0 || index >= game.cores.length() {
    return false
  }

  let core = game.cores[index]
  if not(core.active) {
    return false
  }

  core.hp -= @types.clampi(power, 1, 8)
  core.flash = 0.14
  @particles.spawn_spark_burst(game, core.x, core.y, 8)

  if core.hp <= 0 {
    core.active = false
    game.cores_destroyed += 1

    let bonus = @types.core_score_base +
      @types.clampi(game.stage_index * 18, 0, 480)
    @score.grant_score(game, team, bonus)
    @particles.spawn_explosion(game, core.x, core.y, 1.8)
    @types.push_camera_shake(game, 2.2)
  } else {
    @types.push_camera_shake(game, 0.7)
  }

  true
}

///|
fn update_cores(game : @types.Game, dt : Float) -> Unit {
  for core in game.cores {
    if not(core.active) {
      continue
    }
    core.pulse += dt * 3.8
    core.flash -= dt
    if core.flash < 0.0 {
      core.flash = 0.0
    }
  }
}
