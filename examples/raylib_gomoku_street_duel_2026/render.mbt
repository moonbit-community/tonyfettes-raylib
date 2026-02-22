///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 14, 22, 255))

  let wave : Float = Float::from_double(
    @math.sin((game.ui_t * 0.62).to_double()),
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
fn draw_board_grid(board_x : Int, board_y : Int, tile : Int) -> Unit {
  let size : Int = board_n * tile

  @raylib.draw_rectangle(
    board_x - tile / 2,
    board_y - tile / 2,
    size + tile,
    size + tile,
    @raylib.Color::new(92, 70, 46, 248),
  )
  @raylib.draw_rectangle_lines(
    board_x - tile / 2,
    board_y - tile / 2,
    size + tile,
    size + tile,
    @raylib.Color::new(214, 188, 146, 226),
  )

  for i = 0; i < board_n; i = i + 1 {
    let px : Int = board_x + i * tile
    let py : Int = board_y + i * tile

    @raylib.draw_line(
      board_x,
      py,
      board_x + (board_n - 1) * tile,
      py,
      @raylib.Color::new(62, 44, 28, 240),
    )

    @raylib.draw_line(
      px,
      board_y,
      px,
      board_y + (board_n - 1) * tile,
      @raylib.Color::new(62, 44, 28, 240),
    )
  }

  let stars : Array[(Int, Int)] = [
    (3, 3),
    (3, 7),
    (3, 11),
    (7, 3),
    (7, 7),
    (7, 11),
    (11, 3),
    (11, 7),
    (11, 11),
  ]

  for i = 0; i < stars.length(); i = i + 1 {
    let (sx, sy) = stars[i]
    @raylib.draw_circle(
      board_x + sx * tile,
      board_y + sy * tile,
      4.5,
      @raylib.Color::new(40, 28, 18, 250),
    )
  }
}

///|
fn draw_stone(
  x : Int,
  y : Int,
  p : Int,
  board_x : Int,
  board_y : Int,
  tile : Int,
) -> Unit {
  let cx : Int = board_x + x * tile
  let cy : Int = board_y + y * tile
  let r : Float = Float::from_int(tile) * 0.42

  if p == player_human {
    @raylib.draw_circle(cx, cy, r, @raylib.Color::new(28, 34, 46, 255))
    @raylib.draw_circle(
      cx - 4,
      cy - 4,
      r * 0.42,
      @raylib.Color::new(126, 146, 176, 196),
    )
    @raylib.draw_circle_lines(cx, cy, r, @raylib.Color::new(210, 220, 236, 220))
  } else {
    @raylib.draw_circle(cx, cy, r, @raylib.Color::new(224, 228, 238, 255))
    @raylib.draw_circle(
      cx - 4,
      cy - 4,
      r * 0.42,
      @raylib.Color::new(252, 252, 255, 206),
    )
    @raylib.draw_circle_lines(cx, cy, r, @raylib.Color::new(68, 76, 88, 190))
  }
}

///|
fn draw_hint(game : Game, board_x : Int, board_y : Int, tile : Int) -> Unit {
  if not(game.hint_active) {
    return
  }

  let hx : Int = board_x + game.hint_x * tile
  let hy : Int = board_y + game.hint_y * tile
  let r : Float = Float::from_int(tile) * 0.48

  @raylib.draw_circle_lines(hx, hy, r, @raylib.Color::new(255, 230, 132, 250))
  @raylib.draw_circle_lines(
    hx,
    hy,
    r - 4.0,
    @raylib.Color::new(255, 238, 172, 246),
  )
}

///|
fn draw_last_markers(
  game : Game,
  board_x : Int,
  board_y : Int,
  tile : Int,
) -> Unit {
  if game.last_hx >= 0 && game.last_hy >= 0 {
    let x : Int = board_x + game.last_hx * tile
    let y : Int = board_y + game.last_hy * tile
    @raylib.draw_circle_lines(
      x,
      y,
      Float::from_int(tile) * 0.24,
      @raylib.Color::new(255, 220, 132, 245),
    )
  }

  if game.last_ax >= 0 && game.last_ay >= 0 {
    let x : Int = board_x + game.last_ax * tile
    let y : Int = board_y + game.last_ay * tile
    @raylib.draw_circle_lines(
      x,
      y,
      Float::from_int(tile) * 0.24,
      @raylib.Color::new(132, 208, 255, 245),
    )
  }
}

///|
fn draw_board(game : Game) -> Unit {
  let (board_x, board_y, tile) = board_metrics(game)

  draw_board_grid(board_x, board_y, tile)

  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      let p : Int = cell_at(game, x, y)
      if p != player_empty {
        draw_stone(x, y, p, board_x, board_y, tile)
      }
    }
  }

  draw_hint(game, board_x, board_y, tile)
  draw_last_markers(game, board_x, board_y, tile)

  if game.state == state_play {
    let cx : Int = board_x + game.cursor_x * tile
    let cy : Int = board_y + game.cursor_y * tile
    @raylib.draw_circle_lines(
      cx,
      cy,
      Float::from_int(tile) * 0.52,
      @raylib.Color::new(248, 250, 255, 248),
    )
  }
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
    "Gomoku Street Duel",
    px + 20,
    py + 22,
    36,
    @raylib.Color::new(238, 248, 255, 246),
  )
  @raylib.draw_text(
    "Five-in-a-row 2026",
    px + 20,
    py + 64,
    24,
    @raylib.Color::new(188, 216, 236, 236),
  )

  @raylib.draw_text(
    if game.turn == player_human {
      "Turn: You"
    } else {
      "Turn: AI"
    },
    px + 20,
    py + 110,
    30,
    @raylib.Color::new(226, 236, 250, 242),
  )

  @raylib.draw_text(
    "Moves \{game.move_count}",
    px + 20,
    py + 152,
    28,
    @raylib.Color::new(214, 230, 246, 236),
  )
  @raylib.draw_text(
    "Time \{game.game_time.to_int()}s",
    px + 20,
    py + 186,
    28,
    @raylib.Color::new(214, 230, 246, 236),
  )

  @raylib.draw_text(
    "Wins \{game.human_wins}",
    px + 20,
    py + 236,
    28,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "AI Wins \{game.ai_wins}",
    px + 20,
    py + 270,
    28,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Draws \{game.draws}",
    px + 20,
    py + 304,
    28,
    @raylib.Color::new(220, 236, 250, 242),
  )

  @raylib.draw_text(
    "Hints \{game.hints_left}",
    px + 20,
    py + 354,
    26,
    @raylib.Color::new(214, 228, 246, 236),
  )

  @raylib.draw_text(
    "Keyboard",
    px + 20,
    py + 408,
    24,
    @raylib.Color::new(220, 236, 250, 240),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows",
    px + 20,
    py + 436,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Place: Enter/Space",
    px + 20,
    py + 462,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Hint: H  Undo: U/Z",
    px + 20,
    py + 488,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )
  @raylib.draw_text(
    "Clear: C  Reset: R",
    px + 20,
    py + 514,
    22,
    @raylib.Color::new(186, 210, 232, 232),
  )

  let (px0, py0, pw0, ph0) = place_button_rect()
  let (hx, hy, hw, hh) = hint_button_rect()
  let (ux, uy, uw, uh) = undo_button_rect()
  let (cx, cy, cw, ch) = clear_button_rect()
  let (rx, ry, rw, rh) = reset_button_rect()

  draw_button(
    "PLACE",
    px0,
    py0,
    pw0,
    ph0,
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
    "UNDO",
    ux,
    uy,
    uw,
    uh,
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
    @raylib.Color::new(112, 90, 132, 236),
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
fn draw_sparks(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let alpha : Int = if game.sparks[i].life > 0.72 {
      244
    } else if game.sparks[i].life > 0.44 {
      206
    } else if game.sparks[i].life > 0.22 {
      170
    } else {
      126
    }

    let core : @raylib.Color = if game.sparks[i].kind == 1 {
      @raylib.Color::new(255, 214, 108, alpha)
    } else if game.sparks[i].kind == 0 {
      @raylib.Color::new(130, 208, 255, alpha)
    } else {
      @raylib.Color::new(210, 196, 255, alpha)
    }

    let edge : @raylib.Color = if game.sparks[i].kind == 1 {
      @raylib.Color::new(255, 242, 196, alpha - 44)
    } else if game.sparks[i].kind == 0 {
      @raylib.Color::new(206, 236, 255, alpha - 44)
    } else {
      @raylib.Color::new(230, 220, 255, alpha - 44)
    }

    let r : Float = 1.2 +
      game.sparks[i].size * (0.46 + game.sparks[i].life * 0.84)
    let x : Int = game.sparks[i].x.to_int()
    let y : Int = game.sparks[i].y.to_int()

    @raylib.draw_circle(x, y, r, core)
    @raylib.draw_circle_lines(x, y, r + 1.0, edge)
  }
}

