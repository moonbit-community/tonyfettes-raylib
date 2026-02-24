///|
fn draw_ocean_background(game : Game) -> Unit {
  for y = 0; y < screen_h; y = y + 4 {
    let r = clampi(7 + y * 20 / screen_h, 0, 255)
    let g = clampi(20 + y * 42 / screen_h, 0, 255)
    let b = clampi(34 + y * 58 / screen_h, 0, 255)
    @raylib.draw_rectangle(0, y, screen_w, 4, @raylib.Color::new(r, g, b, 255))
  }

  for i = 0; i < 18; i = i + 1 {
    let y = 34 + i * 26
    let phase = game.time_s * 1.5 + Float::from_int(i) * 0.7
    let xoff = (sinf(phase) * 18.0).to_int()
    @raylib.draw_line(
      18 + xoff,
      y,
      screen_w - 18 + xoff,
      y,
      @raylib.Color::new(120, 190, 230, 28),
    )
  }
}

///|
fn draw_arena() -> Unit {
  @raylib.draw_rectangle(
    arena_x0,
    arena_y0,
    arena_w,
    arena_h,
    @raylib.Color::new(8, 24, 38, 190),
  )

  @raylib.draw_rectangle(
    arena_x0,
    arena_y0,
    arena_w,
    surface_band_h,
    @raylib.Color::new(28, 88, 130, 86),
  )

  @raylib.draw_rectangle_lines(
    arena_x0,
    arena_y0,
    arena_w,
    arena_h,
    @raylib.Color::new(132, 210, 244, 170),
  )

  for i = 0; i < 24; i = i + 1 {
    let px = arena_x0 + i * 50
    let y = arena_y0 + 20 + (sinf(Float::from_int(i) * 0.8) * 7.0).to_int()
    @raylib.draw_line(px, y, px + 34, y, @raylib.Color::new(182, 228, 252, 98))
  }
}

///|
fn draw_hot_zone(game : Game) -> Unit {
  let active = in_hot_zone_xy(game.sub_x, game.sub_y)
  @raylib.draw_circle(
    hot_zone_x.to_int(),
    hot_zone_y.to_int(),
    hot_zone_r,
    @raylib.Color::new(230, 84, 68, if active { 52 } else { 34 }),
  )
  @raylib.draw_circle_lines(
    hot_zone_x.to_int(),
    hot_zone_y.to_int(),
    hot_zone_r,
    @raylib.Color::new(255, 162, 120, if active { 220 } else { 122 }),
  )
}

///|
fn draw_targets(game : Game) -> Unit {
  for i = 0; i < game.target_goal; i = i + 1 {
    if not(game.targets[i].active) {
      continue
    }

    let tx = game.targets[i].x.to_int()
    let ty = game.targets[i].y.to_int()

    if game.targets[i].detected {
      @raylib.draw_circle(tx, ty, 8.5, @raylib.Color::new(116, 252, 172, 220))
      @raylib.draw_circle(tx, ty, 4.0, @raylib.Color::new(216, 255, 232, 240))

      if game.targets[i].pulse_t > 0.0 {
        let alpha = clampi((game.targets[i].pulse_t * 180.0).to_int(), 0, 190)
        @raylib.draw_circle_lines(
          tx,
          ty,
          18.0 + (1.0 - game.targets[i].pulse_t) * 34.0,
          @raylib.Color::new(152, 255, 198, alpha),
        )
      }
    } else if game.sonar_wave_t > 0.0 {
      let d = sqrtf(
        dist2(game.sub_x, game.sub_y, game.targets[i].x, game.targets[i].y),
      )
      if absf(d - game.sonar_wave_r) < 12.0 {
        @raylib.draw_circle(tx, ty, 5.0, @raylib.Color::new(148, 250, 204, 128))
      }
    }
  }
}

