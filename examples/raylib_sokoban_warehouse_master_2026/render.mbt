///|
fn draw_bg(game : Game) -> Unit {
  let pulse : Float = Float::from_double(
    @math.sin((game.pulse_t * 0.8).to_double()),
  )

  @raylib.clear_background(@raylib.Color::new(10, 13, 20, 255))

  for i = 0; i < 18; i = i + 1 {
    let y : Int = i * 60 - 18
    let alpha : Int = 18 + i * 13 % 32
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      46,
      @raylib.Color::new(
        20 + i * 7 % 25,
        26 + i * 9 % 28,
        38 + i * 11 % 30,
        alpha,
      ),
    )
  }

  @raylib.draw_circle(
    180,
    140,
    160.0 + pulse * 10.0,
    @raylib.Color::new(34, 62, 84, 26),
  )
  @raylib.draw_circle(
    screen_w - 220,
    170,
    170.0,
    @raylib.Color::new(60, 40, 28, 20),
  )
}

///|
fn board_layout(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 28
  let area_y : Int = 28
  let area_w : Int = screen_w - 396
  let area_h : Int = screen_h - 56

  let safe_w : Int = maxi(1, game.grid_w)
  let safe_h : Int = maxi(1, game.grid_h)

  let tile_x : Int = (area_w - 24) / safe_w
  let tile_y : Int = (area_h - 24) / safe_h
  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 28, 66)

  let mut left : Int = area_x + (area_w - safe_w * tile) / 2
  let mut top : Int = area_y + (area_h - safe_h * tile) / 2

  if game.shake_t > 0.0 {
    left = left + @raylib.get_random_value(-3, 3)
    top = top + @raylib.get_random_value(-3, 3)
  }

  (left, top, tile)
}

///|
fn draw_cell_floor(px : Int, py : Int, tile : Int, goal : Bool) -> Unit {
  if goal {
    @raylib.draw_rectangle(
      px,
      py,
      tile,
      tile,
      @raylib.Color::new(39, 34, 27, 255),
    )
    @raylib.draw_rectangle_lines(
      px,
      py,
      tile,
      tile,
      @raylib.Color::new(137, 112, 64, 170),
    )
    @raylib.draw_circle(
      px + tile / 2,
      py + tile / 2,
      Float::from_int(tile) * 0.21,
      @raylib.Color::new(214, 168, 52, 196),
    )
    @raylib.draw_circle_lines(
      px + tile / 2,
      py + tile / 2,
      Float::from_int(tile) * 0.27,
      @raylib.Color::new(236, 204, 120, 230),
    )
  } else {
    @raylib.draw_rectangle(
      px,
      py,
      tile,
      tile,
      @raylib.Color::new(28, 32, 40, 255),
    )
    @raylib.draw_rectangle_lines(
      px,
      py,
      tile,
      tile,
      @raylib.Color::new(52, 62, 76, 150),
    )
  }
}

///|
fn draw_cell_wall(px : Int, py : Int, tile : Int) -> Unit {
  @raylib.draw_rectangle(
    px,
    py,
    tile,
    tile,
    @raylib.Color::new(68, 76, 94, 255),
  )
  @raylib.draw_rectangle(
    px + 3,
    py + 3,
    tile - 6,
    tile - 6,
    @raylib.Color::new(94, 108, 129, 255),
  )
  @raylib.draw_rectangle_lines(
    px,
    py,
    tile,
    tile,
    @raylib.Color::new(138, 154, 174, 200),
  )
}

///|
fn draw_box(px : Int, py : Int, tile : Int, on_goal : Bool) -> Unit {
  let body = if on_goal {
    @raylib.Color::new(186, 136, 72, 255)
  } else {
    @raylib.Color::new(142, 102, 54, 255)
  }
  let edge = if on_goal {
    @raylib.Color::new(250, 210, 122, 255)
  } else {
    @raylib.Color::new(208, 162, 104, 255)
  }

  @raylib.draw_rectangle(px + 4, py + 4, tile - 8, tile - 8, body)
  @raylib.draw_rectangle_lines(px + 4, py + 4, tile - 8, tile - 8, edge)
  @raylib.draw_line(px + 8, py + 8, px + tile - 8, py + tile - 8, edge)
  @raylib.draw_line(px + tile - 8, py + 8, px + 8, py + tile - 8, edge)
}

