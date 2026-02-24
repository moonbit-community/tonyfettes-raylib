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
    let amp = minf(26.0, game.shake_t * 44.0)
    (randf(-amp, amp), randf(-amp, amp))
  }
}

///|
fn scene_tint(game : Game) -> @raylib.Color {
  let cold = clampf(1.0 - game.heat / maxf(heat_max, 1.0), 0.0, 1.0)
  @raylib.Color::new(
    18 + (cold * 30.0).to_int(),
    28 + (cold * 18.0).to_int(),
    44 + (cold * 14.0).to_int(),
    255,
  )
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

  let tint = scene_tint(game)
  @raylib.draw_rectangle(0, 0, screen_w, screen_h, a_col(tint, 42))

  let moon_x = Float::from_int(screen_w) * 0.78 +
    sinf(game.time_s * 0.12) * 34.0
  let moon_y = Float::from_int(hud_h) + 86.0 + cosf(game.time_s * 0.18) * 18.0
  @raylib.draw_circle(
    (moon_x + cam_x * 0.24).to_int(),
    (moon_y + cam_y * 0.24).to_int(),
    72.0,
    @raylib.Color::new(220, 238, 255, 64),
  )
  @raylib.draw_circle(
    (moon_x + cam_x * 0.24).to_int(),
    (moon_y + cam_y * 0.24).to_int(),
    40.0,
    @raylib.Color::new(242, 248, 255, 132),
  )

  for i = 0; i < 200; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 89.0 + fi * fi * 0.13 + game.time_s * 7.0) %
      Float::from_int(screen_w)
    let mut y = (fi * 41.0 + fi * 13.0) % Float::from_int(screen_h - hud_h)
    y = y + Float::from_int(hud_h)

    let tw : Float = 0.45 + 0.55 * sinf(fi * 0.73 + game.time_s * 1.4)
    let alpha = 60 + (tw * 110.0).to_int()
    @raylib.draw_circle(
      (x + cam_x * 0.12).to_int(),
      (y + cam_y * 0.12).to_int(),
      0.7 + tw * 1.3,
      @raylib.Color::new(170 + (tw * 70.0).to_int(), 214, 255, alpha),
    )
  }

  for band = 0; band < 4; band = band + 1 {
    let fb = Float::from_int(band)
    let base_y = Float::from_int(hud_h) + 56.0 + fb * 42.0
    for x = -120; x < screen_w + 180; x = x + 26 {
      let fx = Float::from_int(x)
      let wave = sinf(fx * 0.012 + game.time_s * (0.8 + fb * 0.2) + fb)
      let wave2 = cosf(fx * 0.018 + game.time_s * (0.46 + fb * 0.16) + fb * 1.2)
      let y = base_y + wave * (26.0 + fb * 5.0) + wave2 * (16.0 + fb * 3.0)
      let glow : Float = 0.45 +
        0.55 * sinf(fx * 0.01 + game.time_s * 1.2 + fb * 0.8)
      let col = if band % 2 == 0 {
        @raylib.Color::new(84, 224 + (glow * 20.0).to_int(), 186, 42)
      } else {
        @raylib.Color::new(108, 170 + (glow * 28.0).to_int(), 255, 34)
      }
      @raylib.draw_circle(
        (fx + cam_x * 0.1).to_int(),
        (y + cam_y * 0.1).to_int(),
        22.0 + glow * 6.0,
        col,
      )
    }
  }
}

///|
fn mountain_col(depth : Int) -> @raylib.Color {
  if depth == 0 {
    @raylib.Color::new(20, 34, 58, 220)
  } else if depth == 1 {
    @raylib.Color::new(24, 46, 72, 192)
  } else {
    @raylib.Color::new(34, 58, 90, 170)
  }
}

