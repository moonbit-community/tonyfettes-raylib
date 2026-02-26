///|
fn bg_wave(game : Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

  let w0 : Float = bg_wave(game, 0.66)
  let w1 : Float = bg_wave(game, 0.93)

  @raylib.draw_circle(
    220,
    150,
    210.0 + w0 * 18.0,
    @raylib.Color::new(28, 52, 90, 44),
  )
  @raylib.draw_circle(
    screen_w - 260,
    170,
    204.0 - w1 * 16.0,
    @raylib.Color::new(70, 38, 72, 34),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 64
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      46,
      @raylib.Color::new(
        12 + i * 7 % 20,
        16 + i * 8 % 20,
        24 + i * 10 % 24,
        14 + i * 8 % 28,
      ),
    )
  }
}

///|
fn draw_world_back(game : Game) -> Unit {
  @raylib.draw_rectangle(
    world_x0,
    world_y0,
    world_w,
    world_h,
    @raylib.Color::new(20, 30, 48, 228),
  )

  @raylib.draw_rectangle_lines(
    world_x0,
    world_y0,
    world_w,
    world_h,
    @raylib.Color::new(150, 192, 226, 210),
  )

  let wave : Float = bg_wave(game, 1.5)
  for i = 0; i < 20; i = i + 1 {
    let y : Int = world_y0 + i * 48
    @raylib.draw_rectangle(
      world_x0 + 6,
      y,
      world_w - 12,
      20,
      @raylib.Color::new(
        28 + i * 4 % 18,
        42 + i * 6 % 22,
        64 + i * 7 % 28,
        26 + i * 4 % 22,
      ),
    )
  }

  @raylib.draw_line(
    world_x0,
    world_y0 + 120 + (wave * 6.0).to_int(),
    world_x0 + world_w,
    world_y0 + 120 - (wave * 6.0).to_int(),
    @raylib.Color::new(154, 202, 236, 62),
  )
}

///|
fn draw_obstacle(ob : Obstacle) -> Unit {
  if not(ob.active) {
    return
  }

  let gy : Float = obstacle_gap_mid(ob)
  let gh : Float = ob.gap_h

  let top_h : Int = (gy - gh / 2.0 - world_top()).to_int()
  let bot_y : Int = (gy + gh / 2.0).to_int()
  let bot_h : Int = (world_bottom() - gy - gh / 2.0).to_int()

  let x : Int = ob.x.to_int()
  let w : Int = ob.w.to_int()

  let c0 : @raylib.Color = if ob.kind == obstacle_kind_beam {
    @raylib.Color::new(170, 104, 96, 244)
  } else if ob.kind == obstacle_kind_spinner {
    @raylib.Color::new(118, 100, 156, 244)
  } else {
    @raylib.Color::new(98, 136, 182, 244)
  }

  @raylib.draw_rectangle(x, world_y0, w, top_h, c0)
  @raylib.draw_rectangle(x, bot_y, w, bot_h, c0)

  @raylib.draw_rectangle_lines(
    x,
    world_y0,
    w,
    top_h,
    @raylib.Color::new(208, 220, 238, 186),
  )
  @raylib.draw_rectangle_lines(
    x,
    bot_y,
    w,
    bot_h,
    @raylib.Color::new(208, 220, 238, 186),
  )

  if ob.kind == obstacle_kind_spinner {
    let cx : Int = x + w / 2
    let cy : Int = gy.to_int()
    let arm : Int = (gh * 0.40).to_int()

    let ang : Float = ob.phase
    let ax : Int = (Float::from_int(cx) +
    Float::from_double(@math.cos(ang.to_double())) * Float::from_int(arm)).to_int()
    let ay : Int = (Float::from_int(cy) +
    Float::from_double(@math.sin(ang.to_double())) * Float::from_int(arm)).to_int()

    @raylib.draw_line(cx, cy, ax, ay, @raylib.Color::new(238, 212, 146, 236))
    @raylib.draw_circle(cx, cy, 7.0, @raylib.Color::new(255, 226, 164, 236))
    @raylib.draw_circle(ax, ay, 8.0, @raylib.Color::new(255, 174, 122, 236))
  }
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_score {
    @raylib.Color::new(120, 218, 255, 250)
  } else if kind == pickup_boost {
    @raylib.Color::new(255, 200, 122, 250)
  } else if kind == pickup_shield {
    @raylib.Color::new(172, 206, 255, 250)
  } else {
    @raylib.Color::new(255, 130, 152, 250)
  }
}

