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
    let amp : Float = minf(24.0, game.shake_t * 42.0)
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
    sky_top(),
    sky_bottom(),
  )

  let moon_x : Float = Float::from_int(screen_w) * 0.78 +
    sinf(game.time_s * 0.2) * 44.0
  let moon_y : Float = Float::from_int(hud_h) +
    86.0 +
    cosf(game.time_s * 0.24) * 14.0

  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    88.0,
    @raylib.Color::new(220, 236, 255, 52),
  )
  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    48.0,
    @raylib.Color::new(236, 246, 255, 132),
  )

  for i = 0; i < 180; i = i + 1 {
    let fi = Float::from_int(i)
    let x : Float = (fi * 83.0 + fi * fi * 0.11 + game.time_s * 6.0) %
      Float::from_int(screen_w)
    let y : Float = Float::from_int(hud_h) +
      (fi * 38.0 + fi * fi * 0.27) % Float::from_int(screen_h - hud_h)

    let tw : Float = 0.5 + 0.5 * sinf(fi * 0.66 + game.time_s * 1.4)
    let alpha = 70 + (tw * 120.0).to_int()

    @raylib.draw_circle(
      (x + cam_x * 0.12).to_int(),
      (y + cam_y * 0.12).to_int(),
      0.8 + tw * 1.4,
      @raylib.Color::new(170 + (tw * 70.0).to_int(), 214, 255, alpha),
    )
  }

  for band = 0; band < 4; band = band + 1 {
    let fb = Float::from_int(band)
    let base_y = Float::from_int(hud_h) + 62.0 + fb * 44.0

    for x = -120; x < screen_w + 180; x = x + 30 {
      let fx = Float::from_int(x)
      let wave = sinf(fx * 0.011 + game.time_s * (0.74 + fb * 0.14) + fb)
      let wave2 = cosf(fx * 0.018 + game.time_s * (0.54 + fb * 0.13) + fb * 1.2)
      let y = base_y + wave * (22.0 + fb * 6.0) + wave2 * (12.0 + fb * 3.0)
      let glow : Float = 0.45 + 0.55 * sinf(fx * 0.009 + game.time_s * 1.1 + fb)

      let col = if band % 2 == 0 {
        @raylib.Color::new(96, 222 + (glow * 24.0).to_int(), 188, 42)
      } else {
        @raylib.Color::new(120, 178 + (glow * 28.0).to_int(), 255, 36)
      }

      @raylib.draw_circle(
        (fx + cam_x * 0.1).to_int(),
        (y + cam_y * 0.1).to_int(),
        18.0 + glow * 6.0,
        col,
      )
    }
  }
}

///|
fn draw_far_clouds(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < 24; i = i + 1 {
    let fi = Float::from_int(i)
    let speed : Float = 14.0 + fi * 0.9
    let x : Float = (fi * 120.0 + game.time_s * speed + fi * fi * 0.6) %
      (Float::from_int(screen_w) + 260.0) -
      130.0
    let y : Float = Float::from_int(hud_h) + 30.0 + fi * 29.0 % 220.0
    let w : Float = 80.0 + fi % 4.0 * 34.0
    let h : Float = 30.0 + fi % 3.0 * 12.0

    @raylib.draw_circle(
      (x + cam_x * 0.16).to_int(),
      (y + cam_y * 0.16).to_int(),
      w * 0.32,
      @raylib.Color::new(160, 188, 224, 30),
    )
    @raylib.draw_circle(
      (x + w * 0.24 + cam_x * 0.16).to_int(),
      (y + h * 0.1 + cam_y * 0.16).to_int(),
      w * 0.38,
      @raylib.Color::new(170, 198, 230, 30),
    )
    @raylib.draw_circle(
      (x - w * 0.22 + cam_x * 0.16).to_int(),
      (y + h * 0.08 + cam_y * 0.16).to_int(),
      w * 0.26,
      @raylib.Color::new(150, 180, 218, 28),
    )
  }
}

