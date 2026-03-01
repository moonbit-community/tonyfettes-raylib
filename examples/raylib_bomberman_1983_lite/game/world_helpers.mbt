///|
fn damage_tile_at_point(
  game : @types.Game,
  world_x : Float,
  world_y : Float,
  power : Int,
) -> Bool {
  if not(@world.point_in_world(world_x, world_y)) {
    return true
  }

  let tx = @types.world_x_to_tile(world_x)
  let ty = @types.world_y_to_tile(world_y)
  let tile = @types.get_tile(game, tx, ty)
  if not(@types.is_tile_solid_for_bullet(tile)) {
    return false
  }

  let idx = @types.tile_index(tx, ty)
  match tile {
    Brick => {
      game.map_hp[idx] -= power
      if game.map_hp[idx] <= 0 {
        @types.set_tile(game, tx, ty, @types.Empty, 0)
        @particles.spawn_explosion(
          game,
          @types.tile_center_x(tx),
          @types.tile_center_y(ty),
          0.45,
        )
      } else {
        @particles.spawn_spark_burst(game, world_x, world_y, 6)
      }
    }
    Steel =>
      if power >= 3 {
        @types.set_tile(game, tx, ty, @types.Empty, 0)
        @particles.spawn_explosion(
          game,
          @types.tile_center_x(tx),
          @types.tile_center_y(ty),
          0.7,
        )
      } else {
        @particles.spawn_spark_burst(game, world_x, world_y, 9)
      }
    Base => {
      game.base_alive = false
      game.base_flash = 1.0
      @particles.spawn_explosion(
        game,
        @types.tile_center_x(tx),
        @types.tile_center_y(ty),
        2.1,
      )
      @types.push_camera_shake(game, 3.6)
    }
    _ => ()
  }
  true
}

///|
fn sight_blocked(
  game : @types.Game,
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
) -> Bool {
  let dx = bx - ax
  let dy = by - ay
  let distance = (dx * dx + dy * dy).sqrt()
  if distance <= 1.0 {
    return false
  }
  let step = Float::from_int(@types.tile_size / 2)
  let n = @types.clampi((distance / step).to_int(), 1, 80)
  for i in 1..<n {
    let t = Float::from_int(i) / Float::from_int(n)
    let px = ax + dx * t
    let py = ay + dy * t
    let tile = @types.get_tile(
      game,
      @types.world_x_to_tile(px),
      @types.world_y_to_tile(py),
    )
    match tile {
      Brick | Steel | Base => return true
      _ => ()
    }
  }
  false
}
