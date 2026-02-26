///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - tw / 2, y, size, col)
}

///|
fn draw_right_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, x - tw, y, size, col)
}

///|
fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
fn cam_shake(game : Game) -> (Float, Float) {
  if game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let amp : Float = minf(24.0, game.shake_t * 40.0)
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
    bg_top(),
    bg_bottom(),
  )

  let moon_x : Float = Float::from_int(screen_w) * 0.8 +
    sinf(game.time_s * 0.16) * 34.0
  let moon_y : Float = Float::from_int(hud_h) +
    74.0 +
    cosf(game.time_s * 0.22) * 14.0

  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    84.0,
    @raylib.Color::new(210, 234, 255, 58),
  )
  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    46.0,
    @raylib.Color::new(232, 246, 255, 130),
  )

  for i = 0; i < 160; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 88.0 + fi * fi * 0.12 + game.time_s * 6.0) %
      Float::from_int(screen_w)
    let y = Float::from_int(hud_h) +
      (fi * 42.0 + fi * 15.0) % Float::from_int(screen_h - hud_h)

    let tw : Float = 0.5 + 0.5 * sinf(fi * 0.7 + game.time_s * 1.4)
    let alpha = 64 + (tw * 112.0).to_int()

    @raylib.draw_circle(
      (x + cam_x * 0.1).to_int(),
      (y + cam_y * 0.1).to_int(),
      0.8 + tw * 1.4,
      @raylib.Color::new(170 + (tw * 70.0).to_int(), 210, 255, alpha),
    )
  }

  for layer = 0; layer < 4; layer = layer + 1 {
    let fl = Float::from_int(layer)
    let yy = Float::from_int(hud_h) + 64.0 + fl * 48.0

    for x = -120; x < screen_w + 180; x = x + 30 {
      let fx = Float::from_int(x)
      let wave = sinf(fx * 0.012 + game.time_s * (0.8 + fl * 0.18) + fl)
      let wave2 = cosf(fx * 0.016 + game.time_s * (0.54 + fl * 0.12) + fl * 1.2)
      let y = yy + wave * (22.0 + fl * 5.0) + wave2 * (14.0 + fl * 2.0)
      let glow : Float = 0.45 + 0.55 * sinf(fx * 0.01 + game.time_s * 1.2 + fl)

      let col = if layer % 2 == 0 {
        @raylib.Color::new(84, 222 + (glow * 24.0).to_int(), 184, 40)
      } else {
        @raylib.Color::new(108, 166 + (glow * 28.0).to_int(), 255, 34)
      }

      @raylib.draw_circle(
        (fx + cam_x * 0.08).to_int(),
        (y + cam_y * 0.08).to_int(),
        20.0 + glow * 6.0,
        col,
      )
    }
  }
}

///|
fn draw_floor_grid(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle(
    play_left.to_int(),
    play_top.to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(8, 18, 34, 44),
  )

  @raylib.draw_rectangle_lines(
    (play_left + cam_x * 0.1).to_int(),
    (play_top + cam_y * 0.1).to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(110, 188, 244, 88),
  )

  let step = 44
  let shift = (game.time_s * 28.0).to_int() % step

  for x = play_left.to_int() - step
      x < play_right.to_int() + step
      x = x + step {
    @raylib.draw_line(
      x - shift,
      play_top.to_int(),
      x - shift,
      play_bottom.to_int(),
      @raylib.Color::new(86, 142, 198, 38),
    )
  }

  for y = play_top.to_int() - step
      y < play_bottom.to_int() + step
      y = y + step {
    @raylib.draw_line(
      play_left.to_int(),
      y - shift,
      play_right.to_int(),
      y - shift,
      @raylib.Color::new(86, 142, 198, 34),
    )
  }
}

