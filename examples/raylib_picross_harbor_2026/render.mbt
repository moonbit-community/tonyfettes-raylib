///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(9, 12, 18, 255))

  let wave : Float = Float::from_double(
    @math.sin((game.ui_t * 0.6).to_double()),
  )

  @raylib.draw_circle(
    220,
    150,
    180.0 + wave * 14.0,
    @raylib.Color::new(24, 44, 64, 46),
  )
  @raylib.draw_circle(
    screen_w - 220,
    180,
    190.0 - wave * 12.0,
    @raylib.Color::new(54, 34, 26, 34),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 66 - 20
    let alpha : Int = 16 + i * 9 % 30
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      52,
      @raylib.Color::new(
        14 + i * 6 % 24,
        22 + i * 8 % 24,
        34 + i * 10 % 24,
        alpha,
      ),
    )
  }
}

///|
fn board_font_size(tile : Int) -> Int {
  clampi(tile / 2, 14, 24)
}

///|
fn draw_spark_layer(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let c : @raylib.Color = if game.sparks[i].kind == 0 {
      @raylib.Color::new(255, 218, 116, 236)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(122, 214, 255, 236)
    } else if game.sparks[i].kind == 2 {
      @raylib.Color::new(246, 106, 94, 228)
    } else {
      @raylib.Color::new(206, 228, 255, 226)
    }

    @raylib.draw_circle(
      game.sparks[i].x.to_int(),
      game.sparks[i].y.to_int(),
      maxf(1.0, game.sparks[i].size),
      c,
    )
  }
}

