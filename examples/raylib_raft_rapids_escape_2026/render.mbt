///|
fn ui_wave(game : Game, k : Float) -> Float {
  sinf(game.ui_t * k)
}

///|
fn shake_offset_x(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-6, 6)
  }
}

///|
fn shake_offset_y(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(7, 16, 26, 255))

  let w0 : Float = ui_wave(game, 0.58)
  let w1 : Float = ui_wave(game, 0.92)

  @raylib.draw_circle(
    210,
    140,
    220.0 + w0 * 20.0,
    @raylib.Color::new(18, 64, 96, 36),
  )
  @raylib.draw_circle(
    620,
    120,
    200.0 - w1 * 22.0,
    @raylib.Color::new(18, 48, 74, 32),
  )
  @raylib.draw_circle(
    screen_w - 320,
    180,
    260.0 + w1 * 18.0,
    @raylib.Color::new(34, 52, 90, 34),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 70
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      44,
      @raylib.Color::new(
        8 + i * 2 % 12,
        20 + i * 3 % 20,
        30 + i * 5 % 26,
        10 + i * 2 % 18,
      ),
    )
  }
}

///|
fn draw_world_back(game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(14, 40, 62, 235),
  )

  @raylib.draw_rectangle_lines(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(168, 224, 238, 210),
  )

  for i = 0; i < 23; i = i + 1 {
    let y : Int = world_y0 + oy + i * 42
    let shift : Int = (ui_wave(game, 1.0 + Float::from_int(i) * 0.07) * 18.0).to_int()

    @raylib.draw_line(
      world_x0 + 14 + ox,
      y,
      world_x0 + world_w - 14 + ox + shift,
      y,
      @raylib.Color::new(48, 96 + i * 5 % 44, 130 + i * 4 % 62, 52),
    )
  }

  let bank_wave : Int = (ui_wave(game, 1.32) * 8.0).to_int()

  @raylib.draw_rectangle(
    world_x0 - 10 + ox + bank_wave,
    world_y0 + oy,
    14,
    world_h,
    @raylib.Color::new(48, 74, 48, 220),
  )
  @raylib.draw_rectangle(
    world_x0 + world_w - 4 + ox - bank_wave,
    world_y0 + oy,
    14,
    world_h,
    @raylib.Color::new(48, 74, 48, 220),
  )
}

///|
fn draw_currents(game : Game, ox : Int, oy : Int) -> Unit {
  for r = 0; r < 12; r = r + 1 {
    let row_y : Float = world_top() + 38.0 + Float::from_int(r) * 76.0

    for c = 0; c < 7; c = c + 1 {
      let x : Float = world_left() + 90.0 + Float::from_int(c) * 150.0
      let cx : Float = water_current_x(game, row_y)
      let cy : Float = water_current_y(game, x)

      let sx : Int = x.to_int() + ox
      let sy : Int = row_y.to_int() + oy
      let ex : Int = (x + cx * 0.16).to_int() + ox
      let ey : Int = (row_y + cy * 0.08).to_int() + oy

      @raylib.draw_line(sx, sy, ex, ey, @raylib.Color::new(180, 236, 248, 70))
      @raylib.draw_circle(ex, ey, 2.0, @raylib.Color::new(188, 244, 255, 84))
    }
  }
}

///|
fn obstacle_color(kind : Int) -> @raylib.Color {
  if kind == obstacle_rock {
    @raylib.Color::new(106, 132, 146, 245)
  } else if kind == obstacle_log {
    @raylib.Color::new(132, 98, 58, 245)
  } else {
    @raylib.Color::new(192, 92, 102, 245)
  }
}

