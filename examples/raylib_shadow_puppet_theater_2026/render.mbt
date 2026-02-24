///|
let stage_screen_x : Int = 248

///|
let stage_screen_y : Int = 126

///|
let stage_screen_w : Int = 980

///|
let stage_screen_h : Int = 682

///|
fn draw_thick_line(
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_line(x0, y0, x1, y1, color)
  @raylib.draw_line(x0 + 1, y0, x1 + 1, y1, color)
  @raylib.draw_line(x0 - 1, y0, x1 - 1, y1, color)
}

///|
fn draw_backdrop(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 8, 14, 255))

  for i = 0; i < 13; i = i + 1 {
    let wave : Float = sinf(game.scene_t * 0.42 + Float::from_int(i) * 0.57) *
      10.0
    let y = i * 82 + wave.to_int()
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      56,
      @raylib.Color::new(18 + i * 2 % 20, 12 + i * 3 % 16, 26 + i * 4 % 20, 70),
    )
  }

  let curtain_wave_f : Float = sinf(game.scene_t * 1.05) * 10.0
  let curtain_wave = curtain_wave_f.to_int()

  @raylib.draw_rectangle(
    0,
    0,
    170 + curtain_wave,
    screen_h,
    @raylib.Color::new(66, 18, 26, 255),
  )
  @raylib.draw_rectangle(
    screen_w - 170 - curtain_wave,
    0,
    170 + curtain_wave,
    screen_h,
    @raylib.Color::new(66, 18, 26, 255),
  )

  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    72,
    @raylib.Color::new(24, 10, 16, 255),
  )
  @raylib.draw_rectangle(
    0,
    screen_h - 100,
    screen_w,
    100,
    @raylib.Color::new(16, 10, 14, 255),
  )
}

///|
fn draw_spotlight(game : Game) -> Unit {
  let cx = stage_screen_x + stage_screen_w / 2
  let cy = stage_screen_y + stage_screen_h / 2 - 26

  let pulse : Float = 0.5 + 0.5 * sinf(game.beat_t * 2.15)
  let radius : Float = 272.0 + game.spotlight * 2.32 + pulse * 28.0
  let glow_f : Float = 48.0 + game.spotlight * 1.65
  let glow_alpha = clampi(glow_f.to_int(), 54, 230)
  let inner_radius : Float = radius * 0.62

  @raylib.draw_circle(
    cx,
    cy,
    radius,
    @raylib.Color::new(248, 236, 188, glow_alpha),
  )
  @raylib.draw_circle(
    cx,
    cy - 16,
    inner_radius,
    @raylib.Color::new(252, 246, 224, glow_alpha / 2),
  )
}

///|
fn draw_stage_screen(game : Game) -> Unit {
  let warmth_f : Float = 170.0 + game.excitement * 0.72
  let alpha_f : Float = 126.0 + game.spotlight * 1.1
  let warmth = clampi(warmth_f.to_int(), 162, 246)
  let alpha = clampi(alpha_f.to_int(), 120, 236)

  @raylib.draw_rectangle(
    stage_screen_x,
    stage_screen_y,
    stage_screen_w,
    stage_screen_h,
    @raylib.Color::new(warmth, warmth - 22, warmth - 64, alpha),
  )

  for i = 0; i < 16; i = i + 1 {
    let y = stage_screen_y + 14 + i * 42
    @raylib.draw_line(
      stage_screen_x + 12,
      y,
      stage_screen_x + stage_screen_w - 12,
      y,
      @raylib.Color::new(110, 86, 62, 44),
    )
  }

  @raylib.draw_rectangle_lines(
    stage_screen_x - 6,
    stage_screen_y - 6,
    stage_screen_w + 12,
    stage_screen_h + 12,
    @raylib.Color::new(224, 186, 136, 232),
  )
  @raylib.draw_rectangle_lines(
    stage_screen_x - 18,
    stage_screen_y - 18,
    stage_screen_w + 36,
    stage_screen_h + 36,
    @raylib.Color::new(126, 78, 52, 190),
  )
}

