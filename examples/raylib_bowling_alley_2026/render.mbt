///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

  let pulse : Float = Float::from_double(
    @math.sin((game.ui_t * 0.86).to_double()),
  )

  @raylib.draw_circle(
    280,
    170,
    220.0 + pulse * 14.0,
    @raylib.Color::new(30, 48, 84, 42),
  )
  @raylib.draw_circle(
    screen_w - 220,
    200,
    190.0 - pulse * 12.0,
    @raylib.Color::new(72, 40, 34, 36),
  )

  for i = 0; i < 14; i = i + 1 {
    let y : Int = i * 76
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      52,
      @raylib.Color::new(
        14 + i * 9 % 22,
        18 + i * 11 % 22,
        28 + i * 13 % 26,
        16 + i * 9 % 30,
      ),
    )
  }
}

///|
fn lane_shake_x(game : Game) -> Int {
  if game.shake_t > 0.0 {
    @raylib.get_random_value(-4, 4)
  } else {
    0
  }
}

///|
fn lane_shake_y(game : Game) -> Int {
  if game.shake_t > 0.0 {
    @raylib.get_random_value(-4, 4)
  } else {
    0
  }
}

///|
fn draw_lane(game : Game) -> (Int, Int) {
  let sx : Int = lane_shake_x(game)
  let sy : Int = lane_shake_y(game)

  @raylib.draw_rectangle(
    lane_x + sx - 18,
    lane_y + sy - 18,
    lane_w + 36,
    lane_h + 36,
    @raylib.Color::new(24, 34, 52, 226),
  )
  @raylib.draw_rectangle_lines(
    lane_x + sx - 18,
    lane_y + sy - 18,
    lane_w + 36,
    lane_h + 36,
    @raylib.Color::new(158, 186, 218, 216),
  )

  @raylib.draw_rectangle(
    lane_x + sx,
    lane_y + sy,
    lane_w,
    lane_h,
    @raylib.Color::new(164, 124, 82, 252),
  )

  for i = 0; i < 26; i = i + 1 {
    let y : Int = lane_y + sy + i * 36
    @raylib.draw_rectangle(
      lane_x + sx + 6,
      y,
      lane_w - 12,
      18,
      @raylib.Color::new(
        190 + i * 7 % 24,
        148 + i * 11 % 22,
        90 + i * 9 % 20,
        78,
      ),
    )
  }

  @raylib.draw_rectangle(
    lane_x + sx + 20,
    lane_y + sy,
    12,
    lane_h,
    @raylib.Color::new(58, 42, 32, 140),
  )
  @raylib.draw_rectangle(
    lane_x + sx + lane_w - 32,
    lane_y + sy,
    12,
    lane_h,
    @raylib.Color::new(58, 42, 32, 140),
  )

  let foul_y : Int = foul_line_y.to_int() + sy
  @raylib.draw_rectangle(
    lane_x + sx + 24,
    foul_y,
    lane_w - 48,
    6,
    @raylib.Color::new(218, 64, 64, 232),
  )

  let deck_y : Int = pin_deck_y.to_int() + sy - 34
  @raylib.draw_rectangle(
    lane_x + sx + 80,
    deck_y,
    lane_w - 160,
    120,
    @raylib.Color::new(208, 188, 158, 112),
  )

  (sx, sy)
}

///|
fn draw_aim_guide(game : Game, sx : Int, sy : Int) -> Unit {
  if not(game.can_throw) {
    return
  }

  let angle : Float = deg_to_rad(game.aim)
  let ux : Float = Float::from_double(@math.sin(angle.to_double()))
  let uy : Float = -Float::from_double(@math.cos(angle.to_double()))

  let x0 : Int = game.ball_x.to_int() + sx
  let y0 : Int = game.ball_y.to_int() + sy
  let x1 : Int = (game.ball_x + ux * 350.0).to_int() + sx
  let y1 : Int = (game.ball_y + uy * 350.0).to_int() + sy

  @raylib.draw_line(x0, y0, x1, y1, @raylib.Color::new(228, 240, 255, 220))
  @raylib.draw_circle_lines(
    x1,
    y1,
    11.0,
    @raylib.Color::new(228, 240, 255, 220),
  )
}