///|
fn draw_obstacle(ob : Obstacle, ox : Int, oy : Int) -> Unit {
  if not(ob.active) {
    return
  }

  let x : Int = ob.x.to_int() + ox
  let y : Int = ob.y.to_int() + oy
  let w : Int = ob.w.to_int()
  let h : Int = ob.h.to_int()

  let c0 : @raylib.Color = obstacle_color(ob.kind)

  if ob.kind == obstacle_rock {
    @raylib.draw_rectangle(x, y, w, h, c0)
    @raylib.draw_circle(
      x + w / 2,
      y + h / 2,
      Float::from_int(mini(w, h)) * 0.42,
      @raylib.Color::new(160, 184, 196, 180),
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(220, 236, 242, 170),
    )
  } else if ob.kind == obstacle_log {
    @raylib.draw_rectangle(x, y, w, h, c0)
    @raylib.draw_circle(
      x + 8,
      y + h / 2,
      Float::from_int(h) * 0.42,
      @raylib.Color::new(146, 112, 74, 240),
    )
    @raylib.draw_circle(
      x + w - 8,
      y + h / 2,
      Float::from_int(h) * 0.42,
      @raylib.Color::new(146, 112, 74, 240),
    )

    for i = 0; i < 4; i = i + 1 {
      let px : Int = x + 16 + i * (w - 32) / 3
      @raylib.draw_line(
        px,
        y + 4,
        px,
        y + h - 4,
        @raylib.Color::new(92, 70, 40, 210),
      )
    }
  } else {
    let r : Float = Float::from_int(mini(w, h)) * 0.42
    let cx : Int = x + w / 2
    let cy : Int = y + h / 2

    @raylib.draw_circle(cx, cy, r, c0)
    @raylib.draw_circle_lines(
      cx,
      cy,
      r + 3.0,
      @raylib.Color::new(255, 208, 208, 180),
    )

    for i = 0; i < 8; i = i + 1 {
      let a : Float = ob.phase + Float::from_int(i) * 0.785
      let px0 : Int = (Float::from_int(cx) + cosf(a) * (r - 2.0)).to_int()
      let py0 : Int = (Float::from_int(cy) + sinf(a) * (r - 2.0)).to_int()
      let px1 : Int = (Float::from_int(cx) + cosf(a) * (r + 10.0)).to_int()
      let py1 : Int = (Float::from_int(cy) + sinf(a) * (r + 10.0)).to_int()
      @raylib.draw_line(
        px0,
        py0,
        px1,
        py1,
        @raylib.Color::new(255, 214, 128, 220),
      )
    }
  }
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_coin {
    @raylib.Color::new(118, 232, 255, 245)
  } else if kind == pickup_fuel {
    @raylib.Color::new(255, 198, 106, 245)
  } else if kind == pickup_shield {
    @raylib.Color::new(172, 214, 255, 245)
  } else {
    @raylib.Color::new(255, 130, 166, 245)
  }
}

///|
fn draw_pickup(pk : Pickup, ox : Int, oy : Int) -> Unit {
  if not(pk.active) {
    return
  }

  let pulse : Float = sinf(pk.phase * 2.1)
  let rr : Float = pickup_radius(pk.kind) + pulse * 1.8
  let c : @raylib.Color = pickup_color(pk.kind)

  let x : Int = pk.x.to_int() + ox
  let y : Int = pk.y.to_int() + oy

  @raylib.draw_circle(x, y, rr, c)
  @raylib.draw_circle_lines(
    x,
    y,
    rr + 3.0,
    @raylib.Color::new(250, 252, 255, 210),
  )

  if pk.kind == pickup_fuel {
    @raylib.draw_rectangle(
      x - 5,
      y - 8,
      10,
      16,
      @raylib.Color::new(56, 42, 28, 220),
    )
  } else if pk.kind == pickup_shield {
    @raylib.draw_circle_lines(
      x,
      y,
      rr - 5.0,
      @raylib.Color::new(218, 240, 255, 190),
    )
  } else if pk.kind == pickup_repair {
    @raylib.draw_line(
      x - 7,
      y,
      x + 7,
      y,
      @raylib.Color::new(255, 248, 248, 220),
    )
    @raylib.draw_line(
      x,
      y - 7,
      x,
      y + 7,
      @raylib.Color::new(255, 248, 248, 220),
    )
  }
}

///|
fn draw_particles(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let a : Int = if game.particles[i].life > 0.7 {
      236
    } else if game.particles[i].life > 0.4 {
      186
    } else {
      112
    }

    let c : @raylib.Color = if game.particles[i].kind == 2 {
      @raylib.Color::new(194, 236, 255, a)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(255, 156, 138, a)
    } else {
      @raylib.Color::new(144, 224, 255, a)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int() + ox,
      game.particles[i].y.to_int() + oy,
      game.particles[i].size,
      c,
    )
  }
}

