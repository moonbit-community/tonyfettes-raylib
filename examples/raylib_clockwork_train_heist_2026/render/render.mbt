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
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn pulse(game : @types.Game, f : Float) -> Float {
  0.5 + 0.5 * @types.sinf(game.time_s * f)
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
fn draw_background(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 12, 20, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(24, 34, 58, 255),
    @raylib.Color::new(9, 10, 18, 255),
  )

  let glow0 : Int = 24 + (pulse(game, 0.38) * 26.0).to_int()
  let glow1 : Int = 38 + (pulse(game, 0.58) * 32.0).to_int()

  @raylib.draw_circle(180, 118, 220.0, @raylib.Color::new(126, 146, 214, glow0))
  @raylib.draw_circle(
    @types.screen_w - 110,
    96,
    170.0,
    @raylib.Color::new(188, 148, 206, glow1),
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
fn draw_tile_map(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      let rx : Int = @types.board_px(x) + ox
      let ry : Int = @types.board_py(y) + oy
      let t = game.map[y * @types.grid_w + x]

      match t {
        Wall => {
          let tone : Int = if (x + y) % 2 == 0 { 58 } else { 64 }
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(tone, 56, 70, 252),
          )

          @raylib.draw_rectangle(
            rx + 5,
            ry + 8,
            @types.cell - 10,
            @types.cell - 16,
            @raylib.Color::new(84, 66, 66, 228),
          )
        }
        Door => {
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(74, 108, 148, 236),
          )

          @raylib.draw_rectangle(
            rx + 10,
            ry + 12,
            @types.cell - 20,
            @types.cell - 24,
            @raylib.Color::new(130, 186, 232, 210),
          )
        }
        Exit => {
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            if game.vault_open {
              @raylib.Color::new(92, 192, 142, 236)
            } else {
              @raylib.Color::new(74, 92, 120, 232)
            },
          )

          if game.vault_open {
            @raylib.draw_circle(
              rx + @types.cell / 2,
              ry + @types.cell / 2,
              21.0,
              @raylib.Color::new(196, 246, 206, 88),
            )
          }
        }
        Floor => {
          let f0 : Int = if (x + y) % 2 == 0 { 32 } else { 36 }
          @raylib.draw_rectangle(
            rx,
            ry,
            @types.cell,
            @types.cell,
            @raylib.Color::new(26, f0, 56, 222),
          )
        }
      }

      @raylib.draw_rectangle_lines(
        rx,
        ry,
        @types.cell,
        @types.cell,
        @raylib.Color::new(34, 46, 70, 104),
      )
    }
  }
}

