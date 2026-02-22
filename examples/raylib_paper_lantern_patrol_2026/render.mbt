///|
fn draw_centered(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let width = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - width / 2, y, size, color)
}

///|
fn draw_meter(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  value : Float,
  max_value : Float,
  fill : @raylib.Color,
) -> Unit {
  let ratio : Float = if max_value <= 0.0 {
    0.0
  } else {
    clampf(value / max_value, 0.0, 1.0)
  }

  @raylib.draw_text(label, x, y, 21, @raylib.Color::new(220, 228, 242, 244))
  @raylib.draw_rectangle(x, y + 24, w, 18, @raylib.Color::new(24, 30, 42, 244))
  @raylib.draw_rectangle(
    x + 1,
    y + 25,
    (Float::from_int(w - 2) * ratio).to_int(),
    16,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y + 24,
    w,
    18,
    @raylib.Color::new(120, 150, 186, 220),
  )
}

///|
fn shrine_queue_count(game : Game, shrine : Int) -> Int {
  let mut total = 0
  for i in 0..<game.lanterns.length() {
    if game.lanterns[i].active && game.lanterns[i].target_shrine == shrine {
      total = total + 1
    }
  }
  total
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    night_top(),
    night_bottom(),
  )

  for i in 0..<90 {
    let fi = Float::from_int(i)
    let x = (fi * 141.0 + fi * fi * 0.23 + game.run_time * 8.0) %
      Float::from_int(screen_w)
    let y = Float::from_int(play_y) * 0.55 +
      (fi * 89.0 + fi * fi * 0.11 + game.run_time * 1.2) %
      (Float::from_int(screen_h) * 0.55)

    let half = Float::from_int(1) / Float::from_int(2)
    let twinkle : Float = half + half * sinf(fi * 0.9 + game.run_time * 1.6)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      Float::from_int(8) / Float::from_int(10) +
      twinkle * (Float::from_int(14) / Float::from_int(10)),
      @raylib.Color::new(
        176 + (twinkle * 62.0).to_int(),
        206 + (twinkle * 42.0).to_int(),
        255,
        66 + (twinkle * 150.0).to_int(),
      ),
    )
  }

  let moon_x = Float::from_int(screen_w) * 0.82 +
    sinf(game.run_time * 0.18) * 28.0
  let moon_y = Float::from_int(play_y) * 0.78 +
    cosf(game.run_time * 0.22) * 10.0

  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    54.0,
    @raylib.Color::new(210, 224, 250, 64),
  )
  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    30.0,
    @raylib.Color::new(228, 236, 255, 160),
  )
}

///|
fn draw_playfield(game : Game) -> Unit {
  @raylib.draw_rectangle(play_x, play_y, play_w, play_h, street_dark())

  for lane in 0..<7 {
    let y = play_y + 40 + lane * 100
    @raylib.draw_rectangle(
      play_x + 12,
      y,
      play_w - 24,
      62,
      if lane % 2 == 0 {
        street_mid()
      } else {
        a_col(street_mid(), 170)
      },
    )
  }

  for i in 0..<9 {
    let x = play_x + 80 + i * 106
    @raylib.draw_line(
      x,
      play_y + 20,
      x,
      play_y + play_h - 20,
      @raylib.Color::new(72, 80, 102, 95),
    )
  }

  @raylib.draw_rectangle_lines(
    play_x,
    play_y,
    play_w,
    play_h,
    @raylib.Color::new(154, 176, 214, 220),
  )

  @raylib.draw_text(
    "Windy Festival Streets",
    play_x + 18,
    play_y + 14,
    24,
    @raylib.Color::new(206, 224, 246, 240),
  )

  if game.patrol.calm_t > 0.0 {
    @raylib.draw_text(
      "Calm field active",
      play_x + play_w - 214,
      play_y + 14,
      21,
      a_col(calm_col(), 240),
    )
  }
}