///|
fn draw_shrine(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = shrine_x() + cam_x
  let y = shrine_y() + cam_y

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    shrine_radius + 34.0,
    @raylib.Color::new(92, 164, 236, 44),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    shrine_radius,
    @raylib.Color::new(28, 58, 92, 228),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    shrine_radius,
    @raylib.Color::new(134, 216, 255, 170),
  )

  let hp_ratio = clampf(game.shrine_hp / shrine_max_hp, 0.0, 1.0)
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    20.0 + hp_ratio * 12.0,
    @raylib.Color::new(255, 128, 168, 190),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    7.0,
    @raylib.Color::new(236, 248, 255, 220),
  )

  for i = 0; i < bell_count; i = i + 1 {
    let bx = game.bells[i].x + cam_x
    let by = game.bells[i].y + cam_y

    @raylib.draw_line_ex(
      @raylib.Vector2::new(x, y),
      @raylib.Vector2::new(bx, by),
      2.0,
      @raylib.Color::new(122, 194, 242, 84),
    )
  }
}

///|
fn draw_bell(b : Bell, i : Int, cam_x : Float, cam_y : Float) -> Unit {
  let x = b.x + cam_x
  let y = b.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(Float::from_int(i) * 0.7 + b.glow * 8.0)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    26.0 + b.glow * 18.0,
    @raylib.Color::new(120, 224, 255, 34 + (b.glow * 120.0).to_int()),
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    18.0,
    @raylib.Color::new(32, 72, 112, 230),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    18.0,
    @raylib.Color::new(156, 226, 255, 210),
  )

  @raylib.draw_rectangle(
    (x - 5.0).to_int(),
    (y - 12.0).to_int(),
    10,
    16,
    @raylib.Color::new(244, 232, 196, 218),
  )
  @raylib.draw_circle(
    x.to_int(),
    (y + 2.0 + pulse * 2.0).to_int(),
    3.0,
    @raylib.Color::new(255, 188, 126, 230),
  )

  let c : Float = clampf(b.charge, 0.0, 1.0)
  @raylib.draw_rectangle(
    (x - 20.0).to_int(),
    (y + 24.0).to_int(),
    40,
    5,
    @raylib.Color::new(18, 30, 50, 220),
  )
  @raylib.draw_rectangle(
    (x - 20.0).to_int(),
    (y + 24.0).to_int(),
    (Float::from_int(40) * c).to_int(),
    5,
    @raylib.Color::new(124, 244, 204, 220),
  )
}

///|
fn foe_col(kind : Int) -> @raylib.Color {
  if kind == foe_wisp {
    pink()
  } else if kind == foe_brute {
    @raylib.Color::new(255, 170, 118, 255)
  } else if kind == foe_shaman {
    @raylib.Color::new(126, 210, 255, 255)
  } else {
    jade()
  }
}

///|
fn draw_wisp(f : Foe, cam_x : Float, cam_y : Float, pulse : Float) -> Unit {
  let x = f.x + cam_x
  let y = f.y + cam_y

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    f.w * 0.34 + pulse * 4.0,
    @raylib.Color::new(255, 126, 190, 124),
  )
  @raylib.draw_circle(x.to_int(), y.to_int(), f.w * 0.25, pink())
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    f.w * 0.12,
    @raylib.Color::new(32, 24, 44, 220),
  )
}

///|
fn draw_brute(f : Foe, cam_x : Float, cam_y : Float, pulse : Float) -> Unit {
  let x = f.x + cam_x
  let y = f.y + cam_y

  @raylib.draw_rectangle(
    (x - f.w * 0.5).to_int(),
    (y - f.h * 0.5).to_int(),
    f.w.to_int(),
    f.h.to_int(),
    @raylib.Color::new(236, 156, 104, 236),
  )
  @raylib.draw_rectangle_lines(
    (x - f.w * 0.5).to_int(),
    (y - f.h * 0.5).to_int(),
    f.w.to_int(),
    f.h.to_int(),
    @raylib.Color::new(86, 56, 42, 220),
  )

  @raylib.draw_circle(
    (x + pulse * 2.0).to_int(),
    (y - f.h * 0.12).to_int(),
    8.0,
    @raylib.Color::new(40, 30, 22, 230),
  )
}

