///|
fn lane_to_x(lane : Float) -> Float {
  Float::from_int(river_x + river_w / 2) + lane * lane_span_px
}

///|
fn world_y(game : Game, dist : Float) -> Float {
  Float::from_int(boat_y) - (dist - game.distance) * distance_to_px
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 20, 34, 255))

  let glow0 : Float = 0.5 + 0.5 * sinf(game.ui_t * 0.62)
  let glow1 : Float = 0.5 + 0.5 * cosf(game.ui_t * 0.48)

  @raylib.draw_circle(
    230,
    180,
    210.0 + glow0 * 24.0,
    @raylib.Color::new(52, 104, 140, 42),
  )
  @raylib.draw_circle(
    780,
    120,
    280.0 + glow1 * 30.0,
    @raylib.Color::new(42, 92, 126, 34),
  )
  @raylib.draw_circle(
    screen_w - 240,
    220,
    320.0 - glow1 * 28.0,
    @raylib.Color::new(84, 80, 62, 26),
  )

  for i = 0; i < 15; i = i + 1 {
    let y : Int = i * 72
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      46,
      @raylib.Color::new(
        10 + i * 3 % 18,
        18 + i * 4 % 18,
        28 + i * 5 % 20,
        18 + i * 2 % 20,
      ),
    )
  }
}

///|
fn draw_river_surface(game : Game) -> Unit {
  @raylib.draw_rectangle(
    river_x,
    river_y,
    river_w,
    river_h,
    @raylib.Color::new(24, 88, 130, 236),
  )

  @raylib.draw_rectangle_lines(
    river_x,
    river_y,
    river_w,
    river_h,
    @raylib.Color::new(184, 228, 244, 212),
  )

  for i = 0; i < 5; i = i + 1 {
    let lane : Float = -1.0 + Float::from_int(i) * 0.5
    let x : Int = lane_to_x(lane).to_int()
    @raylib.draw_line(
      x,
      river_y + 8,
      x,
      river_y + river_h - 8,
      @raylib.Color::new(166, 214, 230, 58),
    )
  }

  for i = 0; i < 22; i = i + 1 {
    let y_wave : Int = river_y +
      14 +
      i * 40 +
      (sinf(game.ui_t * 1.3 + Float::from_int(i) * 0.45) * 12.0).to_int()
    @raylib.draw_line(
      river_x + 8,
      y_wave,
      river_x + river_w - 10,
      y_wave +
      (sinf(game.ui_t * 0.8 + Float::from_int(i) * 0.32) * 8.0).to_int(),
      @raylib.Color::new(154, 220, 244, 46),
    )
  }
}

///|
fn draw_checkpoint_lines(game : Game) -> Unit {
  for i = game.checkpoint_idx; i < checkpoint_count; i = i + 1 {
    let dist : Float = checkpoint_distance(i)
    let rel : Float = dist - game.distance
    if rel < -80.0 || rel > visible_distance {
      continue
    }

    let y : Int = world_y(game, dist).to_int()
    let alpha : Int = clampi(
      (Float::from_int(220) - absf(rel) * 0.08).to_int(),
      50,
      220,
    )

    @raylib.draw_line(
      river_x + 14,
      y,
      river_x + river_w - 14,
      y,
      @raylib.Color::new(250, 238, 168, alpha),
    )

    let label : String = "CP" + (i + 1).to_string()
    @raylib.draw_text(
      label,
      river_x + 18,
      y - 26,
      24,
      @raylib.Color::new(255, 242, 176, alpha),
    )
  }
}