///|
fn draw_player(px : Int, py : Int, tile : Int, pulse_t : Float) -> Unit {
  let bob : Int = Float::from_double(
    @math.sin((pulse_t * 8.4).to_double()) * 2.0,
  ).to_int()

  @raylib.draw_circle(
    px + tile / 2,
    py + tile / 2 + bob,
    Float::from_int(tile) * 0.34,
    @raylib.Color::new(62, 198, 235, 255),
  )
  @raylib.draw_circle(
    px + tile / 2,
    py + tile / 2 + bob,
    Float::from_int(tile) * 0.20,
    @raylib.Color::new(228, 246, 255, 255),
  )
  @raylib.draw_circle(
    px + tile / 2 + tile / 7,
    py + tile / 2 + bob - tile / 9,
    Float::from_int(tile) * 0.05,
    @raylib.Color::new(13, 33, 55, 255),
  )
}

///|
fn draw_board(game : Game) -> Unit {
  let (left, top, tile) = board_layout(game)

  @raylib.draw_rectangle(
    left - 10,
    top - 10,
    game.grid_w * tile + 20,
    game.grid_h * tile + 20,
    @raylib.Color::new(9, 11, 17, 188),
  )
  @raylib.draw_rectangle_lines(
    left - 10,
    top - 10,
    game.grid_w * tile + 20,
    game.grid_h * tile + 20,
    @raylib.Color::new(96, 132, 166, 120),
  )

  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      let t : Int = tile_at(game, x, y)
      let px : Int = left + x * tile
      let py : Int = top + y * tile

      if t == tile_void {
        @raylib.draw_rectangle(
          px,
          py,
          tile,
          tile,
          @raylib.Color::new(18, 20, 28, 255),
        )
        continue
      }

      if t == tile_wall {
        draw_cell_wall(px, py, tile)
      } else {
        draw_cell_floor(px, py, tile, t == tile_goal)
      }

      if box_at(game, x, y) {
        draw_box(px, py, tile, t == tile_goal)
      }
    }
  }

  let ppx : Int = left + game.player_x * tile
  let ppy : Int = top + game.player_y * tile
  draw_player(ppx, ppy, tile, game.pulse_t)

  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    let sx : Int = left + (game.sparks[i].x * Float::from_int(tile)).to_int()
    let sy : Int = top + (game.sparks[i].y * Float::from_int(tile)).to_int()
    let sr : Float = maxf(1.0, Float::from_int(tile) * game.sparks[i].size)

    let c = if game.sparks[i].kind == 0 {
      @raylib.Color::new(255, 218, 102, 235)
    } else if game.sparks[i].kind == 1 {
      @raylib.Color::new(248, 164, 78, 225)
    } else if game.sparks[i].kind == 2 {
      @raylib.Color::new(236, 100, 86, 214)
    } else {
      @raylib.Color::new(118, 222, 254, 228)
    }

    @raylib.draw_circle(sx, sy, sr, c)
  }
}