///|
fn draw_pickup(pk : Pickup) -> Unit {
  if not(pk.active) {
    return
  }

  let pulse : Float = Float::from_double(@math.sin(pk.phase.to_double()))
  let base_r : Float = if pk.kind == pickup_score { 14.0 } else { 18.0 }
  let r : Float = base_r + pulse * 2.0

  let c : @raylib.Color = pickup_color(pk.kind)

  @raylib.draw_circle(pk.x.to_int(), pk.y.to_int(), r, c)
  @raylib.draw_circle_lines(
    pk.x.to_int(),
    pk.y.to_int(),
    r + 3.0,
    @raylib.Color::new(246, 250, 255, 206),
  )
}

///|
fn draw_player(game : Game) -> Unit {
  let tilt : Float = clampf(game.vy * 0.0014, -0.35, 0.45)

  @raylib.draw_circle(
    game.px.to_int(),
    game.py.to_int(),
    player_r,
    @raylib.Color::new(104, 228, 170, 252),
  )
  @raylib.draw_circle(
    game.px.to_int() - 6,
    game.py.to_int() - 7,
    player_r * 0.36,
    @raylib.Color::new(210, 252, 230, 186),
  )

  let wing_y : Int = (game.py + tilt * 26.0).to_int()
  @raylib.draw_triangle(
    @raylib.Vector2::new(game.px - 6.0, Float::from_int(wing_y)),
    @raylib.Vector2::new(game.px - 30.0, Float::from_int(wing_y - 12)),
    @raylib.Vector2::new(game.px - 26.0, Float::from_int(wing_y + 14)),
    @raylib.Color::new(92, 194, 146, 246),
  )

  @raylib.draw_circle(
    game.px.to_int() + 7,
    game.py.to_int() - 6,
    4.0,
    @raylib.Color::new(22, 32, 30, 236),
  )

  if game.shield_t > 0.0 {
    let pulse : Float = Float::from_double(
      @math.sin((game.ui_t * 8.0).to_double()),
    )
    @raylib.draw_circle_lines(
      game.px.to_int(),
      game.py.to_int(),
      player_r + 8.0 + pulse * 2.0,
      @raylib.Color::new(176, 220, 255, 238),
    )
  }
}

///|
fn draw_hint(game : Game) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let x : Int = world_x0 + world_w / 2
  let y : Int = game.hint_y.to_int()
  let pulse : Float = Float::from_double(
    @math.sin((game.ui_t * 9.0).to_double()),
  )

  @raylib.draw_circle_lines(
    x,
    y,
    30.0 + pulse * 4.0,
    @raylib.Color::new(255, 232, 130, 242),
  )
}

///|
fn draw_particles(game : Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let a : Int = if game.particles[i].life > 0.7 {
      236
    } else if game.particles[i].life > 0.4 {
      196
    } else {
      132
    }

    let c : @raylib.Color = if game.particles[i].kind == 2 {
      @raylib.Color::new(255, 170, 122, a)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(255, 224, 138, a)
    } else {
      @raylib.Color::new(138, 232, 180, a)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int(),
      game.particles[i].y.to_int(),
      1.0 + game.particles[i].size,
      c,
    )
  }
}

///|
fn draw_touch_button(
  label : String,
  rect : (Int, Int, Int, Int),
  active : Bool,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if active {
      tint
    } else {
      @raylib.Color::new(42, 60, 86, 206)
    },
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(184, 216, 242, 218),
  )

  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - @raylib.measure_text(label, 30) / 2,
    rect.1 + rect.3 / 2 - 15,
    30,
    @raylib.Color::new(246, 252, 255, 248),
  )
}

