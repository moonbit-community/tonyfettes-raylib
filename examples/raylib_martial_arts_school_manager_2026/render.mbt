///|
fn with_alpha(color : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    color.r.to_int(),
    color.g.to_int(),
    color.b.to_int(),
    clampi(alpha, 0, 255),
  )
}

///|
fn room_color(room : Int) -> @raylib.Color {
  if room == room_rest {
    @raylib.Color::new(96, 182, 128, 255)
  } else if room == room_train {
    @raylib.Color::new(222, 166, 74, 255)
  } else if room == room_sparring {
    @raylib.Color::new(224, 96, 94, 255)
  } else {
    @raylib.Color::new(92, 148, 236, 255)
  }
}

///|
fn fatigue_color(value : Float) -> @raylib.Color {
  if value < 45.0 {
    @raylib.Color::new(104, 210, 128, 255)
  } else if value < 74.0 {
    @raylib.Color::new(236, 196, 88, 255)
  } else {
    @raylib.Color::new(232, 102, 102, 255)
  }
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fill_color : @raylib.Color,
) -> Unit {
  let clamped = clampf(ratio, 0.0, 1.0)
  let fill_w = (Float::from_int(w - 4) * clamped).to_int()

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(26, 32, 44, 235))
  if fill_w > 0 {
    @raylib.draw_rectangle(x + 2, y + 2, fill_w, h - 4, fill_color)
  }
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(116, 132, 156, 210),
  )
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(16, 20, 30, 255))

  for i = 0; i < 14; i = i + 1 {
    let wave = (sinf(game.scene_t * 0.6 + Float::from_int(i) * 0.38) * 18.0).to_int()
    let y = i * 72 + wave
    let tone = 28 + i * 2

    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      56,
      @raylib.Color::new(tone, tone + 10, tone + 24, 84),
    )
  }

  @raylib.draw_circle(220, 120, 180.0, @raylib.Color::new(76, 114, 188, 88))
  @raylib.draw_circle(
    screen_w - 220,
    136,
    220.0,
    @raylib.Color::new(198, 108, 92, 64),
  )

  if game.incident_flash_t > 0.0 {
    let alpha = clampi((game.incident_flash_t * 130.0).to_int(), 0, 130)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(255, 88, 72, alpha),
    )
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    28,
    22,
    screen_w - 56,
    120,
    @raylib.Color::new(14, 24, 38, 224),
  )
  @raylib.draw_rectangle_lines(
    28,
    22,
    screen_w - 56,
    120,
    @raylib.Color::new(118, 148, 182, 230),
  )

  let title = "Martial Arts School Manager 2026"
  @raylib.draw_text(title, 48, 34, 38, @raylib.Color::new(238, 228, 198, 245))

  let week_text = "Week " + game.week.to_string()
  @raylib.draw_text(
    week_text,
    52,
    84,
    30,
    @raylib.Color::new(240, 244, 252, 236),
  )

  let funds_text = "Funds " + game.funds.to_int().to_string()
  @raylib.draw_text(
    funds_text,
    240,
    84,
    30,
    if game.funds < 280.0 {
      @raylib.Color::new(246, 118, 112, 242)
    } else {
      @raylib.Color::new(144, 220, 154, 242)
    },
  )

  let rep_text = "Reputation " + game.reputation.to_int().to_string()
  @raylib.draw_text(
    rep_text,
    470,
    84,
    30,
    if game.reputation < 25.0 {
      @raylib.Color::new(248, 124, 112, 242)
    } else {
      @raylib.Color::new(236, 226, 170, 242)
    },
  )

  let avg_fatigue = mean_fatigue(game)
  let fatigue_text = "Avg Fatigue " + avg_fatigue.to_int().to_string()
  @raylib.draw_text(fatigue_text, 790, 84, 30, fatigue_color(avg_fatigue))

  let week_ratio : Float = if game.week_duration <= 0.0 {
    0.0
  } else {
    clampf(1.0 - game.week_time_left / game.week_duration, 0.0, 1.0)
  }

  @raylib.draw_text(
    "Week Progress",
    1090,
    38,
    23,
    @raylib.Color::new(224, 232, 244, 220),
  )
  draw_meter(
    1088,
    70,
    300,
    28,
    week_ratio,
    @raylib.Color::new(102, 164, 236, 235),
  )

  let timer_text = "Time left " +
    maxf(0.0, game.week_time_left).to_int().to_string() +
    "s"
  @raylib.draw_text(
    timer_text,
    1090,
    104,
    22,
    @raylib.Color::new(216, 228, 240, 228),
  )

  let burst_text = if game.speed_burst_t > 0.0 {
    "Burst ACTIVE"
  } else if game.speed_burst_cd > 0.0 {
    "Burst CD " + (game.speed_burst_cd + 0.99).to_int().to_string() + "s"
  } else {
    "Burst READY"
  }

  @raylib.draw_text(
    burst_text,
    1320,
    104,
    22,
    if game.speed_burst_t > 0.0 {
      @raylib.Color::new(132, 242, 214, 236)
    } else if game.speed_burst_cd > 0.0 {
      @raylib.Color::new(236, 190, 106, 236)
    } else {
      @raylib.Color::new(144, 228, 172, 236)
    },
  )
}