///|
fn draw_shaman(f : Foe, cam_x : Float, cam_y : Float, pulse : Float) -> Unit {
  let x = f.x + cam_x
  let y = f.y + cam_y

  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y - f.h * 0.52),
    @raylib.Vector2::new(x - f.w * 0.46, y + f.h * 0.4),
    @raylib.Vector2::new(x + f.w * 0.46, y + f.h * 0.4),
    @raylib.Color::new(126, 210, 255, 238),
  )
  @raylib.draw_circle(
    x.to_int(),
    (y - f.h * 0.06).to_int(),
    7.0 + pulse * 2.0,
    @raylib.Color::new(36, 52, 78, 224),
  )
}

///|
fn draw_relic(f : Foe, cam_x : Float, cam_y : Float, pulse : Float) -> Unit {
  let x = f.x + cam_x
  let y = f.y + cam_y

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    f.w * 0.34 + pulse * 4.0,
    @raylib.Color::new(118, 244, 202, 88),
  )
  @raylib.draw_rectangle(
    (x - f.w * 0.3).to_int(),
    (y - f.h * 0.3).to_int(),
    (f.w * 0.6).to_int(),
    (f.h * 0.6).to_int(),
    jade(),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - f.w * 0.3, y),
    @raylib.Vector2::new(x + f.w * 0.3, y),
    2.0,
    @raylib.Color::new(20, 56, 42, 220),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - f.h * 0.3),
    @raylib.Vector2::new(x, y + f.h * 0.3),
    2.0,
    @raylib.Color::new(20, 56, 42, 220),
  )
}

///|
fn draw_foe(f : Foe, cam_x : Float, cam_y : Float) -> Unit {
  if not(f.active) {
    return
  }

  let pulse : Float = 0.5 + 0.5 * sinf(f.phase * 5.0)

  if f.kind == foe_wisp {
    draw_wisp(f, cam_x, cam_y, pulse)
  } else if f.kind == foe_brute {
    draw_brute(f, cam_x, cam_y, pulse)
  } else if f.kind == foe_shaman {
    draw_shaman(f, cam_x, cam_y, pulse)
  } else {
    draw_relic(f, cam_x, cam_y, pulse)
  }

  if f.marked {
    @raylib.draw_circle_lines(
      (f.x + cam_x).to_int(),
      (f.y + cam_y).to_int(),
      maxf(f.w, f.h) * 0.56,
      @raylib.Color::new(126, 244, 255, 180),
    )
  }

  if is_hostile(f.kind) {
    let hp_max : Float = if f.kind == foe_brute {
      44.0
    } else if f.kind == foe_shaman {
      28.0
    } else {
      22.0
    }

    let hp_ratio = clampf(f.hp / hp_max, 0.0, 1.0)
    let hpw = maxf(12.0, f.w)
    let hpx = f.x - hpw * 0.5 + cam_x
    let hpy = f.y - f.h * 0.78 + cam_y

    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      hpw.to_int(),
      4,
      @raylib.Color::new(12, 20, 34, 220),
    )
    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      (hpw * hp_ratio).to_int(),
      4,
      a_col(foe_col(f.kind), 220),
    )
  }
}

///|
fn draw_hero(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let h = game.hero
  let x = h.x + cam_x
  let y = h.y + cam_y

  let inv = if h.invuln > 0.0 { 1.0 } else { 0.0 }
  let body = @raylib.Color::new(
    232 + (inv * 22.0).to_int(),
    242 + (inv * 10.0).to_int(),
    255,
    238,
  )

  if h.aura_t > 0.0 {
    let t = clampf(h.aura_t / 0.42, 0.0, 1.0)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      24.0 + t * 22.0,
      @raylib.Color::new(120, 244, 220, (t * 130.0).to_int()),
    )
  }

  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y - h.h * 0.54),
    @raylib.Vector2::new(x - h.w * 0.5, y + h.h * 0.16),
    @raylib.Vector2::new(x + h.w * 0.5, y + h.h * 0.16),
    body,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y + h.h * 0.56),
    @raylib.Vector2::new(x - h.w * 0.5, y + h.h * 0.16),
    @raylib.Vector2::new(x + h.w * 0.5, y + h.h * 0.16),
    @raylib.Color::new(120, 186, 255, 236),
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    6.0,
    @raylib.Color::new(34, 52, 90, 226),
  )

  let tail_a = sinf(h.anim_t * 10.0) * 6.0
  let tail_b = cosf(h.anim_t * 8.0) * 6.0
  @raylib.draw_circle(
    (x + tail_a).to_int(),
    (y + h.h * 0.72).to_int(),
    4.0,
    @raylib.Color::new(255, 132, 184, 230),
  )
  @raylib.draw_circle(
    (x - tail_b).to_int(),
    (y + h.h * 0.88).to_int(),
    3.0,
    @raylib.Color::new(255, 210, 144, 230),
  )

  if h.hurt_t > 0.0 {
    let t = clampf(h.hurt_t / hero_hurt_time, 0.0, 1.0)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      16.0 + t * 14.0,
      @raylib.Color::new(255, 96, 150, (t * 160.0).to_int()),
    )
  }
}