///|
fn draw_train_shell(ox : Int, oy : Int) -> Unit {
  for car in 0..<5 {
    let x0 : Int = @types.board_px(1 + car * 5) + ox
    let y0 : Int = @types.board_py(2) + oy
    let cw : Int = @types.cell * 4
    let ch : Int = @types.cell * 9

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

  for c in 0..<4 {
    let cx : Int = @types.board_px(5 + c * 5) + @types.cell / 2 + ox
    let cy : Int = @types.board_py(6) + @types.cell / 2 + oy
    @raylib.draw_circle(cx, cy, 13.0, @raylib.Color::new(174, 210, 244, 84))
  }
}

///|
fn draw_loot(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for loot in game.loots {
    if not(loot.active) {
      continue
    }

    let cx : Int = @types.board_px(loot.x) + @types.cell / 2 + ox
    let cy : Int = @types.board_py(loot.y) + @types.cell / 2 + oy

    match loot.kind {
      Blueprint => {
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
      }
      Keycard => {
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
      }
      Gold => {
        @raylib.draw_circle(
          cx,
          cy,
          13.0,
          @raylib.Color::new(242, 208, 112, 244),
        )
        @raylib.draw_circle_lines(
          cx,
          cy,
          13.0,
          @raylib.Color::new(122, 92, 38, 222),
        )
      }
    }

    @raylib.draw_circle(cx, cy, 26.0, @raylib.Color::new(250, 232, 170, 58))
  }
}

///|
fn draw_smokes(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for i in 0..<game.smokes.length() {
    if not(game.smokes[i].active) {
      continue
    }

    let cx : Int = @types.board_px(game.smokes[i].x) + @types.cell / 2 + ox
    let cy : Int = @types.board_py(game.smokes[i].y) + @types.cell / 2 + oy

    let alpha : Int = @types.clampi((game.smokes[i].t * 52.0).to_int(), 56, 188)

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
fn draw_guard(
  g : @types.Guard,
  _game : @types.Game,
  ox : Int,
  oy : Int,
) -> Unit {
  if not(g.active) {
    return
  }

  let cx : Int = @types.cell_center_x(g.body.fx) + ox
  let cy : Int = @types.cell_center_y(g.body.fy) + oy

  let col = match g.mode {
    Stunned => @raylib.Color::new(164, 144, 246, 226)
    Hunt => @raylib.Color::new(244, 138, 160, 232)
    Patrol => guard_base_color(g.color_id)
  }

  @raylib.draw_circle(cx, cy - 8, 14.0, col)
  @raylib.draw_rectangle(cx - 14, cy - 8, 28, 26, col)

  @raylib.draw_circle(cx - 4, cy - 10, 2.0, @raylib.Color::new(30, 42, 62, 255))
  @raylib.draw_circle(cx + 4, cy - 10, 2.0, @raylib.Color::new(30, 42, 62, 255))

  if g.mode == @types.Hunt {
    @raylib.draw_circle_lines(
      cx,
      cy - 2,
      22.0,
      @raylib.Color::new(252, 168, 188, 188),
    )
  }

  if g.mode == @types.Stunned {
    @raylib.draw_circle_lines(
      cx,
      cy - 2,
      20.0,
      @raylib.Color::new(194, 176, 252, 180),
    )
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
fn draw_particles(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    let col = match particle.kind {
      Smoke => @raylib.Color::new(194, 170, 246, 188)
      Glitter => @raylib.Color::new(250, 226, 152, 194)
      Spark => @raylib.Color::new(170, 220, 252, 166)
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
  draw_tile_map(game, ox, oy)
  draw_train_shell(ox, oy)
  draw_loot(game, ox, oy)
  draw_smokes(game, ox, oy)

  for guard_val in game.guards {
    draw_guard(guard_val, game, ox, oy)
  }

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
  let on : Bool = @types.pointer_on_rect(game, rect.0, rect.1, rect.2, rect.3)

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
    "CLOCKWORK TRAIN",
    @types.panel_x0 + 20,
    @types.board_y0 + 20,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "HEIST 2026",
    @types.panel_x0 + 20,
    @types.board_y0 + 56,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Loot " + game.loot_taken.to_string() + "/" + @types.loot_need.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 114,
    28,
    @raylib.Color::new(248, 230, 166, 238),
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 148,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 196,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )

  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 230,
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
    @types.board_y0 + 258,
    30,
    timer_col,
  )

  @raylib.draw_text(
    if game.vault_open {
      "Cable: OPEN"
    } else {
      "Cable: LOCKED"
    },
    @types.panel_x0 + 20,
    @types.board_y0 + 294,
    26,
    if game.vault_open {
      @raylib.Color::new(176, 242, 194, 236)
    } else {
      @raylib.Color::new(208, 168, 182, 236)
    },
  )

  @raylib.draw_text(
    "Smoke Energy",
    @types.panel_x0 + 20,
    @types.board_y0 + 348,
    24,
    @raylib.Color::new(206, 192, 248, 236),
  )

  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 380,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )
  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 380,
    (Float::from_int(@types.panel_w - 40) * game.smoke_energy / 100.0).to_int(),
    22,
    if game.smoke_energy >= @types.smoke_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )
  @raylib.draw_rectangle_lines(
    @types.panel_x0 + 20,
    @types.board_y0 + 380,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    @types.panel_x0 + 20,
    @types.board_y0 + 432,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    @types.panel_x0 + 30,
    @types.board_y0 + 462,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Smoke Space / E",
    @types.panel_x0 + 30,
    @types.board_y0 + 488,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    @types.panel_x0 + 30,
    @types.board_y0 + 514,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    @types.panel_x0 + 20,
    @types.board_y0 + 562,
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
  let hot : Bool = @types.title_hover(game)

  @raylib.draw_rectangle(
    @types.board_x0 + 72,
    @types.board_y0 + 94,
    @types.board_w - 144,
    @types.board_h - 188,
    @raylib.Color::new(8, 14, 28, 224),
  )

  let t0 : String = "CLOCKWORK TRAIN HEIST"
  @raylib.draw_text(
    t0,
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(t0, 56) / 2,
    @types.board_y0 + 160,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Sneak through train cars, steal loot, deploy smoke, then escape.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(
      "Sneak through train cars, steal loot, deploy smoke, then escape.", 28,
    ) /
    2,
    @types.board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Guards patrol routes and chase on sight in straight corridors.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(
      "Guards patrol routes and chase on sight in straight corridors.", 26,
    ) /
    2,
    @types.board_y0 + 286,
    26,
    @raylib.Color::new(186, 214, 240, 232),
  )

  @raylib.draw_text(
    "Need 6 loot pieces to open the cable lock.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text("Need 6 loot pieces to open the cable lock.", 28) / 2,
    @types.board_y0 + 326,
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
fn draw_result_overlay(game : @types.Game) -> Unit {
  let b = @types.retry_button_rect()
  let hot : Bool = @types.retry_hover(game)

  @raylib.draw_rectangle(
    @types.board_x0 + 108,
    @types.board_y0 + 120,
    @types.board_w - 216,
    @types.board_h - 240,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "HEIST COMPLETE" } else { "HEIST FAILED" }

  @raylib.draw_text(
    title,
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(title, 62) / 2,
    @types.board_y0 + 190,
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
    @types.board_x0 + @types.board_w / 2 - @raylib.measure_text(reason, 28) / 2,
    @types.board_y0 + 284,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Loot " +
    game.loot_taken.to_string() +
    "/" +
    @types.loot_need.to_string() +
    "   Lives " +
    game.lives.to_string()

  @raylib.draw_text(
    score_line,
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(score_line, 30) / 2,
    @types.board_y0 + 336,
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
    Title => draw_title_overlay(game)
    Result => draw_result_overlay(game)
    Play => ()
  }
}