///|
fn draw_board(game : Game) -> Unit {
  let (board_x, board_y, tile, clue_l, clue_t, origin_x, origin_y) = board_metrics(
    game,
  )

  let fs : Int = board_font_size(tile)

  let clue_w : Int = clue_l * tile
  let clue_h : Int = clue_t * tile
  let board_w : Int = game.grid_w * tile
  let board_h : Int = game.grid_h * tile

  @raylib.draw_rectangle(
    origin_x - 10,
    origin_y - 10,
    clue_w + board_w + 20,
    clue_h + board_h + 20,
    @raylib.Color::new(9, 14, 22, 200),
  )

  @raylib.draw_rectangle(
    origin_x,
    origin_y,
    clue_w,
    clue_h,
    @raylib.Color::new(16, 22, 33, 244),
  )
  @raylib.draw_rectangle(
    origin_x,
    board_y,
    clue_w,
    board_h,
    @raylib.Color::new(17, 24, 36, 244),
  )
  @raylib.draw_rectangle(
    board_x,
    origin_y,
    board_w,
    clue_h,
    @raylib.Color::new(17, 24, 36, 244),
  )

  @raylib.draw_rectangle_lines(
    origin_x - 10,
    origin_y - 10,
    clue_w + board_w + 20,
    clue_h + board_h + 20,
    @raylib.Color::new(110, 146, 178, 182),
  )

  for y = 0; y < game.grid_h; y = y + 1 {
    let solved : Bool = row_solved(game, y)
    let count : Int = game.row_clue_counts[y]

    for k = 0; k < count; k = k + 1 {
      let val : Int = game.row_clues[y * max_board + (count - 1 - k)]
      let tx : Int = board_x - (k + 1) * tile + tile / 2
      let ty : Int = board_y + y * tile + tile / 2 - fs / 2
      let text : String = if val == 0 { "-" } else { "\{val}" }

      @raylib.draw_text(
        text,
        tx - @raylib.measure_text(text, fs) / 2,
        ty,
        fs,
        if solved {
          @raylib.Color::new(126, 220, 152, 245)
        } else {
          @raylib.Color::new(176, 198, 221, 236)
        },
      )
    }
  }

  for x = 0; x < game.grid_w; x = x + 1 {
    let solved : Bool = col_solved(game, x)
    let count : Int = game.col_clue_counts[x]

    for k = 0; k < count; k = k + 1 {
      let val : Int = game.col_clues[x * max_board + (count - 1 - k)]
      let tx : Int = board_x + x * tile + tile / 2
      let ty : Int = board_y - (k + 1) * tile + tile / 2 - fs / 2
      let text : String = if val == 0 { "-" } else { "\{val}" }

      @raylib.draw_text(
        text,
        tx - @raylib.measure_text(text, fs) / 2,
        ty,
        fs,
        if solved {
          @raylib.Color::new(126, 220, 152, 245)
        } else {
          @raylib.Color::new(176, 198, 221, 236)
        },
      )
    }
  }

  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      let px : Int = board_x + x * tile
      let py : Int = board_y + y * tile

      let sol : Bool = solution_at(game, x, y)
      let state : Int = cell_at(game, x, y)

      let mut bg : @raylib.Color = @raylib.Color::new(28, 34, 45, 255)
      if (x + y) % 2 == 0 {
        bg = @raylib.Color::new(30, 37, 49, 255)
      }

      @raylib.draw_rectangle(px, py, tile, tile, bg)

      if state == cell_fill {
        @raylib.draw_rectangle(
          px + 3,
          py + 3,
          tile - 6,
          tile - 6,
          if sol {
            @raylib.Color::new(92, 198, 242, 255)
          } else {
            @raylib.Color::new(210, 84, 74, 248)
          },
        )
        @raylib.draw_rectangle_lines(
          px + 3,
          py + 3,
          tile - 6,
          tile - 6,
          if sol {
            @raylib.Color::new(202, 242, 255, 240)
          } else {
            @raylib.Color::new(255, 190, 182, 240)
          },
        )
      } else if state == cell_cross {
        let cc : @raylib.Color = if sol {
          @raylib.Color::new(244, 122, 108, 242)
        } else {
          @raylib.Color::new(192, 206, 224, 224)
        }
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(px + 6), Float::from_int(py + 6)),
          @raylib.Vector2::new(
            Float::from_int(px + tile - 6),
            Float::from_int(py + tile - 6),
          ),
          3.0,
          cc,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(
            Float::from_int(px + tile - 6),
            Float::from_int(py + 6),
          ),
          @raylib.Vector2::new(
            Float::from_int(px + 6),
            Float::from_int(py + tile - 6),
          ),
          3.0,
          cc,
        )
      }

      @raylib.draw_rectangle_lines(
        px,
        py,
        tile,
        tile,
        @raylib.Color::new(58, 72, 90, 162),
      )
    }
  }

  if game.state == state_play {
    let cx : Int = board_x + game.cursor_x * tile
    let cy : Int = board_y + game.cursor_y * tile
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(cx + 1),
        Float::from_int(cy + 1),
        Float::from_int(tile - 2),
        Float::from_int(tile - 2),
      ),
      3.0,
      @raylib.Color::new(246, 250, 255, 255),
    )
  }

  draw_spark_layer(game)
}

///|
fn draw_button(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  active : Bool,
  accent : @raylib.Color,
) -> Unit {
  let bg : @raylib.Color = if active {
    accent
  } else {
    @raylib.Color::new(47, 62, 84, 226)
  }

  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(190, 218, 242, 236),
  )

  let fs : Int = 28
  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, fs) / 2,
    y + h / 2 - fs / 2,
    fs,
    @raylib.Color::new(242, 250, 255, 248),
  )
}

