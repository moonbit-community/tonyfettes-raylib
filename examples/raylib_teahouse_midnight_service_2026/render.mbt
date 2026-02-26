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
    let amp : Float = minf(22.0, game.shake_t * 36.0)
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

  let moon_x : Float = Float::from_int(screen_w) * 0.82 +
    sinf(game.time_s * 0.18) * 36.0
  let moon_y : Float = Float::from_int(hud_h) +
    74.0 +
    cosf(game.time_s * 0.22) * 12.0

  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    84.0,
    @raylib.Color::new(210, 234, 255, 56),
  )
  @raylib.draw_circle(
    (moon_x + cam_x * 0.2).to_int(),
    (moon_y + cam_y * 0.2).to_int(),
    46.0,
    @raylib.Color::new(232, 246, 255, 130),
  )

  for i = 0; i < 140; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 90.0 + fi * fi * 0.15 + game.time_s * 6.0) %
      Float::from_int(screen_w)
    let y = Float::from_int(hud_h) +
      (fi * 41.0 + fi * 18.0) % Float::from_int(screen_h - hud_h)

    let tw : Float = 0.5 + 0.5 * sinf(fi * 0.72 + game.time_s * 1.34)
    @raylib.draw_circle(
      (x + cam_x * 0.12).to_int(),
      (y + cam_y * 0.12).to_int(),
      0.8 + tw * 1.4,
      @raylib.Color::new(
        170 + (tw * 70.0).to_int(),
        212,
        255,
        62 + (tw * 130.0).to_int(),
      ),
    )
  }
}

///|
fn draw_room_base(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle(
    play_left.to_int(),
    play_top.to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(58, 42, 34, 220),
  )

  @raylib.draw_rectangle_lines(
    (play_left + cam_x * 0.08).to_int(),
    (play_top + cam_y * 0.08).to_int(),
    (play_right - play_left).to_int(),
    (play_bottom - play_top).to_int(),
    @raylib.Color::new(190, 164, 132, 118),
  )

  let plank_h = 30
  let shift = (game.time_s * 16.0).to_int() % plank_h
  for y = play_top.to_int() - plank_h
      y < play_bottom.to_int() + plank_h
      y = y + plank_h {
    let tone = 84 + (y + shift) / plank_h % 2 * 14
    @raylib.draw_rectangle(
      play_left.to_int(),
      y + shift,
      (play_right - play_left).to_int(),
      plank_h - 2,
      @raylib.Color::new(tone, 62, 46, 90),
    )
  }

  @raylib.draw_rectangle(72, 148, 640, 266, @raylib.Color::new(88, 62, 46, 120))
  @raylib.draw_rectangle_lines(
    72,
    148,
    640,
    266,
    @raylib.Color::new(204, 174, 138, 120),
  )

  @raylib.draw_rectangle(
    768,
    358,
    450,
    310,
    @raylib.Color::new(92, 64, 50, 128),
  )
  @raylib.draw_rectangle_lines(
    768,
    358,
    450,
    310,
    @raylib.Color::new(206, 176, 142, 120),
  )
}

///|
fn draw_station_tag(label : String, x : Float, y : Float, hot : Bool) -> Unit {
  let w = @raylib.measure_text(label, 18) + 20
  @raylib.draw_rectangle(
    (x - Float::from_int(w) * 0.5).to_int(),
    (y - 36.0).to_int(),
    w,
    24,
    if hot {
      @raylib.Color::new(110, 180, 236, 190)
    } else {
      @raylib.Color::new(30, 44, 66, 170)
    },
  )
  @raylib.draw_text(
    label,
    (x - Float::from_int(w) * 0.5 + 10.0).to_int(),
    (y - 34.0).to_int(),
    18,
    @raylib.Color::new(236, 246, 255, 236),
  )
}

///|
fn draw_kettle(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = kettle_x + cam_x
  let y = kettle_y + cam_y
  let hot = near_station(
    game.player.x,
    game.player.y,
    kettle_x,
    kettle_y,
    interact_reach,
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    46.0,
    @raylib.Color::new(84, 130, 186, 220),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    30.0,
    @raylib.Color::new(32, 62, 104, 220),
  )
  @raylib.draw_rectangle(
    (x - 12.0).to_int(),
    (y - 54.0).to_int(),
    24,
    12,
    @raylib.Color::new(188, 206, 234, 220),
  )

  if game.player.carry_water {
    @raylib.draw_circle(
      (x + 38.0).to_int(),
      (y - 32.0).to_int(),
      10.0,
      @raylib.Color::new(124, 234, 255, 190),
    )
  }

  draw_station_tag("KETTLE", x, y, hot)
}

