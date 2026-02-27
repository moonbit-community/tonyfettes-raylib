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
fn draw_value_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  col : @raylib.Color,
  label : String,
) -> Unit {
  let clamped = clampf(value, 0.0, 100.0)
  let fill_w = clampi((Float::from_int(w) * clamped / 100.0).to_int(), 0, w)

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(6, 20, 34, 210))
  @raylib.draw_rectangle(x, y, fill_w, h, col)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(176, 234, 255, 180),
  )
  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 8,
    18,
    @raylib.Color::new(228, 246, 255, 220),
  )
}

///|
fn shake_offset(game : Game) -> (Float, Float) {
  if game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let p = game.shake_t * 24.0
    (randf(-p, p), randf(-p, p))
  }
}

///|
fn draw_backdrop(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    bg_top(),
    bg_bottom(),
  )

  let glow_x = Float::from_int(screen_w) * 0.28 +
    sinf(game.time_s * 0.35) * 120.0
  let glow_y = Float::from_int(screen_h) * 0.24 +
    cosf(game.time_s * 0.24) * 60.0

  @raylib.draw_circle(
    (glow_x + cam_x).to_int(),
    (glow_y + cam_y).to_int(),
    190.0,
    @raylib.Color::new(46, 128, 170, 60),
  )
  @raylib.draw_circle(
    (Float::from_int(screen_w) * 0.73 + cam_x).to_int(),
    (Float::from_int(screen_h) * 0.76 + cam_y).to_int(),
    220.0,
    @raylib.Color::new(122, 82, 170, 40),
  )

  for i = 0; i < 120; i = i + 1 {
    let p = Float::from_int(i)
    let x = (p * 73.0 + sinf(game.time_s * 0.14 + p * 0.2) * 90.0) %
      Float::from_int(screen_w)
    let mut y = (p * 41.0 + game.distance * 0.17 + p * 1.1) %
      Float::from_int(screen_h)
    y = Float::from_int(screen_h) - y

    let pulse : Float = 0.5 + 0.5 * sinf(game.time_s * 0.7 + p * 0.31)
    let r : Float = 0.8 + pulse * 1.7

    @raylib.draw_circle(
      (x + cam_x).to_int(),
      (y + cam_y).to_int(),
      r,
      @raylib.Color::new(
        98 + (pulse * 96.0).to_int(),
        132 + (pulse * 88.0).to_int(),
        176 + (pulse * 72.0).to_int(),
        112,
      ),
    )
  }
}

///|
fn draw_cave(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let step = 14

  for yi = 0; yi < screen_h; yi = yi + step {
    let y0f = Float::from_int(yi)
    let y1f = Float::from_int(yi + step)

    let e0 = cave_edges(game, y0f)
    let e1 = cave_edges(game, y1f)

    let left0 = clampi((e0.0 + cam_x).to_int(), -200, screen_w + 200)
    let right0 = clampi((e0.1 + cam_x).to_int(), -200, screen_w + 200)
    let left1 = clampi((e1.0 + cam_x).to_int(), -200, screen_w + 200)
    let right1 = clampi((e1.1 + cam_x).to_int(), -200, screen_w + 200)

    let left = minf(Float::from_int(left0), Float::from_int(left1)).to_int()
    let right = maxf(Float::from_int(right0), Float::from_int(right1)).to_int()

    let row_h = step + 1

    if left > 0 {
      @raylib.draw_rectangle(
        0,
        yi + cam_y.to_int(),
        left,
        row_h,
        @raylib.Color::new(6, 10, 18, 240),
      )
    }

    if right < screen_w {
      @raylib.draw_rectangle(
        right,
        yi + cam_y.to_int(),
        screen_w - right,
        row_h,
        @raylib.Color::new(6, 10, 18, 240),
      )
    }

    let pulse : Float = 0.5 + 0.5 * sinf(game.time_s * 1.5 + y0f * 0.03)
    let edge_col = @raylib.Color::new(
      cave_glow().r.to_int(),
      cave_glow().g.to_int(),
      cave_glow().b.to_int(),
      80 + (pulse * 120.0).to_int(),
    )

    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(left0), y0f + cam_y),
      @raylib.Vector2::new(Float::from_int(left1), y1f + cam_y),
      3.0,
      edge_col,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(right0), y0f + cam_y),
      @raylib.Vector2::new(Float::from_int(right1), y1f + cam_y),
      3.0,
      edge_col,
    )
  }
}

