///|
fn bg_wave(game : @types.Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
fn draw_bg(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

  let w0 : Float = bg_wave(game, 0.66)
  let w1 : Float = bg_wave(game, 0.92)

  @raylib.draw_circle(
    250,
    164,
    230.0 + w0 * 18.0,
    @raylib.Color::new(24, 48, 88, 44),
  )
  @raylib.draw_circle(
    @types.screen_w - 280,
    182,
    208.0 - w1 * 16.0,
    @raylib.Color::new(68, 38, 66, 34),
  )

  for i in 0..<14 {
    let y : Int = i * 74
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      52,
      @raylib.Color::new(
        12 + i * 7 % 20,
        16 + i * 9 % 20,
        26 + i * 10 % 24,
        14 + i * 8 % 28,
      ),
    )
  }
}

///|
fn draw_board_back(game : @types.Game, bx : Int, by : Int, tile : Int) -> Unit {
  let bw : Int = @types.grid_w * tile
  let bh : Int = @types.grid_h * tile

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
    @raylib.Color::new(154, 194, 226, 220),
  )

  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(22, 34, 52, 236))

  if game.shake_t > 0.0 {
    @raylib.draw_rectangle_lines(
      bx - 22,
      by - 22,
      bw + 44,
      bh + 44,
      @raylib.Color::new(250, 154, 116, 230),
    )
  }
}

///|
fn draw_grid_lines(bx : Int, by : Int, tile : Int) -> Unit {
  let bw : Int = @types.grid_w * tile
  let bh : Int = @types.grid_h * tile

  for x in 0..=@types.grid_w {
    let px : Int = bx + x * tile
    @raylib.draw_line(px, by, px, by + bh, @raylib.Color::new(76, 106, 136, 98))
  }

  for y in 0..=@types.grid_h {
    let py : Int = by + y * tile
    @raylib.draw_line(bx, py, bx + bw, py, @raylib.Color::new(76, 106, 136, 98))
  }
}

///|
fn draw_food(game : @types.Game, bx : Int, by : Int, tile : Int) -> Unit {
  let cx : Int = bx + game.food_x * tile + tile / 2
  let cy : Int = by + game.food_y * tile + tile / 2
  let r : Float = Float::from_int(tile) * 0.33

  if game.food_kind == @types.food_gold {
    @raylib.draw_circle(cx, cy, r, @raylib.Color::new(255, 218, 122, 252))
    @raylib.draw_circle_lines(cx, cy, r, @raylib.Color::new(255, 242, 196, 238))
    @raylib.draw_circle(
      cx - 4,
      cy - 4,
      r * 0.34,
      @raylib.Color::new(255, 254, 236, 176),
    )
  } else {
    @raylib.draw_circle(cx, cy, r, @raylib.Color::new(130, 208, 255, 252))
    @raylib.draw_circle_lines(cx, cy, r, @raylib.Color::new(220, 240, 255, 236))
    @raylib.draw_circle(
      cx - 4,
      cy - 4,
      r * 0.34,
      @raylib.Color::new(255, 255, 255, 160),
    )
  }
}

///|
fn draw_trap(game : @types.Game, bx : Int, by : Int, tile : Int) -> Unit {
  if not(game.trap_active) {
    return
  }

  let cx : Int = bx + game.trap_x * tile + tile / 2
  let cy : Int = by + game.trap_y * tile + tile / 2

  let pulse : Float = Float::from_double(
    @math.sin((game.trap_flash * 8.0).to_double()),
  )
  let r : Float = Float::from_int(tile) * (0.28 + pulse * 0.03)

  @raylib.draw_circle(cx, cy, r, @raylib.Color::new(236, 92, 96, 244))
  @raylib.draw_circle_lines(
    cx,
    cy,
    r + 3.0,
    @raylib.Color::new(255, 194, 186, 214),
  )

  @raylib.draw_line(
    cx - tile / 3,
    cy,
    cx + tile / 3,
    cy,
    @raylib.Color::new(255, 238, 220, 206),
  )
  @raylib.draw_line(
    cx,
    cy - tile / 3,
    cx,
    cy + tile / 3,
    @raylib.Color::new(255, 238, 220, 206),
  )
}

