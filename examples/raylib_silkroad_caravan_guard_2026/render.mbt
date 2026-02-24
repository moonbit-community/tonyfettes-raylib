///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - w / 2, y, size, col)
}

///|
fn draw_right_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, size)
  @raylib.draw_text(text, x - w, y, size, col)
}

///|
fn a_col(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(alpha, 0, 255),
  )
}

///|
fn cam_shake(game : Game) -> (Float, Float) {
  if game.state != state_play || game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let amp = minf(20.0, game.shake_t * 80.0)
    (randf(-amp, amp), randf(-amp, amp))
  }
}

///|
fn draw_sky(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(14, 27, 46, 255),
    @raylib.Color::new(235, 160, 88, 255),
  )

  let sun_x = Float::from_int(screen_w) * 0.76 + sinf(game.time_s * 0.22) * 26.0
  let sun_y : Float = 128.0 + cosf(game.time_s * 0.32) * 10.0
  @raylib.draw_circle(
    (sun_x + cam_x * 0.15).to_int(),
    (sun_y + cam_y * 0.15).to_int(),
    62.0,
    @raylib.Color::new(255, 238, 172, 84),
  )
  @raylib.draw_circle(
    (sun_x + cam_x * 0.15).to_int(),
    (sun_y + cam_y * 0.15).to_int(),
    38.0,
    @raylib.Color::new(255, 248, 196, 178),
  )

  for i = 0; i < 140; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 91.0 + fi * fi * 0.17 + game.time_s * 5.0) %
      Float::from_int(screen_w)
    let y = (fi * 58.0 + fi * 11.0) % 230.0
    let tw : Float = 0.42 + 0.58 * sinf(fi * 0.53 + game.time_s * 1.4)
    @raylib.draw_circle(
      (x + cam_x * 0.08).to_int(),
      (y + cam_y * 0.08).to_int(),
      0.8 + tw * 1.2,
      @raylib.Color::new(242, 244, 252, 36 + (tw * 70.0).to_int()),
    )
  }
}

///|
fn draw_dunes(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for layer = 0; layer < 3; layer = layer + 1 {
    let lf = Float::from_int(layer)
    let height : Float = 440.0 + lf * 86.0
    let amp : Float = 24.0 + lf * 14.0
    let speed : Float = 0.12 + lf * 0.08
    let col = if layer == 0 {
      @raylib.Color::new(198, 132, 76, 210)
    } else if layer == 1 {
      @raylib.Color::new(166, 110, 68, 220)
    } else {
      @raylib.Color::new(132, 88, 58, 232)
    }

    for x = -24; x < screen_w + 24; x = x + 24 {
      let fx = Float::from_int(x)
      let y = height +
        sinf(
          fx * 0.015 + game.distance * 0.002 + game.time_s * speed + lf * 0.8,
        ) *
        amp +
        cosf(fx * 0.009 + game.time_s * (0.34 + lf * 0.1)) * (amp * 0.4)
      @raylib.draw_rectangle(
        (fx + cam_x * (0.1 + lf * 0.07)).to_int(),
        (y + cam_y * 0.12).to_int(),
        28,
        screen_h,
        col,
      )
    }
  }
}

///|
fn draw_lanes(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < lane_count; i = i + 1 {
    let y = lane_y(game, i) + cam_y * 0.2
    let li = Float::from_int(i)
    let lane_col = if i % 2 == 0 {
      @raylib.Color::new(196, 146, 86, 78)
    } else {
      @raylib.Color::new(176, 124, 72, 72)
    }

    @raylib.draw_rectangle(
      -40,
      (y - 35.0).to_int(),
      screen_w + 80,
      70,
      lane_col,
    )

    let step = 116
    let shift = ((game.distance * (0.7 + li * 0.1)).to_int() + i * 33) % step
    for x = -step; x < screen_w + step; x = x + step {
      let mut alpha = 68 +
        (sinf(Float::from_int(x) * 0.02 + game.time_s * 1.2 + li) * 24.0).to_int()
      alpha = clampi(alpha, 24, 116)
      @raylib.draw_rectangle(
        x - shift,
        (y - 2.0).to_int(),
        72,
        4,
        @raylib.Color::new(246, 226, 176, alpha),
      )
    }
  }
}