///|
fn draw_raft(game : Game, ox : Int, oy : Int) -> Unit {
  let cx : Int = game.raft_x.to_int() + ox
  let cy : Int = game.raft_y.to_int() + oy

  let tilt : Float = clampf(game.raft_vx * 0.0016, -0.55, 0.55)

  @raylib.draw_circle(
    cx,
    cy,
    raft_r + 2.0,
    @raylib.Color::new(64, 118, 98, 252),
  )
  @raylib.draw_circle(
    cx,
    cy,
    raft_r - 6.0,
    @raylib.Color::new(176, 142, 84, 252),
  )
  @raylib.draw_circle(
    cx - 8,
    cy - 8,
    8.0,
    @raylib.Color::new(230, 206, 142, 210),
  )

  let prow_x : Int = (Float::from_int(cx) + tilt * 18.0).to_int()
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(prow_x), Float::from_int(cy - 24)),
    @raylib.Vector2::new(Float::from_int(cx - 12), Float::from_int(cy - 8)),
    @raylib.Vector2::new(Float::from_int(cx + 12), Float::from_int(cy - 8)),
    @raylib.Color::new(124, 92, 50, 252),
  )

  @raylib.draw_circle(cx + 6, cy - 6, 4.0, @raylib.Color::new(24, 36, 28, 220))

  if game.boost_on && game.fuel > 0.6 {
    let f : Float = 8.0 + ui_wave(game, 11.0) * 3.0
    @raylib.draw_circle(cx, cy + 18, f, @raylib.Color::new(86, 234, 255, 168))
  }

  if game.shield_t > 0.0 {
    let pulse : Float = sinf(game.ui_t * 8.0)
    @raylib.draw_circle_lines(
      cx,
      cy,
      raft_r + 10.0 + pulse * 2.0,
      @raylib.Color::new(174, 222, 255, 242),
    )
  }
}

///|
fn draw_hint(game : Game, ox : Int, oy : Int) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let pulse : Float = sinf(game.ui_t * 10.0)
  let alpha : Int = if game.hint_t > 1.2 {
    238
  } else {
    112 + (game.hint_t * 100.0).to_int()
  }

  @raylib.draw_circle_lines(
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    30.0 + pulse * 3.0,
    @raylib.Color::new(255, 232, 130, alpha),
  )

  @raylib.draw_line(
    game.raft_x.to_int() + ox,
    game.raft_y.to_int() + oy,
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    @raylib.Color::new(255, 232, 130, alpha / 2),
  )
}

///|
fn draw_progress_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  c_fill : @raylib.Color,
  c_back : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, c_back)

  let clamped : Float = clampf(ratio, 0.0, 1.0)
  let fw : Int = (Float::from_int(w) * clamped).to_int()

  if fw > 0 {
    @raylib.draw_rectangle(x, y, fw, h, c_fill)
  }

  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(216, 236, 244, 190),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(16, 24, 38, 228),
  )
  @raylib.draw_rectangle_lines(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(164, 210, 236, 200),
  )

  @raylib.draw_text(
    "RAFT RAPIDS ESCAPE",
    panel_x0 + 24,
    36,
    34,
    @raylib.Color::new(226, 244, 255, 245),
  )
  @raylib.draw_text(
    "2026 expedition",
    panel_x0 + 24,
    76,
    22,
    @raylib.Color::new(148, 196, 222, 220),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 24,
    138,
    30,
    @raylib.Color::new(236, 244, 255, 242),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 24,
    174,
    24,
    @raylib.Color::new(190, 220, 234, 228),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 24,
    220,
    24,
    @raylib.Color::new(255, 214, 214, 240),
  )
  @raylib.draw_text(
    "Level " + game.level.to_string(),
    panel_x0 + 170,
    220,
    24,
    @raylib.Color::new(200, 226, 255, 240),
  )

  @raylib.draw_text(
    "Distance " + game.distance.to_string() + " m",
    panel_x0 + 24,
    254,
    24,
    @raylib.Color::new(198, 232, 250, 236),
  )

  let fuel_ratio : Float = game.fuel / 100.0
  let shield_ratio : Float = clampf(game.shield_t / 7.0, 0.0, 1.0)
  let time_ratio : Float = clampf(game.game_t / run_time_goal, 0.0, 1.0)

  @raylib.draw_text(
    "Fuel",
    panel_x0 + 24,
    306,
    22,
    @raylib.Color::new(230, 238, 246, 224),
  )
  draw_progress_bar(
    panel_x0 + 24,
    334,
    panel_w - 48,
    18,
    fuel_ratio,
    @raylib.Color::new(255, 190, 94, 242),
    @raylib.Color::new(58, 44, 26, 220),
  )

  @raylib.draw_text(
    "Shield",
    panel_x0 + 24,
    364,
    22,
    @raylib.Color::new(230, 238, 246, 224),
  )
  draw_progress_bar(
    panel_x0 + 24,
    392,
    panel_w - 48,
    18,
    shield_ratio,
    @raylib.Color::new(154, 208, 255, 242),
    @raylib.Color::new(36, 56, 74, 220),
  )

  @raylib.draw_text(
    "Run time",
    panel_x0 + 24,
    422,
    22,
    @raylib.Color::new(230, 238, 246, 224),
  )
  draw_progress_bar(
    panel_x0 + 24,
    450,
    panel_w - 48,
    18,
    time_ratio,
    @raylib.Color::new(138, 240, 176, 242),
    @raylib.Color::new(30, 64, 44, 220),
  )

  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    panel_x0 + 24,
    484,
    24,
    if game.combo >= 4 {
      @raylib.Color::new(255, 232, 126, 246)
    } else {
      @raylib.Color::new(194, 224, 238, 228)
    },
  )

  @raylib.draw_text(
    "Hints left " + game.hint_left.to_string(),
    panel_x0 + 24,
    516,
    22,
    @raylib.Color::new(202, 224, 248, 220),
  )

  @raylib.draw_text(
    "Desktop: WASD/Arrows move",
    panel_x0 + 24,
    568,
    20,
    @raylib.Color::new(170, 206, 226, 214),
  )
  @raylib.draw_text(
    "Shift/J boost, H hint, R restart",
    panel_x0 + 24,
    594,
    20,
    @raylib.Color::new(170, 206, 226, 214),
  )
  @raylib.draw_text(
    "Mobile: touch buttons on right",
    panel_x0 + 24,
    620,
    20,
    @raylib.Color::new(170, 206, 226, 214),
  )
}

