///|
let hud_height_f : Float = Float::from_int(@types.hud_height)

///|
fn world_to_screen_y(world_y : Float, shake_y : Float) -> Float {
  hud_height_f + world_y + shake_y
}

///|
fn draw_background(game : @types.Game, shake_y : Float) -> Unit {
  let sky_top = @raylib.Color::new(130, 200, 255, 255)
  let sky_bottom = @raylib.Color::new(120, 180, 250, 255)

  for i = 0; i < @types.screen_height - @types.hud_height; i = i + 4 {
    let p = Float::from_int(i) / Float::from_int(
        @types.screen_height - @types.hud_height,
      )
    let c = @raylib.color_lerp(sky_top, sky_bottom, p)
    @raylib.draw_rectangle(0, @types.hud_height + i, @types.screen_width, 4, c)
  }

  let base_y = @types.hud_height + 360 + shake_y.to_int()
  for i = 0; i < 20; i = i + 1 {
    let x = (Float::from_int(i) * 340.0 - game.camera_x * 0.35).to_int()
    let h = 90 + i % 3 * 22
    @raylib.draw_rectangle(
      x,
      base_y - h,
      220,
      h,
      @raylib.Color::new(120, 190, 120, 255),
    )
  }

  for i = 0; i < 14; i = i + 1 {
    let x = (Float::from_int(i) * 430.0 - game.camera_x * 0.2).to_int()
    let y = @types.hud_height + 80 + i % 4 * 16
    @raylib.draw_circle(x, y, 24.0, @raylib.white)
    @raylib.draw_circle(x + 22, y + 6, 20.0, @raylib.white)
    @raylib.draw_circle(x - 18, y + 8, 18.0, @raylib.white)
  }
}

///|
fn draw_tile(
  game : @types.Game,
  tx : Int,
  ty : Int,
  tile : Int,
  cam_x : Float,
  shake_y : Float,
) -> Unit {
  if tile == @types.tile_empty {
    return
  }

  let sx = @types.world_to_screen_x(@types.tile_left(tx), cam_x).to_int()
  let sy = world_to_screen_y(@types.tile_top(ty), shake_y).to_int()

  if tile == @types.tile_ground {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(147, 86, 34, 255),
    )
    @raylib.draw_rectangle(
      sx + 3,
      sy + 4,
      @types.tile_size - 6,
      @types.tile_size - 7,
      @raylib.Color::new(168, 103, 48, 255),
    )
    if @types.get_tile(game, tx, ty - 1) == @types.tile_empty {
      @raylib.draw_rectangle(
        sx,
        sy,
        @types.tile_size,
        6,
        @raylib.Color::new(101, 176, 68, 255),
      )
    }
  } else if tile == @types.tile_brick {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(181, 92, 36, 255),
    )
    @raylib.draw_line(
      sx,
      sy + @types.tile_size / 2,
      sx + @types.tile_size,
      sy + @types.tile_size / 2,
      @raylib.Color::new(145, 65, 22, 255),
    )
    @raylib.draw_line(
      sx + @types.tile_size / 2,
      sy,
      sx + @types.tile_size / 2,
      sy + @types.tile_size / 2,
      @raylib.Color::new(145, 65, 22, 255),
    )
    @raylib.draw_line(
      sx + @types.tile_size / 4,
      sy + @types.tile_size / 2,
      sx + @types.tile_size / 4,
      sy + @types.tile_size,
      @raylib.Color::new(145, 65, 22, 255),
    )
    @raylib.draw_line(
      sx + @types.tile_size * 3 / 4,
      sy + @types.tile_size / 2,
      sx + @types.tile_size * 3 / 4,
      sy + @types.tile_size,
      @raylib.Color::new(145, 65, 22, 255),
    )
  } else if tile == @types.tile_question {
    let wave : Float = @math.sinf(
      game.elapsed * (5.0 : Float) + Float::from_int(tx + ty),
    )
    let pulse : Float = (0.45 : Float) +
      (0.55 : Float) * (wave * (0.5 : Float) + (0.5 : Float))
    let c0 = @raylib.Color::new(219, 163, 38, 255)
    let c1 = @raylib.Color::new(255, 220, 112, 255)
    let cc = @raylib.color_lerp(c0, c1, pulse)
    @raylib.draw_rectangle(sx, sy, @types.tile_size, @types.tile_size, cc)
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(162, 108, 25, 255),
    )
    @raylib.draw_text(
      "?",
      sx + 9,
      sy + 4,
      22,
      @raylib.Color::new(130, 84, 20, 255),
    )
  } else if tile == @types.tile_used {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(124, 108, 84, 255),
    )
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(98, 86, 69, 255),
    )
  } else if tile == @types.tile_pipe {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(28, 151, 58, 255),
    )
    let is_pipe_top = @types.get_tile(game, tx, ty - 1) != @types.tile_pipe
    if is_pipe_top {
      @raylib.draw_rectangle(
        sx - 3,
        sy - 6,
        @types.tile_size + 6,
        8,
        @raylib.Color::new(50, 189, 88, 255),
      )
    }
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(18, 104, 40, 255),
    )
  } else if tile == @types.tile_flag_pole {
    @raylib.draw_rectangle(
      sx + @types.tile_size / 2 - 2,
      sy,
      4,
      @types.tile_size,
      @raylib.lightgray,
    )
  } else if tile == @types.tile_castle {
    @raylib.draw_rectangle(
      sx,
      sy,
      @types.tile_size,
      @types.tile_size,
      @raylib.Color::new(118, 118, 128, 255),
    )
    @raylib.draw_rectangle(
      sx + 6,
      sy + 5,
      8,
      8,
      @raylib.Color::new(92, 92, 99, 255),
    )
    @raylib.draw_rectangle(
      sx + 18,
      sy + 17,
      8,
      8,
      @raylib.Color::new(92, 92, 99, 255),
    )
  }
}