///|
fn draw_bolts(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.bolts.length(); i = i + 1 {
    if not(game.bolts[i].active) {
      continue
    }

    let x0 = game.bolts[i].x + cam_x
    let y0 = game.bolts[i].y + cam_y
    let vx = game.bolts[i].vx
    let vy = game.bolts[i].vy
    let n2 = maxf(1.0, vx * vx + vy * vy)
    let inv = Float::from_int(1) / sqrtf(n2)
    let len : Float = 16.0
    let col = if game.bolts[i].kind == 1 {
      @raylib.Color::new(128, 236, 255, 230)
    } else {
      @raylib.Color::new(255, 156, 210, 230)
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(x0, y0),
      @raylib.Vector2::new(x0 - vx * inv * len, y0 - vy * inv * len),
      3.0,
      col,
    )
    @raylib.draw_circle(
      x0.to_int(),
      y0.to_int(),
      3.0,
      @raylib.Color::new(244, 240, 250, 220),
    )
  }
}

///|
fn spark_col(kind : Int) -> @raylib.Color {
  if kind == 0 {
    cyan()
  } else if kind == 1 {
    pink()
  } else if kind == 2 {
    jade()
  } else {
    @raylib.Color::new(232, 242, 255, 255)
  }
}

///|
fn draw_fx(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let life = if game.sparks[i].kind == 3 {
      clampf(game.sparks[i].life / 1.6, 0.0, 1.0)
    } else {
      clampf(game.sparks[i].life / 1.1, 0.0, 1.0)
    }

    let col = a_col(spark_col(game.sparks[i].kind), (life * 220.0).to_int())

    if game.sparks[i].kind == 3 {
      @raylib.draw_circle(
        (game.sparks[i].x + cam_x * 0.2).to_int(),
        (game.sparks[i].y + cam_y * 0.2).to_int(),
        maxf(0.6, game.sparks[i].size * (0.4 + life)),
        col,
      )
    } else {
      @raylib.draw_circle(
        (game.sparks[i].x + cam_x).to_int(),
        (game.sparks[i].y + cam_y).to_int(),
        maxf(0.8, game.sparks[i].size * (0.4 + life)),
        col,
      )
    }
  }

  for i = 0; i < game.rings.length(); i = i + 1 {
    if not(game.rings[i].active) {
      continue
    }

    let life = clampf(game.rings[i].life / 1.0, 0.0, 1.0)
    let col = if game.rings[i].kind == 0 {
      a_col(cyan(), (life * 190.0).to_int())
    } else if game.rings[i].kind == 1 {
      a_col(pink(), (life * 190.0).to_int())
    } else {
      a_col(jade(), (life * 190.0).to_int())
    }

    @raylib.draw_circle_lines(
      (game.rings[i].x + cam_x).to_int(),
      (game.rings[i].y + cam_y).to_int(),
      game.rings[i].r,
      col,
    )
  }

  for i = 0; i < game.echoes.length(); i = i + 1 {
    if not(game.echoes[i].active) {
      continue
    }

    let life = clampf(game.echoes[i].life / 0.24, 0.0, 1.0)
    let stretch : Float = Float::from_int(1) +
      absf(sinf(game.echoes[i].rot * 0.06)) * 0.24

    @raylib.draw_rectangle(
      (game.echoes[i].x - game.echoes[i].w * 0.5 * stretch + cam_x * 0.2).to_int(),
      (game.echoes[i].y - game.echoes[i].h * 0.5 + cam_y * 0.2).to_int(),
      maxf(2.0, game.echoes[i].w * stretch).to_int(),
      maxf(2.0, game.echoes[i].h).to_int(),
      @raylib.Color::new(110, 214, 255, (life * 120.0).to_int()),
    )
  }
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  maxv : Float,
  label : String,
  col : @raylib.Color,
) -> Unit {
  let ratio : Float = if maxv <= 0.0 {
    0.0
  } else {
    clampf(value / maxv, 0.0, 1.0)
  }

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(8, 18, 30, 212))
  @raylib.draw_rectangle(
    x,
    y,
    (Float::from_int(w) * ratio).to_int(),
    h,
    a_col(col, 228),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(148, 208, 244, 168),
  )

  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 8,
    16,
    @raylib.Color::new(228, 242, 255, 238),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    hud_h,
    @raylib.Color::new(6, 14, 28, 236),
  )
  @raylib.draw_line(
    0,
    hud_h,
    screen_w,
    hud_h,
    @raylib.Color::new(90, 168, 232, 160),
  )

  draw_bar(
    20,
    18,
    300,
    24,
    game.shrine_hp,
    shrine_max_hp,
    "SHRINE",
    shrine_col(),
  )
  draw_bar(20, 52, 300, 24, game.spirit, spirit_max, "SPIRIT", spirit_col())

  draw_bar(
    338,
    18,
    320,
    24,
    Float::from_int(game.score),
    Float::from_int(maxf(Float::from_int(game.stage_goal), 1.0).to_int()),
    "GOAL",
    amber(),
  )
  draw_bar(
    338,
    52,
    320,
    24,
    game.time_left,
    stage_time_base + Float::from_int(game.stage) * stage_time_bonus,
    "TIME",
    cyan(),
  )

  @raylib.draw_text(
    "STAGE " + game.stage.to_string(),
    684,
    14,
    24,
    @raylib.Color::new(212, 240, 255, 242),
  )
  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    684,
    42,
    22,
    a_col(amber(), 242),
  )
  @raylib.draw_text(
    "GOAL " + game.stage_goal.to_string(),
    684,
    68,
    20,
    @raylib.Color::new(182, 222, 246, 236),
  )

  draw_right_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 20,
    14,
    22,
    @raylib.Color::new(188, 226, 248, 236),
  )
  draw_right_text(
    "DEFEATS " +
    game.defeats.to_string() +
    "  RELICS " +
    game.rescued.to_string(),
    screen_w - 20,
    44,
    20,
    @raylib.Color::new(170, 212, 236, 228),
  )

  let mut bx = 860
  for i = 0; i < bell_count; i = i + 1 {
    @raylib.draw_rectangle(bx, 76, 70, 18, @raylib.Color::new(12, 22, 38, 220))
    @raylib.draw_rectangle(
      bx,
      76,
      (Float::from_int(70) * clampf(game.bells[i].charge, 0.0, 1.0)).to_int(),
      18,
      @raylib.Color::new(124, 244, 214, 220),
    )
    @raylib.draw_rectangle_lines(
      bx,
      76,
      70,
      18,
      @raylib.Color::new(132, 200, 244, 178),
    )
    @raylib.draw_text(
      "B" + (i + 1).to_string(),
      bx + 24,
      77,
      14,
      @raylib.Color::new(236, 246, 255, 236),
    )
    bx = bx + 78
  }

  if game.combo > 1 && game.combo_t > 0.0 {
    let t = clampf(game.combo_t / 3.6, 0.0, 1.0)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      hud_h + 8,
      30,
      @raylib.Color::new(
        255,
        196,
        134,
        (Float::from_int(120) + t * 120.0).to_int(),
      ),
    )
  }

  if game.state == state_play {
    @raylib.draw_text(
      "WASD move  J/SPACE ring  K/SHIFT dash",
      20,
      hud_h + 8,
      20,
      @raylib.Color::new(186, 220, 242, 204),
    )
  }
}

