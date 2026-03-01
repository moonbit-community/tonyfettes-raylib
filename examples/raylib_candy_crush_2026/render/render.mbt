///|
fn draw_button(
  label : String,
  caption : String,
  rect : (Int, Int, Int, Int),
  hover : Bool,
  enabled : Bool,
) -> Unit {
  let bg = if not(enabled) {
    @raylib.Color::new(52, 62, 84, 188)
  } else if hover {
    @raylib.Color::new(92, 160, 242, 226)
  } else {
    @raylib.Color::new(64, 116, 198, 210)
  }

  @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, bg)
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if hover {
      @raylib.Color::new(230, 245, 255, 236)
    } else {
      @raylib.Color::new(164, 198, 236, 220)
    },
  )

  let ts = 28
  let tw = @raylib.measure_text(label, ts)
  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - tw / 2,
    rect.1 + 15,
    ts,
    if enabled {
      @raylib.Color::new(240, 248, 255, 246)
    } else {
      @raylib.Color::new(180, 194, 212, 222)
    },
  )

  let cs = 20
  let cw = @raylib.measure_text(caption, cs)
  @raylib.draw_text(
    caption,
    rect.0 + rect.2 / 2 - cw / 2,
    rect.1 + rect.3 - 28,
    cs,
    @raylib.Color::new(208, 228, 248, 220),
  )
}

///|
fn draw_background() -> Unit {
  @raylib.clear_background(@raylib.Color::new(14, 20, 34, 255))

  for i in 0..<18 {
    let y = i * (@types.screen_h / 18)
    let tone = 28 + i * 4
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      @types.screen_h / 18 + 2,
      @raylib.Color::new(tone, 28 + i * 3, 58 + i * 4, 255),
    )
  }

  @raylib.draw_circle(180, 120, 160.0, @raylib.Color::new(70, 120, 210, 86))
  @raylib.draw_circle(
    @types.screen_w - 220,
    160,
    210.0,
    @raylib.Color::new(120, 86, 220, 72),
  )
  @raylib.draw_circle(
    420,
    @types.screen_h - 130,
    190.0,
    @raylib.Color::new(70, 180, 180, 66),
  )
}

///|
fn draw_board_frame() -> Unit {
  let bx = @types.board_x()
  let by = @types.board_y()
  let bw = @types.board_pixel_w()
  let bh = @types.board_pixel_h()

  @raylib.draw_rectangle(
    bx - @types.board_pad,
    by - @types.board_pad,
    bw + @types.board_pad * 2,
    bh + @types.board_pad * 2,
    @raylib.Color::new(12, 26, 44, 220),
  )
  @raylib.draw_rectangle_lines(
    bx - @types.board_pad,
    by - @types.board_pad,
    bw + @types.board_pad * 2,
    bh + @types.board_pad * 2,
    @raylib.Color::new(148, 188, 235, 220),
  )

  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(8, 16, 30, 232))
}

///|
fn draw_special_overlay(cx : Int, cy : Int, sp : Int) -> Unit {
  if sp == @types.special_none {
    return
  }

  if sp == @types.special_row {
    @raylib.draw_rectangle(
      cx - 24,
      cy - 6,
      48,
      12,
      @raylib.Color::new(248, 248, 255, 228),
    )
  } else if sp == @types.special_col {
    @raylib.draw_rectangle(
      cx - 6,
      cy - 24,
      12,
      48,
      @raylib.Color::new(248, 248, 255, 228),
    )
  } else {
    @raylib.draw_circle_lines(
      cx,
      cy,
      25.0,
      @raylib.Color::new(250, 245, 255, 236),
    )
    @raylib.draw_circle(cx, cy, 8.0, @raylib.Color::new(255, 255, 255, 240))
  }
}