///|
fn draw_pose_shadow(
  x : Int,
  y : Int,
  scale : Float,
  pose : Pose,
  body : @raylib.Color,
  accent : @raylib.Color,
) -> Unit {
  let fx : Float = Float::from_int(x)
  let fy : Float = Float::from_int(y)
  let ax : Float = Float::from_int(pose.ax)
  let ay : Float = Float::from_int(pose.ay)

  let head_y_f : Float = fy - 126.0 * scale
  let head_y = head_y_f.to_int()
  let head_r : Float = 23.0 * scale

  let torso_w_f : Float = 72.0 * scale
  let torso_h_f : Float = 152.0 * scale
  let torso_y_f : Float = fy - 58.0 * scale
  let torso_w = torso_w_f.to_int()
  let torso_h = torso_h_f.to_int()
  let torso_y = torso_y_f.to_int()

  @raylib.draw_circle(x, head_y, head_r, body)
  @raylib.draw_rectangle(x - torso_w / 2, torso_y, torso_w, torso_h, body)

  let shoulder_lx = (fx - 32.0 * scale).to_int()
  let shoulder_rx = (fx + 32.0 * scale).to_int()
  let shoulder_y = (fy - 40.0 * scale).to_int()

  let lift = ay * 23.0 * scale
  let spread = ax * 20.0 * scale
  let twist = ay * 6.0 * scale

  let left_hand_x = (fx - (66.0 * scale + spread) + twist).to_int()
  let left_hand_y = (Float::from_int(shoulder_y) -
  18.0 * scale -
  lift -
  ax * 4.0 * scale).to_int()
  let right_hand_x = (fx + (66.0 * scale + spread) + twist).to_int()
  let right_hand_y = (Float::from_int(shoulder_y) -
  18.0 * scale -
  lift +
  ax * 4.0 * scale).to_int()

  draw_thick_line(shoulder_lx, shoulder_y, left_hand_x, left_hand_y, body)
  draw_thick_line(shoulder_rx, shoulder_y, right_hand_x, right_hand_y, body)
  @raylib.draw_circle(left_hand_x, left_hand_y, 8.0 * scale, body)
  @raylib.draw_circle(right_hand_x, right_hand_y, 8.0 * scale, body)

  let hip_y = (fy + 62.0 * scale).to_int()
  let foot_y = (fy + (150.0 + absf(ax) * 8.0) * scale).to_int()
  let left_foot_x = (fx - (40.0 + ay * 9.0) * scale).to_int()
  let right_foot_x = (fx + (40.0 + ay * 9.0) * scale).to_int()
  let hip_offset_f : Float = 20.0 * scale
  let hip_offset = hip_offset_f.to_int()

  draw_thick_line(x - hip_offset, hip_y, left_foot_x, foot_y, body)
  draw_thick_line(x + hip_offset, hip_y, right_foot_x, foot_y, body)

  let fan_tip_x = (fx + ax * 16.0 * scale).to_int()
  let fan_tip_y = (fy - (188.0 + ay * 8.0) * scale).to_int()
  let fan_half_w_f : Float = 24.0 * scale
  let fan_half_h_f : Float = 18.0 * scale
  let fan_half_w = fan_half_w_f.to_int()
  let fan_half_h = fan_half_h_f.to_int()

  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(fan_tip_x), Float::from_int(fan_tip_y)),
    @raylib.Vector2::new(
      Float::from_int(fan_tip_x - fan_half_w),
      Float::from_int(fan_tip_y + fan_half_h),
    ),
    @raylib.Vector2::new(
      Float::from_int(fan_tip_x + fan_half_w),
      Float::from_int(fan_tip_y + fan_half_h),
    ),
    accent,
  )
}