///|
fn draw_side_panel(game : Game) -> Unit {
  let panel_x : Int = screen_w - 352
  let panel_y : Int = 20
  let panel_w : Int = 324
  let panel_h : Int = screen_h - 40

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(14, 20, 30, 236),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(98, 140, 174, 192),
  )

  @raylib.draw_text(
    "Warehouse Master 2026",
    panel_x + 22,
    panel_y + 22,
    34,
    @raylib.Color::new(240, 248, 255, 240),
  )
  @raylib.draw_text(
    "Sokoban Campaign",
    panel_x + 22,
    panel_y + 64,
    24,
    @raylib.Color::new(170, 208, 232, 238),
  )

  @raylib.draw_text(
    "Level \{game.level_index + 1}/\{game.level_count}",
    panel_x + 22,
    panel_y + 114,
    28,
    @raylib.Color::new(226, 236, 250, 235),
  )
  @raylib.draw_text(
    game.level_name,
    panel_x + 22,
    panel_y + 148,
    24,
    @raylib.Color::new(248, 220, 142, 245),
  )

  let goals_done : Int = goal_filled_count(game)
  @raylib.draw_text(
    "Goals \{goals_done}/\{game.goals_total}",
    panel_x + 22,
    panel_y + 204,
    26,
    @raylib.Color::new(240, 236, 210, 236),
  )
  @raylib.draw_text(
    "Moves \{game.moves}  (Par \{game.level_par})",
    panel_x + 22,
    panel_y + 238,
    25,
    @raylib.Color::new(212, 230, 246, 236),
  )
  @raylib.draw_text(
    "Pushes \{game.pushes}",
    panel_x + 22,
    panel_y + 270,
    25,
    @raylib.Color::new(212, 230, 246, 236),
  )
  @raylib.draw_text(
    "Time \{game.elapsed.to_int()}s",
    panel_x + 22,
    panel_y + 302,
    25,
    @raylib.Color::new(212, 230, 246, 236),
  )

  @raylib.draw_text(
    "Campaign stars \{game.campaign_stars}",
    panel_x + 22,
    panel_y + 348,
    25,
    @raylib.Color::new(255, 218, 118, 244),
  )
  @raylib.draw_text(
    "Total moves \{game.total_moves}",
    panel_x + 22,
    panel_y + 382,
    24,
    @raylib.Color::new(212, 228, 243, 230),
  )

  @raylib.draw_text(
    "Keyboard",
    panel_x + 22,
    panel_y + 442,
    24,
    @raylib.Color::new(220, 236, 250, 240),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    panel_x + 22,
    panel_y + 472,
    22,
    @raylib.Color::new(188, 212, 232, 230),
  )
  @raylib.draw_text(
    "Undo: Z / Backspace",
    panel_x + 22,
    panel_y + 500,
    22,
    @raylib.Color::new(188, 212, 232, 230),
  )
  @raylib.draw_text(
    "Reset: R",
    panel_x + 22,
    panel_y + 528,
    22,
    @raylib.Color::new(188, 212, 232, 230),
  )
  @raylib.draw_text(
    "Next: Enter / Space",
    panel_x + 22,
    panel_y + 556,
    22,
    @raylib.Color::new(188, 212, 232, 230),
  )

  if game.message_t > 0.0 {
    @raylib.draw_rectangle(
      panel_x + 20,
      panel_y + panel_h - 78,
      panel_w - 40,
      48,
      @raylib.Color::new(42, 56, 77, 232),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 20,
      panel_y + panel_h - 78,
      panel_w - 40,
      48,
      @raylib.Color::new(148, 192, 225, 236),
    )
    @raylib.draw_text(
      game.message,
      panel_x + 34,
      panel_y + panel_h - 66,
      26,
      @raylib.Color::new(245, 250, 255, 246),
    )
  }
}