///|
fn draw_student_table(game : Game) -> Unit {
  let panel_x = 40
  let panel_y = 164
  let panel_w = screen_w - 80
  let panel_h = 636

  let info_x = panel_x + 20
  let grid_x = panel_x + 422
  let row_start_y = panel_y + 98
  let row_h = 84
  let cell_w = 238
  let cell_gap = 8

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 18, 32, 218),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(106, 130, 166, 220),
  )

  @raylib.draw_text(
    "Students",
    info_x,
    panel_y + 22,
    30,
    @raylib.Color::new(228, 236, 248, 236),
  )
  @raylib.draw_text(
    "Assign each student to Rest / Train / Spar / Defense",
    info_x,
    panel_y + 56,
    22,
    @raylib.Color::new(170, 194, 222, 220),
  )

  for col = 0; col < room_count; col = col + 1 {
    let x = grid_x + col * (cell_w + cell_gap)
    let title = room_name(col)
    let tw = @raylib.measure_text(title, 24)

    @raylib.draw_rectangle(
      x,
      panel_y + 20,
      cell_w,
      52,
      with_alpha(room_color(col), 88),
    )
    @raylib.draw_rectangle_lines(
      x,
      panel_y + 20,
      cell_w,
      52,
      with_alpha(room_color(col), 200),
    )
    @raylib.draw_text(
      title,
      x + cell_w / 2 - tw / 2,
      panel_y + 34,
      24,
      @raylib.Color::new(236, 240, 250, 236),
    )
  }

  for i = 0; i < student_count; i = i + 1 {
    let y = row_start_y + i * row_h

    @raylib.draw_rectangle(
      info_x - 10,
      y,
      panel_w - 40,
      row_h - 8,
      if i % 2 == 0 {
        @raylib.Color::new(18, 28, 42, 186)
      } else {
        @raylib.Color::new(22, 34, 50, 186)
      },
    )

    @raylib.draw_text(
      game.students[i].name,
      info_x,
      y + 10,
      30,
      @raylib.Color::new(240, 240, 232, 240),
    )

    @raylib.draw_text(
      "Skill " + game.students[i].skill.to_int().to_string(),
      info_x,
      y + 45,
      18,
      @raylib.Color::new(218, 228, 242, 220),
    )
    draw_meter(
      info_x + 108,
      y + 46,
      200,
      16,
      game.students[i].skill / 130.0,
      @raylib.Color::new(108, 196, 252, 236),
    )

    @raylib.draw_text(
      "Fatigue " + game.students[i].fatigue.to_int().to_string(),
      info_x,
      y + 64,
      18,
      fatigue_color(game.students[i].fatigue),
    )
    draw_meter(
      info_x + 108,
      y + 65,
      200,
      16,
      game.students[i].fatigue / fatigue_max,
      fatigue_color(game.students[i].fatigue),
    )

    for col = 0; col < room_count; col = col + 1 {
      let x = grid_x + col * (cell_w + cell_gap)
      let assigned = game.students[i].room == col
      let selected = (game.state == state_playing || game.state == state_paused) &&
        game.cursor_row == i &&
        game.cursor_col == col

      @raylib.draw_rectangle(
        x,
        y + 8,
        cell_w,
        row_h - 24,
        if assigned {
          with_alpha(room_color(col), 176)
        } else {
          with_alpha(room_color(col), 54)
        },
      )
      @raylib.draw_rectangle_lines(
        x,
        y + 8,
        cell_w,
        row_h - 24,
        if selected {
          @raylib.Color::new(252, 246, 214, 242)
        } else if assigned {
          with_alpha(room_color(col), 226)
        } else {
          @raylib.Color::new(84, 106, 136, 170)
        },
      )

      let label = if assigned { "Assigned" } else { "Press J" }
      let lw = @raylib.measure_text(label, 20)
      @raylib.draw_text(
        label,
        x + cell_w / 2 - lw / 2,
        y + 30,
        20,
        if assigned {
          @raylib.Color::new(255, 246, 214, 242)
        } else {
          @raylib.Color::new(192, 206, 224, 204)
        },
      )
    }
  }

  let incidents_text = "Incidents this week " +
    game.incident_count_week.to_string() +
    "   Total " +
    game.total_incidents.to_string() +
    "   Next in " +
    maxf(0.0, game.incident_timer).to_int().to_string() +
    "s"
  @raylib.draw_text(
    incidents_text,
    panel_x + 22,
    panel_y + panel_h - 44,
    24,
    @raylib.Color::new(236, 192, 168, 230),
  )
}