///|
fn draw_pin(pin : Pin, sx : Int, sy : Int) -> Unit {
  let px : Int = pin.x.to_int() + sx
  let py : Int = pin.y.to_int() + sy

  if pin.standing {
    @raylib.draw_circle(
      px,
      py,
      pin_radius,
      @raylib.Color::new(248, 248, 250, 252),
    )
    @raylib.draw_circle_lines(
      px,
      py,
      pin_radius,
      @raylib.Color::new(88, 90, 96, 180),
    )

    @raylib.draw_rectangle(
      px - 7,
      py - 4,
      14,
      5,
      @raylib.Color::new(210, 54, 56, 236),
    )
    @raylib.draw_rectangle(
      px - 7,
      py + 3,
      14,
      5,
      @raylib.Color::new(210, 54, 56, 236),
    )
  } else {
    @raylib.draw_circle(
      px,
      py,
      pin_radius * 0.76,
      @raylib.Color::new(204, 212, 220, 228),
    )
    @raylib.draw_circle_lines(
      px,
      py,
      pin_radius * 0.76,
      @raylib.Color::new(96, 104, 114, 196),
    )
    @raylib.draw_line(
      px,
      py,
      px + (pin.vx * 0.06).to_int(),
      py + (pin.vy * 0.06).to_int(),
      @raylib.Color::new(236, 160, 96, 214),
    )
  }
}

///|
fn draw_pins(game : Game, sx : Int, sy : Int) -> Unit {
  for i = 0; i < game.pins.length(); i = i + 1 {
    draw_pin(game.pins[i], sx, sy)
  }
}

///|
fn draw_ball(game : Game, sx : Int, sy : Int) -> Unit {
  let bx : Int = game.ball_x.to_int() + sx
  let by : Int = game.ball_y.to_int() + sy

  @raylib.draw_circle(bx, by, ball_radius, @raylib.Color::new(48, 58, 76, 255))
  @raylib.draw_circle(
    bx - 5,
    by - 5,
    ball_radius * 0.38,
    @raylib.Color::new(132, 156, 186, 210),
  )
  @raylib.draw_circle_lines(
    bx,
    by,
    ball_radius,
    @raylib.Color::new(214, 226, 244, 218),
  )
}

///|
fn draw_sparks(game : Game, sx : Int, sy : Int) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let alpha : Int = if game.sparks[i].life > 0.7 {
      238
    } else if game.sparks[i].life > 0.4 {
      200
    } else {
      146
    }

    let c : @raylib.Color = if game.sparks[i].kind == 1 {
      @raylib.Color::new(255, 226, 140, alpha)
    } else if game.sparks[i].kind == 2 {
      @raylib.Color::new(168, 206, 255, alpha)
    } else {
      @raylib.Color::new(255, 182, 108, alpha)
    }

    @raylib.draw_circle(
      game.sparks[i].x.to_int() + sx,
      game.sparks[i].y.to_int() + sy,
      1.0 + game.sparks[i].size,
      c,
    )
  }
}

///|
fn draw_score_grid(game : Game, px : Int, py : Int, pw : Int) -> Unit {
  @raylib.draw_text(
    "Frames",
    px + 16,
    py + 12,
    28,
    @raylib.Color::new(238, 246, 255, 248),
  )

  let mut x : Int = px + 16
  for f = 0; f < 10; f = f + 1 {
    let fw : Int = if f < 9 { 74 } else { 112 }

    @raylib.draw_rectangle(
      x,
      py + 52,
      fw,
      118,
      if game.frame == f && game.state == state_play {
        @raylib.Color::new(72, 104, 142, 202)
      } else {
        @raylib.Color::new(36, 48, 66, 202)
      },
    )
    @raylib.draw_rectangle_lines(
      x,
      py + 52,
      fw,
      118,
      @raylib.Color::new(168, 198, 224, 228),
    )

    @raylib.draw_text(
      "\{f + 1}",
      x + fw / 2 - @raylib.measure_text("\{f + 1}", 24) / 2,
      py + 58,
      24,
      @raylib.Color::new(236, 244, 255, 246),
    )

    let (a, b, c) = frame_marks(game, f)

    @raylib.draw_text(
      a,
      x + 12,
      py + 92,
      30,
      @raylib.Color::new(244, 250, 255, 248),
    )
    let second_x : Int = if f < 9 { x + 40 } else { x + 46 }
    @raylib.draw_text(
      b,
      second_x,
      py + 92,
      30,
      @raylib.Color::new(244, 250, 255, 248),
    )
    if f == 9 {
      @raylib.draw_text(
        c,
        x + 80,
        py + 92,
        30,
        @raylib.Color::new(244, 250, 255, 248),
      )
    }

    let total_str : String = if game.frame_totals[f] >= 0 {
      game.frame_totals[f].to_string()
    } else {
      ""
    }
    @raylib.draw_text(
      total_str,
      x + fw / 2 - @raylib.measure_text(total_str, 28) / 2,
      py + 128,
      28,
      @raylib.Color::new(220, 236, 252, 242),
    )

    x = x + fw + 6
  }

  @raylib.draw_line(
    px + 12,
    py + 178,
    px + pw - 12,
    py + 178,
    @raylib.Color::new(136, 176, 210, 198),
  )
}