///|
fn obj_color(kind : Int) -> @raylib.Color {
  if kind == obj_rock {
    @raylib.Color::new(178, 198, 214, 255)
  } else if kind == obj_mine {
    hazard_col()
  } else if kind == obj_data {
    data_col()
  } else if kind == obj_oxygen {
    oxygen_col()
  } else if kind == obj_current {
    phase_col()
  } else {
    @raylib.Color::new(246, 200, 138, 255)
  }
}

///|
fn draw_obj_current(
  o : Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 2.2)
  let ring_r : Float = o.r + pulse * 8.0

  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    ring_r,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 220),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    ring_r * 0.66,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 140),
  )

  let mut px = o.vx
  let mut py = o.vy
  let p2 = px * px + py * py
  if p2 > 0.001 {
    let inv : Float = Float::from_int(1) / sqrtf(p2)
    px = px * inv
    py = py * inv

    let p0 = @raylib.Vector2::new(
      x - px * ring_r * 0.45,
      y - py * ring_r * 0.45,
    )
    let p1 = @raylib.Vector2::new(
      x + px * ring_r * 0.55,
      y + py * ring_r * 0.55,
    )
    @raylib.draw_line_ex(
      p0,
      p1,
      4.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 210),
    )
  }
}

///|
fn draw_obj_mine(
  o : Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 3.4)
  let rr : Float = o.r + pulse * 3.0

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    rr,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 210),
  )

  for k = 0; k < 8; k = k + 1 {
    let a = Float::from_int(k) * 0.785 + o.spin
    let nx = cosf(a)
    let ny = sinf(a)
    let p0 = @raylib.Vector2::new(x + nx * rr * 0.6, y + ny * rr * 0.6)
    let p1 = @raylib.Vector2::new(x + nx * rr * 1.45, y + ny * rr * 1.45)
    @raylib.draw_line_ex(p0, p1, 2.6, @raylib.Color::new(255, 214, 224, 230))
  }
}

///|
fn draw_obj_data(
  o : Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 4.3)
  let r : Float = o.r + pulse * 2.6

  let top = @raylib.Vector2::new(x, y - r)
  let right = @raylib.Vector2::new(x + r, y)
  let bot = @raylib.Vector2::new(x, y + r)
  let left = @raylib.Vector2::new(x - r, y)

  @raylib.draw_line_ex(top, right, 3.0, col)
  @raylib.draw_line_ex(right, bot, 3.0, col)
  @raylib.draw_line_ex(bot, left, 3.0, col)
  @raylib.draw_line_ex(left, top, 3.0, col)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    r * 0.32,
    @raylib.Color::new(236, 255, 248, 210),
  )
}

///|
fn draw_obj_oxygen(
  o : Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 3.0)
  let r : Float = o.r + pulse * 2.1

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    r,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 120),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    r,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 235),
  )
  @raylib.draw_text(
    "O2",
    (x - 12.0).to_int(),
    (y - 8.0).to_int(),
    16,
    @raylib.Color::new(232, 248, 255, 220),
  )
}

///|
fn draw_obj_scrap(
  o : Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let w = o.r * 1.6
  let h = o.r * 1.1

  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    o.spin * 57.3,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 200),
  )
  @raylib.draw_rectangle_lines(
    (x - w * 0.5).to_int(),
    (y - h * 0.5).to_int(),
    w.to_int(),
    h.to_int(),
    @raylib.Color::new(252, 236, 212, 180),
  )
}

