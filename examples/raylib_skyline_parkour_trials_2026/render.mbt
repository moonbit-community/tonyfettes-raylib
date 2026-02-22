///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - tw / 2, y, size, col)
}

///|
fn draw_button(
  rect : (Float, Float, Float, Float),
  label : String,
  active : Bool,
  base : @raylib.Color,
) -> Unit {
  let fill = if active {
    @raylib.Color::new(
      clampi(base.r.to_int() + 36, 0, 255),
      clampi(base.g.to_int() + 36, 0, 255),
      clampi(base.b.to_int() + 36, 0, 255),
      240,
    )
  } else {
    @raylib.Color::new(base.r.to_int(), base.g.to_int(), base.b.to_int(), 194)
  }

  @raylib.draw_rectangle(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    fill,
  )
  @raylib.draw_rectangle_lines(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    @raylib.Color::new(220, 236, 255, 208),
  )

  let tw = @raylib.measure_text(label, 24)
  @raylib.draw_text(
    label,
    (rect.0 + rect.2 * 0.5).to_int() - tw / 2,
    (rect.1 + rect.3 * 0.5).to_int() - 12,
    24,
    @raylib.Color::new(242, 248, 255, 255),
  )
}

///|
fn camera_x(game : Game) -> Float {
  clampf(
    game.hero.x - Float::from_int(screen_w) * 0.34,
    0.0,
    maxf(0.0, game.stage_width - Float::from_int(screen_w)),
  )
}

///|
fn draw_background(game : Game, cam_x : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    col_bg_top(),
    col_bg_bottom(),
  )

  let glow_x = Float::from_int(screen_w) * 0.72 -
    cam_x * 0.06 +
    sinf(game.run_time_s * 0.3) * 56.0
  let glow_y = Float::from_int(screen_h) * 0.24 +
    cosf(game.run_time_s * 0.24) * 34.0
  @raylib.draw_circle(glow_x.to_int(), glow_y.to_int(), 132.0, col_sky_glow())

  for layer = 0; layer < 3; layer = layer + 1 {
    let depth = Float::from_int(layer + 1)
    let parallax : Float = 0.14 + depth * 0.12
    let bw = 80 + layer * 34
    for i = 0; i < 22; i = i + 1 {
      let idx = Float::from_int(i + layer * 13)
      let track = Float::from_int(screen_w) + Float::from_int(bw * 2)
      let x : Float = (
          idx * Float::from_int(bw) * 1.45 -
          cam_x * parallax +
          sinf(idx * 0.51 + Float::from_int(layer)) * 20.0
        ) %
        track -
        Float::from_int(bw)
      let h = 140 +
        (i * 31 + layer * 67) % 190 +
        (sinf(game.run_time_s * 0.35 + idx * 0.4) * 12.0).to_int()
      let y = screen_h - h - 70 + layer * 26
      let col = if layer == 0 {
        @raylib.Color::new(22, 30, 52, 240)
      } else if layer == 1 {
        @raylib.Color::new(30, 42, 68, 210)
      } else {
        @raylib.Color::new(40, 54, 88, 190)
      }
      @raylib.draw_rectangle(x.to_int(), y, bw, h, col)

      if i % 3 == 0 {
        @raylib.draw_rectangle(
          (x + Float::from_int(bw / 2 - 3)).to_int(),
          y - 16,
          6,
          16,
          @raylib.Color::new(96, 112, 150, 180),
        )
      }
    }
  }
}

///|
fn draw_world_tiles(game : Game, cam_x : Float) -> Unit {
  for i = 0; i < game.tile_count; i = i + 1 {
    let t = game.tiles[i]
    let sx = t.x - cam_x
    if sx > Float::from_int(screen_w) + 100.0 || sx + t.w < -100.0 {
      continue
    }

    if t.kind == tile_solid {
      @raylib.draw_rectangle(
        sx.to_int(),
        t.y.to_int(),
        t.w.to_int(),
        t.h.to_int(),
        col_roof(),
      )
      @raylib.draw_rectangle(
        sx.to_int(),
        t.y.to_int(),
        t.w.to_int(),
        8,
        col_roof_edge(),
      )
      @raylib.draw_rectangle_lines(
        sx.to_int(),
        t.y.to_int(),
        t.w.to_int(),
        t.h.to_int(),
        @raylib.Color::new(22, 26, 34, 210),
      )
    } else {
      let pulse : Float = 0.5 + 0.5 * sinf(game.run_time_s * 7.2 + t.x * 0.02)
      let glow = 120 + (pulse * 96.0).to_int()
      @raylib.draw_rectangle(
        sx.to_int(),
        t.y.to_int(),
        t.w.to_int(),
        t.h.to_int(),
        @raylib.Color::new(220, 46, 52, 220),
      )
      @raylib.draw_rectangle(
        sx.to_int(),
        (t.y + 2.0).to_int(),
        t.w.to_int(),
        clampi((t.h - 4.0).to_int(), 1, 2000),
        @raylib.Color::new(255, 120, 70, clampi(glow, 40, 250)),
      )
      @raylib.draw_rectangle_lines(
        sx.to_int(),
        t.y.to_int(),
        t.w.to_int(),
        t.h.to_int(),
        @raylib.Color::new(255, 220, 170, 220),
      )
    }
  }
}