///|
fn draw_shrines(game : Game) -> Unit {
  for i in 0..<shrine_count {
    let p = shrine_position(i)
    let queue = shrine_queue_count(game, i)
    let half = Float::from_int(1) / Float::from_int(2)
    let pulse : Float = half +
      half * sinf(game.run_time * 2.4 + Float::from_int(i) * 1.5)

    @raylib.draw_circle(
      p.0.to_int(),
      p.1.to_int(),
      Float::from_int(30) + pulse * Float::from_int(4),
      a_col(shrine_col(), 86 + (pulse * 110.0).to_int()),
    )
    @raylib.draw_circle(
      p.0.to_int(),
      p.1.to_int(),
      20.0,
      @raylib.Color::new(38, 68, 84, 236),
    )
    @raylib.draw_circle_lines(
      p.0.to_int(),
      p.1.to_int(),
      delivery_radius,
      @raylib.Color::new(112, 232, 196, 150),
    )

    @raylib.draw_text(
      "S\{i + 1}",
      p.0.to_int() - 10,
      p.1.to_int() - 10,
      22,
      @raylib.Color::new(216, 246, 236, 240),
    )

    if queue > 0 {
      @raylib.draw_text(
        "x\{queue}",
        p.0.to_int() + 24,
        p.1.to_int() - 12,
        20,
        @raylib.Color::new(246, 216, 150, 236),
      )
    }
  }
}

///|
fn draw_gate() -> Unit {
  let gate = gate_position()

  @raylib.draw_rectangle(
    (gate.0 - 60.0).to_int(),
    (gate.1 - 86.0).to_int(),
    120,
    172,
    @raylib.Color::new(74, 46, 40, 220),
  )
  @raylib.draw_rectangle_lines(
    (gate.0 - 60.0).to_int(),
    (gate.1 - 86.0).to_int(),
    120,
    172,
    @raylib.Color::new(236, 194, 130, 202),
  )
  @raylib.draw_text(
    "GATE",
    (gate.0 - 28.0).to_int(),
    (gate.1 - 14.0).to_int(),
    24,
    @raylib.Color::new(250, 230, 178, 236),
  )
}

///|
fn draw_gusts(game : Game) -> Unit {
  for i in 0..<game.gusts.length() {
    if not(game.gusts[i].active) {
      continue
    }

    let life = clampf(game.gusts[i].life / 9.2, 0.0, 1.0)
    let alpha = (life * 130.0 + 28.0).to_int()
    let col = @raylib.Color::new(124, 196, 240, alpha)

    @raylib.draw_circle_lines(
      game.gusts[i].x.to_int(),
      game.gusts[i].y.to_int(),
      game.gusts[i].radius,
      col,
    )

    @raylib.draw_line(
      game.gusts[i].x.to_int(),
      game.gusts[i].y.to_int(),
      (game.gusts[i].x + game.gusts[i].vx * 0.22).to_int(),
      (game.gusts[i].y + game.gusts[i].vy * 0.22).to_int(),
      col,
    )
  }
}

///|
fn draw_sparks(game : Game) -> Unit {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      continue
    }

    let life = clampf(game.sparks[i].life / 2.8, 0.0, 1.0)
    @raylib.draw_circle(
      game.sparks[i].x.to_int(),
      game.sparks[i].y.to_int(),
      game.sparks[i].size,
      @raylib.Color::new(
        255,
        164 + (life * 70.0).to_int(),
        86,
        (life * 230.0).to_int(),
      ),
    )
  }
}

///|
fn draw_thieves(game : Game) -> Unit {
  for i in 0..<game.thieves.length() {
    if not(game.thieves[i].active) {
      continue
    }

    @raylib.draw_circle(
      game.thieves[i].x.to_int(),
      game.thieves[i].y.to_int(),
      thief_radius,
      @raylib.Color::new(188, 84, 104, 236),
    )
    @raylib.draw_circle_lines(
      game.thieves[i].x.to_int(),
      game.thieves[i].y.to_int(),
      thief_radius + 2.0,
      @raylib.Color::new(250, 164, 176, 238),
    )

    if game.thieves[i].target >= 0 &&
      game.thieves[i].target < game.lanterns.length() &&
      game.lanterns[game.thieves[i].target].active {
      @raylib.draw_line(
        game.thieves[i].x.to_int(),
        game.thieves[i].y.to_int(),
        game.lanterns[game.thieves[i].target].x.to_int(),
        game.lanterns[game.thieves[i].target].y.to_int(),
        @raylib.Color::new(252, 136, 132, 96),
      )
    }
  }
}

