///|
fn fire_bullet(game : @types.Game) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      let dir_x : Float = Float::from_double(
        @math.cos(game.ship_angle.to_double()),
      )
      let dir_y : Float = Float::from_double(
        @math.sin(game.ship_angle.to_double()),
      )
      bullet.active = true
      bullet.x = game.ship_x + dir_x * 14.0
      bullet.y = game.ship_y + dir_y * 14.0
      bullet.vx = game.ship_vx + dir_x * 360.0
      bullet.vy = game.ship_vy + dir_y * 360.0
      bullet.ttl = 1.35
      game.fire_cooldown = 0.14
      return
    }
  }
}

///|
fn update_ship(game : @types.Game, dt : Float) -> Unit {
  let rotate_speed : Float = 4.5
  let thrust : Float = 180.0

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    game.ship_angle = game.ship_angle - rotate_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    game.ship_angle = game.ship_angle + rotate_speed * dt
  }

  let is_thrusting = @raylib.is_key_down(@raylib.KeyUp) ||
    @raylib.is_key_down(@raylib.KeyW)
  game.thrusting = is_thrusting
  if is_thrusting {
    let dir_x : Float = Float::from_double(
      @math.cos(game.ship_angle.to_double()),
    )
    let dir_y : Float = Float::from_double(
      @math.sin(game.ship_angle.to_double()),
    )
    game.ship_vx = game.ship_vx + dir_x * thrust * dt
    game.ship_vy = game.ship_vy + dir_y * thrust * dt
  }

  let damping : Float = (1.0 : Float) - (0.35 : Float) * dt
  game.ship_vx = game.ship_vx * damping
  game.ship_vy = game.ship_vy * damping

  game.ship_x = @types.wrap_x(game.ship_x + game.ship_vx * dt)
  game.ship_y = @types.wrap_y(game.ship_y + game.ship_vy * dt)

  if game.fire_cooldown > 0.0 {
    game.fire_cooldown = game.fire_cooldown - dt
    if game.fire_cooldown < 0.0 {
      game.fire_cooldown = 0.0
    }
  }

  if game.ship_invuln > 0.0 {
    game.ship_invuln = game.ship_invuln - dt
    if game.ship_invuln < 0.0 {
      game.ship_invuln = 0.0
    }
  }

  if (
      @raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyX)
    ) &&
    game.fire_cooldown <= 0.0 {
    fire_bullet(game)
  }
}