///|
fn draw_control_hint(game : Game, px : Int, py : Int) -> Unit {
  @raylib.draw_text(
    "Controls",
    px,
    py,
    30,
    @raylib.Color::new(236, 246, 255, 246),
  )
  @raylib.draw_text(
    "Aim: A/D or Left/Right",
    px,
    py + 34,
    24,
    @raylib.Color::new(198, 218, 238, 236),
  )
  @raylib.draw_text(
    "Spin: Q/E",
    px,
    py + 62,
    24,
    @raylib.Color::new(198, 218, 238, 236),
  )
  @raylib.draw_text(
    "Hold + Release: Space/Enter/Touch",
    px,
    py + 90,
    24,
    @raylib.Color::new(198, 218, 238, 236),
  )
  @raylib.draw_text(
    "Restart: R  Back: ESC",
    px,
    py + 118,
    24,
    @raylib.Color::new(198, 218, 238, 236),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      px,
      py + 160,
      panel_w - 44,
      52,
      @raylib.Color::new(44, 62, 88, 220),
    )
    @raylib.draw_rectangle_lines(
      px,
      py + 160,
      panel_w - 44,
      52,
      @raylib.Color::new(182, 210, 236, 232),
    )
    @raylib.draw_text(
      game.message,
      px + 14,
      py + 176,
      26,
      @raylib.Color::new(246, 252, 255, 248),
    )
  }
}

///|
fn draw_side_panel(game : Game) -> Unit {
  let (px, py, pw, ph) = panel_rect()

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 24, 38, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(128, 170, 204, 220),
  )

  @raylib.draw_text(
    "Bowling Alley 2026",
    px + 20,
    py + 20,
    42,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 72,
    36,
    @raylib.Color::new(228, 240, 252, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    px + 260,
    py + 72,
    36,
    @raylib.Color::new(196, 220, 244, 236),
  )

  @raylib.draw_text(
    "Frame \{game.frame + 1}/10",
    px + 20,
    py + 116,
    30,
    @raylib.Color::new(214, 232, 250, 242),
  )
  @raylib.draw_text(
    "Pins Left \{game.pins_left}",
    px + 250,
    py + 116,
    30,
    @raylib.Color::new(214, 232, 250, 242),
  )

  @raylib.draw_text(
    "Strikes \{game.strikes}   Spares \{game.spares}   Opens \{game.opens}",
    px + 20,
    py + 152,
    28,
    @raylib.Color::new(204, 224, 246, 240),
  )

  draw_score_grid(game, px, py + 194, pw)

  let ap : Int = (game.aim * 10.0).to_int()
  let sp : Int = (game.spin * 100.0).to_int()
  let pwv : Int = (game.power * 100.0).to_int()

  @raylib.draw_text(
    "Aim \{ap / 10}.\{absf(Float::from_int(ap % 10)).to_int()} deg",
    px + 20,
    py + 410,
    28,
    @raylib.Color::new(214, 232, 250, 242),
  )
  @raylib.draw_text(
    "Spin \{sp}%",
    px + 20,
    py + 442,
    28,
    @raylib.Color::new(214, 232, 250, 242),
  )
  @raylib.draw_text(
    "Last Knock \{game.last_knock}",
    px + 230,
    py + 442,
    28,
    @raylib.Color::new(214, 232, 250, 242),
  )

  @raylib.draw_rectangle(
    px + 20,
    py + 478,
    pw - 40,
    28,
    @raylib.Color::new(30, 40, 56, 220),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 478,
    (pw - 40) * pwv / 100,
    28,
    @raylib.Color::new(94, 154, 202, 236),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 478,
    pw - 40,
    28,
    @raylib.Color::new(184, 212, 236, 230),
  )

  @raylib.draw_text(
    "Power \{pwv}%",
    px + 28,
    py + 482,
    22,
    @raylib.Color::new(242, 248, 255, 246),
  )

  draw_control_hint(game, px + 20, py + 536)
}

///|
fn draw_touch_button(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  active : Bool,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if active {
      tint
    } else {
      @raylib.Color::new(36, 50, 72, 184)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(182, 214, 242, 214),
  )
  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, 30) / 2,
    y + h / 2 - 15,
    30,
    @raylib.Color::new(244, 250, 255, 248),
  )
}