///|
fn draw_mountains(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let horizon = Float::from_int(hud_h) + 156.0

  for layer = 0; layer < 3; layer = layer + 1 {
    let depth = Float::from_int(layer + 1)
    let speed : Float = 0.08 * depth
    let shift : Float = game.distance * speed % 260.0
    let col = mountain_col(layer)

    for i = -2; i < 12; i = i + 1 {
      let base_x = Float::from_int(i * 180) - shift
      let peak_x = base_x + 90.0 + sinf(Float::from_int(i) * 0.6 + depth) * 32.0
      let peak_y = horizon -
        120.0 -
        depth * 42.0 -
        absf(sinf(Float::from_int(i) * 0.7 + game.time_s * 0.06)) * 30.0
      let right_x = base_x + 180.0

      @raylib.draw_triangle(
        @raylib.Vector2::new(
          base_x + cam_x * (0.09 * depth),
          horizon + cam_y * 0.08,
        ),
        @raylib.Vector2::new(
          peak_x + cam_x * (0.09 * depth),
          peak_y + cam_y * 0.08,
        ),
        @raylib.Vector2::new(
          right_x + cam_x * (0.09 * depth),
          horizon + cam_y * 0.08,
        ),
        col,
      )

      @raylib.draw_triangle(
        @raylib.Vector2::new(
          peak_x + cam_x * (0.09 * depth),
          peak_y + cam_y * 0.08,
        ),
        @raylib.Vector2::new(
          peak_x + 28.0 + cam_x * (0.09 * depth),
          peak_y + 20.0 + cam_y * 0.08,
        ),
        @raylib.Vector2::new(
          peak_x - 18.0 + cam_x * (0.09 * depth),
          peak_y + 26.0 + cam_y * 0.08,
        ),
        @raylib.Color::new(222, 238, 255, 88),
      )
    }
  }
}

///|
fn roof_y() -> Float {
  lane_top - 76.0
}

///|
fn roof_h() -> Float {
  Float::from_int(screen_h) - roof_y() - 30.0
}

///|
fn car_seam_col() -> @raylib.Color {
  @raylib.Color::new(24, 52, 82, 220)
}

///|
fn rail_col() -> @raylib.Color {
  @raylib.Color::new(90, 174, 230, 184)
}

///|
fn draw_train_body(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let y = roof_y()
  let h = roof_h()

  @raylib.draw_rectangle(
    0,
    (y + cam_y).to_int(),
    screen_w,
    h.to_int(),
    @raylib.Color::new(16, 34, 58, 244),
  )

  @raylib.draw_rectangle(
    0,
    (y + cam_y + 10.0).to_int(),
    screen_w,
    (h * 0.42).to_int(),
    @raylib.Color::new(18, 40, 68, 236),
  )

  let seam_step = 160
  let seam_shift = (game.distance * 0.38).to_int() % seam_step
  for x = -seam_step; x < screen_w + seam_step; x = x + seam_step {
    let xx = x - seam_shift
    @raylib.draw_rectangle(
      (Float::from_int(xx) + cam_x * 0.22).to_int(),
      (y + cam_y).to_int(),
      10,
      h.to_int(),
      car_seam_col(),
    )

    @raylib.draw_circle(
      (Float::from_int(xx) + 5.0 + cam_x * 0.22).to_int(),
      (y + cam_y + 28.0).to_int(),
      3.0,
      @raylib.Color::new(130, 188, 234, 188),
    )
    @raylib.draw_circle(
      (Float::from_int(xx) + 5.0 + cam_x * 0.22).to_int(),
      (y + cam_y + h - 26.0).to_int(),
      3.0,
      @raylib.Color::new(130, 188, 234, 188),
    )
  }

  for i = 0; i < lane_count; i = i + 1 {
    let ly = lane_y(i)
    @raylib.draw_line(
      (cam_x * 0.18).to_int(),
      (ly + cam_y).to_int(),
      (Float::from_int(screen_w) + cam_x * 0.18).to_int(),
      (ly + cam_y).to_int(),
      rail_col(),
    )

    @raylib.draw_line(
      (cam_x * 0.18).to_int(),
      (ly + 34.0 + cam_y).to_int(),
      (Float::from_int(screen_w) + cam_x * 0.18).to_int(),
      (ly + 34.0 + cam_y).to_int(),
      a_col(rail_col(), 120),
    )
  }

  let stripe_step = 84
  let stripe_shift = (game.distance * 0.8).to_int() % stripe_step
  for x = -stripe_step; x < screen_w + stripe_step; x = x + stripe_step {
    let xx = x - stripe_shift
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(xx) + cam_x * 0.22, y + 8.0 + cam_y),
      @raylib.Vector2::new(
        Float::from_int(xx + 24) + cam_x * 0.22,
        y + 34.0 + cam_y,
      ),
      2.0,
      @raylib.Color::new(80, 154, 220, 70),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(
        Float::from_int(xx) + cam_x * 0.22,
        y + h - 8.0 + cam_y,
      ),
      @raylib.Vector2::new(
        Float::from_int(xx + 24) + cam_x * 0.22,
        y + h - 34.0 + cam_y,
      ),
      2.0,
      @raylib.Color::new(80, 154, 220, 70),
    )
  }
}