///|
fn draw_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    let rel : Float = game.hazards[i].dist - game.distance
    if rel < -120.0 || rel > visible_distance {
      continue
    }

    let x : Int = lane_to_x(
      game.hazards[i].lane +
      sinf(game.ui_t * 0.9 + game.hazards[i].phase) * 0.03,
    ).to_int()

    let y : Int = world_y(game, game.hazards[i].dist).to_int()

    if game.hazards[i].kind == hazard_debris {
      let w : Int = (game.hazards[i].size * 1.7).to_int()
      let h : Int = (game.hazards[i].size * 0.8).to_int()

      @raylib.draw_rectangle(
        x - w / 2,
        y - h / 2,
        w,
        h,
        @raylib.Color::new(98, 66, 44, 236),
      )
      @raylib.draw_rectangle_lines(
        x - w / 2,
        y - h / 2,
        w,
        h,
        @raylib.Color::new(212, 186, 156, 210),
      )
      @raylib.draw_circle(
        x - w / 2,
        y,
        Float::from_int(h / 2),
        @raylib.Color::new(128, 86, 58, 226),
      )
      @raylib.draw_circle(
        x + w / 2,
        y,
        Float::from_int(h / 2),
        @raylib.Color::new(128, 86, 58, 226),
      )
    } else {
      let r : Float = game.hazards[i].size
      @raylib.draw_circle_lines(x, y, r, @raylib.Color::new(228, 248, 255, 184))
      @raylib.draw_circle_lines(
        x,
        y,
        r * 0.7,
        @raylib.Color::new(168, 226, 248, 164),
      )
      @raylib.draw_line(
        x - r.to_int(),
        y,
        x + r.to_int(),
        y,
        @raylib.Color::new(212, 242, 255, 176),
      )
    }
  }
}

///|
fn draw_boat(
  x : Int,
  y : Int,
  scale : Float,
  hull : @raylib.Color,
  trim : @raylib.Color,
  show_flag : Bool,
) -> Unit {
  @raylib.draw_ellipse(x, y, scale * 74.0, scale * 18.0, hull)
  @raylib.draw_circle(x - (scale * 54.0).to_int(), y, scale * 18.0, hull)
  @raylib.draw_circle(x + (scale * 54.0).to_int(), y, scale * 18.0, hull)

  let deck_w : Int = (scale * 112.0).to_int()
  let deck_h : Int = (scale * 16.0).to_int()
  @raylib.draw_rectangle(
    x - deck_w / 2,
    y - deck_h / 2,
    deck_w,
    deck_h,
    @raylib.Color::new(
      mini(255, hull.r.to_int() + 18),
      mini(255, hull.g.to_int() + 18),
      mini(255, hull.b.to_int() + 18),
      230,
    ),
  )

  for i = 0; i < 8; i = i + 1 {
    let t : Float = Float::from_int(i) / 7.0
    let px : Int = (Float::from_int(x) - scale * 44.0 + t * 88.0 * scale).to_int()

    @raylib.draw_line(
      px,
      y + (scale * 10.0).to_int(),
      px,
      y + (scale * 25.0).to_int(),
      trim,
    )
  }

  if show_flag {
    let mast_x : Int = x - (scale * 8.0).to_int()
    let mast_top : Int = y - (scale * 48.0).to_int()

    @raylib.draw_line(
      mast_x,
      y - (scale * 6.0).to_int(),
      mast_x,
      mast_top,
      @raylib.Color::new(240, 240, 242, 220),
    )

    @raylib.draw_triangle(
      @raylib.Vector2::new(Float::from_int(mast_x), Float::from_int(mast_top)),
      @raylib.Vector2::new(
        Float::from_int(mast_x + (scale * 28.0).to_int()),
        Float::from_int(mast_top + (scale * 10.0).to_int()),
      ),
      @raylib.Vector2::new(
        Float::from_int(mast_x),
        Float::from_int(mast_top + (scale * 20.0).to_int()),
      ),
      @raylib.Color::new(255, 108, 96, 236),
    )
  }
}

///|
fn rival_hull_color(id : Int) -> @raylib.Color {
  if id == 1 {
    @raylib.Color::new(230, 126, 98, 246)
  } else if id == 2 {
    @raylib.Color::new(98, 212, 156, 246)
  } else if id == 3 {
    @raylib.Color::new(120, 164, 242, 246)
  } else {
    @raylib.Color::new(236, 198, 94, 246)
  }
}