///|
fn draw_wind_lanes(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let intensity = clampf(
    absf(game.wind_x) /
    (wind_base + Float::from_int(game.stage) * wind_stage_bonus),
    0.0,
    1.0,
  )
  let count = 26 + (intensity * 40.0).to_int()

  for i = 0; i < count; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 76.0 + game.time_s * (140.0 + absf(game.wind_x) * 0.46)) %
      (Float::from_int(screen_w) + 180.0) -
      90.0
    let y = play_top + (fi * 47.0 + fi * fi * 0.9) % (play_bottom - play_top)
    let len : Float = 20.0 + intensity * 40.0
    let dy = game.wind_y * 0.06

    @raylib.draw_line_ex(
      @raylib.Vector2::new(x + cam_x * 0.14, y + cam_y * 0.14),
      @raylib.Vector2::new(x - len + cam_x * 0.14, y + dy + cam_y * 0.14),
      1.0 + intensity * 2.0,
      @raylib.Color::new(188, 224, 255, 36 + (intensity * 66.0).to_int()),
    )
  }
}

///|
fn draw_play_bounds(cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle(
    play_left.to_int(),
    play_top.to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(10, 20, 38, 36),
  )
  @raylib.draw_rectangle_lines(
    (play_left + cam_x * 0.1).to_int(),
    (play_top + cam_y * 0.1).to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(120, 188, 242, 90),
  )
}

///|
fn draw_anchor_and_rope(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let ax = kite_anchor_x(game)
  let ay = kite_anchor_y()
  let kx = game.kite.x
  let ky = game.kite.y

  let sx = ax + cam_x
  let sy = ay + cam_y
  let ex = kx + cam_x
  let ey = ky + cam_y

  let stretch = clampf(
    sqrtf(dist2(ax, ay, kx, ky)) / maxf(game.rope_len, 1.0),
    0.0,
    1.4,
  )

  @raylib.draw_line_ex(
    @raylib.Vector2::new(sx, sy),
    @raylib.Vector2::new(ex, ey),
    2.0 + stretch * 2.0,
    @raylib.Color::new(222, 232, 246, 184),
  )

  @raylib.draw_circle(
    sx.to_int(),
    sy.to_int(),
    10.0,
    @raylib.Color::new(210, 224, 244, 220),
  )
  @raylib.draw_circle(
    sx.to_int(),
    sy.to_int(),
    4.0,
    @raylib.Color::new(58, 84, 120, 220),
  )
}

///|
fn draw_trails(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      continue
    }

    let life = clampf(game.trails[i].life / 0.36, 0.0, 1.0)
    let col = @raylib.Color::new(122, 224, 255, (life * 132.0).to_int())
    let stretch : Float = Float::from_int(1) +
      absf(sinf(game.trails[i].rot * 0.05)) * 0.28

    @raylib.draw_rectangle(
      (game.trails[i].x - game.trails[i].w * 0.5 * stretch + cam_x * 0.2).to_int(),
      (game.trails[i].y - game.trails[i].h * 0.5 + cam_y * 0.2).to_int(),
      maxf(2.0, game.trails[i].w * stretch).to_int(),
      maxf(2.0, game.trails[i].h).to_int(),
      col,
    )
  }
}

///|
fn obj_col(kind : Int) -> @raylib.Color {
  if kind == obj_lantern {
    amber()
  } else if kind == obj_bird {
    pink()
  } else if kind == obj_storm {
    @raylib.Color::new(116, 186, 255, 255)
  } else if kind == obj_orb {
    energy_col()
  } else {
    @raylib.Color::new(255, 200, 146, 255)
  }
}

///|
fn draw_lantern(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let glow : Float = 0.5 + 0.5 * sinf(o.phase * 4.0)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    o.w * 0.45 + glow * 3.0,
    @raylib.Color::new(255, 214, 120, 100),
  )
  @raylib.draw_rectangle(
    (x - o.w * 0.36).to_int(),
    (y - o.h * 0.44).to_int(),
    (o.w * 0.72).to_int(),
    (o.h * 0.86).to_int(),
    amber(),
  )
  @raylib.draw_rectangle(
    (x - o.w * 0.2).to_int(),
    (y - o.h * 0.64).to_int(),
    (o.w * 0.4).to_int(),
    4,
    @raylib.Color::new(240, 236, 220, 210),
  )
  @raylib.draw_line(
    x.to_int(),
    (y + o.h * 0.44).to_int(),
    x.to_int(),
    (y + o.h * 0.8).to_int(),
    @raylib.Color::new(214, 214, 228, 210),
  )
}

