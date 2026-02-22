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
    @raylib.get_random_value(-4, 4)
  }
}

///|
fn pulse(game : Game, f : Float) -> Float {
  0.5 + 0.5 * sinf(game.time_s * f)
}

///|
fn core_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(244, 182, 120, 242)
  } else if kind == 1 {
    @raylib.Color::new(130, 214, 252, 242)
  } else {
    @raylib.Color::new(176, 236, 166, 242)
  }
}

///|
fn drone_color(id : Int) -> @raylib.Color {
  if id == 0 {
    @raylib.Color::new(244, 152, 166, 232)
  } else if id == 1 {
    @raylib.Color::new(164, 194, 252, 232)
  } else {
    @raylib.Color::new(232, 206, 148, 232)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 10, 18, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(18, 28, 52, 255),
    @raylib.Color::new(8, 10, 18, 255),
  )

  let g0 : Int = 24 + (pulse(game, 0.36) * 20.0).to_int()
  let g1 : Int = 34 + (pulse(game, 0.60) * 24.0).to_int()

  @raylib.draw_circle(154, 108, 220.0, @raylib.Color::new(110, 136, 206, g0))
  @raylib.draw_circle(
    screen_w - 120,
    96,
    180.0,
    @raylib.Color::new(178, 136, 208, g1),
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
fn draw_tiles(game : Game, ox : Int, oy : Int) -> Unit {
  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      let rx : Int = board_px(x) + ox
      let ry : Int = board_py(y) + oy
      let t : Int = tile_at(game, x, y)

      if t == tile_wall {
        let tone : Int = if (x + y) % 2 == 0 { 56 } else { 64 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(tone, 54, 66, 252),
        )
        @raylib.draw_rectangle(
          rx + 5,
          ry + 8,
          cell - 10,
          cell - 14,
          @raylib.Color::new(82, 66, 64, 226),
        )
      } else if t == tile_exit {
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          if game.portal_on {
            @raylib.Color::new(94, 198, 150, 236)
          } else {
            @raylib.Color::new(72, 88, 124, 232)
          },
        )

        if game.portal_on {
          @raylib.draw_circle(
            rx + cell / 2,
            ry + cell / 2,
            22.0,
            @raylib.Color::new(198, 248, 206, 84),
          )
        }
      } else {
        let tone : Int = if (x + y) % 2 == 0 { 26 } else { 32 }
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(24, tone, 52, 224),
        )
      }

      @raylib.draw_rectangle_lines(
        rx,
        ry,
        cell,
        cell,
        @raylib.Color::new(34, 46, 70, 98),
      )
    }
  }
}

///|
fn draw_portals(game : Game, ox : Int, oy : Int) -> Unit {
  let a_cx : Int = board_px(portal_ax) + cell / 2 + ox
  let a_cy : Int = board_py(portal_ay) + cell / 2 + oy
  let b_cx : Int = board_px(portal_bx) + cell / 2 + ox
  let b_cy : Int = board_py(portal_by) + cell / 2 + oy

  let p : Float = pulse(game, 2.8)

  let glow_a : Int = if game.portal_on { 120 + (p * 70.0).to_int() } else { 52 }

  let glow_b : Int = if game.portal_on {
    120 + ((Float::from_int(1) - p) * 70.0).to_int()
  } else {
    52
  }

  @raylib.draw_circle(
    a_cx,
    a_cy,
    22.0,
    @raylib.Color::new(138, 112, 252, glow_a / 2),
  )
  @raylib.draw_circle_lines(
    a_cx,
    a_cy,
    25.0,
    @raylib.Color::new(182, 154, 252, glow_a),
  )

  @raylib.draw_circle(
    b_cx,
    b_cy,
    22.0,
    @raylib.Color::new(116, 208, 244, glow_b / 2),
  )
  @raylib.draw_circle_lines(
    b_cx,
    b_cy,
    25.0,
    @raylib.Color::new(160, 232, 252, glow_b),
  )

  @raylib.draw_text(
    "A",
    a_cx - 8,
    a_cy - 12,
    24,
    @raylib.Color::new(236, 242, 255, 236),
  )
  @raylib.draw_text(
    "B",
    b_cx - 8,
    b_cy - 12,
    24,
    @raylib.Color::new(236, 242, 255, 236),
  )
}

///|
fn draw_cores(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue
    }

    let cx : Int = board_px(game.cores[i].x) + cell / 2 + ox
    let cy : Int = board_py(game.cores[i].y) + cell / 2 + oy
    let col = core_color(game.cores[i].kind)

    @raylib.draw_circle(cx, cy, 12.0, col)
    @raylib.draw_circle_lines(
      cx,
      cy,
      14.0,
      @raylib.Color::new(232, 244, 255, 182),
    )

    @raylib.draw_circle(
      cx,
      cy,
      26.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 54),
    )
  }
}

///|
fn draw_flares(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.flares.length(); i = i + 1 {
    if not(game.flares[i].active) {
      continue
    }

    let cx : Int = board_px(game.flares[i].x) + cell / 2 + ox
    let cy : Int = board_py(game.flares[i].y) + cell / 2 + oy
    let a : Int = clampi((game.flares[i].t * 46.0).to_int(), 50, 188)

    @raylib.draw_circle(cx, cy, 38.0, @raylib.Color::new(192, 174, 244, a / 2))
    @raylib.draw_circle(cx, cy, 20.0, @raylib.Color::new(242, 236, 186, a))
  }
}