///|
fn draw_touch_button(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rect : (Int, Int, Int, Int),
  label : String,
  base : @raylib.Color,
) -> Unit {
  let on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )

  let fill : @raylib.Color = if on {
    @raylib.Color::new(
      mini(255, base.r.to_int() + 38),
      mini(255, base.g.to_int() + 38),
      mini(255, base.b.to_int() + 38),
      228,
    )
  } else {
    base
  }

  @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, fill)
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(220, 236, 246, 188),
  )

  let fs : Int = if rect.3 <= 96 { 24 } else { 30 }
  let tw : Int = @raylib.measure_text(label, fs)
  @raylib.draw_text(
    label,
    rect.0 + (rect.2 - tw) / 2,
    rect.1 + (rect.3 - fs) / 2,
    fs,
    @raylib.Color::new(240, 246, 252, 240),
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
  if game.state != state_play {
    return
  }

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_left(),
    "L",
    @raylib.Color::new(40, 78, 104, 168),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_right(),
    "R",
    @raylib.Color::new(40, 78, 104, 168),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_up(),
    "U",
    @raylib.Color::new(40, 78, 104, 168),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_down(),
    "D",
    @raylib.Color::new(40, 78, 104, 168),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_boost(),
    "BOOST",
    if game.boost_on {
      @raylib.Color::new(96, 182, 250, 188)
    } else {
      @raylib.Color::new(44, 106, 162, 178)
    },
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hint(),
    "HINT",
    @raylib.Color::new(70, 94, 136, 176),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_restart(),
    "RST",
    @raylib.Color::new(94, 78, 116, 176),
  )
}