///|
fn draw_board_cells(game : @types.Game) -> Unit {
  let bx = @types.board_x()
  let by = @types.board_y()

  for y in 0..<@types.board_rows {
    for x in 0..<@types.board_cols {
      let left = bx + x * @types.cell_px
      let top = by + y * @types.cell_px
      let cell_bg = if (x + y) % 2 == 0 {
        @raylib.Color::new(18, 30, 56, 220)
      } else {
        @raylib.Color::new(22, 36, 62, 224)
      }

      @raylib.draw_rectangle(left, top, @types.cell_px, @types.cell_px, cell_bg)
      @raylib.draw_rectangle_lines(
        left,
        top,
        @types.cell_px,
        @types.cell_px,
        @raylib.Color::new(62, 96, 148, 160),
      )

      let i = @types.idx(x, y)
      let kind = game.kinds[i]
      if kind < 0 {
        continue
      }

      let cx = left + @types.cell_px / 2
      let cy = top + @types.cell_px / 2
      let base = @types.candy_color(kind)
      @raylib.draw_circle(cx, cy, 29.0, base)
      @raylib.draw_circle(cx - 9, cy - 12, 10.0, @types.tint(base, 38))
      @raylib.draw_circle_lines(cx, cy, 30.0, @types.tint(base, -50))

      draw_special_overlay(cx, cy, game.specials[i])

      if game.jelly[i] > 0 {
        @raylib.draw_rectangle(
          left + 4,
          top + 4,
          @types.cell_px - 8,
          @types.cell_px - 8,
          @raylib.Color::new(168, 222, 255, 92),
        )
        @raylib.draw_rectangle_lines(
          left + 4,
          top + 4,
          @types.cell_px - 8,
          @types.cell_px - 8,
          @raylib.Color::new(210, 242, 255, 186),
        )
      }

      if game.flash[i] > 0.0 {
        let alpha = (@types.clampf(game.flash[i], 0.0, 1.0) * 170.0).to_int()
        @raylib.draw_rectangle(
          left + 2,
          top + 2,
          @types.cell_px - 4,
          @types.cell_px - 4,
          @raylib.Color::new(255, 255, 255, alpha),
        )
      }
    }
  }
}

///|
fn draw_selection(game : @types.Game) -> Unit {
  let bx = @types.board_x()
  let by = @types.board_y()

  let cursor_left = bx + game.cursor_x * @types.cell_px
  let cursor_top = by + game.cursor_y * @types.cell_px
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(cursor_left + 3),
      Float::from_int(cursor_top + 3),
      Float::from_int(@types.cell_px - 6),
      Float::from_int(@types.cell_px - 6),
    ),
    2.0,
    @raylib.Color::new(192, 220, 255, 214),
  )

  if game.selected {
    let left = bx + game.sel_x * @types.cell_px
    let top = by + game.sel_y * @types.cell_px
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(left + 2),
        Float::from_int(top + 2),
        Float::from_int(@types.cell_px - 4),
        Float::from_int(@types.cell_px - 4),
      ),
      4.0,
      @raylib.Color::new(255, 242, 166, 236),
    )
  }

  if game.hint_active {
    let pulse : Float = 0.52 + 0.48 * @math.sinf(game.hint_t * 8.0)
    let alpha = @types.clampi((pulse * 240.0).to_int(), 84, 240)

    let x0 = bx + game.hint_x0 * @types.cell_px
    let y0 = by + game.hint_y0 * @types.cell_px
    let x1 = bx + game.hint_x1 * @types.cell_px
    let y1 = by + game.hint_y1 * @types.cell_px

    let c = @raylib.Color::new(255, 244, 170, alpha)
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x0 + 5),
        Float::from_int(y0 + 5),
        Float::from_int(@types.cell_px - 10),
        Float::from_int(@types.cell_px - 10),
      ),
      3.0,
      c,
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x1 + 5),
        Float::from_int(y1 + 5),
        Float::from_int(@types.cell_px - 10),
        Float::from_int(@types.cell_px - 10),
      ),
      3.0,
      c,
    )

    @raylib.draw_line_ex(
      @raylib.Vector2::new(
        Float::from_int(x0 + @types.cell_px / 2),
        Float::from_int(y0 + @types.cell_px / 2),
      ),
      @raylib.Vector2::new(
        Float::from_int(x1 + @types.cell_px / 2),
        Float::from_int(y1 + @types.cell_px / 2),
      ),
      4.0,
      c,
    )
  }

  if game.swap_flash_t > 0.0 {
    let t = @types.clampf(game.swap_flash_t / 0.42, 0.0, 1.0)
    let alpha = (t * 210.0).to_int()

    let left0 = bx + game.swap_x0 * @types.cell_px
    let top0 = by + game.swap_y0 * @types.cell_px
    let left1 = bx + game.swap_x1 * @types.cell_px
    let top1 = by + game.swap_y1 * @types.cell_px

    let c = @raylib.Color::new(255, 255, 255, alpha)
    @raylib.draw_rectangle(
      left0 + 10,
      top0 + 10,
      @types.cell_px - 20,
      @types.cell_px - 20,
      c,
    )
    @raylib.draw_rectangle(
      left1 + 10,
      top1 + 10,
      @types.cell_px - 20,
      @types.cell_px - 20,
      c,
    )
  }
}