///|
fn draw_objects(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.objs.length(); i = i + 1 {
    let o = game.objs[i]
    if not(o.active) {
      continue
    }

    if o.cloak && game.sonar_t <= 0.0 {
      continue
    }

    let base = obj_color(o.kind)
    let alpha = if o.cloak { 130 } else { 255 }
    let col = @raylib.Color::new(
      base.r.to_int(),
      base.g.to_int(),
      base.b.to_int(),
      alpha,
    )

    if o.kind == obj_rock {
      @raylib.draw_circle(
        (o.x + cam_x).to_int(),
        (o.y + cam_y).to_int(),
        o.r,
        @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 220),
      )
      @raylib.draw_circle_lines(
        (o.x + cam_x).to_int(),
        (o.y + cam_y).to_int(),
        o.r,
        @raylib.Color::new(86, 102, 122, 210),
      )
    } else if o.kind == obj_mine {
      draw_obj_mine(o, col, cam_x, cam_y)
    } else if o.kind == obj_data {
      draw_obj_data(o, col, cam_x, cam_y)
    } else if o.kind == obj_oxygen {
      draw_obj_oxygen(o, col, cam_x, cam_y)
    } else if o.kind == obj_current {
      draw_obj_current(o, col, cam_x, cam_y)
    } else {
      draw_obj_scrap(o, col, cam_x, cam_y)
    }
  }
}

///|
fn draw_trails(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.trails.length(); i = i + 1 {
    let t = game.trails[i]
    if not(t.active) {
      continue
    }

    let a = clampi((t.life * 255.0).to_int(), 0, 255)
    let col = if t.kind == 1 {
      @raylib.Color::new(120, 240, 255, a)
    } else {
      @raylib.Color::new(214, 242, 255, a)
    }

    @raylib.draw_rectangle(
      (t.x - t.w * 0.5 + cam_x).to_int(),
      (t.y - t.h * 0.5 + cam_y).to_int(),
      t.w.to_int(),
      t.h.to_int(),
      col,
    )
  }
}

///|
fn draw_particles(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue
    }

    let a = clampi((p.life * 255.0).to_int(), 0, 255)
    let c = if p.kind == 1 {
      @raylib.Color::new(255, 124, 168, a)
    } else if p.kind == 2 {
      @raylib.Color::new(146, 214, 255, a)
    } else {
      @raylib.Color::new(164, 248, 196, a)
    }

    @raylib.draw_circle(
      (p.x + cam_x).to_int(),
      (p.y + cam_y).to_int(),
      p.size,
      c,
    )
  }
}

///|
fn draw_ripples(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.ripples.length(); i = i + 1 {
    let r = game.ripples[i]
    if not(r.active) {
      continue
    }

    let a = clampi((r.life * 255.0).to_int(), 0, 255)
    let c = if r.kind == 1 {
      @raylib.Color::new(184, 146, 255, a)
    } else {
      @raylib.Color::new(126, 228, 255, a)
    }

    @raylib.draw_circle_lines(
      (r.x + cam_x).to_int(),
      (r.y + cam_y).to_int(),
      r.r,
      c,
    )
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let px = game.hero.x + cam_x
  let py = game.hero.y + cam_y

  let pulse : Float = 0.5 + 0.5 * sinf(game.hero.anim_t * 7.2)
  let body_r : Float = game.hero.r + pulse * 1.6

  let body_col = if game.hero.hurt_t > 0.0 {
    @raylib.Color::new(255, 186, 204, 255)
  } else {
    @raylib.Color::new(140, 234, 255, 255)
  }

  @raylib.draw_circle(px.to_int(), py.to_int(), body_r, body_col)
  @raylib.draw_circle_lines(
    px.to_int(),
    py.to_int(),
    body_r,
    @raylib.Color::new(32, 48, 62, 220),
  )

  @raylib.draw_circle(
    (px + body_r * 0.34).to_int(),
    (py - body_r * 0.26).to_int(),
    body_r * 0.34,
    @raylib.Color::new(218, 248, 255, 240),
  )

  let fin : Float = Float::from_int(1) + absf(game.hero.vx) / player_max_speed
  @raylib.draw_triangle(
    @raylib.Vector2::new(px - body_r * 1.1, py),
    @raylib.Vector2::new(px - body_r * 1.9 * fin, py - body_r * 0.6),
    @raylib.Vector2::new(px - body_r * 1.9 * fin, py + body_r * 0.6),
    @raylib.Color::new(86, 194, 232, 230),
  )

  if game.dash_t > 0.0 {
    @raylib.draw_circle_lines(
      px.to_int(),
      py.to_int(),
      body_r + 8.0 + game.dash_t * 34.0,
      @raylib.Color::new(120, 236, 255, 200),
    )
  }

  if game.hero.invuln > 0.0 {
    let alpha = 80 + (sinf(game.time_s * 14.0) * 80.0 + 80.0).to_int()
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      body_r + 5.0,
      @raylib.Color::new(250, 254, 255, clampi(alpha, 30, 220)),
    )
  }

  emit_trail(
    game,
    game.hero.x - game.hero.r * 1.12,
    game.hero.y,
    randf(9.0, 14.0),
    randf(4.0, 8.0),
    randf(0.14, 0.28),
    0,
  )
}

