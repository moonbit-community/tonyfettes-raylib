///|
fn bg_wave(game : Game, k : Float) -> Float {
  sinf(game.ui_t * k)
}

///|
fn shake_x(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-6, 6)
  }
}

///|
fn shake_y(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 18, 30, 255))

  let w0 : Float = bg_wave(game, 0.46)
  let w1 : Float = bg_wave(game, 0.88)

  @raylib.draw_circle(
    190,
    120,
    230.0 + w0 * 20.0,
    @raylib.Color::new(26, 66, 94, 28),
  )
  @raylib.draw_circle(
    720,
    150,
    280.0 - w1 * 26.0,
    @raylib.Color::new(24, 60, 90, 30),
  )
  @raylib.draw_circle(
    screen_w - 320,
    190,
    300.0 + w1 * 20.0,
    @raylib.Color::new(36, 54, 88, 32),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 64
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      40,
      @raylib.Color::new(
        9 + i * 2 % 13,
        16 + i * 3 % 17,
        24 + i * 4 % 20,
        12 + i * 2 % 18,
      ),
    )
  }
}

///|
fn draw_world_back(_game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(18, 32, 46, 236),
  )

  @raylib.draw_rectangle_lines(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(174, 208, 230, 204),
  )

  for i = 0; i < 20; i = i + 1 {
    let y : Int = world_y0 + oy + i * 48
    @raylib.draw_line(
      world_x0 + ox + 12,
      y,
      world_x0 + ox + world_w - 12,
      y,
      @raylib.Color::new(78, 112, 134, 36),
    )
  }

  for i = 0; i < 22; i = i + 1 {
    let x : Int = world_x0 + ox + i * 52
    @raylib.draw_line(
      x,
      world_y0 + oy + 12,
      x,
      world_y0 + oy + world_h - 12,
      @raylib.Color::new(70, 102, 122, 28),
    )
  }

  @raylib.draw_rectangle(
    world_x0 + ox - 8,
    world_y0 + oy,
    12,
    world_h,
    @raylib.Color::new(72, 88, 84, 218),
  )
  @raylib.draw_rectangle(
    world_x0 + ox + world_w - 4,
    world_y0 + oy,
    12,
    world_h,
    @raylib.Color::new(72, 88, 84, 218),
  )
}

///|
fn draw_safe_zone(game : Game, ox : Int, oy : Int) -> Unit {
  let pulse : Float = sinf(game.ui_t * 7.0)

  @raylib.draw_rectangle(
    safe_zone_x() + ox,
    safe_zone_y() + oy,
    safe_zone_w(),
    safe_zone_h(),
    @raylib.Color::new(58, 110, 142, 130),
  )
  @raylib.draw_rectangle_lines(
    safe_zone_x() + ox,
    safe_zone_y() + oy,
    safe_zone_w(),
    safe_zone_h(),
    @raylib.Color::new(214, 238, 252, 230),
  )

  @raylib.draw_circle_lines(
    safe_cx().to_int() + ox,
    safe_cy().to_int() + oy,
    40.0 + pulse * 3.0,
    @raylib.Color::new(228, 246, 255, 220),
  )

  @raylib.draw_text(
    "RESCUE PAD",
    safe_zone_x() + ox + 24,
    safe_zone_y() + oy + 18,
    24,
    @raylib.Color::new(234, 246, 255, 240),
  )
}

///|
fn draw_storm(game : Game, ox : Int, oy : Int) -> Unit {
  let alpha : Int = 36 + game.wave * 7

  for i = 0; i < 84; i = i + 1 {
    let t : Float = Float::from_int(i)

    let sx : Float = world_left() +
      Float::from_int(i * 71 % world_w) +
      sinf(game.storm_t * (0.9 + t * 0.01) + t * 0.6) * 30.0
    let sy : Float = world_top() +
      Float::from_int(i * 37 % world_h) +
      cosf(game.storm_t * (1.1 + t * 0.007) + t * 0.4) * 24.0

    let ex : Float = sx - 28.0
    let ey : Float = sy + 18.0

    @raylib.draw_line(
      sx.to_int() + ox,
      sy.to_int() + oy,
      ex.to_int() + ox,
      ey.to_int() + oy,
      @raylib.Color::new(196, 224, 244, alpha),
    )
  }
}

