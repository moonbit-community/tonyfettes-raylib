///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(13, 10, 8, 255))

  for i = 0; i < 14; i = i + 1 {
    let y = i * 70 - 24
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      54,
      @raylib.Color::new(22 + i * 5 % 22, 16 + i * 4 % 18, 10 + i * 3 % 14, 58),
    )
  }

  let pulse = (game.stage_time * 3.5).to_int() % 18
  @raylib.draw_circle(
    250,
    120,
    Float::from_int(130 + pulse),
    @raylib.Color::new(88, 60, 24, 32),
  )
  @raylib.draw_circle(
    screen_w - 220,
    150,
    Float::from_int(150 - pulse / 2),
    @raylib.Color::new(40, 74, 84, 28),
  )
}

///|
fn draw_world_bounds() -> Unit {
  @raylib.draw_rectangle(
    world_x.to_int(),
    world_y.to_int(),
    world_w.to_int(),
    world_h.to_int(),
    @raylib.Color::new(34, 28, 22, 248),
  )
  @raylib.draw_rectangle_lines(
    world_x.to_int(),
    world_y.to_int(),
    world_w.to_int(),
    world_h.to_int(),
    @raylib.Color::new(172, 136, 88, 220),
  )
}

///|
fn draw_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    let col = if game.hazards[i].kind == hazard_kind_lava {
      @raylib.Color::new(168, 50, 18, 222)
    } else {
      @raylib.Color::new(120, 30, 24, 222)
    }
    @raylib.draw_rectangle(
      game.hazards[i].x.to_int(),
      game.hazards[i].y.to_int(),
      game.hazards[i].w.to_int(),
      game.hazards[i].h.to_int(),
      col,
    )
    @raylib.draw_rectangle_lines(
      game.hazards[i].x.to_int(),
      game.hazards[i].y.to_int(),
      game.hazards[i].w.to_int(),
      game.hazards[i].h.to_int(),
      @raylib.Color::new(255, 162, 108, 220),
    )
  }
}

///|
fn draw_traps(game : Game) -> Unit {
  for i = 0; i < game.traps.length(); i = i + 1 {
    let hot = trap_is_hot(game.traps[i])
    let base_col = if hot {
      @raylib.Color::new(242, 78, 52, 236)
    } else if game.traps[i].kind == trap_kind_spike {
      @raylib.Color::new(86, 72, 70, 226)
    } else {
      @raylib.Color::new(64, 84, 96, 226)
    }

    @raylib.draw_rectangle(
      game.traps[i].x.to_int(),
      game.traps[i].y.to_int(),
      game.traps[i].w.to_int(),
      game.traps[i].h.to_int(),
      base_col,
    )
    @raylib.draw_rectangle_lines(
      game.traps[i].x.to_int(),
      game.traps[i].y.to_int(),
      game.traps[i].w.to_int(),
      game.traps[i].h.to_int(),
      if hot {
        @raylib.Color::new(255, 206, 186, 250)
      } else {
        @raylib.Color::new(166, 150, 132, 196)
      },
    )

    if hot {
      @raylib.draw_text(
        "HOT",
        game.traps[i].x.to_int() + 8,
        game.traps[i].y.to_int() + 6,
        16,
        @raylib.Color::new(255, 236, 232, 248),
      )
    }
  }
}

///|
fn draw_plates(game : Game) -> Unit {
  for i = 0; i < game.plates.length(); i = i + 1 {
    @raylib.draw_rectangle(
      game.plates[i].x.to_int(),
      game.plates[i].y.to_int(),
      game.plates[i].w.to_int(),
      game.plates[i].h.to_int(),
      if game.plates[i].pressed {
        @raylib.Color::new(40, 122, 96, 232)
      } else {
        @raylib.Color::new(58, 82, 62, 220)
      },
    )
    @raylib.draw_rectangle_lines(
      game.plates[i].x.to_int(),
      game.plates[i].y.to_int(),
      game.plates[i].w.to_int(),
      game.plates[i].h.to_int(),
      @raylib.Color::new(186, 234, 210, 220),
    )
    @raylib.draw_text(
      "PLATE",
      game.plates[i].x.to_int() + 18,
      game.plates[i].y.to_int() + 32,
      16,
      @raylib.Color::new(232, 250, 236, 246),
    )
  }
}

