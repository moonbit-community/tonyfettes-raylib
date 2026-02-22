///|
fn bg_wave(game : Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

  let w0 : Float = bg_wave(game, 0.64)
  let w1 : Float = bg_wave(game, 0.94)

  @raylib.draw_circle(
    240,
    170,
    220.0 + w0 * 20.0,
    @raylib.Color::new(24, 46, 84, 46),
  )
  @raylib.draw_circle(
    screen_w - 280,
    190,
    200.0 - w1 * 16.0,
    @raylib.Color::new(64, 36, 64, 36),
  )

  for i = 0; i < 14; i = i + 1 {
    let y : Int = i * 74
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      52,
      @raylib.Color::new(
        12 + i * 6 % 20,
        16 + i * 8 % 20,
        26 + i * 9 % 24,
        14 + i * 9 % 26,
      ),
    )
  }
}

///|
fn draw_board_back(bx : Int, by : Int, tile : Int) -> Unit {
  let bw : Int = board_w * tile
  let bh : Int = board_h * tile

  @raylib.draw_rectangle(
    bx - 18,
    by - 18,
    bw + 36,
    bh + 36,
    @raylib.Color::new(16, 24, 38, 232),
  )
  @raylib.draw_rectangle_lines(
    bx - 18,
    by - 18,
    bw + 36,
    bh + 36,
    @raylib.Color::new(150, 188, 220, 210),
  )

  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(24, 34, 52, 236))
}

///|
fn draw_cell_hidden(x : Int, y : Int, tile : Int, flagged : Bool) -> Unit {
  @raylib.draw_rectangle(
    x + 1,
    y + 1,
    tile - 2,
    tile - 2,
    @raylib.Color::new(52, 76, 110, 236),
  )

  @raylib.draw_rectangle(
    x + 3,
    y + 3,
    tile - 6,
    tile / 3,
    @raylib.Color::new(88, 122, 160, 140),
  )

  if flagged {
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(x + tile / 2 - 6),
        Float::from_int(y + 8),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + tile / 2 - 6),
        Float::from_int(y + tile - 8),
      ),
      @raylib.Vector2::new(
        Float::from_int(x + tile - 8),
        Float::from_int(y + tile / 2),
      ),
      @raylib.Color::new(232, 78, 86, 248),
    )
    @raylib.draw_rectangle(
      x + tile / 2 - 9,
      y + 8,
      4,
      tile - 16,
      @raylib.Color::new(224, 226, 236, 236),
    )
  }
}

///|
fn number_color(v : Int) -> @raylib.Color {
  if v == 1 {
    @raylib.Color::new(120, 188, 255, 255)
  } else if v == 2 {
    @raylib.Color::new(112, 236, 160, 255)
  } else if v == 3 {
    @raylib.Color::new(255, 132, 136, 255)
  } else if v == 4 {
    @raylib.Color::new(186, 152, 255, 255)
  } else if v == 5 {
    @raylib.Color::new(255, 176, 112, 255)
  } else if v == 6 {
    @raylib.Color::new(132, 232, 242, 255)
  } else if v == 7 {
    @raylib.Color::new(224, 224, 236, 255)
  } else {
    @raylib.Color::new(255, 206, 120, 255)
  }
}

///|
fn draw_cell_revealed(
  x : Int,
  y : Int,
  tile : Int,
  around : Int,
  mine : Bool,
  exploded : Bool,
) -> Unit {
  @raylib.draw_rectangle(
    x + 1,
    y + 1,
    tile - 2,
    tile - 2,
    if exploded {
      @raylib.Color::new(124, 36, 48, 250)
    } else {
      @raylib.Color::new(34, 44, 62, 250)
    },
  )

  if mine {
    @raylib.draw_circle(
      x + tile / 2,
      y + tile / 2,
      Float::from_int(tile) * 0.24,
      @raylib.Color::new(34, 34, 42, 252),
    )
    @raylib.draw_circle_lines(
      x + tile / 2,
      y + tile / 2,
      Float::from_int(tile) * 0.24,
      @raylib.Color::new(240, 112, 112, 236),
    )
    return
  }

  if around > 0 {
    let s : String = around.to_string()
    let fs : Int = tile / 2 + 6
    @raylib.draw_text(
      s,
      x + tile / 2 - @raylib.measure_text(s, fs) / 2,
      y + tile / 2 - fs / 2,
      fs,
      number_color(around),
    )
  }
}

