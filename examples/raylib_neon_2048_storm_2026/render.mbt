///|
fn bg_wave(game : Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 10, 18, 255))

  let w0 : Float = bg_wave(game, 0.68)
  let w1 : Float = bg_wave(game, 0.96)

  @raylib.draw_circle(
    220,
    150,
    220.0 + w0 * 18.0,
    @raylib.Color::new(28, 54, 92, 44),
  )
  @raylib.draw_circle(
    screen_w - 220,
    170,
    194.0 - w1 * 16.0,
    @raylib.Color::new(74, 34, 72, 34),
  )

  for i = 0; i < 15; i = i + 1 {
    let y : Int = i * 68
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      48,
      @raylib.Color::new(
        12 + i * 7 % 20,
        16 + i * 9 % 18,
        26 + i * 11 % 24,
        16 + i * 8 % 26,
      ),
    )
  }
}

///|
fn tile_body_color(v : Int) -> @raylib.Color {
  if v <= 0 {
    @raylib.Color::new(30, 40, 58, 236)
  } else if v == 2 {
    @raylib.Color::new(88, 134, 196, 244)
  } else if v == 4 {
    @raylib.Color::new(98, 156, 208, 244)
  } else if v == 8 {
    @raylib.Color::new(114, 164, 190, 244)
  } else if v == 16 {
    @raylib.Color::new(136, 166, 170, 244)
  } else if v == 32 {
    @raylib.Color::new(166, 150, 150, 246)
  } else if v == 64 {
    @raylib.Color::new(200, 146, 128, 246)
  } else if v == 128 {
    @raylib.Color::new(224, 144, 108, 248)
  } else if v == 256 {
    @raylib.Color::new(236, 138, 96, 248)
  } else if v == 512 {
    @raylib.Color::new(246, 130, 88, 248)
  } else if v == 1024 {
    @raylib.Color::new(255, 122, 82, 250)
  } else if v == 2048 {
    @raylib.Color::new(255, 210, 112, 252)
  } else {
    @raylib.Color::new(255, 238, 164, 252)
  }
}

///|
fn tile_text_color(v : Int) -> @raylib.Color {
  if v >= 2048 {
    @raylib.Color::new(56, 42, 20, 255)
  } else {
    @raylib.Color::new(240, 246, 255, 250)
  }
}

///|
fn draw_board_panel(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  let bw : Int = board_n * tile
  let bh : Int = board_n * tile

  @raylib.draw_rectangle(
    bx - 18,
    by - 18,
    bw + 36,
    bh + 36,
    @raylib.Color::new(14, 24, 40, 234),
  )
  @raylib.draw_rectangle_lines(
    bx - 18,
    by - 18,
    bw + 36,
    bh + 36,
    @raylib.Color::new(150, 194, 228, 220),
  )

  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(24, 34, 52, 236))

  if game.shake_t > 0.0 {
    @raylib.draw_rectangle_lines(
      bx - 20,
      by - 20,
      bw + 40,
      bh + 40,
      @raylib.Color::new(255, 166, 118, 228),
    )
  }
}