///|
fn draw_doors(game : Game) -> Unit {
  for i = 0; i < game.doors.length(); i = i + 1 {
    let ratio : Float = if game.doors[i].hold_time > 0.0 {
      clampf(game.doors[i].timer / game.doors[i].hold_time, 0.0, 1.0)
    } else {
      0.0
    }

    let open_alpha : Int = 96 + (ratio * Float::from_int(90)).to_int()
    let door_col = if game.doors[i].open {
      @raylib.Color::new(62, 174, 140, open_alpha)
    } else {
      @raylib.Color::new(118, 68, 34, 248)
    }

    @raylib.draw_rectangle(
      game.doors[i].x.to_int(),
      game.doors[i].y.to_int(),
      game.doors[i].w.to_int(),
      game.doors[i].h.to_int(),
      door_col,
    )
    @raylib.draw_rectangle_lines(
      game.doors[i].x.to_int(),
      game.doors[i].y.to_int(),
      game.doors[i].w.to_int(),
      game.doors[i].h.to_int(),
      if game.doors[i].open {
        @raylib.Color::new(206, 248, 220, 232)
      } else {
        @raylib.Color::new(236, 184, 124, 232)
      },
    )
  }
}

///|
fn draw_relics(game : Game) -> Unit {
  for i = 0; i < game.relics.length(); i = i + 1 {
    if not(game.relics[i].active) {
      continue
    }

    let pulse : Int = 5 +
      (game.stage_time * 12.0 + Float::from_int(i) * 1.4).to_int() % 4
    @raylib.draw_circle(
      game.relics[i].x.to_int(),
      game.relics[i].y.to_int(),
      game.relics[i].r + Float::from_int(pulse),
      @raylib.Color::new(188, 146, 52, 68),
    )
    @raylib.draw_circle(
      game.relics[i].x.to_int(),
      game.relics[i].y.to_int(),
      game.relics[i].r,
      @raylib.Color::new(248, 206, 84, 246),
    )
    @raylib.draw_circle_lines(
      game.relics[i].x.to_int(),
      game.relics[i].y.to_int(),
      game.relics[i].r + 2.0,
      @raylib.Color::new(255, 250, 204, 246),
    )
  }
}

///|
fn draw_exit_gate(game : Game) -> Unit {
  let unlocked = exit_unlocked(game)

  @raylib.draw_rectangle(
    game.exit_x.to_int(),
    game.exit_y.to_int(),
    game.exit_w.to_int(),
    game.exit_h.to_int(),
    if unlocked {
      @raylib.Color::new(78, 140, 86, 214)
    } else {
      @raylib.Color::new(94, 52, 46, 214)
    },
  )
  @raylib.draw_rectangle_lines(
    game.exit_x.to_int(),
    game.exit_y.to_int(),
    game.exit_w.to_int(),
    game.exit_h.to_int(),
    if unlocked {
      @raylib.Color::new(206, 250, 214, 246)
    } else {
      @raylib.Color::new(236, 180, 170, 236)
    },
  )

  @raylib.draw_text(
    if unlocked {
      "EXIT"
    } else {
      "SEALED"
    },
    game.exit_x.to_int() + 8,
    game.exit_y.to_int() + game.exit_h.to_int() / 2 - 10,
    20,
    @raylib.Color::new(250, 246, 238, 246),
  )
}

///|
fn draw_player(game : Game) -> Unit {
  let px = (game.player.x - game.player.w * 0.5).to_int()
  let py = (game.player.y - game.player.h * 0.5).to_int()

  if game.player.dash_on {
    @raylib.draw_circle(
      game.player.x.to_int(),
      game.player.y.to_int(),
      game.player.w * 0.82,
      @raylib.Color::new(104, 208, 230, 88),
    )
  }

  @raylib.draw_rectangle(
    px,
    py,
    game.player.w.to_int(),
    game.player.h.to_int(),
    @raylib.Color::new(190, 208, 224, 246),
  )
  @raylib.draw_rectangle_lines(
    px,
    py,
    game.player.w.to_int(),
    game.player.h.to_int(),
    @raylib.Color::new(24, 36, 46, 250),
  )

  @raylib.draw_circle(
    game.player.x.to_int(),
    (game.player.y - 6.0).to_int(),
    4.0,
    @raylib.Color::new(36, 52, 66, 250),
  )
}