///|
fn draw_leaf_racks(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for tea = 0; tea < tea_count; tea = tea + 1 {
    let x = leaf_x() + cam_x
    let y = leaf_y(tea) + cam_y
    let hot = near_station(
      game.player.x,
      game.player.y,
      leaf_x(),
      leaf_y(tea),
      interact_reach,
    )

    @raylib.draw_rectangle(
      (x - 42.0).to_int(),
      (y - 30.0).to_int(),
      84,
      60,
      @raylib.Color::new(84, 60, 46, 220),
    )
    @raylib.draw_rectangle_lines(
      (x - 42.0).to_int(),
      (y - 30.0).to_int(),
      84,
      60,
      @raylib.Color::new(196, 164, 128, 168),
    )

    @raylib.draw_circle(x.to_int(), y.to_int(), 18.0, tea_color(tea))
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      8.0,
      @raylib.Color::new(26, 30, 34, 200),
    )

    if game.player.carry_leaf == tea {
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        24.0,
        @raylib.Color::new(116, 244, 220, 220),
      )
    }

    if hot {
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        28.0,
        @raylib.Color::new(124, 210, 255, 180),
      )
    }

    @raylib.draw_text(
      tea_name(tea),
      (x + 54.0).to_int(),
      (y - 10.0).to_int(),
      16,
      @raylib.Color::new(236, 228, 208, 230),
    )
  }

  draw_station_tag("LEAVES", leaf_x() + cam_x, leaf_y(2) + cam_y, false)
}

///|
fn draw_brewer(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = brew_x + cam_x
  let y = brew_y + cam_y
  let hot = near_station(
    game.player.x,
    game.player.y,
    brew_x,
    brew_y,
    interact_reach,
  )

  @raylib.draw_rectangle(
    (x - 64.0).to_int(),
    (y - 48.0).to_int(),
    128,
    96,
    @raylib.Color::new(68, 54, 52, 226),
  )
  @raylib.draw_rectangle_lines(
    (x - 64.0).to_int(),
    (y - 48.0).to_int(),
    128,
    96,
    @raylib.Color::new(196, 172, 152, 170),
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    30.0,
    @raylib.Color::new(46, 84, 104, 220),
  )

  if game.brew_active {
    let t = clampf(
      1.0 -
      game.brew_t /
      maxf(0.1, brew_time_base - Float::from_int(game.stage - 1) * 0.12),
      0.0,
      1.0,
    )
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      22.0 + t * 6.0,
      a_col(tea_color(game.brew_type), 160),
    )
    @raylib.draw_rectangle(
      (x - 44.0).to_int(),
      (y + 36.0).to_int(),
      88,
      8,
      @raylib.Color::new(16, 24, 34, 220),
    )
    @raylib.draw_rectangle(
      (x - 44.0).to_int(),
      (y + 36.0).to_int(),
      (Float::from_int(88) * t).to_int(),
      8,
      @raylib.Color::new(118, 244, 214, 220),
    )
  }

  if game.ready_cup >= 0 {
    @raylib.draw_circle(
      (x + 52.0).to_int(),
      (y - 22.0).to_int(),
      16.0,
      tea_color(game.ready_cup),
    )
    @raylib.draw_circle(
      (x + 52.0).to_int(),
      (y - 22.0).to_int(),
      6.0,
      @raylib.Color::new(24, 28, 34, 210),
    )
  }

  draw_station_tag("BREWER", x, y, hot)
}

