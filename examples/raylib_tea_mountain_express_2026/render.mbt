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
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value_100 : Float,
  fill : @raylib.Color,
  label : String,
) -> Unit {
  let pct = clamp01(value_100 / 100.0)
  let fill_w = clampi((Float::from_int(w) * pct).to_int(), 0, w)

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(18, 22, 30, 230))
  @raylib.draw_rectangle(x, y, fill_w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(206, 220, 236, 120),
  )
  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 9,
    18,
    @raylib.Color::new(242, 247, 252, 230),
  )
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(40, 86, 132, 255),
    @raylib.Color::new(14, 24, 40, 255),
  )

  for i = 0; i < 9; i = i + 1 {
    let fi = Float::from_int(i)
    let drift = sinf(game.world_t * 0.18 + fi * 0.73) * 70.0
    let ridge_y = 170 + i * 62
    let ridge_h = 240 - i * 18

    @raylib.draw_triangle(
      @raylib.Vector2::new(-120.0 + drift, Float::from_int(ridge_y + ridge_h)),
      @raylib.Vector2::new(
        Float::from_int(screen_w / 2) + drift + fi * 30.0,
        Float::from_int(ridge_y),
      ),
      @raylib.Vector2::new(
        Float::from_int(screen_w + 130) + drift,
        Float::from_int(ridge_y + ridge_h),
      ),
      @raylib.Color::new(20 + i * 3, 32 + i * 3, 46 + i * 4, 180),
    )
  }

  for i = 0; i < 26; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 78.0 + game.world_t * 16.0 + sinf(fi * 1.3) * 40.0) %
      Float::from_int(screen_w)
    let y : Float = 86.0 + fi * 8.4 + cosf(game.world_t * 0.55 + fi) * 18.0
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      1.8 + fi * 0.03,
      @raylib.Color::new(246, 250, 255, 105),
    )
  }
}

///|
fn draw_road(game : Game) -> Unit {
  let row_h = 16

  for yi = road_top_y_i; yi < screen_h; yi = yi + row_h {
    let y0 = Float::from_int(yi)
    let y1 = Float::from_int(yi + row_h)

    let c0 = road_center_x(game.world_t, y0)
    let c1 = road_center_x(game.world_t, y1)
    let w0 = road_half_width(y0)
    let w1 = road_half_width(y1)

    let left = minf(c0 - w0, c1 - w1).to_int()
    let right = maxf(c0 + w0, c1 + w1).to_int()
    let road_w = right - left

    if left > 0 {
      @raylib.draw_rectangle(
        0,
        yi,
        left,
        row_h + 1,
        @raylib.Color::new(30, 26, 28, 232),
      )
    }

    if right < screen_w {
      @raylib.draw_rectangle(
        right,
        yi,
        screen_w - right,
        row_h + 1,
        @raylib.Color::new(30, 26, 28, 232),
      )
    }

    if road_w > 0 {
      let shade = 52 + (yi - road_top_y_i) * 66 / (screen_h - road_top_y_i)
      @raylib.draw_rectangle(
        left,
        yi,
        road_w,
        row_h + 1,
        @raylib.Color::new(shade, shade - 4, shade - 6, 255),
      )
    }

    let l0 = lane_center_x(game.world_t, 0, y0)
    let m0 = lane_center_x(game.world_t, 1, y0)
    let r0 = lane_center_x(game.world_t, 2, y0)
    let l1 = lane_center_x(game.world_t, 0, y1)
    let m1 = lane_center_x(game.world_t, 1, y1)
    let r1 = lane_center_x(game.world_t, 2, y1)

    let divider0_0 = (l0 + m0) * 0.5
    let divider1_0 = (m0 + r0) * 0.5
    let divider0_1 = (l1 + m1) * 0.5
    let divider1_1 = (m1 + r1) * 0.5

    let stripe_phase = (Float::from_int(yi) + game.distance * 0.35).to_int() %
      48
    if stripe_phase < 24 {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(divider0_0, y0),
        @raylib.Vector2::new(divider0_1, y1),
        3.0,
        @raylib.Color::new(244, 210, 124, 190),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(divider1_0, y0),
        @raylib.Vector2::new(divider1_1, y1),
        3.0,
        @raylib.Color::new(244, 210, 124, 190),
      )
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(c0 - w0, y0),
      @raylib.Vector2::new(c1 - w1, y1),
      4.0,
      @raylib.Color::new(224, 166, 86, 220),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(c0 + w0, y0),
      @raylib.Vector2::new(c1 + w1, y1),
      4.0,
      @raylib.Color::new(224, 166, 86, 220),
    )
  }
}