///|
fn draw_button_visual(
  label : String,
  rect : (Float, Float, Float, Float),
  pressed : Bool,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let hot = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )
  let base = if pressed {
    @raylib.Color::new(86, 198, 255, 192)
  } else if hot {
    @raylib.Color::new(64, 126, 188, 176)
  } else {
    @raylib.Color::new(24, 56, 94, 150)
  }

  @raylib.draw_rectangle(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    base,
  )
  @raylib.draw_rectangle_lines(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    @raylib.Color::new(168, 224, 255, 214),
  )

  let ts = 28
  let tw = @raylib.measure_text(label, ts)
  @raylib.draw_text(
    label,
    (rect.0 + rect.2 * 0.5 - Float::from_int(tw) * 0.5).to_int(),
    (rect.1 + rect.3 * 0.5 - Float::from_int(ts) * 0.5).to_int(),
    ts,
    @raylib.Color::new(236, 248, 255, 242),
  )
}

///|
fn draw_touch_controls(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if not(game.touch_mode) {
    return
  }

  if game.state == state_play {
    draw_button_visual(
      "<",
      btn_left_rect(),
      game.input_x < -0.2,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      ">",
      btn_right_rect(),
      game.input_x > 0.2,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "^",
      btn_up_rect(),
      game.input_y < -0.2,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "v",
      btn_down_rect(),
      game.input_y > 0.2,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "RING",
      btn_ring_rect(),
      game.input_ring_press,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "DASH",
      btn_dash_rect(),
      game.input_dash_press,
      mx,
      my,
      hold,
      touch_count,
    )
  } else if game.state == state_title {
    draw_button_visual(
      "START",
      title_start_rect(),
      false,
      mx,
      my,
      hold,
      touch_count,
    )
  } else {
    draw_button_visual("RETRY", retry_rect(), false, mx, my, hold, touch_count)
  }
}

