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
fn core_color(kind : Int) -> @raylib.Color {
  if kind == 1 {
    @raylib.Color::new(130, 214, 252, 242)
  } else if kind == 2 {
    @raylib.Color::new(176, 236, 166, 242)
  } else {
    @raylib.Color::new(244, 182, 120, 242)
  }
}

///|
fn drone_color(id : Int) -> @raylib.Color {
  if id == 1 {
    @raylib.Color::new(164, 194, 252, 232)
  } else if id == 2 {
    @raylib.Color::new(232, 206, 148, 232)
  } else {
    @raylib.Color::new(244, 152, 166, 232)
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

  let g0 : Int = 24 + (pulse(game, 0.36) * 20.0).to_int()
  let g1 : Int = 34 + (pulse(game, 0.60) * 24.0).to_int()

  @raylib.draw_circle(154, 108, 220.0, @raylib.Color::new(110, 136, 206, g0))
  @raylib.draw_circle(
    @types.screen_w - 120,
    96,
    180.0,
    @raylib.Color::new(178, 136, 208, g1),
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
      let t : Int = game.map[y * @types.grid_w + x]

      if t == @types.tile_wall {
        let tone : Int = if (x + y) % 2 == 0 { 56 } else { 64 }
        @raylib.draw_rectangle(
          rx,
          ry,
          @types.cell,
          @types.cell,
          @raylib.Color::new(tone, 54, 66, 252),
        )
        @raylib.draw_rectangle(
          rx + 5,
          ry + 8,
          @types.cell - 10,
          @types.cell - 14,
          @raylib.Color::new(82, 66, 64, 226),
        )
      } else if t == @types.tile_exit {
        @raylib.draw_rectangle(
          rx,
          ry,
          @types.cell,
          @types.cell,
          if game.portal_on {
            @raylib.Color::new(94, 198, 150, 236)
          } else {
            @raylib.Color::new(72, 88, 124, 232)
          },
        )

        if game.portal_on {
          @raylib.draw_circle(
            rx + @types.cell / 2,
            ry + @types.cell / 2,
            22.0,
            @raylib.Color::new(198, 248, 206, 84),
          )
        }
      } else {
        let tone : Int = if (x + y) % 2 == 0 { 26 } else { 32 }
        @raylib.draw_rectangle(
          rx,
          ry,
          @types.cell,
          @types.cell,
          @raylib.Color::new(24, tone, 52, 224),
        )
      }

      @raylib.draw_rectangle_lines(
        rx,
        ry,
        @types.cell,
        @types.cell,
        @raylib.Color::new(34, 46, 70, 98),
      )
    }
  }
}