///|
fn cooldown_text(cd : Float, total : Float) -> String {
  if cd <= 0.0 {
    "READY"
  } else {
    (cd / total * 100.0).to_int().to_string() + "%"
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  draw_value_bar(24, 20, 280, 26, game.hull, hp_col(), "HULL")
  draw_value_bar(24, 54, 280, 26, game.oxygen, oxygen_col(), "OXY")

  @raylib.draw_rectangle(326, 20, 150, 60, @raylib.Color::new(6, 18, 30, 220))
  @raylib.draw_rectangle_lines(
    326,
    20,
    150,
    60,
    @raylib.Color::new(128, 206, 234, 170),
  )
  @raylib.draw_text("DASH", 338, 26, 18, @raylib.Color::new(208, 234, 248, 230))
  @raylib.draw_text(
    cooldown_text(game.dash_cd, dash_cd_time),
    338,
    47,
    17,
    if game.dash_cd <= 0.0 {
      @raylib.Color::new(126, 248, 172, 240)
    } else {
      @raylib.Color::new(238, 198, 132, 220)
    },
  )

  @raylib.draw_rectangle(486, 20, 150, 60, @raylib.Color::new(6, 18, 30, 220))
  @raylib.draw_rectangle_lines(
    486,
    20,
    150,
    60,
    @raylib.Color::new(146, 186, 242, 170),
  )
  @raylib.draw_text(
    "SONAR",
    500,
    26,
    18,
    @raylib.Color::new(220, 230, 255, 230),
  )
  @raylib.draw_text(
    cooldown_text(game.sonar_cd, sonar_cd_time),
    500,
    47,
    17,
    if game.sonar_cd <= 0.0 {
      @raylib.Color::new(126, 248, 172, 240)
    } else {
      @raylib.Color::new(238, 198, 132, 220)
    },
  )

  @raylib.draw_rectangle(
    screen_w - 300,
    20,
    276,
    92,
    @raylib.Color::new(6, 18, 30, 220),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 300,
    20,
    276,
    92,
    @raylib.Color::new(134, 202, 234, 170),
  )

  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    screen_w - 284,
    30,
    22,
    @raylib.Color::new(232, 248, 255, 240),
  )
  @raylib.draw_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 284,
    56,
    18,
    @raylib.Color::new(172, 224, 245, 220),
  )
  @raylib.draw_text(
    "STAGE " + game.stage.to_string(),
    screen_w - 284,
    76,
    18,
    @raylib.Color::new(168, 242, 214, 230),
  )

  let dist_text = "DEPTH " +
    game.distance.to_int().to_string() +
    " / " +
    game.stage_goal.to_int().to_string()
  draw_right_text(
    dist_text,
    screen_w - 28,
    122,
    20,
    @raylib.Color::new(198, 236, 255, 236),
  )

  @raylib.draw_rectangle(
    screen_w - 332,
    122,
    304,
    14,
    @raylib.Color::new(6, 18, 30, 220),
  )
  let ratio = clampf(game.distance / maxf(game.stage_goal, 1.0), 0.0, 1.0)
  @raylib.draw_rectangle(
    screen_w - 332,
    122,
    (Float::from_int(304) * ratio).to_int(),
    14,
    @raylib.Color::new(136, 250, 206, 225),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 332,
    122,
    304,
    14,
    @raylib.Color::new(130, 210, 236, 170),
  )

  if game.combo >= 2 && game.combo_t > 0.0 {
    let alpha = clampi((game.combo_t * 130.0 + 60.0).to_int(), 0, 255)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      22,
      28,
      @raylib.Color::new(255, 224, 142, alpha),
    )
  }
}

