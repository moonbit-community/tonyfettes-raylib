///|
fn shake_dx(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-6, 6)
  }
}

///|
fn shake_dy(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn pulse(game : Game, f : Float) -> Float {
  0.5 + 0.5 * sinf(game.time_s * f)
}

///|
fn draw_background(game : Game) -> Unit {
  let a0 : Int = 24 + (pulse(game, 0.34) * 20.0).to_int()
  let a1 : Int = 36 + (pulse(game, 0.52) * 26.0).to_int()

  @raylib.clear_background(@raylib.Color::new(8, 10, 18, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(16, 26, 44, 255),
    @raylib.Color::new(7, 9, 16, 255),
  )

  @raylib.draw_circle(180, 120, 220.0, @raylib.Color::new(84, 126, 168, a0))
  @raylib.draw_circle(
    screen_w - 120,
    96,
    180.0,
    @raylib.Color::new(164, 132, 188, a1),
  )

  @raylib.draw_rectangle(
    board_x0 - 8,
    board_y0 - 8,
    board_w + 16,
    board_h + 16,
    @raylib.Color::new(10, 14, 24, 220),
  )
}

///|
fn draw_grid_base(game : Game, ox : Int, oy : Int) -> Unit {
  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      let rx : Int = board_px(x) + ox
      let ry : Int = board_py(y) + oy
      let t : Int = tile_at(game, x, y)

      if t == tile_wall {
        let shade : Int = if (x + y) % 2 == 0 { 62 } else { 72 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(shade, 56, 64, 255),
        )
        @raylib.draw_rectangle(
          rx + 6,
          ry + 8,
          cell - 12,
          cell - 14,
          @raylib.Color::new(98, 74, 66, 220),
        )
        @raylib.draw_rectangle_lines(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(34, 28, 36, 180),
        )
      } else {
        let floor_tint : Int = if (x + y) % 2 == 0 { 34 } else { 38 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(26, floor_tint, 50, 220),
        )
        @raylib.draw_rectangle_lines(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(30, 46, 66, 100),
        )
      }
    }
  }
}

///|
fn draw_seals(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < seal_need; i = i + 1 {
    let p = seal_pos(i)
    let cx : Int = board_px(p.0) + cell / 2 + ox
    let cy : Int = board_py(p.1) + cell / 2 + oy
    let on : Bool = shelf_index_at(game, p.0, p.1) >= 0

    let glow : Int = if on {
      210
    } else {
      100 + (pulse(game, 2.0 + Float::from_int(i)) * 66.0).to_int()
    }

    @raylib.draw_circle(
      cx,
      cy,
      21.0,
      if on {
        @raylib.Color::new(126, 236, 176, 126)
      } else {
        @raylib.Color::new(126, 192, 236, 62)
      },
    )

    @raylib.draw_circle_lines(
      cx,
      cy,
      24.0,
      @raylib.Color::new(188, 232, 248, glow),
    )

    @raylib.draw_circle_lines(
      cx,
      cy,
      14.0,
      @raylib.Color::new(196, 232, 255, glow),
    )
  }
}

///|
fn draw_pages(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < max_pages; i = i + 1 {
    if game.page_taken[i] {
      continue
    }

    let x : Int = game.page_x[i]
    let y : Int = game.page_y[i]
    let rx : Int = board_px(x) + 14 + ox
    let ry : Int = board_py(y) + 12 + oy

    let glow : Int = 156 +
      (pulse(game, 1.6 + Float::from_int(i) * 0.4) * 70.0).to_int()

    @raylib.draw_rectangle(
      rx,
      ry,
      30,
      36,
      @raylib.Color::new(246, 230, 188, 240),
    )
    @raylib.draw_rectangle_lines(
      rx,
      ry,
      30,
      36,
      @raylib.Color::new(120, 90, 52, 220),
    )

    @raylib.draw_line(
      rx + 9,
      ry + 8,
      rx + 24,
      ry + 8,
      @raylib.Color::new(132, 102, 68, 200),
    )
    @raylib.draw_line(
      rx + 9,
      ry + 15,
      rx + 24,
      ry + 15,
      @raylib.Color::new(132, 102, 68, 200),
    )

    @raylib.draw_circle(
      rx + 15,
      ry + 18,
      24.0,
      @raylib.Color::new(246, 226, 174, glow / 5),
    )
  }
}