///|
fn draw_cell(
  game : Game,
  x : Int,
  y : Int,
  tile : Int,
  bx : Int,
  by : Int,
) -> Unit {
  let i : Int = idx(x, y)
  let px : Int = bx + x * tile
  let py : Int = by + y * tile

  let v : Int = game.board[i]

  if v == blocker_value {
    @raylib.draw_rectangle(
      px + 4,
      py + 4,
      tile - 8,
      tile - 8,
      @raylib.Color::new(72, 78, 92, 244),
    )
    @raylib.draw_rectangle(
      px + 10,
      py + 10,
      tile - 20,
      tile / 4,
      @raylib.Color::new(142, 152, 174, 114),
    )
    @raylib.draw_rectangle_lines(
      px + 4,
      py + 4,
      tile - 8,
      tile - 8,
      @raylib.Color::new(202, 214, 234, 170),
    )
    @raylib.draw_text(
      "#",
      px + tile / 2 - @raylib.measure_text("#", 44) / 2,
      py + tile / 2 - 22,
      44,
      @raylib.Color::new(232, 236, 244, 236),
    )
    return
  }

  @raylib.draw_rectangle(
    px + 4,
    py + 4,
    tile - 8,
    tile - 8,
    if v <= 0 {
      @raylib.Color::new(42, 56, 80, 228)
    } else {
      tile_body_color(v)
    },
  )

  if v <= 0 {
    @raylib.draw_rectangle(
      px + 10,
      py + 10,
      tile - 20,
      tile / 3,
      @raylib.Color::new(96, 130, 166, 74),
    )
  } else {
    @raylib.draw_rectangle(
      px + 8,
      py + 8,
      tile - 16,
      tile / 4,
      @raylib.Color::new(255, 255, 255, 46),
    )
    let s : String = v.to_string()
    let fs : Int = if v < 100 { 54 } else if v < 1000 { 46 } else { 40 }
    @raylib.draw_text(
      s,
      px + tile / 2 - @raylib.measure_text(s, fs) / 2,
      py + tile / 2 - fs / 2,
      fs,
      tile_text_color(v),
    )
  }
}

///|
fn draw_grid(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      draw_cell(game, x, y, tile, bx, by)
    }
  }

  let bw : Int = board_n * tile
  let bh : Int = board_n * tile

  for i = 0; i <= board_n; i = i + 1 {
    let px : Int = bx + i * tile
    @raylib.draw_line(
      px,
      by,
      px,
      by + bh,
      @raylib.Color::new(82, 110, 142, 110),
    )

    let py : Int = by + i * tile
    @raylib.draw_line(
      bx,
      py,
      bx + bw,
      py,
      @raylib.Color::new(82, 110, 142, 110),
    )
  }
}

///|
fn draw_cursor(game : Game, bx : Int, by : Int, tile : Int) -> Unit {
  if game.state != state_play {
    return
  }

  let px : Int = bx + game.cursor_x * tile
  let py : Int = by + game.cursor_y * tile

  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(px + 4),
      Float::from_int(py + 4),
      Float::from_int(tile - 8),
      Float::from_int(tile - 8),
    ),
    2.0,
    if game.zap_ready {
      @raylib.Color::new(255, 224, 128, 250)
    } else {
      @raylib.Color::new(238, 246, 255, 246)
    },
  )
}

///|
fn draw_sparks(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let alpha : Int = if game.sparks[i].life > 0.7 {
      236
    } else if game.sparks[i].life > 0.4 {
      196
    } else {
      132
    }

    let c : @raylib.Color = if game.sparks[i].kind == 2 {
      @raylib.Color::new(255, 180, 126, alpha)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(142, 214, 255, alpha)
    } else {
      @raylib.Color::new(190, 234, 255, alpha)
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
fn draw_touch_button(
  label : String,
  rect : (Int, Int, Int, Int),
  active : Bool,
  tint : @raylib.Color,
) -> Unit {
  let x : Int = rect.0
  let y : Int = rect.1
  let w : Int = rect.2
  let h : Int = rect.3

  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if active {
      tint
    } else {
      @raylib.Color::new(44, 62, 88, 204)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(184, 216, 242, 218),
  )

  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, 30) / 2,
    y + h / 2 - 15,
    30,
    @raylib.Color::new(246, 252, 255, 248),
  )
}

