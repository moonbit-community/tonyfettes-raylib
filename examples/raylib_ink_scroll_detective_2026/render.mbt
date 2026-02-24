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
fn draw_right_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, x - tw, y, size, col)
}

///|
fn a_col(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(alpha, 0, 255),
  )
}

///|
fn suspect_col(index : Int) -> @raylib.Color {
  if index == 0 {
    @raylib.Color::new(236, 118, 124, 255)
  } else if index == 1 {
    @raylib.Color::new(120, 170, 246, 255)
  } else if index == 2 {
    @raylib.Color::new(132, 224, 176, 255)
  } else {
    @raylib.Color::new(246, 202, 120, 255)
  }
}

///|
fn state_label(state : Int) -> String {
  if state == state_title {
    "TITLE"
  } else if state == state_playing {
    "PLAYING"
  } else if state == state_paused {
    "PAUSED"
  } else {
    "GAME OVER"
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 14, 26, 255),
    @raylib.Color::new(18, 24, 42, 255),
  )

  for i = 0; i < 12; i = i + 1 {
    let fi = Float::from_int(i)
    let y : Float = 70.0 + fi * 62.0 + sinf(game.city_time * 0.9 + fi) * 24.0
    let shift = ((game.city_time * (34.0 + fi * 2.0)).to_int() + i * 19) % 220
    @raylib.draw_line(
      -220 + shift,
      y.to_int(),
      screen_w + 240,
      (y + 16.0).to_int(),
      @raylib.Color::new(26, 42, 74, 64),
    )
  }

  @raylib.draw_rectangle(
    city_origin_x_i - 8,
    city_origin_y_i - 8,
    city_w_i() + 16,
    city_h_i() + 16,
    @raylib.Color::new(14, 18, 30, 170),
  )
}

///|
fn draw_districts(game : Game) -> Unit {
  for y = 0; y < city_rows; y = y + 1 {
    for x = 0; x < city_cols; x = x + 1 {
      let idx = cell_index(x, y)
      let heat = game.pulses[idx].heat

      let r = 24 + (heat * 66.0).to_int() + x * 2
      let g = 28 + (heat * 78.0).to_int() + y * 2
      let b = 44 + (heat * 88.0).to_int()

      let lx = cell_left_i(x)
      let ty = cell_top_i(y)

      @raylib.draw_rectangle(
        lx,
        ty,
        cell_w_i - 2,
        cell_h_i - 2,
        @raylib.Color::new(
          clampi(r, 0, 255),
          clampi(g, 0, 255),
          clampi(b, 0, 255),
          220,
        ),
      )

      if game.focus_t > 0.0 {
        let dx0 = x - game.cursor_x
        let adx = if dx0 < 0 { -dx0 } else { dx0 }
        let dy0 = y - game.cursor_y
        let ady = if dy0 < 0 { -dy0 } else { dy0 }
        if adx + ady <= 1 {
          @raylib.draw_rectangle(
            lx,
            ty,
            cell_w_i - 2,
            cell_h_i - 2,
            @raylib.Color::new(130, 220, 255, 26),
          )
        }
      }

      @raylib.draw_rectangle_lines(
        lx,
        ty,
        cell_w_i - 2,
        cell_h_i - 2,
        @raylib.Color::new(58, 84, 118, 120),
      )
    }
  }
}

///|
fn draw_district_ids() -> Unit {
  for y = 0; y < city_rows; y = y + 1 {
    for x = 0; x < city_cols; x = x + 1 {
      let id = cell_index(x, y)
      @raylib.draw_text(
        id.to_string(),
        cell_left_i(x) + 8,
        cell_top_i(y) + 8,
        14,
        @raylib.Color::new(186, 202, 230, 112),
      )
    }
  }
}