///|
fn survivor_color(s : Survivor) -> @raylib.Color {
  if s.panic > 2.6 {
    @raylib.Color::new(255, 164, 146, 246)
  } else if s.panic > 1.2 {
    @raylib.Color::new(246, 206, 146, 246)
  } else {
    @raylib.Color::new(164, 224, 252, 246)
  }
}

///|
fn draw_survivor(s : Survivor, ox : Int, oy : Int) -> Unit {
  if not(s.active) {
    return
  }

  let x : Int = s.x.to_int() + ox
  let y : Int = s.y.to_int() + oy

  let c0 : @raylib.Color = survivor_color(s)

  @raylib.draw_circle(x, y, survivor_r, c0)
  @raylib.draw_circle(x, y - 6, 6.0, @raylib.Color::new(30, 42, 56, 220))

  let a : Float = s.phase
  let px : Int = (s.x + cosf(a) * 16.0).to_int() + ox
  let py : Int = (s.y + sinf(a) * 16.0).to_int() + oy
  @raylib.draw_circle(px, py, 2.0, @raylib.Color::new(246, 252, 255, 200))

  if s.carried {
    @raylib.draw_circle_lines(
      x,
      y,
      survivor_r + 4.0,
      @raylib.Color::new(220, 246, 255, 220),
    )
  }
}

///|
fn hazard_color(kind : Int) -> @raylib.Color {
  if kind == hazard_cloud {
    @raylib.Color::new(142, 166, 186, 238)
  } else if kind == hazard_drone {
    @raylib.Color::new(128, 150, 188, 246)
  } else {
    @raylib.Color::new(182, 220, 255, 244)
  }
}

///|
fn draw_hazard(h : Hazard, ox : Int, oy : Int) -> Unit {
  if not(h.active) {
    return
  }

  let x : Int = h.x.to_int() + ox
  let y : Int = h.y.to_int() + oy
  let c0 : @raylib.Color = hazard_color(h.kind)

  if h.kind == hazard_cloud {
    @raylib.draw_circle(x - 16, y + 4, h.r * 0.62, c0)
    @raylib.draw_circle(x + 12, y + 2, h.r * 0.56, c0)
    @raylib.draw_circle(x, y - 8, h.r * 0.68, c0)

    let bolt_x : Int = (h.x + sinf(h.phase * 3.0) * 12.0).to_int() + ox
    @raylib.draw_line(
      bolt_x,
      y,
      bolt_x - 8,
      y + 20,
      @raylib.Color::new(255, 236, 164, 220),
    )
    @raylib.draw_line(
      bolt_x - 8,
      y + 20,
      bolt_x + 6,
      y + 36,
      @raylib.Color::new(255, 236, 164, 220),
    )
  } else if h.kind == hazard_drone {
    @raylib.draw_circle(x, y, h.r, c0)
    @raylib.draw_circle_lines(
      x,
      y,
      h.r + 4.0,
      @raylib.Color::new(218, 236, 246, 188),
    )
    @raylib.draw_line(
      x - h.r.to_int(),
      y,
      x + h.r.to_int(),
      y,
      @raylib.Color::new(210, 224, 238, 206),
    )
    @raylib.draw_circle(x + 5, y - 5, 3.0, @raylib.Color::new(28, 40, 58, 220))
  } else {
    let r : Float = h.r
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(x),
        Float::from_int(y - r.to_int() - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(x - r.to_int() - 5),
        Float::from_int(y + r.to_int() + 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + r.to_int() + 5),
        Float::from_int(y + r.to_int() + 4),
      ),
      c0,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(
        Float::from_int(x),
        Float::from_int(y - r.to_int() - 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(x - r.to_int() - 5),
        Float::from_int(y + r.to_int() + 4),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + r.to_int() + 5),
        Float::from_int(y + r.to_int() + 4),
      ),
      @raylib.Color::new(232, 246, 255, 196),
    )
  }
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_fuel {
    @raylib.Color::new(255, 194, 108, 244)
  } else if kind == pickup_medkit {
    @raylib.Color::new(255, 132, 162, 244)
  } else {
    @raylib.Color::new(202, 156, 255, 244)
  }
}