///|
fn player_segment_color(i : Int) -> @raylib.Color {
  if i == 0 {
    @raylib.Color::new(94, 226, 158, 252)
  } else {
    @raylib.Color::new(58, 166, 116, 246)
  }
}

///|
fn rival_segment_color(kind : Int, head : Bool) -> @raylib.Color {
  if kind % 2 == 0 {
    if head {
      @raylib.Color::new(236, 134, 124, 252)
    } else {
      @raylib.Color::new(166, 92, 90, 246)
    }
  } else if head {
    @raylib.Color::new(150, 154, 255, 252)
  } else {
    @raylib.Color::new(108, 114, 194, 246)
  }
}

///|
fn draw_player(game : @types.Game, bx : Int, by : Int, tile : Int) -> Unit {
  for i = game.p_len - 1; i >= 0; i = i - 1 {
    let x : Int = bx + game.p_seg_x[i] * tile
    let y : Int = by + game.p_seg_y[i] * tile

    @raylib.draw_rectangle(
      x + 3,
      y + 3,
      tile - 6,
      tile - 6,
      player_segment_color(i),
    )

    if i == 0 {
      @raylib.draw_rectangle_lines(
        x + 3,
        y + 3,
        tile - 6,
        tile - 6,
        @raylib.Color::new(224, 255, 236, 236),
      )

      let ex0 : Int = x + tile / 2 - 7
      let ex1 : Int = x + tile / 2 + 3
      let ey : Int = y + tile / 2 - 3
      @raylib.draw_rectangle(ex0, ey, 4, 4, @raylib.Color::new(14, 24, 18, 228))
      @raylib.draw_rectangle(ex1, ey, 4, 4, @raylib.Color::new(14, 24, 18, 228))
    }
  }
}

///|
fn draw_rival(
  game : @types.Game,
  rid : Int,
  bx : Int,
  by : Int,
  tile : Int,
) -> Unit {
  let rival = game.rivals[rid]
  if not(rival.alive) {
    return
  }

  for i = rival.len - 1; i >= 0; i = i - 1 {
    let x : Int = bx + rival.seg_x[i] * tile
    let y : Int = by + rival.seg_y[i] * tile

    @raylib.draw_rectangle(
      x + 3,
      y + 3,
      tile - 6,
      tile - 6,
      rival_segment_color(rival.color_kind, i == 0),
    )

    if i == 0 {
      @raylib.draw_rectangle_lines(
        x + 3,
        y + 3,
        tile - 6,
        tile - 6,
        @raylib.Color::new(236, 228, 255, 216),
      )
      let ex0 : Int = x + tile / 2 - 7
      let ex1 : Int = x + tile / 2 + 3
      let ey : Int = y + tile / 2 - 3
      @raylib.draw_rectangle(
        ex0, ey, 4, 4, @raylib.Color::new(22, 20, 28, 220),
      )
      @raylib.draw_rectangle(
        ex1, ey, 4, 4, @raylib.Color::new(22, 20, 28, 220),
      )
    }
  }
}

///|
fn draw_hint(game : @types.Game, bx : Int, by : Int, tile : Int) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let x : Int = bx + game.hint_x * tile + tile / 2
  let y : Int = by + game.hint_y * tile + tile / 2

  let pulse : Float = Float::from_double(
    @math.sin((game.ui_t * 8.0).to_double()),
  )
  let r : Float = Float::from_int(tile) * (0.42 + pulse * 0.06)

  @raylib.draw_circle_lines(x, y, r, @raylib.Color::new(255, 232, 132, 244))
}