///|
fn draw_world(game : Game) -> Unit {
  draw_world_bounds()
  draw_hazards(game)
  draw_traps(game)
  draw_plates(game)
  draw_relics(game)
  draw_doors(game)
  draw_exit_gate(game)
  draw_player(game)
}

///|
fn draw_meter(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  ratio : Float,
  fill : @raylib.Color,
) -> Unit {
  @raylib.draw_text(label, x, y, 22, @raylib.Color::new(236, 232, 226, 248))
  @raylib.draw_rectangle(x, y + 28, w, 24, @raylib.Color::new(58, 50, 44, 236))
  @raylib.draw_rectangle(
    x + 2,
    y + 30,
    (Float::from_int(w - 4) * clampf(ratio, 0.0, 1.0)).to_int(),
    20,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y + 28,
    w,
    24,
    @raylib.Color::new(206, 188, 160, 226),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  let (px, py, pw, ph) = panel_rect()
  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(22, 26, 30, 236))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(120, 146, 170, 220),
  )

  @raylib.draw_text(
    "Ancient Temple Trap Run",
    px + 24,
    py + 26,
    28,
    @raylib.Color::new(246, 238, 208, 248),
  )

  @raylib.draw_text(
    "Stage \{game.stage_index + 1}/\{game.stage_count}: \{stage_name(game.stage_index)}",
    px + 24,
    py + 66,
    22,
    @raylib.Color::new(222, 230, 240, 240),
  )

  @raylib.draw_text(
    "Relics \{game.collected_relics}/\{game.required_relics}",
    px + 24,
    py + 108,
    24,
    if exit_unlocked(game) {
      @raylib.Color::new(148, 238, 168, 246)
    } else {
      @raylib.Color::new(246, 214, 142, 246)
    },
  )

  draw_meter(
    "Stamina",
    px + 24,
    py + 150,
    320,
    game.player.stamina / stamina_max,
    if game.player.dash_on {
      @raylib.Color::new(86, 206, 234, 236)
    } else {
      @raylib.Color::new(128, 190, 132, 236)
    },
  )

  @raylib.draw_text(
    "Time \{game.stage_time.to_int()}s",
    px + 24,
    py + 220,
    24,
    @raylib.Color::new(222, 228, 240, 244),
  )

  @raylib.draw_text(
    "Controls",
    px + 24,
    py + 268,
    24,
    @raylib.Color::new(248, 238, 212, 244),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    px + 24,
    py + 300,
    22,
    @raylib.Color::new(214, 222, 230, 242),
  )
  @raylib.draw_text(
    "Dash: Shift (drains stamina)",
    px + 24,
    py + 330,
    22,
    @raylib.Color::new(214, 222, 230, 242),
  )
  @raylib.draw_text(
    "Restart stage: R",
    px + 24,
    py + 360,
    22,
    @raylib.Color::new(214, 222, 230, 242),
  )

  @raylib.draw_text(
    "Step on plates to open doors.",
    px + 24,
    py + 420,
    22,
    @raylib.Color::new(208, 236, 218, 244),
  )
  @raylib.draw_text(
    "Cross before the hold timer runs out.",
    px + 24,
    py + 448,
    22,
    @raylib.Color::new(208, 236, 218, 244),
  )

  let (rx, ry, rw, rh) = play_restart_rect()
  @raylib.draw_rectangle(rx, ry, rw, rh, @raylib.Color::new(82, 74, 66, 230))
  @raylib.draw_rectangle_lines(
    rx,
    ry,
    rw,
    rh,
    @raylib.Color::new(214, 198, 172, 240),
  )
  @raylib.draw_text(
    "Retry Stage",
    rx + rw / 2 - @raylib.measure_text("Retry Stage", 24) / 2,
    ry + rh / 2 - 12,
    24,
    @raylib.Color::new(248, 240, 224, 246),
  )
}

///|
fn draw_button(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  accent : @raylib.Color,
  hot : Bool,
) -> Unit {
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if hot {
      accent
    } else {
      @raylib.Color::new(72, 76, 88, 232)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(224, 232, 244, 240),
  )
  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, 32) / 2,
    y + h / 2 - 16,
    32,
    @raylib.Color::new(246, 248, 252, 248),
  )
}

///|
fn draw_touch_button(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  active : Bool,
) -> Unit {
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if active {
      @raylib.Color::new(112, 166, 190, 168)
    } else {
      @raylib.Color::new(78, 90, 108, 126)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(216, 230, 248, 160),
  )
  @raylib.draw_text(
    label,
    x + w / 2 - @raylib.measure_text(label, 30) / 2,
    y + h / 2 - 15,
    30,
    @raylib.Color::new(242, 248, 255, 210),
  )
}