///|
fn draw_speed_lines(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let intensity = clampf((game.scroll - base_scroll) / 120.0, 0.0, 1.0)
  let count = 26 + (intensity * 44.0).to_int()

  for i = 0; i < count; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 58.0 + game.time_s * (180.0 + game.scroll * 0.34)) %
      (Float::from_int(screen_w) + 160.0) -
      80.0
    let y = Float::from_int(hud_h) +
      (fi * 41.0 + fi * fi * 0.9) % Float::from_int(screen_h - hud_h)
    let len : Float = 26.0 + intensity * 46.0
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x + cam_x * 0.14, y + cam_y * 0.14),
      @raylib.Vector2::new(x - len + cam_x * 0.14, y + cam_y * 0.14),
      1.0 + intensity * 2.6,
      @raylib.Color::new(198, 236, 255, 40 + (intensity * 64.0).to_int()),
    )
  }
}

///|
fn ent_base_col(kind : Int) -> @raylib.Color {
  if kind == ent_guard {
    @raylib.Color::new(255, 136, 162, 255)
  } else if kind == ent_drone {
    @raylib.Color::new(114, 236, 255, 255)
  } else if kind == ent_turret {
    @raylib.Color::new(255, 186, 118, 255)
  } else if kind == ent_crate {
    @raylib.Color::new(220, 150, 100, 255)
  } else if kind == ent_medkit {
    @raylib.Color::new(255, 108, 130, 255)
  } else if kind == ent_battery {
    heat_col()
  } else {
    @raylib.Color::new(212, 172, 255, 255)
  }
}

///|
fn draw_shadow_blobs(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.shadows.length(); i = i + 1 {
    if not(game.shadows[i].active) {
      continue
    }

    let t = clampf(game.shadows[i].life / 0.28, 0.0, 1.0)
    let a = (t * 120.0).to_int()
    let col = @raylib.Color::new(30, 64, 104, a)

    let stretch : Float = Float::from_int(1) +
      absf(sinf(game.shadows[i].rot * 0.05)) * 0.24
    let kind_boost = Float::from_int(game.shadows[i].kind) * 0.08
    @raylib.draw_rectangle(
      (game.shadows[i].x - game.shadows[i].w * (0.5 + kind_boost) + cam_x * 0.34).to_int(),
      (game.shadows[i].y - game.shadows[i].h * 0.5 + cam_y * 0.34).to_int(),
      maxf(2.0, game.shadows[i].w * stretch).to_int(),
      maxf(2.0, game.shadows[i].h).to_int(),
      col,
    )
  }
}

///|
fn draw_guard(
  e : Ent,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y

  @raylib.draw_rectangle(
    (x - e.w * 0.35).to_int(),
    (y - e.h * 0.48).to_int(),
    (e.w * 0.7).to_int(),
    (e.h * 0.64).to_int(),
    col,
  )
  @raylib.draw_circle(
    x.to_int(),
    (y - e.h * 0.62).to_int(),
    12.0,
    a_col(col, 220),
  )
  @raylib.draw_rectangle(
    (x + e.w * 0.18).to_int(),
    (y - e.h * 0.16).to_int(),
    18,
    4,
    @raylib.Color::new(246, 232, 220, 240),
  )

  @raylib.draw_circle(
    (x - 4.0).to_int(),
    (y - e.h * 0.62).to_int(),
    3.0,
    @raylib.Color::new(16, 26, 36, 230),
  )
  @raylib.draw_circle(
    (x + 4.0).to_int(),
    (y - e.h * 0.62).to_int(),
    3.0,
    @raylib.Color::new(16, 26, 36, 230),
  )
}

///|
fn draw_drone(
  e : Ent,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 4.0)

  @raylib.draw_circle(x.to_int(), y.to_int(), e.w * 0.36, col)
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    e.w * 0.2,
    @raylib.Color::new(16, 34, 44, 240),
  )

  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - e.w * 0.6, y),
    @raylib.Vector2::new(x + e.w * 0.6, y),
    4.0,
    a_col(col, 190),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - e.h * 0.6),
    @raylib.Vector2::new(x, y + e.h * 0.6),
    4.0,
    a_col(col, 190),
  )

  @raylib.draw_circle(
    (x + cosf(e.spin * 3.2) * 16.0).to_int(),
    (y + sinf(e.spin * 2.9) * 16.0).to_int(),
    4.0 + pulse * 2.0,
    @raylib.Color::new(220, 255, 255, 200),
  )
}

