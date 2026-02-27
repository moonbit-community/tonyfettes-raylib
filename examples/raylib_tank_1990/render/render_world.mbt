///|
fn draw_starfield(game : @types.Game) -> Unit {
  @raylib.clear_background(game.profile.sky_bottom)
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    game.profile.sky_top,
    game.profile.sky_bottom,
  )

  for i = 0; i < game.stars.length(); i = i + 1 {
    let star = game.stars[i]
    let phase = Float::from_double(@math.sin(star.twinkle.to_double())) * 0.5 +
      0.5
    let alpha = Float::from_double(0.25 + phase.to_double() * 0.75)
    let color = @raylib.color_alpha(@raylib.raywhite, alpha)
    @raylib.draw_circle(star.x.to_int(), star.y.to_int(), 1.0 + phase, color)
  }
}

///|
fn draw_world_backdrop(shake_x : Float, shake_y : Float) -> Unit {
  @raylib.draw_rectangle(
    @types.map_offset_x - 6 + shake_x.to_int(),
    @types.map_offset_y - 6 + shake_y.to_int(),
    @types.map_pixel_w + 12,
    @types.map_pixel_h + 12,
    @raylib.Color::new(30, 36, 46, 255),
  )
  @raylib.draw_rectangle(
    @types.map_offset_x + shake_x.to_int(),
    @types.map_offset_y + shake_y.to_int(),
    @types.map_pixel_w,
    @types.map_pixel_h,
    @raylib.Color::new(20, 23, 28, 255),
  )
}

///|
fn draw_single_tile(
  game : @types.Game,
  tx : Int,
  ty : Int,
  tile : Int,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  let sx = @types.tile_to_screen_x(tx, shake_x)
  let sy = @types.tile_to_screen_y(ty, shake_y)

  if tile == @types.tile_brick {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(140, 72, 51, 255),
    )
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(88, 43, 30, 255),
    )
    @raylib.draw_line(
      sx,
      sy + @types.tile_size / 2,
      sx + @types.tile_size,
      sy + @types.tile_size / 2,
      @raylib.Color::new(110, 55, 37, 255),
    )
  } else if tile == @types.tile_steel {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(110, 124, 143, 255),
    )
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(180, 190, 204, 255),
    )
    @raylib.draw_line(
      sx,
      sy,
      sx + @types.tile_size,
      sy + @types.tile_size,
      @raylib.Color::new(84, 94, 108, 255),
    )
  } else if tile == @types.tile_water {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(35, 70, 140, 255),
    )
    let wave = (Float::from_int(game.frame_counter) * 0.18 +
      Float::from_int(tx + ty)).to_int() %
      4
    @raylib.draw_line(
      sx,
      sy + 5 + wave,
      sx + @types.tile_size,
      sy + 3 + wave,
      @raylib.Color::new(70, 130, 220, 255),
    )
  } else if tile == @types.tile_ice {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(156, 222, 232, 255),
    )
    @raylib.draw_line(
      sx + 4,
      sy + 5,
      sx + @types.tile_size - 4,
      sy + @types.tile_size - 5,
      @raylib.Color::new(210, 248, 255, 255),
    )
  } else if tile == @types.tile_base {
    let base_color = if game.base_alive {
      @raylib.Color::new(201, 167, 86, 255)
    } else {
      @raylib.Color::new(110, 32, 32, 255)
    }
    @raylib.draw_rectangle(
      sx, sy, @types.tile_size, @types.tile_size, base_color,
    )
    @raylib.draw_rectangle_lines(
      sx, sy, @types.tile_size, @types.tile_size, @raylib.darkbrown,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(sx + 4),
        Float::from_int(sy + @types.tile_size - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(sx + @types.tile_size - 4),
        Float::from_int(sy + @types.tile_size - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(sx + @types.tile_size / 2),
        Float::from_int(sy + 5),
      ),
      @raylib.black,
    )
  }
}