///|
fn draw_touch_controls(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  let (lx, ly, lw, lh) = touch_left_rect()
  let (rx, ry, rw, rh) = touch_right_rect()
  let (ux, uy, uw, uh) = touch_up_rect()
  let (dx, dy, dw, dh) = touch_down_rect()
  let (dash_x, dash_y, dash_w, dash_h) = touch_dash_rect()

  draw_touch_button(
    "L",
    lx,
    ly,
    lw,
    lh,
    pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, lx, ly, lw, lh),
  )
  draw_touch_button(
    "R",
    rx,
    ry,
    rw,
    rh,
    pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, rx, ry, rw, rh),
  )
  draw_touch_button(
    "U",
    ux,
    uy,
    uw,
    uh,
    pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, ux, uy, uw, uh),
  )
  draw_touch_button(
    "D",
    dx,
    dy,
    dw,
    dh,
    pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, dx, dy, dw, dh),
  )
  draw_touch_button(
    "DASH",
    dash_x,
    dash_y,
    dash_w,
    dash_h,
    pointer_on_rect(
      mouse_x, mouse_y, mouse_hold, touch_count, dash_x, dash_y, dash_w, dash_h,
    ),
  )
}

///|
fn draw_banner(game : Game) -> Unit {
  if game.banner_t <= 0.0 {
    return
  }

  let alpha = clampf(game.banner_t / 1.4, 0.0, 1.0)
  let a : Int = (alpha * 210.0).to_int()

  let bw = @raylib.measure_text(game.banner_text, 30) + 56
  let bx = screen_w / 2 - bw / 2
  let by = 22

  @raylib.draw_rectangle(bx, by, bw, 44, @raylib.Color::new(24, 28, 34, a))
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    44,
    @raylib.Color::new(222, 234, 248, a),
  )
  @raylib.draw_text(
    game.banner_text,
    bx + 28,
    by + 11,
    22,
    @raylib.Color::new(242, 248, 255, a + 20),
  )
}

///|
fn draw_title_overlay(
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
    @raylib.Color::new(10, 14, 18, 172),
  )

  let card_x = screen_w / 2 - 420
  let card_y = screen_h / 2 - 220
  @raylib.draw_rectangle(
    card_x,
    card_y,
    840,
    430,
    @raylib.Color::new(26, 34, 40, 236),
  )
  @raylib.draw_rectangle_lines(
    card_x,
    card_y,
    840,
    430,
    @raylib.Color::new(216, 198, 148, 236),
  )

  @raylib.draw_text(
    "ANCIENT TEMPLE: TRAP RUN",
    card_x + 60,
    card_y + 44,
    48,
    @raylib.Color::new(250, 228, 152, 250),
  )

  @raylib.draw_text(
    "Collect relics, hold plates, and dash through closing stone doors.",
    card_x + 60,
    card_y + 118,
    28,
    @raylib.Color::new(220, 232, 242, 244),
  )
  @raylib.draw_text(
    "Timed traps and hazard pits will end the run instantly.",
    card_x + 60,
    card_y + 156,
    28,
    @raylib.Color::new(220, 232, 242, 244),
  )

  @raylib.draw_text(
    "Desktop: WASD/Arrows + Shift  |  Mobile: touch d-pad + DASH",
    card_x + 60,
    card_y + 204,
    24,
    @raylib.Color::new(182, 218, 236, 236),
  )

  let (sx, sy, sw, sh) = title_start_rect()
  let hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, sx, sy, sw, sh,
  )
  draw_button(
    "Start Expedition",
    sx,
    sy,
    sw,
    sh,
    @raylib.Color::new(88, 146, 108, 236),
    hot,
  )
}