///|
fn draw_title_overlay(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 24, 136),
  )

  draw_center_text(
    "JADE TEMPLE BELLKEEPER 2026",
    120,
    60,
    @raylib.Color::new(228, 246, 255, 250),
  )
  draw_center_text(
    "Ring guardian bells to repel cursed spirits",
    196,
    30,
    @raylib.Color::new(184, 220, 244, 236),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 358,
    248,
    716,
    228,
    @raylib.Color::new(10, 20, 36, 186),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 358,
    248,
    716,
    228,
    @raylib.Color::new(146, 204, 244, 216),
  )

  draw_center_text(
    "HOW TO PLAY",
    268,
    32,
    @raylib.Color::new(242, 248, 255, 240),
  )
  draw_center_text(
    "Move with WASD / arrows",
    314,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Press J / SPACE near a bell to ring shockwaves",
    346,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Use K / SHIFT dash through enemies",
    378,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Protect shrine health and hit stage score goal before time runs out",
    410,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Mobile: tap directional + ring + dash pads",
    442,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )

  let btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn.0,
    btn.1,
    btn.2,
    btn.3,
  )

  @raylib.draw_rectangle(
    btn.0.to_int(),
    btn.1.to_int(),
    btn.2.to_int(),
    btn.3.to_int(),
    if hover {
      @raylib.Color::new(88, 190, 246, 220)
    } else {
      @raylib.Color::new(42, 122, 192, 190)
    },
  )
  @raylib.draw_rectangle_lines(
    btn.0.to_int(),
    btn.1.to_int(),
    btn.2.to_int(),
    btn.3.to_int(),
    @raylib.Color::new(206, 242, 255, 232),
  )

  draw_center_text(
    "PRESS SPACE / ENTER TO START",
    btn.1.to_int() + 28,
    30,
    @raylib.Color::new(240, 250, 255, 246),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = clampf(game.result_t / stage_clear_wait, 0.0, 1.0)
  let y = lerpf(232.0, 166.0, ease_out_cubic(t)).to_int()

  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 18, 30, 124),
  )

  draw_center_text("STAGE CLEAR", y, 68, @raylib.Color::new(158, 255, 226, 246))
  draw_center_text(
    "Bonus +" + (280 + game.stage * 120).to_string(),
    y + 78,
    30,
    a_col(amber(), 240),
  )
  draw_center_text(
    "Next bell cycle loading...",
    y + 118,
    26,
    @raylib.Color::new(206, 238, 255, 234),
  )
}

