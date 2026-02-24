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
  @raylib.clear_background(@raylib.Color::new(14, 22, 34, 255))

  let w0 : Float = bg_wave(game, 0.44)
  let w1 : Float = bg_wave(game, 0.88)

  @raylib.draw_circle(
    200,
    130,
    230.0 + w0 * 18.0,
    @raylib.Color::new(40, 70, 100, 30),
  )
  @raylib.draw_circle(
    720,
    150,
    280.0 - w1 * 24.0,
    @raylib.Color::new(38, 66, 96, 30),
  )
  @raylib.draw_circle(
    screen_w - 320,
    180,
    300.0 + w1 * 18.0,
    @raylib.Color::new(48, 60, 96, 32),
  )
}

///|
fn draw_world_back(game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(52, 64, 74, 236),
  )

  @raylib.draw_rectangle_lines(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(176, 206, 226, 206),
  )

  for i = 0; i <= world_w / road_step; i = i + 1 {
    let x : Int = world_x0 + ox + i * road_step
    @raylib.draw_rectangle(
      x - 22,
      world_y0 + oy,
      44,
      world_h,
      @raylib.Color::new(62, 76, 88, 236),
    )

    for j = 0; j < world_h / 52; j = j + 1 {
      @raylib.draw_rectangle(
        x - 2,
        world_y0 + oy + j * 52 + 10,
        4,
        24,
        @raylib.Color::new(236, 232, 188, 120),
      )
    }
  }

  for i = 0; i <= world_h / road_step; i = i + 1 {
    let y : Int = world_y0 + oy + i * road_step
    @raylib.draw_rectangle(
      world_x0 + ox,
      y - 22,
      world_w,
      44,
      @raylib.Color::new(62, 76, 88, 236),
    )

    for j = 0; j < world_w / 52; j = j + 1 {
      @raylib.draw_rectangle(
        world_x0 + ox + j * 52 + 10,
        y - 2,
        24,
        4,
        @raylib.Color::new(236, 232, 188, 120),
      )
    }
  }

  for i = 0; i < 3; i = i + 1 {
    let rx : Int = restaurant_x(i).to_int() - 42 + ox
    let ry : Int = restaurant_y(i).to_int() - 36 + oy

    @raylib.draw_rectangle(rx, ry, 84, 72, @raylib.Color::new(168, 86, 64, 236))
    @raylib.draw_rectangle_lines(
      rx,
      ry,
      84,
      72,
      @raylib.Color::new(246, 218, 186, 220),
    )

    @raylib.draw_text(
      "P" + (i + 1).to_string(),
      rx + 28,
      ry + 20,
      30,
      @raylib.Color::new(252, 240, 226, 242),
    )
  }

  let depx : Int = depot_x().to_int() + ox
  let depy : Int = depot_y().to_int() + oy

  @raylib.draw_rectangle(
    depx - depot_w() / 2,
    depy - depot_h() / 2,
    depot_w(),
    depot_h(),
    @raylib.Color::new(86, 124, 150, 170),
  )
  @raylib.draw_rectangle_lines(
    depx - depot_w() / 2,
    depy - depot_h() / 2,
    depot_w(),
    depot_h(),
    @raylib.Color::new(222, 242, 255, 220),
  )

  @raylib.draw_text(
    "DEPOT",
    depx - 40,
    depy - 10,
    24,
    @raylib.Color::new(236, 248, 255, 240),
  )

  let city_flash : Int = (bg_wave(game, 2.1) * 16.0).to_int()
  @raylib.draw_circle(
    depx + 44,
    depy - 34,
    6.0,
    @raylib.Color::new(190 + city_flash, 230, 255, 200),
  )
}

///|
fn traffic_color(kind : Int) -> @raylib.Color {
  if kind == traffic_sedan {
    @raylib.Color::new(204, 112, 104, 244)
  } else if kind == traffic_van {
    @raylib.Color::new(128, 166, 216, 244)
  } else {
    @raylib.Color::new(212, 184, 118, 244)
  }
}

///|
fn draw_traffic(t : Traffic, ox : Int, oy : Int) -> Unit {
  if not(t.active) {
    return
  }

  let x : Int = (t.x - t.w * 0.5).to_int() + ox
  let y : Int = (t.y - t.h * 0.5).to_int() + oy

  let c0 : @raylib.Color = traffic_color(t.kind)

  @raylib.draw_rectangle(x, y, t.w.to_int(), t.h.to_int(), c0)
  @raylib.draw_rectangle_lines(
    x,
    y,
    t.w.to_int(),
    t.h.to_int(),
    @raylib.Color::new(238, 246, 252, 188),
  )

  @raylib.draw_circle(
    x + t.w.to_int() / 2,
    y + t.h.to_int() / 2,
    4.0,
    @raylib.Color::new(30, 40, 56, 220),
  )
}