///|
fn draw_drones(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.drones.length(); i = i + 1 {
    if not(game.drones[i].active) {
      continue
    }

    let cx : Int = cell_center_x(game.drones[i].body.fx) + ox
    let cy : Int = cell_center_y(game.drones[i].body.fy) + oy

    let col = if game.drones[i].mode == drone_stunned {
      @raylib.Color::new(170, 150, 246, 230)
    } else if game.drones[i].mode == drone_hunt {
      @raylib.Color::new(252, 140, 164, 236)
    } else {
      drone_color(game.drones[i].color_id)
    }

    @raylib.draw_circle(cx, cy, 14.0, col)
    @raylib.draw_rectangle(
      cx - 12,
      cy - 10,
      24,
      20,
      @raylib.Color::new(24, 34, 52, 170),
    )

    @raylib.draw_circle(
      cx - 5,
      cy - 2,
      2.0,
      @raylib.Color::new(230, 240, 255, 220),
    )
    @raylib.draw_circle(
      cx + 5,
      cy - 2,
      2.0,
      @raylib.Color::new(230, 240, 255, 220),
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

  @raylib.draw_circle(cx, cy - 8, 14.0, @raylib.Color::new(120, 214, 246, 244))
  @raylib.draw_rectangle(
    cx - 14,
    cy - 8,
    28,
    26,
    @raylib.Color::new(90, 174, 214, 236),
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
      @raylib.Color::new(250, 224, 154, 194)
    } else {
      @raylib.Color::new(170, 220, 252, 170)
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
fn light_alpha(game : Game, x : Int, y : Int) -> Int {
  let mut best : Int = manhattan(x, y, game.player.x, game.player.y)

  for i = 0; i < game.flares.length(); i = i + 1 {
    if not(game.flares[i].active) {
      continue
    }

    let d : Int = manhattan(x, y, game.flares[i].x, game.flares[i].y)
    if d < best {
      best = d
    }
  }

  if best <= 1 {
    20
  } else if best == 2 {
    54
  } else if best == 3 {
    88
  } else if best == 4 {
    128
  } else {
    172
  }
}

///|
fn draw_blackout(game : Game, ox : Int, oy : Int) -> Unit {
  for y = 1; y < grid_h - 1; y = y + 1 {
    for x = 1; x < grid_w - 1; x = x + 1 {
      let a : Int = light_alpha(game, x, y)
      @raylib.draw_rectangle(
        board_px(x) + ox,
        board_py(y) + oy,
        cell,
        cell,
        @raylib.Color::new(6, 8, 16, a),
      )
    }
  }
}

///|
fn draw_board(game : Game, ox : Int, oy : Int) -> Unit {
  draw_tiles(game, ox, oy)
  draw_portals(game, ox, oy)
  draw_cores(game, ox, oy)
  draw_flares(game, ox, oy)
  draw_drones(game, ox, oy)
  draw_player(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_blackout(game, ox, oy)

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
    "PORTAL BLACKOUT",
    panel_x0 + 20,
    board_y0 + 18,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "ESCAPE 2026",
    panel_x0 + 20,
    board_y0 + 54,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Cores " + game.cores_taken.to_string() + "/" + core_need.to_string(),
    panel_x0 + 20,
    board_y0 + 112,
    28,
    @raylib.Color::new(250, 230, 168, 238),
  )

  @raylib.draw_text(
    if game.portal_on {
      "Portal: ONLINE"
    } else {
      "Portal: OFFLINE"
    },
    panel_x0 + 20,
    board_y0 + 146,
    26,
    if game.portal_on {
      @raylib.Color::new(176, 242, 194, 236)
    } else {
      @raylib.Color::new(220, 166, 180, 236)
    },
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 20,
    board_y0 + 182,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 20,
    board_y0 + 228,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 20,
    board_y0 + 262,
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
    board_y0 + 290,
    30,
    timer_col,
  )

  @raylib.draw_text(
    "Flare Energy",
    panel_x0 + 20,
    board_y0 + 338,
    24,
    @raylib.Color::new(210, 194, 250, 236),
  )

  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 370,
    panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )

  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 370,
    (Float::from_int(panel_w - 40) * game.flare_energy / 100.0).to_int(),
    22,
    if game.flare_energy >= flare_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )

  @raylib.draw_rectangle_lines(
    panel_x0 + 20,
    board_y0 + 370,
    panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    panel_x0 + 20,
    board_y0 + 418,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    panel_x0 + 30,
    board_y0 + 448,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Action Space/E (portal or flare)",
    panel_x0 + 30,
    board_y0 + 474,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    panel_x0 + 30,
    board_y0 + 500,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    panel_x0 + 20,
    board_y0 + 542,
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
    board_x0 + 66,
    board_y0 + 92,
    board_w - 132,
    board_h - 186,
    @raylib.Color::new(8, 14, 28, 224),
  )

  let t0 : String = "PORTAL BLACKOUT ESCAPE"
  @raylib.draw_text(
    t0,
    board_x0 + board_w / 2 - @raylib.measure_text(t0, 56) / 2,
    board_y0 + 156,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Recover cores, reactivate portal pair, and escape before lights return.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Recover cores, reactivate portal pair, and escape before lights return.",
      28,
    ) /
    2,
    board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Drones hunt in clear lines. Use flare EMP to create safe windows.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Drones hunt in clear lines. Use flare EMP to create safe windows.", 26,
    ) /
    2,
    board_y0 + 286,
    26,
    @raylib.Color::new(186, 214, 240, 232),
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

  let label : String = "START RUN"
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
    board_x0 + 102,
    board_y0 + 122,
    board_w - 204,
    board_h - 244,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "ESCAPED" } else { "FAILED" }

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
    "Portal breach complete. Blackout team extracted."
  } else {
    game.loss_reason
  }

  @raylib.draw_text(
    reason,
    board_x0 + board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    board_y0 + 286,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Cores " +
    game.cores_taken.to_string() +
    "/" +
    core_need.to_string() +
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