///|
fn draw_portals(game : @types.Game, ox : Int, oy : Int) -> Unit {
  let a_cx : Int = @types.board_px(@types.portal_ax) + @types.cell / 2 + ox
  let a_cy : Int = @types.board_py(@types.portal_ay) + @types.cell / 2 + oy
  let b_cx : Int = @types.board_px(@types.portal_bx) + @types.cell / 2 + ox
  let b_cy : Int = @types.board_py(@types.portal_by) + @types.cell / 2 + oy

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
fn draw_cores(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for core in game.cores {
    if not(core.active) {
      continue
    }

    let cx : Int = @types.board_px(core.x) + @types.cell / 2 + ox
    let cy : Int = @types.board_py(core.y) + @types.cell / 2 + oy
    let col = core_color(core.kind)

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
fn draw_flares(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for flare in game.flares {
    if not(flare.active) {
      continue
    }

    let cx : Int = @types.board_px(flare.x) + @types.cell / 2 + ox
    let cy : Int = @types.board_py(flare.y) + @types.cell / 2 + oy
    let a : Int = @types.clampi((flare.t * 46.0).to_int(), 50, 188)

    @raylib.draw_circle(cx, cy, 38.0, @raylib.Color::new(192, 174, 244, a / 2))
    @raylib.draw_circle(cx, cy, 20.0, @raylib.Color::new(242, 236, 186, a))
  }
}

///|
fn draw_drones(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for drone in game.drones {
    if not(drone.active) {
      continue
    }

    let cx : Int = @types.cell_center_x(drone.body.fx) + ox
    let cy : Int = @types.cell_center_y(drone.body.fy) + oy

    let col = if drone.mode == @types.drone_stunned {
      @raylib.Color::new(170, 150, 246, 230)
    } else if drone.mode == @types.drone_hunt {
      @raylib.Color::new(252, 140, 164, 236)
    } else {
      drone_color(drone.color_id)
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
    26,
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

    let col = if particle.kind == 1 {
      @raylib.Color::new(250, 224, 154, 194)
    } else if particle.kind == 2 {
      @raylib.Color::new(170, 220, 252, 170)
    } else {
      @raylib.Color::new(194, 170, 246, 188)
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
fn light_alpha(game : @types.Game, x : Int, y : Int) -> Int {
  let mut best : Int = @types.manhattan(x, y, game.player.x, game.player.y)

  for flare in game.flares {
    if not(flare.active) {
      continue
    }

    let d : Int = @types.manhattan(x, y, flare.x, flare.y)
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
fn draw_blackout(game : @types.Game, ox : Int, oy : Int) -> Unit {
  for y in 1..<(@types.grid_h - 1) {
    for x in 1..<(@types.grid_w - 1) {
      let a : Int = light_alpha(game, x, y)
      @raylib.draw_rectangle(
        @types.board_px(x) + ox,
        @types.board_py(y) + oy,
        @types.cell,
        @types.cell,
        @raylib.Color::new(6, 8, 16, a),
      )
    }
  }
}

///|
fn draw_board(game : @types.Game, ox : Int, oy : Int) -> Unit {
  draw_tiles(game, ox, oy)
  draw_portals(game, ox, oy)
  draw_cores(game, ox, oy)
  draw_flares(game, ox, oy)
  draw_drones(game, ox, oy)
  draw_player(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_blackout(game, ox, oy)

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
  if game.state != @types.state_play {
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
    "PORTAL BLACKOUT",
    @types.panel_x0 + 20,
    @types.board_y0 + 18,
    34,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "ESCAPE 2026",
    @types.panel_x0 + 20,
    @types.board_y0 + 54,
    26,
    @raylib.Color::new(176, 208, 238, 236),
  )

  @raylib.draw_text(
    "Cores " +
    game.cores_taken.to_string() +
    "/" +
    @types.core_need.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 112,
    28,
    @raylib.Color::new(250, 230, 168, 238),
  )

  @raylib.draw_text(
    if game.portal_on {
      "Portal: ONLINE"
    } else {
      "Portal: OFFLINE"
    },
    @types.panel_x0 + 20,
    @types.board_y0 + 146,
    26,
    if game.portal_on {
      @raylib.Color::new(176, 242, 194, 236)
    } else {
      @raylib.Color::new(220, 166, 180, 236)
    },
  )

  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 182,
    28,
    @raylib.Color::new(244, 186, 196, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 228,
    30,
    @raylib.Color::new(220, 236, 252, 238),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    @types.panel_x0 + 20,
    @types.board_y0 + 262,
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
    @types.board_y0 + 290,
    30,
    timer_col,
  )

  @raylib.draw_text(
    "Flare Energy",
    @types.panel_x0 + 20,
    @types.board_y0 + 338,
    24,
    @raylib.Color::new(210, 194, 250, 236),
  )

  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 370,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(38, 48, 72, 226),
  )

  @raylib.draw_rectangle(
    @types.panel_x0 + 20,
    @types.board_y0 + 370,
    (Float::from_int(@types.panel_w - 40) * game.flare_energy / 100.0).to_int(),
    22,
    if game.flare_energy >= @types.flare_cost {
      @raylib.Color::new(166, 132, 244, 236)
    } else {
      @raylib.Color::new(112, 94, 148, 214)
    },
  )

  @raylib.draw_rectangle_lines(
    @types.panel_x0 + 20,
    @types.board_y0 + 370,
    @types.panel_w - 40,
    22,
    @raylib.Color::new(214, 226, 244, 178),
  )

  @raylib.draw_text(
    "Desktop:",
    @types.panel_x0 + 20,
    @types.board_y0 + 418,
    24,
    @raylib.Color::new(206, 228, 248, 232),
  )
  @raylib.draw_text(
    "Move WASD / Arrows",
    @types.panel_x0 + 30,
    @types.board_y0 + 448,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "Action Space/E (portal or flare)",
    @types.panel_x0 + 30,
    @types.board_y0 + 474,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )
  @raylib.draw_text(
    "H Hint, R Retry, Esc Menu",
    @types.panel_x0 + 30,
    @types.board_y0 + 500,
    21,
    @raylib.Color::new(170, 206, 236, 220),
  )

  @raylib.draw_text(
    "Mobile: left D-pad, right A/H/Retry/Menu",
    @types.panel_x0 + 20,
    @types.board_y0 + 542,
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

  let t0 : String = "PORTAL BLACKOUT ESCAPE"
  @raylib.draw_text(
    t0,
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(t0, 56) / 2,
    @types.board_y0 + 156,
    56,
    @raylib.Color::new(236, 244, 255, 246),
  )

  @raylib.draw_text(
    "Recover cores, reactivate portal pair, and escape before lights return.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(
      "Recover cores, reactivate portal pair, and escape before lights return.",
      28,
    ) /
    2,
    @types.board_y0 + 248,
    28,
    @raylib.Color::new(186, 214, 240, 236),
  )

  @raylib.draw_text(
    "Drones hunt in clear lines. Use flare EMP to create safe windows.",
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(
      "Drones hunt in clear lines. Use flare EMP to create safe windows.", 26,
    ) /
    2,
    @types.board_y0 + 286,
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
    @types.board_x0 + 102,
    @types.board_y0 + 122,
    @types.board_w - 204,
    @types.board_h - 244,
    @raylib.Color::new(8, 14, 28, 228),
  )

  let title : String = if game.win { "ESCAPED" } else { "FAILED" }

  @raylib.draw_text(
    title,
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(title, 62) / 2,
    @types.board_y0 + 190,
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
    @types.board_x0 +
    @types.board_w / 2 -
    @raylib.measure_text(reason, 28) / 2,
    @types.board_y0 + 286,
    28,
    @raylib.Color::new(196, 220, 246, 236),
  )

  let score_line : String = "Score " +
    game.score.to_string() +
    "   Cores " +
    game.cores_taken.to_string() +
    "/" +
    @types.core_need.to_string() +
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

  if game.state == @types.state_title {
    draw_title_overlay(game)
  } else if game.state == @types.state_result {
    draw_result_overlay(game)
  }
}