///|
fn draw_turret(
  e : Ent,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y

  @raylib.draw_rectangle(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.42).to_int(),
    e.w.to_int(),
    (e.h * 0.78).to_int(),
    col,
  )

  @raylib.draw_rectangle(
    (x - e.w * 0.14).to_int(),
    (y - e.h * 0.66).to_int(),
    (e.w * 0.28).to_int(),
    (e.h * 0.26).to_int(),
    @raylib.Color::new(240, 236, 216, 210),
  )

  @raylib.draw_rectangle(
    (x - e.w * 0.62).to_int(),
    (y - e.h * 0.26).to_int(),
    (e.w * 0.4).to_int(),
    6,
    @raylib.Color::new(248, 226, 190, 220),
  )
  @raylib.draw_rectangle(
    (x - e.w * 0.62).to_int(),
    (y - e.h * 0.06).to_int(),
    (e.w * 0.4).to_int(),
    6,
    @raylib.Color::new(248, 226, 190, 220),
  )
}

///|
fn draw_crate(
  e : Ent,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y

  @raylib.draw_rectangle(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.5).to_int(),
    e.w.to_int(),
    e.h.to_int(),
    col,
  )
  @raylib.draw_rectangle_lines(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.5).to_int(),
    e.w.to_int(),
    e.h.to_int(),
    @raylib.Color::new(70, 44, 32, 220),
  )

  @raylib.draw_line(
    (x - e.w * 0.5).to_int(),
    y.to_int(),
    (x + e.w * 0.5).to_int(),
    y.to_int(),
    @raylib.Color::new(70, 44, 32, 220),
  )
  @raylib.draw_line(
    x.to_int(),
    (y - e.h * 0.5).to_int(),
    x.to_int(),
    (y + e.h * 0.5).to_int(),
    @raylib.Color::new(70, 44, 32, 220),
  )
}

///|
fn draw_pickup(
  e : Ent,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y

  if e.kind == ent_medkit {
    @raylib.draw_circle(x.to_int(), y.to_int(), 18.0, col)
    @raylib.draw_rectangle(
      (x - 5.0).to_int(),
      (y - 12.0).to_int(),
      10,
      24,
      @raylib.Color::new(255, 242, 242, 236),
    )
    @raylib.draw_rectangle(
      (x - 12.0).to_int(),
      (y - 5.0).to_int(),
      24,
      10,
      @raylib.Color::new(255, 242, 242, 236),
    )
  } else if e.kind == ent_battery {
    @raylib.draw_rectangle(
      (x - 15.0).to_int(),
      (y - 17.0).to_int(),
      30,
      34,
      col,
    )
    @raylib.draw_rectangle(
      (x - 5.0).to_int(),
      (y - 23.0).to_int(),
      10,
      6,
      @raylib.Color::new(198, 240, 220, 220),
    )
    @raylib.draw_rectangle(
      (x - 9.0).to_int(),
      (y - 7.0).to_int(),
      18,
      14,
      @raylib.Color::new(12, 42, 34, 220),
    )
  } else {
    let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 3.5)
    @raylib.draw_circle(x.to_int(), y.to_int(), 16.0 + pulse * 4.0, col)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      9.0,
      @raylib.Color::new(24, 24, 50, 210),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x - 8.0, y),
      @raylib.Vector2::new(x + 8.0, y),
      2.0,
      @raylib.Color::new(242, 244, 255, 214),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x, y - 8.0),
      @raylib.Vector2::new(x, y + 8.0),
      2.0,
      @raylib.Color::new(242, 244, 255, 214),
    )
  }
}

