///|
fn color_for_kind(kind : Int) -> @raylib.Color {
  let r : Int = 70 + kind * 37 % 168
  let g : Int = 78 + kind * 61 % 158
  let b : Int = 86 + kind * 49 % 146
  @raylib.Color::new(r, g, b, 255)
}

///|
fn tile_label(kind : Int) -> String {
  let suit : Int = kind % 4
  let rank : Int = kind % 9 + 1
  if suit == 0 {
    "B\{rank}"
  } else if suit == 1 {
    "C\{rank}"
  } else if suit == 2 {
    "D\{rank}"
  } else {
    "W\{rank}"
  }
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 14, 22, 255))

  let wave : Float = Float::from_double(
    @math.sin((game.ui_t * 0.6).to_double()),
  )

  @raylib.draw_circle(
    220,
    150,
    184.0 + wave * 14.0,
    @raylib.Color::new(28, 50, 74, 44),
  )
  @raylib.draw_circle(
    screen_w - 220,
    170,
    186.0 - wave * 12.0,
    @raylib.Color::new(64, 40, 30, 34),
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
        34 + i * 10 % 24,
        16 + i * 9 % 30,
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
      @raylib.Color::new(255, 218, 110, 236)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(126, 220, 255, 236)
    } else if game.sparks[i].kind == 2 {
      @raylib.Color::new(246, 110, 96, 228)
    } else {
      @raylib.Color::new(220, 232, 255, 226)
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
fn draw_hint(game : Game) -> Unit {
  if not(game.hint_active) {
    return
  }

  let (board_x, board_y, tile) = board_metrics(game)

  let x1 : Int = board_x + (game.hint_x1 - 1) * tile
  let y1 : Int = board_y + (game.hint_y1 - 1) * tile
  let x2 : Int = board_x + (game.hint_x2 - 1) * tile
  let y2 : Int = board_y + (game.hint_y2 - 1) * tile

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(x1 + 2),
      Float::from_int(y1 + 2),
      Float::from_int(tile - 4),
      Float::from_int(tile - 4),
    ),
    3.0,
    @raylib.Color::new(252, 234, 136, 246),
  )

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(x2 + 2),
      Float::from_int(y2 + 2),
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

  let font_size : Int = clampi(tile / 3, 16, 28)

  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      let px : Int = board_x + (x - 1) * tile
      let py : Int = board_y + (y - 1) * tile

      if not(active_at(game, x, y)) {
        @raylib.draw_rectangle(
          px,
          py,
          tile,
          tile,
          @raylib.Color::new(18, 22, 30, 255),
        )
        continue
      }

      @raylib.draw_rectangle(
        px,
        py,
        tile,
        tile,
        if (x + y) % 2 == 0 {
          @raylib.Color::new(28, 36, 48, 255)
        } else {
          @raylib.Color::new(32, 40, 54, 255)
        },
      )

      let k : Int = cell_at(game, x, y)
      if k > 0 {
        let c : @raylib.Color = color_for_kind(k)

        @raylib.draw_rectangle(px + 4, py + 4, tile - 8, tile - 8, c)
        @raylib.draw_rectangle_lines(
          px + 4,
          py + 4,
          tile - 8,
          tile - 8,
          if free_tile(game, x, y) {
            @raylib.Color::new(248, 252, 255, 242)
          } else {
            @raylib.Color::new(186, 198, 214, 220)
          },
        )

        if not(free_tile(game, x, y)) {
          @raylib.draw_rectangle(
            px + 5,
            py + 5,
            tile - 10,
            tile - 10,
            @raylib.Color::new(14, 18, 26, 66),
          )
        }

        let label : String = tile_label(k)
        @raylib.draw_text(
          label,
          px + tile / 2 - @raylib.measure_text(label, font_size) / 2,
          py + tile / 2 - font_size / 2,
          font_size,
          @raylib.Color::new(248, 252, 255, 248),
        )
      }

      @raylib.draw_rectangle_lines(
        px,
        py,
        tile,
        tile,
        @raylib.Color::new(64, 80, 100, 170),
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
      @raylib.Color::new(236, 246, 255, 248),
    )
  }

  draw_hint(game)
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
    "Mahjong Solitaire",
    px + 20,
    py + 22,
    36,
    @raylib.Color::new(238, 248, 255, 246),
  )
  @raylib.draw_text(
    "Pavilion 2026",
    px + 20,
    py + 64,
    24,
    @raylib.Color::new(188, 216, 236, 236),
  )

  @raylib.draw_text(
    "Level \{game.level_index + 1}/\{game.level_count}",
    px + 20,
    py + 108,
    30,
    @raylib.Color::new(226, 236, 250, 242),
  )
  @raylib.draw_text(
    game.level_name,
    px + 20,
    py + 144,
    28,
    @raylib.Color::new(252, 224, 142, 246),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 196,
    30,
    @raylib.Color::new(230, 240, 252, 242),
  )
  @raylib.draw_text(
    "Combo \{game.combo}",
    px + 20,
    py + 230,
    28,
    @raylib.Color::new(210, 228, 246, 236),
  )
  @raylib.draw_text(
    "Time \{game.timer.to_int()}s",
    px + 20,
    py + 264,
    28,
    @raylib.Color::new(210, 228, 246, 236),
  )
  @raylib.draw_text(
    "Remaining \{game.remaining}",
    px + 20,
    py + 298,
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
    py + 340,
    pw - 40,
    24,
    @raylib.Color::new(28, 36, 50, 255),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 340,
    (Float::from_int(pw - 40) * ratio).to_int(),
    24,
    @raylib.Color::new(92, 198, 240, 255),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 340,
    pw - 40,
    24,
    @raylib.Color::new(172, 208, 236, 220),
  )

  @raylib.draw_text(
    "Hints \{game.hints_left}",
    px + 20,
    py + 376,
    25,
    @raylib.Color::new(214, 228, 246, 236),
  )
  @raylib.draw_text(
    "Shuffles \{game.shuffles_left}",
    px + 20,
    py + 406,
    25,
    @raylib.Color::new(214, 228, 246, 236),
  )
  @raylib.draw_text(
    "Undos \{game.undos_left}",
    px + 20,
    py + 436,
    25,
    @raylib.Color::new(214, 228, 246, 236),
  )
  @raylib.draw_text(
    "Cleared \{game.total_levels}",
    px + 20,
    py + 466,
    25,
    @raylib.Color::new(214, 228, 246, 236),
  )

  @raylib.draw_text(
    "Keyboard",
    px + 20,
    py + 506,
    24,
    @raylib.Color::new(220, 236, 250, 240),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows",
    px + 20,
    py + 534,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Select: Enter/Space",
    px + 20,
    py + 560,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Hint: H  Shuffle: J",
    px + 20,
    py + 586,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Undo: U/Z  Clear: C",
    px + 20,
    py + 612,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Reset: R",
    px + 20,
    py + 638,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )

  let (sx, sy, sw, sh) = select_button_rect()
  let (hx, hy, hw, hh) = hint_button_rect()
  let (fx, fy, fw, fh) = shuffle_button_rect()
  let (ux, uy, uw, uh) = undo_button_rect()
  let (rx, ry, rw, rh) = reset_button_rect()
  let (cx, cy, cw, ch) = clear_button_rect()

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
    "UNDO",
    ux,
    uy,
    uw,
    uh,
    false,
    @raylib.Color::new(112, 92, 132, 236),
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
  draw_button(
    "CLEAR",
    cx,
    cy,
    cw,
    ch,
    false,
    @raylib.Color::new(88, 104, 128, 236),
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
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
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
    "Mahjong Solitaire Pavilion 2026",
    screen_w / 2 -
    @raylib.measure_text("Mahjong Solitaire Pavilion 2026", 78) / 2,
    106,
    78,
    @raylib.Color::new(238, 248, 255, 248),
  )
  @raylib.draw_text(
    "Pair identical free tiles and clear the board.",
    screen_w / 2 -
    @raylib.measure_text("Pair identical free tiles and clear the board.", 34) /
    2,
    244,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )
  @raylib.draw_text(
    "A tile is free when at least one horizontal side is open.",
    screen_w / 2 -
    @raylib.measure_text(
      "A tile is free when at least one horizontal side is open.", 34,
    ) /
    2,
    286,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )

  let (bx, by, bw, bh) = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Start Pavilion",
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
    px + 94,
    py + 150,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Time left: \{game.timer.to_int()}s",
    px + 94,
    py + 196,
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
    "Stage Failed",
    px + pw / 2 - @raylib.measure_text("Stage Failed", 62) / 2,
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
    "Pavilion Completed",
    px + pw / 2 - @raylib.measure_text("Pavilion Completed", 68) / 2,
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
    "Restart Pavilion",
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
  draw_touch_overlay(mouse_x, mouse_y, mouse_hold, touch_count)
  draw_sparks(game)

  if game.state == state_level_clear {
    draw_level_clear_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_campaign_clear {
    draw_campaign_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_fail {
    draw_fail_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