///|
fn draw_counter(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = counter_x + cam_x
  let y = counter_y + cam_y
  let hot = near_station(
    game.player.x,
    game.player.y,
    counter_x,
    counter_y,
    interact_reach + 10.0,
  )

  @raylib.draw_rectangle(
    (x - 86.0).to_int(),
    (y - 44.0).to_int(),
    172,
    88,
    @raylib.Color::new(86, 60, 44, 226),
  )
  @raylib.draw_rectangle_lines(
    (x - 86.0).to_int(),
    (y - 44.0).to_int(),
    172,
    88,
    @raylib.Color::new(196, 164, 130, 176),
  )

  @raylib.draw_rectangle(
    (x - 76.0).to_int(),
    (y - 34.0).to_int(),
    152,
    18,
    @raylib.Color::new(122, 84, 60, 210),
  )

  if game.ready_cup >= 0 {
    @raylib.draw_circle(
      (x - 44.0).to_int(),
      (y + 12.0).to_int(),
      14.0,
      tea_color(game.ready_cup),
    )
  }

  draw_station_tag("SERVE", x, y, hot)
}

///|
fn draw_customer_chair(x : Float, y : Float) -> Unit {
  @raylib.draw_rectangle(
    (x - 42.0).to_int(),
    (y + 30.0).to_int(),
    84,
    18,
    @raylib.Color::new(90, 64, 48, 230),
  )
  @raylib.draw_rectangle(
    (x - 36.0).to_int(),
    (y - 36.0).to_int(),
    72,
    68,
    @raylib.Color::new(66, 48, 38, 220),
  )
}