///|
fn draw_bird(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let wing : Float = sinf(o.phase * 16.0) * 16.0

  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y - o.h * 0.46),
    @raylib.Vector2::new(x - o.w * 0.42, y + o.h * 0.38),
    @raylib.Vector2::new(x + o.w * 0.42, y + o.h * 0.38),
    pink(),
  )

  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - 2.0),
    @raylib.Vector2::new(x - o.w * 0.72, y - wing),
    4.0,
    @raylib.Color::new(255, 146, 196, 220),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - 2.0),
    @raylib.Vector2::new(x + o.w * 0.72, y - wing),
    4.0,
    @raylib.Color::new(255, 146, 196, 220),
  )

  @raylib.draw_circle(
    x.to_int(),
    (y - o.h * 0.08).to_int(),
    6.0,
    @raylib.Color::new(36, 26, 48, 220),
  )
}

///|
fn draw_storm(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.phase * 3.2)

  @raylib.draw_circle(
    (x - o.w * 0.24).to_int(),
    y.to_int(),
    o.h * 0.4,
    @raylib.Color::new(86, 136, 206, 210),
  )
  @raylib.draw_circle(
    (x + o.w * 0.22).to_int(),
    (y - o.h * 0.04).to_int(),
    o.h * 0.48,
    @raylib.Color::new(96, 148, 218, 218),
  )
  @raylib.draw_circle(
    x.to_int(),
    (y - o.h * 0.24).to_int(),
    o.h * 0.44,
    @raylib.Color::new(106, 160, 228, 226),
  )

  @raylib.draw_triangle(
    @raylib.Vector2::new(x - 8.0, y + o.h * 0.2),
    @raylib.Vector2::new(x + 4.0, y + o.h * 0.2),
    @raylib.Vector2::new(x - 12.0, y + o.h * 0.72 + pulse * 6.0),
    @raylib.Color::new(218, 236, 255, 220),
  )
}

///|
fn draw_orb(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.phase * 5.8)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    o.w * 0.45 + pulse * 3.0,
    @raylib.Color::new(126, 246, 206, 104),
  )
  @raylib.draw_circle(x.to_int(), y.to_int(), o.w * 0.32, energy_col())
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    o.w * 0.14,
    @raylib.Color::new(18, 58, 50, 220),
  )
}

///|
fn draw_koi(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let sway : Float = sinf(o.phase * 9.0) * 9.0

  @raylib.draw_triangle(
    @raylib.Vector2::new(x + o.w * 0.5, y),
    @raylib.Vector2::new(x - o.w * 0.36, y - o.h * 0.42),
    @raylib.Vector2::new(x - o.w * 0.36, y + o.h * 0.42),
    @raylib.Color::new(255, 186, 130, 244),
  )

  @raylib.draw_triangle(
    @raylib.Vector2::new(x - o.w * 0.42, y),
    @raylib.Vector2::new(x - o.w * 0.72, y - o.h * 0.34 + sway),
    @raylib.Vector2::new(x - o.w * 0.72, y + o.h * 0.34 + sway),
    @raylib.Color::new(255, 214, 168, 228),
  )

  @raylib.draw_circle(
    (x + o.w * 0.16).to_int(),
    (y - o.h * 0.1).to_int(),
    4.0,
    @raylib.Color::new(34, 28, 24, 220),
  )
}