///|
fn draw_button_hint(
  rect : (Float, Float, Float, Float),
  text : String,
  active : Bool,
  primary : Bool,
) -> Unit {
  let alpha = if active { 170 } else { 86 }
  let base = if primary {
    @raylib.Color::new(94, 204, 255, alpha)
  } else {
    @raylib.Color::new(168, 156, 255, alpha)
  }

  @raylib.draw_rectangle(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    @raylib.Color::new(10, 24, 40, alpha),
  )
  @raylib.draw_rectangle_lines(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    base,
  )

  let tw = @raylib.measure_text(text, 24)
  @raylib.draw_text(
    text,
    (rect.0 + rect.2 * 0.5 - Float::from_int(tw) * 0.5).to_int(),
    (rect.1 + rect.3 * 0.5 - 12.0).to_int(),
    24,
    @raylib.Color::new(226, 244, 255, clampi(alpha + 40, 0, 255)),
  )
}

///|
fn draw_touch_controls(game : Game) -> Unit {
  let left = btn_left_rect()
  let right = btn_right_rect()
  let up = btn_up_rect()
  let down = btn_down_rect()
  let dash = btn_dash_rect()
  let sonar = btn_sonar_rect()

  draw_button_hint(left, "<", game.input_x < -0.1, true)
  draw_button_hint(right, ">", game.input_x > 0.1, true)
  draw_button_hint(up, "^", game.input_y < -0.1, true)
  draw_button_hint(down, "v", game.input_y > 0.1, true)
  draw_button_hint(dash, "DASH", game.dash_t > 0.0, false)
  draw_button_hint(sonar, "SONAR", game.sonar_t > 0.0, false)
}

///|
fn draw_title_overlay(
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
    @raylib.Color::new(4, 8, 18, 120),
  )

  draw_center_text(
    "ABYSS SIGNAL RUNNER 2026",
    110,
    58,
    @raylib.Color::new(186, 244, 255, 245),
  )
  draw_center_text(
    "Pilot a deep-sea scout through living caves.",
    192,
    28,
    @raylib.Color::new(190, 224, 244, 220),
  )
  draw_center_text(
    "Scan hidden threats, chain combos, survive pressure.",
    226,
    24,
    @raylib.Color::new(176, 214, 238, 220),
  )

  let b = title_start_rect()
  let hover = pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
  @raylib.draw_rectangle(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    if hover {
      @raylib.Color::new(46, 116, 150, 220)
    } else {
      @raylib.Color::new(22, 66, 94, 210)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    @raylib.Color::new(170, 236, 255, 210),
  )

  draw_center_text(
    "START DIVE",
    (b.1 + 24.0).to_int(),
    36,
    @raylib.Color::new(228, 247, 255, 255),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 440,
    370,
    880,
    220,
    @raylib.Color::new(8, 18, 30, 176),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 440,
    370,
    880,
    220,
    @raylib.Color::new(124, 202, 236, 170),
  )

  draw_center_text(
    "Keyboard: WASD/Arrows move | Shift/K dash | Space/J/L sonar | R restart",
    400,
    22,
    @raylib.Color::new(204, 228, 244, 220),
  )
  draw_center_text(
    "Mobile: Left cluster = move | Right buttons = Dash + Sonar",
    435,
    22,
    @raylib.Color::new(198, 226, 244, 220),
  )
  draw_center_text(
    "Mine + rock are lethal without timing. Sonar reveals cloaked targets.",
    470,
    22,
    @raylib.Color::new(220, 232, 248, 220),
  )
  draw_center_text(
    "Collect data for combo scoring and oxygen efficiency.",
    505,
    22,
    @raylib.Color::new(220, 232, 248, 220),
  )

  if game.best_score > 0 {
    draw_center_text(
      "Best Score: " + game.best_score.to_string(),
      550,
      26,
      @raylib.Color::new(255, 220, 136, 240),
    )
  }
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = ease_out_quad(clampf(game.result_t / stage_clear_delay, 0.0, 1.0))
  let panel_w = (Float::from_int(420) + t * Float::from_int(120)).to_int()
  let panel_h = (Float::from_int(170) + t * Float::from_int(40)).to_int()

  @raylib.draw_rectangle(
    screen_w / 2 - panel_w / 2,
    screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 30, 44, 210),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - panel_w / 2,
    screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(146, 238, 212, 220),
  )

  draw_center_text(
    "STAGE " + game.stage.to_string() + " CLEAR",
    screen_h / 2 - 46,
    44,
    @raylib.Color::new(180, 255, 208, 255),
  )
  draw_center_text(
    "Next stage loading...",
    screen_h / 2 + 8,
    26,
    @raylib.Color::new(208, 238, 240, 230),
  )
  draw_center_text(
    "Tap or press ENTER to continue now",
    screen_h / 2 + 44,
    20,
    @raylib.Color::new(196, 222, 238, 220),
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
    @raylib.Color::new(10, 8, 14, 190),
  )

  draw_center_text(
    "SIGNAL LOST",
    176,
    64,
    @raylib.Color::new(255, 178, 194, 250),
  )
  draw_center_text(
    "Final Score: " + game.score.to_string(),
    262,
    34,
    @raylib.Color::new(236, 236, 246, 240),
  )
  draw_center_text(
    "Data Collected: " + game.data_collected.to_string(),
    302,
    28,
    @raylib.Color::new(194, 244, 214, 230),
  )
  draw_center_text(
    "Stage Reached: " + game.stage.to_string(),
    336,
    28,
    @raylib.Color::new(186, 224, 244, 230),
  )

  let b = restart_rect()
  let hover = pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)

  @raylib.draw_rectangle(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    if hover {
      @raylib.Color::new(124, 72, 96, 220)
    } else {
      @raylib.Color::new(84, 44, 66, 210)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    @raylib.Color::new(255, 174, 206, 220),
  )

  draw_center_text(
    "RETRY",
    (b.1 + 16.0).to_int(),
    34,
    @raylib.Color::new(255, 236, 244, 255),
  )

  draw_center_text(
    "Press R / ENTER or tap RETRY",
    560,
    24,
    @raylib.Color::new(222, 226, 236, 220),
  )
}