///|
fn draw_order(o : Order, highlight : Bool, ox : Int, oy : Int) -> Unit {
  if not(o.active) {
    return
  }

  let src_x : Int = o.x_from.to_int() + ox
  let src_y : Int = o.y_from.to_int() + oy
  let dst_x : Int = o.x_to.to_int() + ox
  let dst_y : Int = o.y_to.to_int() + oy

  @raylib.draw_line(
    src_x,
    src_y,
    dst_x,
    dst_y,
    @raylib.Color::new(216, 238, 250, if highlight { 180 } else { 90 }),
  )

  if not(o.picked) {
    @raylib.draw_circle(
      src_x,
      src_y,
      18.0,
      if highlight {
        @raylib.Color::new(255, 188, 132, 240)
      } else {
        @raylib.Color::new(236, 168, 120, 200)
      },
    )
    @raylib.draw_text(
      "PK",
      src_x - 16,
      src_y - 10,
      20,
      @raylib.Color::new(34, 30, 20, 220),
    )
  } else {
    @raylib.draw_circle(
      dst_x,
      dst_y,
      20.0,
      if highlight {
        @raylib.Color::new(146, 224, 164, 240)
      } else {
        @raylib.Color::new(130, 202, 148, 200)
      },
    )
    @raylib.draw_text(
      "DL",
      dst_x - 16,
      dst_y - 10,
      20,
      @raylib.Color::new(24, 40, 26, 220),
    )
  }
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_fuel {
    @raylib.Color::new(255, 198, 110, 244)
  } else if kind == pickup_repair {
    @raylib.Color::new(255, 138, 164, 244)
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

  let pulse : Float = sinf(p.phase * 2.4)
  let rr : Float = 15.0 + pulse * 1.6

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
      @raylib.Color::new(255, 164, 164, a)
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
fn draw_rider(game : Game, ox : Int, oy : Int) -> Unit {
  let x : Int = game.rider_x.to_int() + ox
  let y : Int = game.rider_y.to_int() + oy

  let tilt : Float = clampf(game.rider_vx * 0.0014, -0.45, 0.45)

  @raylib.draw_circle(
    x,
    y,
    rider_r + 2.0,
    @raylib.Color::new(106, 174, 214, 248),
  )
  @raylib.draw_circle(
    x,
    y,
    rider_r - 6.0,
    @raylib.Color::new(220, 240, 252, 246),
  )

  @raylib.draw_rectangle(
    x - 18,
    y + 12,
    36,
    8,
    @raylib.Color::new(82, 112, 140, 240),
  )

  @raylib.draw_circle(
    (Float::from_int(x) + tilt * 10.0).to_int(),
    y - 6,
    4.0,
    @raylib.Color::new(24, 34, 46, 220),
  )

  if game.boost_on || game.turbo_t > 0.0 {
    @raylib.draw_circle(
      x,
      y + 14,
      8.0 + sinf(game.ui_t * 9.0) * 2.0,
      @raylib.Color::new(118, 236, 255, 178),
    )
  }

  if game.cargo_idx >= 0 {
    @raylib.draw_rectangle(
      x + 12,
      y - 18,
      16,
      16,
      @raylib.Color::new(232, 176, 106, 240),
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
    game.rider_x.to_int() + ox,
    game.rider_y.to_int() + oy,
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
    "PIZZA DELIVERY",
    panel_x0 + 24,
    34,
    34,
    @raylib.Color::new(234, 248, 255, 246),
  )
  @raylib.draw_text(
    "MAYHEM 2026",
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
    "Delivered " + game.delivered.to_string(),
    panel_x0 + 24,
    198,
    24,
    @raylib.Color::new(214, 236, 248, 236),
  )
  @raylib.draw_text(
    "Missed " + game.missed.to_string(),
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
    "Scooter HP",
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
    game.scooter_hp / 100.0,
    @raylib.Color::new(255, 142, 166, 242),
    @raylib.Color::new(64, 36, 44, 220),
  )

  @raylib.draw_text(
    "Fuel",
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
    game.fuel / 100.0,
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
    "Cargo " + (if game.cargo_idx >= 0 { "ON" } else { "OFF" }),
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
    "Desktop: WASD move, Space/E action",
    panel_x0 + 24,
    554,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Shift boost, Q repair, H hint",
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
    btn_action(),
    "ACT",
    if game.action_on {
      @raylib.Color::new(160, 134, 90, 220)
    } else {
      @raylib.Color::new(100, 98, 86, 182)
    },
    @raylib.Color::new(190, 170, 120, 230),
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

  let h0 : String = "PIZZA DELIVERY MAYHEM"
  let h1 : String = "Pick up from shops and race through traffic"
  let h2 : String = "Deliver hot, keep scooter alive, hit 2200 points"

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 72) / 2,
    176,
    72,
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

  let txt : String = "START SHIFT"
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

  let h0 : String = if game.win { "SHIFT CLEARED" } else { "SHIFT FAILED" }
  let h1 : String = if game.win {
    "City fed before rush hour ended."
  } else {
    "Too many crashes and missed deliveries."
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
  let l1 : String = "Delivered " +
    game.delivered.to_string() +
    "   Missed " +
    game.missed.to_string()
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

  let txt : String = "RIDE AGAIN"
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

  for i = 0; i < game.orders.length(); i = i + 1 {
    let highlight : Bool = game.cargo_idx == i
    draw_order(game.orders[i], highlight, ox, oy)
  }

  for i = 0; i < game.traffic.length(); i = i + 1 {
    draw_traffic(game.traffic[i], ox, oy)
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i], ox, oy)
  }

  draw_hint(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_rider(game, ox, oy)

  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_msg(game)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