///|
fn draw_mines(game : Game) -> Unit {
  for i = 0; i < game.mine_count; i = i + 1 {
    if not(game.mines[i].active) {
      continue
    }

    let mx = game.mines[i].x.to_int()
    let my = game.mines[i].y.to_int()

    let visible = not(game.mines[i].armed) || game.mines[i].reveal_t > 0.0

    if visible {
      let alpha = if game.mines[i].armed {
        clampi(
          (Float::from_int(90) + game.mines[i].reveal_t * Float::from_int(70)).to_int(),
          90,
          220,
        )
      } else {
        130
      }

      @raylib.draw_circle(
        mx,
        my,
        game.mines[i].r,
        @raylib.Color::new(206, 66, 84, alpha / 2),
      )
      @raylib.draw_circle_lines(
        mx,
        my,
        game.mines[i].r,
        @raylib.Color::new(255, 116, 138, alpha),
      )
      @raylib.draw_circle(mx, my, 2.8, @raylib.Color::new(255, 200, 210, alpha))
    } else {
      @raylib.draw_circle(mx, my, 2.0, @raylib.Color::new(44, 60, 76, 110))
    }
  }
}

///|
fn draw_submarine(game : Game) -> Unit {
  let shake_x = sinf(game.time_s * 96.0) * game.shake_t * 7.0
  let sx = game.sub_x + shake_x
  let sy = game.sub_y

  @raylib.draw_circle(
    sx.to_int(),
    sy.to_int(),
    sub_r,
    @raylib.Color::new(238, 214, 102, 235),
  )

  @raylib.draw_rectangle(
    (sx - sub_r - 11.0).to_int(),
    (sy - 8.0).to_int(),
    20,
    16,
    @raylib.Color::new(186, 164, 68, 230),
  )

  @raylib.draw_circle(
    (sx + 6.0).to_int(),
    (sy - 2.0).to_int(),
    5.0,
    @raylib.Color::new(36, 82, 108, 255),
  )

  let fin_col = @raylib.Color::new(198, 176, 78, 240)
  @raylib.draw_line(
    (sx - 8.0).to_int(),
    (sy + 14.0).to_int(),
    (sx + 14.0).to_int(),
    (sy + 14.0).to_int(),
    fin_col,
  )
  @raylib.draw_line(
    (sx - 8.0).to_int(),
    (sy - 14.0).to_int(),
    (sx + 14.0).to_int(),
    (sy - 14.0).to_int(),
    fin_col,
  )

  let prop_phase = sinf(game.time_s * 24.0)
  @raylib.draw_line(
    (sx - sub_r - 18.0).to_int(),
    (sy - 8.0 + prop_phase * 4.0).to_int(),
    (sx - sub_r - 18.0).to_int(),
    (sy + 8.0 - prop_phase * 4.0).to_int(),
    @raylib.Color::new(246, 238, 180, 220),
  )
}

///|
fn draw_sonar_wave(game : Game) -> Unit {
  if game.sonar_wave_t <= 0.0 {
    return
  }

  let alpha = clampi(
    (game.sonar_wave_t / sonar_pulse_time * 230.0).to_int(),
    0,
    230,
  )
  @raylib.draw_circle_lines(
    game.sub_x.to_int(),
    game.sub_y.to_int(),
    game.sonar_wave_r,
    @raylib.Color::new(124, 232, 255, alpha),
  )

  @raylib.draw_circle_lines(
    game.sub_x.to_int(),
    game.sub_y.to_int(),
    maxf(0.0, game.sonar_wave_r - 24.0),
    @raylib.Color::new(98, 200, 240, alpha / 2),
  )
}

///|
fn draw_bearing_indicator(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  let target = nearest_undetected_target(game)
  if not(target.2) {
    return
  }

  let dx = target.0 - game.sub_x
  let dy = target.1 - game.sub_y
  let len = sqrtf(maxf(dx * dx + dy * dy, 0.001))

  let bx = screen_w / 2
  let by = 52

  @raylib.draw_circle_lines(
    bx,
    by,
    36.0,
    @raylib.Color::new(136, 206, 236, 188),
  )
  @raylib.draw_line(
    bx,
    by,
    (Float::from_int(bx) + dx / len * 28.0).to_int(),
    (Float::from_int(by) + dy / len * 28.0).to_int(),
    @raylib.Color::new(146, 246, 176, 230),
  )
  @raylib.draw_circle(
    (Float::from_int(bx) + dx / len * 28.0).to_int(),
    (Float::from_int(by) + dy / len * 28.0).to_int(),
    4.0,
    @raylib.Color::new(200, 255, 220, 235),
  )
}

