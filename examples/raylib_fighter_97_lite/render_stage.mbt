///|
fn draw_stage_sky(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 10, 16, 255))

  let top_color = if game.state == state_match_over {
    @raylib.Color::new(18, 26, 42, 255)
  } else {
    @raylib.Color::new(14, 26, 44, 255)
  }
  let bottom_color = @raylib.Color::new(28, 46, 68, 255)

  @raylib.draw_rectangle_gradient_v(
    0, 0, screen_width, screen_height, top_color, bottom_color,
  )

  let moon_x = f(1060.0) +
    Float::from_double(@math.sin((game.bg_scroll * f(0.02)).to_double())) *
    f(80.0)
  let moon_y = f(132.0) +
    Float::from_double(@math.cos((game.bg_scroll * f(0.03)).to_double())) *
    f(16.0)
  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    58.0,
    @raylib.Color::new(235, 243, 255, 120),
  )
  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    40.0,
    @raylib.Color::new(244, 252, 255, 180),
  )

  for i = 0; i < 90; i = i + 1 {
    let tx = (i * 133 + game.frame_count * 3) % (screen_width + 200)
    let ty = (i * 67 + 45) % 260
    let twinkle = Float::from_double(
      @math.sin(
        (Float::from_int(i) * f(0.7) + game.bg_scroll * f(0.1)).to_double(),
      ),
    )
    let alpha = f(0.25) + (twinkle * f(0.5) + f(0.5)) * f(0.75)
    let color = @raylib.color_alpha(@raylib.raywhite, alpha)
    @raylib.draw_circle(tx - 80, ty, f(1.0) + twinkle * f(0.5), color)
  }
}

///|
fn draw_city_layer(
  game : Game,
  layer : Int,
  y_base : Int,
  height_min : Int,
  height_max : Int,
  color : @raylib.Color,
) -> Unit {
  let parallax = f(0.1) + Float::from_int(layer) * f(0.1)
  let scroll = (game.bg_scroll * parallax).to_int()
  let block_w = 36 + layer * 12
  let max_blocks = screen_width / block_w + 6

  for i = 0; i < max_blocks; i = i + 1 {
    let x = i * block_w - scroll % block_w - block_w
    let wave = Float::from_double(
      @math.sin(
        (Float::from_int(i * 11 + layer * 17) + game.bg_scroll * f(0.08)).to_double(),
      ),
    )
    let h = height_min +
      (Float::from_int(height_max - height_min) * (wave * f(0.5) + f(0.5))).to_int()
    @raylib.draw_rectangle(x, y_base - h, block_w - 3, h, color)

    if layer >= 2 {
      for w = 0; w < 5; w = w + 1 {
        let wx = x + 4 + w * 6
        let wy = y_base - h + 7 + (w * 13 + i * 5) % (h - 14)
        let lit = (w + i + game.frame_count / 27) % 5
        if lit <= 1 {
          @raylib.draw_rectangle(
            wx,
            wy,
            3,
            4,
            @raylib.Color::new(255, 216, 128, 120),
          )
        }
      }
    }
  }
}

///|
fn draw_stage_city(game : Game) -> Unit {
  draw_city_layer(game, 0, 430, 90, 160, @raylib.Color::new(18, 30, 46, 255))
  draw_city_layer(game, 1, 448, 100, 185, @raylib.Color::new(24, 36, 56, 255))
  draw_city_layer(game, 2, 468, 120, 220, @raylib.Color::new(29, 44, 66, 255))
  draw_city_layer(game, 3, 498, 140, 260, @raylib.Color::new(36, 52, 76, 255))
}

///|
fn draw_stage_crowd(game : Game) -> Unit {
  let crowd_y = 548
  @raylib.draw_rectangle(
    0,
    crowd_y - 36,
    screen_width,
    50,
    @raylib.Color::new(18, 20, 26, 220),
  )

  for i = 0; i < 190; i = i + 1 {
    let x = (i * 19 + (game.bg_scroll * f(9.0)).to_int()) % (screen_width + 32) -
      16
    let phase = Float::from_double(
      @math.sin(
        (Float::from_int(i) * f(0.4) + game.bg_scroll * f(0.3)).to_double(),
      ),
    )
    let bob = (phase * f(4.0)).to_int()

    let hue = i % 4
    let shirt = if hue == 0 {
      @raylib.Color::new(98, 112, 150, 220)
    } else if hue == 1 {
      @raylib.Color::new(136, 96, 132, 220)
    } else if hue == 2 {
      @raylib.Color::new(85, 126, 114, 220)
    } else {
      @raylib.Color::new(146, 112, 86, 220)
    }

    @raylib.draw_rectangle(x - 3, crowd_y - 12 + bob, 6, 12, shirt)
    @raylib.draw_circle(
      x,
      crowd_y - 18 + bob,
      4.0,
      @raylib.Color::new(222, 191, 156, 230),
    )

    if i % 10 == 0 {
      @raylib.draw_line(
        x - 4,
        crowd_y - 14 + bob,
        x - 10,
        crowd_y - 24 + bob,
        @raylib.Color::new(216, 236, 255, 150),
      )
    }
  }
}

///|
fn draw_stage_floor(game : Game) -> Unit {
  let floor_top = 560
  @raylib.draw_rectangle(
    0,
    floor_top,
    screen_width,
    screen_height - floor_top,
    @raylib.Color::new(42, 38, 36, 255),
  )

  for i = 0; i <= 40; i = i + 1 {
    let t = Float::from_int(i) / f(40.0)
    let y = floor_top + (t * t * f(210.0)).to_int()
    let alpha = f(0.16) - t * f(0.14)
    @raylib.draw_line(
      0,
      y,
      screen_width,
      y,
      @raylib.color_alpha(@raylib.Color::new(255, 228, 184, 255), alpha),
    )
  }

  for i = -14; i <= 14; i = i + 1 {
    let x = screen_width / 2 + i * 48 + (game.bg_scroll * f(0.8)).to_int() % 48
    let alpha = f(0.2) -
      Float::from_int(absf(Float::from_int(i)).to_int()) * f(0.008)
    @raylib.draw_line(
      x,
      floor_top,
      x + i * 15,
      screen_height,
      @raylib.color_alpha(@raylib.Color::new(240, 200, 130, 255), alpha),
    )
  }

  let left_rope = camera_project_x(game, stage_left_x - 40.0).to_int()
  let right_rope = camera_project_x(game, stage_right_x + 40.0).to_int()
  for i = 0; i < 3; i = i + 1 {
    let y = camera_project_y(game, f(430.0) + Float::from_int(i * 38)).to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(left_rope), Float::from_int(y)),
      @raylib.Vector2::new(Float::from_int(right_rope), Float::from_int(y)),
      4.0,
      @raylib.Color::new(194, 68, 58, 190),
    )
  }
}

///|
fn draw_stage_flash(game : Game) -> Unit {
  if game.stage_flash <= 0.0 {
    return
  }
  let alpha = clampf(game.stage_flash * f(1.8), f(0.0), f(0.48))
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.color_alpha(@raylib.white, alpha),
  )
}

///|
fn draw_stage(game : Game) -> Unit {
  draw_stage_sky(game)
  draw_stage_city(game)
  draw_stage_crowd(game)
  draw_stage_floor(game)
  draw_particles(game)
  draw_stage_flash(game)
}
