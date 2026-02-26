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
    @raylib.get_random_value(-4, 4)
  }
}

///|
fn pulse(game : Game, f : Float) -> Float {
  0.5 + 0.5 * @math.sinf(game.time_s * f)
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  ratio : Float,
  bg : @raylib.Color,
  fg : @raylib.Color,
) -> Unit {
  let t = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * t).to_int(), h, fg)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(232, 240, 250, 180),
  )

  let pct = clampi((t * 100.0).to_int(), 0, 100)
  @raylib.draw_text(
    "\{label} \{pct}%",
    x + 8,
    y + 4,
    20,
    @raylib.Color::new(246, 248, 252, 240),
  )
}

///|
fn draw_background(game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.clear_background(@raylib.Color::new(14, 16, 24, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(34, 26, 44, 255),
    @raylib.Color::new(12, 16, 26, 255),
  )

  let glow_0 = 36 + (pulse(game, 0.54) * 22.0).to_int()
  let glow_1 = 36 + (pulse(game, 0.68) * 24.0).to_int()
  let glow_2 = 32 + (pulse(game, 0.82) * 28.0).to_int()

  @raylib.draw_circle(
    180 + ox,
    110 + oy,
    230.0,
    @raylib.Color::new(230, 102, 66, glow_0),
  )
  @raylib.draw_circle(
    850 + ox,
    96 + oy,
    210.0,
    @raylib.Color::new(230, 190, 72, glow_1),
  )
  @raylib.draw_circle(
    screen_w - 180 + ox,
    130 + oy,
    250.0,
    @raylib.Color::new(210, 80, 120, glow_2),
  )

  @raylib.draw_rectangle(
    street_left - 22 + ox,
    lane_top - 42 + oy,
    street_w() + 44,
    street_h() + 84,
    @raylib.Color::new(12, 14, 22, 178),
  )

  if game.flash_t > 0.0 {
    let alpha = clampi((game.flash_t * 160.0).to_int(), 0, 180)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(250, 90, 62, alpha),
    )
  }
}

///|
fn draw_lanes(game : Game, ox : Int, oy : Int) -> Unit {
  ignore(game)

  for lane = 0; lane < lane_count; lane = lane + 1 {
    let cy = lane_y(lane).to_int() + oy
    let y0 = cy - lane_height / 2

    let lane_tone = if lane % 2 == 0 {
      @raylib.Color::new(42, 50, 74, 214)
    } else {
      @raylib.Color::new(36, 44, 66, 214)
    }

    @raylib.draw_rectangle(
      street_left + ox,
      y0,
      street_w(),
      lane_height,
      lane_tone,
    )
    @raylib.draw_rectangle_lines(
      street_left + ox,
      y0,
      street_w(),
      lane_height,
      @raylib.Color::new(152, 178, 212, 110),
    )

    let mut x = street_left
    while x < street_right {
      @raylib.draw_rectangle(
        x + ox,
        cy - 2,
        30,
        4,
        @raylib.Color::new(216, 224, 242, 58),
      )
      x = x + 56
    }

    @raylib.draw_text(
      "L\{lane + 1}",
      street_left - 40 + ox,
      y0 + lane_height / 2 - 9,
      22,
      @raylib.Color::new(232, 238, 250, 170),
    )
  }

  @raylib.draw_rectangle_lines(
    street_left + ox,
    lane_top - 8 + oy,
    street_w(),
    street_h() + 16,
    @raylib.Color::new(252, 210, 122, 196),
  )
}

///|
fn draw_firecracker(threat : Threat, ox : Int, oy : Int) -> Unit {
  let cx = threat.x.to_int() + ox
  let cy = threat.y.to_int() + oy

  let core = if threat.stun_t > 0.0 {
    @raylib.Color::new(150, 192, 255, 236)
  } else {
    @raylib.Color::new(246, 116, 82, 236)
  }

  let shell = if threat.stun_t > 0.0 {
    @raylib.Color::new(102, 148, 240, 206)
  } else {
    @raylib.Color::new(184, 46, 62, 206)
  }

  @raylib.draw_circle(cx, cy, threat.radius + 4.0, shell)
  @raylib.draw_circle(cx, cy, threat.radius - 7.0, core)

  let ray = (threat.radius + 14.0 + @math.sinf(threat.spin * 2.2) * 4.0).to_int()

  @raylib.draw_line(
    cx - ray,
    cy,
    cx + ray,
    cy,
    @raylib.Color::new(254, 214, 174, 218),
  )
  @raylib.draw_line(
    cx,
    cy - ray,
    cx,
    cy + ray,
    @raylib.Color::new(254, 214, 174, 218),
  )
  @raylib.draw_line(
    cx - ray / 2,
    cy - ray / 2,
    cx + ray / 2,
    cy + ray / 2,
    @raylib.Color::new(254, 214, 174, 170),
  )
  @raylib.draw_line(
    cx - ray / 2,
    cy + ray / 2,
    cx + ray / 2,
    cy - ray / 2,
    @raylib.Color::new(254, 214, 174, 170),
  )
}

