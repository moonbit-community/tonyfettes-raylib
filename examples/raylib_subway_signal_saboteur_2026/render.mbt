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
fn train_target_color(id : Int) -> @raylib.Color {
  if id == 0 {
    @raylib.Color::new(250, 154, 144, 246)
  } else if id == 1 {
    @raylib.Color::new(144, 214, 254, 246)
  } else {
    @raylib.Color::new(182, 236, 166, 246)
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

  let g0 : Int = 24 + (pulse(game, 0.40) * 20.0).to_int()
  let g1 : Int = 32 + (pulse(game, 0.68) * 26.0).to_int()

  @raylib.draw_circle(160, 108, 220.0, @raylib.Color::new(102, 132, 198, g0))
  @raylib.draw_circle(
    screen_w - 120,
    94,
    180.0,
    @raylib.Color::new(174, 134, 200, g1),
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
          @raylib.Color::new(tone, 56, 66, 252),
        )
        @raylib.draw_rectangle(
          rx + 5,
          ry + 8,
          cell - 10,
          cell - 14,
          @raylib.Color::new(84, 66, 64, 226),
        )
      } else if t == tile_track {
        @raylib.draw_rectangle(
          rx,
          ry,
          cell,
          cell,
          @raylib.Color::new(34, 48, 74, 232),
        )

        @raylib.draw_rectangle(
          rx,
          ry + cell / 2 - 7,
          cell,
          14,
          @raylib.Color::new(118, 136, 168, 220),
        )

        @raylib.draw_line(
          rx + 6,
          ry + cell / 2 - 10,
          rx + 6,
          ry + cell / 2 + 10,
          @raylib.Color::new(208, 220, 236, 132),
        )
        @raylib.draw_line(
          rx + cell - 6,
          ry + cell / 2 - 10,
          rx + cell - 6,
          ry + cell / 2 + 10,
          @raylib.Color::new(208, 220, 236, 132),
        )
      } else {
        let tone : Int = if (x + y) % 2 == 0 { 28 } else { 34 }
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
        @raylib.Color::new(34, 46, 70, 100),
      )
    }
  }
}

///|
fn draw_junctions(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < junction_n; i = i + 1 {
    let jx : Int = junction_x(i)

    for lane = 0; lane < train_lane_n; lane = lane + 1 {
      let cy : Int = board_py(lane_to_y(lane)) + cell / 2 + oy
      let cx : Int = board_px(jx) + cell / 2 + ox

      @raylib.draw_circle(cx, cy, 12.0, @raylib.Color::new(138, 188, 238, 70))

      let dir : Int = game.switch_state[i]
      let arrow_y : Int = cy - dir * 10

      @raylib.draw_line(
        cx - 14,
        cy,
        cx + 14,
        arrow_y,
        @raylib.Color::new(188, 224, 252, 220),
      )

      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx + 14), Float::from_int(arrow_y)),
        @raylib.Vector2::new(
          Float::from_int(cx + 8),
          Float::from_int(arrow_y - 4),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx + 8),
          Float::from_int(arrow_y + 4),
        ),
        @raylib.Color::new(220, 236, 252, 226),
      )
    }

    let top_px : Int = board_px(jx) + 8 + ox
    let top_py : Int = board_py(signal_panel_top_y()) + 8 + oy
    let bot_px : Int = board_px(jx) + 8 + ox
    let bot_py : Int = board_py(signal_panel_bottom_y()) + 8 + oy

    @raylib.draw_rectangle(
      top_px,
      top_py,
      cell - 16,
      cell - 16,
      @raylib.Color::new(82, 126, 176, 230),
    )
    @raylib.draw_rectangle(
      bot_px,
      bot_py,
      cell - 16,
      cell - 16,
      @raylib.Color::new(82, 126, 176, 230),
    )

    @raylib.draw_rectangle_lines(
      top_px,
      top_py,
      cell - 16,
      cell - 16,
      @raylib.Color::new(212, 230, 250, 196),
    )
    @raylib.draw_rectangle_lines(
      bot_px,
      bot_py,
      cell - 16,
      cell - 16,
      @raylib.Color::new(212, 230, 250, 196),
    )
  }
}

///|
fn draw_trains(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.trains.length(); i = i + 1 {
    if not(game.trains[i].active) {
      continue
    }

    let cx : Int = cell_center_x(game.trains[i].x) + ox
    let cy : Int = board_py(lane_to_y(game.trains[i].lane)) + cell / 2 + oy
    let col = train_target_color(game.trains[i].color_id)

    @raylib.draw_rectangle(
      cx - 18,
      cy - 13,
      36,
      26,
      @raylib.Color::new(46, 62, 90, 240),
    )
    @raylib.draw_rectangle_lines(
      cx - 18,
      cy - 13,
      36,
      26,
      @raylib.Color::new(212, 228, 248, 178),
    )

    @raylib.draw_rectangle(cx - 10, cy - 9, 20, 18, col)
    @raylib.draw_rectangle(
      cx - 6,
      cy - 5,
      12,
      10,
      @raylib.Color::new(20, 30, 44, 184),
    )

    @raylib.draw_circle(cx + 22, cy, 8.0, col)
  }
}

