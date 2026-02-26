///|
fn color_for_kind(kind : Int) -> @raylib.Color {
  let r : Int = 72 + kind * 41 % 166
  let g : Int = 74 + kind * 67 % 158
  let b : Int = 80 + kind * 53 % 150
  @raylib.Color::new(r, g, b, 255)
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 14, 22, 255))

  let wave : Float = Float::from_double(
    @math.sin((game.ui_t * 0.62).to_double()),
  )

  @raylib.draw_circle(
    220,
    160,
    180.0 + wave * 14.0,
    @raylib.Color::new(26, 48, 72, 46),
  )
  @raylib.draw_circle(
    screen_w - 220,
    170,
    180.0 - wave * 12.0,
    @raylib.Color::new(62, 40, 28, 38),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 66 - 20
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      52,
      @raylib.Color::new(
        14 + i * 6 % 24,
        22 + i * 8 % 24,
        32 + i * 9 % 24,
        15 + i * 9 % 30,
      ),
    )
  }
}

///|
fn draw_sparks(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let c : @raylib.Color = if game.sparks[i].kind == 0 {
      @raylib.Color::new(255, 216, 108, 236)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(126, 220, 255, 236)
    } else if game.sparks[i].kind == 2 {
      @raylib.Color::new(248, 112, 96, 228)
    } else {
      @raylib.Color::new(220, 230, 255, 226)
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
fn draw_link_path(game : Game) -> Unit {
  if not(game.path_active) || game.path_points < 2 {
    return
  }

  for i = 0; i < game.path_points - 1; i = i + 1 {
    let (ax, ay) = path_point_flash(game, i)
    let (bx, by) = path_point_flash(game, i + 1)
    let (sx, sy) = world_center_ext(game, ax, ay)
    let (tx, ty) = world_center_ext(game, bx, by)

    @raylib.draw_line_ex(
      @raylib.Vector2::new(sx, sy),
      @raylib.Vector2::new(tx, ty),
      6.0,
      @raylib.Color::new(250, 230, 122, 244),
    )
    @raylib.draw_circle(
      sx.to_int(),
      sy.to_int(),
      5.0,
      @raylib.Color::new(255, 244, 180, 246),
    )
  }
}

///|
fn draw_hint_pair(game : Game) -> Unit {
  if not(game.hint_active) {
    return
  }

  let (board_x, board_y, tile) = board_metrics(game)

  let hx0 : Int = board_x + (game.hint_x0 - 1) * tile
  let hy0 : Int = board_y + (game.hint_y0 - 1) * tile
  let hx1 : Int = board_x + (game.hint_x1 - 1) * tile
  let hy1 : Int = board_y + (game.hint_y1 - 1) * tile

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(hx0 + 2),
      Float::from_int(hy0 + 2),
      Float::from_int(tile - 4),
      Float::from_int(tile - 4),
    ),
    3.0,
    @raylib.Color::new(252, 234, 136, 246),
  )

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(hx1 + 2),
      Float::from_int(hy1 + 2),
      Float::from_int(tile - 4),
      Float::from_int(tile - 4),
    ),
    3.0,
    @raylib.Color::new(252, 234, 136, 246),
  )
}

///|
fn draw_board(game : Game) -> Unit {
  let (board_x, board_y, tile) = board_metrics(game)

  @raylib.draw_rectangle(
    board_x - 12,
    board_y - 12,
    game.board_w * tile + 24,
    game.board_h * tile + 24,
    @raylib.Color::new(10, 16, 26, 206),
  )
  @raylib.draw_rectangle_lines(
    board_x - 12,
    board_y - 12,
    game.board_w * tile + 24,
    game.board_h * tile + 24,
    @raylib.Color::new(110, 150, 182, 182),
  )

  let text_size : Int = clampi(tile / 2, 16, 30)

  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      let k : Int = cell_at(game, x, y)
      let px : Int = board_x + (x - 1) * tile
      let py : Int = board_y + (y - 1) * tile

      @raylib.draw_rectangle(
        px,
        py,
        tile,
        tile,
        if (x + y) % 2 == 0 {
          @raylib.Color::new(26, 34, 46, 255)
        } else {
          @raylib.Color::new(30, 38, 52, 255)
        },
      )

      if k > 0 {
        let c : @raylib.Color = color_for_kind(k)

        @raylib.draw_rectangle(px + 4, py + 4, tile - 8, tile - 8, c)
        @raylib.draw_rectangle_lines(
          px + 4,
          py + 4,
          tile - 8,
          tile - 8,
          @raylib.Color::new(244, 248, 255, 226),
        )

        let label : String = "\{k}"
        @raylib.draw_text(
          label,
          px + tile / 2 - @raylib.measure_text(label, text_size) / 2,
          py + tile / 2 - text_size / 2,
          text_size,
          @raylib.Color::new(245, 252, 255, 250),
        )
      }

      @raylib.draw_rectangle_lines(
        px,
        py,
        tile,
        tile,
        @raylib.Color::new(64, 80, 100, 168),
      )
    }
  }

  if game.select_active {
    let sx : Int = board_x + (game.select_x - 1) * tile
    let sy : Int = board_y + (game.select_y - 1) * tile

    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(sx + 1),
        Float::from_int(sy + 1),
        Float::from_int(tile - 2),
        Float::from_int(tile - 2),
      ),
      4.0,
      @raylib.Color::new(255, 236, 136, 250),
    )
  }

  if game.state == state_play {
    let cx : Int = board_x + (game.cursor_x - 1) * tile
    let cy : Int = board_y + (game.cursor_y - 1) * tile

    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(cx + 3),
        Float::from_int(cy + 3),
        Float::from_int(tile - 6),
        Float::from_int(tile - 6),
      ),
      3.0,
      @raylib.Color::new(238, 246, 255, 248),
    )
  }

  draw_hint_pair(game)
  draw_link_path(game)
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
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if active {
      accent
    } else {
      @raylib.Color::new(46, 62, 86, 226)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(190, 220, 242, 236),
  )

  let fs : Int = 28
  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, fs) / 2,
    y + h / 2 - fs / 2,
    fs,
    @raylib.Color::new(244, 250, 255, 248),
  )
}