///|
fn draw_side_panel(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.panel_x(),
    @types.panel_y(),
    @types.ui_panel_w,
    @types.screen_h,
    @raylib.Color::new(10, 18, 34, 224),
  )
  @raylib.draw_line(
    @types.panel_x(),
    0,
    @types.panel_x(),
    @types.screen_h,
    @raylib.Color::new(118, 160, 214, 206),
  )

  @raylib.draw_text(
    "CANDY CRUSH 2026",
    @types.panel_x() + 34,
    36,
    36,
    @raylib.Color::new(238, 244, 255, 244),
  )
  @raylib.draw_text(
    "Match 3+ to clear jelly",
    @types.panel_x() + 34,
    82,
    24,
    @raylib.Color::new(186, 214, 242, 228),
  )

  @raylib.draw_text(
    "LEVEL  " + game.level.to_string(),
    @types.panel_x() + 34,
    140,
    30,
    @raylib.Color::new(240, 245, 255, 240),
  )
  @raylib.draw_text(
    "SCORE  " + game.score.to_string(),
    @types.panel_x() + 34,
    182,
    30,
    @raylib.Color::new(255, 232, 172, 242),
  )
  @raylib.draw_text(
    "BEST   " + game.best_score.to_string(),
    @types.panel_x() + 34,
    224,
    28,
    @raylib.Color::new(196, 220, 255, 234),
  )

  @raylib.draw_text(
    "MOVES  " + game.moves_left.to_string(),
    @types.panel_x() + 34,
    560,
    32,
    if game.moves_left <= 5 {
      @raylib.Color::new(255, 176, 166, 246)
    } else {
      @raylib.Color::new(236, 248, 255, 244)
    },
  )
  @raylib.draw_text(
    "JELLY  " + game.jelly_left.to_string(),
    @types.panel_x() + 34,
    604,
    32,
    if game.jelly_left <= 6 {
      @raylib.Color::new(166, 244, 194, 246)
    } else {
      @raylib.Color::new(236, 248, 255, 244)
    },
  )
  @raylib.draw_text(
    "MAX CHAIN  x" + game.chain_best.to_string(),
    @types.panel_x() + 34,
    648,
    28,
    @raylib.Color::new(210, 228, 246, 230),
  )

  let hint_rect = @types.hint_button_rect()
  let shuffle_rect = @types.shuffle_button_rect()
  let restart_rect = @types.restart_button_rect()

  draw_button(
    "Hint",
    "H or tap",
    hint_rect,
    @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      hint_rect.0,
      hint_rect.1,
      hint_rect.2,
      hint_rect.3,
    ),
    game.state == Play,
  )

  draw_button(
    "Shuffle",
    "J or tap (-1 move)",
    shuffle_rect,
    @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      shuffle_rect.0,
      shuffle_rect.1,
      shuffle_rect.2,
      shuffle_rect.3,
    ),
    game.state == Play,
  )

  draw_button(
    "Restart",
    "R or tap",
    restart_rect,
    @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      restart_rect.0,
      restart_rect.1,
      restart_rect.2,
      restart_rect.3,
    ),
    true,
  )

  @raylib.draw_text(
    "Keyboard: Arrows/WASD + Enter",
    @types.panel_x() + 34,
    @types.screen_h - 78,
    20,
    @raylib.Color::new(176, 206, 236, 226),
  )
  @raylib.draw_text(
    "Touch: tap candies to swap",
    @types.panel_x() + 34,
    @types.screen_h - 52,
    20,
    @raylib.Color::new(176, 206, 236, 226),
  )
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_t <= 0.0 {
    return
  }

  let alpha = (@types.clampf(game.message_t / @types.message_ttl_max, 0.0, 1.0) *
  220.0).to_int()
  @raylib.draw_rectangle(
    @types.board_x(),
    @types.board_y() - 52,
    @types.board_pixel_w(),
    40,
    @raylib.Color::new(14, 24, 46, alpha),
  )
  @raylib.draw_rectangle_lines(
    @types.board_x(),
    @types.board_y() - 52,
    @types.board_pixel_w(),
    40,
    @raylib.Color::new(150, 190, 234, alpha),
  )

  @raylib.draw_text(
    game.message,
    @types.board_x() + 16,
    @types.board_y() - 44,
    24,
    @raylib.Color::new(240, 246, 255, alpha),
  )
}