///|
fn draw_incident(threat : Threat, ox : Int, oy : Int) -> Unit {
  let cx = threat.x.to_int() + ox
  let cy = threat.y.to_int() + oy

  let body = if threat.stun_t > 0.0 {
    @raylib.Color::new(118, 166, 248, 236)
  } else {
    @raylib.Color::new(242, 182, 112, 236)
  }

  let outline = if threat.stun_t > 0.0 {
    @raylib.Color::new(196, 224, 250, 220)
  } else {
    @raylib.Color::new(250, 226, 168, 220)
  }

  @raylib.draw_circle(cx - 14, cy - 9, 12.0, body)
  @raylib.draw_circle(cx + 12, cy - 8, 11.0, body)
  @raylib.draw_circle(cx, cy - 13, 11.0, body)
  @raylib.draw_rectangle(cx - 23, cy - 6, 46, 26, body)

  @raylib.draw_rectangle_lines(cx - 23, cy - 6, 46, 26, outline)

  if threat.stun_t > 0.0 {
    let aura : Float = 22.0 + @math.sinf(threat.spin * 3.2) * 4.0
    @raylib.draw_circle_lines(
      cx,
      cy + 2,
      aura,
      @raylib.Color::new(176, 212, 250, 188),
    )
  }
}

///|
fn draw_threat(threat : Threat, ox : Int, oy : Int) -> Unit {
  if not(threat.active) {
    return
  }

  if threat.kind == threat_firecracker {
    draw_firecracker(threat, ox, oy)
  } else {
    draw_incident(threat, ox, oy)
  }
}

///|
fn draw_troupe(game : Game, ox : Int, oy : Int) -> Unit {
  let cx = game.troupe_x.to_int() + ox
  let cy = game.troupe_y.to_int() + oy

  let body_col = if game.burst_t > 0.0 {
    @raylib.Color::new(252, 118, 68, 246)
  } else if game.guard_t > 0.0 {
    @raylib.Color::new(104, 156, 244, 246)
  } else {
    @raylib.Color::new(246, 92, 78, 244)
  }

  let trim_col = @raylib.Color::new(254, 226, 172, 236)

  @raylib.draw_rectangle(cx - 46, cy - 22, 92, 44, body_col)
  @raylib.draw_rectangle_lines(
    cx - 46,
    cy - 22,
    92,
    44,
    @raylib.Color::new(252, 238, 208, 220),
  )

  @raylib.draw_circle(cx + 56, cy - 2, 22.0, body_col)
  @raylib.draw_circle(cx + 64, cy - 10, 10.0, trim_col)
  @raylib.draw_circle(cx + 50, cy - 8, 5.0, trim_col)

  @raylib.draw_rectangle(cx - 58, cy - 13, 12, 26, trim_col)
  @raylib.draw_rectangle(
    cx - 70,
    cy - 8,
    14,
    16,
    @raylib.Color::new(246, 74, 60, 238),
  )

  @raylib.draw_circle(cx + 62, cy - 5, 3.0, @raylib.Color::new(28, 30, 42, 255))
  @raylib.draw_circle(cx + 49, cy - 4, 3.0, @raylib.Color::new(28, 30, 42, 255))

  @raylib.draw_rectangle(cx - 20, cy - 8, 40, 8, trim_col)

  if game.guard_t > 0.0 {
    let ring_r : Float = guard_radius * (0.65 + 0.35 * pulse(game, 10.0))
    @raylib.draw_circle_lines(
      cx,
      cy,
      ring_r,
      @raylib.Color::new(164, 210, 252, 226),
    )
  }
}