///|
fn draw_ent(e : Ent, cam_x : Float, cam_y : Float) -> Unit {
  if not(e.active) {
    return
  }

  let mut col = ent_base_col(e.kind)
  if e.cloak {
    col = a_col(col, 84)
  }

  if e.kind == ent_guard {
    draw_guard(e, col, cam_x, cam_y)
  } else if e.kind == ent_drone {
    draw_drone(e, col, cam_x, cam_y)
  } else if e.kind == ent_turret {
    draw_turret(e, col, cam_x, cam_y)
  } else if e.kind == ent_crate {
    draw_crate(e, col, cam_x, cam_y)
  } else {
    draw_pickup(e, col, cam_x, cam_y)
  }

  if is_hostile(e.kind) {
    let hpw = maxf(8.0, e.w)
    let hpx = e.x - hpw * 0.5 + cam_x
    let hpy = e.y - e.h * 0.72 + cam_y
    let pct = clampf(
      e.hp / maxf(1.0, if e.kind == ent_crate { 35.0 } else { 24.0 }),
      0.0,
      1.0,
    )
    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      hpw.to_int(),
      4,
      @raylib.Color::new(18, 24, 36, 210),
    )
    @raylib.draw_rectangle(
      hpx.to_int(),
      hpy.to_int(),
      (hpw * pct).to_int(),
      4,
      @raylib.Color::new(255, 112, 150, 210),
    )
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let h = game.hero
  let x = h.x + cam_x
  let y = h.y + cam_y

  let dash_ratio = clampf(game.dash_t / maxf(dash_time, 0.001), 0.0, 1.0)
  let hurt_ratio = clampf(h.hurt_t / 0.56, 0.0, 1.0)

  let body_col = if h.invuln > 0.0 {
    @raylib.Color::new(178, 254, 255, 220)
  } else {
    @raylib.Color::new(246, 246, 250, 244)
  }

  let coat_col = @raylib.Color::new(
    82 + (dash_ratio * 60.0).to_int(),
    142 + (dash_ratio * 70.0).to_int(),
    220,
    240,
  )

  let lean = h.heading * 0.24
  let bob = if h.grounded {
    sinf(h.anim_t * 14.0) * 2.5 * (0.4 + absf(h.vx) / player_max_vx)
  } else {
    0.0
  }

  @raylib.draw_circle(
    (x + lean * 0.2).to_int(),
    (y - h.h * 0.66 + bob).to_int(),
    14.0,
    body_col,
  )
  @raylib.draw_circle(
    (x + lean * 0.2).to_int(),
    (y - h.h * 0.66 + bob).to_int(),
    6.0,
    @raylib.Color::new(26, 32, 52, 230),
  )

  @raylib.draw_rectangle(
    (x - h.w * 0.28 + lean).to_int(),
    (y - h.h * 0.52 + bob).to_int(),
    (h.w * 0.56).to_int(),
    (h.h * 0.62).to_int(),
    coat_col,
  )

  let leg_swing = sinf(h.anim_t * 12.0) * 6.0 * (absf(h.vx) / player_max_vx)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - 8.0 + lean, y - 4.0 + bob),
    @raylib.Vector2::new(x - 8.0 + lean - leg_swing, y + 24.0 + bob),
    6.0,
    @raylib.Color::new(186, 220, 246, 234),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x + 8.0 + lean, y - 4.0 + bob),
    @raylib.Vector2::new(x + 8.0 + lean + leg_swing, y + 24.0 + bob),
    6.0,
    @raylib.Color::new(186, 220, 246, 234),
  )

  let arm_reach : Float = if game.input_fire_hold { 24.0 } else { 16.0 }
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x + 8.0 + lean, y - h.h * 0.32 + bob),
    @raylib.Vector2::new(x + arm_reach + lean, y - h.h * 0.26 + bob),
    5.0,
    @raylib.Color::new(226, 236, 248, 236),
  )

  @raylib.draw_rectangle(
    (x + arm_reach + lean - 2.0).to_int(),
    (y - h.h * 0.28 + bob - 2.0).to_int(),
    18,
    4,
    @raylib.Color::new(242, 220, 188, 240),
  )

  if h.muzzle_t > 0.0 {
    let t = clampf(h.muzzle_t / 0.12, 0.0, 1.0)
    @raylib.draw_circle(
      (x + arm_reach + 20.0 + lean).to_int(),
      (y - h.h * 0.28 + bob).to_int(),
      4.0 + t * 10.0,
      @raylib.Color::new(255, 226, 136, 160 + (t * 80.0).to_int()),
    )
  }

  if game.hook_t > 0.0 {
    let t = clampf(game.hook_t / hook_time, 0.0, 1.0)
    let r = hook_radius * (0.5 + (1.0 - t) * 0.5)
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      r,
      @raylib.Color::new(124, 244, 255, 120),
    )
  }

  if hurt_ratio > 0.0 {
    let hurt_col = @raylib.Color::new(
      255,
      72,
      122,
      (hurt_ratio * 160.0).to_int(),
    )
    @raylib.draw_circle(
      (x - h.w * 0.08).to_int(),
      (y - h.h * 0.26).to_int(),
      16.0 + hurt_ratio * 10.0,
      hurt_col,
    )
  }
}