///|
fn draw_side_panel(game : Game) -> Unit {
  let px : Int = right_panel_x()
  let py : Int = 20
  let pw : Int = 396
  let ph : Int = screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(12, 18, 28, 242))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(114, 158, 188, 206),
  )

  @raylib.draw_text(
    "Picross Harbor 2026",
    px + 20,
    py + 22,
    38,
    @raylib.Color::new(238, 248, 255, 246),
  )
  @raylib.draw_text(
    "Nonogram Campaign",
    px + 20,
    py + 66,
    24,
    @raylib.Color::new(186, 216, 238, 236),
  )

  @raylib.draw_text(
    "Level \{game.level_index + 1}/\{game.level_count}",
    px + 20,
    py + 112,
    30,
    @raylib.Color::new(226, 236, 250, 242),
  )
  @raylib.draw_text(
    game.level_name,
    px + 20,
    py + 150,
    28,
    @raylib.Color::new(252, 224, 142, 246),
  )

  @raylib.draw_text(
    "Time \{game.level_time.to_int()}s / \{game.level_par_time}s",
    px + 20,
    py + 206,
    26,
    @raylib.Color::new(210, 230, 248, 236),
  )
  @raylib.draw_text(
    "Mistakes \{game.mistakes}/\{game.level_mistake_limit}",
    px + 20,
    py + 238,
    26,
    @raylib.Color::new(210, 230, 248, 236),
  )
  @raylib.draw_text(
    "Hints \{game.hints_left}  Used \{game.hints_used}",
    px + 20,
    py + 270,
    26,
    @raylib.Color::new(210, 230, 248, 236),
  )

  let progress : Float = if game.solution_total <= 0 {
    0.0
  } else {
    Float::from_int(game.filled_correct) / Float::from_int(game.solution_total)
  }
  let bar_x : Int = px + 20
  let bar_y : Int = py + 314
  let bar_w : Int = pw - 40
  let bar_h : Int = 24

  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(28, 34, 48, 255),
  )
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    (Float::from_int(bar_w) * progress).to_int(),
    bar_h,
    @raylib.Color::new(94, 200, 240, 255),
  )
  @raylib.draw_rectangle_lines(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(170, 206, 234, 220),
  )

  @raylib.draw_text(
    "Correct fills \{game.filled_correct}/\{game.solution_total}",
    px + 20,
    py + 346,
    24,
    @raylib.Color::new(206, 224, 244, 236),
  )
  @raylib.draw_text(
    "Wrong fills \{game.filled_wrong}",
    px + 20,
    py + 374,
    24,
    @raylib.Color::new(206, 224, 244, 236),
  )

  @raylib.draw_text(
    "Campaign stars \{game.total_stars}",
    px + 20,
    py + 418,
    24,
    @raylib.Color::new(255, 218, 122, 246),
  )
  @raylib.draw_text(
    "Completed \{game.total_completed}",
    px + 20,
    py + 446,
    24,
    @raylib.Color::new(206, 224, 244, 236),
  )

  @raylib.draw_text(
    "Keyboard",
    px + 20,
    py + 498,
    24,
    @raylib.Color::new(224, 238, 250, 240),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    px + 20,
    py + 526,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Fill: Space/F",
    px + 20,
    py + 552,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Mark: X/C",
    px + 20,
    py + 578,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Undo: Z",
    px + 20,
    py + 604,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Hint: H",
    px + 20,
    py + 630,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Reset: R",
    px + 20,
    py + 656,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Swap tool: Tab",
    px + 20,
    py + 682,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )

  let (fx, fy, fw, fh) = fill_button_rect()
  let (cx, cy, cw, ch) = cross_button_rect()
  let (ux, uy, uw, uh) = undo_button_rect()
  let (hx, hy, hw, hh) = hint_button_rect()
  let (rx, ry, rw, rh) = reset_button_rect()

  draw_button(
    "FILL",
    fx,
    fy,
    fw,
    fh,
    game.tool_mode == tool_fill,
    @raylib.Color::new(66, 154, 202, 236),
  )
  draw_button(
    "MARK",
    cx,
    cy,
    cw,
    ch,
    game.tool_mode == tool_cross,
    @raylib.Color::new(158, 116, 76, 236),
  )
  draw_button(
    "UNDO",
    ux,
    uy,
    uw,
    uh,
    false,
    @raylib.Color::new(78, 116, 148, 236),
  )
  draw_button(
    "HINT",
    hx,
    hy,
    hw,
    hh,
    false,
    @raylib.Color::new(162, 126, 66, 236),
  )
  draw_button(
    "RESET",
    rx,
    ry,
    rw,
    rh,
    false,
    @raylib.Color::new(126, 80, 76, 236),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + ph - 86,
      pw - 40,
      52,
      @raylib.Color::new(38, 50, 70, 232),
    )
    @raylib.draw_rectangle_lines(
      px + 20,
      py + ph - 86,
      pw - 40,
      52,
      @raylib.Color::new(172, 206, 232, 238),
    )
    @raylib.draw_text(
      game.message,
      px + 30,
      py + ph - 70,
      28,
      @raylib.Color::new(244, 250, 255, 248),
    )
  }
}