///|
fn draw_grid_lines(bx : Int, by : Int, tile : Int) -> Unit {
  let bw : Int = board_w * tile
  let bh : Int = board_h * tile

  for x = 0; x <= board_w; x = x + 1 {
    let px : Int = bx + x * tile
    @raylib.draw_line(
      px,
      by,
      px,
      by + bh,
      @raylib.Color::new(74, 100, 130, 108),
    )
  }

  for y = 0; y <= board_h; y = y + 1 {
    let py : Int = by + y * tile
    @raylib.draw_line(
      bx,
      py,
      bx + bw,
      py,
      @raylib.Color::new(74, 100, 130, 108),
    )
  }
}

///|
fn draw_cells(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  for y = 0; y < board_h; y = y + 1 {
    for x = 0; x < board_w; x = x + 1 {
      let i : Int = idx(x, y)
      let px : Int = bx + x * tile
      let py : Int = by + y * tile

      if game.cells[i].revealed ||
        (game.state == state_result && game.cells[i].mine) {
        draw_cell_revealed(
          px,
          py,
          tile,
          game.cells[i].around,
          game.cells[i].mine,
          game.cells[i].exploded,
        )
      } else {
        draw_cell_hidden(px, py, tile, game.cells[i].flagged)
      }
    }
  }

  draw_grid_lines(bx, by, tile)
}

///|
fn draw_last_reveal(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  if game.last_reveal_x < 0 || game.last_reveal_y < 0 {
    return
  }

  let px : Int = bx + game.last_reveal_x * tile
  let py : Int = by + game.last_reveal_y * tile

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(px + 5),
      Float::from_int(py + 5),
      Float::from_int(tile - 10),
      Float::from_int(tile - 10),
    ),
    2.0,
    @raylib.Color::new(132, 214, 255, 226),
  )
}

///|
fn draw_cursor(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  if game.state != state_play {
    return
  }

  let x : Int = bx + game.cursor_x * tile
  let y : Int = by + game.cursor_y * tile

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(x + 2),
      Float::from_int(y + 2),
      Float::from_int(tile - 4),
      Float::from_int(tile - 4),
    ),
    2.0,
    if game.mode == mode_reveal {
      @raylib.Color::new(254, 254, 254, 250)
    } else {
      @raylib.Color::new(255, 202, 132, 250)
    },
  )
}

///|
fn draw_sparks(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let a : Int = if game.sparks[i].life > 0.7 {
      236
    } else if game.sparks[i].life > 0.4 {
      196
    } else {
      132
    }

    let c : @raylib.Color = if game.sparks[i].kind == 2 {
      @raylib.Color::new(255, 126, 112, a)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(250, 204, 120, a)
    } else {
      @raylib.Color::new(142, 210, 255, a)
    }

    @raylib.draw_circle(
      game.sparks[i].x.to_int(),
      game.sparks[i].y.to_int(),
      1.0 + game.sparks[i].size,
      c,
    )
  }
}

///|
fn draw_progress_bar(game : Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  let pct : Int = clear_ratio_pct(game)

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(28, 42, 60, 220))
  @raylib.draw_rectangle(
    x,
    y,
    w * pct / 100,
    h,
    @raylib.Color::new(86, 162, 216, 236),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(176, 210, 236, 228),
  )

  let s : String = "\{pct}%"
  @raylib.draw_text(
    s,
    x + w / 2 - @raylib.measure_text(s, 24) / 2,
    y + h / 2 - 12,
    24,
    @raylib.Color::new(244, 250, 255, 248),
  )
}

///|
fn draw_touch_button(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  active : Bool,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if active {
      color
    } else {
      @raylib.Color::new(42, 60, 86, 206)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(184, 216, 242, 224),
  )

  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, 28) / 2,
    y + h / 2 - 14,
    28,
    @raylib.Color::new(246, 252, 255, 248),
  )
}