///|
fn draw_lanterns(game : Game) -> Unit {
  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) {
      continue
    }

    let target = shrine_position(game.lanterns[i].target_shrine)

    @raylib.draw_line(
      game.lanterns[i].x.to_int(),
      game.lanterns[i].y.to_int(),
      target.0.to_int(),
      target.1.to_int(),
      @raylib.Color::new(146, 182, 212, 58),
    )

    @raylib.draw_rectangle(
      (game.lanterns[i].x - 8.0).to_int(),
      (game.lanterns[i].y - 10.0).to_int(),
      16,
      22,
      lantern_frame_col(),
    )

    @raylib.draw_rectangle(
      (game.lanterns[i].x - 6.0).to_int(),
      (game.lanterns[i].y - 8.0).to_int(),
      12,
      18,
      @raylib.Color::new(246, 238, 198, 228),
    )

    @raylib.draw_circle(
      game.lanterns[i].x.to_int(),
      (game.lanterns[i].y - 12.0 + sinf(game.lanterns[i].wobble) * 1.2).to_int(),
      5.0,
      lantern_flame_col(game.lanterns[i].flame),
    )

    let flame_ratio = clampf(game.lanterns[i].flame / 100.0, 0.0, 1.0)
    @raylib.draw_rectangle(
      (game.lanterns[i].x - 10.0).to_int(),
      (game.lanterns[i].y - 22.0).to_int(),
      20,
      4,
      @raylib.Color::new(34, 44, 64, 210),
    )
    @raylib.draw_rectangle(
      (game.lanterns[i].x - 10.0).to_int(),
      (game.lanterns[i].y - 22.0).to_int(),
      (Float::from_int(20) * flame_ratio).to_int(),
      4,
      lantern_flame_col(game.lanterns[i].flame),
    )

    if game.patrol.escort == i {
      @raylib.draw_circle_lines(
        game.lanterns[i].x.to_int(),
        game.lanterns[i].y.to_int(),
        lantern_radius + 8.0,
        @raylib.Color::new(124, 242, 198, 236),
      )
    }
  }
}

///|
fn draw_patrol(game : Game) -> Unit {
  if game.patrol.calm_t > 0.0 {
    let ratio = clampf(game.patrol.calm_t / calm_duration, 0.0, 1.0)
    @raylib.draw_circle_lines(
      game.patrol.x.to_int(),
      game.patrol.y.to_int(),
      calm_radius * (0.92 + 0.08 * sinf(game.run_time * 7.0)),
      a_col(calm_col(), (ratio * 220.0).to_int()),
    )
  }

  if game.patrol.guard_t > 0.0 {
    let ratio = clampf(game.patrol.guard_t / guard_time, 0.0, 1.0)
    @raylib.draw_circle_lines(
      game.patrol.x.to_int(),
      game.patrol.y.to_int(),
      guard_radius,
      @raylib.Color::new(244, 216, 136, (ratio * 240.0).to_int()),
    )
  }

  if game.patrol.escort >= 0 &&
    game.patrol.escort < game.lanterns.length() &&
    game.lanterns[game.patrol.escort].active {
    @raylib.draw_line(
      game.patrol.x.to_int(),
      game.patrol.y.to_int(),
      game.lanterns[game.patrol.escort].x.to_int(),
      game.lanterns[game.patrol.escort].y.to_int(),
      @raylib.Color::new(146, 238, 208, 200),
    )
  }

  @raylib.draw_circle(
    game.patrol.x.to_int(),
    game.patrol.y.to_int(),
    patrol_radius,
    @raylib.Color::new(224, 232, 246, 246),
  )
  @raylib.draw_circle_lines(
    game.patrol.x.to_int(),
    game.patrol.y.to_int(),
    patrol_radius + 2.0,
    @raylib.Color::new(24, 36, 48, 250),
  )

  @raylib.draw_circle(
    (game.patrol.x + game.patrol.vx * 0.03).to_int(),
    (game.patrol.y + game.patrol.vy * 0.03).to_int(),
    4.0,
    @raylib.Color::new(28, 56, 82, 248),
  )
}