///|
fn draw_pickup(p : Pickup, ox : Int, oy : Int) -> Unit {
  if not(p.active) {
    return
  }

  let x : Int = p.x.to_int() + ox
  let y : Int = p.y.to_int() + oy

  let pulse : Float = sinf(p.phase * 2.5)
  let rr : Float = 16.0 + pulse * 1.6

  let c0 : @raylib.Color = pickup_color(p.kind)

  @raylib.draw_circle(x, y, rr, c0)
  @raylib.draw_circle_lines(
    x,
    y,
    rr + 3.0,
    @raylib.Color::new(246, 252, 255, 210),
  )

  if p.kind == pickup_fuel {
    @raylib.draw_rectangle(
      x - 5,
      y - 8,
      10,
      16,
      @raylib.Color::new(62, 40, 22, 230),
    )
  } else if p.kind == pickup_medkit {
    @raylib.draw_line(
      x - 6,
      y,
      x + 6,
      y,
      @raylib.Color::new(250, 248, 248, 240),
    )
    @raylib.draw_line(
      x,
      y - 6,
      x,
      y + 6,
      @raylib.Color::new(250, 248, 248, 240),
    )
  } else {
    @raylib.draw_circle_lines(
      x,
      y,
      rr - 4.0,
      @raylib.Color::new(236, 212, 255, 216),
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
      184
    } else {
      108
    }

    let c0 : @raylib.Color = if game.particles[i].kind == 2 {
      @raylib.Color::new(206, 174, 255, a)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(255, 162, 164, a)
    } else {
      @raylib.Color::new(174, 234, 255, a)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int() + ox,
      game.particles[i].y.to_int() + oy,
      game.particles[i].size,
      c0,
    )
  }
}