///|
fn draw_rivals(game : Game) -> Unit {
  for i = 0; i < game.rivals.length(); i = i + 1 {
    if not(game.rivals[i].active) {
      continue
    }

    let rel : Float = game.rivals[i].dist - game.distance
    if rel < -140.0 || rel > visible_distance {
      continue
    }

    let y : Int = world_y(game, game.rivals[i].dist).to_int()
    let x : Int = lane_to_x(game.rivals[i].lane).to_int()

    let scale : Float = clampf(0.72 + rel / visible_distance * 0.42, 0.66, 1.05)
    let hull : @raylib.Color = rival_hull_color(game.rivals[i].id)

    draw_boat(x, y, scale, hull, @raylib.Color::new(246, 250, 255, 220), false)

    @raylib.draw_text(
      "R" + game.rivals[i].id.to_string(),
      x - 16,
      y - (scale * 38.0).to_int(),
      20,
      @raylib.Color::new(244, 250, 255, 236),
    )
  }
}

///|
fn draw_player_boat(game : Game) -> Unit {
  let x : Int = lane_to_x(game.lane).to_int()
  let y : Int = boat_y

  let hull : @raylib.Color = if game.burst_t > 0.0 {
    @raylib.Color::new(250, 142, 92, 250)
  } else {
    @raylib.Color::new(190, 58, 52, 248)
  }

  let trim : @raylib.Color = if game.input.stabilize_down {
    @raylib.Color::new(186, 242, 255, 232)
  } else {
    @raylib.Color::new(246, 220, 188, 228)
  }

  draw_boat(x, y, 1.0, hull, trim, true)

  @raylib.draw_circle(
    x + 72,
    y - 2,
    14.0,
    @raylib.Color::new(246, 188, 86, 244),
  )
  @raylib.draw_circle(x + 76, y - 4, 4.5, @raylib.Color::new(44, 34, 24, 238))

  let miss : Float = minf(game.rhythm_t, beat_period - game.rhythm_t)
  let pulse : Float = 1.0 - clampf(miss / beat_good_window, 0.0, 1.0)

  @raylib.draw_circle_lines(
    x,
    y,
    96.0 + pulse * 12.0,
    @raylib.Color::new(
      248,
      236,
      168,
      (Float::from_int(80) + pulse * 130.0).to_int(),
    ),
  )

  if game.burst_t > 0.0 {
    @raylib.draw_circle_lines(
      x,
      y,
      114.0 + pulse * 16.0,
      @raylib.Color::new(255, 166, 116, 214),
    )
  }
}

