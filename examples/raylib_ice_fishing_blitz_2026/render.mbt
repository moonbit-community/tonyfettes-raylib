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
  @raylib.clear_background(@raylib.Color::new(9, 18, 30, 255))

  let w0 : Float = bg_wave(game, 0.42)
  let w1 : Float = bg_wave(game, 0.84)

  @raylib.draw_circle(
    200,
    120,
    240.0 + w0 * 22.0,
    @raylib.Color::new(28, 64, 94, 30),
  )
  @raylib.draw_circle(
    760,
    160,
    300.0 - w1 * 26.0,
    @raylib.Color::new(24, 58, 88, 30),
  )
  @raylib.draw_circle(
    screen_w - 300,
    200,
    320.0 + w1 * 22.0,
    @raylib.Color::new(36, 54, 86, 32),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 64
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      40,
      @raylib.Color::new(
        8 + i * 2 % 12,
        15 + i * 3 % 17,
        24 + i * 4 % 20,
        12 + i * 2 % 18,
      ),
    )
  }
}

///|
fn draw_world_back(game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    world_x0 + ox,
    water_top + oy,
    world_w,
    water_bottom - water_top,
    @raylib.Color::new(20, 56, 82, 236),
  )

  @raylib.draw_rectangle(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    water_top - world_y0,
    @raylib.Color::new(200, 226, 240, 238),
  )

  @raylib.draw_rectangle_lines(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(172, 206, 230, 206),
  )

  for i = 0; i < 18; i = i + 1 {
    let y : Int = water_top + oy + i * 42
    let shift : Int = (bg_wave(game, 1.1 + Float::from_int(i) * 0.07) * 20.0).to_int()

    @raylib.draw_line(
      world_x0 + ox + 12,
      y,
      world_x0 + ox + world_w - 12 + shift,
      y,
      @raylib.Color::new(86, 132, 168, 46),
    )
  }

  for i = 0; i < 24; i = i + 1 {
    let x : Int = world_x0 + ox + i * 48
    @raylib.draw_line(
      x,
      water_top + oy + 6,
      x,
      world_y0 + oy + world_h - 8,
      @raylib.Color::new(70, 110, 140, 24),
    )
  }

  let crack_wobble : Int = (bg_wave(game, 1.9) * 8.0).to_int()

  for i = 0; i < 9; i = i + 1 {
    let sx : Int = world_x0 + 120 + i * 108 + crack_wobble
    let sy : Int = water_top - 14 + oy + @raylib.get_random_value(-3, 3)
    @raylib.draw_line(
      sx + ox,
      sy,
      sx + 44 + ox,
      sy + @raylib.get_random_value(-8, 8),
      @raylib.Color::new(168, 194, 210, 140),
    )
  }

  @raylib.draw_circle(
    hole_x + ox,
    hole_y + oy,
    40.0,
    @raylib.Color::new(28, 56, 86, 246),
  )
  @raylib.draw_circle_lines(
    hole_x + ox,
    hole_y + oy,
    44.0,
    @raylib.Color::new(228, 246, 255, 220),
  )

  @raylib.draw_rectangle(
    catch_zone_x() + ox,
    catch_zone_y() + oy,
    catch_zone_w(),
    catch_zone_h(),
    @raylib.Color::new(82, 128, 162, 120),
  )
  @raylib.draw_rectangle_lines(
    catch_zone_x() + ox,
    catch_zone_y() + oy,
    catch_zone_w(),
    catch_zone_h(),
    @raylib.Color::new(222, 242, 255, 206),
  )

  @raylib.draw_text(
    "CATCH ZONE",
    catch_zone_x() + 52 + ox,
    catch_zone_y() + 20 + oy,
    22,
    @raylib.Color::new(234, 246, 255, 220),
  )
}

///|
fn fish_color(kind : Int) -> @raylib.Color {
  if kind == fish_trout {
    @raylib.Color::new(154, 224, 252, 244)
  } else if kind == fish_salmon {
    @raylib.Color::new(255, 178, 144, 244)
  } else {
    @raylib.Color::new(244, 216, 120, 246)
  }
}