///|
fn draw_value_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  max_value : Float,
  label : String,
  col : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(10, 26, 40, 214))

  let ratio = clampf(value / maxf(max_value, 0.001), 0.0, 1.0)
  let fw = (Float::from_int(w - 4) * ratio).to_int()
  @raylib.draw_rectangle(x + 2, y + 2, fw, h - 4, col)

  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(136, 210, 240, 170),
  )

  let txt = label + " " + value.to_int().to_string()
  @raylib.draw_text(
    txt,
    x + 8,
    y + 5,
    18,
    @raylib.Color::new(236, 246, 255, 235),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  draw_value_bar(
    20,
    16,
    248,
    30,
    game.oxygen,
    oxygen_max,
    "OXY",
    @raylib.Color::new(116, 226, 246, 224),
  )
  draw_value_bar(
    20,
    52,
    248,
    30,
    game.fuel,
    fuel_max,
    "FUEL",
    @raylib.Color::new(244, 196, 108, 224),
  )
  draw_value_bar(
    20,
    88,
    248,
    30,
    game.hull,
    hull_max,
    "HULL",
    @raylib.Color::new(244, 124, 126, 224),
  )

  @raylib.draw_rectangle(
    screen_w - 296,
    16,
    276,
    106,
    @raylib.Color::new(10, 26, 40, 214),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 296,
    16,
    276,
    106,
    @raylib.Color::new(136, 210, 240, 170),
  )

  @raylib.draw_text(
    "MISSION " + game.mission.to_string(),
    screen_w - 280,
    26,
    22,
    @raylib.Color::new(234, 246, 255, 238),
  )
  @raylib.draw_text(
    "TARGETS " +
    game.targets_found.to_string() +
    " / " +
    game.target_goal.to_string(),
    screen_w - 280,
    56,
    20,
    @raylib.Color::new(170, 242, 196, 236),
  )

  let sonar_ready = if game.sonar_cd <= 0.0 {
    "READY"
  } else {
    (game.sonar_cd * 100.0).to_int().to_string() + "cs"
  }
  @raylib.draw_text(
    "SONAR " + sonar_ready,
    screen_w - 280,
    84,
    18,
    if game.sonar_cd <= 0.0 {
      @raylib.Color::new(132, 250, 170, 236)
    } else {
      @raylib.Color::new(236, 210, 142, 236)
    },
  )

  let zone_text = if in_hot_zone_xy(game.sub_x, game.sub_y) {
    "THERMAL ZONE: STRONG SONAR / HIGH OXYGEN DRAIN"
  } else {
    "TIP: THERMAL ZONE AMPLIFIES SONAR, BUT DRAINS OXYGEN"
  }
  @raylib.draw_text(
    zone_text,
    20,
    screen_h - 34,
    18,
    @raylib.Color::new(210, 232, 248, 218),
  )
}

///|
fn draw_touch_button(
  rect : (Int, Int, Int, Int),
  label : String,
  active : Bool,
  hover : Bool,
  accent : (Int, Int, Int),
) -> Unit {
  let alpha = if active { 188 } else if hover { 156 } else { 110 }

  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(10, 26, 40, alpha),
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(accent.0, accent.1, accent.2, clampi(alpha + 60, 0, 255)),
  )

  let tw = @raylib.measure_text(label, 22)
  @raylib.draw_text(
    label,
    rect.0 + (rect.2 - tw) / 2,
    rect.1 + rect.3 / 2 - 11,
    22,
    @raylib.Color::new(236, 246, 255, clampi(alpha + 68, 0, 255)),
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

  let left_btn = mobile_left_btn()
  let right_btn = mobile_right_btn()
  let up_btn = mobile_up_btn()
  let down_btn = mobile_down_btn()
  let sonar_btn = mobile_sonar_btn()
  let boost_btn = mobile_boost_btn()
  let restart_btn = mobile_restart_btn()

  draw_touch_button(
    left_btn,
    "<",
    game.move_x < -0.2,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      left_btn.0,
      left_btn.1,
      left_btn.2,
      left_btn.3,
    ),
    (140, 210, 246),
  )

  draw_touch_button(
    right_btn,
    ">",
    game.move_x > 0.2,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      right_btn.0,
      right_btn.1,
      right_btn.2,
      right_btn.3,
    ),
    (140, 210, 246),
  )

  draw_touch_button(
    up_btn,
    "^",
    game.move_y < -0.2,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      up_btn.0,
      up_btn.1,
      up_btn.2,
      up_btn.3,
    ),
    (140, 210, 246),
  )

  draw_touch_button(
    down_btn,
    "v",
    game.move_y > 0.2,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      down_btn.0,
      down_btn.1,
      down_btn.2,
      down_btn.3,
    ),
    (140, 210, 246),
  )

  draw_touch_button(
    sonar_btn,
    "PING",
    game.sonar_cd <= 0.0,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      sonar_btn.0,
      sonar_btn.1,
      sonar_btn.2,
      sonar_btn.3,
    ),
    (112, 248, 172),
  )

  draw_touch_button(
    boost_btn,
    "BOOST",
    game.boost_hold,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      boost_btn.0,
      boost_btn.1,
      boost_btn.2,
      boost_btn.3,
    ),
    (248, 198, 116),
  )

  draw_touch_button(
    restart_btn,
    "RESTART",
    false,
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart_btn.0,
      restart_btn.1,
      restart_btn.2,
      restart_btn.3,
    ),
    (240, 132, 142),
  )
}