///|
fn draw_signal_pulse(game : Game) -> Unit {
  if game.sonar_t <= 0.0 {
    return
  }

  let t : Float = Float::from_int(1) - game.sonar_t / sonar_time
  let rr = sonar_reveal_r * t
  let a = clampi(((Float::from_int(1) - t) * 190.0).to_int(), 0, 190)

  @raylib.draw_circle_lines(
    game.hero.x.to_int(),
    game.hero.y.to_int(),
    rr,
    @raylib.Color::new(180, 156, 255, a),
  )
}

///|
fn draw_play_hint(game : Game) -> Unit {
  if game.hint_t > 15.0 {
    return
  }

  let fade : Float = Float::from_int(1) -
    clampf((game.hint_t - 7.0) / 8.0, 0.0, 1.0)
  let alpha = clampi((fade * 180.0).to_int(), 0, 180)

  @raylib.draw_rectangle(
    screen_w / 2 - 310,
    screen_h - 58,
    620,
    34,
    @raylib.Color::new(8, 18, 28, alpha),
  )
  draw_center_text(
    "Dash breaks rocks/mines. Sonar reveals cloaked objects.",
    screen_h - 52,
    22,
    @raylib.Color::new(206, 230, 246, alpha + 40),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_trails(game, cam_x, cam_y)
  draw_ripples(game, cam_x, cam_y)
  draw_objects(game, cam_x, cam_y)
  draw_particles(game, cam_x, cam_y)
  draw_player(game, cam_x, cam_y)
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.clear_background(bg_top())

  let cam = shake_offset(game)
  let cam_x = cam.0
  let cam_y = cam.1

  draw_backdrop(game, cam_x, cam_y)
  draw_cave(game, cam_x, cam_y)
  draw_world(game, cam_x, cam_y)
  draw_signal_pulse(game)

  if game.flash_t > 0.0 {
    let a = clampi((game.flash_t * 220.0).to_int(), 0, 220)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(255, 146, 190, a),
    )
  }

  if game.state != state_title {
    draw_hud(game)
  }

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_play {
    draw_play_hint(game)
    if game.touch_mode {
      draw_touch_controls(game)
    }
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game)
  } else {
    draw_game_over_overlay(game, mx, my, hold, touch_count)
  }
}