///|
fn draw_touch_overlay(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  ignore(game)

  let cx : Int = dpad_center_x()
  let cy : Int = dpad_center_y()
  let s : Int = dpad_size()

  let left_hit : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s - 18,
    cy - s / 2,
    s,
    s,
  )
  let right_hit : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx + 18,
    cy - s / 2,
    s,
    s,
  )
  let up_hit : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s / 2,
    cy - s - 18,
    s,
    s,
  )
  let down_hit : Bool = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    cx - s / 2,
    cy + 18,
    s,
    s,
  )

  let base : @raylib.Color = @raylib.Color::new(42, 54, 72, 176)
  let on : @raylib.Color = @raylib.Color::new(96, 142, 182, 226)
  let border : @raylib.Color = @raylib.Color::new(170, 210, 236, 210)

  @raylib.draw_rectangle(
    cx - s - 18,
    cy - s / 2,
    s,
    s,
    if left_hit {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx + 18,
    cy - s / 2,
    s,
    s,
    if right_hit {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx - s / 2,
    cy - s - 18,
    s,
    s,
    if up_hit {
      on
    } else {
      base
    },
  )
  @raylib.draw_rectangle(
    cx - s / 2,
    cy + 18,
    s,
    s,
    if down_hit {
      on
    } else {
      base
    },
  )

  @raylib.draw_rectangle_lines(cx - s - 18, cy - s / 2, s, s, border)
  @raylib.draw_rectangle_lines(cx + 18, cy - s / 2, s, s, border)
  @raylib.draw_rectangle_lines(cx - s / 2, cy - s - 18, s, s, border)
  @raylib.draw_rectangle_lines(cx - s / 2, cy + 18, s, s, border)

  @raylib.draw_text(
    "L",
    cx - s + 12 - 18,
    cy - 10,
    28,
    @raylib.Color::new(236, 246, 255, 250),
  )
  @raylib.draw_text(
    "R",
    cx + 18 + 20,
    cy - 10,
    28,
    @raylib.Color::new(236, 246, 255, 250),
  )
  @raylib.draw_text(
    "U",
    cx - 9,
    cy - s - 2,
    28,
    @raylib.Color::new(236, 246, 255, 250),
  )
  @raylib.draw_text(
    "D",
    cx - 10,
    cy + s + 26,
    28,
    @raylib.Color::new(236, 246, 255, 250),
  )

  let ux : Int = action_panel_x()
  let uy : Int = action_panel_y()
  let uw : Int = action_panel_w()
  let uh : Int = action_panel_h()

  @raylib.draw_rectangle(ux, uy, uw, uh, @raylib.Color::new(58, 74, 98, 178))
  @raylib.draw_rectangle_lines(ux, uy, uw, uh, border)
  @raylib.draw_text(
    "UNDO",
    ux + 22,
    uy + 22,
    28,
    @raylib.Color::new(240, 248, 255, 246),
  )

  @raylib.draw_rectangle(
    ux,
    uy + uh + 14,
    uw,
    uh,
    @raylib.Color::new(76, 64, 56, 178),
  )
  @raylib.draw_rectangle_lines(ux, uy + uh + 14, uw, uh, border)
  @raylib.draw_text(
    "RESET",
    ux + 18,
    uy + uh + 36,
    28,
    @raylib.Color::new(250, 236, 230, 246),
  )
}

///|
fn draw_title(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  ignore(game)

  @raylib.draw_text(
    "Warehouse Master 2026",
    screen_w / 2 - @raylib.measure_text("Warehouse Master 2026", 76) / 2,
    120,
    76,
    @raylib.Color::new(236, 245, 255, 248),
  )
  @raylib.draw_text(
    "Classic Sokoban reimagined with mobile controls,",
    screen_w / 2 -
    @raylib.measure_text("Classic Sokoban reimagined with mobile controls,", 34) /
    2,
    236,
    34,
    @raylib.Color::new(194, 218, 237, 238),
  )
  @raylib.draw_text(
    "undo tactics, and 12 handcrafted warehouse stages.",
    screen_w / 2 -
    @raylib.measure_text(
      "undo tactics, and 12 handcrafted warehouse stages.", 34,
    ) /
    2,
    278,
    34,
    @raylib.Color::new(194, 218, 237, 238),
  )

  let (bx, by, bw, bh) = title_start_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )

  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    if hover {
      @raylib.Color::new(106, 154, 188, 234)
    } else {
      @raylib.Color::new(72, 104, 132, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(214, 238, 255, 248),
  )

  @raylib.draw_text(
    "Start Campaign",
    bx + bw / 2 - @raylib.measure_text("Start Campaign", 44) / 2,
    by + 22,
    44,
    @raylib.Color::new(244, 250, 255, 250),
  )

  @raylib.draw_text(
    "Move crates onto all goal marks.",
    screen_w / 2 -
    @raylib.measure_text("Move crates onto all goal marks.", 30) / 2,
    418,
    30,
    @raylib.Color::new(224, 234, 245, 236),
  )
  @raylib.draw_text(
    "Don't trap crates against walls unless the tile is a goal.",
    screen_w / 2 -
    @raylib.measure_text(
      "Don't trap crates against walls unless the tile is a goal.", 30,
    ) /
    2,
    456,
    30,
    @raylib.Color::new(224, 234, 245, 236),
  )
}

///|
fn draw_level_clear_panel(
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
    @raylib.Color::new(4, 8, 14, 154),
  )

  let pw : Int = 760
  let ph : Int = 430
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(20, 28, 40, 242))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(166, 206, 236, 236),
  )

  @raylib.draw_text(
    "Level Cleared",
    px + pw / 2 - @raylib.measure_text("Level Cleared", 60) / 2,
    py + 36,
    60,
    @raylib.Color::new(245, 252, 255, 248),
  )
  @raylib.draw_text(
    "Moves: \{game.moves} (Par \{game.level_par})",
    px + 92,
    py + 140,
    34,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Pushes: \{game.pushes}",
    px + 92,
    py + 184,
    34,
    @raylib.Color::new(220, 236, 250, 242),
  )
  @raylib.draw_text(
    "Time: \{game.elapsed.to_int()}s",
    px + 92,
    py + 228,
    34,
    @raylib.Color::new(220, 236, 250, 242),
  )

  let star_line : String = if game.last_level_stars >= 3 {
    "Stars: ***"
  } else if game.last_level_stars == 2 {
    "Stars: **"
  } else {
    "Stars: *"
  }
  @raylib.draw_text(
    star_line,
    px + 92,
    py + 274,
    40,
    @raylib.Color::new(255, 220, 128, 246),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )

  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    if hover {
      @raylib.Color::new(94, 142, 176, 238)
    } else {
      @raylib.Color::new(70, 102, 130, 224)
    },
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(216, 240, 255, 246),
  )
  @raylib.draw_text(
    "Next Shift",
    bx + bw / 2 - @raylib.measure_text("Next Shift", 42) / 2,
    by + 20,
    42,
    @raylib.Color::new(244, 252, 255, 248),
  )
}