///|
fn draw_perimeter(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let mut t : Float = 0.0
  while t < tau {
    let x0 = caravan_center_x + cosf(t) * perimeter_outer_rx + cam_x * 0.4
    let y0 = caravan_center_y + sinf(t) * perimeter_outer_ry + cam_y * 0.4
    let x1 = caravan_center_x + cosf(t) * perimeter_inner_rx + cam_x * 0.4
    let y1 = caravan_center_y + sinf(t) * perimeter_inner_ry + cam_y * 0.4

    @raylib.draw_circle(
      x0.to_int(),
      y0.to_int(),
      2.0,
      @raylib.Color::new(242, 214, 162, 130),
    )
    @raylib.draw_circle(
      x1.to_int(),
      y1.to_int(),
      1.8,
      @raylib.Color::new(214, 184, 132, 116),
    )

    t = t + tau / 110.0
  }

  if game.state == state_play {
    let prog = checkpoint_progress(game)
    let ring_r = perimeter_outer_rx + 10.0 + sinf(game.time_s * 4.5) * 2.0
    let mut s : Float = 0.0
    while s < tau * prog {
      let x = caravan_center_x + cosf(s) * ring_r + cam_x * 0.2
      let y = caravan_center_y +
        sinf(s) * (perimeter_outer_ry + 8.0) +
        cam_y * 0.2
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        1.8,
        @raylib.Color::new(138, 246, 218, 130),
      )
      s = s + tau / 180.0
    }
  }
}

///|
fn draw_wagons(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.wagons.length(); i = i + 1 {
    let x = (game.wagons[i].x + cam_x).to_int()
    let y = (game.wagons[i].y + cam_y).to_int()
    let hp_ratio = clamp01(
      game.wagons[i].hp / maxf(game.wagons[i].max_hp, 0.001),
    )

    let body_col = if game.wagons[i].hp <= 0.0 {
      @raylib.Color::new(72, 54, 46, 255)
    } else {
      @raylib.Color::new(
        102 + (hp_ratio * 58.0).to_int(),
        74 + (hp_ratio * 34.0).to_int(),
        44,
        255,
      )
    }

    @raylib.draw_rectangle(x - 46, y - 24, 92, 48, body_col)
    @raylib.draw_rectangle(
      x - 42,
      y - 30,
      84,
      14,
      @raylib.Color::new(152, 118, 68, 255),
    )

    @raylib.draw_circle(
      x - 26,
      y + 25,
      9.0,
      @raylib.Color::new(34, 28, 26, 255),
    )
    @raylib.draw_circle(
      x + 26,
      y + 25,
      9.0,
      @raylib.Color::new(34, 28, 26, 255),
    )
    @raylib.draw_circle(
      x - 26,
      y + 25,
      4.0,
      @raylib.Color::new(154, 138, 110, 255),
    )
    @raylib.draw_circle(
      x + 26,
      y + 25,
      4.0,
      @raylib.Color::new(154, 138, 110, 255),
    )

    @raylib.draw_rectangle(
      x - 48,
      y - 26,
      96,
      4,
      @raylib.Color::new(228, 188, 126, 144),
    )

    if game.wagons[i].repair_cd > 0.0 {
      @raylib.draw_circle_lines(
        x,
        y,
        30.0 + sinf(game.time_s * 12.0 + Float::from_int(i)) * 2.0,
        @raylib.Color::new(112, 236, 202, 188),
      )
    }

    let bar_w = 86
    let hp_w = (Float::from_int(bar_w) * hp_ratio).to_int()
    @raylib.draw_rectangle(
      x - bar_w / 2,
      y - 44,
      bar_w,
      8,
      @raylib.Color::new(34, 28, 22, 220),
    )
    @raylib.draw_rectangle(
      x - bar_w / 2,
      y - 44,
      hp_w,
      8,
      @raylib.Color::new(126 + (hp_ratio * 90.0).to_int(), 220, 124, 230),
    )

    if game.wagons[i].hp <= 0.0 {
      @raylib.draw_line(
        x - 40,
        y - 20,
        x + 40,
        y + 20,
        @raylib.Color::new(240, 78, 62, 220),
      )
      @raylib.draw_line(
        x + 40,
        y - 20,
        x - 40,
        y + 20,
        @raylib.Color::new(240, 78, 62, 220),
      )
    }
  }

  @raylib.draw_line(
    (game.wagons[0].x + cam_x + 46.0).to_int(),
    (game.wagons[0].y + cam_y).to_int(),
    (game.wagons[1].x + cam_x - 46.0).to_int(),
    (game.wagons[1].y + cam_y).to_int(),
    @raylib.Color::new(120, 96, 62, 220),
  )
  @raylib.draw_line(
    (game.wagons[1].x + cam_x + 46.0).to_int(),
    (game.wagons[1].y + cam_y).to_int(),
    (game.wagons[2].x + cam_x - 46.0).to_int(),
    (game.wagons[2].y + cam_y).to_int(),
    @raylib.Color::new(120, 96, 62, 220),
  )
}