///|
fn draw_fish(f : Fish, ox : Int, oy : Int) -> Unit {
  if not(f.active) {
    return
  }

  let x : Int = f.x.to_int() + ox
  let y : Int = f.y.to_int() + oy

  let c0 : @raylib.Color = fish_color(f.kind)

  @raylib.draw_ellipse(x, y, f.r + 4.0, f.r * 0.68, c0)

  let dir : Int = if f.vx >= 0.0 { 1 } else { -1 }

  @raylib.draw_triangle(
    @raylib.Vector2::new(
      Float::from_int(x - dir * (f.r.to_int() + 4)),
      Float::from_int(y),
    ),
    @raylib.Vector2::new(
      Float::from_int(x - dir * (f.r.to_int() + 14)),
      Float::from_int(y - 10),
    ),
    @raylib.Vector2::new(
      Float::from_int(x - dir * (f.r.to_int() + 14)),
      Float::from_int(y + 10),
    ),
    @raylib.Color::new(
      mini(255, c0.r.to_int() + 18),
      mini(255, c0.g.to_int() + 18),
      mini(255, c0.b.to_int() + 18),
      230,
    ),
  )

  @raylib.draw_circle(
    x + dir * 5,
    y - 2,
    3.0,
    @raylib.Color::new(24, 36, 52, 220),
  )

  if f.hooked {
    @raylib.draw_circle_lines(
      x,
      y,
      f.r + 6.0,
      @raylib.Color::new(220, 246, 255, 220),
    )
  }
}

///|
fn hazard_color(kind : Int) -> @raylib.Color {
  if kind == hazard_jelly {
    @raylib.Color::new(186, 168, 224, 234)
  } else if kind == hazard_eel {
    @raylib.Color::new(132, 210, 196, 242)
  } else {
    @raylib.Color::new(206, 236, 255, 246)
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

  if h.kind == hazard_jelly {
    @raylib.draw_circle(x, y, h.r, c0)

    for k = 0; k < 5; k = k + 1 {
      let px : Int = x - h.r.to_int() + 8 + k * 8
      @raylib.draw_line(
        px,
        y + h.r.to_int() - 2,
        px + @raylib.get_random_value(-6, 6),
        y + h.r.to_int() + 18,
        @raylib.Color::new(216, 204, 238, 188),
      )
    }
  } else if h.kind == hazard_eel {
    @raylib.draw_ellipse(x, y, h.r + 10.0, h.r * 0.54, c0)
    @raylib.draw_circle(x + 8, y - 2, 3.0, @raylib.Color::new(18, 32, 44, 220))
    @raylib.draw_circle(x - 10, y, 2.0, @raylib.Color::new(216, 246, 255, 200))
  } else {
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(x),
        Float::from_int(y - h.r.to_int() - 6),
      ),
      @raylib.Vector2::new(
        Float::from_int(x - h.r.to_int() - 5),
        Float::from_int(y + h.r.to_int() + 5),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + h.r.to_int() + 5),
        Float::from_int(y + h.r.to_int() + 5),
      ),
      c0,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(
        Float::from_int(x),
        Float::from_int(y - h.r.to_int() - 6),
      ),
      @raylib.Vector2::new(
        Float::from_int(x - h.r.to_int() - 5),
        Float::from_int(y + h.r.to_int() + 5),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + h.r.to_int() + 5),
        Float::from_int(y + h.r.to_int() + 5),
      ),
      @raylib.Color::new(232, 246, 255, 196),
    )
  }
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_bait {
    @raylib.Color::new(255, 200, 116, 244)
  } else if kind == pickup_repair {
    @raylib.Color::new(255, 138, 162, 244)
  } else {
    @raylib.Color::new(206, 162, 255, 244)
  }
}