///|
fn draw_title(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_text(
    "Gomoku Street Duel 2026",
    screen_w / 2 - @raylib.measure_text("Gomoku Street Duel 2026", 84) / 2,
    108,
    84,
    @raylib.Color::new(238, 248, 255, 248),
  )
  @raylib.draw_text(
    "Place five stones in a line before the AI does.",
    screen_w / 2 -
    @raylib.measure_text("Place five stones in a line before the AI does.", 34) /
    2,
    248,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )
  @raylib.draw_text(
    "Heuristic AI, touch controls, hints, and undo.",
    screen_w / 2 -
    @raylib.measure_text("Heuristic AI, touch controls, hints, and undo.", 34) /
    2,
    290,
    34,
    @raylib.Color::new(192, 220, 240, 238),
  )

  let (bx, by, bw, bh) = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Start Duel",
    bx,
    by,
    bw,
    bh,
    hover,
    @raylib.Color::new(84, 142, 180, 236),
  )
}

///|
fn draw_result_overlay(
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

  let pw : Int = 760
  let ph : Int = 390
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 26, 36, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(166, 206, 236, 236),
  )

  let title : String = if game.winner == player_human {
    "You Win"
  } else if game.winner == player_ai {
    "AI Wins"
  } else {
    "Draw"
  }

  @raylib.draw_text(
    title,
    px + pw / 2 - @raylib.measure_text(title, 64) / 2,
    py + 36,
    64,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Moves: \{game.move_count}",
    px + 94,
    py + 160,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Time: \{game.game_time.to_int()}s",
    px + 94,
    py + 206,
    36,
    @raylib.Color::new(220, 236, 250, 242),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )
  draw_button(
    "Next Round",
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
    draw_title(mouse_x, mouse_y, mouse_hold, touch_count)
    return
  }

  draw_board(game)
  draw_side_panel(game)
  draw_touch_overlay(mouse_x, mouse_y, mouse_hold, touch_count)
  draw_sparks(game)

  if game.state == state_result {
    draw_result_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