///|
fn draw_active_stage_pose(game : Game) -> Unit {
  let cx = stage_screen_x + stage_screen_w / 2
  let cy = stage_screen_y + stage_screen_h / 2 + 88
  let target = target_pose(game)

  let target_alpha = if game.state == state_play || game.state == state_paused {
    132
  } else {
    96
  }

  draw_pose_shadow(
    cx,
    cy,
    1.06,
    target,
    @raylib.Color::new(74, 56, 46, target_alpha),
    @raylib.Color::new(120, 96, 62, target_alpha),
  )

  let body_color = if game.state == state_result {
    @raylib.Color::new(20, 20, 24, 190)
  } else {
    @raylib.Color::new(16, 16, 22, 238)
  }
  draw_pose_shadow(
    cx,
    cy,
    1.0,
    game.current_pose,
    body_color,
    @raylib.Color::new(38, 30, 24, 230),
  )

  let cue_ratio : Float = if game.cue_time_limit <= 0.0 {
    0.0
  } else {
    clampf(game.cue_time_left / game.cue_time_limit, 0.0, 1.0)
  }
  let ring_alpha_f : Float = 45.0 + cue_ratio * 180.0
  let ring_alpha = clampi(ring_alpha_f.to_int(), 30, 225)
  let ring_radius : Float = 228.0 + sinf(game.beat_t * 1.6) * 8.0
  @raylib.draw_circle_lines(
    cx,
    cy,
    ring_radius,
    @raylib.Color::new(248, 208, 126, ring_alpha),
  )
}

///|
fn draw_audience(game : Game) -> Unit {
  let base_y = screen_h - 34
  let cheer_amp : Float = 2.0 + game.excitement * 0.12

  for i = 0; i < 22; i = i + 1 {
    let x = 42 + i * 74
    let bounce_f : Float = sinf(game.scene_t * 2.6 + Float::from_int(i) * 0.44) *
      cheer_amp
    let bounce = bounce_f.to_int()
    let y = base_y - bounce

    @raylib.draw_circle(
      x,
      y,
      26.0,
      @raylib.Color::new(20 + i * 3 % 22, 20 + i * 2 % 26, 28 + i * 5 % 24, 255),
    )

    let eye_color = if game.excitement > 70.0 {
      @raylib.Color::new(250, 214, 136, 232)
    } else {
      @raylib.Color::new(198, 196, 188, 210)
    }
    @raylib.draw_circle(x - 8, y - 4, 2.8, eye_color)
    @raylib.draw_circle(x + 8, y - 4, 2.8, eye_color)
  }
}

///|
fn draw_sequence_strip(game : Game) -> Unit {
  let total = game.sequence.length()
  if total <= 0 {
    return
  }

  let card_w = 112
  let card_h = 146
  let gap = 14
  let full_w = total * card_w + (total - 1) * gap
  let start_x = stage_screen_x + stage_screen_w / 2 - full_w / 2
  let y = 28

  for i = 0; i < total; i = i + 1 {
    let x = start_x + i * (card_w + gap)

    let frame = if i < game.target_idx {
      @raylib.Color::new(122, 234, 156, 240)
    } else if i == game.target_idx && game.state == state_play {
      @raylib.Color::new(246, 222, 142, 244)
    } else {
      @raylib.Color::new(162, 150, 136, 220)
    }

    let fill = if i < game.target_idx {
      @raylib.Color::new(24, 56, 38, 210)
    } else if i == game.target_idx && game.state == state_play {
      @raylib.Color::new(64, 46, 24, 210)
    } else {
      @raylib.Color::new(42, 34, 32, 186)
    }

    @raylib.draw_rectangle(x, y, card_w, card_h, fill)
    @raylib.draw_rectangle_lines(x, y, card_w, card_h, frame)

    draw_pose_shadow(
      x + card_w / 2,
      y + 108,
      0.29,
      game.sequence[i],
      @raylib.Color::new(220, 214, 204, 224),
      @raylib.Color::new(180, 162, 132, 198),
    )

    @raylib.draw_text(
      (i + 1).to_string(),
      x + 8,
      y + 8,
      20,
      @raylib.Color::new(240, 236, 228, 220),
    )
  }
}

///|
fn draw_meter(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  value : Float,
  max_value : Float,
  fg : @raylib.Color,
  bg : @raylib.Color,
) -> Unit {
  let ratio : Float = if max_value <= 0.0 {
    0.0
  } else {
    clampf(value / max_value, 0.0, 1.0)
  }
  let fill_w : Int = (Float::from_int(w) * ratio).to_int()

  @raylib.draw_text(label, x, y, 22, @raylib.Color::new(246, 242, 234, 255))
  @raylib.draw_rectangle(x, y + 27, w, 16, bg)
  @raylib.draw_rectangle(x, y + 27, fill_w, 16, fg)
  @raylib.draw_rectangle_lines(
    x,
    y + 27,
    w,
    16,
    @raylib.Color::new(244, 236, 226, 120),
  )
}