///|
fn draw_side_panel(game : Game) -> Unit {
  let px : Int = panel_x()
  let py : Int = 20
  let pw : Int = 396
  let ph : Int = screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(12, 18, 30, 242))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(114, 156, 188, 206),
  )

  @raylib.draw_text(
    "MatchLink Festival",
    px + 20,
    py + 22,
    36,
    @raylib.Color::new(238, 248, 255, 246),
  )
  @raylib.draw_text(
    "Lianliankan 2026",
    px + 20,
    py + 64,
    24,
    @raylib.Color::new(188, 216, 236, 236),
  )

  @raylib.draw_text(
    "Level \{game.level_index + 1}/\{game.level_count}",
    px + 20,
    py + 110,
    30,
    @raylib.Color::new(226, 236, 250, 242),
  )
  @raylib.draw_text(
    game.level_name,
    px + 20,
    py + 146,
    28,
    @raylib.Color::new(252, 224, 142, 246),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 198,
    30,
    @raylib.Color::new(230, 240, 252, 242),
  )
  @raylib.draw_text(
    "Combo \{game.combo}",
    px + 20,
    py + 232,
    28,
    @raylib.Color::new(210, 228, 246, 236),
  )
  @raylib.draw_text(
    "Time \{game.timer.to_int()}s",
    px + 20,
    py + 266,
    28,
    @raylib.Color::new(210, 228, 246, 236),
  )
  @raylib.draw_text(
    "Remaining \{game.remaining}",
    px + 20,
    py + 300,
    28,
    @raylib.Color::new(210, 228, 246, 236),
  )

  let ratio : Float = if game.time_limit <= 0.0 {
    0.0
  } else {
    game.timer / game.time_limit
  }

  @raylib.draw_rectangle(
    px + 20,
    py + 342,
    pw - 40,
    24,
    @raylib.Color::new(28, 36, 50, 255),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 342,
    (Float::from_int(pw - 40) * ratio).to_int(),
    24,
    @raylib.Color::new(92, 198, 240, 255),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 342,
    pw - 40,
    24,
    @raylib.Color::new(172, 208, 236, 220),
  )

  @raylib.draw_text(
    "Hints \{game.hints_left}  Shuffles \{game.shuffles_left}",
    px + 20,
    py + 378,
    26,
    @raylib.Color::new(214, 228, 246, 236),
  )
  @raylib.draw_text(
    "Cleared \{game.total_levels}  Time \{game.total_time.to_int()}s",
    px + 20,
    py + 410,
    24,
    @raylib.Color::new(198, 218, 238, 230),
  )

  @raylib.draw_text(
    "Keyboard",
    px + 20,
    py + 458,
    24,
    @raylib.Color::new(220, 236, 250, 240),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    px + 20,
    py + 486,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Select: Enter/Space",
    px + 20,
    py + 512,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Hint: H",
    px + 20,
    py + 538,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Shuffle: J",
    px + 20,
    py + 564,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Clear sel: C",
    px + 20,
    py + 590,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Reset: R",
    px + 20,
    py + 616,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )

  let (sx, sy, sw, sh) = select_button_rect()
  let (hx, hy, hw, hh) = hint_button_rect()
  let (fx, fy, fw, fh) = shuffle_button_rect()
  let (cx, cy, cw, ch) = clear_button_rect()
  let (rx, ry, rw, rh) = reset_button_rect()

  draw_button(
    "SELECT",
    sx,
    sy,
    sw,
    sh,
    false,
    @raylib.Color::new(80, 134, 176, 236),
  )
  draw_button(
    "HINT",
    hx,
    hy,
    hw,
    hh,
    false,
    @raylib.Color::new(162, 124, 70, 236),
  )
  draw_button(
    "SHUFFLE",
    fx,
    fy,
    fw,
    fh,
    false,
    @raylib.Color::new(112, 98, 164, 236),
  )
  draw_button(
    "CLEAR",
    cx,
    cy,
    cw,
    ch,
    false,
    @raylib.Color::new(110, 84, 132, 236),
  )
  draw_button(
    "RESET",
    rx,
    ry,
    rw,
    rh,
    false,
    @raylib.Color::new(132, 86, 82, 236),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + ph - 86,
      pw - 40,
      52,
      @raylib.Color::new(38, 52, 72, 232),
    )
    @raylib.draw_rectangle_lines(
      px + 20,
      py + ph - 86,
      pw - 40,
      52,
      @raylib.Color::new(174, 208, 234, 238),
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
fn draw_touch_overlay(
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
  let on : @raylib.Color = @raylib.Color::new(86, 134, 170, 224)
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
fn draw_title(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_text(
    "MatchLink Festival 2026",
    screen_w / 2 - @raylib.measure_text("MatchLink Festival 2026", 86) / 2,
    104,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )
  @raylib.draw_text(
    "Classic Lianliankan puzzle: match identical lantern tiles.",
    screen_w / 2 -
    @raylib.measure_text(
      "Classic Lianliankan puzzle: match identical lantern tiles.", 34,
    ) /
    2,
    246,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )
  @raylib.draw_text(
    "Links may use up to two turns. Race the timer and chain combos.",
    screen_w / 2 -
    @raylib.measure_text(
      "Links may use up to two turns. Race the timer and chain combos.", 34,
    ) /
    2,
    288,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )

  let (bx, by, bw, bh) = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Start Festival",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(84, 142, 180, 236),
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
    @raylib.Color::new(6, 10, 16, 168),
  )

  let pw : Int = 760
  let ph : Int = 390
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 26, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(166, 206, 236, 236),
  )

  @raylib.draw_text(
    "Stage Cleared",
    px + pw / 2 - @raylib.measure_text("Stage Cleared", 62) / 2,
    py + 34,
    62,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Score: \{game.score}",
    px + 96,
    py + 150,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Time left: \{game.timer.to_int()}s",
    px + 96,
    py + 196,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Hints left: \{game.hints_left}",
    px + 96,
    py + 242,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Next Stage",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(86, 142, 180, 236),
  )
}