///|
fn draw_title_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(8, 14, 24, 154),
  )

  @raylib.draw_text(
    "CANDY CRUSH 2026",
    @types.screen_w / 2 - 270,
    146,
    72,
    @raylib.Color::new(242, 248, 255, 248),
  )
  @raylib.draw_text(
    "Build chains, trigger specials, clear every jelly tile.",
    @types.screen_w / 2 - 338,
    240,
    32,
    @raylib.Color::new(198, 220, 246, 236),
  )

  @raylib.draw_text(
    "Desktop: Arrow/WASD + Enter, H hint, J shuffle, R restart",
    @types.screen_w / 2 - 360,
    304,
    26,
    @raylib.Color::new(188, 214, 240, 230),
  )
  @raylib.draw_text(
    "Mobile: tap one candy then an adjacent candy to swap",
    @types.screen_w / 2 - 350,
    340,
    26,
    @raylib.Color::new(188, 214, 240, 230),
  )

  let start = @types.start_button_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_press,
    game.touch_count,
    start.0,
    start.1,
    start.2,
    start.3,
  )
  draw_button("Start", "Enter / Space / Tap", start, hover, true)
}

///|
fn draw_result_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(12, 16, 28, 172),
  )

  let title = match game.state {
    LevelClear => "LEVEL CLEARED"
    _ => "OUT OF MOVES"
  }
  @raylib.draw_text(
    title,
    @types.screen_w / 2 - 250,
    164,
    66,
    match game.state {
      LevelClear => @raylib.Color::new(170, 255, 210, 244)
      _ => @raylib.Color::new(255, 182, 182, 244)
    },
  )

  @raylib.draw_text(
    "Score " +
    game.score.to_string() +
    "    Best " +
    game.best_score.to_string(),
    @types.screen_w / 2 - 220,
    262,
    34,
    @raylib.Color::new(236, 246, 255, 242),
  )
  @raylib.draw_text(
    "Max chain x" + game.chain_best.to_string(),
    @types.screen_w / 2 - 130,
    308,
    30,
    @raylib.Color::new(210, 230, 250, 236),
  )

  let action = @types.result_button_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_press,
    game.touch_count,
    action.0,
    action.1,
    action.2,
    action.3,
  )

  match game.state {
    LevelClear =>
      draw_button("Next Level", "Enter / Space / Tap", action, hover, true)
    _ => draw_button("Play Again", "Enter / Space / Tap", action, hover, true)
  }

  @raylib.draw_text(
    "Press T to return to title",
    @types.screen_w / 2 - 148,
    action.1 + 112,
    24,
    @raylib.Color::new(182, 206, 232, 228),
  )
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_background()
  draw_board_frame()
  draw_board_cells(game)
  draw_selection(game)
  draw_side_panel(game)
  draw_message(game)
  match game.state {
    Title => draw_title_overlay(game)
    LevelClear | GameOver => draw_result_overlay(game)
    Play => ()
  }
  if game.state == Play && game.touch_mode {
    @raylib.draw_text(
      "Touch ready: tap two adjacent candies",
      @types.board_x(),
      @types.board_y() + @types.board_pixel_h() + 14,
      22,
      @raylib.Color::new(206, 228, 248, 226),
    )
  }
}