///|
fn shot_col(s : Shot) -> @raylib.Color {
  if s.from_player {
    if s.kind == 1 {
      @raylib.Color::new(255, 212, 112, 255)
    } else {
      cyan()
    }
  } else if s.kind == 0 {
    @raylib.Color::new(255, 128, 176, 255)
  } else if s.kind == 1 {
    @raylib.Color::new(126, 240, 255, 255)
  } else {
    @raylib.Color::new(255, 190, 120, 255)
  }
}

///|
fn draw_shots(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.shots.length(); i = i + 1 {
    if not(game.shots[i].active) {
      continue
    }

    let col = shot_col(game.shots[i])
    let len : Float = if game.shots[i].from_player { 18.0 } else { 12.0 }
    let vx = game.shots[i].vx
    let vy = game.shots[i].vy
    let v2 = maxf(1.0, vx * vx + vy * vy)
    let inv = Float::from_int(1) / sqrtf(v2)

    let x0 = game.shots[i].x + cam_x
    let y0 = game.shots[i].y + cam_y
    let x1 = x0 - vx * inv * len
    let y1 = y0 - vy * inv * len

    @raylib.draw_line_ex(
      @raylib.Vector2::new(x0, y0),
      @raylib.Vector2::new(x1, y1),
      if game.shots[i].from_player {
        3.4
      } else {
        2.8
      },
      col,
    )
    @raylib.draw_circle(
      x0.to_int(),
      y0.to_int(),
      if game.shots[i].from_player {
        3.6
      } else {
        3.0
      },
      @raylib.Color::new(250, 250, 250, 220),
    )
  }
}

///|
fn fx_col(kind : Int) -> @raylib.Color {
  if kind == 0 {
    cyan()
  } else if kind == 1 {
    @raylib.Color::new(255, 116, 166, 255)
  } else if kind == 2 {
    @raylib.Color::new(118, 246, 212, 255)
  } else {
    snow_col()
  }
}

///|
fn draw_fx(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.fxs.length(); i = i + 1 {
    if not(game.fxs[i].active) {
      continue
    }

    let base = fx_col(game.fxs[i].kind)
    let life_norm = if game.fxs[i].kind == 3 {
      clampf(game.fxs[i].life / 1.4, 0.0, 1.0)
    } else {
      clampf(game.fxs[i].life / 1.0, 0.0, 1.0)
    }
    let col = a_col(base, (life_norm * 220.0).to_int())

    if game.fxs[i].kind == 3 {
      @raylib.draw_circle(
        (game.fxs[i].x + cam_x * 0.2).to_int(),
        (game.fxs[i].y + cam_y * 0.2).to_int(),
        maxf(0.6, game.fxs[i].size * (0.5 + life_norm)),
        col,
      )
    } else {
      @raylib.draw_circle(
        (game.fxs[i].x + cam_x).to_int(),
        (game.fxs[i].y + cam_y).to_int(),
        maxf(0.8, game.fxs[i].size * (0.4 + life_norm)),
        col,
      )
    }
  }

  for i = 0; i < game.rings.length(); i = i + 1 {
    if not(game.rings[i].active) {
      continue
    }

    let life_norm = clampf(game.rings[i].life / 1.0, 0.0, 1.0)
    let col = if game.rings[i].kind == 0 {
      a_col(cyan(), (life_norm * 190.0).to_int())
    } else if game.rings[i].kind == 1 {
      a_col(
        @raylib.Color::new(255, 122, 166, 255),
        (life_norm * 190.0).to_int(),
      )
    } else {
      a_col(
        @raylib.Color::new(146, 255, 214, 255),
        (life_norm * 190.0).to_int(),
      )
    }

    @raylib.draw_circle_lines(
      (game.rings[i].x + cam_x).to_int(),
      (game.rings[i].y + cam_y).to_int(),
      game.rings[i].r,
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

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(10, 20, 34, 210))
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
    @raylib.Color::new(152, 214, 244, 170),
  )

  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 8,
    16,
    @raylib.Color::new(226, 238, 252, 236),
  )
}