///|
fn draw_customer(c : Customer, cam_x : Float, cam_y : Float) -> Unit {
  if not(c.active) {
    return
  }

  let x = c.x + cam_x
  let y = c.y + cam_y

  draw_customer_chair(x, y)

  let mood = clampf(c.mood, 0.0, 1.0)
  let body = @raylib.Color::new(
    150 + (mood * 70.0).to_int(),
    122 + (mood * 60.0).to_int(),
    100 + (mood * 40.0).to_int(),
    240,
  )

  @raylib.draw_circle(x.to_int(), (y - 4.0).to_int(), 20.0, body)
  @raylib.draw_circle(
    (x - 7.0).to_int(),
    (y - 8.0).to_int(),
    3.0,
    @raylib.Color::new(28, 24, 22, 220),
  )
  @raylib.draw_circle(
    (x + 7.0).to_int(),
    (y - 8.0).to_int(),
    3.0,
    @raylib.Color::new(28, 24, 22, 220),
  )

  if c.angry {
    @raylib.draw_line(
      (x - 10.0).to_int(),
      (y + 5.0).to_int(),
      (x + 10.0).to_int(),
      (y + 5.0).to_int(),
      @raylib.Color::new(64, 22, 24, 220),
    )
  } else {
    @raylib.draw_line(
      (x - 8.0).to_int(),
      (y + 5.0).to_int(),
      (x + 8.0).to_int(),
      (y + 8.0).to_int(),
      @raylib.Color::new(60, 32, 22, 220),
    )
  }

  @raylib.draw_circle(
    (x + 36.0).to_int(),
    (y - 30.0).to_int(),
    18.0,
    @raylib.Color::new(240, 248, 255, 232),
  )
  @raylib.draw_circle(
    (x + 36.0).to_int(),
    (y - 30.0).to_int(),
    11.0,
    tea_color(c.tea_type),
  )

  let p = clampf(c.patience / maxf(1.0, c.patience_max), 0.0, 1.0)
  @raylib.draw_rectangle(
    (x - 36.0).to_int(),
    (y - 48.0).to_int(),
    72,
    6,
    @raylib.Color::new(20, 26, 32, 210),
  )
  @raylib.draw_rectangle(
    (x - 36.0).to_int(),
    (y - 48.0).to_int(),
    (Float::from_int(72) * p).to_int(),
    6,
    @raylib.Color::new(255, 122, 160, 220),
  )
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let p = game.player
  let x = p.x + cam_x
  let y = p.y + cam_y

  let dash_ratio = clampf(p.dash_t / maxf(dash_time, 0.001), 0.0, 1.0)
  let focus_ratio = clampf(game.focus / focus_max, 0.0, 1.0)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    24.0 + dash_ratio * 12.0,
    @raylib.Color::new(118, 234, 214, (focus_ratio * 84.0).to_int()),
  )

  @raylib.draw_rectangle(
    (x - p.w * 0.28).to_int(),
    (y - p.h * 0.52).to_int(),
    (p.w * 0.56).to_int(),
    (p.h * 0.66).to_int(),
    @raylib.Color::new(232, 236, 248, 236),
  )
  @raylib.draw_circle(
    x.to_int(),
    (y - p.h * 0.66).to_int(),
    12.0,
    @raylib.Color::new(246, 232, 220, 236),
  )

  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - 8.0, y + 2.0),
    @raylib.Vector2::new(x - 10.0 - sinf(p.anim_t * 8.0) * 5.0, y + 24.0),
    5.0,
    @raylib.Color::new(176, 206, 236, 232),
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x + 8.0, y + 2.0),
    @raylib.Vector2::new(x + 10.0 + sinf(p.anim_t * 8.0) * 5.0, y + 24.0),
    5.0,
    @raylib.Color::new(176, 206, 236, 232),
  )

  if p.carry_water {
    @raylib.draw_circle(
      (x + 22.0).to_int(),
      (y - 14.0).to_int(),
      8.0,
      @raylib.Color::new(126, 236, 255, 220),
    )
  }

  if p.carry_leaf >= 0 {
    @raylib.draw_circle(
      (x - 22.0).to_int(),
      (y - 14.0).to_int(),
      8.0,
      tea_color(p.carry_leaf),
    )
  }

  if p.interact_t > 0.0 {
    let t = clampf(p.interact_t / 0.22, 0.0, 1.0)
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      24.0 + t * 18.0,
      @raylib.Color::new(124, 244, 214, (t * 200.0).to_int()),
    )
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

    let base = if game.sparks[i].kind == 0 {
      amber()
    } else if game.sparks[i].kind == 1 {
      pink()
    } else if game.sparks[i].kind == 2 {
      jade()
    } else {
      @raylib.Color::new(232, 244, 255, 255)
    }

    let col = a_col(base, (life * 220.0).to_int())

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

  for i = 0; i < game.shadows.length(); i = i + 1 {
    if not(game.shadows[i].active) {
      continue
    }

    let life = clampf(game.shadows[i].life / 0.24, 0.0, 1.0)
    let stretch : Float = Float::from_int(1) +
      absf(sinf(game.shadows[i].rot * 0.06)) * 0.24

    @raylib.draw_rectangle(
      (game.shadows[i].x - game.shadows[i].w * 0.5 * stretch + cam_x * 0.2).to_int(),
      (game.shadows[i].y - game.shadows[i].h * 0.5 + cam_y * 0.2).to_int(),
      maxf(2.0, game.shadows[i].w * stretch).to_int(),
      maxf(2.0, game.shadows[i].h).to_int(),
      @raylib.Color::new(116, 218, 255, (life * 118.0).to_int()),
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

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(8, 18, 32, 212))
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
    @raylib.Color::new(148, 208, 246, 172),
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
    @raylib.Color::new(6, 14, 30, 236),
  )
  @raylib.draw_line(
    0,
    hud_h,
    screen_w,
    hud_h,
    @raylib.Color::new(92, 170, 232, 162),
  )

  draw_bar(
    20,
    18,
    300,
    24,
    game.reputation,
    reputation_max,
    "REPUTATION",
    reputation_col(),
  )
  draw_bar(20, 52, 300, 24, game.focus, focus_max, "FOCUS", focus_col())

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
    @raylib.Color::new(214, 240, 255, 242),
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
    @raylib.Color::new(186, 222, 246, 236),
  )

  draw_right_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 20,
    14,
    22,
    @raylib.Color::new(186, 224, 248, 236),
  )
  draw_right_text(
    "SERVED " + game.served.to_string() + "  MISSED " + game.missed.to_string(),
    screen_w - 20,
    44,
    20,
    @raylib.Color::new(170, 214, 236, 228),
  )

  @raylib.draw_text(
    if game.focus_mode {
      "FOCUS MODE"
    } else {
      "NORMAL"
    },
    screen_w - 180,
    72,
    18,
    if game.focus_mode {
      @raylib.Color::new(124, 244, 210, 236)
    } else {
      @raylib.Color::new(188, 206, 226, 214)
    },
  )

  if game.combo > 1 && game.combo_t > 0.0 {
    let t = clampf(game.combo_t / 3.8, 0.0, 1.0)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      hud_h + 8,
      30,
      @raylib.Color::new(
        255,
        198,
        134,
        (Float::from_int(120) + t * 120.0).to_int(),
      ),
    )
  }

  if game.state == state_play {
    @raylib.draw_text(
      "WASD move  J/E/SPACE interact  K hold focus  L dash",
      20,
      hud_h + 8,
      20,
      @raylib.Color::new(188, 220, 242, 204),
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
    @raylib.Color::new(86, 198, 255, 194)
  } else if hot {
    @raylib.Color::new(64, 128, 188, 176)
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
    @raylib.Color::new(170, 224, 255, 214),
  )

  let ts = 24
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
      "ACT",
      btn_interact_rect(),
      game.input_interact_press,
      mx,
      my,
      hold,
      touch_count,
    )
    draw_button_visual(
      "FOCUS",
      btn_focus_rect(),
      game.input_focus_hold,
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
    @raylib.Color::new(8, 14, 24, 138),
  )

  draw_center_text(
    "TEAHOUSE MIDNIGHT SERVICE 2026",
    120,
    58,
    @raylib.Color::new(230, 246, 255, 250),
  )
  draw_center_text(
    "Brew fast, serve right, keep the late-night crowd calm",
    194,
    30,
    @raylib.Color::new(186, 220, 244, 236),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    246,
    720,
    236,
    @raylib.Color::new(10, 20, 38, 186),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 360,
    246,
    720,
    236,
    @raylib.Color::new(148, 206, 246, 214),
  )

  draw_center_text("FLOW", 268, 32, @raylib.Color::new(242, 248, 255, 240))
  draw_center_text(
    "1) Kettle for water",
    312,
    24,
    @raylib.Color::new(196, 222, 244, 236),
  )
  draw_center_text(
    "2) Leaf rack for tea type",
    344,
    24,
    @raylib.Color::new(196, 222, 244, 236),
  )
  draw_center_text(
    "3) Brewer to make cup",
    376,
    24,
    @raylib.Color::new(196, 222, 244, 236),
  )
  draw_center_text(
    "4) Serve at counter near waiting customer",
    408,
    24,
    @raylib.Color::new(196, 222, 244, 236),
  )
  draw_center_text(
    "Hold focus to slow patience drain, dash to reposition",
    440,
    24,
    @raylib.Color::new(196, 222, 244, 236),
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
      @raylib.Color::new(90, 190, 246, 220)
    } else {
      @raylib.Color::new(44, 124, 194, 192)
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
  let y = lerpf(232.0, 166.0, ease_out_cubic(t)).to_int()

  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 20, 30, 126),
  )

  draw_center_text(
    "SHIFT COMPLETE",
    y,
    66,
    @raylib.Color::new(166, 255, 228, 246),
  )
  draw_center_text(
    "Bonus +" + (stage_clear_bonus + game.stage * 120).to_string(),
    y + 78,
    30,
    a_col(amber(), 240),
  )
  draw_center_text(
    "Next rush arriving...",
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

  draw_center_text("SERVICE COLLAPSED", 150, 66, a_col(pink(), 248))
  draw_center_text(
    "Customers walked out before dawn",
    226,
    30,
    @raylib.Color::new(234, 206, 220, 236),
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
    "SERVED " +
    game.served.to_string() +
    "    MISSED " +
    game.missed.to_string(),
    386,
    28,
    @raylib.Color::new(188, 214, 236, 236),
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

  let t = clampf(game.flash_t / 0.24, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(255, 130, 170, (t * 120.0).to_int()),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_sky(game, cam_x, cam_y)
  draw_room_base(game, cam_x, cam_y)

  draw_kettle(game, cam_x, cam_y)
  draw_leaf_racks(game, cam_x, cam_y)
  draw_brewer(game, cam_x, cam_y)
  draw_counter(game, cam_x, cam_y)

  for i = 0; i < game.customers.length(); i = i + 1 {
    if game.customers[i].active {
      draw_customer(game.customers[i], cam_x, cam_y)
    }
  }

  draw_player(game, cam_x, cam_y)
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
      "Mobile: move pad + ACT / FOCUS / DASH",
      screen_h - 24,
      20,
      @raylib.Color::new(210, 236, 255, 220),
    )
  }
}