///|
fn draw_checkpoints(game : Game, cam_x : Float) -> Unit {
  for i = 0; i < game.checkpoint_count; i = i + 1 {
    let cp = game.checkpoints[i]
    let sx = cp.x - cam_x
    if sx > Float::from_int(screen_w) + 80.0 || sx + cp.w < -80.0 {
      continue
    }

    if cp.taken {
      @raylib.draw_rectangle(
        sx.to_int(),
        cp.y.to_int(),
        cp.w.to_int(),
        cp.h.to_int(),
        @raylib.Color::new(96, 106, 124, 160),
      )
      continue
    }

    let pulse : Float = 0.5 +
      0.5 * sinf(game.run_time_s * 5.0 + Float::from_int(i))
    @raylib.draw_rectangle(
      sx.to_int(),
      cp.y.to_int(),
      cp.w.to_int(),
      cp.h.to_int(),
      @raylib.Color::new(44, 130, 170, 120 + (pulse * 90.0).to_int()),
    )
    @raylib.draw_rectangle_lines(
      sx.to_int(),
      cp.y.to_int(),
      cp.w.to_int(),
      cp.h.to_int(),
      col_checkpoint(),
    )
    let cap_r : Float = 9.0 + pulse * 3.0
    @raylib.draw_circle(
      (sx + cp.w * 0.5).to_int(),
      (cp.y - 14.0).to_int(),
      cap_r,
      @raylib.Color::new(96, 228, 255, 180),
    )
  }
}

///|
fn draw_goal(game : Game, cam_x : Float) -> Unit {
  let sx = game.goal_x - cam_x
  let pulse : Float = 0.5 + 0.5 * sinf(game.run_time_s * 4.0)

  @raylib.draw_rectangle(
    sx.to_int(),
    game.goal_y.to_int(),
    game.goal_w.to_int(),
    game.goal_h.to_int(),
    @raylib.Color::new(36, 96, 44, 150 + (pulse * 80.0).to_int()),
  )
  @raylib.draw_rectangle_lines(
    sx.to_int(),
    game.goal_y.to_int(),
    game.goal_w.to_int(),
    game.goal_h.to_int(),
    col_goal(),
  )
  let orb_r : Float = 12.0 + pulse * 5.0
  @raylib.draw_circle(
    (sx + game.goal_w * 0.5).to_int(),
    (game.goal_y - 18.0).to_int(),
    orb_r,
    @raylib.Color::new(160, 255, 170, 180),
  )
}

///|
fn draw_player(game : Game, cam_x : Float) -> Unit {
  let hero = game.hero
  let sx = hero.x - cam_x

  let body_col = if not(hero.on_ground) && hero.wall_window_t > 0.0 {
    col_player_wall()
  } else {
    col_player_run()
  }

  @raylib.draw_rectangle(
    sx.to_int(),
    hero.y.to_int(),
    player_w.to_int(),
    player_h.to_int(),
    body_col,
  )
  @raylib.draw_rectangle_lines(
    sx.to_int(),
    hero.y.to_int(),
    player_w.to_int(),
    player_h.to_int(),
    @raylib.Color::new(28, 22, 18, 220),
  )
  @raylib.draw_rectangle(
    (sx + 5.0).to_int(),
    (hero.y + 8.0).to_int(),
    (player_w - 10.0).to_int(),
    10,
    @raylib.Color::new(255, 244, 210, 200),
  )

  let eye_x = if hero.facing > 0 { sx + player_w - 9.0 } else { sx + 9.0 }
  @raylib.draw_circle(
    eye_x.to_int(),
    (hero.y + 21.0).to_int(),
    3.2,
    @raylib.Color::new(20, 20, 26, 240),
  )

  if absf(hero.vx) > 190.0 {
    let trail_w = clampi((absf(hero.vx) * 0.045).to_int(), 8, 24)
    let tx = if hero.facing > 0 {
      sx - Float::from_int(trail_w) - 3.0
    } else {
      sx + player_w + 3.0
    }
    @raylib.draw_rectangle(
      tx.to_int(),
      (hero.y + 18.0).to_int(),
      trail_w,
      14,
      @raylib.Color::new(255, 210, 128, 120),
    )
  }
}