///|
fn draw_shelves(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.shelf_n; i = i + 1 {
    let x : Int = game.shelf_x[i]
    let y : Int = game.shelf_y[i]
    let rx : Int = board_px(x) + 6 + ox
    let ry : Int = board_py(y) + 8 + oy

    let on_seal : Bool = seal_index_at(x, y) >= 0

    @raylib.draw_rectangle(
      rx,
      ry,
      cell - 12,
      cell - 16,
      if on_seal {
        @raylib.Color::new(168, 122, 76, 242)
      } else {
        @raylib.Color::new(140, 104, 72, 236)
      },
    )

    @raylib.draw_rectangle(
      rx + 4,
      ry + 5,
      cell - 20,
      9,
      @raylib.Color::new(98, 72, 50, 210),
    )
    @raylib.draw_rectangle(
      rx + 4,
      ry + 20,
      cell - 20,
      9,
      @raylib.Color::new(98, 72, 50, 210),
    )

    @raylib.draw_rectangle_lines(
      rx,
      ry,
      cell - 12,
      cell - 16,
      @raylib.Color::new(66, 48, 32, 220),
    )
  }
}

///|
fn draw_gate(game : Game, ox : Int, oy : Int) -> Unit {
  let rx : Int = board_px(exit_x) + 4 + ox
  let ry : Int = board_py(exit_y) + 4 + oy

  let gate_col = if game.gate_open {
    @raylib.Color::new(118, 210, 146, 232)
  } else {
    @raylib.Color::new(78, 84, 124, 236)
  }

  @raylib.draw_rectangle(rx, ry, cell - 8, cell - 8, gate_col)
  @raylib.draw_rectangle_lines(
    rx,
    ry,
    cell - 8,
    cell - 8,
    @raylib.Color::new(210, 228, 246, 180),
  )

  if game.gate_open {
    @raylib.draw_circle(
      rx + (cell - 8) / 2,
      ry + (cell - 8) / 2,
      18.0,
      @raylib.Color::new(224, 250, 210, 80),
    )
  } else {
    @raylib.draw_line(
      rx + 12,
      ry + 12,
      rx + cell - 20,
      ry + cell - 20,
      @raylib.Color::new(38, 30, 62, 220),
    )
    @raylib.draw_line(
      rx + cell - 20,
      ry + 12,
      rx + 12,
      ry + cell - 20,
      @raylib.Color::new(38, 30, 62, 220),
    )
  }
}

///|
fn draw_player(game : Game, ox : Int, oy : Int) -> Unit {
  let cx : Int = cell_center_x(game.player.fx) + ox
  let cy : Int = cell_center_y(game.player.fy) + oy

  let blink : Bool = game.flash_t > 0.0 &&
    (game.flash_t * 14.0).to_int() % 2 == 0
  if blink {
    return
  }

  @raylib.draw_circle(cx, cy, 18.0, @raylib.Color::new(110, 200, 248, 244))
  @raylib.draw_circle(cx, cy - 3, 11.0, @raylib.Color::new(224, 244, 255, 236))

  @raylib.draw_circle(cx - 4, cy - 4, 2.0, @raylib.Color::new(28, 52, 72, 255))
  @raylib.draw_circle(cx + 4, cy - 4, 2.0, @raylib.Color::new(28, 52, 72, 255))

  @raylib.draw_rectangle(
    cx - 12,
    cy + 12,
    24,
    8,
    @raylib.Color::new(82, 148, 190, 230),
  )
}

