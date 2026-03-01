///|
fn shake_dx(game : @types.Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-6, 6)
  }
}

///|
fn shake_dy(game : @types.Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-4, 4)
  }
}

///|
fn pulse(game : @types.Game, f : Float) -> Float {
  0.5 + 0.5 * @types.sinf(game.time_s * f)
}

///|
fn train_target_color(id : @types.TrainColor) -> @raylib.Color {
  match id {
    @types.Red => @raylib.Color::new(250, 154, 144, 246)
    @types.Blue => @raylib.Color::new(144, 214, 254, 246)
    @types.Green => @raylib.Color::new(182, 236, 166, 246)
  }
}

///|
fn draw_background(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 10, 18, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(18, 28, 52, 255),
    @raylib.Color::new(8, 10, 18, 255),
  )

  let g0 : Int = 24 + (pulse(game, 0.40) * 20.0).to_int()
  let g1 : Int = 32 + (pulse(game, 0.68) * 26.0).to_int()

  @raylib.draw_circle(160, 108, 220.0, @raylib.Color::new(102, 132, 198, g0))
  @raylib.draw_circle(
    @types.screen_w - 120,
    94,
    180.0,
    @raylib.Color::new(174, 134, 200, g1),
  )

  @raylib.draw_rectangle(
    @types.board_x0 - 8,
    @types.board_y0 - 8,
    @types.board_w + 16,
    @types.board_h + 16,
    @raylib.Color::new(10, 14, 24, 220),
  )
}

///|
fn draw_tiles(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      let rx : Int = @types.board_px(x) + ox
      let ry : Int = @types.board_py(y) + oy

      match @types.tile_at(game, x, y) {
        @types.Wall => {
          let tone : Int = if (x + y) % 2 == 0 { 56 } else { 64 }
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(tone, 56, 66, 252),
          )
          @raylib.draw_rectangle(
            rx + 5,
            ry + 8,
            @types.cell - 10,
            @types.cell - 14,
            @raylib.Color::new(84, 66, 64, 226),
          )
        }
        @types.Track => {
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(34, 48, 74, 232),
          )

          @raylib.draw_rectangle(
            rx,
            ry + @types.cell / 2 - 7,
            @types.cell,
            14,
            @raylib.Color::new(118, 136, 168, 220),
          )

          @raylib.draw_line(
            rx + 6,
            ry + @types.cell / 2 - 10,
            rx + 6,
            ry + @types.cell / 2 + 10,
            @raylib.Color::new(208, 220, 236, 132),
          )
          @raylib.draw_line(
            rx + @types.cell - 6,
            ry + @types.cell / 2 - 10,
            rx + @types.cell - 6,
            ry + @types.cell / 2 + 10,
            @raylib.Color::new(208, 220, 236, 132),
          )
        }
        _ => {
          let tone : Int = if (x + y) % 2 == 0 { 28 } else { 34 }
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(24, tone, 52, 224),
          )
        }
      }

      @raylib.draw_rectangle_lines(
        rx,
        ry,
        @types.cell,
        @types.cell,
        @raylib.Color::new(34, 46, 70, 100),
      )
    }
  }
}