///|
fn draw_pickup(p : Pickup, ox : Int, oy : Int) -> Unit {
  if not(p.active) {
    return
  }

  let x : Int = p.x.to_int() + ox
  let y : Int = p.y.to_int() + oy
  let pulse : Float = sinf(p.phase * 2.6)
  let rr : Float = 15.0 + pulse * 1.6

  let c0 : @raylib.Color = pickup_color(p.kind)

  @raylib.draw_circle(x, y, rr, c0)
  @raylib.draw_circle_lines(
    x,
    y,
    rr + 3.0,
    @raylib.Color::new(246, 252, 255, 210),
  )

  if p.kind == pickup_bait {
    @raylib.draw_rectangle(
      x - 5,
      y - 8,
      10,
      16,
      @raylib.Color::new(58, 36, 20, 230),
    )
  } else if p.kind == pickup_repair {
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
      @raylib.Color::new(236, 214, 255, 220),
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
      @raylib.Color::new(255, 162, 162, a)
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
fn draw_hook(game : Game, ox : Int, oy : Int) -> Unit {
  let hx : Int = game.hook_x.to_int() + ox
  let hy : Int = game.hook_y.to_int() + oy

  let line_a : Int = if game.grab_on { 240 } else { 190 }

  @raylib.draw_line(
    hole_x + ox,
    hole_y + 10 + oy,
    hx,
    hy,
    @raylib.Color::new(236, 246, 255, line_a),
  )

  @raylib.draw_circle(
    hx,
    hy,
    hook_r,
    if game.grab_on {
      @raylib.Color::new(238, 214, 146, 244)
    } else {
      @raylib.Color::new(214, 230, 242, 236)
    },
  )

  @raylib.draw_circle_lines(
    hx,
    hy,
    hook_r + 4.0,
    @raylib.Color::new(246, 252, 255, 216),
  )

  @raylib.draw_line(
    hx,
    hy + 2,
    hx - 8,
    hy + 14,
    @raylib.Color::new(248, 252, 255, 230),
  )
  @raylib.draw_line(
    hx,
    hy + 2,
    hx + 8,
    hy + 14,
    @raylib.Color::new(248, 252, 255, 230),
  )

  if game.boost_on || game.turbo_t > 0.0 {
    @raylib.draw_circle(
      hx,
      hy,
      hook_r + 8.0 + sinf(game.ui_t * 9.0) * 2.0,
      @raylib.Color::new(126, 234, 255, 98),
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
    100 + (game.hint_t * 110.0).to_int()
  }

  @raylib.draw_circle_lines(
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    30.0 + pulse * 4.0,
    @raylib.Color::new(255, 234, 132, alpha),
  )
  @raylib.draw_line(
    game.hook_x.to_int() + ox,
    game.hook_y.to_int() + oy,
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
    "ICE FISHING BLITZ",
    panel_x0 + 24,
    34,
    34,
    @raylib.Color::new(234, 248, 255, 246),
  )
  @raylib.draw_text(
    "2026 CHALLENGE",
    panel_x0 + 24,
    72,
    26,
    @raylib.Color::new(176, 208, 230, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string() + " / " + score_goal.to_string(),
    panel_x0 + 24,
    126,
    30,
    @raylib.Color::new(238, 246, 255, 244),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 24,
    162,
    24,
    @raylib.Color::new(198, 226, 244, 236),
  )

  @raylib.draw_text(
    "Caught " + game.caught.to_string(),
    panel_x0 + 24,
    198,
    24,
    @raylib.Color::new(214, 236, 248, 236),
  )
  @raylib.draw_text(
    "Escaped " + game.escaped.to_string(),
    panel_x0 + 170,
    198,
    24,
    @raylib.Color::new(255, 196, 196, 236),
  )
  @raylib.draw_text(
    "Wave " + game.wave.to_string(),
    panel_x0 + 320,
    198,
    24,
    @raylib.Color::new(198, 226, 244, 228),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 24,
    232,
    24,
    @raylib.Color::new(255, 214, 220, 240),
  )
  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    panel_x0 + 170,
    232,
    24,
    if game.combo >= 4 {
      @raylib.Color::new(255, 234, 136, 246)
    } else {
      @raylib.Color::new(194, 224, 238, 228)
    },
  )

  @raylib.draw_text(
    "Line HP",
    panel_x0 + 24,
    282,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    310,
    panel_w - 48,
    18,
    game.line_hp / 100.0,
    @raylib.Color::new(255, 142, 166, 242),
    @raylib.Color::new(64, 36, 44, 220),
  )

  @raylib.draw_text(
    "Bait Energy",
    panel_x0 + 24,
    340,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    368,
    panel_w - 48,
    18,
    game.bait / 100.0,
    @raylib.Color::new(255, 196, 108, 242),
    @raylib.Color::new(70, 52, 28, 220),
  )

  @raylib.draw_text(
    "Time",
    panel_x0 + 24,
    398,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    426,
    panel_w - 48,
    18,
    game.game_t / run_time_goal,
    @raylib.Color::new(154, 236, 178, 242),
    @raylib.Color::new(34, 64, 44, 220),
  )

  @raylib.draw_text(
    "Turbo " + game.turbo_t.to_int().to_string() + "s",
    panel_x0 + 24,
    460,
    24,
    @raylib.Color::new(212, 184, 252, 236),
  )
  @raylib.draw_text(
    "Line " + game.line_len.to_int().to_string() + "m",
    panel_x0 + 170,
    460,
    24,
    @raylib.Color::new(206, 230, 246, 236),
  )

  @raylib.draw_text(
    "Hints left " + game.hint_left.to_string(),
    panel_x0 + 24,
    496,
    22,
    @raylib.Color::new(206, 230, 246, 224),
  )

  @raylib.draw_text(
    "Desktop: WASD move hook, Space clamp",
    panel_x0 + 24,
    554,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Shift boost, E repair, H hint",
    panel_x0 + 24,
    580,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Mobile: right-side touch controls",
    panel_x0 + 24,
    606,
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
    if game.grab_on {
      @raylib.Color::new(140, 128, 84, 214)
    } else {
      @raylib.Color::new(90, 104, 152, 182)
    },
    @raylib.Color::new(166, 154, 112, 230),
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
  let y : Int = world_y0 + 16

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

  let h0 : String = "ICE FISHING BLITZ"
  let h1 : String = "Hook fish from deep water and score big"
  let h2 : String = "Use clamp, avoid hazards, hit 1600 points"

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 78) / 2,
    176,
    78,
    @raylib.Color::new(232, 246, 255, 246),
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    276,
    32,
    @raylib.Color::new(186, 214, 236, 238),
  )
  @raylib.draw_text(
    h2,
    screen_w / 2 - @raylib.measure_text(h2, 28) / 2,
    324,
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

  let txt : String = "START FISHING"
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

  let h0 : String = if game.win { "TROPHY HAUL" } else { "BLIZZARD LOSS" }
  let h1 : String = if game.win {
    "You dominated the ice fishing league."
  } else {
    "The line failed before target score."
  }

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 76) / 2,
    182,
    76,
    if game.win {
      @raylib.Color::new(178, 246, 198, 246)
    } else {
      @raylib.Color::new(255, 186, 176, 246)
    },
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    278,
    32,
    @raylib.Color::new(208, 228, 242, 236),
  )

  let l0 : String = "Score " +
    game.score.to_string() +
    " / " +
    score_goal.to_string()
  let l1 : String = "Caught " +
    game.caught.to_string() +
    "   Escaped " +
    game.escaped.to_string()
  let l2 : String = "Best " + game.best_score.to_string()
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

  let txt : String = "PLAY AGAIN"
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

  for i = 0; i < game.fish.length(); i = i + 1 {
    draw_fish(game.fish[i], ox, oy)
  }

  for i = 0; i < game.hazards.length(); i = i + 1 {
    draw_hazard(game.hazards[i], ox, oy)
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i], ox, oy)
  }

  draw_hint(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_hook(game, ox, oy)

  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_msg(game)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
