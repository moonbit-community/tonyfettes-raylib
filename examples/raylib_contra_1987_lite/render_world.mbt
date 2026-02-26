///|
fn draw_starfield(game : Game) -> Unit {
  @raylib.clear_background(game.profile.sky_bottom)
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_width,
    screen_height,
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
    map_offset_x - 6 + shake_x.to_int(),
    map_offset_y - 6 + shake_y.to_int(),
    map_pixel_w + 12,
    map_pixel_h + 12,
    @raylib.Color::new(30, 36, 46, 255),
  )
  @raylib.draw_rectangle(
    map_offset_x + shake_x.to_int(),
    map_offset_y + shake_y.to_int(),
    map_pixel_w,
    map_pixel_h,
    @raylib.Color::new(20, 23, 28, 255),
  )
}

///|
fn draw_single_tile(
  game : Game,
  tx : Int,
  ty : Int,
  tile : Int,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  let sx = tile_to_screen_x(tx, shake_x)
  let sy = tile_to_screen_y(ty, shake_y)

  if tile == tile_brick {
    @raylib.draw_rectangle(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(140, 72, 51, 255),
    )
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(88, 43, 30, 255),
    )
    @raylib.draw_line(
      sx,
      sy + tile_size / 2,
      sx + tile_size,
      sy + tile_size / 2,
      @raylib.Color::new(110, 55, 37, 255),
    )
  } else if tile == tile_steel {
    @raylib.draw_rectangle(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(110, 124, 143, 255),
    )
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(180, 190, 204, 255),
    )
    @raylib.draw_line(
      sx,
      sy,
      sx + tile_size,
      sy + tile_size,
      @raylib.Color::new(84, 94, 108, 255),
    )
  } else if tile == tile_water {
    @raylib.draw_rectangle(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(35, 70, 140, 255),
    )
    let wave = (Float::from_int(game.frame_counter) * 0.18 +
      Float::from_int(tx + ty)).to_int() %
      4
    @raylib.draw_line(
      sx,
      sy + 5 + wave,
      sx + tile_size,
      sy + 3 + wave,
      @raylib.Color::new(70, 130, 220, 255),
    )
  } else if tile == tile_ice {
    @raylib.draw_rectangle(
      sx,
      sy,
      tile_size,
      tile_size,
      @raylib.Color::new(156, 222, 232, 255),
    )
    @raylib.draw_line(
      sx + 4,
      sy + 5,
      sx + tile_size - 4,
      sy + tile_size - 5,
      @raylib.Color::new(210, 248, 255, 255),
    )
  } else if tile == tile_base {
    let base_color = if game.base_alive {
      @raylib.Color::new(201, 167, 86, 255)
    } else {
      @raylib.Color::new(110, 32, 32, 255)
    }
    @raylib.draw_rectangle(sx, sy, tile_size, tile_size, base_color)
    @raylib.draw_rectangle_lines(
      sx, sy, tile_size, tile_size, @raylib.darkbrown,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(sx + 4),
        Float::from_int(sy + tile_size - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(sx + tile_size - 4),
        Float::from_int(sy + tile_size - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(sx + tile_size / 2),
        Float::from_int(sy + 5),
      ),
      @raylib.black,
    )
  }
}

///|
fn draw_terrain_layer(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for ty = 0; ty < map_tiles_h; ty = ty + 1 {
    for tx = 0; tx < map_tiles_w; tx = tx + 1 {
      let tile = get_tile(game, tx, ty)
      if tile == tile_empty || tile == tile_bush {
        continue
      }
      draw_single_tile(game, tx, ty, tile, shake_x, shake_y)
    }
  }
}

///|
fn draw_bush_layer(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for ty = 0; ty < map_tiles_h; ty = ty + 1 {
    for tx = 0; tx < map_tiles_w; tx = tx + 1 {
      if get_tile(game, tx, ty) != tile_bush {
        continue
      }
      let sx = tile_to_screen_x(tx, shake_x)
      let sy = tile_to_screen_y(ty, shake_y)
      @raylib.draw_rectangle(
        sx,
        sy,
        tile_size,
        tile_size,
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
  tank : Tank,
  body_color : @raylib.Color,
  trim_color : @raylib.Color,
  shake_x : Float,
  shake_y : Float,
) -> Unit {
  let sx = world_to_screen_x(tank.x, shake_x)
  let sy = world_to_screen_y(tank.y, shake_y)
  let body_x = sx - tank_half.to_int()
  let body_y = sy - tank_half.to_int()
  let body_size = tank_size.to_int()

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
  if tank.dir == dir_up {
    @raylib.draw_rectangle(
      sx - turret_w / 2,
      sy - turret_len,
      turret_w,
      turret_len,
      trim_color,
    )
  } else if tank.dir == dir_down {
    @raylib.draw_rectangle(
      sx - turret_w / 2,
      sy,
      turret_w,
      turret_len,
      trim_color,
    )
  } else if tank.dir == dir_left {
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
fn draw_cores(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    let core = game.cores[i]
    let sx = world_to_screen_x(core.x, shake_x)
    let sy = world_to_screen_y(core.y, shake_y)
    let pulse = Float::from_double(@math.sin(core.pulse.to_double())) * 0.5 +
      0.5
    let radius = core_radius - 2.0 + pulse * 2.2

    let base = if core.flash > 0.0 {
      @raylib.Color::new(255, 220, 188, 255)
    } else {
      @raylib.Color::new(214, 76, 74, 255)
    }

    @raylib.draw_circle(sx, sy, radius + 4.0, @raylib.color_alpha(base, 0.18))
    @raylib.draw_circle(sx, sy, radius, base)
    @raylib.draw_circle_lines(
      sx,
      sy,
      radius + 1.2,
      @raylib.Color::new(255, 236, 198, 255),
    )

    let hp_ratio = Float::from_int(clampi(core.hp, 0, core.max_hp)) /
      Float::from_int(core.max_hp)
    let hp_w = 22
    let fill = clampi((Float::from_int(hp_w) * hp_ratio).to_int(), 0, hp_w)
    @raylib.draw_rectangle(sx - hp_w / 2, sy - 21, hp_w, 4, @raylib.black)
    @raylib.draw_rectangle(
      sx - hp_w / 2,
      sy - 21,
      fill,
      4,
      @raylib.Color::new(255, 202, 120, 255),
    )
  }
}

///|
fn draw_players(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
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
        world_to_screen_x(player.x, shake_x),
        world_to_screen_y(player.y, shake_y),
        radius,
        @raylib.skyblue,
      )
    }
  }
}

///|
fn draw_enemies(game : Game, shake_x : Float, shake_y : Float) -> Unit {
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

    let body = enemy_color(enemy.enemy_kind)
    let trim = @raylib.Color::new(70, 30, 30, 255)
    draw_tank(enemy, body, trim, shake_x, shake_y)

    if enemy.enemy_kind == enemy_heavy {
      for hp_i = 0; hp_i < enemy.hp; hp_i = hp_i + 1 {
        @raylib.draw_rectangle(
          world_to_screen_x(enemy.x, shake_x) - 9 + hp_i * 4,
          world_to_screen_y(enemy.y, shake_y) - 13,
          3,
          2,
          @raylib.white,
        )
      }
    }
  }
}