///|
fn draw_tiles(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  let start_tx = @types.clampi(
    @types.world_to_tile_x(cam_x) - 1,
    0,
    @types.world_tiles_w - 1,
  )
  let end_tx = @types.clampi(
    @types.world_to_tile_x(cam_x + Float::from_int(@types.screen_width)) + 2,
    0,
    @types.world_tiles_w - 1,
  )

  for ty = 0; ty < @types.world_tiles_h; ty = ty + 1 {
    for tx = start_tx; tx <= end_tx; tx = tx + 1 {
      draw_tile(game, tx, ty, @types.get_tile(game, tx, ty), cam_x, shake_y)
    }
  }
}

///|
fn draw_flag(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  let pole_x = @types.world_to_screen_x(game.flag_x, cam_x).to_int()
  let top_y = world_to_screen_y(game.flag_top_y, shake_y).to_int()
  let bottom_y = world_to_screen_y(
    game.flag_bottom_y + @types.player_half_h(),
    shake_y,
  ).to_int()

  @raylib.draw_rectangle(
    pole_x - 2,
    top_y,
    4,
    bottom_y - top_y,
    @raylib.lightgray,
  )

  let flag_y = if game.player.reached_flag && game.player.flag_phase >= 1 {
    world_to_screen_y(game.player.y - @types.player_half_h(), shake_y).to_int()
  } else {
    top_y + 14
  }
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(pole_x + 2), Float::from_int(flag_y)),
    @raylib.Vector2::new(
      Float::from_int(pole_x + 50),
      Float::from_int(flag_y + 12),
    ),
    @raylib.Vector2::new(
      Float::from_int(pole_x + 2),
      Float::from_int(flag_y + 24),
    ),
    @raylib.Color::new(30, 170, 70, 255),
  )
}

///|
fn draw_coins(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.coins.length(); i = i + 1 {
    let c = game.coins[i]
    if not(c.active) {
      continue i + 1
    }
    let sx = @types.world_to_screen_x(c.x, cam_x).to_int()
    let sy = world_to_screen_y(c.y, shake_y).to_int()
    let spin : Float = @math.sinf(c.phase * (2.0 : Float))
    let rx : Float = (8.0 : Float) +
      (spin * (0.5 : Float) + (0.5 : Float)) * (2.0 : Float)
    @raylib.draw_ellipse(sx, sy, rx, (10.0 : Float), @raylib.gold)
    @raylib.draw_ellipse_lines(sx, sy, rx, (10.0 : Float), @raylib.orange)
  }
}