///|
fn hazard_color(kind : Int) -> @raylib.Color {
  if kind == hazard_rock {
    @raylib.Color::new(176, 188, 198, 255)
  } else if kind == hazard_landslide {
    @raylib.Color::new(206, 134, 90, 255)
  } else {
    @raylib.Color::new(120, 204, 248, 255)
  }
}

///|
fn draw_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    let y = game.hazards[i].y
    if y < Float::from_int(road_top_y_i) - 20.0 {
      continue
    }

    let x = lane_center_x(game.world_t, game.hazards[i].lane, y)
    let size = game.hazards[i].size
    let col = hazard_color(game.hazards[i].kind)

    if game.hazards[i].kind == hazard_rock {
      @raylib.draw_circle(x.to_int(), y.to_int(), size, col)
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        size + 3.0,
        @raylib.Color::new(240, 244, 252, 180),
      )
    } else if game.hazards[i].kind == hazard_landslide {
      @raylib.draw_triangle(
        @raylib.Vector2::new(x - size, y + size * 0.8),
        @raylib.Vector2::new(x + size, y + size * 0.8),
        @raylib.Vector2::new(x - size * 0.15, y - size),
        col,
      )
      @raylib.draw_rectangle(
        (x - size).to_int(),
        (y + size * 0.7).to_int(),
        (size * 2.0).to_int(),
        (size * 0.45).to_int(),
        @raylib.Color::new(126, 74, 52, 220),
      )
    } else {
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        size,
        @raylib.Color::new(130, 220, 252, 220),
      )
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        size * 0.62,
        @raylib.Color::new(130, 220, 252, 180),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(x - size * 0.8, y),
        @raylib.Vector2::new(x + size * 0.8, y),
        4.0,
        @raylib.Color::new(186, 236, 255, 180),
      )
    }

    let cue = if hazard_tilt_bias(game.hazards[i].kind) < -0.2 {
      "L"
    } else if hazard_tilt_bias(game.hazards[i].kind) > 0.2 {
      "R"
    } else {
      "C"
    }

    @raylib.draw_text(
      cue,
      (x - 6.0).to_int(),
      (y - size - 18.0).to_int(),
      20,
      @raylib.Color::new(248, 250, 255, 210),
    )
  }
}