///|
fn draw_hud_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    hud_x,
    river_y,
    hud_w,
    river_h,
    @raylib.Color::new(14, 20, 30, 242),
  )
  @raylib.draw_rectangle_lines(
    hud_x,
    river_y,
    hud_w,
    river_h,
    @raylib.Color::new(140, 190, 214, 214),
  )

  @raylib.draw_text(
    "Dragon Boat Sprint",
    hud_x + 22,
    river_y + 20,
    40,
    @raylib.Color::new(238, 248, 255, 244),
  )
  @raylib.draw_text(
    "Festival 2026",
    hud_x + 22,
    river_y + 66,
    24,
    @raylib.Color::new(188, 218, 238, 238),
  )

  let rank_now : Int = if game.state == state_result {
    game.finish_rank
  } else {
    current_rank(game)
  }

  @raylib.draw_text(
    "Distance  " +
    game.distance.to_int().to_string() +
    "m / " +
    finish_distance.to_int().to_string() +
    "m",
    hud_x + 22,
    river_y + 116,
    28,
    @raylib.Color::new(216, 232, 246, 236),
  )
  @raylib.draw_text(
    "Speed     " + game.speed.to_int().to_string() + " m/s",
    hud_x + 22,
    river_y + 150,
    28,
    @raylib.Color::new(216, 232, 246, 236),
  )
  @raylib.draw_text(
    "Rank      #" + rank_now.to_string(),
    hud_x + 22,
    river_y + 184,
    30,
    @raylib.Color::new(252, 232, 162, 244),
  )

  @raylib.draw_text(
    "Score     " + game.score.to_string(),
    hud_x + 22,
    river_y + 224,
    30,
    @raylib.Color::new(254, 246, 210, 244),
  )
  @raylib.draw_text(
    "Streak    " +
    game.streak.to_string() +
    "  (Best " +
    game.best_streak.to_string() +
    ")",
    hud_x + 22,
    river_y + 260,
    28,
    @raylib.Color::new(214, 230, 246, 236),
  )
  @raylib.draw_text(
    "Checkpoints  " +
    game.checkpoint_idx.to_string() +
    "/" +
    checkpoint_count.to_string(),
    hud_x + 22,
    river_y + 294,
    28,
    @raylib.Color::new(214, 230, 246, 236),
  )
  @raylib.draw_text(
    "Debris Hits  " + game.hit_count.to_string(),
    hud_x + 22,
    river_y + 328,
    28,
    @raylib.Color::new(222, 214, 208, 236),
  )

  let meter_x : Int = hud_x + 24
  let meter_y : Int = river_y + 392
  let meter_w : Int = hud_w - 48
  let meter_h : Int = 30

  @raylib.draw_text(
    "Rhythm Meter",
    meter_x,
    meter_y - 32,
    26,
    @raylib.Color::new(230, 238, 248, 236),
  )

  @raylib.draw_rectangle(
    meter_x,
    meter_y,
    meter_w,
    meter_h,
    @raylib.Color::new(36, 50, 66, 230),
  )

  let fill_ratio : Float = clampf(game.rhythm_meter / 100.0, 0.0, 1.0)
  let fill_w : Int = (Float::from_int(meter_w) * fill_ratio).to_int()

  @raylib.draw_rectangle(
    meter_x,
    meter_y,
    fill_w,
    meter_h,
    if game.rhythm_meter >= 100.0 {
      @raylib.Color::new(246, 204, 92, 242)
    } else {
      @raylib.Color::new(132, 224, 250, 236)
    },
  )

  @raylib.draw_rectangle_lines(
    meter_x,
    meter_y,
    meter_w,
    meter_h,
    @raylib.Color::new(182, 214, 236, 222),
  )

  let burst_text : String = if game.burst_t > 0.0 {
    "Burst active: " + (game.burst_t * 10.0).to_int().to_string() + "/10"
  } else if game.rhythm_meter >= 100.0 {
    "Space burst ready"
  } else {
    "Build meter with timed J strokes"
  }

  @raylib.draw_text(
    burst_text,
    meter_x,
    meter_y + 38,
    24,
    @raylib.Color::new(246, 222, 164, 236),
  )

  let beat_x : Int = meter_x
  let beat_y : Int = meter_y + 92
  let beat_w : Int = meter_w
  let beat_h : Int = 18

  @raylib.draw_text(
    "Beat Lane",
    beat_x,
    beat_y - 30,
    24,
    @raylib.Color::new(224, 236, 246, 236),
  )

  @raylib.draw_rectangle(
    beat_x,
    beat_y,
    beat_w,
    beat_h,
    @raylib.Color::new(34, 46, 62, 228),
  )
  @raylib.draw_rectangle(
    beat_x,
    beat_y,
    18,
    beat_h,
    @raylib.Color::new(244, 214, 132, 176),
  )
  @raylib.draw_rectangle(
    beat_x + beat_w - 18,
    beat_y,
    18,
    beat_h,
    @raylib.Color::new(244, 214, 132, 176),
  )

  let phase : Float = clampf(game.rhythm_t / beat_period, 0.0, 1.0)
  let marker_x : Int = beat_x + (Float::from_int(beat_w) * phase).to_int()

  @raylib.draw_line(
    marker_x,
    beat_y - 4,
    marker_x,
    beat_y + beat_h + 4,
    @raylib.Color::new(242, 246, 255, 244),
  )

  @raylib.draw_text(
    "Tap J when marker hits either gold edge",
    beat_x,
    beat_y + 26,
    22,
    @raylib.Color::new(210, 228, 242, 226),
  )

  @raylib.draw_text(
    "Controls",
    hud_x + 24,
    river_y + 584,
    30,
    @raylib.Color::new(238, 246, 255, 242),
  )
  @raylib.draw_text(
    "A/D or Left/Right : Lane steer",
    hud_x + 24,
    river_y + 624,
    24,
    @raylib.Color::new(206, 226, 242, 234),
  )
  @raylib.draw_text(
    "J : Paddle stroke (timing)",
    hud_x + 24,
    river_y + 654,
    24,
    @raylib.Color::new(206, 226, 242, 234),
  )
  @raylib.draw_text(
    "K : Stabilize against waves",
    hud_x + 24,
    river_y + 684,
    24,
    @raylib.Color::new(206, 226, 242, 234),
  )
  @raylib.draw_text(
    "Space : Burst when meter full",
    hud_x + 24,
    river_y + 714,
    24,
    @raylib.Color::new(206, 226, 242, 234),
  )
  @raylib.draw_text(
    "P : Pause    R : Restart",
    hud_x + 24,
    river_y + 744,
    24,
    @raylib.Color::new(206, 226, 242, 234),
  )

  @raylib.draw_text(
    "Festival sprint: rhythm streak boosts top speed.",
    hud_x + 24,
    river_y + 802,
    23,
    @raylib.Color::new(206, 222, 238, 216),
  )
  @raylib.draw_text(
    "Avoid debris, absorb waves, clear checkpoints, win rank.",
    hud_x + 24,
    river_y + 832,
    23,
    @raylib.Color::new(206, 222, 238, 216),
  )
}