///|
fn draw_terrain_layer(
  game : @types.Game,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  for ty = 0; ty < @types.map_tiles_h; ty = ty + 1 {
    for tx = 0; tx < @types.map_tiles_w; tx = tx + 1 {
      let tile = @types.get_tile(game, tx, ty)
      if tile == @types.tile_empty || tile == @types.tile_bush {
        continue
      }
      draw_single_tile(game, tx, ty, tile, shake_x, shake_y)
    }
  }
}

///|
fn draw_bush_layer(
  game : @types.Game,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  for ty = 0; ty < @types.map_tiles_h; ty = ty + 1 {
    for tx = 0; tx < @types.map_tiles_w; tx = tx + 1 {
      if @types.get_tile(game, tx, ty) != @types.tile_bush {
        continue
      }
      let sx = @types.tile_to_screen_x(tx, shake_x)
      let sy = @types.tile_to_screen_y(ty, shake_y)
      @raylib.draw_rectangle(
        sx,
        sy,
        @types.tile_size,
        @types.tile_size,
        @raylib.Color::new(42, 106, 53, 220),
      )
      @raylib.draw_circle(
        sx + 6,
        sy + 9,
        5.0,
        @raylib.Color::new(74, 145, 80, 230),
      )
      @raylib.draw_circle(
        sx + 15,
        sy + 8,
        4.0,
        @raylib.Color::new(58, 126, 63, 230),
      )
      @raylib.draw_circle(
        sx + 12,
        sy + 15,
        5.0,
        @raylib.Color::new(85, 153, 88, 230),
      )
    }
  }
}

///|
fn draw_tank(
  tank : @types.Tank,
  body_color : @raylib.Color,
  trim_color : @raylib.Color,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  let sx = @types.world_to_screen_x(tank.x, shake_x)
  let sy = @types.world_to_screen_y(tank.y, shake_y)
  let body_x = sx - @types.tank_half.to_int()
  let body_y = sy - @types.tank_half.to_int()
  let body_size = @types.tank_size.to_int()

  @raylib.draw_rectangle(body_x, body_y, body_size, body_size, body_color)
  @raylib.draw_rectangle_lines(body_x, body_y, body_size, body_size, trim_color)

  @raylib.draw_rectangle(
    body_x + 3,
    body_y + 3,
    body_size - 6,
    body_size - 6,
    @raylib.color_alpha(trim_color, 0.25),
  )

  let turret_len = 11
  let turret_w = 4
  if tank.dir == @types.dir_up {
    @raylib.draw_rectangle(
      sx - turret_w / 2,
      sy - turret_len,
      turret_w,
      turret_len,
      trim_color,
    )
  } else if tank.dir == @types.dir_down {
    @raylib.draw_rectangle(
      sx - turret_w / 2,
      sy,
      turret_w,
      turret_len,
      trim_color,
    )
  } else if tank.dir == @types.dir_left {
    @raylib.draw_rectangle(
      sx - turret_len,
      sy - turret_w / 2,
      turret_len,
      turret_w,
      trim_color,
    )
  } else {
    @raylib.draw_rectangle(
      sx,
      sy - turret_w / 2,
      turret_len,
      turret_w,
      trim_color,
    )
  }

  @raylib.draw_circle(sx, sy, 5.0, trim_color)
}

///|
fn draw_players(game : @types.Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < @types.max_players; i = i + 1 {
    if not(game.players[i].active) {
      continue i + 1
    }
    let player = game.players[i]

    if player.invuln_timer > 0.0 {
      let blink = (player.blink_timer * 8.0).to_int() % 2
      if blink == 0 {
        continue i + 1
      }
    }

    let body = if i == 0 {
      @raylib.Color::new(96, 199, 255, 255)
    } else {
      @raylib.Color::new(255, 173, 95, 255)
    }
    let trim = if i == 0 {
      @raylib.Color::new(24, 102, 180, 255)
    } else {
      @raylib.Color::new(170, 86, 34, 255)
    }
    draw_tank(player, body, trim, shake_x, shake_y)

    if player.shield_timer > 0.0 {
      let pulse = Float::from_double(
        @math.sin(player.blink_timer.to_double() * 14.0),
      )
      let radius = Float::from_double(14.0 + pulse.to_double() * 1.5)
      @raylib.draw_circle_lines(
        @types.world_to_screen_x(player.x, shake_x),
        @types.world_to_screen_y(player.y, shake_y),
        radius,
        @raylib.skyblue,
      )
    }
  }
}