///|
fn draw_touch_ui(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if game.state != state_play {
    return
  }

  let (mx0, my0, mw0, mh0) = touch_mode_button()
  let (hx0, hy0, hw0, hh0) = touch_hint_button()
  let (rx0, ry0, rw0, rh0) = touch_reset_button()
  let (ax0, ay0, aw0, ah0) = touch_reveal_button()

  let mode_on : Bool = pointer_on_rect(
    mx, my, hold, touch_count, mx0, my0, mw0, mh0,
  )
  let hint_on : Bool = pointer_on_rect(
    mx, my, hold, touch_count, hx0, hy0, hw0, hh0,
  )
  let reset_on : Bool = pointer_on_rect(
    mx, my, hold, touch_count, rx0, ry0, rw0, rh0,
  )
  let action_on : Bool = pointer_on_rect(
    mx, my, hold, touch_count, ax0, ay0, aw0, ah0,
  )

  draw_touch_button(
    if game.mode == mode_reveal {
      "MODE: REVEAL"
    } else {
      "MODE: FLAG"
    },
    mx0,
    my0,
    mw0,
    mh0,
    mode_on,
    @raylib.Color::new(88, 146, 206, 228),
  )
  draw_touch_button(
    "HINT \{game.hints}",
    hx0,
    hy0,
    hw0,
    hh0,
    hint_on,
    @raylib.Color::new(170, 136, 84, 228),
  )
  draw_touch_button(
    "RESTART",
    rx0,
    ry0,
    rw0,
    rh0,
    reset_on,
    @raylib.Color::new(138, 102, 92, 228),
  )
  draw_touch_button(
    if game.mode == mode_reveal {
      "REVEAL CELL"
    } else {
      "TOGGLE FLAG"
    },
    ax0,
    ay0,
    aw0,
    ah0,
    action_on,
    @raylib.Color::new(102, 152, 200, 228),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  let px : Int = panel_x()
  let py : Int = 20
  let pw : Int = screen_w - panel_x() - 22
  let ph : Int = screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(14, 22, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(126, 166, 202, 216),
  )

  @raylib.draw_text(
    "Minesweeper Neon Ops",
    px + 18,
    py + 20,
    42,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "City Grid 2026",
    px + 18,
    py + 66,
    28,
    @raylib.Color::new(196, 220, 244, 238),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 18,
    py + 108,
    34,
    @raylib.Color::new(226, 240, 254, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    px + 280,
    py + 108,
    32,
    @raylib.Color::new(194, 220, 246, 238),
  )

  @raylib.draw_text(
    "Lives \{game.lives}",
    px + 18,
    py + 152,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Mines \{game.mine_count}",
    px + 170,
    py + 152,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Flags Left \{flags_left(game)}",
    px + 340,
    py + 152,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )

  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 18,
    py + 190,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Mistakes \{game.mistakes}",
    px + 210,
    py + 190,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Combo x\{game.combo}",
    px + 400,
    py + 190,
    30,
    @raylib.Color::new(214, 232, 252, 244),
  )

  draw_progress_bar(game, px + 18, py + 234, pw - 36, 36)

  @raylib.draw_text(
    "Unrevealed Safe Cells: \{unrevealed_safe_cells(game)}",
    px + 18,
    py + 282,
    30,
    @raylib.Color::new(208, 228, 248, 242),
  )

  let mode_name : String = if game.mode == mode_reveal {
    "Reveal"
  } else {
    "Flag"
  }

  @raylib.draw_text(
    "Current Mode: \{mode_name}",
    px + 18,
    py + 326,
    28,
    @raylib.Color::new(208, 228, 248, 242),
  )

  if game.combo > 1 {
    @raylib.draw_text(
      "Combo Bonus x\{game.combo}",
      px + 18,
      py + 364,
      30,
      @raylib.Color::new(255, 220, 132, 246),
    )
  }

  @raylib.draw_text(
    "Controls",
    px + 18,
    py + 428,
    28,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows",
    px + 18,
    py + 460,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Reveal: Enter/Space",
    px + 18,
    py + 486,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Flag: F / Right Click",
    px + 18,
    py + 512,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Mode: M  Hint: H",
    px + 18,
    py + 538,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Restart: R  Back: ESC",
    px + 18,
    py + 564,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      px + 18,
      py + 602,
      pw - 36,
      56,
      @raylib.Color::new(40, 58, 82, 224),
    )
    @raylib.draw_rectangle_lines(
      px + 18,
      py + 602,
      pw - 36,
      56,
      @raylib.Color::new(176, 208, 236, 230),
    )
    @raylib.draw_text(
      game.msg,
      px + 30,
      py + 620,
      28,
      @raylib.Color::new(246, 252, 255, 248),
    )
  }
}