///|
fn draw_action_fx(game : Game, ox : Int, oy : Int) -> Unit {
  let cx = game.troupe_x.to_int() + ox
  let cy = game.troupe_y.to_int() + oy

  if game.strike_t > 0.0 {
    let t : Float = 1.0 - game.strike_t / maxf(strike_fx_time, 0.01)
    let radius : Float = strike_radius * (0.78 + t * 0.28)
    let alpha = clampi(
      (Float::from_int(220) * (Float::from_int(1) - t)).to_int(),
      0,
      220,
    )

    @raylib.draw_circle_lines(
      cx,
      cy,
      radius,
      @raylib.Color::new(252, 226, 168, alpha),
    )
  }

  if game.burst_t > 0.0 {
    let t : Float = 1.0 - game.burst_t / maxf(burst_duration, 0.01)
    let radius : Float = burst_radius * (0.80 + t * 0.30)
    let alpha = clampi(
      (Float::from_int(206) * (Float::from_int(1) - t * 0.6)).to_int(),
      0,
      230,
    )

    @raylib.draw_circle_lines(
      cx,
      cy,
      radius,
      @raylib.Color::new(252, 198, 98, alpha),
    )

    @raylib.draw_circle_lines(
      cx,
      cy,
      radius * 0.64,
      @raylib.Color::new(252, 232, 172, alpha),
    )
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(20, 18, 560, 188, @raylib.Color::new(10, 16, 26, 214))
  @raylib.draw_rectangle_lines(
    20,
    18,
    560,
    188,
    @raylib.Color::new(252, 214, 140, 182),
  )

  @raylib.draw_text(
    "LION DANCE DEFENSE",
    40,
    30,
    34,
    @raylib.Color::new(252, 236, 196, 244),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    42,
    72,
    28,
    @raylib.Color::new(250, 246, 238, 242),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    240,
    72,
    28,
    @raylib.Color::new(250, 246, 238, 212),
  )

  @raylib.draw_text(
    "Combo x\{game.combo}",
    42,
    104,
    24,
    @raylib.Color::new(252, 216, 142, 238),
  )
  @raylib.draw_text(
    "Cleared \{game.cleared}  Leaked \{game.leaked}",
    240,
    104,
    24,
    @raylib.Color::new(242, 232, 218, 220),
  )

  @raylib.draw_text(
    "Lane \{game.troupe_lane + 1}",
    42,
    132,
    22,
    @raylib.Color::new(212, 226, 248, 218),
  )

  draw_meter(
    620,
    28,
    420,
    34,
    "HYPE",
    game.hype / hype_max,
    @raylib.Color::new(52, 34, 22, 210),
    @raylib.Color::new(248, 148, 80, 236),
  )

  draw_meter(
    620,
    78,
    420,
    34,
    "CROWD ORDER",
    game.crowd_order / order_max,
    @raylib.Color::new(28, 44, 54, 210),
    @raylib.Color::new(120, 224, 210, 236),
  )

  draw_meter(
    620,
    128,
    420,
    34,
    "MORALE",
    game.morale / morale_max,
    @raylib.Color::new(48, 28, 40, 210),
    @raylib.Color::new(242, 96, 134, 236),
  )

  let burst_eta = if game.burst_cd <= 0.0 {
    "Ready"
  } else {
    "\{game.burst_cd.to_int() + 1}s"
  }

  @raylib.draw_text(
    "Burst CD: \{burst_eta}",
    1062,
    34,
    24,
    @raylib.Color::new(246, 236, 220, 222),
  )

  let strike_eta = if game.strike_cd <= 0.0 {
    "Ready"
  } else {
    "\{(game.strike_cd * 10.0).to_int()}t"
  }

  let guard_eta = if game.guard_cd <= 0.0 {
    "Ready"
  } else {
    "\{(game.guard_cd * 10.0).to_int()}t"
  }

  @raylib.draw_text(
    "Strike: \{strike_eta}   Guard: \{guard_eta}",
    1062,
    72,
    24,
    @raylib.Color::new(226, 236, 252, 210),
  )

  @raylib.draw_text(
    "Survival: \{game.elapsed.to_int()}s",
    1062,
    110,
    24,
    @raylib.Color::new(226, 236, 252, 190),
  )

  @raylib.draw_text(
    "Incident must be stunned (K) before strike (J).",
    1062,
    142,
    22,
    @raylib.Color::new(242, 208, 170, 206),
  )
}

///|
fn draw_controls_legend() -> Unit {
  @raylib.draw_rectangle(
    20,
    screen_h - 64,
    screen_w - 40,
    42,
    @raylib.Color::new(12, 16, 24, 210),
  )
  @raylib.draw_rectangle_lines(
    20,
    screen_h - 64,
    screen_w - 40,
    42,
    @raylib.Color::new(140, 164, 194, 120),
  )

  @raylib.draw_text(
    "WASD/Arrows Move   J Strike/Clear   K Guard/Stun   Space Hype Burst   P Pause   R Restart",
    38,
    screen_h - 54,
    24,
    @raylib.Color::new(236, 242, 252, 230),
  )
}

///|
fn draw_message(game : Game) -> Unit {
  if game.msg_t <= 0.0 {
    return
  }

  let alpha = clampi((game.msg_t * 190.0).to_int(), 0, 220)
  @raylib.draw_rectangle(
    380,
    screen_h - 130,
    840,
    44,
    @raylib.Color::new(20, 26, 38, alpha),
  )
  @raylib.draw_rectangle_lines(
    380,
    screen_h - 130,
    840,
    44,
    @raylib.Color::new(246, 214, 156, alpha),
  )

  @raylib.draw_text(
    game.msg,
    402,
    screen_h - 120,
    24,
    @raylib.Color::new(252, 244, 232, clampi(alpha + 40, 0, 255)),
  )
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  let p = pulse(game, 1.2)
  let panel_w = 980
  let panel_h = 420
  let panel_x = (screen_w - panel_w) / 2
  let panel_y = (screen_h - panel_h) / 2 - 20

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 14, 24, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(250, 216, 142, 220),
  )

  @raylib.draw_text(
    "FESTIVAL LION DANCE DEFENSE 2026",
    panel_x + 56,
    panel_y + 42,
    52,
    @raylib.Color::new(252, 236, 198, 246),
  )

  @raylib.draw_text(
    "Intercept firecracker hazards and crowd incidents before they break the parade lanes.",
    panel_x + 58,
    panel_y + 122,
    28,
    @raylib.Color::new(234, 242, 252, 230),
  )

  @raylib.draw_text(
    "Chain clean defenses to build hype. If crowd order drops, morale drains fast.",
    panel_x + 58,
    panel_y + 158,
    28,
    @raylib.Color::new(234, 242, 252, 230),
  )

  @raylib.draw_text(
    "J: Strike clear    K: Guard stun    Space: Hype burst",
    panel_x + 58,
    panel_y + 216,
    30,
    @raylib.Color::new(252, 220, 150, 236),
  )

  @raylib.draw_text(
    "WASD/Arrows to move across lanes    P pause    R restart",
    panel_x + 58,
    panel_y + 252,
    30,
    @raylib.Color::new(252, 220, 150, 236),
  )

  let blink = if p > 0.5 {
    @raylib.Color::new(252, 234, 182, 246)
  } else {
    @raylib.Color::new(250, 206, 122, 210)
  }

  @raylib.draw_text(
    "Press J / Enter / Space to begin",
    panel_x + 258,
    panel_y + 326,
    36,
    blink,
  )
}