///|
fn draw_clues(game : Game) -> Unit {
  for i = 0; i < game.clues.length(); i = i + 1 {
    if game.clues[i].discovered {
      continue
    }

    let x = cell_center_x(game.clues[i].x)
    let y = cell_center_y(game.clues[i].y)

    let base = suspect_col(game.clues[i].suspect)
    let pulse : Float = 0.45 +
      0.55 * sinf(game.city_time * 4.0 + Float::from_int(i) * 0.5)
    let radius : Float = 6.0 + pulse * 4.0

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      radius,
      a_col(base, 120 + (pulse * 80.0).to_int()),
    )

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      2.0,
      @raylib.Color::new(240, 246, 255, 220),
    )
  }

  for i = 0; i < game.clues.length(); i = i + 1 {
    if game.clues[i].glow_t <= 0.0 {
      continue
    }

    let x = cell_center_x(game.clues[i].x)
    let y = cell_center_y(game.clues[i].y)
    let glow = game.clues[i].glow_t
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      16.0 + glow * 22.0,
      @raylib.Color::new(246, 252, 255, clampi((glow * 180.0).to_int(), 0, 255)),
    )
  }
}

///|
fn draw_suspects(game : Game) -> Unit {
  for i = 0; i < game.suspects.length(); i = i + 1 {
    let x = cell_center_x(game.suspects[i].home_x)
    let y = cell_center_y(game.suspects[i].home_y)
    let col = suspect_col(i)

    @raylib.draw_circle(x.to_int(), y.to_int(), 16.0, a_col(col, 210))
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      21.0,
      @raylib.Color::new(240, 246, 255, 160),
    )

    if game.marked_suspect == i {
      let pulse : Float = 0.5 + 0.5 * sinf(game.city_time * 7.0)
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        28.0 + pulse * 5.0,
        @raylib.Color::new(255, 220, 138, 200),
      )
    }

    if game.suspects[i].deduction_unlocked {
      @raylib.draw_text(
        "D",
        (x - 5.0).to_int(),
        (y - 37.0).to_int(),
        20,
        @raylib.Color::new(250, 244, 146, 230),
      )
    }

    @raylib.draw_text(
      game.suspects[i].name,
      (x - 46.0).to_int(),
      (y + 22.0).to_int(),
      16,
      @raylib.Color::new(226, 236, 252, 200),
    )
  }
}

///|
fn draw_incidents(game : Game) -> Unit {
  for i = 0; i < game.incidents.length(); i = i + 1 {
    if not(game.incidents[i].active) {
      continue
    }

    let x = cell_center_x(game.incidents[i].x)
    let y = cell_center_y(game.incidents[i].y)
    let sevf = Float::from_int(game.incidents[i].severity)

    let pulse : Float = 0.45 +
      0.55 * sinf(game.city_time * 8.0 + game.incidents[i].pulse_t * 2.0)

    let core_col = if game.incidents[i].severity == 1 {
      @raylib.Color::new(244, 188, 122, 230)
    } else if game.incidents[i].severity == 2 {
      @raylib.Color::new(244, 136, 102, 230)
    } else {
      @raylib.Color::new(244, 90, 104, 230)
    }

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      10.0 + sevf * 5.0 + pulse * 4.0,
      a_col(core_col, 88),
    )
    @raylib.draw_circle(x.to_int(), y.to_int(), 6.0 + sevf * 3.5, core_col)

    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      20.0 + sevf * 8.0 + pulse * 8.0,
      a_col(core_col, 150),
    )

    @raylib.draw_text(
      game.incidents[i].timer.to_int().to_string(),
      (x - 8.0).to_int(),
      (y - 8.0).to_int(),
      16,
      @raylib.Color::new(252, 250, 245, 240),
    )
  }
}