///|
fn draw_enemy(enemy : @types.Enemy, cam_x : Float, shake_y : Float) -> Unit {
  let x = @types.world_to_screen_x(enemy.x, cam_x).to_int()
  let y = world_to_screen_y(enemy.y, shake_y).to_int()

  if enemy.squashed {
    @raylib.draw_ellipse(x, y + 7, 14.0, 7.0, @raylib.brown)
    return
  }

  @raylib.draw_ellipse(
    x,
    y + 4,
    12.0,
    10.0,
    @raylib.Color::new(176, 115, 62, 255),
  )
  @raylib.draw_ellipse(
    x,
    y - 6,
    13.0,
    9.0,
    @raylib.Color::new(148, 84, 43, 255),
  )
  @raylib.draw_rectangle(
    x - 9,
    y + 8,
    7,
    6,
    @raylib.Color::new(92, 53, 30, 255),
  )
  @raylib.draw_rectangle(
    x + 2,
    y + 8,
    7,
    6,
    @raylib.Color::new(92, 53, 30, 255),
  )
  @raylib.draw_circle(x - 4, y - 7, 2.2, @raylib.white)
  @raylib.draw_circle(x + 4, y - 7, 2.2, @raylib.white)
  @raylib.draw_circle(x - 4, y - 7, 1.1, @raylib.black)
  @raylib.draw_circle(x + 4, y - 7, 1.1, @raylib.black)
}

///|
fn draw_enemies(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if e.active {
      draw_enemy(e, cam_x, shake_y)
    }
  }
}

///|
fn draw_player(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  let player = game.player
  if player.invuln_t > 0.0 && (@raylib.get_time() * 18.0).to_int() % 2 == 0 {
    return
  }

  let x0 = @types.world_to_screen_x(
      player.x - @types.player_half_w(),
      cam_x,
    ).to_int()
  let y0 = world_to_screen_y(player.y - @types.player_half_h(), shake_y).to_int()

  // Body and overalls.
  @raylib.draw_rectangle(
    x0 + 4,
    y0 + 12,
    16,
    16,
    @raylib.Color::new(46, 88, 220, 255),
  )
  @raylib.draw_rectangle(
    x0 + 5,
    y0 + 7,
    14,
    9,
    @raylib.Color::new(222, 58, 45, 255),
  )

  // Head and hat.
  @raylib.draw_rectangle(
    x0 + 6,
    y0 + 2,
    12,
    9,
    @raylib.Color::new(244, 198, 152, 255),
  )
  @raylib.draw_rectangle(
    x0 + 4,
    y0,
    16,
    5,
    @raylib.Color::new(204, 44, 40, 255),
  )

  // Arms and boots.
  @raylib.draw_rectangle(
    x0 + 1,
    y0 + 13,
    4,
    9,
    @raylib.Color::new(222, 58, 45, 255),
  )
  @raylib.draw_rectangle(
    x0 + 19,
    y0 + 13,
    4,
    9,
    @raylib.Color::new(222, 58, 45, 255),
  )
  @raylib.draw_rectangle(
    x0 + 4,
    y0 + 26,
    8,
    4,
    @raylib.Color::new(113, 64, 42, 255),
  )
  @raylib.draw_rectangle(
    x0 + 12,
    y0 + 26,
    8,
    4,
    @raylib.Color::new(113, 64, 42, 255),
  )

  // Face direction.
  if player.facing >= 0 {
    @raylib.draw_circle(x0 + 14, y0 + 5, 1.3, @raylib.black)
  } else {
    @raylib.draw_circle(x0 + 10, y0 + 5, 1.3, @raylib.black)
  }
}

///|
fn draw_particles(game : @types.Game, cam_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    let alpha = @types.clampf(p.life / p.max_life, 0.0, 1.0)
    let col = @raylib.fade(p.color, alpha)
    let sx = @types.world_to_screen_x(p.x, cam_x).to_int()
    let sy = world_to_screen_y(p.y, shake_y).to_int()
    @raylib.draw_circle(sx, sy, p.size * alpha + 0.5, col)
  }
}

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let shake_x = if game.shake_t > 0.0 {
    @types.randf(-5.0, 5.0)
  } else {
    0.0
  }
  let shake_y = if game.shake_t > 0.0 {
    @types.randf(-3.0, 3.0)
  } else {
    0.0
  }
  let cam_x = game.camera_x + shake_x

  draw_background(game, shake_y)
  draw_tiles(game, cam_x, shake_y)
  draw_flag(game, cam_x, shake_y)
  draw_coins(game, cam_x, shake_y)
  draw_enemies(game, cam_x, shake_y)
  draw_player(game, cam_x, shake_y)
  draw_particles(game, cam_x, shake_y)
}