///|
fn draw_junctions(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for i in 0..<@types.junction_n {
    let jx : Int = @types.junction_x(i)

    for lane in 0..<@types.train_lane_n {
      let cy : Int = @types.board_py(@types.lane_to_y(lane)) +
        @types.cell / 2 +
        oy
      let cx : Int = @types.board_px(jx) + @types.cell / 2 + ox

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

    let top_px : Int = @types.board_px(jx) + 8 + ox
    let top_py : Int = @types.board_py(@types.signal_panel_top_y()) + 8 + oy
    let bot_px : Int = @types.board_px(jx) + 8 + ox
    let bot_py : Int = @types.board_py(@types.signal_panel_bottom_y()) + 8 + oy

    @raylib.draw_rectangle(
      top_px,
      top_py,
      @types.cell - 16,
      @types.cell - 16,
      @raylib.Color::new(82, 126, 176, 230),
    )
    @raylib.draw_rectangle(
      bot_px,
      bot_py,
      @types.cell - 16,
      @types.cell - 16,
      @raylib.Color::new(82, 126, 176, 230),
    )

    @raylib.draw_rectangle_lines(
      top_px,
      top_py,
      @types.cell - 16,
      @types.cell - 16,
      @raylib.Color::new(212, 230, 250, 196),
    )
    @raylib.draw_rectangle_lines(
      bot_px,
      bot_py,
      @types.cell - 16,
      @types.cell - 16,
      @raylib.Color::new(212, 230, 250, 196),
    )
  }
}

///|
fn draw_trains(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for train in game.trains {
    if not(train.active) {
      continue
    }

    let cx : Int = @types.cell_center_x(train.x) + ox
    let cy : Int = @types.board_py(@types.lane_to_y(train.lane)) +
      @types.cell / 2 +
      oy
    let col = train_target_color(train.color_id)

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
fn draw_inspectors(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for inspector in game.inspectors {
    if not(inspector.active) {
      continue
    }

    let cx : Int = @types.cell_center_x(inspector.body.fx) + ox
    let cy : Int = @types.cell_center_y(inspector.body.fy) + oy

    let col = match inspector.mode {
      @types.Stunned => @raylib.Color::new(164, 144, 248, 228)
      @types.Hunt => @raylib.Color::new(250, 144, 164, 232)
      @types.Patrol => @raylib.Color::new(238, 202, 154, 232)
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

    if inspector.mode == @types.Hunt {
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
fn draw_player(game : @types.Game, ox : Int, oy : Int) -> Unit {
  let blink : Bool = game.flash_t > 0.0 &&
    (game.flash_t * 14.0).to_int() % 2 == 0
  if blink {
    return
  }

  let cx : Int = @types.cell_center_x(game.player.fx) + ox
  let cy : Int = @types.cell_center_y(game.player.fy) + oy

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
fn draw_particles(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    let col = match particle.kind {
      @types.Smoke => @raylib.Color::new(194, 170, 246, 186)
      @types.Gold => @raylib.Color::new(248, 224, 152, 192)
      @types.Spark => @raylib.Color::new(170, 220, 252, 168)
    }

    @raylib.draw_circle(
      particle.x.to_int() + ox,
      particle.y.to_int() + oy,
      particle.size,
      col,
    )
  }
}

///|
fn draw_board(game : @types.Game, ox : Int, oy : Int) -> Unit {
  draw_tiles(game, ox, oy)
  draw_junctions(game, ox, oy)
  draw_trains(game, ox, oy)
  draw_inspectors(game, ox, oy)
  draw_player(game, ox, oy)
  draw_particles(game, ox, oy)

  @raylib.draw_rectangle_lines(
    @types.board_x0 - 2 + ox,
    @types.board_y0 - 2 + oy,
    @types.board_w + 4,
    @types.board_h + 4,
    @raylib.Color::new(130, 164, 200, 198),
  )
}

///|
fn draw_touch_button(
  game : @types.Game,
  rect : (Int, Int, Int, Int),
  label : String,
  c_idle : @raylib.Color,
  c_on : @raylib.Color,
) -> Unit {
  let on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
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
fn draw_touch_controls(game : @types.Game) -> Unit {
  if game.state != @types.Play {
    return
  }

  draw_touch_button(
    game,
    @types.btn_left(),
    "<",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    game,
    @types.btn_right(),
    ">",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    game,
    @types.btn_up(),
    "^",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )
  draw_touch_button(
    game,
    @types.btn_down(),
    "v",
    @raylib.Color::new(42, 64, 96, 116),
    @raylib.Color::new(74, 114, 168, 186),
  )

  draw_touch_button(
    game,
    @types.btn_action(),
    "A",
    @raylib.Color::new(98, 62, 118, 134),
    @raylib.Color::new(168, 94, 212, 192),
  )

  draw_touch_button(
    game,
    @types.btn_hint(),
    "Hint",
    @raylib.Color::new(44, 78, 110, 136),
    @raylib.Color::new(84, 144, 196, 198),
  )

  draw_touch_button(
    game,
    @types.btn_restart(),
    "Retry",
    @raylib.Color::new(86, 62, 44, 136),
    @raylib.Color::new(170, 120, 78, 198),
  )

  draw_touch_button(
    game,
    @types.btn_menu(),
    "Menu",
    @raylib.Color::new(70, 58, 90, 136),
    @raylib.Color::new(132, 102, 172, 198),
  )
}

///|
fn draw_panel(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.panel_x0,
    @types.board_y0,
    @types.panel_w,
    @types.board_h,
    @raylib.Color::new(12, 18, 34, 232),
  )

  @raylib.draw_rectangle_lines(
    @types.panel_x0,
    @types.board_y0,
    @types.panel_w,
    @types.board_h,
    @raylib.Color::new(96, 126, 162, 194),
  )

  @raylib.draw_text(
    "SUBWAY SIGNAL",
    @types.panel_x0 + 20,
    @types.board_y0 + 18,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "SABOTEUR 2026",
    @types.panel_x0 + 20,
    @types.board_y0 + 54,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Routed " +
    game.routed_ok.to_string() +
    "/" +
    @types.goal_routed.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 112,
    28,
    @raylib.Color::new(250, 230, 168, 238),
  )

  @raylib.draw_text(
    "Wrong " +
    game.routed_bad.to_string() +
    "   Crash " +
    game.collisions.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 146,
    24,
    @raylib.Color::new(248, 176, 192, 230),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 178,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 224,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 258,
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
    @types.panel_x0 + 20,
    @types.board_y0 + 286,
    30,
    timer_col,
  )

  @raylib.draw_text(
    "Signals",
    @types.panel_x0 + 20,
    @types.board_y0 + 332,
    24,
    @raylib.Color::new(206, 228, 248, 236),
  )

  for i in 0..<@types.junction_n {
    let mode_txt : String = if game.switch_state[i] < 0 {
      "UP"
    } else if game.switch_state[i] > 0 {
      "DOWN"
    } else {
      "STRAIGHT"
    }

    @raylib.draw_text(
      "J" + (i + 1).to_string() + " : " + mode_txt,
      @types.panel_x0 + 28,
      @types.board_y0 + 364 + i * 28,
      22,
      @raylib.Color::new(182, 212, 240, 228),
    )
  }

  @raylib.draw_text(
    "EMP Energy",
    @types.panel_x0 + 20,
    @types.board_y0 + 492,
    24,
    @raylib.Color::new(210, 194, 250, 236),
  )

  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 524,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )

  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 524,
    (Float::from_int(@types.panel_w - 40) * game.emp_energy / 100.0).to_int(),
    22,
    if game.emp_energy >= @types.emp_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )

  @raylib.draw_rectangle_lines(
    @types.panel_x0 + 20,
    @types.board_y0 + 524,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    @types.panel_x0 + 20,
    @types.board_y0 + 568,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    @types.panel_x0 + 30,
    @types.board_y0 + 598,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Action Space/E (toggle or EMP)",
    @types.panel_x0 + 30,
    @types.board_y0 + 624,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    @types.panel_x0 + 30,
    @types.board_y0 + 650,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    @types.panel_x0 + 20,
    @types.board_y0 + 692,
    20,
    @raylib.Color::new(166, 198, 226, 212),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      @types.panel_x0 + 16,
      @types.board_y0 + @types.board_h - 86,
      @types.panel_w - 32,
      64,
      @raylib.Color::new(26, 38, 62, 224),
    )

    @raylib.draw_rectangle_lines(
      @types.panel_x0 + 16,
      @types.board_y0 + @types.board_h - 86,
      @types.panel_w - 32,
      64,
      @raylib.Color::new(140, 182, 222, 178),
    )

    @raylib.draw_text(
      game.msg,
      @types.panel_x0 + 24,
      @types.board_y0 + @types.board_h - 66,
      20,
      @raylib.Color::new(228, 240, 255, 236),
    )
  }
}

///|
fn draw_title_overlay(game : @types.Game) -> Unit {
  let b = @types.start_button_rect()
  let hot : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    @types.board_x0 + 66,
    @types.board_y0 + 92,
    @types.board_w - 132,
    @types.board_h - 186,
    @raylib.Color::new(8, 14, 28, 224),
  )

  let t0 : String = "SUBWAY SIGNAL SABOTEUR"
  @raylib.draw_text(
    t0,
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(t0, 56) / 2,
    @types.board_y0 + 156,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Operate junction signals to route trains to correct colored exits.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(
      "Operate junction signals to route trains to correct colored exits.", 28,
    ) /
    2,
    @types.board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Avoid inspectors. Use EMP when trapped.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text("Avoid inspectors. Use EMP when trapped.", 28) / 2,
    @types.board_y0 + 286,
    28,
    @raylib.Color::new(186, 214, 240, 232),
  )

  @raylib.draw_text(
    "Need 20 successful routes before time runs out.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text("Need 20 successful routes before time runs out.", 28) /
    2,
    @types.board_y0 + 324,
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
}

///|
fn draw_result_overlay(game : @types.Game) -> Unit {
  let b = @types.retry_button_rect()
  let hot : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    @types.board_x0 + 100,
    @types.board_y0 + 122,
    @types.board_w - 200,
    @types.board_h - 244,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "SHIFT COMPLETE" } else { "SHIFT FAILED" }

  @raylib.draw_text(
    title,
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(title, 62) / 2,
    @types.board_y0 + 188,
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
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    @types.board_y0 + 282,
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
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(score_line, 30) / 2,
    @types.board_y0 + 334,
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
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_background(game)

  let ox : Int = shake_dx(game)
  let oy : Int = shake_dy(game)

  draw_board(game, ox, oy)
  draw_panel(game)
  draw_touch_controls(game)

  match game.state {
    @types.Title => draw_title_overlay(game)
    @types.Result => draw_result_overlay(game)
    @types.Play => ()
  }
}
