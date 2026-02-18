///|
fn is_player_enabled(game : Game, index : Int) -> Bool {
  if index == 0 {
    true
  } else {
    game.coop_enabled
  }
}

///|
fn read_player_move_dir(index : Int) -> Int {
  if index == 0 {
    if @raylib.is_key_down(@raylib.KeyUp) {
      dir_up
    } else if @raylib.is_key_down(@raylib.KeyDown) {
      dir_down
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      dir_left
    } else if @raylib.is_key_down(@raylib.KeyRight) {
      dir_right
    } else {
      -1
    }
  } else if @raylib.is_key_down(@raylib.KeyW) {
    dir_up
  } else if @raylib.is_key_down(@raylib.KeyS) {
    dir_down
  } else if @raylib.is_key_down(@raylib.KeyA) {
    dir_left
  } else if @raylib.is_key_down(@raylib.KeyD) {
    dir_right
  } else {
    -1
  }
}

///|
fn is_player_shoot_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyEnter)
  } else {
    @raylib.is_key_down(@raylib.KeySpace)
  }
}

///|
fn player_is_on_ice(game : Game, player : Tank) -> Bool {
  let tx = world_x_to_tile(player.x)
  let ty = world_y_to_tile(player.y)
  get_tile(game, tx, ty) == tile_ice
}

///|
fn can_player_fire(game : Game, index : Int) -> Bool {
  let player = game.players[index]
  if not(player.active) {
    return false
  }
  if player.reload_timer > 0.0 {
    return false
  }

  let team = team_of_player(index)
  let mut active_count = 0
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if game.bullets[i].active && game.bullets[i].owner_team == team {
      active_count += 1
    }
  }

  let cap = if player.weapon_level >= 2 { 2 } else { 1 }
  active_count < cap
}

///|
fn update_player_reload_timers(game : Game, dt : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    let player = game.players[i]
    if player.reload_timer > 0.0 {
      player.reload_timer -= dt
      if player.reload_timer < 0.0 {
        player.reload_timer = 0.0
      }
    }
    if player.invuln_timer > 0.0 {
      player.invuln_timer -= dt
      if player.invuln_timer < 0.0 {
        player.invuln_timer = 0.0
      }
    }
    if player.shield_timer > 0.0 {
      player.shield_timer -= dt
      if player.shield_timer < 0.0 {
        player.shield_timer = 0.0
      }
    }
    if player.skid_timer > 0.0 {
      player.skid_timer -= dt
      if player.skid_timer < 0.0 {
        player.skid_timer = 0.0
      }
    }
    player.blink_timer += dt * 5.0
  }
}

///|
fn try_move_player(game : Game, index : Int, dir : Int, dt : Float) -> Unit {
  let player = game.players[index]
  if not(player.active) {
    return
  }

  let vx = dir_vector_x(dir)
  let vy = dir_vector_y(dir)
  let step = player.move_speed * dt
  let nx = player.x + vx * step
  let ny = player.y + vy * step

  if tank_hits_world(game, nx, ny) {
    return
  }
  if tank_hits_players(game, nx, ny, index) {
    return
  }
  if tank_hits_enemies(game, nx, ny, -1) {
    return
  }

  player.x = nx
  player.y = ny
}

///|
fn update_player_input(game : Game, dt : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    if not(is_player_enabled(game, i)) {
      continue i + 1
    }

    let player = game.players[i]
    if not(player.active) {
      continue i + 1
    }

    let (move_dir, shoot_pressed) = if game.demo_mode {
      demo_player_command(game, i, dt)
    } else {
      (read_player_move_dir(i), is_player_shoot_pressed(i))
    }
    if move_dir >= 0 {
      player.dir = move_dir
      try_move_player(game, i, move_dir, dt)
      if player_is_on_ice(game, player) {
        player.skid_timer = 0.12
      }
    } else if player.skid_timer > 0.0 && player_is_on_ice(game, player) {
      try_move_player(game, i, player.dir, dt * 0.55)
    }

    if shoot_pressed && can_player_fire(game, i) {
      let muzzle_x = player.x + dir_vector_x(player.dir) * (tank_half + 3.0)
      let muzzle_y = player.y + dir_vector_y(player.dir) * (tank_half + 3.0)
      let speed = bullet_speed_player +
        Float::from_int(player.weapon_level) * 38.0
      let power = if player.weapon_level >= 3 {
        3
      } else if player.weapon_level >= 1 {
        2
      } else {
        1
      }
      spawn_bullet(
        game,
        team_of_player(i),
        muzzle_x,
        muzzle_y,
        player.dir,
        speed,
        power,
      )
      player.reload_timer = player.reload_delay
      spawn_spark_burst(game, muzzle_x, muzzle_y, 5)
    }
  }
}

///|
fn on_player_destroyed(game : Game, index : Int) -> Unit {
  let player = game.players[index]
  if not(player.active) {
    return
  }
  if player.invuln_timer > 0.0 || player.shield_timer > 0.0 {
    spawn_spark_burst(game, player.x, player.y, 7)
    return
  }

  player.active = false
  player.lives -= 1
  if player.weapon_level > 0 {
    player.weapon_level -= 1
  }
  player.reload_delay = player_reload_base *
    (1.0 - Float::from_int(player.weapon_level) * 0.08)
  if player.reload_delay < 0.12 {
    player.reload_delay = 0.12
  }
  player.respawn_timer = player_respawn_delay
  spawn_explosion(game, player.x, player.y, 1.25)
}

///|
fn update_player_respawns(game : Game, dt : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    if not(is_player_enabled(game, i)) {
      continue i + 1
    }
    let player = game.players[i]
    if player.active {
      continue i + 1
    }
    if player.lives <= 0 {
      continue i + 1
    }
    player.respawn_timer -= dt
    if player.respawn_timer <= 0.0 {
      respawn_player_tank(game, i)
      spawn_respawn_burst(game, player.x, player.y)
    }
  }
}

///|
fn all_players_out(game : Game) -> Bool {
  let mut living = 0
  for i = 0; i < max_players; i = i + 1 {
    if not(is_player_enabled(game, i)) {
      continue i + 1
    }
    let player = game.players[i]
    if player.active || player.lives > 0 {
      living += 1
    }
  }
  living == 0
}