///|
fn draw_obj(o : SkyObj, cam_x : Float, cam_y : Float) -> Unit {
  if not(o.active) {
    return
  }

  let base = obj_col(o.kind)

  if o.kind == obj_lantern {
    draw_lantern(o, cam_x, cam_y)
  } else if o.kind == obj_bird {
    draw_bird(o, cam_x, cam_y)
  } else if o.kind == obj_storm {
    draw_storm(o, cam_x, cam_y)
  } else if o.kind == obj_orb {
    draw_orb(o, cam_x, cam_y)
  } else {
    draw_koi(o, cam_x, cam_y)
  }

  if is_hostile(o.kind) {
    let hpw = maxf(12.0, o.w)
    let hpx = o.x - hpw * 0.5 + cam_x
    let hpy = o.y - o.h * 0.8 + cam_y

    let hp_ratio = clampf(
      o.hp /
      maxf(
        1.0,
        if o.kind == obj_storm {
          30.0 + Float::from_int(6 * 1)
        } else {
          20.0 + Float::from_int(4 * 1)
        },
      ),
      0.0,
      1.0,
    )

    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      hpw.to_int(),
      4,
      @raylib.Color::new(10, 18, 32, 220),
    )
    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      (hpw * hp_ratio).to_int(),
      4,
      @raylib.Color::new(255, 126, 170, 220),
    )
  }

  if o.flagged {
    @raylib.draw_circle_lines(
      (o.x + cam_x).to_int(),
      (o.y + cam_y).to_int(),
      maxf(o.w, o.h) * 0.56,
      a_col(base, 168),
    )
  }
}

///|
fn draw_kite(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = game.kite.x + cam_x
  let y = game.kite.y + cam_y

  let body_col = if game.kite.invuln > 0.0 {
    @raylib.Color::new(176, 252, 255, 226)
  } else {
    @raylib.Color::new(242, 244, 252, 244)
  }

  let burst_col = @raylib.Color::new(
    140,
    222,
    255,
    (game.kite.burst_glow * 220.0).to_int(),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    20.0 + game.kite.burst_glow * 22.0,
    burst_col,
  )

  let tilt = game.kite.angle
  let kx0 = x + sinf(tilt * 0.017) * 6.0

  @raylib.draw_triangle(
    @raylib.Vector2::new(kx0, y - game.kite.h * 0.52),
    @raylib.Vector2::new(x - game.kite.w * 0.5, y),
    @raylib.Vector2::new(x + game.kite.w * 0.5, y),
    body_col,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(kx0, y + game.kite.h * 0.52),
    @raylib.Vector2::new(x - game.kite.w * 0.5, y),
    @raylib.Vector2::new(x + game.kite.w * 0.5, y),
    a_col(cyan(), 210),
  )

  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - game.kite.w * 0.5, y),
    @raylib.Vector2::new(x + game.kite.w * 0.5, y),
    3.0,
    @raylib.Color::new(72, 106, 146, 220),
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    5.0,
    @raylib.Color::new(56, 84, 132, 232),
  )

  for i = 0; i < 8; i = i + 1 {
    let fi = Float::from_int(i)
    let sway = sinf(game.kite.anim_t * 8.0 + fi * 0.6) * 8.0
    let tx = x + sinf(game.kite.angle * 0.02) * fi * 1.8 + sway * 0.16
    let ty = y + fi * 14.0 + sway

    @raylib.draw_circle(
      tx.to_int(),
      ty.to_int(),
      maxf(1.0, 4.0 - fi * 0.36),
      if i % 2 == 0 {
        a_col(pink(), 210)
      } else {
        a_col(amber(), 210)
      },
    )
  }

  if game.kite.reel_glow > 0.0 {
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      24.0 + game.kite.reel_glow * 14.0,
      @raylib.Color::new(122, 250, 206, 180),
    )
  }

  if game.kite.hurt_t > 0.0 {
    let t = clampf(game.kite.hurt_t / 0.62, 0.0, 1.0)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      16.0 + t * 16.0,
      @raylib.Color::new(255, 108, 156, (t * 160.0).to_int()),
    )
  }
}

///|
fn spark_col(kind : Int) -> @raylib.Color {
  if kind == 0 {
    amber()
  } else if kind == 1 {
    pink()
  } else if kind == 2 {
    cyan()
  } else {
    @raylib.Color::new(236, 244, 255, 255)
  }
}