///|
fn draw_cursor(game : Game) -> Unit {
  let lx = cell_left_i(game.cursor_x)
  let ty = cell_top_i(game.cursor_y)

  let pulse : Float = 0.5 + 0.5 * sinf(game.city_time * 10.0)
  let glow = 150 + (pulse * 90.0).to_int()

  @raylib.draw_rectangle_lines(
    lx - 1,
    ty - 1,
    cell_w_i,
    cell_h_i,
    @raylib.Color::new(242, 246, 255, clampi(glow, 0, 255)),
  )

  @raylib.draw_rectangle_lines(
    lx - 4,
    ty - 4,
    cell_w_i + 6,
    cell_h_i + 6,
    @raylib.Color::new(138, 212, 255, 100),
  )

  if game.focus_t > 0.0 {
    @raylib.draw_rectangle(
      lx,
      ty,
      cell_w_i - 2,
      cell_h_i - 2,
      @raylib.Color::new(140, 226, 255, 24),
    )
  }
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fg : @raylib.Color,
  label : String,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(28, 34, 48, 228))
  @raylib.draw_rectangle(
    x + 1,
    y + 1,
    (Float::from_int(w - 2) * clamp01(ratio)).to_int(),
    h - 2,
    fg,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(120, 148, 188, 180),
  )
  @raylib.draw_text(
    label,
    x + 8,
    y - 20,
    16,
    @raylib.Color::new(226, 236, 255, 216),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    108,
    @raylib.Color::new(8, 12, 22, 216),
  )

  @raylib.draw_text(
    "INK SCROLL // DETECTIVE",
    22,
    14,
    26,
    @raylib.Color::new(224, 238, 255, 246),
  )
  @raylib.draw_text(
    state_label(game.state),
    24,
    48,
    20,
    @raylib.Color::new(130, 190, 255, 220),
  )

  let trust_ratio = clamp01(game.trust / trust_max)
  draw_meter(
    270,
    26,
    250,
    20,
    trust_ratio,
    @raylib.Color::new(122, 232, 174, 224),
    "Trust " + game.trust.to_int().to_string(),
  )

  let time_ratio = clamp01(game.case_time / time_limit_s)
  draw_meter(
    270,
    64,
    250,
    20,
    time_ratio,
    @raylib.Color::new(238, 168, 118, 220),
    "Case Time " + game.case_time.to_int().to_string() + "s",
  )

  draw_right_text(
    "Score " + game.score.to_string(),
    screen_w - 24,
    18,
    26,
    @raylib.Color::new(248, 244, 218, 246),
  )
  draw_right_text(
    "Best " + game.best_score.to_string(),
    screen_w - 24,
    48,
    20,
    @raylib.Color::new(190, 210, 236, 220),
  )

  let focus_text = if game.focus_t > 0.0 {
    "Focus active " + game.focus_t.to_int().to_string() + "s"
  } else if game.focus_cd > 0.0 {
    "Focus cooldown " + game.focus_cd.to_int().to_string() + "s"
  } else {
    "Focus ready"
  }
  draw_right_text(
    focus_text,
    screen_w - 24,
    74,
    18,
    @raylib.Color::new(144, 224, 248, 220),
  )

  @raylib.draw_text(
    "Incidents " +
    active_incident_count(game).to_string() +
    "  Solved " +
    game.solved_incidents.to_string() +
    "  Failed " +
    game.failed_incidents.to_string() +
    "  Wrong " +
    game.wrong_accusations.to_string(),
    548,
    28,
    20,
    @raylib.Color::new(214, 230, 248, 220),
  )

  let marked = if game.marked_suspect >= 0 {
    game.suspects[game.marked_suspect].name
  } else {
    "None"
  }

  @raylib.draw_text(
    "Marked suspect: " + marked,
    548,
    58,
    20,
    @raylib.Color::new(244, 220, 166, 224),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      0,
      screen_h - 56,
      screen_w,
      56,
      @raylib.Color::new(8, 12, 22, 206),
    )
    @raylib.draw_text(
      game.message,
      22,
      screen_h - 40,
      24,
      @raylib.Color::new(236, 246, 255, 246),
    )
  }
}

