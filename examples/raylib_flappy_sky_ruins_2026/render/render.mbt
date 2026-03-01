///|
fn bg_wave(game : @types.Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
fn draw_bg(game : @types.Game) -> Unit {
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
    @types.screen_w - 260,
    170,
    204.0 - w1 * 16.0,
    @raylib.Color::new(70, 38, 72, 34),
  )

  for i in 0..<16 {
    let y : Int = i * 64
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
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
fn draw_world_back(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(20, 30, 48, 228),
  )

  @raylib.draw_rectangle_lines(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(150, 192, 226, 210),
  )

  let wave : Float = bg_wave(game, 1.5)
  for i in 0..<20 {
    let y : Int = @types.world_y0 + i * 48
    @raylib.draw_rectangle(
      @types.world_x0 + 6,
      y,
      @types.world_w - 12,
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
    @types.world_x0,
    @types.world_y0 + 120 + (wave * 6.0).to_int(),
    @types.world_x0 + @types.world_w,
    @types.world_y0 + 120 - (wave * 6.0).to_int(),
    @raylib.Color::new(154, 202, 236, 62),
  )
}

///|
fn draw_obstacle(ob : @types.Obstacle) -> Unit {
  if not(ob.active) {
    return
  }

  let gy : Float = @types.obstacle_gap_mid(ob)
  let gh : Float = ob.gap_h

  let top_h : Int = (gy - gh / 2.0 - @types.world_top()).to_int()
  let bot_y : Int = (gy + gh / 2.0).to_int()
  let bot_h : Int = (@types.world_bottom() - gy - gh / 2.0).to_int()

  let x : Int = ob.x.to_int()
  let w : Int = ob.w.to_int()

  let c0 : @raylib.Color = if ob.kind == @types.obstacle_kind_beam {
    @raylib.Color::new(170, 104, 96, 244)
  } else if ob.kind == @types.obstacle_kind_spinner {
    @raylib.Color::new(118, 100, 156, 244)
  } else {
    @raylib.Color::new(98, 136, 182, 244)
  }

  @raylib.draw_rectangle(x, @types.world_y0, w, top_h, c0)
  @raylib.draw_rectangle(x, bot_y, w, bot_h, c0)

  @raylib.draw_rectangle_lines(
    x,
    @types.world_y0,
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

  if ob.kind == @types.obstacle_kind_spinner {
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
  if kind == @types.pickup_score {
    @raylib.Color::new(120, 218, 255, 250)
  } else if kind == @types.pickup_boost {
    @raylib.Color::new(255, 200, 122, 250)
  } else if kind == @types.pickup_shield {
    @raylib.Color::new(172, 206, 255, 250)
  } else {
    @raylib.Color::new(255, 130, 152, 250)
  }
}

///|
fn draw_pickup(pk : @types.Pickup) -> Unit {
  if not(pk.active) {
    return
  }

  let pulse : Float = Float::from_double(@math.sin(pk.phase.to_double()))
  let base_r : Float = if pk.kind == @types.pickup_score { 14.0 } else { 18.0 }
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
fn draw_player(game : @types.Game) -> Unit {
  let tilt : Float = @types.clampf(game.vy * 0.0014, -0.35, 0.45)

  @raylib.draw_circle(
    game.px.to_int(),
    game.py.to_int(),
    @types.player_r,
    @raylib.Color::new(104, 228, 170, 252),
  )
  @raylib.draw_circle(
    game.px.to_int() - 6,
    game.py.to_int() - 7,
    @types.player_r * 0.36,
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
      @types.player_r + 8.0 + pulse * 2.0,
      @raylib.Color::new(176, 220, 255, 238),
    )
  }
}

///|
fn draw_hint(game : @types.Game) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let x : Int = @types.world_x0 + @types.world_w / 2
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
fn draw_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    let a : Int = if particle.life > 0.7 {
      236
    } else if particle.life > 0.4 {
      196
    } else {
      132
    }

    let c : @raylib.Color = if particle.kind == 2 {
      @raylib.Color::new(255, 170, 122, a)
    } else if particle.kind == 1 {
      @raylib.Color::new(255, 224, 138, a)
    } else {
      @raylib.Color::new(138, 232, 180, a)
    }

    @raylib.draw_circle(
      particle.x.to_int(),
      particle.y.to_int(),
      1.0 + particle.size,
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
fn draw_controls(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  let flap = @types.btn_flap_rect()
  let boost = @types.btn_boost_rect()
  let rs = @types.btn_restart_rect()
  let hint = @types.btn_hint_rect()

  let flap_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    flap.0,
    flap.1,
    flap.2,
    flap.3,
  )
  let boost_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    boost.0,
    boost.1,
    boost.2,
    boost.3,
  )
  let rs_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    rs.0,
    rs.1,
    rs.2,
    rs.3,
  )
  let hint_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
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
fn draw_panel(game : @types.Game) -> Unit {
  let px : Int = @types.panel_x0
  let py : Int = 20
  let pw : Int = @types.panel_w
  let ph : Int = @types.screen_h - 40

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
fn draw_title(game : @types.Game) -> Unit {
  @raylib.draw_text(
    "Flappy Sky Ruins 2026",
    @types.screen_w / 2 -
    @raylib.measure_text("Flappy Sky Ruins 2026", 86) / 2,
    110,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @raylib.draw_text(
    "Flap through collapsing ruins, collect relics, and survive for 3 minutes.",
    @types.screen_w / 2 -
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
    @types.screen_w / 2 -
    @raylib.measure_text("Mobile touch controls are built in.", 34) / 2,
    294,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let r = @types.start_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )

  draw_touch_button("Start Run", r, hov, @raylib.Color::new(92, 150, 206, 230))
}

///|
fn draw_result_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 840
  let ph : Int = 500
  let px : Int = @types.screen_w / 2 - pw / 2
  let py : Int = @types.screen_h / 2 - ph / 2

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

  let r = @types.retry_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )
  draw_touch_button("Play Again", r, hov, @raylib.Color::new(96, 154, 210, 230))
}

///|
fn draw_world(game : @types.Game) -> Unit {
  draw_world_back(game)

  for obstacle in game.obstacles {
    draw_obstacle(obstacle)
  }

  for pickup in game.pickups {
    draw_pickup(pickup)
  }

  draw_hint(game)
  draw_player(game)
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_bg(game)

  if game.state == @types.state_title {
    draw_title(game)
    return
  }

  draw_world(game)
  draw_particles(game)
  draw_panel(game)
  draw_controls(game)

  if game.state == @types.state_result {
    draw_result_overlay(game)
  }
}