///|
fn draw_fail_overlay(
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
    @raylib.Color::new(14, 6, 6, 170),
  )

  let pw : Int = 760
  let ph : Int = 380
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(44, 20, 20, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(246, 178, 170, 236),
  )

  @raylib.draw_text(
    "Festival Over",
    px + pw / 2 - @raylib.measure_text("Festival Over", 62) / 2,
    py + 34,
    62,
    @raylib.Color::new(255, 238, 236, 250),
  )
  @raylib.draw_text(
    "Your score: \{game.score}",
    px + 94,
    py + 152,
    38,
    @raylib.Color::new(252, 220, 214, 244),
  )
  @raylib.draw_text(
    "Press R or tap Retry",
    px + 94,
    py + 206,
    36,
    @raylib.Color::new(246, 208, 198, 238),
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
    @raylib.Color::new(156, 88, 82, 238),
  )
}

///|
fn draw_campaign_overlay(
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

  let pw : Int = 900
  let ph : Int = 520
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
    "Festival Completed",
    px + pw / 2 - @raylib.measure_text("Festival Completed", 68) / 2,
    py + 34,
    68,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Final score: \{game.score}",
    px + 112,
    py + 156,
    42,
    @raylib.Color::new(255, 220, 126, 248),
  )
  @raylib.draw_text(
    "Stages cleared: \{game.total_levels}",
    px + 112,
    py + 212,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Play time: \{game.total_time.to_int()}s",
    px + 112,
    py + 254,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )

  @raylib.draw_text(
    "Press Enter / Space or tap button to restart",
    px + 112,
    py + 334,
    30,
    @raylib.Color::new(194, 220, 240, 232),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Restart Festival",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(84, 142, 180, 236),
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
    draw_title(mouse_x, mouse_y, mouse_hold, touch_count)
    return
  }

  draw_board(game)
  draw_side_panel(game)
  draw_touch_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  draw_sparks(game)

  if game.state == state_level_clear {
    draw_level_clear_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_campaign_clear {
    draw_campaign_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_fail {
    draw_fail_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