///|
fn draw_campaign_clear(
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
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 880
  let ph : Int = 520
  let px : Int = screen_w / 2 - pw / 2
  let py : Int = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(18, 25, 35, 245))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(166, 206, 236, 236),
  )

  @raylib.draw_text(
    "Campaign Complete",
    px + pw / 2 - @raylib.measure_text("Campaign Complete", 66) / 2,
    py + 34,
    66,
    @raylib.Color::new(246, 252, 255, 250),
  )
  @raylib.draw_text(
    "Total stars: \{game.campaign_stars}",
    px + 100,
    py + 152,
    42,
    @raylib.Color::new(255, 220, 124, 248),
  )
  @raylib.draw_text(
    "Total moves: \{game.total_moves}",
    px + 100,
    py + 204,
    36,
    @raylib.Color::new(222, 236, 250, 242),
  )
  @raylib.draw_text(
    "Total pushes: \{game.total_pushes}",
    px + 100,
    py + 248,
    36,
    @raylib.Color::new(222, 236, 250, 242),
  )
  @raylib.draw_text(
    "Total time: \{game.total_elapsed.to_int()}s",
    px + 100,
    py + 292,
    36,
    @raylib.Color::new(222, 236, 250, 242),
  )

  @raylib.draw_text(
    "Press Enter / Space or tap button to restart campaign",
    px + 100,
    py + 354,
    30,
    @raylib.Color::new(194, 220, 240, 232),
  )

  let (bx, by, bw, bh) = next_button_rect()
  let hover : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, bx, by, bw, bh,
  )

  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    if hover {
      @raylib.Color::new(96, 142, 178, 236)
    } else {
      @raylib.Color::new(74, 106, 136, 224)
    },
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(216, 240, 255, 246),
  )
  @raylib.draw_text(
    "Restart",
    bx + bw / 2 - @raylib.measure_text("Restart", 42) / 2,
    by + 20,
    42,
    @raylib.Color::new(246, 252, 255, 248),
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
  draw_bg(game)

  if game.state == state_title {
    draw_title(game, mouse_x, mouse_y, mouse_hold, touch_count)
    return
  }

  draw_board(game)
  draw_side_panel(game)
  draw_touch_overlay(game, mouse_x, mouse_y, mouse_hold, touch_count)

  if game.state == state_level_clear {
    draw_level_clear_panel(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_campaign_clear {
    draw_campaign_clear(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }
}
