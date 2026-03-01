///|
fn draw_duelist(
  x : Int,
  y : Int,
  stance : Int,
  lane_x : Int,
  lane_y : Int,
  body : @raylib.Color,
  accent : @raylib.Color,
  guard_flash_t : Float,
) -> Unit {
  let lean = lane_x * 10
  let lift = lane_y * 7

  let head_x = x + lean
  let head_y = y - 154 + lift
  let torso_x = x - 42 + lean
  let torso_y = y - 122 + lift

  @raylib.draw_circle(head_x, head_y, 30.0, body)
  @raylib.draw_rectangle(torso_x, torso_y, 84, 186, body)

  let shoulder_y = y - 66 + lift
  let mut left_hand_x = x - 98 + lean
  let mut left_hand_y = y - 22 + lift
  let mut right_hand_x = x + 98 + lean
  let mut right_hand_y = y - 22 + lift

  if stance == @types.stance_spear {
    left_hand_y = left_hand_y - 42
    right_hand_y = right_hand_y - 64
    right_hand_x = right_hand_x + 28
  } else if stance == @types.stance_fan {
    left_hand_y = left_hand_y - 20
    right_hand_y = right_hand_y - 44
    right_hand_x = right_hand_x + 18
  } else if stance == @types.stance_guard {
    left_hand_y = left_hand_y - 8
    right_hand_y = right_hand_y - 8
    left_hand_x = left_hand_x + 14
    right_hand_x = right_hand_x - 14
  } else {
    left_hand_y = left_hand_y - 44
    left_hand_x = left_hand_x - 22
    right_hand_y = right_hand_y - 18
  }

  @raylib.draw_line(head_x - 30, shoulder_y, left_hand_x, left_hand_y, body)
  @raylib.draw_line(head_x + 30, shoulder_y, right_hand_x, right_hand_y, body)
  @raylib.draw_circle(left_hand_x, left_hand_y, 10.0, body)
  @raylib.draw_circle(right_hand_x, right_hand_y, 10.0, body)

  let hip_y = y + 62 + lift
  @raylib.draw_line(
    x - 18 + lean, hip_y, x - 52 + lean, y + 188 + lift, body,
  )
  @raylib.draw_line(
    x + 18 + lean, hip_y, x + 52 + lean, y + 188 + lift, body,
  )

  if stance == @types.stance_spear {
    @raylib.draw_line(
      right_hand_x,
      right_hand_y,
      right_hand_x + 80,
      right_hand_y - 44,
      accent,
    )
    @raylib.draw_circle(right_hand_x + 84, right_hand_y - 46, 6.0, accent)
  } else if stance == @types.stance_fan {
    @raylib.draw_circle(right_hand_x + 22, right_hand_y - 2, 18.0, accent)
  } else if stance == @types.stance_guard {
    @raylib.draw_rectangle(x - 40 + lean, y - 52 + lift, 80, 72, accent)
  } else {
    @raylib.draw_line(
      left_hand_x,
      left_hand_y,
      left_hand_x - 64,
      left_hand_y + 34,
      accent,
    )
    @raylib.draw_line(
      left_hand_x,
      left_hand_y,
      left_hand_x - 68,
      left_hand_y - 10,
      accent,
    )
  }

  if guard_flash_t > 0.0 {
    let glow_a = @types.clampi((guard_flash_t * 360.0).to_int(), 60, 210)
    @raylib.draw_circle_lines(
      head_x,
      y - 28 + lift,
      112.0,
      @types.col(152, 234, 184, glow_a),
    )
  }
}