///|
fn draw_touch_controls(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  ignore(game)

  let cx : Int = dpad_center_x()
  let cy : Int = dpad_center_y()
  let s : Int = dpad_size()

  let left_on : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s - 18,
    cy - s / 2,
    s,
    s,
  )
  let right_on : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx + 18,
    cy - s / 2,
    s,
    s,
  )
  let up_on : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s / 2,
    cy - s - 18,
    s,
    s,
  )
  let down_on : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s / 2,
    cy + 18,
    s,
    s,
  )

  let base : @raylib.Color = @raylib.Color::new(40, 54, 74, 176)
  let on : @raylib.Color = @raylib.Color::new(82, 132, 170, 224)
  let edge : @raylib.Color = @raylib.Color::new(176, 214, 242, 214)

  @raylib.draw_rectangle(
    cx - s - 18,
    cy - s / 2,
    s,
    s,
    if left_on {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx + 18,
    cy - s / 2,
    s,
    s,
    if right_on {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx - s / 2,
    cy - s - 18,
    s,
    s,
    if up_on {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx - s / 2,
    cy + 18,
    s,
    s,
    if down_on {
      on
    } else {
      base
    },
  )

  @raylib.draw_rectangle_lines(cx - s - 18, cy - s / 2, s, s, edge)
  @raylib.draw_rectangle_lines(cx + 18, cy - s / 2, s, s, edge)
  @raylib.draw_rectangle_lines(cx - s / 2, cy - s - 18, s, s, edge)
  @raylib.draw_rectangle_lines(cx - s / 2, cy + 18, s, s, edge)

  @raylib.draw_text(
    "L",
    cx - s + 16 - 18,
    cy - 8,
    28,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "R",
    cx + 18 + 20,
    cy - 8,
    28,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "U",
    cx - 10,
    cy - s - 2,
    28,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "D",
    cx - 10,
    cy + s + 26,
    28,
    @raylib.Color::new(236, 246, 255, 248),
  )
}

///|
fn draw_title_screen(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  ignore(game)

  @raylib.draw_text(
    "Picross Harbor 2026",
    screen_w / 2 - @raylib.measure_text("Picross Harbor 2026", 92) / 2,
    108,
    92,
    @raylib.Color::new(238, 248, 255, 248),
  )
  @raylib.draw_text(
    "Decode harbor blueprints, one nonogram at a time.",
    screen_w / 2 -
    @raylib.measure_text(
      "Decode harbor blueprints, one nonogram at a time.", 36,
    ) /
    2,
    246,
    36,
    @raylib.Color::new(190, 218, 238, 238),
  )
  @raylib.draw_text(
    "12 handcrafted puzzles | keyboard + touch",
    screen_w / 2 -
    @raylib.measure_text("12 handcrafted puzzles | keyboard + touch", 34) / 2,
    292,
    34,
    @raylib.Color::new(190, 218, 238, 238),
  )

  @raylib.draw_text(
    "Fill cells to match row/column clues. Avoid wrong fills and wrong crosses.",
    screen_w / 2 -
    @raylib.measure_text(
      "Fill cells to match row/column clues. Avoid wrong fills and wrong crosses.",
      30,
    ) /
    2,
    404,
    30,
    @raylib.Color::new(218, 234, 248, 236),
  )
  @raylib.draw_text(
    "Hints are limited but can save a run.",
    screen_w / 2 -
    @raylib.measure_text("Hints are limited but can save a run.", 30) / 2,
    442,
    30,
    @raylib.Color::new(218, 234, 248, 236),
  )

  let (bx, by, bw, bh) = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )

  draw_button(
    "Start Campaign",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(86, 144, 184, 236),
  )
}

///|
fn draw_level_clear_overlay(
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
    @raylib.Color::new(6, 10, 18, 166),
  )

  let pw : Int = 760
  let ph : Int = 420
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 26, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(168, 208, 236, 236),
  )

  @raylib.draw_text(
    "Puzzle Cleared",
    px + pw / 2 - @raylib.measure_text("Puzzle Cleared", 62) / 2,
    py + 34,
    62,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Time: \{game.level_time.to_int()}s",
    px + 94,
    py + 136,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Mistakes: \{game.mistakes}",
    px + 94,
    py + 182,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Hints used: \{game.hints_used}",
    px + 94,
    py + 228,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )

  let stars_text : String = if game.last_level_stars >= 3 {
    "Stars: ***"
  } else if game.last_level_stars == 2 {
    "Stars: **"
  } else {
    "Stars: *"
  }

  @raylib.draw_text(
    stars_text,
    px + 94,
    py + 282,
    46,
    @raylib.Color::new(255, 220, 126, 248),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Next Puzzle",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(86, 142, 180, 236),
  )
}