///|
fn draw_touch_overlay(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  let (alx, aly, alw, alh) = touch_aim_left_rect()
  let (arx, ary, arw, arh) = touch_aim_right_rect()
  let (slx, sly, slw, slh) = touch_spin_left_rect()
  let (srx, sry, srw, srh) = touch_spin_right_rect()
  let (px, py, pw, ph) = touch_power_rect()

  let l_on : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, alx, aly, alw, alh,
  )
  let r_on : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, arx, ary, arw, arh,
  )
  let sl_on : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, slx, sly, slw, slh,
  )
  let sr_on : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, srx, sry, srw, srh,
  )
  let p_on : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, px, py, pw, ph,
  )

  draw_touch_button(
    "AIM-",
    alx,
    aly,
    alw,
    alh,
    l_on,
    @raylib.Color::new(88, 136, 180, 224),
  )
  draw_touch_button(
    "AIM+",
    arx,
    ary,
    arw,
    arh,
    r_on,
    @raylib.Color::new(88, 136, 180, 224),
  )
  draw_touch_button(
    "SPIN-",
    slx,
    sly,
    slw,
    slh,
    sl_on,
    @raylib.Color::new(124, 108, 180, 224),
  )
  draw_touch_button(
    "SPIN+",
    srx,
    sry,
    srw,
    srh,
    sr_on,
    @raylib.Color::new(124, 108, 180, 224),
  )
  draw_touch_button(
    "HOLD/RELEASE",
    px,
    py,
    pw,
    ph,
    p_on || game.charging,
    @raylib.Color::new(184, 110, 82, 224),
  )
}

///|
fn draw_title(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_text(
    "Bowling Alley Showdown 2026",
    screen_w / 2 - @raylib.measure_text("Bowling Alley Showdown 2026", 86) / 2,
    110,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @raylib.draw_text(
    "Hit strikes, build combos, and survive the pressure of a full 10-frame run.",
    screen_w / 2 -
    @raylib.measure_text(
      "Hit strikes, build combos, and survive the pressure of a full 10-frame run.",
      32,
    ) /
    2,
    246,
    32,
    @raylib.Color::new(198, 220, 242, 238),
  )
  @raylib.draw_text(
    "Mobile-ready touch controls are on screen in-game.",
    screen_w / 2 -
    @raylib.measure_text(
      "Mobile-ready touch controls are on screen in-game.", 32,
    ) /
    2,
    286,
    32,
    @raylib.Color::new(198, 220, 242, 238),
  )

  let (bx, by, bw, bh) = title_start_button()
  let hover : Bool = title_start_hover(
    mouse_x, mouse_y, mouse_hold, touch_count,
  )

  draw_touch_button(
    "Start Match",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(92, 146, 188, 232),
  )

  @raylib.draw_text(
    "Keyboard: A/D aim, Q/E spin, hold+release Space",
    screen_w / 2 -
    @raylib.measure_text("Keyboard: A/D aim, Q/E spin, hold+release Space", 30) /
    2,
    760,
    30,
    @raylib.Color::new(200, 222, 242, 236),
  )
}

///|
fn draw_result_overlay(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
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
  let ph : Int = 470
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 28, 42, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(168, 204, 234, 238),
  )

  let grade : String = if game.score >= 240 {
    "Perfect Storm"
  } else if game.score >= 200 {
    "Pro League"
  } else if game.score >= 160 {
    "Solid Match"
  } else {
    "Keep Training"
  }

  @raylib.draw_text(
    "Match Complete",
    px + pw / 2 - @raylib.measure_text("Match Complete", 66) / 2,
    py + 34,
    66,
    @raylib.Color::new(242, 250, 255, 250),
  )
  @raylib.draw_text(
    "Final Score \{game.score}",
    px + pw / 2 - @raylib.measure_text("Final Score \{game.score}", 52) / 2,
    py + 124,
    52,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    grade,
    px + pw / 2 - @raylib.measure_text(grade, 44) / 2,
    py + 188,
    44,
    @raylib.Color::new(202, 226, 248, 242),
  )

  @raylib.draw_text(
    "Strikes \{game.strikes}    Spares \{game.spares}    Opens \{game.opens}",
    px + 120,
    py + 262,
    34,
    @raylib.Color::new(214, 234, 252, 242),
  )

  let (bx, by, bw, bh) = retry_button()
  let hover : Bool = result_retry_hover(
    mouse_x, mouse_y, mouse_hold, touch_count,
  )

  draw_touch_button(
    "Play Again",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(92, 150, 188, 232),
  )
}

///|
fn draw_frame(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_bg(game)

  if game.state == state_title {
    draw_title(mouse_x, mouse_y, mouse_hold, touch_count)
    return
  }

  let (sx, sy) = draw_lane(game)
  draw_aim_guide(game, sx, sy)
  draw_pins(game, sx, sy)
  draw_ball(game, sx, sy)
  draw_sparks(game, sx, sy)
  draw_side_panel(game)
  draw_touch_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)

  if game.state == state_result {
    draw_result_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