///|
fn draw_controls(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if game.state != state_play {
    return
  }

  let l_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_left().0,
    btn_left().1,
    btn_left().2,
    btn_left().3,
  )
  let r_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_right().0,
    btn_right().1,
    btn_right().2,
    btn_right().3,
  )
  let u_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_up().0,
    btn_up().1,
    btn_up().2,
    btn_up().3,
  )
  let d_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_down().0,
    btn_down().1,
    btn_down().2,
    btn_down().3,
  )
  let z_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_zap().0,
    btn_zap().1,
    btn_zap().2,
    btn_zap().3,
  )
  let u2_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_undo().0,
    btn_undo().1,
    btn_undo().2,
    btn_undo().3,
  )
  let rs_on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn_restart().0,
    btn_restart().1,
    btn_restart().2,
    btn_restart().3,
  )

  draw_touch_button(
    "L",
    btn_left(),
    l_on,
    @raylib.Color::new(86, 138, 194, 228),
  )
  draw_touch_button(
    "R",
    btn_right(),
    r_on,
    @raylib.Color::new(86, 138, 194, 228),
  )
  draw_touch_button("U", btn_up(), u_on, @raylib.Color::new(86, 138, 194, 228))
  draw_touch_button(
    "D",
    btn_down(),
    d_on,
    @raylib.Color::new(86, 138, 194, 228),
  )

  draw_touch_button(
    if game.zap_ready {
      "ZAP READY"
    } else {
      "CHARGE ZAP"
    },
    btn_zap(),
    z_on || game.zap_ready,
    @raylib.Color::new(194, 136, 86, 228),
  )
  draw_touch_button(
    "UNDO",
    btn_undo(),
    u2_on,
    @raylib.Color::new(118, 98, 164, 228),
  )
  draw_touch_button(
    "RESTART",
    btn_restart(),
    rs_on,
    @raylib.Color::new(136, 92, 100, 228),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  let px : Int = panel_x0
  let py : Int = 24
  let pw : Int = panel_w
  let ph : Int = screen_h - 48

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(14, 22, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(126, 170, 206, 220),
  )

  @raylib.draw_text(
    "Neon 2048 Storm",
    px + 20,
    py + 20,
    44,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "Grid Duel 2026",
    px + 20,
    py + 68,
    28,
    @raylib.Color::new(194, 220, 246, 238),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 112,
    36,
    @raylib.Color::new(226, 240, 255, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    px + 260,
    py + 112,
    34,
    @raylib.Color::new(206, 228, 248, 240),
  )

  @raylib.draw_text(
    "Moves \{game.moves}",
    px + 20,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 200,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @raylib.draw_text(
    "Max Tile \{game.max_tile}",
    px + 20,
    py + 194,
    32,
    if game.max_tile >= target_tile {
      @raylib.Color::new(255, 220, 120, 246)
    } else {
      @raylib.Color::new(220, 236, 252, 242)
    },
  )

  @raylib.draw_text(
    "Storm In \{game.turns_to_storm}",
    px + 20,
    py + 236,
    30,
    @raylib.Color::new(214, 232, 252, 242),
  )
  @raylib.draw_text(
    "Debris \{game.blockers_spawned}",
    px + 220,
    py + 236,
    30,
    @raylib.Color::new(214, 232, 252, 242),
  )

  @raylib.draw_text(
    "Zap Charge",
    px + 20,
    py + 286,
    28,
    @raylib.Color::new(220, 236, 252, 242),
  )

  @raylib.draw_rectangle(
    px + 20,
    py + 318,
    pw - 40,
    30,
    @raylib.Color::new(30, 42, 60, 220),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 318,
    (pw - 40) * game.zap_charge / 100,
    30,
    if game.zap_ready {
      @raylib.Color::new(250, 194, 100, 236)
    } else {
      @raylib.Color::new(96, 164, 216, 236)
    },
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 318,
    pw - 40,
    30,
    @raylib.Color::new(186, 214, 238, 230),
  )
  @raylib.draw_text(
    "\{game.zap_charge}%",
    px + pw / 2 - @raylib.measure_text("\{game.zap_charge}%", 24) / 2,
    py + 322,
    24,
    @raylib.Color::new(244, 250, 255, 248),
  )

  @raylib.draw_text(
    "Rank \{rank_name(tile_rank(game.max_tile))}",
    px + 20,
    py + 368,
    30,
    @raylib.Color::new(220, 236, 252, 242),
  )

  @raylib.draw_text(
    "Controls",
    px + 20,
    py + 418,
    28,
    @raylib.Color::new(230, 244, 255, 246),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    px + 20,
    py + 450,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Zap: Enter/Space or Right Click",
    px + 20,
    py + 476,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Undo: U/Z   Restart: R",
    px + 20,
    py + 502,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Touch: use the on-screen buttons",
    px + 20,
    py + 528,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + 564,
      pw - 40,
      56,
      @raylib.Color::new(40, 58, 82, 222),
    )
    @raylib.draw_rectangle_lines(
      px + 20,
      py + 564,
      pw - 40,
      56,
      @raylib.Color::new(176, 208, 236, 230),
    )
    @raylib.draw_text(
      game.msg,
      px + 30,
      py + 582,
      28,
      @raylib.Color::new(246, 252, 255, 248),
    )
  }
}

///|
fn draw_title(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Unit {
  @raylib.draw_text(
    "Neon 2048 Storm 2026",
    screen_w / 2 - @raylib.measure_text("Neon 2048 Storm 2026", 88) / 2,
    114,
    88,
    @raylib.Color::new(236, 246, 255, 248),
  )

  @raylib.draw_text(
    "Merge fast, survive storm debris, and charge your Zap skill.",
    screen_w / 2 -
    @raylib.measure_text(
      "Merge fast, survive storm debris, and charge your Zap skill.", 34,
    ) /
    2,
    262,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )
  @raylib.draw_text(
    "Touch controls are available for mobile web play.",
    screen_w / 2 -
    @raylib.measure_text(
      "Touch controls are available for mobile web play.", 34,
    ) /
    2,
    304,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let (x, y, w, h) = title_start_button()
  let hov : Bool = title_hover(mx, my, hold, touch_count)

  draw_touch_button(
    "Start Match",
    (x, y, w, h),
    hov,
    @raylib.Color::new(92, 150, 208, 230),
  )

  @raylib.draw_text(
    "Tip: save Zap for blockers or dead-board rescue.",
    screen_w / 2 -
    @raylib.measure_text("Tip: save Zap for blockers or dead-board rescue.", 30) /
    2,
    784,
    30,
    @raylib.Color::new(192, 214, 238, 236),
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
    @raylib.Color::new(6, 10, 16, 176),
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
    @raylib.Color::new(172, 206, 236, 236),
  )

  let title : String = if game.win {
    "Target Reached"
  } else {
    "Storm Locked Grid"
  }

  @raylib.draw_text(
    title,
    px + pw / 2 - @raylib.measure_text(title, 64) / 2,
    py + 34,
    64,
    @raylib.Color::new(244, 250, 255, 250),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 100,
    py + 132,
    46,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    "Max Tile \{game.max_tile}",
    px + 100,
    py + 184,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Grade \{final_grade(game)}",
    px + 100,
    py + 230,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Rank \{rank_name(tile_rank(game.max_tile))}",
    px + 100,
    py + 276,
    36,
    @raylib.Color::new(214, 232, 252, 244),
  )

  @raylib.draw_text(
    "Moves \{game.moves}    Debris \{game.blockers_spawned}    Time \{game.game_t.to_int()}s",
    px + 100,
    py + 328,
    32,
    @raylib.Color::new(206, 228, 248, 238),
  )

  let (x, y, w, h) = retry_button()
  let hov : Bool = result_hover(mx, my, hold, touch_count)

  draw_touch_button(
    "Play Again",
    (x, y, w, h),
    hov,
    @raylib.Color::new(96, 154, 210, 230),
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
  draw_board_panel(game, bx, by, tile)
  draw_grid(game, bx, by, tile)
  draw_cursor(game, bx, by, tile)

  draw_sparks(game)
  draw_panel(game)
  draw_controls(game, mx, my, hold, touch_count)

  if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
