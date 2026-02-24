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
fn guard_base_color(id : Int) -> @raylib.Color {
  if id == 0 {
    @raylib.Color::new(220, 154, 120, 232)
  } else if id == 1 {
    @raylib.Color::new(152, 198, 248, 232)
  } else if id == 2 {
    @raylib.Color::new(200, 162, 238, 232)
  } else {
    @raylib.Color::new(182, 220, 162, 232)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 12, 20, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(24, 34, 58, 255),
    @raylib.Color::new(9, 10, 18, 255),
  )

  let glow0 : Int = 24 + (pulse(game, 0.38) * 26.0).to_int()
  let glow1 : Int = 38 + (pulse(game, 0.58) * 32.0).to_int()

  @raylib.draw_circle(180, 118, 220.0, @raylib.Color::new(126, 146, 214, glow0))
  @raylib.draw_circle(
    screen_w - 110,
    96,
    170.0,
    @raylib.Color::new(188, 148, 206, glow1),
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
fn draw_tile_map(game : Game, ox : Int, oy : Int) -> Unit {
  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      let rx : Int = board_px(x) + ox
      let ry : Int = board_py(y) + oy
      let t : Int = tile_at(game, x, y)

      if t == tile_wall {
        let tone : Int = if (x + y) % 2 == 0 { 58 } else { 64 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(tone, 56, 70, 252),
        )

        @raylib.draw_rectangle(
          rx + 5,
          ry + 8,
          cell - 10,
          cell - 16,
          @raylib.Color::new(84, 66, 66, 228),
        )
      } else if t == tile_door {
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(74, 108, 148, 236),
        )

        @raylib.draw_rectangle(
          rx + 10,
          ry + 12,
          cell - 20,
          cell - 24,
          @raylib.Color::new(130, 186, 232, 210),
        )
      } else if t == tile_exit {
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          if game.vault_open {
            @raylib.Color::new(92, 192, 142, 236)
          } else {
            @raylib.Color::new(74, 92, 120, 232)
          },
        )

        if game.vault_open {
          @raylib.draw_circle(
            rx + cell / 2,
            ry + cell / 2,
            21.0,
            @raylib.Color::new(196, 246, 206, 88),
          )
        }
      } else {
        let f0 : Int = if (x + y) % 2 == 0 { 32 } else { 36 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(26, f0, 56, 222),
        )
      }

      @raylib.draw_rectangle_lines(
        rx,
        ry,
        cell,
        cell,
        @raylib.Color::new(34, 46, 70, 104),
      )
    }
  }
}

///|
fn draw_train_shell(ox : Int, oy : Int) -> Unit {
  for car = 0; car < 5; car = car + 1 {
    let x0 : Int = board_px(1 + car * 5) + ox
    let y0 : Int = board_py(2) + oy
    let cw : Int = cell * 4
    let ch : Int = cell * 9

    @raylib.draw_rectangle_lines(
      x0 - 4,
      y0 - 4,
      cw + 8,
      ch + 8,
      @raylib.Color::new(150, 176, 214, 198),
    )

    @raylib.draw_rectangle(
      x0 - 2,
      y0 + ch + 4,
      cw + 4,
      6,
      @raylib.Color::new(72, 86, 118, 218),
    )
  }

  for c = 0; c < 4; c = c + 1 {
    let cx : Int = board_px(5 + c * 5) + cell / 2 + ox
    let cy : Int = board_py(6) + cell / 2 + oy
    @raylib.draw_circle(cx, cy, 13.0, @raylib.Color::new(174, 210, 244, 84))
  }
}