///|
fn draw_raiders(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.raiders.length(); i = i + 1 {
    if not(game.raiders[i].active) {
      continue
    }

    let x = game.raiders[i].x + cam_x
    let y = game.raiders[i].y + cam_y

    let mut col = if game.raiders[i].kind == raider_brute {
      @raylib.Color::new(212, 86, 62, 255)
    } else if game.raiders[i].kind == raider_rider {
      @raylib.Color::new(252, 166, 68, 255)
    } else {
      @raylib.Color::new(236, 112, 84, 255)
    }

    if game.raiders[i].flash_t > 0.0 {
      col = @raylib.Color::new(250, 236, 214, 255)
    }

    @raylib.draw_circle(x.to_int(), y.to_int(), game.raiders[i].radius, col)

    let mut nx = game.raiders[i].vx
    let mut ny = game.raiders[i].vy
    let n_len = sqrtf(nx * nx + ny * ny)
    if n_len > 0.01 {
      nx = nx / n_len
      ny = ny / n_len
    } else {
      nx = -1.0
      ny = 0.0
    }

    let tip = @raylib.Vector2::new(
      x + nx * (game.raiders[i].radius + 8.0),
      y + ny * (game.raiders[i].radius + 8.0),
    )
    let left = @raylib.Vector2::new(x - ny * 5.0, y + nx * 5.0)
    let right = @raylib.Vector2::new(x + ny * 5.0, y - nx * 5.0)
    @raylib.draw_triangle(tip, left, right, @raylib.Color::new(42, 32, 28, 220))

    let raider_max_hp : Float = if game.raiders[i].kind == raider_brute {
      108.0
    } else if game.raiders[i].kind == raider_rider {
      72.0
    } else {
      62.0
    }
    let hp = clamp01(game.raiders[i].hp / raider_max_hp)
    @raylib.draw_rectangle(
      x.to_int() - 18,
      y.to_int() - 24,
      36,
      4,
      @raylib.Color::new(24, 20, 18, 210),
    )
    @raylib.draw_rectangle(
      x.to_int() - 18,
      y.to_int() - 24,
      (Float::from_int(36) * hp).to_int(),
      4,
      @raylib.Color::new(246, 212, 124, 230),
    )
  }
}

///|
fn draw_bullets(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue
    }

    let alpha = clampi((game.bullets[i].life * 380.0).to_int(), 0, 255)
    @raylib.draw_circle(
      (game.bullets[i].x + cam_x).to_int(),
      (game.bullets[i].y + cam_y).to_int(),
      3.8,
      @raylib.Color::new(246, 244, 172, alpha),
    )
  }
}