///|
fn timer_string(v : Float) -> String {
  let ds = clampi((maxf(0.0, v) * 10.0).to_int(), 0, 9999)
  let sec = ds / 10
  let dec = ds % 10
  "\{sec}.\{dec}"
}

///|
fn run_string(v : Float) -> String {
  let ds = clampi((maxf(0.0, v) * 10.0).to_int(), 0, 99999)
  let sec = ds / 10
  let dec = ds % 10
  "\{sec}.\{dec}"
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(14, 12, 340, 116, @raylib.Color::new(8, 12, 18, 148))
  @raylib.draw_rectangle_lines(
    14,
    12,
    340,
    116,
    @raylib.Color::new(160, 188, 232, 180),
  )

  @raylib.draw_text(
    "TIME \{timer_string(game.timer_s)}",
    26,
    26,
    38,
    col_text_main(),
  )
  @raylib.draw_text(
    "STAGE \{game.stage}/\{stage_count}",
    28,
    74,
    24,
    col_text_dim(),
  )
  @raylib.draw_text(
    "CHECKPOINTS \{game.checkpoints_hit}",
    184,
    76,
    22,
    @raylib.Color::new(132, 232, 255, 235),
  )

  @raylib.draw_rectangle(
    screen_w - 252,
    12,
    238,
    74,
    @raylib.Color::new(8, 12, 18, 136),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 252,
    12,
    238,
    74,
    @raylib.Color::new(160, 188, 232, 170),
  )
  @raylib.draw_text(
    "RUN \{run_string(game.run_time_s)} s",
    screen_w - 238,
    26,
    26,
    col_text_main(),
  )
  @raylib.draw_text("R: restart run", screen_w - 236, 56, 20, col_text_dim())

  if game.state == state_play {
    @raylib.draw_text(
      "A/D or Arrow: move   SPACE: jump   SHIFT: wall climb",
      22,
      screen_h - 30,
      20,
      @raylib.Color::new(198, 214, 238, 200),
    )
  }

  if game.bonus_popup_t > 0.0 {
    let alpha = clampi((game.bonus_popup_t * 255.0).to_int(), 0, 255)
    @raylib.draw_text(
      "+\{game.bonus_popup_value}s",
      28,
      122,
      30,
      @raylib.Color::new(118, 255, 186, alpha),
    )
  }
}

///|
fn draw_play_touch_controls(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let left = touch_left_rect()
  let right = touch_right_rect()
  let jump = touch_jump_rect()
  let climb = touch_climb_rect()
  let restart = touch_play_restart_rect()

  let left_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let right_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let jump_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    jump.0,
    jump.1,
    jump.2,
    jump.3,
  )
  let climb_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    climb.0,
    climb.1,
    climb.2,
    climb.3,
  )
  let restart_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart.0,
    restart.1,
    restart.2,
    restart.3,
  )

  draw_button(left, "<", left_on, @raylib.Color::new(44, 84, 144, 220))
  draw_button(right, ">", right_on, @raylib.Color::new(44, 84, 144, 220))
  draw_button(jump, "JUMP", jump_on, @raylib.Color::new(110, 132, 54, 220))
  draw_button(climb, "CLIMB", climb_on, @raylib.Color::new(116, 72, 44, 220))
  draw_button(
    restart,
    "RESTART",
    restart_on,
    @raylib.Color::new(82, 54, 54, 220),
  )
}