///|
fn draw_loot(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.loots.length(); i = i + 1 {
    if not(game.loots[i].active) {
      continue
    }

    let cx : Int = board_px(game.loots[i].x) + cell / 2 + ox
    let cy : Int = board_py(game.loots[i].y) + cell / 2 + oy

    let kind : Int = game.loots[i].kind
    if kind == loot_blueprint {
      @raylib.draw_rectangle(
        cx - 15,
        cy - 19,
        30,
        38,
        @raylib.Color::new(164, 212, 255, 236),
      )
      @raylib.draw_rectangle_lines(
        cx - 15,
        cy - 19,
        30,
        38,
        @raylib.Color::new(82, 118, 162, 220),
      )
      @raylib.draw_line(
        cx - 10,
        cy - 8,
        cx + 10,
        cy - 8,
        @raylib.Color::new(88, 124, 170, 220),
      )
      @raylib.draw_line(
        cx - 10,
        cy,
        cx + 10,
        cy,
        @raylib.Color::new(88, 124, 170, 220),
      )
    } else if kind == loot_keycard {
      @raylib.draw_rectangle(
        cx - 18,
        cy - 10,
        36,
        20,
        @raylib.Color::new(196, 242, 186, 240),
      )
      @raylib.draw_rectangle_lines(
        cx - 18,
        cy - 10,
        36,
        20,
        @raylib.Color::new(96, 154, 86, 220),
      )
      @raylib.draw_circle(
        cx + 10,
        cy,
        3.0,
        @raylib.Color::new(86, 126, 76, 220),
      )
    } else {
      @raylib.draw_circle(cx, cy, 13.0, @raylib.Color::new(242, 208, 112, 244))
      @raylib.draw_circle_lines(
        cx,
        cy,
        13.0,
        @raylib.Color::new(122, 92, 38, 222),
      )
    }

    @raylib.draw_circle(cx, cy, 26.0, @raylib.Color::new(250, 232, 170, 58))
  }
}

///|
fn draw_smokes(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    let cx : Int = board_px(game.smokes[i].x) + cell / 2 + ox
    let cy : Int = board_py(game.smokes[i].y) + cell / 2 + oy

    let alpha : Int = clampi((game.smokes[i].t * 52.0).to_int(), 56, 188)

    @raylib.draw_circle(
      cx,
      cy,
      34.0 + pulse(game, 2.0 + Float::from_int(i) * 0.2) * 6.0,
      @raylib.Color::new(160, 146, 210, alpha),
    )

    @raylib.draw_circle(
      cx - 12,
      cy + 5,
      18.0,
      @raylib.Color::new(190, 180, 228, alpha / 2),
    )
  }
}

///|
fn draw_guard(g : Guard, _game : Game, ox : Int, oy : Int) -> Unit {
  if not(g.active) {
    return
  }

  let cx : Int = cell_center_x(g.body.fx) + ox
  let cy : Int = cell_center_y(g.body.fy) + oy

  let col = if g.mode == guard_stunned {
    @raylib.Color::new(164, 144, 246, 226)
  } else if g.mode == guard_hunt {
    @raylib.Color::new(244, 138, 160, 232)
  } else {
    guard_base_color(g.color_id)
  }

  @raylib.draw_circle(cx, cy - 8, 14.0, col)
  @raylib.draw_rectangle(cx - 14, cy - 8, 28, 26, col)

  @raylib.draw_circle(cx - 4, cy - 10, 2.0, @raylib.Color::new(30, 42, 62, 255))
  @raylib.draw_circle(cx + 4, cy - 10, 2.0, @raylib.Color::new(30, 42, 62, 255))

  if g.mode == guard_hunt {
    @raylib.draw_circle_lines(
      cx,
      cy - 2,
      22.0,
      @raylib.Color::new(252, 168, 188, 188),
    )
  }

  if g.mode == guard_stunned {
    @raylib.draw_circle_lines(
      cx,
      cy - 2,
      20.0,
      @raylib.Color::new(194, 176, 252, 180),
    )
  }
}

///|
fn draw_player(game : Game, ox : Int, oy : Int) -> Unit {
  let blink : Bool = game.flash_t > 0.0 &&
    (game.flash_t * 14.0).to_int() % 2 == 0
  if blink {
    return
  }

  let cx : Int = cell_center_x(game.player.fx) + ox
  let cy : Int = cell_center_y(game.player.fy) + oy

  @raylib.draw_circle(cx, cy - 8, 15.0, @raylib.Color::new(118, 214, 242, 244))
  @raylib.draw_rectangle(
    cx - 14,
    cy - 8,
    28,
    28,
    @raylib.Color::new(92, 178, 218, 238),
  )

  @raylib.draw_rectangle(
    cx - 6,
    cy + 12,
    12,
    8,
    @raylib.Color::new(70, 132, 166, 220),
  )

  @raylib.draw_circle(cx - 4, cy - 10, 2.0, @raylib.Color::new(22, 46, 66, 255))
  @raylib.draw_circle(cx + 4, cy - 10, 2.0, @raylib.Color::new(22, 46, 66, 255))
}