///|
fn draw_dust(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.dusts.length(); i = i + 1 {
    if not(game.dusts[i].active) {
      continue
    }

    let mut alpha = clampi((game.dusts[i].life * 280.0).to_int(), 0, 255)
    let col = if game.dusts[i].kind == 1 {
      @raylib.Color::new(238, 118, 86, alpha)
    } else if game.dusts[i].kind == 2 {
      @raylib.Color::new(255, 246, 182, alpha)
    } else if game.dusts[i].kind == 3 {
      alpha = clampi(alpha + 30, 0, 255)
      @raylib.Color::new(120, 244, 204, alpha)
    } else {
      @raylib.Color::new(232, 196, 148, alpha)
    }

    @raylib.draw_circle(
      (game.dusts[i].x + cam_x).to_int(),
      (game.dusts[i].y + cam_y).to_int(),
      game.dusts[i].size,
      col,
    )
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let px = game.hero.x + cam_x
  let py = game.hero.y + cam_y

  let mut col = @raylib.Color::new(92, 222, 236, 255)
  if game.hero.roll_t > 0.0 {
    col = @raylib.Color::new(160, 252, 246, 255)
  } else if game.hero.invuln_t > 0.0 {
    col = @raylib.Color::new(148, 236, 252, 210)
  }

  @raylib.draw_circle(px.to_int(), py.to_int(), player_radius, col)
  @raylib.draw_circle(
    px.to_int(),
    py.to_int(),
    player_radius * 0.56,
    @raylib.Color::new(24, 58, 74, 255),
  )

  @raylib.draw_line(
    px.to_int(),
    py.to_int(),
    (px + game.hero.facing_x * 24.0).to_int(),
    (py + game.hero.facing_y * 24.0).to_int(),
    @raylib.Color::new(252, 246, 192, 255),
  )

  if game.hero.roll_t > 0.0 {
    let pulse : Float = 24.0 + sinf(game.time_s * 32.0) * 2.0
    @raylib.draw_circle_lines(
      px.to_int(),
      py.to_int(),
      pulse,
      @raylib.Color::new(164, 250, 238, 220),
    )
  }

  if game.hero.repair_t > 0.0 {
    @raylib.draw_line(
      (px - 10.0).to_int(),
      py.to_int(),
      (px + 10.0).to_int(),
      py.to_int(),
      @raylib.Color::new(122, 244, 212, 255),
    )
    @raylib.draw_line(
      px.to_int(),
      (py - 10.0).to_int(),
      px.to_int(),
      (py + 10.0).to_int(),
      @raylib.Color::new(122, 244, 212, 255),
    )
  }
}

///|
fn draw_bar(
  name : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fill : @raylib.Color,
  value_text : String,
) -> Unit {
  let r = clamp01(ratio)
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(14, 18, 26, 220))
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    maxi(0, (Float::from_int(w - 4) * r).to_int()),
    h - 4,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(220, 210, 184, 140),
  )
  @raylib.draw_text(
    name,
    x + 8,
    y + 4,
    18,
    @raylib.Color::new(242, 236, 214, 220),
  )
  draw_right_text(
    value_text,
    x + w - 8,
    y + 4,
    18,
    @raylib.Color::new(242, 236, 214, 220),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    124,
    @raylib.Color::new(10, 16, 24, 196),
  )
  @raylib.draw_line(
    0,
    124,
    screen_w,
    124,
    @raylib.Color::new(236, 210, 162, 110),
  )

  draw_bar(
    "Morale",
    24,
    18,
    316,
    28,
    game.morale / morale_max,
    @raylib.Color::new(110, 236, 148, 232),
    "\{game.morale.to_int()}%",
  )

  draw_bar(
    "Ammo",
    24,
    52,
    316,
    28,
    Float::from_int(game.ammo) / Float::from_int(ammo_max),
    @raylib.Color::new(252, 224, 122, 232),
    "\{game.ammo}/\{ammo_max}",
  )

  draw_bar(
    "Repair Kits",
    24,
    86,
    316,
    28,
    Float::from_int(game.repair_kits) / Float::from_int(kit_max),
    @raylib.Color::new(122, 228, 214, 232),
    "\{game.repair_kits}/\{kit_max}",
  )

  @raylib.draw_text(
    "Score: \{game.score}",
    370,
    16,
    28,
    @raylib.Color::new(246, 236, 206, 255),
  )
  @raylib.draw_text(
    "Best: \{game.best_score}",
    370,
    48,
    24,
    @raylib.Color::new(214, 234, 246, 236),
  )
  @raylib.draw_text(
    "Kills: \{game.kills}",
    370,
    76,
    24,
    @raylib.Color::new(236, 194, 170, 236),
  )

  @raylib.draw_text(
    "Checkpoint \{mini(game.checkpoint, checkpoint_total)}/\{checkpoint_total}",
    634,
    16,
    28,
    @raylib.Color::new(242, 232, 202, 255),
  )
  @raylib.draw_text(
    "Distance \{game.distance.to_int()}m",
    634,
    50,
    24,
    @raylib.Color::new(210, 228, 238, 232),
  )
  @raylib.draw_text(
    "Raiders \{active_raider_count(game)}",
    634,
    80,
    24,
    @raylib.Color::new(246, 170, 132, 236),
  )

  let px = 956
  let py = 26
  let pw = 376
  let ph = 24
  let prog = checkpoint_progress(game)
  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 20, 28, 220))
  @raylib.draw_rectangle(
    px + 2,
    py + 2,
    (Float::from_int(pw - 4) * prog).to_int(),
    ph - 4,
    @raylib.Color::new(136, 244, 214, 224),
  )
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(232, 222, 196, 160),
  )
  @raylib.draw_text(
    "To Next Checkpoint",
    px,
    py + 32,
    20,
    @raylib.Color::new(234, 224, 198, 214),
  )

  @raylib.draw_text(
    "WASD/Arrows Move  J Shoot/Confirm  K Repair  Space Roll  P Pause  R Restart",
    344,
    98,
    18,
    @raylib.Color::new(232, 220, 190, 170),
  )

  if game.message.length() > 0 && game.message_t > 0.0 {
    let alpha = clampi((game.message_t * 260.0).to_int(), 0, 255)
    draw_center_text(
      game.message,
      132,
      28,
      @raylib.Color::new(250, 238, 206, alpha),
    )
  }
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 18, 126),
  )

  draw_center_text(
    "Silkroad Caravan Guard 2026",
    156,
    64,
    @raylib.Color::new(246, 230, 188, 255),
  )
  draw_center_text(
    "Escort Survival on Shifting Desert Lanes",
    228,
    30,
    @raylib.Color::new(194, 224, 238, 230),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    292,
    720,
    246,
    @raylib.Color::new(10, 16, 24, 184),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 360,
    292,
    720,
    246,
    @raylib.Color::new(236, 212, 170, 150),
  )

  draw_center_text(
    "Intercept raiders before they reach your wagons.",
    328,
    28,
    @raylib.Color::new(242, 228, 204, 240),
  )
  draw_center_text(
    "Spend kits to repair damage and keep caravan morale above zero.",
    366,
    26,
    @raylib.Color::new(230, 218, 196, 230),
  )
  draw_center_text(
    "Secure \{checkpoint_total} checkpoints to complete the route.",
    402,
    26,
    @raylib.Color::new(230, 218, 196, 230),
  )

  draw_center_text(
    "WASD/Arrows Move   J Shoot/Confirm   K Repair   Space Roll",
    454,
    24,
    @raylib.Color::new(172, 234, 218, 230),
  )
  draw_center_text(
    "P Pause   R Restart",
    486,
    24,
    @raylib.Color::new(172, 234, 218, 230),
  )

  let blink = if @raylib.get_time().to_int() % 2 == 0 { 255 } else { 170 }
  draw_center_text(
    "Press J to start escort",
    576,
    36,
    @raylib.Color::new(252, 244, 188, blink),
  )

  draw_center_text(
    "Best Score: \{game.best_score}",
    630,
    28,
    @raylib.Color::new(216, 232, 242, 230),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 14, 164),
  )
  draw_center_text(
    "Paused",
    screen_h / 2 - 54,
    64,
    @raylib.Color::new(244, 232, 202, 255),
  )
  draw_center_text(
    "Press P or J to resume",
    screen_h / 2 + 20,
    30,
    @raylib.Color::new(216, 232, 246, 236),
  )
  draw_center_text(
    "Press R to restart",
    screen_h / 2 + 58,
    28,
    @raylib.Color::new(196, 220, 238, 222),
  )
}