///|
fn draw_ghost(g : Ghost, game : Game, ox : Int, oy : Int, i : Int) -> Unit {
  if not(g.active) {
    return
  }

  let cx : Int = cell_center_x(g.body.fx) + ox
  let cy : Int = cell_center_y(g.body.fy) + oy

  let bob : Int = (pulse(game, 4.6 + Float::from_int(i)) * 5.0).to_int()

  let body_col = if g.mode == ghost_stunned {
    @raylib.Color::new(146, 132, 248, 214)
  } else if g.mode == ghost_hunt {
    @raylib.Color::new(250, 152, 164, 230)
  } else {
    @raylib.Color::new(226, 232, 248, 222)
  }

  @raylib.draw_circle(cx, cy - 8 + bob, 16.0, body_col)
  @raylib.draw_rectangle(cx - 16, cy - 8 + bob, 32, 24, body_col)

  @raylib.draw_circle(
    cx - 5,
    cy - 12 + bob,
    3.0,
    @raylib.Color::new(34, 44, 66, 255),
  )
  @raylib.draw_circle(
    cx + 5,
    cy - 12 + bob,
    3.0,
    @raylib.Color::new(34, 44, 66, 255),
  )

  if g.mode == ghost_stunned {
    @raylib.draw_circle_lines(
      cx,
      cy - 3 + bob,
      24.0,
      @raylib.Color::new(186, 168, 252, 180),
    )
  }
}

///|
fn draw_particles(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let c = if game.particles[i].kind == 2 {
      @raylib.Color::new(206, 154, 248, 196)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(255, 224, 146, 192)
    } else {
      @raylib.Color::new(156, 212, 255, 170)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int() + ox,
      game.particles[i].y.to_int() + oy,
      game.particles[i].size,
      c,
    )
  }
}

///|
fn draw_board(game : Game, ox : Int, oy : Int) -> Unit {
  draw_grid_base(game, ox, oy)
  draw_seals(game, ox, oy)
  draw_pages(game, ox, oy)
  draw_shelves(game, ox, oy)
  draw_gate(game, ox, oy)

  for i = 0; i < game.ghosts.length(); i = i + 1 {
    draw_ghost(game.ghosts[i], game, ox, oy, i)
  }

  draw_player(game, ox, oy)
  draw_particles(game, ox, oy)

  @raylib.draw_rectangle_lines(
    board_x0 - 2 + ox,
    board_y0 - 2 + oy,
    board_w + 4,
    board_h + 4,
    @raylib.Color::new(124, 160, 196, 200),
  )
}