///|
fn draw_status_strip(game : Game) -> Unit {
  if game.status_t <= 0.0 {
    return
  }

  let alpha = (clampf(game.status_t / status_default_t, 0.0, 1.0) * 210.0).to_int()

  @raylib.draw_rectangle(
    play_x + 18,
    play_y + 50,
    play_w - 36,
    42,
    @raylib.Color::new(12, 20, 34, alpha),
  )
  @raylib.draw_rectangle_lines(
    play_x + 18,
    play_y + 50,
    play_w - 36,
    42,
    @raylib.Color::new(140, 198, 246, alpha),
  )

  draw_centered(
    game.status_text,
    play_y + 60,
    23,
    @raylib.Color::new(232, 240, 252, clampi(alpha + 36, 0, 255)),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    hud_x,
    hud_y,
    hud_w,
    hud_h,
    @raylib.Color::new(14, 22, 36, 244),
  )
  @raylib.draw_rectangle_lines(
    hud_x,
    hud_y,
    hud_w,
    hud_h,
    @raylib.Color::new(126, 164, 214, 226),
  )

  @raylib.draw_text(
    "PAPER LANTERN PATROL",
    hud_x + 14,
    hud_y + 16,
    30,
    @raylib.Color::new(236, 242, 254, 248),
  )
  @raylib.draw_text(
    "2026 Festival Night",
    hud_x + 14,
    hud_y + 50,
    21,
    @raylib.Color::new(184, 206, 236, 238),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    hud_x + 14,
    hud_y + 88,
    29,
    @raylib.Color::new(250, 214, 152, 248),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    hud_x + 14,
    hud_y + 120,
    23,
    @raylib.Color::new(214, 230, 248, 238),
  )

  @raylib.draw_text(
    "Deliveries \{game.deliveries}",
    hud_x + 14,
    hud_y + 154,
    22,
    @raylib.Color::new(206, 238, 218, 238),
  )
  @raylib.draw_text(
    "Extinguished \{game.extinguished}/\{extinguish_limit}",
    hud_x + 14,
    hud_y + 182,
    22,
    a_col(danger_col(), 236),
  )
  @raylib.draw_text(
    "Combo x\{maxf(Float::from_int(game.combo), 1.0).to_int()}",
    hud_x + 14,
    hud_y + 210,
    22,
    @raylib.Color::new(236, 222, 132, 236),
  )

  draw_meter(
    "Combo Window",
    hud_x + 14,
    hud_y + 244,
    hud_w - 28,
    game.combo_t,
    combo_window,
    @raylib.Color::new(236, 198, 114, 236),
  )

  let calm_ready : Float = if game.patrol.calm_cd <= 0.0 {
    calm_cooldown
  } else {
    calm_cooldown - game.patrol.calm_cd
  }

  draw_meter(
    "Calm-Wind Cooldown",
    hud_x + 14,
    hud_y + 304,
    hud_w - 28,
    calm_ready,
    calm_cooldown,
    calm_col(),
  )

  draw_meter(
    "Guard Stance",
    hud_x + 14,
    hud_y + 364,
    hud_w - 28,
    game.patrol.guard_t,
    guard_time,
    @raylib.Color::new(244, 206, 136, 236),
  )

  @raylib.draw_text(
    "Active Lanterns \{active_lantern_count(game)}",
    hud_x + 14,
    hud_y + 428,
    21,
    @raylib.Color::new(220, 236, 220, 236),
  )
  @raylib.draw_text(
    "Gusts \{active_gust_count(game)}  Thieves \{active_thief_count(game)}",
    hud_x + 14,
    hud_y + 454,
    21,
    @raylib.Color::new(220, 236, 220, 236),
  )

  @raylib.draw_text(
    "Controls",
    hud_x + 14,
    hud_y + 502,
    24,
    @raylib.Color::new(238, 244, 255, 246),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    hud_x + 14,
    hud_y + 534,
    20,
    @raylib.Color::new(212, 226, 246, 238),
  )
  @raylib.draw_text(
    "J: Interact / Escort / Pickup",
    hud_x + 14,
    hud_y + 560,
    20,
    @raylib.Color::new(212, 226, 246, 238),
  )
  @raylib.draw_text(
    "K: Cancel escort / Guard",
    hud_x + 14,
    hud_y + 586,
    20,
    @raylib.Color::new(212, 226, 246, 238),
  )
  @raylib.draw_text(
    "Space: Calm-wind field",
    hud_x + 14,
    hud_y + 612,
    20,
    @raylib.Color::new(212, 226, 246, 238),
  )
  @raylib.draw_text(
    "P: Pause    R: Restart",
    hud_x + 14,
    hud_y + 638,
    20,
    @raylib.Color::new(212, 226, 246, 238),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 24, 170),
  )

  draw_centered(
    "Paper Lantern Patrol 2026",
    164,
    66,
    @raylib.Color::new(236, 246, 255, 252),
  )
  draw_centered(
    "Night festival routes are unstable: wind, sparks, and thieves roam the streets.",
    248,
    30,
    @raylib.Color::new(210, 226, 246, 244),
  )
  draw_centered(
    "Escort lanterns to shrines. Chain safe deliveries before too many flames go out.",
    286,
    30,
    @raylib.Color::new(210, 226, 246, 244),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    340,
    720,
    198,
    @raylib.Color::new(12, 22, 40, 200),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 360,
    340,
    720,
    198,
    @raylib.Color::new(146, 198, 248, 222),
  )

  draw_centered(
    "J escort/pickup  K drop/guard  SPACE calm field  P pause  R restart",
    392,
    29,
    @raylib.Color::new(234, 240, 252, 244),
  )
  draw_centered(
    "Press J, Space, or Enter to start patrol",
    442,
    35,
    @raylib.Color::new(255, 226, 148, 250),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 20, 172),
  )
  draw_centered("PAUSED", 290, 78, @raylib.Color::new(242, 248, 255, 250))
  draw_centered(
    "Press P to continue patrol, R to restart run",
    388,
    34,
    @raylib.Color::new(216, 228, 246, 244),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(26, 8, 16, 186),
  )
  draw_centered("RUN OVER", 238, 78, @raylib.Color::new(252, 186, 186, 252))
  draw_centered(
    game.game_over_reason,
    332,
    34,
    @raylib.Color::new(252, 224, 214, 244),
  )
  draw_centered(
    "Delivered \{game.deliveries} lanterns   Score \{game.score}",
    390,
    34,
    @raylib.Color::new(236, 246, 226, 244),
  )
  draw_centered(
    "Best \{game.best_score}   Extinguished \{game.extinguished}",
    432,
    32,
    @raylib.Color::new(236, 246, 226, 244),
  )
  draw_centered(
    "Press R, J, or Enter to restart",
    502,
    36,
    @raylib.Color::new(255, 226, 148, 250),
  )
}

///|
fn draw_flash(game : Game) -> Unit {
  if game.screen_flash_t <= 0.0 {
    return
  }

  let alpha = (clampf(game.screen_flash_t / 0.28, 0.0, 1.0) * 130.0).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(255, 152, 118, alpha),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  @raylib.clear_background(night_top())

  draw_background(game)
  draw_playfield(game)
  draw_shrines(game)
  draw_gate()
  draw_gusts(game)
  draw_sparks(game)
  draw_thieves(game)
  draw_lanterns(game)
  draw_patrol(game)
  draw_status_strip(game)
  draw_hud(game)

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }

  draw_flash(game)
}