///|
fn draw_sparks(game : Game, cam_x : Float, cam_y : Float) -> Unit {
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

  for i = 0; i < game.halos.length(); i = i + 1 {
    if not(game.halos[i].active) {
      continue
    }

    let life = clampf(game.halos[i].life / 1.0, 0.0, 1.0)
    let col = if game.halos[i].kind == 0 {
      a_col(amber(), (life * 190.0).to_int())
    } else if game.halos[i].kind == 1 {
      a_col(pink(), (life * 190.0).to_int())
    } else {
      a_col(cyan(), (life * 190.0).to_int())
    }

    @raylib.draw_circle_lines(
      (game.halos[i].x + cam_x).to_int(),
      (game.halos[i].y + cam_y).to_int(),
      game.halos[i].r,
      col,
    )
  }
}

///|
fn draw_hud_bar(
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

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(8, 20, 34, 214))
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
    @raylib.Color::new(148, 206, 244, 170),
  )

  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 8,
    16,
    @raylib.Color::new(226, 242, 255, 238),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    hud_h,
    @raylib.Color::new(6, 16, 30, 238),
  )
  @raylib.draw_line(
    0,
    hud_h,
    screen_w,
    hud_h,
    @raylib.Color::new(92, 166, 228, 160),
  )

  draw_hud_bar(20, 18, 300, 24, game.calm, calm_max, "CALM", calm_col())
  draw_hud_bar(20, 52, 300, 24, game.energy, energy_max, "ENERGY", energy_col())

  draw_hud_bar(
    338,
    18,
    320,
    24,
    Float::from_int(game.score),
    Float::from_int(maxf(Float::from_int(game.stage_goal), 1.0).to_int()),
    "GOAL",
    wind_col(),
  )

  draw_hud_bar(
    338,
    52,
    320,
    24,
    game.time_left,
    stage_time_base + Float::from_int(game.stage) * stage_time_bonus,
    "TIME",
    amber(),
  )

  @raylib.draw_text(
    "STAGE " + game.stage.to_string(),
    684,
    14,
    24,
    @raylib.Color::new(214, 240, 255, 242),
  )
  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    684,
    42,
    22,
    a_col(amber(), 240),
  )
  @raylib.draw_text(
    "GOAL " + game.stage_goal.to_string(),
    684,
    68,
    20,
    @raylib.Color::new(184, 222, 248, 236),
  )

  draw_right_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 20,
    14,
    22,
    @raylib.Color::new(188, 224, 248, 236),
  )
  draw_right_text(
    "RESCUED " + game.rescued.to_string() + "  HITS " + game.hits.to_string(),
    screen_w - 20,
    44,
    20,
    @raylib.Color::new(170, 214, 236, 228),
  )

  let wind_mag = sqrtf(game.wind_x * game.wind_x + game.wind_y * game.wind_y)
  draw_right_text(
    "WIND " + wind_mag.to_int().to_string(),
    screen_w - 20,
    70,
    18,
    a_col(wind_col(), 220),
  )

  if game.combo > 1 && game.combo_t > 0.0 {
    let t = clampf(game.combo_t / 4.0, 0.0, 1.0)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      hud_h + 6,
      30,
      @raylib.Color::new(
        255,
        200,
        132,
        (Float::from_int(120) + t * 120.0).to_int(),
      ),
    )
  }

  if game.state == state_play {
    @raylib.draw_text(
      "WASD move  SPACE burst  J/SHIFT reel",
      20,
      hud_h + 6,
      20,
      @raylib.Color::new(186, 220, 244, 204),
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
    @raylib.Color::new(84, 196, 255, 194)
  } else if hot {
    @raylib.Color::new(62, 126, 184, 176)
  } else {
    @raylib.Color::new(22, 54, 92, 152)
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
    @raylib.Color::new(166, 224, 255, 214),
  )

  let ts = 28
  let tw = @raylib.measure_text(label, ts)
  @raylib.draw_text(
    label,
    (rect.0 + rect.2 * 0.5 - Float::from_int(tw) * 0.5).to_int(),
    (rect.1 + rect.3 * 0.5 - Float::from_int(ts) * 0.5).to_int(),
    ts,
    @raylib.Color::new(238, 248, 255, 244),
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
      "BURST",
      btn_burst_rect(),
      game.input_burst_press,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "REEL",
      btn_reel_rect(),
      game.input_reel_hold,
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
    @raylib.Color::new(8, 14, 24, 132),
  )

  draw_center_text(
    "CELESTIAL KITE FESTIVAL 2026",
    120,
    60,
    @raylib.Color::new(230, 246, 255, 250),
  )
  draw_center_text(
    "Ride the wind, rescue lanterns, survive storm flocks",
    194,
    30,
    @raylib.Color::new(184, 220, 244, 238),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    246,
    720,
    236,
    @raylib.Color::new(10, 20, 38, 184),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 360,
    246,
    720,
    236,
    @raylib.Color::new(148, 206, 244, 214),
  )

  draw_center_text("CONTROLS", 264, 32, @raylib.Color::new(242, 248, 255, 240))
  draw_center_text(
    "WASD / arrows: steer kite in all directions",
    310,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "SPACE / BURST: shockwave to break nearby threats",
    342,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "J / SHIFT / REEL: shorten rope and resist gusts",
    374,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Collect lanterns to beat goal before time and calm run out",
    406,
    24,
    @raylib.Color::new(194, 222, 244, 236),
  )
  draw_center_text(
    "Mobile: tap pads directly (no drag joystick needed)",
    438,
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
      @raylib.Color::new(88, 190, 244, 220)
    } else {
      @raylib.Color::new(46, 126, 196, 192)
    },
  )
  @raylib.draw_rectangle_lines(
    btn.0.to_int(),
    btn.1.to_int(),
    btn.2.to_int(),
    btn.3.to_int(),
    @raylib.Color::new(206, 244, 255, 232),
  )

  draw_center_text(
    "PRESS SPACE / ENTER TO START",
    btn.1.to_int() + 28,
    30,
    @raylib.Color::new(242, 250, 255, 246),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = clampf(game.result_t / stage_clear_wait, 0.0, 1.0)
  let y = lerpf(230.0, 166.0, ease_out_cubic(t)).to_int()

  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 20, 30, 122),
  )

  draw_center_text("STAGE CLEAR", y, 68, @raylib.Color::new(156, 255, 228, 246))
  draw_center_text(
    "Bonus +" + (220 + game.stage * 90).to_string(),
    y + 78,
    30,
    a_col(amber(), 242),
  )
  draw_center_text(
    "Preparing stronger winds...",
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

  draw_center_text("FESTIVAL LOST", 150, 66, a_col(pink(), 248))
  draw_center_text(
    "The storm swallowed your signal kite",
    226,
    30,
    @raylib.Color::new(232, 204, 220, 236),
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
    @raylib.Color::new(160, 196, 244, 220),
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
    "RESCUED " + game.rescued.to_string() + "    HITS " + game.hits.to_string(),
    386,
    28,
    @raylib.Color::new(190, 216, 238, 238),
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
      @raylib.Color::new(110, 194, 255, 220)
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

  let t = clampf(game.flash_t / 0.36, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(255, 126, 174, (t * 120.0).to_int()),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_sky(game, cam_x, cam_y)
  draw_far_clouds(game, cam_x, cam_y)
  draw_wind_lanes(game, cam_x, cam_y)
  draw_play_bounds(cam_x, cam_y)
  draw_anchor_and_rope(game, cam_x, cam_y)
  draw_trails(game, cam_x, cam_y)

  for i = 0; i < game.objs.length(); i = i + 1 {
    if game.objs[i].active && is_collectible(game.objs[i].kind) {
      draw_obj(game.objs[i], cam_x, cam_y)
    }
  }

  for i = 0; i < game.objs.length(); i = i + 1 {
    if game.objs[i].active && is_hostile(game.objs[i].kind) {
      draw_obj(game.objs[i], cam_x, cam_y)
    }
  }

  draw_kite(game, cam_x, cam_y)
  draw_sparks(game, cam_x, cam_y)
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
      "Mobile: tap directional and action pads",
      screen_h - 24,
      20,
      @raylib.Color::new(210, 236, 255, 220),
    )
  }
}