///|
fn draw_touch_button(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rect : (Int, Int, Int, Int),
  label : String,
  c_idle : @raylib.Color,
  c_on : @raylib.Color,
) -> Unit {
  let on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )

  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if on {
      c_on
    } else {
      c_idle
    },
  )

  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(216, 232, 248, 186),
  )

  let fs : Int = if rect.3 >= 100 { 32 } else { 22 }
  let tw : Int = @raylib.measure_text(label, fs)
  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - tw / 2,
    rect.1 + rect.3 / 2 - fs / 2,
    fs,
    @raylib.Color::new(238, 246, 255, 236),
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

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_left(),
    "<",
    @raylib.Color::new(44, 64, 94, 118),
    @raylib.Color::new(72, 108, 160, 180),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_right(),
    ">",
    @raylib.Color::new(44, 64, 94, 118),
    @raylib.Color::new(72, 108, 160, 180),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_up(),
    "^",
    @raylib.Color::new(44, 64, 94, 118),
    @raylib.Color::new(72, 108, 160, 180),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_down(),
    "v",
    @raylib.Color::new(44, 64, 94, 118),
    @raylib.Color::new(72, 108, 160, 180),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_action(),
    "A",
    @raylib.Color::new(96, 56, 116, 132),
    @raylib.Color::new(164, 86, 206, 190),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hint(),
    "Hint",
    @raylib.Color::new(46, 78, 108, 132),
    @raylib.Color::new(82, 136, 186, 190),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_restart(),
    "Retry",
    @raylib.Color::new(82, 64, 44, 132),
    @raylib.Color::new(162, 116, 72, 198),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_menu(),
    "Menu",
    @raylib.Color::new(70, 58, 90, 132),
    @raylib.Color::new(128, 104, 170, 198),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    board_y0,
    panel_w,
    board_h,
    @raylib.Color::new(13, 20, 34, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x0,
    board_y0,
    panel_w,
    board_h,
    @raylib.Color::new(96, 122, 156, 190),
  )

  @raylib.draw_text(
    "HAUNTED LIBRARY",
    panel_x0 + 20,
    board_y0 + 20,
    36,
    @raylib.Color::new(228, 238, 252, 244),
  )
  @raylib.draw_text(
    "PUZZLE 2026",
    panel_x0 + 20,
    board_y0 + 58,
    26,
    @raylib.Color::new(164, 194, 224, 236),
  )

  @raylib.draw_text(
    "Pages " + game.pages.to_string() + "/5",
    panel_x0 + 22,
    board_y0 + 120,
    28,
    @raylib.Color::new(250, 232, 186, 236),
  )
  @raylib.draw_text(
    "Seals " + game.seals_on.to_string() + "/3",
    panel_x0 + 22,
    board_y0 + 156,
    28,
    @raylib.Color::new(176, 236, 206, 236),
  )
  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 22,
    board_y0 + 192,
    28,
    @raylib.Color::new(255, 186, 202, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 22,
    board_y0 + 240,
    30,
    @raylib.Color::new(220, 238, 255, 236),
  )
  @raylib.draw_text(
    "Steps " + game.steps.to_string(),
    panel_x0 + 22,
    board_y0 + 276,
    24,
    @raylib.Color::new(178, 206, 234, 222),
  )
  @raylib.draw_text(
    "Time " + game.time_s.to_int().to_string() + "s",
    panel_x0 + 22,
    board_y0 + 306,
    24,
    @raylib.Color::new(178, 206, 234, 222),
  )

  @raylib.draw_text(
    "Lantern Energy",
    panel_x0 + 22,
    board_y0 + 356,
    24,
    @raylib.Color::new(212, 204, 250, 236),
  )

  @raylib.draw_rectangle(
    panel_x0 + 24,
    board_y0 + 392,
    panel_w - 48,
    22,
    @raylib.Color::new(40, 50, 70, 220),
  )

  @raylib.draw_rectangle(
    panel_x0 + 24,
    board_y0 + 392,
    (Float::from_int(panel_w - 48) * game.stun_energy / 100.0).to_int(),
    22,
    if game.stun_energy >= 30.0 {
      @raylib.Color::new(166, 128, 240, 236)
    } else {
      @raylib.Color::new(128, 94, 132, 218)
    },
  )

  @raylib.draw_rectangle_lines(
    panel_x0 + 24,
    board_y0 + 392,
    panel_w - 48,
    22,
    @raylib.Color::new(212, 220, 246, 176),
  )

  let gate_txt : String = if game.gate_open {
    "Gate: OPEN"
  } else {
    "Gate: LOCKED"
  }

  @raylib.draw_text(
    gate_txt,
    panel_x0 + 22,
    board_y0 + 430,
    26,
    if game.gate_open {
      @raylib.Color::new(176, 242, 184, 240)
    } else {
      @raylib.Color::new(216, 166, 176, 234)
    },
  )

  @raylib.draw_text(
    "Desktop:",
    panel_x0 + 22,
    board_y0 + 490,
    24,
    @raylib.Color::new(206, 228, 250, 228),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    panel_x0 + 30,
    board_y0 + 520,
    21,
    @raylib.Color::new(166, 204, 236, 216),
  )
  @raylib.draw_text(
    "Pulse Space / E",
    panel_x0 + 30,
    board_y0 + 546,
    21,
    @raylib.Color::new(166, 204, 236, 216),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    panel_x0 + 30,
    board_y0 + 572,
    21,
    @raylib.Color::new(166, 204, 236, 216),
  )

  @raylib.draw_text(
    "Mobile: Left D-pad, Right A/H/Retry/Menu",
    panel_x0 + 22,
    board_y0 + 620,
    20,
    @raylib.Color::new(168, 200, 232, 212),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      panel_x0 + 20,
      board_y0 + board_h - 84,
      panel_w - 40,
      62,
      @raylib.Color::new(28, 40, 66, 220),
    )
    @raylib.draw_rectangle_lines(
      panel_x0 + 20,
      board_y0 + board_h - 84,
      panel_w - 40,
      62,
      @raylib.Color::new(142, 186, 226, 180),
    )

    @raylib.draw_text(
      game.msg,
      panel_x0 + 30,
      board_y0 + board_h - 64,
      20,
      @raylib.Color::new(228, 240, 255, 236),
    )
  }
}