///|
fn draw_particles(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let col = if game.particles[i].kind == 2 {
      @raylib.Color::new(194, 170, 246, 188)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(250, 226, 152, 194)
    } else {
      @raylib.Color::new(170, 220, 252, 166)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int() + ox,
      game.particles[i].y.to_int() + oy,
      game.particles[i].size,
      col,
    )
  }
}

///|
fn draw_board(game : Game, ox : Int, oy : Int) -> Unit {
  draw_tile_map(game, ox, oy)
  draw_train_shell(ox, oy)
  draw_loot(game, ox, oy)
  draw_smokes(game, ox, oy)

  for i = 0; i < game.guards.length(); i = i + 1 {
    draw_guard(game.guards[i], game, ox, oy)
  }

  draw_player(game, ox, oy)
  draw_particles(game, ox, oy)

  @raylib.draw_rectangle_lines(
    board_x0 - 2 + ox,
    board_y0 - 2 + oy,
    board_w + 4,
    board_h + 4,
    @raylib.Color::new(130, 164, 200, 198),
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
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_right(),
    ">",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_up(),
    "^",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_down(),
    "v",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_action(),
    "A",
    @raylib.Color::new(98, 62, 118, 134),
    @raylib.Color::new(168, 94, 212, 192),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hint(),
    "Hint",
    @raylib.Color::new(44, 78, 110, 136),
    @raylib.Color::new(84, 144, 196, 198),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_restart(),
    "Retry",
    @raylib.Color::new(86, 62, 44, 136),
    @raylib.Color::new(170, 120, 78, 198),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_menu(),
    "Menu",
    @raylib.Color::new(70, 58, 90, 136),
    @raylib.Color::new(132, 102, 172, 198),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    board_y0,
    panel_w,
    board_h,
    @raylib.Color::new(12, 18, 34, 232),
  )

  @raylib.draw_rectangle_lines(
    panel_x0,
    board_y0,
    panel_w,
    board_h,
    @raylib.Color::new(96, 126, 162, 194),
  )

  @raylib.draw_text(
    "CLOCKWORK TRAIN",
    panel_x0 + 20,
    board_y0 + 20,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "HEIST 2026",
    panel_x0 + 20,
    board_y0 + 56,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Loot " + game.loot_taken.to_string() + "/" + loot_need.to_string(),
    panel_x0 + 20,
    board_y0 + 114,
    28,
    @raylib.Color::new(248, 230, 166, 238),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 20,
    board_y0 + 148,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 20,
    board_y0 + 196,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )

  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 20,
    board_y0 + 230,
    24,
    @raylib.Color::new(174, 206, 236, 224),
  )

  let timer_col = if game.time_left < 45.0 {
    @raylib.Color::new(254, 162, 176, 242)
  } else {
    @raylib.Color::new(192, 228, 252, 234)
  }

  @raylib.draw_text(
    "Time " + game.time_left.to_int().to_string() + "s",
    panel_x0 + 20,
    board_y0 + 258,
    30,
    timer_col,
  )

  @raylib.draw_text(
    if game.vault_open {
      "Cable: OPEN"
    } else {
      "Cable: LOCKED"
    },
    panel_x0 + 20,
    board_y0 + 294,
    26,
    if game.vault_open {
      @raylib.Color::new(176, 242, 194, 236)
    } else {
      @raylib.Color::new(208, 168, 182, 236)
    },
  )

  @raylib.draw_text(
    "Smoke Energy",
    panel_x0 + 20,
    board_y0 + 348,
    24,
    @raylib.Color::new(206, 192, 248, 236),
  )

  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 380,
    panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )
  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 380,
    (Float::from_int(panel_w - 40) * game.smoke_energy / 100.0).to_int(),
    22,
    if game.smoke_energy >= smoke_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )
  @raylib.draw_rectangle_lines(
    panel_x0 + 20,
    board_y0 + 380,
    panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    panel_x0 + 20,
    board_y0 + 432,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    panel_x0 + 30,
    board_y0 + 462,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Smoke Space / E",
    panel_x0 + 30,
    board_y0 + 488,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    panel_x0 + 30,
    board_y0 + 514,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    panel_x0 + 20,
    board_y0 + 562,
    20,
    @raylib.Color::new(166, 198, 226, 212),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      panel_x0 + 16,
      board_y0 + board_h - 86,
      panel_w - 32,
      64,
      @raylib.Color::new(26, 38, 62, 224),
    )
    @raylib.draw_rectangle_lines(
      panel_x0 + 16,
      board_y0 + board_h - 86,
      panel_w - 32,
      64,
      @raylib.Color::new(140, 182, 222, 178),
    )

    @raylib.draw_text(
      game.msg,
      panel_x0 + 24,
      board_y0 + board_h - 66,
      20,
      @raylib.Color::new(228, 240, 255, 236),
    )
  }
}