///|
fn draw_game_over_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(12, 8, 18, 172),
  )

  draw_center_text("SHRINE FALLEN", 150, 66, a_col(pink(), 248))
  draw_center_text(
    "Dark spirits silenced the sanctuary",
    226,
    30,
    @raylib.Color::new(234, 204, 220, 236),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 274,
    278,
    548,
    194,
    @raylib.Color::new(16, 16, 34, 192),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 274,
    278,
    548,
    194,
    @raylib.Color::new(162, 196, 244, 220),
  )

  draw_center_text(
    "STAGE " + game.stage.to_string(),
    302,
    30,
    @raylib.Color::new(214, 232, 255, 242),
  )
  draw_center_text(
    "SCORE " + game.score.to_string(),
    338,
    36,
    a_col(amber(), 246),
  )
  draw_center_text(
    "DEFEATS " +
    game.defeats.to_string() +
    "    RELICS " +
    game.rescued.to_string(),
    386,
    28,
    @raylib.Color::new(188, 214, 238, 236),
  )
  draw_center_text(
    "BEST " + game.best_score.to_string(),
    424,
    28,
    @raylib.Color::new(182, 220, 250, 236),
  )

  let retry = retry_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    retry.0,
    retry.1,
    retry.2,
    retry.3,
  )

  @raylib.draw_rectangle(
    retry.0.to_int(),
    retry.1.to_int(),
    retry.2.to_int(),
    retry.3.to_int(),
    if hover {
      @raylib.Color::new(112, 194, 255, 220)
    } else {
      @raylib.Color::new(62, 124, 196, 192)
    },
  )
  @raylib.draw_rectangle_lines(
    retry.0.to_int(),
    retry.1.to_int(),
    retry.2.to_int(),
    retry.3.to_int(),
    @raylib.Color::new(210, 240, 255, 230),
  )

  draw_center_text(
    "SPACE / ENTER / TAP TO RETRY",
    retry.1.to_int() + 18,
    26,
    @raylib.Color::new(242, 250, 255, 246),
  )
}

///|
fn draw_flash(game : Game) -> Unit {
  if game.flash_t <= 0.0 {
    return
  }

  let t = clampf(game.flash_t / 0.32, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(255, 130, 168, (t * 120.0).to_int()),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_sky(game, cam_x, cam_y)
  draw_floor_grid(game, cam_x, cam_y)
  draw_shrine(game, cam_x, cam_y)

  for i = 0; i < bell_count; i = i + 1 {
    draw_bell(game.bells[i], i, cam_x, cam_y)
  }

  for i = 0; i < game.foes.length(); i = i + 1 {
    if game.foes[i].active && is_relic(game.foes[i].kind) {
      draw_foe(game.foes[i], cam_x, cam_y)
    }
  }

  for i = 0; i < game.foes.length(); i = i + 1 {
    if game.foes[i].active && is_hostile(game.foes[i].kind) {
      draw_foe(game.foes[i], cam_x, cam_y)
    }
  }

  draw_hero(game, cam_x, cam_y)
  draw_bolts(game, cam_x, cam_y)
  draw_fx(game, cam_x, cam_y)
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.clear_background(@raylib.Color::new(6, 12, 24, 255))

  let shake = cam_shake(game)
  draw_world(game, shake.0, shake.1)
  draw_hud(game)

  if game.state == state_title {
    draw_title_overlay(mx, my, hold, touch_count)
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game)
  } else if game.state == state_game_over {
    draw_game_over_overlay(game, mx, my, hold, touch_count)
  }

  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_flash(game)

  if game.state == state_play && game.touch_mode {
    draw_center_text(
      "Mobile: tap arrows + RING + DASH",
      screen_h - 24,
      20,
      @raylib.Color::new(210, 236, 255, 222),
    )
  }
}