///|
fn draw_cooldown(
  label : String,
  value : Float,
  maxv : Float,
  x : Int,
  y : Int,
  w : Int,
) -> Unit {
  let pct : Float = if maxv <= 0.0 {
    0.0
  } else {
    clampf(1.0 - value / maxv, 0.0, 1.0)
  }

  @raylib.draw_rectangle(x, y, w, 18, @raylib.Color::new(14, 26, 44, 220))
  @raylib.draw_rectangle(
    x,
    y,
    (Float::from_int(w) * pct).to_int(),
    18,
    @raylib.Color::new(112, 230, 206, 220),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    18,
    @raylib.Color::new(134, 188, 236, 180),
  )
  @raylib.draw_text(
    label,
    x + 6,
    y + 1,
    14,
    @raylib.Color::new(236, 246, 255, 230),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    hud_h,
    @raylib.Color::new(8, 18, 30, 236),
  )
  @raylib.draw_line(
    0,
    hud_h,
    screen_w,
    hud_h,
    @raylib.Color::new(90, 170, 228, 160),
  )

  draw_hud_bar(20, 20, 300, 24, game.armor, armor_max, "ARMOR", armor_col())
  draw_hud_bar(20, 54, 300, 24, game.heat, heat_max, "HEAT", heat_col())

  let stage_ratio = clampf(game.distance / maxf(game.stage_goal, 1.0), 0.0, 1.0)
  draw_hud_bar(
    340,
    20,
    320,
    24,
    stage_ratio,
    1.0,
    "STAGE PROGRESS",
    @raylib.Color::new(120, 188, 255, 255),
  )

  draw_cooldown("DASH", game.dash_cd, dash_cd_time, 340, 54, 100)
  draw_cooldown("HOOK", game.hook_cd, hook_cd_time, 454, 54, 100)
  draw_cooldown("FIRE", game.fire_cd, fire_cd_base, 568, 54, 92)

  @raylib.draw_text(
    "STAGE " + game.stage.to_string(),
    690,
    16,
    24,
    @raylib.Color::new(214, 240, 255, 242),
  )
  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    690,
    46,
    22,
    a_col(amber(), 238),
  )

  draw_right_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 20,
    16,
    22,
    @raylib.Color::new(184, 216, 246, 238),
  )
  draw_right_text(
    "KILLS " + game.kills.to_string() + "  LOOT " + game.loot.to_string(),
    screen_w - 20,
    48,
    20,
    @raylib.Color::new(170, 212, 236, 228),
  )

  if game.combo > 1 && game.combo_t > 0.0 {
    let scale : Float = clampf(game.combo_t / 3.5, 0.0, 1.0)
    let a = (Float::from_int(120) + scale * 120.0).to_int()
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      hud_h + 8,
      30,
      @raylib.Color::new(255, 192, 128, a),
    )
  }

  if game.state == state_play {
    @raylib.draw_text(
      "A/D move  W/SPACE jump  J shoot  K dash  L hook",
      20,
      hud_h + 8,
      20,
      @raylib.Color::new(188, 220, 244, 200),
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
    @raylib.Color::new(88, 196, 255, 190)
  } else if hot {
    @raylib.Color::new(64, 128, 188, 170)
  } else {
    @raylib.Color::new(24, 56, 94, 148)
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
    @raylib.Color::new(168, 224, 255, 210),
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
      "JUMP",
      btn_jump_rect(),
      game.input_jump_press,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "FIRE",
      btn_fire_rect(),
      game.input_fire_hold,
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
    draw_button_visual(
      "HOOK",
      btn_hook_rect(),
      game.input_hook_press,
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
    @raylib.Color::new(8, 14, 24, 130),
  )

  draw_center_text(
    "POLAR TRAIN HEIST 2026",
    124,
    64,
    @raylib.Color::new(230, 246, 255, 252),
  )
  draw_center_text(
    "Dash rooftops, break the convoy, survive the storm",
    202,
    30,
    @raylib.Color::new(180, 218, 242, 232),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 350,
    252,
    700,
    220,
    @raylib.Color::new(10, 22, 38, 180),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 350,
    252,
    700,
    220,
    @raylib.Color::new(142, 202, 248, 210),
  )

  draw_center_text("CONTROLS", 270, 32, @raylib.Color::new(242, 246, 255, 240))
  draw_center_text(
    "A/D or touch arrows: Move lane space",
    314,
    24,
    @raylib.Color::new(194, 222, 244, 232),
  )
  draw_center_text(
    "W / SPACE or JUMP: Leap between threats",
    346,
    24,
    @raylib.Color::new(194, 222, 244, 232),
  )
  draw_center_text(
    "J / Mouse or FIRE: Shoot",
    378,
    24,
    @raylib.Color::new(194, 222, 244, 232),
  )
  draw_center_text(
    "K / DASH: Invulnerable burst, costs heat",
    410,
    24,
    @raylib.Color::new(194, 222, 244, 232),
  )
  draw_center_text(
    "L / HOOK: EMP pulse clears nearby danger",
    442,
    24,
    @raylib.Color::new(194, 222, 244, 232),
  )

  let start_btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start_btn.0,
    start_btn.1,
    start_btn.2,
    start_btn.3,
  )

  let fill = if hover {
    @raylib.Color::new(84, 190, 246, 220)
  } else {
    @raylib.Color::new(40, 120, 190, 180)
  }

  @raylib.draw_rectangle(
    start_btn.0.to_int(),
    start_btn.1.to_int(),
    start_btn.2.to_int(),
    start_btn.3.to_int(),
    fill,
  )
  @raylib.draw_rectangle_lines(
    start_btn.0.to_int(),
    start_btn.1.to_int(),
    start_btn.2.to_int(),
    start_btn.3.to_int(),
    @raylib.Color::new(204, 244, 255, 230),
  )

  draw_center_text(
    "PRESS SPACE / ENTER TO START",
    start_btn.1.to_int() + 28,
    30,
    @raylib.Color::new(240, 250, 255, 244),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = clampf(game.result_t / stage_clear_wait, 0.0, 1.0)
  let y = lerpf(234.0, 170.0, ease_out_cubic(t)).to_int()

  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 20, 26, 120),
  )

  draw_center_text("STAGE CLEAR", y, 68, @raylib.Color::new(164, 255, 226, 246))
  draw_center_text(
    "Score +" + (320 + game.stage * 120).to_string(),
    y + 78,
    30,
    @raylib.Color::new(255, 226, 164, 238),
  )
  draw_center_text(
    "Next stage loading...",
    y + 122,
    26,
    @raylib.Color::new(206, 238, 255, 232),
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
    @raylib.Color::new(12, 8, 18, 170),
  )

  draw_center_text("HEIST FAILED", 154, 66, a_col(pink(), 248))
  draw_center_text(
    "The convoy outran your heat reserves",
    230,
    30,
    @raylib.Color::new(236, 204, 220, 236),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 270,
    278,
    540,
    188,
    @raylib.Color::new(16, 16, 32, 190),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 270,
    278,
    540,
    188,
    @raylib.Color::new(164, 196, 244, 220),
  )

  draw_center_text(
    "STAGE " + game.stage.to_string(),
    300,
    30,
    @raylib.Color::new(214, 232, 255, 244),
  )
  draw_center_text(
    "SCORE " + game.score.to_string(),
    338,
    36,
    @raylib.Color::new(255, 228, 174, 246),
  )
  draw_center_text(
    "KILLS " + game.kills.to_string() + "    LOOT " + game.loot.to_string(),
    384,
    28,
    @raylib.Color::new(188, 214, 236, 236),
  )
  draw_center_text(
    "BEST " + game.best_score.to_string(),
    420,
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
  let fill = if hover {
    @raylib.Color::new(112, 194, 255, 220)
  } else {
    @raylib.Color::new(62, 124, 196, 190)
  }

  @raylib.draw_rectangle(
    retry.0.to_int(),
    retry.1.to_int(),
    retry.2.to_int(),
    retry.3.to_int(),
    fill,
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
    @raylib.Color::new(255, 130, 160, (t * 120.0).to_int()),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_sky(game, cam_x, cam_y)
  draw_mountains(game, cam_x, cam_y)
  draw_speed_lines(game, cam_x, cam_y)
  draw_train_body(game, cam_x, cam_y)

  draw_shadow_blobs(game, cam_x, cam_y)

  for i = 0; i < game.ents.length(); i = i + 1 {
    if game.ents[i].active && is_pickup(game.ents[i].kind) {
      draw_ent(game.ents[i], cam_x, cam_y)
    }
  }

  for i = 0; i < game.ents.length(); i = i + 1 {
    if game.ents[i].active && is_hostile(game.ents[i].kind) {
      draw_ent(game.ents[i], cam_x, cam_y)
    }
  }

  draw_player(game, cam_x, cam_y)
  draw_shots(game, cam_x, cam_y)
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
  @raylib.clear_background(@raylib.Color::new(4, 10, 20, 255))

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
      "Mobile: tap control pads  |  Swipe not required",
      screen_h - 24,
      20,
      @raylib.Color::new(210, 236, 255, 220),
    )
  }
}