///|
fn draw_title(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Unit {
  @raylib.draw_text(
    "Minesweeper Neon Ops 2026",
    screen_w / 2 - @raylib.measure_text("Minesweeper Neon Ops 2026", 84) / 2,
    108,
    84,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "Classic minefield puzzle remixed with lives, combo scoring, and tactical hints.",
    screen_w / 2 -
    @raylib.measure_text(
      "Classic minefield puzzle remixed with lives, combo scoring, and tactical hints.",
      34,
    ) /
    2,
    246,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )
  @raylib.draw_text(
    "Touch controls are available for mobile play.",
    screen_w / 2 -
    @raylib.measure_text("Touch controls are available for mobile play.", 34) /
    2,
    288,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let (x, y, w, h) = title_start_button()
  let hov : Bool = title_hover(mx, my, hold, touch_count)

  draw_touch_button(
    "Start Operation",
    x,
    y,
    w,
    h,
    hov,
    @raylib.Color::new(88, 148, 204, 228),
  )

  @raylib.draw_text(
    "Tip: first reveal is always safe, so start aggressively near the center.",
    screen_w / 2 -
    @raylib.measure_text(
      "Tip: first reveal is always safe, so start aggressively near the center.",
      30,
    ) /
    2,
    772,
    30,
    @raylib.Color::new(188, 212, 238, 234),
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
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 840
  let ph : Int = 500
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 24, 36, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(170, 204, 236, 234),
  )

  let title : String = if game.win {
    "Operation Success"
  } else {
    "Operation Failed"
  }

  @raylib.draw_text(
    title,
    px + pw / 2 - @raylib.measure_text(title, 64) / 2,
    py + 32,
    64,
    @raylib.Color::new(244, 250, 255, 250),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 110,
    py + 136,
    42,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @raylib.draw_text(
    "Grade \{grade_name(game.grade)}  \{grade_title(game.grade)}",
    px + 110,
    py + 186,
    38,
    @raylib.Color::new(216, 236, 254, 244),
  )
  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 110,
    py + 236,
    34,
    @raylib.Color::new(206, 228, 248, 238),
  )
  @raylib.draw_text(
    "Mistakes \{game.mistakes}",
    px + 110,
    py + 276,
    34,
    @raylib.Color::new(206, 228, 248, 238),
  )
  @raylib.draw_text(
    "Best Combo x\{game.combo_best}",
    px + 110,
    py + 316,
    34,
    @raylib.Color::new(206, 228, 248, 238),
  )

  let (bx, by, bw, bh) = result_retry_button()
  let hov : Bool = result_hover(mx, my, hold, touch_count)

  draw_touch_button(
    "Play Again",
    bx,
    by,
    bw,
    bh,
    hov,
    @raylib.Color::new(92, 152, 206, 230),
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
  draw_bg(game)

  if game.state == state_title {
    draw_title(mx, my, hold, touch_count)
    return
  }

  let (bx, by, tile) = board_metrics(game)
  draw_board_back(bx, by, tile)
  draw_cells(game, bx, by, tile)
  draw_last_reveal(game, bx, by, tile)
  draw_cursor(game, bx, by, tile)

  draw_sparks(game)
  draw_panel(game)
  draw_touch_ui(game, mx, my, hold, touch_count)

  if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