///|
fn draw_level_fail_overlay(
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
    @raylib.Color::new(10, 4, 4, 168),
  )

  let pw : Int = 760
  let ph : Int = 400
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(40, 20, 20, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(244, 178, 170, 230),
  )

  @raylib.draw_text(
    "Puzzle Failed",
    px + pw / 2 - @raylib.measure_text("Puzzle Failed", 62) / 2,
    py + 34,
    62,
    @raylib.Color::new(255, 236, 236, 250),
  )
  @raylib.draw_text(
    "Mistakes reached \{game.mistakes}/\{game.level_mistake_limit}",
    px + 92,
    py + 154,
    36,
    @raylib.Color::new(252, 222, 214, 242),
  )
  @raylib.draw_text(
    "Press R or tap Retry to restart this board.",
    px + 92,
    py + 206,
    34,
    @raylib.Color::new(244, 208, 198, 236),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Retry",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(154, 90, 84, 238),
  )
}

///|
fn draw_campaign_clear_overlay(
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
    @raylib.Color::new(6, 10, 16, 176),
  )

  let pw : Int = 920
  let ph : Int = 540
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 25, 35, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(166, 206, 236, 236),
  )

  @raylib.draw_text(
    "Campaign Complete",
    px + pw / 2 - @raylib.measure_text("Campaign Complete", 68) / 2,
    py + 32,
    68,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Total stars: \{game.total_stars}",
    px + 110,
    py + 152,
    42,
    @raylib.Color::new(255, 220, 126, 248),
  )
  @raylib.draw_text(
    "Boards solved: \{game.total_completed}",
    px + 110,
    py + 204,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Total time: \{game.total_time.to_int()}s",
    px + 110,
    py + 246,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Total mistakes: \{game.total_mistakes}",
    px + 110,
    py + 288,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Total hints used: \{game.total_hints}",
    px + 110,
    py + 330,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )

  @raylib.draw_text(
    "Press Enter / Space or tap button to play again",
    px + 110,
    py + 388,
    30,
    @raylib.Color::new(194, 220, 240, 232),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Restart Campaign",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(86, 142, 180, 236),
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
    draw_title_screen(game, mouse_x, mouse_y, mouse_hold, touch_count)
    return
  }

  draw_board(game)
  draw_side_panel(game)
  draw_touch_controls(game, mouse_x, mouse_y, mouse_hold, touch_count)

  if game.state == state_level_clear {
    draw_level_clear_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_campaign_clear {
    draw_campaign_clear_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_level_fail {
    draw_level_fail_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