///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - tw / 2, y, size, color)
}

///|
fn draw_menu_button(
  rect : (Int, Int, Int, Int),
  label : String,
  hover : Bool,
  accent : (Int, Int, Int),
) -> Unit {
  let bg_alpha = if hover { 198 } else { 162 }
  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(12, 30, 46, bg_alpha),
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(accent.0, accent.1, accent.2, 230),
  )

  let tw = @raylib.measure_text(label, 28)
  @raylib.draw_text(
    label,
    rect.0 + (rect.2 - tw) / 2,
    rect.1 + rect.3 / 2 - 14,
    28,
    @raylib.Color::new(236, 248, 255, 242),
  )
}

///|
fn draw_title_overlay(
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
    @raylib.Color::new(6, 18, 28, 130),
  )
  @raylib.draw_rectangle(
    screen_w / 2 - 392,
    94,
    784,
    520,
    @raylib.Color::new(8, 22, 36, 224),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 392,
    94,
    784,
    520,
    @raylib.Color::new(134, 208, 242, 190),
  )

  draw_center_text(
    "SUBMARINE SONAR HUNT 2026",
    146,
    48,
    @raylib.Color::new(206, 244, 255, 245),
  )
  draw_center_text(
    "Scan hidden wreck beacons, avoid mines, and survive fuel + oxygen pressure.",
    216,
    24,
    @raylib.Color::new(184, 226, 242, 236),
  )

  @raylib.draw_text(
    "Keyboard: WASD/Arrows move  |  SPACE/F sonar pulse  |  Shift boost",
    screen_w / 2 - 326,
    282,
    22,
    @raylib.Color::new(190, 232, 248, 220),
  )
  @raylib.draw_text(
    "Thermal zone: stronger pulse range but much faster oxygen drain.",
    screen_w / 2 - 276,
    322,
    22,
    @raylib.Color::new(244, 196, 152, 220),
  )
  @raylib.draw_text(
    "Touch: left pad moves, PING triggers sonar, BOOST consumes fuel for speed.",
    screen_w / 2 - 306,
    360,
    22,
    @raylib.Color::new(176, 238, 202, 220),
  )

  let start_btn = title_start_button_rect()
  let start_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start_btn.0,
    start_btn.1,
    start_btn.2,
    start_btn.3,
  )

  draw_menu_button(
    start_btn,
    "START FROM MISSION " + game.best_mission.to_string(),
    start_hover,
    (126, 250, 176),
  )

  @raylib.draw_text(
    "Press Enter/Space or tap button",
    screen_w / 2 - 144,
    start_btn.1 + 82,
    20,
    @raylib.Color::new(194, 226, 244, 220),
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
    @raylib.Color::new(6, 18, 28, 142),
  )
  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    118,
    720,
    442,
    @raylib.Color::new(8, 22, 36, 228),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 360,
    118,
    720,
    442,
    @raylib.Color::new(134, 208, 242, 194),
  )

  if game.state == state_win {
    draw_center_text(
      "MISSION CLEARED",
      176,
      46,
      @raylib.Color::new(162, 250, 186, 245),
    )
    draw_center_text(
      "Targets detected: " +
      game.target_goal.to_string() +
      " / " +
      game.target_goal.to_string(),
      246,
      30,
      @raylib.Color::new(196, 236, 248, 236),
    )
    draw_center_text(
      "Next mission adds more beacons and denser minefields.",
      286,
      24,
      @raylib.Color::new(196, 236, 248, 220),
    )
  } else {
    draw_center_text(
      "MISSION FAILED",
      176,
      46,
      @raylib.Color::new(250, 146, 152, 246),
    )
    draw_center_text(
      lose_reason_text(game),
      246,
      30,
      @raylib.Color::new(244, 218, 220, 236),
    )
    draw_center_text(
      "Re-run mission with tighter pulse timing and route planning.",
      286,
      24,
      @raylib.Color::new(206, 234, 248, 218),
    )
  }

  let restart_btn = result_restart_button_rect()
  let next_btn = result_next_button_rect()
  let title_btn = result_title_button_rect()

  let restart_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_btn.0,
    restart_btn.1,
    restart_btn.2,
    restart_btn.3,
  )

  draw_menu_button(restart_btn, "RESTART", restart_hover, (126, 212, 242))

  if game.state == state_win {
    let next_hover = pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      next_btn.0,
      next_btn.1,
      next_btn.2,
      next_btn.3,
    )

    draw_menu_button(
      next_btn,
      if game.mission >= mission_max {
        "MAX MISSION"
      } else {
        "NEXT"
      },
      next_hover,
      (146, 248, 182),
    )
  } else {
    @raylib.draw_rectangle(
      next_btn.0,
      next_btn.1,
      next_btn.2,
      next_btn.3,
      @raylib.Color::new(24, 40, 52, 132),
    )
    @raylib.draw_rectangle_lines(
      next_btn.0,
      next_btn.1,
      next_btn.2,
      next_btn.3,
      @raylib.Color::new(92, 120, 140, 156),
    )
    let tw = @raylib.measure_text("NEXT", 28)
    @raylib.draw_text(
      "NEXT",
      next_btn.0 + (next_btn.2 - tw) / 2,
      next_btn.1 + next_btn.3 / 2 - 14,
      28,
      @raylib.Color::new(140, 162, 178, 170),
    )
  }

  let title_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    title_btn.0,
    title_btn.1,
    title_btn.2,
    title_btn.3,
  )

  draw_menu_button(title_btn, "TITLE", title_hover, (248, 208, 142))

  @raylib.draw_text(
    "R/Enter restart  |  N next (win)  |  T/Esc title",
    screen_w / 2 - 216,
    title_btn.1 + 70,
    20,
    @raylib.Color::new(186, 222, 242, 220),
  )
}