///|
fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 18, 160),
  )
  @raylib.draw_rectangle(
    470,
    320,
    660,
    220,
    @raylib.Color::new(12, 18, 28, 230),
  )
  @raylib.draw_rectangle_lines(
    470,
    320,
    660,
    220,
    @raylib.Color::new(188, 212, 244, 220),
  )

  @raylib.draw_text(
    "PAUSED",
    700,
    370,
    56,
    @raylib.Color::new(246, 238, 224, 244),
  )
  @raylib.draw_text(
    "P to resume   R to restart",
    602,
    450,
    34,
    @raylib.Color::new(232, 238, 248, 224),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(16, 10, 16, 178),
  )

  @raylib.draw_rectangle(
    410,
    250,
    780,
    390,
    @raylib.Color::new(20, 14, 24, 236),
  )
  @raylib.draw_rectangle_lines(
    410,
    250,
    780,
    390,
    @raylib.Color::new(252, 176, 162, 226),
  )

  @raylib.draw_text(
    "PARADE OVER",
    640,
    300,
    68,
    @raylib.Color::new(252, 210, 190, 246),
  )

  @raylib.draw_text(
    "Score \{game.score}   Best \{game.best_score}",
    560,
    392,
    40,
    @raylib.Color::new(244, 238, 228, 238),
  )

  @raylib.draw_text(
    "Cleared \{game.cleared}   Leaked \{game.leaked}   Peak Combo x\{game.combo}",
    510,
    438,
    34,
    @raylib.Color::new(236, 230, 222, 230),
  )

  @raylib.draw_text(
    "Press R / J / Enter to run again",
    580,
    530,
    36,
    @raylib.Color::new(252, 226, 166, 246),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  let ox = shake_x(game)
  let oy = shake_y(game)

  draw_background(game, ox, oy)
  draw_lanes(game, ox, oy)

  for i = 0; i < game.threats.length(); i = i + 1 {
    draw_threat(game.threats[i], ox, oy)
  }

  draw_action_fx(game, ox, oy)
  draw_troupe(game, ox, oy)

  draw_hud(game)
  draw_controls_legend()
  draw_message(game)

  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_paused {
    draw_pause_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