///|
fn draw_title_overlay(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 16, 132),
  )
  draw_center_text("SKYLINE PARKOUR TRIALS", 110, 62, col_text_main())
  draw_center_text(
    "Momentum rooftops. Wall windows. Beat the clock.",
    188,
    28,
    col_text_dim(),
  )

  let start = title_start_rect()
  let start_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start.0,
    start.1,
    start.2,
    start.3,
  )
  draw_button(
    start,
    "START RUN",
    start_on,
    @raylib.Color::new(42, 106, 88, 220),
  )

  draw_center_text("Desktop", 560, 26, col_text_main())
  draw_center_text(
    "A / D move   SPACE jump   SHIFT climb",
    596,
    24,
    col_text_dim(),
  )
  draw_center_text("Mobile", 634, 26, col_text_main())
  draw_center_text(
    "Left/Right + Jump/Climb touch buttons",
    668,
    24,
    col_text_dim(),
  )
}

///|
fn draw_panel(title : String, subtitle : String) -> Unit {
  let pw = 760
  let ph = 340
  let px = screen_w / 2 - pw / 2
  let py = screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(10, 14, 24, 228))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(156, 188, 244, 210),
  )
  draw_center_text(title, py + 34, 54, col_text_main())
  draw_center_text(subtitle, py + 108, 28, col_text_dim())
}

///|
fn lose_reason_text(reason : Int) -> String {
  if reason == lose_time {
    "Out of time"
  } else if reason == lose_fall {
    "Missed the skyline"
  } else if reason == lose_hazard {
    "Hit a hazard"
  } else {
    "Run failed"
  }
}

///|
fn draw_stage_clear_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_panel(
    "STAGE \{game.stage} CLEAR",
    "Carry momentum into Stage \{game.pending_next_stage}",
  )

  draw_center_text(
    "Time left: \{timer_string(game.timer_s)} s",
    screen_h / 2 - 8,
    32,
    @raylib.Color::new(146, 255, 172, 255),
  )

  let next_rect = panel_next_rect()
  let restart_rect = panel_restart_rect()
  let next_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let restart_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  draw_button(next_rect, "NEXT", next_on, @raylib.Color::new(46, 108, 78, 220))
  draw_button(
    restart_rect,
    "RESTART RUN",
    restart_on,
    @raylib.Color::new(92, 64, 64, 220),
  )
}

///|
fn draw_game_over_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_panel("RUN FAILED", lose_reason_text(game.lose_reason))
  draw_center_text(
    "Reached stage \{game.stage}  |  Run \{run_string(game.run_time_s)} s",
    screen_h / 2 - 8,
    30,
    @raylib.Color::new(255, 186, 166, 255),
  )

  let retry_rect = panel_next_rect()
  let restart_rect = panel_restart_rect()
  let retry_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    retry_rect.0,
    retry_rect.1,
    retry_rect.2,
    retry_rect.3,
  )
  let restart_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  draw_button(
    retry_rect,
    "RETRY",
    retry_on,
    @raylib.Color::new(86, 86, 120, 220),
  )
  draw_button(
    restart_rect,
    "FULL RESTART",
    restart_on,
    @raylib.Color::new(96, 62, 62, 220),
  )
}

///|
fn draw_victory_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_panel("TRIALS COMPLETE", "Skyline route mastered")
  draw_center_text(
    "Final run: \{run_string(game.run_time_s)} s   |   Time left: \{timer_string(game.timer_s)} s",
    screen_h / 2 - 12,
    30,
    @raylib.Color::new(150, 255, 182, 255),
  )
  draw_center_text(
    "Checkpoints hit: \{game.checkpoints_hit}",
    screen_h / 2 + 28,
    28,
    @raylib.Color::new(190, 232, 255, 255),
  )

  let next_rect = panel_next_rect()
  let restart_rect = panel_restart_rect()
  let next_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let restart_on = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  draw_button(
    next_rect,
    "PLAY AGAIN",
    next_on,
    @raylib.Color::new(52, 112, 82, 220),
  )
  draw_button(
    restart_rect,
    "TITLE",
    restart_on,
    @raylib.Color::new(72, 72, 98, 220),
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
  let cam_x = camera_x(game)

  draw_background(game, cam_x)
  draw_world_tiles(game, cam_x)
  draw_checkpoints(game, cam_x)
  draw_goal(game, cam_x)
  draw_player(game, cam_x)
  draw_hud(game)

  if game.state == state_title {
    draw_title_overlay(mx, my, hold, touch_count)
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_game_over {
    draw_game_over_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_victory {
    draw_victory_overlay(game, mx, my, hold, touch_count)
  }

  if game.touch_mode && game.state == state_play {
    draw_play_touch_controls(mx, my, hold, touch_count)
  }
}