///|
fn draw_title_overlay(
  _game : Game,
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
    @raylib.Color::new(6, 10, 18, 160),
  )

  let title : String = "RAFT RAPIDS ESCAPE"
  let sub : String = "Survive 180 seconds through chaotic river channels"

  let tw : Int = @raylib.measure_text(title, 82)
  let sw : Int = @raylib.measure_text(sub, 30)

  @raylib.draw_text(
    title,
    screen_w / 2 - tw / 2,
    180,
    82,
    @raylib.Color::new(230, 248, 255, 246),
  )
  @raylib.draw_text(
    sub,
    screen_w / 2 - sw / 2,
    282,
    30,
    @raylib.Color::new(174, 208, 232, 236),
  )

  let p0 : String = "Collect coins/fuel, keep raft intact, use hints smartly"
  let p1 : String = "Desktop: WASD + Shift | Mobile: right-side touch pad"

  @raylib.draw_text(
    p0,
    screen_w / 2 - @raylib.measure_text(p0, 26) / 2,
    360,
    26,
    @raylib.Color::new(184, 220, 242, 222),
  )
  @raylib.draw_text(
    p1,
    screen_w / 2 - @raylib.measure_text(p1, 26) / 2,
    396,
    26,
    @raylib.Color::new(184, 220, 242, 222),
  )

  let b = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hover {
      @raylib.Color::new(72, 156, 222, 236)
    } else {
      @raylib.Color::new(52, 126, 190, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(226, 242, 255, 232),
  )

  let txt : String = "START EXPEDITION"
  let txt_w : Int = @raylib.measure_text(txt, 44)
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - txt_w) / 2,
    b.1 + 34,
    44,
    @raylib.Color::new(242, 249, 255, 248),
  )
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
    @raylib.Color::new(8, 10, 18, 170),
  )

  let head : String = if game.win {
    "MISSION COMPLETE"
  } else {
    "MISSION FAILED"
  }
  let sub : String = if game.win {
    "Rapids mastered. Route secured."
  } else {
    "Raft lost in the flood."
  }

  @raylib.draw_text(
    head,
    screen_w / 2 - @raylib.measure_text(head, 76) / 2,
    180,
    76,
    if game.win {
      @raylib.Color::new(176, 246, 198, 246)
    } else {
      @raylib.Color::new(255, 182, 174, 246)
    },
  )
  @raylib.draw_text(
    sub,
    screen_w / 2 - @raylib.measure_text(sub, 34) / 2,
    272,
    34,
    @raylib.Color::new(208, 228, 242, 236),
  )

  let l0 : String = "Score " + game.score.to_string()
  let l1 : String = "Best " + game.best_score.to_string()
  let l2 : String = "Distance " + game.distance.to_string() + " m"
  let l3 : String = "Time " +
    game.game_t.to_int().to_string() +
    " / " +
    run_time_goal.to_int().to_string() +
    " s"

  @raylib.draw_text(
    l0,
    screen_w / 2 - @raylib.measure_text(l0, 38) / 2,
    350,
    38,
    @raylib.Color::new(238, 246, 252, 244),
  )
  @raylib.draw_text(
    l1,
    screen_w / 2 - @raylib.measure_text(l1, 32) / 2,
    396,
    32,
    @raylib.Color::new(206, 230, 244, 236),
  )
  @raylib.draw_text(
    l2,
    screen_w / 2 - @raylib.measure_text(l2, 32) / 2,
    434,
    32,
    @raylib.Color::new(206, 230, 244, 236),
  )
  @raylib.draw_text(
    l3,
    screen_w / 2 - @raylib.measure_text(l3, 32) / 2,
    472,
    32,
    @raylib.Color::new(206, 230, 244, 236),
  )

  let b = retry_button_rect()
  let hover : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hover {
      @raylib.Color::new(76, 152, 216, 236)
    } else {
      @raylib.Color::new(54, 124, 182, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(226, 242, 255, 230),
  )

  let txt : String = "RUN AGAIN"
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - @raylib.measure_text(txt, 42)) / 2,
    b.1 + 32,
    42,
    @raylib.Color::new(242, 249, 255, 248),
  )
}

///|
fn draw_msg(game : Game) -> Unit {
  if game.msg_t <= 0.0 || game.msg == "" {
    return
  }

  let a : Int = if game.msg_t > 1.0 {
    230
  } else {
    90 + (game.msg_t * 140.0).to_int()
  }

  let w : Int = @raylib.measure_text(game.msg, 28) + 36
  let x : Int = world_x0 + (world_w - w) / 2
  let y : Int = world_y0 + 18

  @raylib.draw_rectangle(x, y, w, 46, @raylib.Color::new(22, 34, 54, a))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    46,
    @raylib.Color::new(198, 228, 246, mini(240, a + 10)),
  )
  @raylib.draw_text(
    game.msg,
    x + 18,
    y + 10,
    28,
    @raylib.Color::new(236, 246, 255, mini(255, a + 20)),
  )
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_background(game)

  let ox : Int = shake_offset_x(game)
  let oy : Int = shake_offset_y(game)

  draw_world_back(game, ox, oy)
  draw_currents(game, ox, oy)

  for i = 0; i < game.obstacles.length(); i = i + 1 {
    draw_obstacle(game.obstacles[i], ox, oy)
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i], ox, oy)
  }

  draw_hint(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_raft(game, ox, oy)

  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_msg(game)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