///|
fn draw_bullets(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue i + 1
    }
    let bullet = game.bullets[i]
    let color = if bullet.owner_team == team_enemy {
      @raylib.Color::new(255, 94, 94, 255)
    } else if bullet.owner_team == team_player2 {
      @raylib.Color::new(255, 222, 120, 255)
    } else {
      @raylib.Color::new(122, 222, 255, 255)
    }
    @raylib.draw_circle(
      world_to_screen_x(bullet.x, shake_x),
      world_to_screen_y(bullet.y, shake_y),
      bullet.radius,
      color,
    )
  }
}

///|
fn draw_particles(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue i + 1
    }
    let p = game.particles[i]
    let alpha = clampf(p.life / p.max_life, 0.0, 1.0)
    let c = @raylib.color_alpha(p.color, alpha)
    @raylib.draw_circle(
      world_to_screen_x(p.x, shake_x),
      world_to_screen_y(p.y, shake_y),
      p.size,
      c,
    )
  }
}

///|
fn powerup_color(kind : Int) -> @raylib.Color {
  if kind == powerup_shield {
    @raylib.skyblue
  } else if kind == powerup_star {
    @raylib.gold
  } else if kind == powerup_grenade {
    @raylib.red
  } else if kind == powerup_clock {
    @raylib.lime
  } else if kind == powerup_shovel {
    @raylib.brown
  } else if kind == powerup_tank {
    @raylib.orange
  } else {
    @raylib.white
  }
}

///|
fn powerup_text(kind : Int) -> String {
  if kind == powerup_shield {
    "S"
  } else if kind == powerup_star {
    "*"
  } else if kind == powerup_grenade {
    "G"
  } else if kind == powerup_clock {
    "C"
  } else if kind == powerup_shovel {
    "H"
  } else if kind == powerup_tank {
    "+"
  } else {
    "?"
  }
}

///|
fn draw_powerups(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      continue i + 1
    }
    let p = game.powerups[i]
    let blink_visible = p.ttl > 3.0 || (p.blink * 8.0).to_int() % 2 == 0
    if not(blink_visible) {
      continue i + 1
    }

    let sx = world_to_screen_x(p.x, shake_x)
    let sy = world_to_screen_y(p.y, shake_y)
    let color = powerup_color(p.kind)
    let pulse = Float::from_double(@math.sin(p.pulse.to_double())) * 0.5 + 0.5
    let radius = powerup_radius(p.kind) - 1.0 + pulse * 2.0

    @raylib.draw_circle(sx, sy, radius, @raylib.color_alpha(color, 0.25))
    @raylib.draw_circle_lines(sx, sy, radius + 1.0, color)
    @raylib.draw_text(powerup_text(p.kind), sx - 5, sy - 8, 16, color)
  }
}

///|
fn draw_world(game : Game) -> Unit {
  let (shake_x, shake_y) = shake_offsets(game)

  draw_starfield(game)
  draw_world_backdrop(shake_x, shake_y)
  draw_terrain_layer(game, shake_x, shake_y)
  draw_cores(game, shake_x, shake_y)
  draw_powerups(game, shake_x, shake_y)
  draw_players(game, shake_x, shake_y)
  draw_enemies(game, shake_x, shake_y)
  draw_bullets(game, shake_x, shake_y)
  draw_particles(game, shake_x, shake_y)
  draw_bush_layer(game, shake_x, shake_y)

  if game.profile.fog_alpha > 0.0 {
    @raylib.draw_rectangle(
      map_offset_x,
      map_offset_y,
      map_pixel_w,
      map_pixel_h,
      @raylib.color_alpha(
        @raylib.Color::new(220, 230, 245, 255),
        game.profile.fog_alpha,
      ),
    )
  }
}