///|
fn draw_inspectors(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.inspectors.length(); i = i + 1 {
    if not(game.inspectors[i].active) {
      continue
    }

    let cx : Int = cell_center_x(game.inspectors[i].body.fx) + ox
    let cy : Int = cell_center_y(game.inspectors[i].body.fy) + oy

    let col = if game.inspectors[i].mode == inspector_stunned {
      @raylib.Color::new(164, 144, 248, 228)
    } else if game.inspectors[i].mode == inspector_hunt {
      @raylib.Color::new(250, 144, 164, 232)
    } else {
      @raylib.Color::new(238, 202, 154, 232)
    }

    @raylib.draw_circle(cx, cy - 8, 13.0, col)
    @raylib.draw_rectangle(cx - 13, cy - 8, 26, 24, col)

    @raylib.draw_circle(
      cx - 4,
      cy - 10,
      2.0,
      @raylib.Color::new(30, 42, 62, 255),
    )
    @raylib.draw_circle(
      cx + 4,
      cy - 10,
      2.0,
      @raylib.Color::new(30, 42, 62, 255),
    )

    if game.inspectors[i].mode == inspector_hunt {
      @raylib.draw_circle_lines(
        cx,
        cy - 2,
        20.0,
        @raylib.Color::new(252, 170, 190, 188),
      )
    }
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
    27,
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
      @raylib.Color::new(194, 170, 246, 186)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(248, 224, 152, 192)
    } else {
      @raylib.Color::new(170, 220, 252, 168)
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
  draw_tiles(game, ox, oy)
  draw_junctions(game, ox, oy)
  draw_trains(game, ox, oy)
  draw_inspectors(game, ox, oy)
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
    "SUBWAY SIGNAL",
    panel_x0 + 20,
    board_y0 + 18,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "SABOTEUR 2026",
    panel_x0 + 20,
    board_y0 + 54,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Routed " + game.routed_ok.to_string() + "/" + goal_routed.to_string(),
    panel_x0 + 20,
    board_y0 + 112,
    28,
    @raylib.Color::new(250, 230, 168, 238),
  )

  @raylib.draw_text(
    "Wrong " +
    game.routed_bad.to_string() +
    "   Crash " +
    game.collisions.to_string(),
    panel_x0 + 20,
    board_y0 + 146,
    24,
    @raylib.Color::new(248, 176, 192, 230),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 20,
    board_y0 + 178,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 20,
    board_y0 + 224,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 20,
    board_y0 + 258,
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
    board_y0 + 286,
    30,
    timer_col,
  )

  @raylib.draw_text(
    "Signals",
    panel_x0 + 20,
    board_y0 + 332,
    24,
    @raylib.Color::new(206, 228, 248, 236),
  )

  for i = 0; i < junction_n; i = i + 1 {
    let mode_txt : String = if game.switch_state[i] < 0 {
      "UP"
    } else if game.switch_state[i] > 0 {
      "DOWN"
    } else {
      "STRAIGHT"
    }

    @raylib.draw_text(
      "J" + (i + 1).to_string() + " : " + mode_txt,
      panel_x0 + 28,
      board_y0 + 364 + i * 28,
      22,
      @raylib.Color::new(182, 212, 240, 228),
    )
  }

  @raylib.draw_text(
    "EMP Energy",
    panel_x0 + 20,
    board_y0 + 492,
    24,
    @raylib.Color::new(210, 194, 250, 236),
  )

  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 524,
    panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )

  @raylib.draw_rectangle(
    panel_x0 + 20,
    board_y0 + 524,
    (Float::from_int(panel_w - 40) * game.emp_energy / 100.0).to_int(),
    22,
    if game.emp_energy >= emp_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )

  @raylib.draw_rectangle_lines(
    panel_x0 + 20,
    board_y0 + 524,
    panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    panel_x0 + 20,
    board_y0 + 568,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    panel_x0 + 30,
    board_y0 + 598,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Action Space/E (toggle or EMP)",
    panel_x0 + 30,
    board_y0 + 624,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    panel_x0 + 30,
    board_y0 + 650,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    panel_x0 + 20,
    board_y0 + 692,
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

  let t0 : String = "SUBWAY SIGNAL SABOTEUR"
  @raylib.draw_text(
    t0,
    board_x0 + board_w / 2 - @raylib.measure_text(t0, 56) / 2,
    board_y0 + 156,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Operate junction signals to route trains to correct colored exits.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text(
      "Operate junction signals to route trains to correct colored exits.", 28,
    ) /
    2,
    board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Avoid inspectors. Use EMP when trapped.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text("Avoid inspectors. Use EMP when trapped.", 28) / 2,
    board_y0 + 286,
    28,
    @raylib.Color::new(186, 214, 240, 232),
  )

  @raylib.draw_text(
    "Need 20 successful routes before time runs out.",
    board_x0 +
    board_w / 2 -
    @raylib.measure_text("Need 20 successful routes before time runs out.", 28) /
    2,
    board_y0 + 324,
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

  let label : String = "START SHIFT"
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
    board_x0 + 100,
    board_y0 + 122,
    board_w - 200,
    board_h - 244,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "SHIFT COMPLETE" } else { "SHIFT FAILED" }

  @raylib.draw_text(
    title,
    board_x0 + board_w / 2 - @raylib.measure_text(title, 62) / 2,
    board_y0 + 188,
    62,
    if game.win {
      @raylib.Color::new(196, 244, 206, 248)
    } else {
      @raylib.Color::new(250, 174, 188, 248)
    },
  )

  let reason : String = if game.win {
    "Control room cracked. All trains diverted as planned."
  } else {
    game.loss_reason
  }

  @raylib.draw_text(
    reason,
    board_x0 + board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    board_y0 + 282,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Routed " +
    game.routed_ok.to_string() +
    "   Wrong " +
    game.routed_bad.to_string()

  @raylib.draw_text(
    score_line,
    board_x0 + board_w / 2 - @raylib.measure_text(score_line, 30) / 2,
    board_y0 + 334,
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