///|
fn draw_controls(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if game.state != state_play {
    return
  }

  let flap = btn_flap_rect()
  let boost = btn_boost_rect()
  let rs = btn_restart_rect()
  let hint = btn_hint_rect()

  let flap_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    flap.0,
    flap.1,
    flap.2,
    flap.3,
  )
  let boost_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    boost.0,
    boost.1,
    boost.2,
    boost.3,
  )
  let rs_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    rs.0,
    rs.1,
    rs.2,
    rs.3,
  )
  let hint_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    hint.0,
    hint.1,
    hint.2,
    hint.3,
  )

  draw_touch_button(
    "FLAP",
    flap,
    flap_on,
    @raylib.Color::new(92, 150, 206, 230),
  )
  draw_touch_button(
    if game.boost_meter > 0.08 {
      "BOOST"
    } else {
      "BOOST 0"
    },
    boost,
    boost_on || game.boost_on,
    @raylib.Color::new(194, 140, 92, 230),
  )
  draw_touch_button("RESTART", rs, rs_on, @raylib.Color::new(134, 96, 106, 230))
  draw_touch_button(
    "HINT \{game.hint_left}",
    hint,
    hint_on,
    @raylib.Color::new(166, 134, 84, 230),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  let px : Int = panel_x0
  let py : Int = 20
  let pw : Int = panel_w
  let ph : Int = screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(14, 22, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(126, 170, 206, 220),
  )

  @raylib.draw_text(
    "Flappy Sky Ruins",
    px + 20,
    py + 20,
    42,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "2026 Expedition",
    px + 20,
    py + 66,
    28,
    @raylib.Color::new(196, 220, 246, 238),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 110,
    36,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    px + 252,
    py + 110,
    34,
    @raylib.Color::new(206, 228, 248, 240),
  )

  @raylib.draw_text(
    "Lives \{game.lives}",
    px + 20,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Level \{game.level}",
    px + 176,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 320,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @raylib.draw_text(
    "Distance \{game.distance}",
    px + 20,
    py + 194,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Combo x\{game.combo}",
    px + 240,
    py + 194,
    30,
    if game.combo > 1 {
      @raylib.Color::new(255, 224, 136, 248)
    } else {
      @raylib.Color::new(212, 232, 252, 242)
    },
  )

  @raylib.draw_text(
    "Boost",
    px + 20,
    py + 236,
    30,
    @raylib.Color::new(220, 236, 252, 242),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(30, 42, 60, 220),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    ((pw - 40).to_double() * game.boost_meter.to_double()).to_int(),
    30,
    @raylib.Color::new(94, 164, 220, 236),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(184, 214, 236, 230),
  )

  let shield_text : String = if game.shield_t > 0.0 { "ON" } else { "OFF" }
  @raylib.draw_text(
    "Shield \{shield_text}",
    px + 20,
    py + 314,
    28,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @raylib.draw_text(
    "Controls",
    px + 20,
    py + 360,
    28,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    "Flap: Space / Tap",
    px + 20,
    py + 392,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Boost: Shift / J",
    px + 20,
    py + 418,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Hint: H",
    px + 20,
    py + 444,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Restart: R",
    px + 20,
    py + 470,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + 560,
      pw - 40,
      56,
      @raylib.Color::new(40, 58, 82, 224),
    )
    @raylib.draw_rectangle_lines(
      px + 20,
      py + 560,
      pw - 40,
      56,
      @raylib.Color::new(176, 208, 236, 230),
    )
    @raylib.draw_text(
      game.msg,
      px + 30,
      py + 578,
      28,
      @raylib.Color::new(246, 252, 255, 248),
    )
  }
}

///|
fn draw_title(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Unit {
  @raylib.draw_text(
    "Flappy Sky Ruins 2026",
    screen_w / 2 - @raylib.measure_text("Flappy Sky Ruins 2026", 86) / 2,
    110,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @raylib.draw_text(
    "Flap through collapsing ruins, collect relics, and survive for 3 minutes.",
    screen_w / 2 -
    @raylib.measure_text(
      "Flap through collapsing ruins, collect relics, and survive for 3 minutes.",
      34,
    ) /
    2,
    252,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )
  @raylib.draw_text(
    "Mobile touch controls are built in.",
    screen_w / 2 -
    @raylib.measure_text("Mobile touch controls are built in.", 34) / 2,
    294,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let r = start_button_rect()
  let hov : Bool = title_hover(mx, my, hold, touch_count)

  draw_touch_button("Start Run", r, hov, @raylib.Color::new(92, 150, 206, 230))
}

///|
fn draw_result_overlay(
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
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 840
  let ph : Int = 500
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 24, 36, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(172, 206, 236, 236),
  )

  let title : String = if game.win { "Run Complete" } else { "Run Failed" }

  @raylib.draw_text(
    title,
    px + pw / 2 - @raylib.measure_text(title, 64) / 2,
    py + 34,
    64,
    @raylib.Color::new(244, 250, 255, 250),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 100,
    py + 132,
    44,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @raylib.draw_text(
    "Distance \{game.distance}",
    px + 100,
    py + 182,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Level \{game.level}",
    px + 100,
    py + 228,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 100,
    py + 274,
    36,
    @raylib.Color::new(206, 228, 248, 238),
  )

  let r = retry_button_rect()
  let hov : Bool = result_hover(mx, my, hold, touch_count)
  draw_touch_button("Play Again", r, hov, @raylib.Color::new(96, 154, 210, 230))
}

///|
fn draw_world(game : Game) -> Unit {
  draw_world_back(game)

  for i = 0; i < game.obstacles.length(); i = i + 1 {
    draw_obstacle(game.obstacles[i])
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i])
  }

  draw_hint(game)
  draw_player(game)
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_bg(game)

  if game.state == state_title {
    draw_title(mx, my, hold, touch_count)
    return
  }

  draw_world(game)
  draw_particles(game)
  draw_panel(game)
  draw_controls(game, mx, my, hold, touch_count)

  if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