///|
fn draw_hud_panel(game : Game) -> Unit {
  let panel_x = stage_screen_x + stage_screen_w + 24
  let panel_y = 24
  let panel_w = screen_w - panel_x - 20
  let panel_h = screen_h - 48

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(22, 18, 26, 216),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(196, 168, 140, 226),
  )

  @raylib.draw_text(
    "SHADOW PUPPET",
    panel_x + 20,
    panel_y + 14,
    30,
    @raylib.Color::new(250, 232, 188, 250),
  )
  @raylib.draw_text(
    "Scene " + game.stage.to_string(),
    panel_x + 22,
    panel_y + 56,
    26,
    @raylib.Color::new(236, 222, 200, 240),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x + 22,
    panel_y + 94,
    24,
    @raylib.Color::new(244, 236, 220, 236),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x + 22,
    panel_y + 124,
    22,
    @raylib.Color::new(190, 182, 170, 230),
  )

  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    panel_x + 22,
    panel_y + 162,
    28,
    @raylib.Color::new(250, 208, 126, 248),
  )
  @raylib.draw_text(
    "Best combo x" + game.best_combo.to_string(),
    panel_x + 22,
    panel_y + 198,
    21,
    @raylib.Color::new(216, 202, 184, 230),
  )

  draw_meter(
    "Spotlight",
    panel_x + 20,
    panel_y + 240,
    panel_w - 40,
    game.spotlight,
    spotlight_max,
    @raylib.Color::new(246, 216, 126, 238),
    @raylib.Color::new(68, 50, 34, 220),
  )
  draw_meter(
    "Excitement",
    panel_x + 20,
    panel_y + 302,
    panel_w - 40,
    game.excitement,
    excitement_max,
    @raylib.Color::new(122, 234, 170, 238),
    @raylib.Color::new(26, 62, 54, 220),
  )

  let burst_ready : Float = if game.burst_cd <= 0.0 {
    1.0
  } else {
    1.0 - clampf(game.burst_cd / burst_cooldown, 0.0, 1.0)
  }
  draw_meter(
    "Burst Ready",
    panel_x + 20,
    panel_y + 364,
    panel_w - 40,
    burst_ready,
    1.0,
    @raylib.Color::new(138, 198, 255, 235),
    @raylib.Color::new(34, 48, 70, 220),
  )

  let cue_ratio : Float = if game.cue_time_limit <= 0.0 {
    0.0
  } else {
    clampf(game.cue_time_left / game.cue_time_limit, 0.0, 1.0)
  }
  let cue_color = if cue_ratio > 0.5 {
    @raylib.Color::new(128, 240, 176, 236)
  } else if cue_ratio > 0.25 {
    @raylib.Color::new(252, 210, 116, 238)
  } else {
    @raylib.Color::new(248, 110, 98, 238)
  }
  draw_meter(
    "Cue Timer",
    panel_x + 20,
    panel_y + 426,
    panel_w - 40,
    cue_ratio,
    1.0,
    cue_color,
    @raylib.Color::new(64, 44, 42, 220),
  )

  let target = target_pose(game)
  @raylib.draw_text(
    "Current Pose: (" +
    game.current_pose.ax.to_string() +
    ", " +
    game.current_pose.ay.to_string() +
    ")",
    panel_x + 20,
    panel_y + 490,
    21,
    @raylib.Color::new(238, 236, 228, 240),
  )
  @raylib.draw_text(
    "Target Pose: (" +
    target.ax.to_string() +
    ", " +
    target.ay.to_string() +
    ")",
    panel_x + 20,
    panel_y + 520,
    21,
    @raylib.Color::new(244, 210, 148, 240),
  )

  @raylib.draw_text(
    "Hits " +
    game.hit_count.to_string() +
    "   Misses " +
    game.miss_count.to_string(),
    panel_x + 20,
    panel_y + 554,
    20,
    @raylib.Color::new(214, 208, 198, 230),
  )
  @raylib.draw_text(
    "Slowdown " + (active_slow_factor(game) * 100.0).to_int().to_string() + "%",
    panel_x + 20,
    panel_y + 584,
    20,
    @raylib.Color::new(188, 202, 232, 234),
  )
}