///|
fn draw_backdrop(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.col(14, 15, 24, 255))

  for i in 0..<13 {
    let wave = @types.sinf(
      game.crowd_wave_t * 0.38 + Float::from_int(i) * 0.37,
    )
    let y = i * 78 + (wave * 12.0).to_int()
    let c = 20 + i * 7 % 24
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      52,
      @types.col(c + 10, c + 4, c + 20, 120),
    )
  }

  @raylib.draw_rectangle(
    @types.stage_left,
    @types.stage_top,
    @types.stage_w,
    @types.stage_h,
    @types.col(36, 27, 42, 245),
  )
  @raylib.draw_rectangle_lines(
    @types.stage_left - 8,
    @types.stage_top - 8,
    @types.stage_w + 16,
    @types.stage_h + 16,
    @types.col(212, 166, 124, 230),
  )
  @raylib.draw_rectangle_lines(
    @types.stage_left - 22,
    @types.stage_top - 22,
    @types.stage_w + 44,
    @types.stage_h + 44,
    @types.col(97, 64, 52, 210),
  )

  for i in 0..<9 {
    let y = @types.stage_top + 70 + i * 70
    @raylib.draw_line(
      @types.stage_left + 20,
      y,
      @types.stage_left + @types.stage_w - 20,
      y,
      @types.col(82, 64, 70, 88),
    )
  }
}

///|
fn draw_lane_grid(game : @types.Game) -> Unit {
  for yi in 0..<3 {
    let ly = yi - 1
    for xi in 0..<3 {
      let lx = xi - 1
      let x = @types.lane_to_x(lx)
      let y = @types.lane_to_y(ly)
      let active = lx == game.lane_x && ly == game.lane_y
      let tint = if active {
        @types.col(255, 238, 190, 255)
      } else {
        @types.col(121, 112, 134, 210)
      }
      @raylib.draw_circle_lines(x, y, 44.0, tint)
      @raylib.draw_circle(x, y, if active { 8.0 } else { 5.0 }, tint)
    }
  }
}

///|
fn draw_stage_actors(game : @types.Game) -> Unit {
  let rival_stance = if game.prompt_active {
    game.prompt.stance
  } else {
    (game.crowd_wave_t * 1.2).to_int() % @types.stance_count
  }

  let rival_pulse : Float = 0.5 +
    0.5 * @types.sinf(game.crowd_wave_t * 2.1)
  let rival_glow : Float = 110.0 + rival_pulse * 110.0
  let rival_glow_a = @types.clampi(rival_glow.to_int(), 90, 220)

  @raylib.draw_circle(
    1170, 370, 132.0, @types.col(160, 84, 98, rival_glow_a),
  )
  @raylib.draw_circle(420, 370, 118.0, @types.col(74, 122, 160, 130))

  draw_duelist(
    430,
    620,
    game.stance,
    game.lane_x,
    game.lane_y,
    @types.col(212, 223, 230, 255),
    @types.stance_color(game.stance, 255),
    game.guard_flash_t,
  )

  draw_duelist(
    1160,
    620,
    rival_stance,
    -game.lane_x,
    0,
    @types.col(68, 47, 62, 255),
    @types.stance_color(rival_stance, 250),
    0.0,
  )

  @raylib.draw_text(
    "Your Troupe", 322, 790, 26, @types.col(219, 228, 236, 245),
  )
  @raylib.draw_text(
    "Rival Troupe", 1075, 790, 26, @types.col(234, 194, 162, 245),
  )
}

///|
fn draw_focus_cursor(game : @types.Game) -> Unit {
  let x = @types.lane_to_x(game.lane_x)
  let y = @types.lane_to_y(game.lane_y)
  let pulse : Float = 0.5 + 0.5 * @types.sinf(game.crowd_wave_t * 4.4)
  let radius : Float = 56.0 + pulse * 7.0

  @raylib.draw_circle_lines(x, y, radius, @types.col(255, 243, 210, 245))
  @raylib.draw_circle_lines(
    x, y, radius + 10.0, @types.stance_color(game.stance, 220),
  )

  let stance_text = "Stance: " + @types.stance_name(game.stance)
  let tx = x - @raylib.measure_text(stance_text, 20) / 2
  @raylib.draw_text(
    stance_text, tx, y + 62, 20, @types.stance_color(game.stance, 240),
  )
}