///|
fn draw_cart(game : Game) -> Unit {
  let x = game.lane_x
  let y = cart_y
  let lean = game.tilt * 18.0

  let heat_ratio = clamp01(game.boost_heat / 100.0)
  let boost_glow = clamp01(game.boost_timer / boost_duration)

  @raylib.draw_ellipse(
    x.to_int(),
    (y + 30.0).to_int(),
    72.0,
    16.0,
    @raylib.Color::new(12, 14, 18, 170),
  )

  @raylib.draw_rectangle(
    (x - 56.0 + lean).to_int(),
    (y - 40.0).to_int(),
    112,
    48,
    @raylib.Color::new(124 + (boost_glow * 80.0).to_int(), 74, 42, 255),
  )

  @raylib.draw_rectangle(
    (x - 42.0 + lean * 0.8).to_int(),
    (y - 68.0).to_int(),
    84,
    28,
    @raylib.Color::new(182 + (heat_ratio * 40.0).to_int(), 112, 70, 255),
  )

  @raylib.draw_rectangle_lines(
    (x - 56.0 + lean).to_int(),
    (y - 40.0).to_int(),
    112,
    48,
    @raylib.Color::new(255, 236, 210, 200),
  )

  @raylib.draw_circle(
    (x - 40.0).to_int(),
    (y + 10.0).to_int(),
    15.0,
    @raylib.Color::new(26, 22, 20, 255),
  )
  @raylib.draw_circle(
    (x + 40.0).to_int(),
    (y + 10.0).to_int(),
    15.0,
    @raylib.Color::new(26, 22, 20, 255),
  )

  @raylib.draw_circle_lines(
    (x - 40.0).to_int(),
    (y + 10.0).to_int(),
    15.0,
    @raylib.Color::new(202, 184, 150, 210),
  )
  @raylib.draw_circle_lines(
    (x + 40.0).to_int(),
    (y + 10.0).to_int(),
    15.0,
    @raylib.Color::new(202, 184, 150, 210),
  )

  @raylib.draw_rectangle(
    (x - 30.0 + lean * 0.8).to_int(),
    (y - 88.0).to_int(),
    60,
    18,
    @raylib.Color::new(52, 88, 54, 220),
  )

  if game.boost_timer > 0.0 {
    let exhaust : Float = 26.0 + boost_glow * 18.0
    @raylib.draw_triangle(
      @raylib.Vector2::new(x + lean * 1.05, y + 4.0),
      @raylib.Vector2::new(x + lean * 0.9 - 16.0, y - 6.0),
      @raylib.Vector2::new(x + lean * 0.9 - exhaust, y + 5.0),
      @raylib.Color::new(255, 182, 96, 210),
    )
  }

  if game.input_stabilize_hold {
    @raylib.draw_circle_lines(
      (x + lean * 0.9).to_int(),
      (y - 58.0).to_int(),
      44.0,
      @raylib.Color::new(138, 236, 194, 180),
    )
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(16, 14, 362, 174, @raylib.Color::new(8, 12, 18, 170))
  @raylib.draw_rectangle(
    screen_w - 366,
    14,
    350,
    174,
    @raylib.Color::new(8, 12, 18, 170),
  )

  draw_meter(
    30,
    28,
    332,
    24,
    game.cargo_quality,
    @raylib.Color::new(150, 208, 122, 255),
    "Cargo Quality",
  )
  draw_meter(
    30,
    60,
    332,
    24,
    game.durability,
    @raylib.Color::new(246, 168, 96, 255),
    "Cart Durability",
  )
  draw_meter(
    30,
    92,
    332,
    24,
    game.reputation,
    @raylib.Color::new(116, 186, 250, 255),
    "Contract Reputation",
  )
  draw_meter(
    30,
    124,
    332,
    24,
    game.boost_heat,
    @raylib.Color::new(248, 118, 96, 255),
    "Boiler Heat",
  )

  let schedule_full = checkpoint_time_limit(game.checkpoint_index)
  let schedule_pct = clamp01(
      maxf(game.schedule_s, 0.0) / maxf(schedule_full, 0.01),
    ) *
    100.0

  draw_meter(
    screen_w - 352,
    28,
    320,
    24,
    schedule_pct,
    @raylib.Color::new(248, 216, 118, 255),
    "Schedule Window",
  )

  let dist_left = maxf(0.0, game.next_checkpoint_distance - game.distance)
  @raylib.draw_text(
    "Speed " + game.speed.to_int().to_string() + " km/h",
    screen_w - 348,
    66,
    24,
    @raylib.Color::new(236, 240, 248, 230),
  )
  @raylib.draw_text(
    "Next checkpoint " + dist_left.to_int().to_string() + " m",
    screen_w - 348,
    96,
    24,
    @raylib.Color::new(236, 240, 248, 230),
  )
  @raylib.draw_text(
    "Checkpoint " + game.checkpoint_index.to_string(),
    screen_w - 348,
    126,
    24,
    @raylib.Color::new(236, 240, 248, 230),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    24,
    screen_h - 58,
    30,
    @raylib.Color::new(246, 248, 252, 230),
  )
  @raylib.draw_text(
    "Multiplier x" + game.multiplier.to_string(),
    330,
    screen_h - 56,
    28,
    @raylib.Color::new(255, 220, 138, 230),
  )
  @raylib.draw_text(
    "Deliveries " +
    game.successful_deliveries.to_string() +
    " / Fail " +
    game.failed_deliveries.to_string(),
    620,
    screen_h - 56,
    28,
    @raylib.Color::new(212, 224, 238, 220),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      screen_w / 2 - 440,
      screen_h - 112,
      880,
      38,
      @raylib.Color::new(12, 16, 24, 184),
    )
    draw_center_text(
      game.message,
      screen_h - 106,
      24,
      @raylib.Color::new(246, 250, 255, 232),
    )
  }
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 10, 14, 110),
  )
  @raylib.draw_rectangle(
    screen_w / 2 - 500,
    140,
    1000,
    620,
    @raylib.Color::new(12, 18, 26, 210),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 500,
    140,
    1000,
    620,
    @raylib.Color::new(246, 212, 148, 220),
  )

  draw_center_text(
    "TEA MOUNTAIN EXPRESS 2026",
    186,
    58,
    @raylib.Color::new(252, 238, 206, 246),
  )

  draw_center_text(
    "High-speed tea caravan logistics over dangerous mountain passes.",
    270,
    30,
    @raylib.Color::new(216, 228, 242, 220),
  )

  draw_center_text(
    "Keep cargo quality, cart durability, and schedule alive to protect reputation.",
    314,
    30,
    @raylib.Color::new(216, 228, 242, 220),
  )

  @raylib.draw_text(
    "Controls",
    screen_w / 2 - 84,
    382,
    36,
    @raylib.Color::new(255, 226, 160, 230),
  )

  @raylib.draw_text(
    "A/D or Left/Right: lane switch     W/S or Up/Down: tilt",
    screen_w / 2 - 360,
    436,
    30,
    @raylib.Color::new(236, 244, 252, 230),
  )
  @raylib.draw_text(
    "J: quick brake + confirm           K: stabilize cargo",
    screen_w / 2 - 360,
    478,
    30,
    @raylib.Color::new(236, 244, 252, 230),
  )
  @raylib.draw_text(
    "Space: boost (cooldown + overheat risk)     P: pause     R: restart",
    screen_w / 2 - 360,
    520,
    30,
    @raylib.Color::new(236, 244, 252, 230),
  )

  draw_center_text(
    "Press J to dispatch caravan",
    612,
    42,
    @raylib.Color::new(255, 212, 118, 240),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 10, 16, 130),
  )
  draw_center_text(
    "PAUSED",
    screen_h / 2 - 96,
    64,
    @raylib.Color::new(246, 248, 252, 240),
  )
  draw_center_text(
    "Press P or J to continue",
    screen_h / 2 - 16,
    34,
    @raylib.Color::new(230, 238, 248, 220),
  )
  draw_center_text(
    "Press R to restart route",
    screen_h / 2 + 28,
    34,
    @raylib.Color::new(230, 238, 248, 220),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 14, 168),
  )
  @raylib.draw_rectangle(
    screen_w / 2 - 430,
    210,
    860,
    430,
    @raylib.Color::new(14, 18, 24, 220),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 430,
    210,
    860,
    430,
    @raylib.Color::new(232, 182, 126, 220),
  )

  draw_center_text(
    "CONTRACT LOST",
    256,
    64,
    @raylib.Color::new(255, 196, 132, 244),
  )

  draw_center_text(
    "Score " + game.score.to_string() + "   Best " + game.best_score.to_string(),
    350,
    38,
    @raylib.Color::new(236, 244, 252, 232),
  )
  draw_center_text(
    "Deliveries " +
    game.successful_deliveries.to_string() +
    "   Failed " +
    game.failed_deliveries.to_string(),
    398,
    36,
    @raylib.Color::new(236, 244, 252, 220),
  )
  draw_center_text(
    "Final cargo " +
    game.cargo_quality.to_int().to_string() +
    "%   durability " +
    game.durability.to_int().to_string() +
    "%   reputation " +
    game.reputation.to_int().to_string() +
    "%",
    444,
    34,
    @raylib.Color::new(230, 236, 246, 214),
  )

  draw_center_text(
    "Press J or R for a new run",
    526,
    40,
    @raylib.Color::new(255, 218, 132, 236),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_road(game)
  draw_hazards(game)
  draw_cart(game)
  draw_hud(game)

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_pause_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