///|
fn draw_message_banner(game : Game) -> Unit {
  if game.msg_t <= 0.0 || game.msg == "" {
    return
  }

  let alpha : Int = clampi(
    (Float::from_int(90) + game.msg_t * 120.0).to_int(),
    0,
    230,
  )
  let box_w : Int = 680
  let box_h : Int = 56
  let x : Int = river_x + river_w / 2 - box_w / 2
  let y : Int = river_y + 20

  @raylib.draw_rectangle(
    x,
    y,
    box_w,
    box_h,
    @raylib.Color::new(16, 24, 36, alpha),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    box_w,
    box_h,
    @raylib.Color::new(190, 226, 244, alpha),
  )

  @raylib.draw_text(
    game.msg,
    x + box_w / 2 - @raylib.measure_text(game.msg, 30) / 2,
    y + 13,
    30,
    @raylib.Color::new(246, 252, 255, alpha),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 18, 170),
  )

  let title = "Dragon Boat Sprint Festival"
  @raylib.draw_text(
    title,
    screen_w / 2 - @raylib.measure_text(title, 64) / 2,
    180,
    64,
    @raylib.Color::new(244, 252, 255, 248),
  )

  let sub = "2026"
  @raylib.draw_text(
    sub,
    screen_w / 2 - @raylib.measure_text(sub, 44) / 2,
    250,
    44,
    @raylib.Color::new(255, 220, 150, 240),
  )

  @raylib.draw_text(
    "Steer lanes, sync paddle rhythm, survive waves and debris.",
    screen_w / 2 - 420,
    340,
    36,
    @raylib.Color::new(216, 234, 246, 238),
  )
  @raylib.draw_text(
    "Outrace rivals, clear checkpoints, and sprint to the festival finish.",
    screen_w / 2 - 470,
    390,
    36,
    @raylib.Color::new(216, 234, 246, 238),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 380,
    500,
    760,
    220,
    @raylib.Color::new(18, 30, 44, 216),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 380,
    500,
    760,
    220,
    @raylib.Color::new(180, 216, 238, 224),
  )

  @raylib.draw_text(
    "A/D or Left/Right  steer lane bias",
    screen_w / 2 - 340,
    536,
    30,
    @raylib.Color::new(232, 242, 250, 240),
  )
  @raylib.draw_text(
    "J  paddle stroke on beat edges",
    screen_w / 2 - 340,
    574,
    30,
    @raylib.Color::new(232, 242, 250, 240),
  )
  @raylib.draw_text(
    "K  stabilize during wave impacts",
    screen_w / 2 - 340,
    612,
    30,
    @raylib.Color::new(232, 242, 250, 240),
  )
  @raylib.draw_text(
    "Space burst when rhythm meter is full",
    screen_w / 2 - 340,
    650,
    30,
    @raylib.Color::new(232, 242, 250, 240),
  )

  let start_msg = "Press Enter, J, or Space to start"
  @raylib.draw_text(
    start_msg,
    screen_w / 2 - @raylib.measure_text(start_msg, 42) / 2,
    770,
    42,
    @raylib.Color::new(255, 228, 158, 246),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 14, 20, 180),
  )

  let title = "PAUSED"
  @raylib.draw_text(
    title,
    screen_w / 2 - @raylib.measure_text(title, 86) / 2,
    330,
    86,
    @raylib.Color::new(244, 248, 255, 246),
  )

  let msg = "Press P to resume or R to restart"
  @raylib.draw_text(
    msg,
    screen_w / 2 - @raylib.measure_text(msg, 40) / 2,
    450,
    40,
    @raylib.Color::new(220, 236, 248, 238),
  )
}