///|
fn draw_controls_strip() -> Unit {
  @raylib.draw_rectangle(
    0,
    screen_h - 100,
    screen_w,
    100,
    @raylib.Color::new(18, 12, 16, 238),
  )

  @raylib.draw_text(
    "Arrows/WASD move pose axes   J lock pose   K undo last lock",
    34,
    screen_h - 76,
    26,
    @raylib.Color::new(244, 236, 220, 240),
  )
  @raylib.draw_text(
    "SPACE spotlight burst (slowdown)   P pause   R restart",
    34,
    screen_h - 42,
    24,
    @raylib.Color::new(216, 208, 192, 236),
  )
}

///|
fn draw_message_banner(game : Game) -> Unit {
  if game.message_t <= 0.0 {
    return
  }

  let alpha_f : Float = game.message_t * 220.0
  let alpha = clampi(alpha_f.to_int(), 0, 230)
  let w = 840
  let h = 46
  let x = screen_w / 2 - w / 2
  let y = 86

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(26, 18, 22, alpha))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(248, 214, 156, alpha),
  )
  @raylib.draw_text(
    game.message,
    x + 20,
    y + 11,
    26,
    @raylib.Color::new(250, 240, 220, alpha),
  )
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 8, 14, 170),
  )

  @raylib.draw_text(
    "SHADOW PUPPET THEATER 2026",
    320,
    220,
    64,
    @raylib.Color::new(250, 230, 176, 255),
  )
  @raylib.draw_text(
    "Recreate each silhouette sequence under pressure.",
    424,
    314,
    34,
    @raylib.Color::new(242, 234, 220, 246),
  )
  @raylib.draw_text(
    "Perfect locks raise audience excitement; mistakes drain spotlight energy.",
    306,
    360,
    28,
    @raylib.Color::new(212, 206, 198, 240),
  )
  @raylib.draw_text(
    "ENTER / J / SPACE to start",
    548,
    460,
    38,
    @raylib.Color::new(252, 214, 132, 255),
  )
  @raylib.draw_text(
    "Best Score " +
    game.best_score.to_string() +
    "    Best Combo x" +
    game.best_combo.to_string(),
    514,
    518,
    30,
    @raylib.Color::new(232, 222, 206, 244),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 10, 16, 150),
  )
  @raylib.draw_text(
    "PAUSED",
    screen_w / 2 - 128,
    screen_h / 2 - 70,
    84,
    @raylib.Color::new(248, 234, 194, 255),
  )
  @raylib.draw_text(
    "Press P to resume",
    screen_w / 2 - 176,
    screen_h / 2 + 18,
    36,
    @raylib.Color::new(236, 226, 210, 246),
  )
}

///|
fn draw_result_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 8, 12, 176),
  )

  let rise_f : Float = sinf(game.result_t * 2.6) * 8.0
  let rise = rise_f.to_int()
  @raylib.draw_text(
    "CURTAIN FALL",
    520,
    214 + rise,
    72,
    @raylib.Color::new(252, 224, 170, 255),
  )
  @raylib.draw_text(
    "Final Score " + game.score.to_string(),
    612,
    334,
    42,
    @raylib.Color::new(246, 240, 226, 250),
  )
  @raylib.draw_text(
    "Scene " +
    game.stage.to_string() +
    "   Best Combo x" +
    game.best_combo.to_string(),
    582,
    390,
    34,
    @raylib.Color::new(228, 216, 196, 244),
  )
  @raylib.draw_text(
    "Hits " +
    game.hit_count.to_string() +
    "   Misses " +
    game.miss_count.to_string(),
    642,
    438,
    30,
    @raylib.Color::new(212, 206, 198, 240),
  )
  @raylib.draw_text(
    "Press R / ENTER / J / SPACE to restart",
    454,
    520,
    32,
    @raylib.Color::new(252, 206, 132, 252),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_backdrop(game)
  draw_spotlight(game)
  draw_stage_screen(game)
  draw_active_stage_pose(game)
  draw_audience(game)
  draw_sequence_strip(game)
  draw_hud_panel(game)
  draw_controls_strip()
  draw_message_banner(game)

  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_result {
    draw_result_overlay(game)
  }
}