///|
fn draw_heli(game : Game, ox : Int, oy : Int) -> Unit {
  let x : Int = game.heli_x.to_int() + ox
  let y : Int = game.heli_y.to_int() + oy

  let tilt : Float = clampf(game.heli_vx * 0.0013, -0.45, 0.45)

  @raylib.draw_circle(x, y, heli_r + 2.0, @raylib.Color::new(86, 128, 156, 248))
  @raylib.draw_circle(
    x,
    y,
    heli_r - 6.0,
    @raylib.Color::new(194, 216, 232, 248),
  )

  @raylib.draw_rectangle(
    x - 34,
    y + 18,
    68,
    8,
    @raylib.Color::new(62, 92, 118, 238),
  )

  @raylib.draw_line(
    x - 42,
    y - 28,
    x + 42,
    y - 28,
    @raylib.Color::new(220, 238, 246, 220),
  )
  @raylib.draw_line(
    x,
    y - 34,
    x,
    y - 16,
    @raylib.Color::new(220, 238, 246, 220),
  )

  @raylib.draw_circle(
    (Float::from_int(x) + tilt * 12.0).to_int(),
    y - 6,
    4.0,
    @raylib.Color::new(20, 34, 48, 220),
  )

  if game.boost_on || game.turbo_t > 0.0 {
    @raylib.draw_circle(
      x,
      y + 18,
      8.0 + sinf(game.ui_t * 9.0) * 2.0,
      @raylib.Color::new(118, 236, 255, 178),
    )
  }

  let tip_x : Int = hook_tip_x(game).to_int() + ox
  let tip_y : Int = hook_tip_y(game).to_int() + oy

  @raylib.draw_line(
    x,
    y + 4,
    tip_x,
    tip_y,
    @raylib.Color::new(238, 246, 252, 204),
  )
  @raylib.draw_circle(tip_x, tip_y, 7.0, @raylib.Color::new(232, 242, 250, 236))
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
    100 + (game.hint_t * 110.0).to_int()
  }

  @raylib.draw_circle_lines(
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    30.0 + pulse * 4.0,
    @raylib.Color::new(255, 234, 132, alpha),
  )
  @raylib.draw_line(
    game.heli_x.to_int() + ox,
    game.heli_y.to_int() + oy,
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    @raylib.Color::new(255, 234, 132, alpha / 2),
  )
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fill : @raylib.Color,
  back : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, back)

  let rr : Float = clampf(ratio, 0.0, 1.0)
  let fw : Int = (Float::from_int(w) * rr).to_int()
  if fw > 0 {
    @raylib.draw_rectangle(x, y, fw, h, fill)
  }

  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(220, 236, 246, 186),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(14, 22, 36, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(160, 202, 232, 204),
  )

  @raylib.draw_text(
    "SKYHOOK CARGO",
    panel_x0 + 24,
    34,
    34,
    @raylib.Color::new(234, 248, 255, 246),
  )
  @raylib.draw_text(
    "RESCUE 2026",
    panel_x0 + 24,
    72,
    26,
    @raylib.Color::new(176, 208, 230, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 24,
    128,
    30,
    @raylib.Color::new(238, 246, 255, 244),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 24,
    164,
    24,
    @raylib.Color::new(198, 226, 244, 236),
  )

  @raylib.draw_text(
    "Rescued " + game.rescued.to_string() + " / " + rescue_target.to_string(),
    panel_x0 + 24,
    200,
    24,
    @raylib.Color::new(214, 236, 248, 236),
  )
  @raylib.draw_text(
    "Lost " + game.lost.to_string(),
    panel_x0 + 260,
    200,
    24,
    @raylib.Color::new(255, 196, 196, 236),
  )

  @raylib.draw_text(
    "Wave " + game.wave.to_string(),
    panel_x0 + 24,
    236,
    24,
    @raylib.Color::new(198, 226, 244, 228),
  )
  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 160,
    236,
    24,
    @raylib.Color::new(255, 214, 220, 240),
  )

  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    panel_x0 + 260,
    236,
    24,
    if game.combo >= 4 {
      @raylib.Color::new(255, 234, 136, 246)
    } else {
      @raylib.Color::new(194, 224, 238, 228)
    },
  )

  @raylib.draw_text(
    "Hull",
    panel_x0 + 24,
    284,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    312,
    panel_w - 48,
    18,
    game.hull / 100.0,
    @raylib.Color::new(255, 144, 168, 242),
    @raylib.Color::new(64, 36, 44, 220),
  )

  @raylib.draw_text(
    "Fuel",
    panel_x0 + 24,
    342,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    370,
    panel_w - 48,
    18,
    game.fuel / 100.0,
    @raylib.Color::new(255, 194, 108, 242),
    @raylib.Color::new(70, 52, 28, 220),
  )

  @raylib.draw_text(
    "Mission time",
    panel_x0 + 24,
    400,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    428,
    panel_w - 48,
    18,
    game.game_t / run_time_goal,
    @raylib.Color::new(154, 236, 178, 242),
    @raylib.Color::new(34, 64, 44, 220),
  )

  @raylib.draw_text(
    "Turbo " + game.turbo_t.to_int().to_string() + "s",
    panel_x0 + 24,
    462,
    24,
    @raylib.Color::new(212, 184, 252, 236),
  )
  @raylib.draw_text(
    "Hook " + game.hook_len.to_int().to_string() + " m",
    panel_x0 + 184,
    462,
    24,
    @raylib.Color::new(206, 230, 246, 236),
  )

  @raylib.draw_text(
    "Hints left " + game.hint_left.to_string(),
    panel_x0 + 24,
    498,
    22,
    @raylib.Color::new(206, 230, 246, 224),
  )

  @raylib.draw_text(
    "Desktop: WASD move, Space hook",
    panel_x0 + 24,
    556,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Shift boost, E repair, H hint",
    panel_x0 + 24,
    582,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Mobile: right-side touch controls",
    panel_x0 + 24,
    608,
    20,
    @raylib.Color::new(172, 206, 226, 216),
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
  c_idle : @raylib.Color,
  c_on : @raylib.Color,
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

  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if on {
      c_on
    } else {
      c_idle
    },
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(220, 236, 248, 190),
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
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_right(),
    "R",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_up(),
    "U",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_down(),
    "D",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hook(),
    "HOOK",
    @raylib.Color::new(90, 104, 152, 182),
    @raylib.Color::new(142, 166, 236, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_boost(),
    "BST",
    if game.boost_on || game.turbo_t > 0.0 {
      @raylib.Color::new(102, 166, 222, 220)
    } else {
      @raylib.Color::new(70, 120, 168, 182)
    },
    @raylib.Color::new(120, 184, 240, 230),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hint(),
    "HNT",
    @raylib.Color::new(90, 96, 134, 182),
    @raylib.Color::new(152, 170, 224, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_restart(),
    "RST",
    @raylib.Color::new(102, 88, 124, 182),
    @raylib.Color::new(170, 136, 194, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_repair(),
    "RPR",
    @raylib.Color::new(88, 102, 128, 182),
    @raylib.Color::new(150, 178, 214, 220),
  )
}

///|
fn draw_msg(game : Game) -> Unit {
  if game.msg_t <= 0.0 || game.msg == "" {
    return
  }

  let a : Int = if game.msg_t > 1.0 {
    228
  } else {
    90 + (game.msg_t * 136.0).to_int()
  }

  let w : Int = @raylib.measure_text(game.msg, 28) + 38
  let x : Int = world_x0 + (world_w - w) / 2
  let y : Int = world_y0 + 18

  @raylib.draw_rectangle(x, y, w, 46, @raylib.Color::new(22, 34, 52, a))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    46,
    @raylib.Color::new(198, 228, 246, mini(250, a + 12)),
  )
  @raylib.draw_text(
    game.msg,
    x + 18,
    y + 10,
    28,
    @raylib.Color::new(236, 246, 252, mini(255, a + 20)),
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
    @raylib.Color::new(8, 12, 20, 168),
  )

  let h0 : String = "SKYHOOK CARGO RESCUE"
  let h1 : String = "Lift civilians through storm corridors"
  let h2 : String = "Rescue 18 before mission timer runs out"

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 72) / 2,
    178,
    72,
    @raylib.Color::new(232, 246, 255, 246),
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    272,
    32,
    @raylib.Color::new(186, 214, 236, 238),
  )
  @raylib.draw_text(
    h2,
    screen_w / 2 - @raylib.measure_text(h2, 28) / 2,
    322,
    28,
    @raylib.Color::new(184, 212, 232, 228),
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
      @raylib.Color::new(82, 154, 214, 236)
    } else {
      @raylib.Color::new(56, 126, 186, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 242, 255, 230),
  )

  let txt : String = "START SORTIE"
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - @raylib.measure_text(txt, 46)) / 2,
    b.1 + 34,
    46,
    @raylib.Color::new(244, 250, 255, 248),
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
    @raylib.Color::new(8, 10, 18, 176),
  )

  let h0 : String = if game.win { "RESCUE COMPLETE" } else { "MISSION FAILED" }
  let h1 : String = if game.win {
    "Extraction corridor secured."
  } else {
    "Storm corridor collapsed."
  }

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 74) / 2,
    182,
    74,
    if game.win {
      @raylib.Color::new(178, 246, 198, 246)
    } else {
      @raylib.Color::new(255, 186, 176, 246)
    },
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    276,
    32,
    @raylib.Color::new(208, 228, 242, 236),
  )

  let l0 : String = "Rescued " +
    game.rescued.to_string() +
    " / " +
    rescue_target.to_string()
  let l1 : String = "Lost " + game.lost.to_string()
  let l2 : String = "Score " +
    game.score.to_string() +
    "   Best " +
    game.best_score.to_string()
  let l3 : String = "Time " +
    game.game_t.to_int().to_string() +
    " / " +
    run_time_goal.to_int().to_string() +
    " s"

  @raylib.draw_text(
    l0,
    screen_w / 2 - @raylib.measure_text(l0, 38) / 2,
    352,
    38,
    @raylib.Color::new(238, 246, 252, 244),
  )
  @raylib.draw_text(
    l1,
    screen_w / 2 - @raylib.measure_text(l1, 34) / 2,
    398,
    34,
    @raylib.Color::new(206, 230, 244, 238),
  )
  @raylib.draw_text(
    l2,
    screen_w / 2 - @raylib.measure_text(l2, 34) / 2,
    440,
    34,
    @raylib.Color::new(206, 230, 244, 238),
  )
  @raylib.draw_text(
    l3,
    screen_w / 2 - @raylib.measure_text(l3, 32) / 2,
    482,
    32,
    @raylib.Color::new(206, 230, 244, 238),
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
      @raylib.Color::new(76, 152, 214, 236)
    } else {
      @raylib.Color::new(52, 122, 180, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 242, 255, 228),
  )

  let txt : String = "FLY AGAIN"
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - @raylib.measure_text(txt, 42)) / 2,
    b.1 + 32,
    42,
    @raylib.Color::new(242, 248, 255, 248),
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

  let ox : Int = shake_x(game)
  let oy : Int = shake_y(game)

  draw_world_back(game, ox, oy)
  draw_storm(game, ox, oy)
  draw_safe_zone(game, ox, oy)

  for i = 0; i < game.hazards.length(); i = i + 1 {
    draw_hazard(game.hazards[i], ox, oy)
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i], ox, oy)
  }

  for i = 0; i < game.survivors.length(); i = i + 1 {
    draw_survivor(game.survivors[i], ox, oy)
  }

  draw_hint(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_heli(game, ox, oy)

  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_msg(game)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