///|
fn draw_end_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 14, 154),
  )

  let title = if game.state == state_victory {
    "Route Cleared"
  } else {
    "Caravan Lost"
  }

  let title_col = if game.state == state_victory {
    @raylib.Color::new(148, 246, 212, 255)
  } else {
    @raylib.Color::new(250, 140, 108, 255)
  }

  draw_center_text(title, 172, 72, title_col)

  @raylib.draw_rectangle(
    screen_w / 2 - 300,
    278,
    600,
    226,
    @raylib.Color::new(10, 16, 24, 194),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 300,
    278,
    600,
    226,
    @raylib.Color::new(236, 212, 172, 150),
  )

  draw_center_text(
    "Score: \{game.score}",
    316,
    42,
    @raylib.Color::new(242, 234, 212, 255),
  )
  draw_center_text(
    "Best: \{game.best_score}",
    364,
    34,
    @raylib.Color::new(212, 230, 242, 238),
  )
  draw_center_text(
    "Checkpoints: \{mini(game.checkpoint, checkpoint_total)}/\{checkpoint_total}",
    406,
    30,
    @raylib.Color::new(236, 218, 188, 236),
  )
  draw_center_text(
    "Raiders eliminated: \{game.kills}",
    444,
    30,
    @raylib.Color::new(236, 206, 188, 236),
  )

  draw_center_text(
    "Press J to escort again   R to restart immediately",
    548,
    30,
    @raylib.Color::new(194, 228, 238, 232),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_sky(game, cam_x, cam_y)
  draw_dunes(game, cam_x, cam_y)
  draw_lanes(game, cam_x, cam_y)
  draw_perimeter(game, cam_x, cam_y)
  draw_wagons(game, cam_x, cam_y)
  draw_raiders(game, cam_x, cam_y)
  draw_bullets(game, cam_x, cam_y)
  draw_dust(game, cam_x, cam_y)
  draw_player(game, cam_x, cam_y)
}

///|
fn draw_frame(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 12, 18, 255))

  let (cam_x, cam_y) = cam_shake(game)
  draw_world(game, cam_x, cam_y)

  if game.state == state_title {
    draw_title_overlay(game)
    return
  }

  draw_hud(game)

  if game.state == state_pause {
    draw_pause_overlay()
  }

  if game.state == state_game_over || game.state == state_victory {
    draw_end_overlay(game)
  }

  if game.flash_t > 0.0 {
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(
        246,
        236,
        216,
        clampi((game.flash_t * 168.0).to_int(), 0, 255),
      ),
    )
  }
}