///|
fn draw_suspect_board(game : Game) -> Unit {
  let panel_x = city_origin_x_i + city_w_i() + 18
  let panel_w = screen_w - panel_x - 18

  @raylib.draw_rectangle(
    panel_x,
    city_origin_y_i,
    panel_w,
    city_h_i(),
    @raylib.Color::new(14, 20, 32, 178),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    city_origin_y_i,
    panel_w,
    city_h_i(),
    @raylib.Color::new(88, 122, 166, 200),
  )

  @raylib.draw_text(
    "Evidence Board",
    panel_x + 14,
    city_origin_y_i + 10,
    22,
    @raylib.Color::new(230, 240, 255, 242),
  )

  for i = 0; i < suspect_count; i = i + 1 {
    let y = city_origin_y_i + 50 + i * 136
    let col = suspect_col(i)

    @raylib.draw_text(
      game.suspects[i].name,
      panel_x + 14,
      y,
      19,
      @raylib.Color::new(224, 236, 252, 230),
    )

    let conf = suspect_confidence(game, i)
    let conf_ratio = game.suspects[i].suspicion

    @raylib.draw_rectangle(
      panel_x + 14,
      y + 30,
      panel_w - 28,
      14,
      @raylib.Color::new(26, 32, 48, 220),
    )
    @raylib.draw_rectangle(
      panel_x + 15,
      y + 31,
      (Float::from_int(panel_w - 30) * conf_ratio).to_int(),
      12,
      a_col(col, 206),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 14,
      y + 30,
      panel_w - 28,
      14,
      @raylib.Color::new(120, 150, 188, 180),
    )

    @raylib.draw_text(
      "Confidence " + conf.to_string(),
      panel_x + 14,
      y + 52,
      16,
      @raylib.Color::new(196, 214, 238, 220),
    )

    let chains = completed_chains(game, i)
    @raylib.draw_text(
      "Chains " + chains.to_string() + "/" + chains_per_suspect.to_string(),
      panel_x + 14,
      y + 74,
      16,
      @raylib.Color::new(182, 206, 236, 220),
    )

    let ded = if game.suspects[i].deduction_unlocked {
      "Deduction unlocked"
    } else {
      "Deduction locked"
    }
    @raylib.draw_text(
      ded,
      panel_x + 14,
      y + 96,
      16,
      @raylib.Color::new(244, 220, 156, 224),
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
    @raylib.Color::new(4, 8, 16, 112),
  )

  draw_center_text(
    "INK SCROLL: DETECTIVE",
    218,
    64,
    @raylib.Color::new(236, 246, 255, 250),
  )

  draw_center_text(
    "Inspect clues, question suspects, resolve incidents before trust collapses.",
    306,
    26,
    @raylib.Color::new(198, 218, 244, 232),
  )

  draw_center_text(
    "WASD/Arrows Move  J Inspect/Confirm  K Mark/Back  Space Focus  P Pause  R Restart",
    354,
    22,
    @raylib.Color::new(176, 202, 232, 224),
  )

  draw_center_text(
    "Press J to begin investigation",
    430,
    34,
    @raylib.Color::new(250, 232, 170, 246),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 10, 20, 136),
  )
  draw_center_text("PAUSED", 328, 62, @raylib.Color::new(238, 246, 255, 250))
  draw_center_text(
    "Press P or K to resume",
    404,
    30,
    @raylib.Color::new(190, 212, 240, 228),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 18, 174),
  )

  draw_center_text(
    "CASE CLOSED",
    256,
    62,
    @raylib.Color::new(250, 236, 212, 246),
  )

  draw_center_text(
    "Score " + game.score.to_string() + "   Best " + game.best_score.to_string(),
    344,
    34,
    @raylib.Color::new(236, 242, 255, 238),
  )

  draw_center_text(
    "Solved " +
    game.solved_incidents.to_string() +
    "   Failed " +
    game.failed_incidents.to_string() +
    "   Wrong " +
    game.wrong_accusations.to_string(),
    392,
    30,
    @raylib.Color::new(210, 224, 244, 228),
  )

  draw_center_text(
    "Clues collected " +
    game.clue_found.to_string() +
    "/" +
    clue_count.to_string(),
    436,
    30,
    @raylib.Color::new(198, 216, 240, 228),
  )

  draw_center_text(
    "Press J or R to restart, K for title",
    502,
    30,
    @raylib.Color::new(250, 226, 168, 242),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_districts(game)
  draw_district_ids()
  draw_clues(game)
  draw_suspects(game)
  draw_incidents(game)
  draw_cursor(game)
  draw_hud(game)
  draw_suspect_board(game)

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