///|
fn draw_title_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let b = start_button_rect()
  let hot : Bool = title_hover(mx, my, hold, touch_count)

  @raylib.draw_rectangle(
    board_x0 + 72,
    board_y0 + 94,
    board_w - 144,
    board_h - 188,
    @raylib.Color::new(8, 14, 28, 224),
  )

  let t0 : String = "CLOCKWORK TRAIN HEIST"
  @raylib.draw_text(
    t0,
    board_x0 + board_w / 2 - @raylib.measure_text(t0, 56) / 2,
    board_y0 + 160,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Sneak through train cars, steal loot, deploy smoke, then escape.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Sneak through train cars, steal loot, deploy smoke, then escape.", 28,
    ) /
    2,
    board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Guards patrol routes and chase on sight in straight corridors.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Guards patrol routes and chase on sight in straight corridors.", 26,
    ) /
    2,
    board_y0 + 286,
    26,
    @raylib.Color::new(186, 214, 240, 232),
  )

  @raylib.draw_text(
    "Need 6 loot pieces to open the cable lock.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text("Need 6 loot pieces to open the cable lock.", 28) / 2,
    board_y0 + 326,
    28,
    @raylib.Color::new(244, 228, 166, 236),
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hot {
      @raylib.Color::new(102, 168, 224, 248)
    } else {
      @raylib.Color::new(66, 114, 172, 236)
    },
  )

  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 238, 252, 226),
  )

  let label : String = "START HEIST"
  @raylib.draw_text(
    label,
    b.0 + b.2 / 2 - @raylib.measure_text(label, 36) / 2,
    b.1 + 18,
    36,
    @raylib.Color::new(244, 250, 255, 248),
  )

  ignore(game)
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
    board_x0 + 108,
    board_y0 + 120,
    board_w - 216,
    board_h - 240,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "HEIST COMPLETE" } else { "HEIST FAILED" }

  @raylib.draw_text(
    title,
    board_x0 + board_w / 2 - @raylib.measure_text(title, 62) / 2,
    board_y0 + 190,
    62,
    if game.win {
      @raylib.Color::new(196, 244, 206, 248)
    } else {
      @raylib.Color::new(250, 174, 188, 248)
    },
  )

  let reason : String = if game.win {
    "The train vanishes into fog with your stolen cache."
  } else {
    game.loss_reason
  }

  @raylib.draw_text(
    reason,
    board_x0 + board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    board_y0 + 284,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Loot " +
    game.loot_taken.to_string() +
    "/" +
    loot_need.to_string() +
    "   Lives " +
    game.lives.to_string()

  @raylib.draw_text(
    score_line,
    board_x0 + board_w / 2 - @raylib.measure_text(score_line, 30) / 2,
    board_y0 + 336,
    30,
    @raylib.Color::new(232, 240, 255, 238),
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hot {
      @raylib.Color::new(126, 184, 234, 248)
    } else {
      @raylib.Color::new(80, 128, 188, 236)
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