///|
fn draw_active_prompt(game : @types.Game) -> Unit {
  if not(game.prompt_active) {
    @types.draw_center_text(
      "Listen for the next drum cue...",
      @types.stage_top + @types.stage_h / 2 - 16,
      28,
      @types.col(203, 191, 178, 160),
    )
    return
  }

  let px = @types.lane_to_x(game.prompt.lane_x)
  let py = @types.lane_to_y(game.prompt.lane_y)

  let progress = @types.clampf(
    1.0 - game.prompt.time_left / @types.prompt_lead_time,
    0.0,
    1.0,
  )
  let radius : Float = 196.0 - progress * 156.0
  let urgency : Float = 1.0 -
    @types.clampf(
      @types.absf(game.prompt.time_left) / @types.timing_miss,
      0.0,
      1.0,
    )
  let glow_f : Float = 96.0 + urgency * 150.0
  let glow = @types.clampi(glow_f.to_int(), 86, 246)

  let cue_color = @types.stance_color(game.prompt.stance, glow)
  @raylib.draw_circle_lines(px, py, radius, cue_color)
  @raylib.draw_circle_lines(
    px,
    py,
    @types.maxf(18.0, radius - 22.0),
    @types.col(246, 234, 214, glow),
  )
  @raylib.draw_circle(
    px, py, 20.0, @types.stance_color(game.prompt.stance, 170),
  )

  let stance_text = @types.stance_name(game.prompt.stance)
  let tw = @raylib.measure_text(stance_text, 26)
  @raylib.draw_text(
    stance_text, px - tw / 2, py - 14, 26, @types.col(24, 20, 28, 230),
  )

  let timing_text = if @types.absf(game.prompt.time_left) <=
    @types.timing_perfect {
    "PERFECT"
  } else if @types.absf(game.prompt.time_left) <= @types.timing_good {
    "GOOD"
  } else {
    "INCOMING"
  }
  @types.draw_center_text(timing_text, @types.stage_top + 18, 28, cue_color)
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  max_value : Float,
  label : String,
  fill : @raylib.Color,
) -> Unit {
  let ratio = @types.clampf(value / max_value, 0.0, 1.0)
  let fill_w = (Float::from_int(w - 4) * ratio).to_int()

  @raylib.draw_rectangle(x, y, w, h, @types.col(20, 19, 26, 220))
  @raylib.draw_rectangle(x + 2, y + 2, fill_w, h - 4, fill)
  @raylib.draw_rectangle_lines(x, y, w, h, @types.col(227, 214, 194, 240))

  let value_i = value.to_int()
  @raylib.draw_text(
    label + " " + value_i.to_string(),
    x + 8,
    y + 6,
    18,
    @types.col(250, 246, 233, 250),
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  draw_meter(
    46,
    24,
    340,
    34,
    game.health,
    @types.health_max,
    "Health",
    @types.col(204, 86, 82, 245),
  )
  draw_meter(
    46,
    68,
    340,
    34,
    game.harmony,
    @types.harmony_max,
    "Harmony",
    @types.col(108, 186, 138, 245),
  )

  let burst_value = if game.burst_cd <= 0.0 {
    @types.burst_cooldown
  } else {
    @types.burst_cooldown - game.burst_cd
  }
  draw_meter(
    1218,
    24,
    340,
    34,
    burst_value,
    @types.burst_cooldown,
    "Focus",
    @types.col(126, 161, 238, 245),
  )
  draw_meter(
    1218,
    68,
    340,
    34,
    game.duel_time_left,
    @types.duel_duration,
    "Time",
    @types.col(233, 187, 110, 245),
  )

  @raylib.draw_text(
    "Acclaim " + game.acclaim.to_string(),
    640,
    24,
    32,
    @types.col(246, 228, 196, 255),
  )
  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    640,
    62,
    28,
    @types.col(255, 202, 128, 252),
  )
  @raylib.draw_text(
    "Best combo " + game.best_combo.to_string(),
    860,
    66,
    24,
    @types.col(208, 211, 236, 236),
  )

  let burst_text = if game.burst_t > 0.0 {
    "FOCUS BURST ACTIVE"
  } else if game.burst_cd <= 0.0 {
    "SPACE: Focus Burst Ready"
  } else {
    "Burst cooldown " + (game.burst_cd.to_int() + 1).to_string() + "s"
  }
  @types.draw_center_text(
    burst_text, 906, 22, @types.col(181, 205, 255, 230),
  )

  @raylib.draw_text(
    "Hits " + game.hits.to_string() + "  Misses " + game.misses.to_string(),
    670,
    94,
    20,
    @types.col(228, 216, 203, 230),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    270, 148, 1060, 650, @types.col(8, 8, 12, 204),
  )
  @raylib.draw_rectangle_lines(
    270, 148, 1060, 650, @types.col(228, 192, 148, 236),
  )

  @types.draw_center_text(
    "PEKING OPERA DUEL 2026", 210, 62, @types.col(246, 228, 188, 252),
  )
  @types.draw_center_text(
    "Match rhythm prompts and stance transitions against a rival troupe.",
    304,
    30,
    @types.col(219, 209, 194, 236),
  )

  @raylib.draw_text(
    "WASD/Arrows: stance axes + lane focus",
    390,
    392,
    30,
    @types.col(239, 232, 218, 245),
  )
  @raylib.draw_text(
    "J: beat hit / confirm   K: defensive transition   SPACE: focus burst",
    390,
    438,
    30,
    @types.col(239, 232, 218, 245),
  )
  @raylib.draw_text(
    "P: pause   R: restart duel",
    390,
    484,
    30,
    @types.col(239, 232, 218, 245),
  )

  @types.draw_center_text(
    "Press J or ENTER to begin",
    584,
    40,
    @types.col(255, 205, 121, 252),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h, @types.col(0, 0, 0, 118),
  )
  @types.draw_center_text(
    "PAUSED", 372, 72, @types.col(248, 233, 198, 250),
  )
  @types.draw_center_text(
    "Press P or J to resume", 470, 34, @types.col(233, 220, 206, 245),
  )
}