///|
fn draw_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    let a : Int = if spark.life > 0.7 {
      236
    } else if spark.life > 0.4 {
      190
    } else {
      128
    }

    let c : @raylib.Color = if spark.kind == 2 {
      @raylib.Color::new(255, 164, 122, a)
    } else if spark.kind == 1 {
      @raylib.Color::new(255, 228, 140, a)
    } else {
      @raylib.Color::new(140, 220, 174, a)
    }

    @raylib.draw_circle(spark.x.to_int(), spark.y.to_int(), 1.0 + spark.size, c)
  }
}

///|
fn draw_touch_button(
  label : String,
  rect : (Int, Int, Int, Int),
  active : Bool,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if active {
      tint
    } else {
      @raylib.Color::new(44, 62, 88, 204)
    },
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(182, 214, 240, 218),
  )

  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - @raylib.measure_text(label, 30) / 2,
    rect.1 + rect.3 / 2 - 15,
    30,
    @raylib.Color::new(246, 252, 255, 248),
  )
}

///|
fn draw_controls(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  let left = @types.btn_left()
  let right = @types.btn_right()
  let up = @types.btn_up()
  let down = @types.btn_down()
  let boost = @types.btn_boost()
  let restart = @types.btn_restart()
  let hint = @types.btn_hint()

  let l_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, left.0, left.1, left.2, left.3,
  )
  let r_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, right.0, right.1, right.2, right.3,
  )
  let u_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, up.0, up.1, up.2, up.3,
  )
  let d_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, down.0, down.1, down.2, down.3,
  )
  let b_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, boost.0, boost.1, boost.2, boost.3,
  )
  let rs_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, restart.0, restart.1, restart.2, restart.3,
  )
  let h_on : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, hint.0, hint.1, hint.2, hint.3,
  )

  draw_touch_button("L", left, l_on, @raylib.Color::new(86, 138, 194, 228))
  draw_touch_button("R", right, r_on, @raylib.Color::new(86, 138, 194, 228))
  draw_touch_button("U", up, u_on, @raylib.Color::new(86, 138, 194, 228))
  draw_touch_button("D", down, d_on, @raylib.Color::new(86, 138, 194, 228))

  draw_touch_button(
    if game.boost_meter > 0.08 {
      "BOOST"
    } else {
      "BOOST 0"
    },
    boost,
    b_on || game.boost_on,
    @raylib.Color::new(194, 140, 92, 228),
  )

  draw_touch_button(
    "RESTART",
    restart,
    rs_on,
    @raylib.Color::new(134, 96, 104, 228),
  )
  draw_touch_button(
    "HINT \{game.hint_left}",
    hint,
    h_on,
    @raylib.Color::new(166, 132, 82, 228),
  )
}