///|
fn draw_footer_help() -> Unit {
  let footer = "WASD/Arrows: move cursor   J: assign/train   K: cancel to rest   SPACE: burst   P: pause   R: restart"
  @raylib.draw_rectangle(
    0,
    screen_h - 42,
    screen_w,
    42,
    @raylib.Color::new(10, 14, 24, 236),
  )
  @raylib.draw_text(
    footer,
    24,
    screen_h - 33,
    21,
    @raylib.Color::new(206, 222, 242, 230),
  )
}

///|
fn draw_message(game : Game) -> Unit {
  if game.message_t <= 0.0 {
    return
  }

  let alpha = clampi(
    (clampf(game.message_t / 3.0, 0.0, 1.0) * 226.0).to_int(),
    90,
    226,
  )
  @raylib.draw_rectangle(
    320,
    812,
    960,
    64,
    @raylib.Color::new(24, 34, 52, alpha),
  )
  @raylib.draw_rectangle_lines(
    320,
    812,
    960,
    64,
    @raylib.Color::new(154, 180, 214, alpha),
  )

  let tw = @raylib.measure_text(game.message, 28)
  @raylib.draw_text(
    game.message,
    screen_w / 2 - tw / 2,
    831,
    28,
    @raylib.Color::new(244, 246, 252, alpha),
  )
}

///|
fn draw_week_banner(game : Game) -> Unit {
  if game.week_banner_t <= 0.0 || game.state != state_playing {
    return
  }

  let pulse : Float = 0.5 + 0.5 * sinf(game.scene_t * 6.2)
  let alpha = clampi(
    (game.week_banner_t / 2.6 * (150.0 + pulse * 80.0)).to_int(),
    0,
    230,
  )
  let text = "WEEK " + game.week.to_string()
  let tw = @raylib.measure_text(text, 56)

  @raylib.draw_text(
    text,
    screen_w / 2 - tw / 2,
    142,
    56,
    @raylib.Color::new(250, 240, 198, alpha),
  )
}

///|
fn draw_overlay_card(
  title : String,
  lines : Array[String],
  y : Int,
  border : @raylib.Color,
) -> Unit {
  let x = screen_w / 2 - 520
  let w = 1040
  let h = 460

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(6, 10, 18, 232))
  @raylib.draw_rectangle_lines(x, y, w, h, border)

  let title_w = @raylib.measure_text(title, 52)
  @raylib.draw_text(
    title,
    x + w / 2 - title_w / 2,
    y + 34,
    52,
    @raylib.Color::new(248, 238, 208, 244),
  )

  for i = 0; i < lines.length(); i = i + 1 {
    @raylib.draw_text(
      lines[i],
      x + 60,
      y + 132 + i * 44,
      30,
      @raylib.Color::new(216, 228, 244, 234),
    )
  }
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 16, 172),
  )

  let lines : Array[String] = [
    "Balance funds, reputation, and fatigue while weekly pressure rises.",
    "Use cursor + J to assign each student to Rest, Train, Spar, or Defense.",
    "Sparring earns reputation and cash, Defense softens incidents, Rest prevents burnout.",
    "K forces selected student to Rest. SPACE accelerates time with cooldown.",
    "Press J or ENTER to begin. Press R anytime for a hard restart.",
    "Best survived weeks: " + game.best_week.to_string(),
  ]

  draw_overlay_card(
    "MARTIAL ARTS SCHOOL MANAGER",
    lines,
    210,
    @raylib.Color::new(204, 178, 126, 236),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(0, 0, 0, 120),
  )

  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 78)
  @raylib.draw_text(
    text,
    screen_w / 2 - tw / 2,
    screen_h / 2 - 84,
    78,
    @raylib.Color::new(248, 236, 204, 240),
  )

  let sub = "Press P to resume"
  let sw = @raylib.measure_text(sub, 36)
  @raylib.draw_text(
    sub,
    screen_w / 2 - sw / 2,
    screen_h / 2 + 6,
    36,
    @raylib.Color::new(220, 230, 246, 236),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 0, 0, 162),
  )

  let lines : Array[String] = [
    game.defeat_reason,
    "Weeks survived: " + game.weeks_survived.to_string(),
    "Final funds: " + game.funds.to_int().to_string(),
    "Final reputation: " + game.reputation.to_int().to_string(),
    "Incidents handled: " + game.total_incidents.to_string(),
    "Press J or ENTER to run again.",
  ]

  draw_overlay_card(
    "DOJO CLOSED",
    lines,
    220,
    @raylib.Color::new(226, 120, 102, 236),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_hud(game)
  draw_student_table(game)
  draw_footer_help()
  draw_week_banner(game)
  draw_message(game)

  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