///|
fn draw_result_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 20, 170),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 420,
    170,
    840,
    620,
    @raylib.Color::new(16, 24, 38, 234),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 420,
    170,
    840,
    620,
    @raylib.Color::new(180, 216, 236, 226),
  )

  let title = "Festival Finish"
  @raylib.draw_text(
    title,
    screen_w / 2 - @raylib.measure_text(title, 62) / 2,
    220,
    62,
    @raylib.Color::new(246, 252, 255, 246),
  )

  @raylib.draw_text(
    "Rank #" + game.finish_rank.to_string(),
    screen_w / 2 - 110,
    306,
    48,
    @raylib.Color::new(254, 226, 148, 244),
  )

  @raylib.draw_text(
    "Final Score  " + game.score.to_string(),
    screen_w / 2 - 220,
    382,
    42,
    @raylib.Color::new(238, 246, 255, 242),
  )
  @raylib.draw_text(
    "Finish Time  " + game.finish_time.to_int().to_string() + "s",
    screen_w / 2 - 220,
    432,
    38,
    @raylib.Color::new(220, 234, 248, 238),
  )
  @raylib.draw_text(
    "Best Rhythm Streak  " + game.best_streak.to_string(),
    screen_w / 2 - 220,
    478,
    38,
    @raylib.Color::new(220, 234, 248, 238),
  )
  @raylib.draw_text(
    "Checkpoints  " +
    game.checkpoint_idx.to_string() +
    "/" +
    checkpoint_count.to_string(),
    screen_w / 2 - 220,
    524,
    38,
    @raylib.Color::new(220, 234, 248, 238),
  )
  @raylib.draw_text(
    "Debris Hits  " + game.hit_count.to_string(),
    screen_w / 2 - 220,
    570,
    38,
    @raylib.Color::new(220, 234, 248, 238),
  )

  let msg = "Press Enter/J/Space for another run, or R to restart immediately"
  @raylib.draw_text(
    msg,
    screen_w / 2 - @raylib.measure_text(msg, 30) / 2,
    692,
    30,
    @raylib.Color::new(240, 246, 254, 236),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_river_surface(game)
  draw_checkpoint_lines(game)
  draw_hazards(game)
  draw_rivals(game)
  draw_player_boat(game)
  draw_hud_panel(game)
  draw_message_banner(game)

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_pause_overlay()
  } else if game.state == state_result {
    draw_result_overlay(game)
  }
}