///|
fn draw_title_overlay(
  _game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let b = start_button_rect()
  let hot : Bool = title_hover(mx, my, hold, touch_count)

  @raylib.draw_rectangle(
    board_x0 + 56,
    board_y0 + 74,
    board_w - 112,
    board_h - 148,
    @raylib.Color::new(8, 14, 26, 222),
  )

  let t0 : String = "HAUNTED LIBRARY PUZZLE"
  @raylib.draw_text(
    t0,
    board_x0 + board_w / 2 - @raylib.measure_text(t0, 58) / 2,
    board_y0 + 154,
    58,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Recover 5 lost pages, push shelves onto 3 runes, then escape.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Recover 5 lost pages, push shelves onto 3 runes, then escape.", 28,
    ) /
    2,
    board_y0 + 252,
    28,
    @raylib.Color::new(184, 214, 240, 232),
  )

  @raylib.draw_text(
    "Ghosts hunt in straight sightlines. Use pulse wisely.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Ghosts hunt in straight sightlines. Use pulse wisely.", 26,
    ) /
    2,
    board_y0 + 292,
    26,
    @raylib.Color::new(184, 214, 240, 232),
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hot {
      @raylib.Color::new(102, 168, 224, 248)
    } else {
      @raylib.Color::new(64, 112, 168, 236)
    },
  )

  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 238, 252, 226),
  )

  let label : String = "START RUN"
  @raylib.draw_text(
    label,
    b.0 + b.2 / 2 - @raylib.measure_text(label, 36) / 2,
    b.1 + 18,
    36,
    @raylib.Color::new(244, 250, 255, 248),
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
  let b = retry_button_rect()
  let hot : Bool = retry_hover(mx, my, hold, touch_count)

  @raylib.draw_rectangle(
    board_x0 + 92,
    board_y0 + 120,
    board_w - 184,
    board_h - 240,
    @raylib.Color::new(8, 14, 26, 228),
  )

  let title : String = if game.win { "ARCHIVE SAVED" } else { "RUN FAILED" }

  @raylib.draw_text(
    title,
    board_x0 + board_w / 2 - @raylib.measure_text(title, 62) / 2,
    board_y0 + 196,
    62,
    if game.win {
      @raylib.Color::new(198, 244, 200, 248)
    } else {
      @raylib.Color::new(250, 172, 188, 248)
    },
  )

  let reason : String = if game.win {
    "Specters fade as dawn enters the grand hall."
  } else {
    game.loss_reason
  }

  @raylib.draw_text(
    reason,
    board_x0 + board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    board_y0 + 288,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Pages " +
    game.pages.to_string() +
    "/5   Seals " +
    game.seals_on.to_string() +
    "/3"

  @raylib.draw_text(
    score_line,
    board_x0 + board_w / 2 - @raylib.measure_text(score_line, 30) / 2,
    board_y0 + 338,
    30,
    @raylib.Color::new(234, 240, 255, 238),
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hot {
      @raylib.Color::new(126, 182, 232, 248)
    } else {
      @raylib.Color::new(78, 126, 184, 236)
    },
  )

  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(228, 238, 252, 222),
  )

  let label : String = "RUN AGAIN"
  @raylib.draw_text(
    label,
    b.0 + b.2 / 2 - @raylib.measure_text(label, 34) / 2,
    b.1 + 20,
    34,
    @raylib.Color::new(246, 252, 255, 248),
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
  draw_background(game)

  let ox : Int = shake_dx(game)
  let oy : Int = shake_dy(game)

  draw_board(game, ox, oy)
  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