///|
fn draw_panel(game : @types.Game) -> Unit {
  let px : Int = @types.panel_x0
  let py : Int = 20
  let pw : Int = @types.panel_w
  let ph : Int = @types.screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(14, 22, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(124, 168, 204, 220),
  )

  @raylib.draw_text(
    "Snake Battle Arena",
    px + 20,
    py + 20,
    42,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "Neon Circuit 2026",
    px + 20,
    py + 66,
    28,
    @raylib.Color::new(196, 220, 246, 238),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 110,
    36,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    px + 260,
    py + 110,
    34,
    @raylib.Color::new(206, 228, 248, 240),
  )

  @raylib.draw_text(
    "Lives \{game.lives}",
    px + 20,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Kills \{game.total_kills}",
    px + 190,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @raylib.draw_text(
    "Time \{(@types.match_time_limit - game.game_t).to_int()}s",
    px + 320,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @raylib.draw_text(
    "Combo x\{game.combo}",
    px + 20,
    py + 194,
    30,
    if game.combo > 1 {
      @raylib.Color::new(255, 220, 134, 248)
    } else {
      @raylib.Color::new(212, 232, 252, 242)
    },
  )

  @raylib.draw_text(
    "Boost",
    px + 20,
    py + 236,
    30,
    @raylib.Color::new(220, 236, 252, 242),
  )

  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(30, 42, 60, 220),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    ((pw - 40).to_double() * game.boost_meter.to_double()).to_int(),
    30,
    @raylib.Color::new(94, 164, 220, 236),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(184, 214, 236, 230),
  )

  let food_name : String = if game.food_kind == @types.food_gold {
    "Gold"
  } else {
    "Normal"
  }
  @raylib.draw_text(
    "Food: \{food_name}",
    px + 20,
    py + 316,
    28,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @raylib.draw_text(
    "Controls",
    px + 20,
    py + 364,
    28,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    px + 20,
    py + 396,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Boost: Shift/J",
    px + 20,
    py + 422,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Hint: H   Restart: R",
    px + 20,
    py + 448,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @raylib.draw_text(
    "Goal: outscore rivals before timer",
    px + 20,
    py + 474,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )

  @raylib.draw_text(
    "Rival A \{game.rivals[0].score}",
    px + 20,
    py + 524,
    30,
    @raylib.Color::new(236, 160, 156, 242),
  )
  if game.rivals.length() > 1 {
    @raylib.draw_text(
      "Rival B \{game.rivals[1].score}",
      px + 220,
      py + 524,
      30,
      @raylib.Color::new(170, 174, 255, 242),
    )
  }

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + 564,
      pw - 40,
      56,
      @raylib.Color::new(40, 58, 82, 224),
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
fn draw_title(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  @raylib.draw_text(
    "Snake Battle Arena 2026",
    @types.screen_w / 2 -
    @raylib.measure_text("Snake Battle Arena 2026", 86) /
    2,
    110,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @raylib.draw_text(
    "Fast snake duels with AI rivals, traps, combo scoring, and boost management.",
    @types.screen_w / 2 -
    @raylib.measure_text(
      "Fast snake duels with AI rivals, traps, combo scoring, and boost management.",
      34,
    ) /
    2,
    250,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )
  @raylib.draw_text(
    "Touch controls are available for mobile web play.",
    @types.screen_w / 2 -
    @raylib.measure_text(
      "Touch controls are available for mobile web play.", 34,
    ) /
    2,
    292,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let b = @types.start_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, b.0, b.1, b.2, b.3,
  )

  draw_touch_button(
    "Start Arena",
    b,
    hov,
    @raylib.Color::new(92, 150, 206, 230),
  )
}

///|
fn draw_result_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 840
  let ph : Int = 490
  let px : Int = @types.screen_w / 2 - pw / 2
  let py : Int = @types.screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 24, 36, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(172, 206, 236, 236),
  )

  let title : String = if game.win { "Victory" } else { "Defeat" }

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
    44,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @raylib.draw_text(
    "Rivals \{rival_total_score(game)}",
    px + 100,
    py + 182,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Kills \{game.total_kills}   Lives \{game.lives}",
    px + 100,
    py + 228,
    36,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @raylib.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 100,
    py + 272,
    34,
    @raylib.Color::new(206, 228, 248, 238),
  )

  let b = @types.retry_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, b.0, b.1, b.2, b.3,
  )

  draw_touch_button(
    "Play Again", b, hov, @raylib.Color::new(96, 154, 210, 230),
  )
}

///|
fn rival_total_score(game : @types.Game) -> Int {
  let mut s : Int = 0
  for rival in game.rivals {
    s = s + rival.score
  }
  s
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_bg(game)

  if game.state == @types.state_title {
    draw_title(game)
    return
  }

  let (bx, by, tile) = @types.board_metrics(game.shake_t)

  draw_board_back(game, bx, by, tile)
  draw_grid_lines(bx, by, tile)
  draw_food(game, bx, by, tile)
  draw_trap(game, bx, by, tile)

  for rid in 0..<game.rivals.length() {
    draw_rival(game, rid, bx, by, tile)
  }
  draw_player(game, bx, by, tile)
  draw_hint(game, bx, by, tile)

  draw_sparks(game)
  draw_panel(game)
  draw_controls(game)

  if game.state == @types.state_result {
    draw_result_overlay(game)
  }
}