///|
fn draw_enemies(game : @types.Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }
    let enemy = game.enemies[i]

    if enemy.invuln_timer > 0.0 {
      let blink = (enemy.invuln_timer * 14.0).to_int() % 2
      if blink == 0 {
        continue i + 1
      }
    }

    let body = @types.enemy_color(enemy.enemy_kind)
    let trim = @raylib.Color::new(70, 30, 30, 255)
    draw_tank(enemy, body, trim, shake_x, shake_y)

    if enemy.enemy_kind == @types.enemy_heavy {
      for hp_i = 0; hp_i < enemy.hp; hp_i = hp_i + 1 {
        @raylib.draw_rectangle(
          @types.world_to_screen_x(enemy.x, shake_x) - 9 + hp_i * 4,
          @types.world_to_screen_y(enemy.y, shake_y) - 13,
          3,
          2,
          @raylib.white,
        )
      }
    }
  }
}

///|
fn draw_bullets(game : @types.Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue i + 1
    }
    let bullet = game.bullets[i]
    let color = if bullet.owner_team == @types.team_enemy {
      @raylib.Color::new(255, 94, 94, 255)
    } else if bullet.owner_team == @types.team_player2 {
      @raylib.Color::new(255, 222, 120, 255)
    } else {
      @raylib.Color::new(122, 222, 255, 255)
    }
    @raylib.draw_circle(
      @types.world_to_screen_x(bullet.x, shake_x),
      @types.world_to_screen_y(bullet.y, shake_y),
      bullet.radius,
      color,
    )
  }
}

///|
fn draw_particles(game : @types.Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue i + 1
    }
    let p = game.particles[i]
    let alpha = @types.clampf(p.life / p.max_life, 0.0, 1.0)
    let c = @raylib.color_alpha(p.color, alpha)
    @raylib.draw_circle(
      @types.world_to_screen_x(p.x, shake_x),
      @types.world_to_screen_y(p.y, shake_y),
      p.size,
      c,
    )
  }
}

///|
fn draw_powerups(game : @types.Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      continue i + 1
    }
    let p = game.powerups[i]
    let blink_visible = p.ttl > 3.0 || (p.blink * 8.0).to_int() % 2 == 0
    if not(blink_visible) {
      continue i + 1
    }

    let sx = @types.world_to_screen_x(p.x, shake_x)
    let sy = @types.world_to_screen_y(p.y, shake_y)
    let color = @types.powerup_color(p.kind)
    let pulse = Float::from_double(@math.sin(p.pulse.to_double())) * 0.5 + 0.5
    let radius = @types.powerup_radius(p.kind) - 1.0 + pulse * 2.0

    @raylib.draw_circle(sx, sy, radius, @raylib.color_alpha(color, 0.25))
    @raylib.draw_circle_lines(sx, sy, radius + 1.0, color)
    @raylib.draw_text(@types.powerup_text(p.kind), sx - 5, sy - 8, 16, color)
  }
}

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let (shake_x, shake_y) = @types.shake_offsets(game)

  draw_starfield(game)
  draw_world_backdrop(shake_x, shake_y)
  draw_terrain_layer(game, shake_x, shake_y)
  draw_powerups(game, shake_x, shake_y)
  draw_players(game, shake_x, shake_y)
  draw_enemies(game, shake_x, shake_y)
  draw_bullets(game, shake_x, shake_y)
  draw_particles(game, shake_x, shake_y)
  draw_bush_layer(game, shake_x, shake_y)

  if game.profile.fog_alpha > 0.0 {
    @raylib.draw_rectangle(
      @types.map_offset_x,
      @types.map_offset_y,
      @types.map_pixel_w,
      @types.map_pixel_h,
      @raylib.color_alpha(
        @raylib.Color::new(220, 230, 245, 255),
        game.profile.fog_alpha,
      ),
    )
  }
}