///|
fn draw_stage_clear_overlay(
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
    @raylib.Color::new(8, 18, 16, 154),
  )

  let px = screen_w / 2 - 380
  let py = screen_h / 2 - 170
  @raylib.draw_rectangle(px, py, 760, 320, @raylib.Color::new(18, 36, 28, 238))
  @raylib.draw_rectangle_lines(
    px,
    py,
    760,
    320,
    @raylib.Color::new(182, 240, 210, 240),
  )

  @raylib.draw_text(
    "Stage Cleared",
    px + 232,
    py + 40,
    52,
    @raylib.Color::new(176, 248, 202, 250),
  )
  @raylib.draw_text(
    "\{stage_name(game.stage_index)} conquered",
    px + 188,
    py + 106,
    32,
    @raylib.Color::new(230, 242, 252, 246),
  )

  let (next_x, next_y, next_w, next_h) = panel_next_rect()
  let (rst_x, rst_y, rst_w, rst_h) = panel_restart_rect()
  let next_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, next_x, next_y, next_w, next_h,
  )
  let rst_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, rst_x, rst_y, rst_w, rst_h,
  )

  draw_button(
    "Next",
    next_x,
    next_y,
    next_w,
    next_h,
    @raylib.Color::new(84, 154, 114, 236),
    next_hot,
  )
  draw_button(
    "Retry",
    rst_x,
    rst_y,
    rst_w,
    rst_h,
    @raylib.Color::new(132, 108, 74, 236),
    rst_hot,
  )
}

///|
fn draw_failed_overlay(
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
    @raylib.Color::new(24, 6, 6, 178),
  )

  let px = screen_w / 2 - 430
  let py = screen_h / 2 - 190
  @raylib.draw_rectangle(px, py, 860, 360, @raylib.Color::new(46, 22, 20, 240))
  @raylib.draw_rectangle_lines(
    px,
    py,
    860,
    360,
    @raylib.Color::new(242, 164, 154, 236),
  )

  @raylib.draw_text(
    "Expedition Lost",
    px + 230,
    py + 38,
    56,
    @raylib.Color::new(255, 180, 168, 250),
  )
  @raylib.draw_text(
    game.fail_reason,
    px + 58,
    py + 122,
    30,
    @raylib.Color::new(246, 232, 228, 246),
  )

  let (title_x, title_y, title_w, title_h) = panel_next_rect()
  let (retry_x, retry_y, retry_w, retry_h) = panel_restart_rect()
  let title_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, title_x, title_y, title_w, title_h,
  )
  let retry_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, retry_x, retry_y, retry_w, retry_h,
  )

  draw_button(
    "Title",
    title_x,
    title_y,
    title_w,
    title_h,
    @raylib.Color::new(92, 110, 128, 236),
    title_hot,
  )
  draw_button(
    "Retry",
    retry_x,
    retry_y,
    retry_w,
    retry_h,
    @raylib.Color::new(168, 90, 70, 238),
    retry_hot,
  )
}

///|
fn draw_victory_overlay(
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
    @raylib.Color::new(8, 22, 26, 178),
  )

  let px = screen_w / 2 - 430
  let py = screen_h / 2 - 190
  @raylib.draw_rectangle(px, py, 860, 360, @raylib.Color::new(16, 34, 46, 238))
  @raylib.draw_rectangle_lines(
    px,
    py,
    860,
    360,
    @raylib.Color::new(186, 228, 244, 242),
  )

  @raylib.draw_text(
    "Temple Escaped",
    px + 216,
    py + 36,
    56,
    @raylib.Color::new(172, 232, 250, 250),
  )
  @raylib.draw_text(
    "Every relic recovered. The cursed vault is now behind you.",
    px + 90,
    py + 122,
    30,
    @raylib.Color::new(228, 238, 246, 246),
  )

  let (again_x, again_y, again_w, again_h) = panel_next_rect()
  let (title_x, title_y, title_w, title_h) = panel_restart_rect()
  let again_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, again_x, again_y, again_w, again_h,
  )
  let title_hot = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, title_x, title_y, title_w, title_h,
  )

  draw_button(
    "Run Again",
    again_x,
    again_y,
    again_w,
    again_h,
    @raylib.Color::new(84, 152, 190, 236),
    again_hot,
  )
  draw_button(
    "Title",
    title_x,
    title_y,
    title_w,
    title_h,
    @raylib.Color::new(88, 104, 126, 236),
    title_hot,
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
  draw_background(game)

  if game.state != state_title {
    draw_world(game)
    draw_hud(game)

    if game.state == state_play && game.touch_mode {
      draw_touch_controls(mouse_x, mouse_y, mouse_hold, touch_count)
    }

    draw_banner(game)
  }

  if game.state == state_title {
    draw_title_overlay(mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_failed {
    draw_failed_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_victory {
    draw_victory_overlay(mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