///|
fn draw_title_preview(game : Game) -> Unit {
  let cx = Float::from_int(screen_w / 2)
  let cy = Float::from_int(screen_h / 2 - 26)
  let wave : Float = Float::from_int(120) + sinf(game.time_s * 1.3) * 42.0

  @raylib.draw_circle(
    cx.to_int(),
    cy.to_int(),
    28.0,
    @raylib.Color::new(238, 214, 102, 230),
  )
  @raylib.draw_circle(
    (cx + 8.0).to_int(),
    (cy - 4.0).to_int(),
    7.0,
    @raylib.Color::new(36, 82, 108, 240),
  )
  @raylib.draw_circle_lines(
    cx.to_int(),
    cy.to_int(),
    wave,
    @raylib.Color::new(120, 228, 255, 156),
  )
  @raylib.draw_circle_lines(
    cx.to_int(),
    cy.to_int(),
    wave + 54.0,
    @raylib.Color::new(104, 198, 238, 106),
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
  @raylib.clear_background(@raylib.Color::new(8, 22, 36, 255))

  draw_ocean_background(game)
  draw_arena()

  if game.state == state_title {
    draw_hot_zone(game)
    draw_title_preview(game)
    draw_title_overlay(game, mx, my, hold, touch_count)
    return
  }

  draw_hot_zone(game)
  draw_targets(game)
  draw_mines(game)
  draw_sonar_wave(game)
  draw_submarine(game)
  draw_bearing_indicator(game)
  draw_hud(game)
  draw_touch_controls(game, mx, my, hold, touch_count)

  if game.state == state_win || game.state == state_lose {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