///|
fn draw_game_over_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    220, 136, 1160, 690, @types.col(6, 6, 10, 214),
  )
  @raylib.draw_rectangle_lines(
    220, 136, 1160, 690, @types.col(236, 194, 146, 236),
  )

  @types.draw_center_text(
    "CURTAIN FALL", 196, 68, @types.col(247, 227, 191, 252),
  )

  @raylib.draw_text(
    game.game_over_reason,
    296,
    320,
    30,
    @types.col(240, 225, 205, 242),
  )

  @raylib.draw_text(
    "Acclaim: " + game.acclaim.to_string(),
    370,
    410,
    36,
    @types.col(246, 212, 154, 250),
  )
  @raylib.draw_text(
    "Best Combo: " + game.best_combo.to_string(),
    370,
    458,
    32,
    @types.col(213, 225, 244, 250),
  )
  @raylib.draw_text(
    "Grade: " + @types.grade_for_acclaim(game.acclaim),
    370,
    506,
    32,
    @types.col(201, 236, 192, 250),
  )

  @types.draw_center_text(
    "R: restart duel   J: return to title",
    674,
    34,
    @types.col(247, 226, 202, 250),
  )
}

///|
fn draw_message_banner(game : @types.Game) -> Unit {
  if game.message_t <= 0.0 {
    return
  }

  @raylib.draw_rectangle(
    220, 866, 1160, 56, @types.col(9, 10, 14, 200),
  )
  @raylib.draw_rectangle_lines(
    220, 866, 1160, 56, @types.col(219, 192, 156, 230),
  )

  @types.draw_center_text(
    game.message, 882, 24, @types.col(241, 229, 212, 248),
  )
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_backdrop(game)
  draw_stage_actors(game)
  draw_lane_grid(game)

  if game.state == @types.state_playing ||
    game.state == @types.state_paused {
    draw_active_prompt(game)
  }

  draw_focus_cursor(game)
  draw_hud(game)

  if game.state == @types.state_title {
    draw_title_overlay()
  } else if game.state == @types.state_paused {
    draw_paused_overlay()
  } else if game.state == @types.state_game_over {
    draw_game_over_overlay(game)
  }

  draw_message_banner(game)
}
