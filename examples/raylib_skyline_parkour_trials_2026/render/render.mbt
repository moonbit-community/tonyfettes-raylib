///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, @types.screen_w / 2 - tw / 2, y, size, col)
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
      @types.clampi(base.r.to_int() + 36, 0, 255),
      @types.clampi(base.g.to_int() + 36, 0, 255),
      @types.clampi(base.b.to_int() + 36, 0, 255),
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
fn camera_x(game : @types.Game) -> Float {
  @types.clampf(
    game.hero.x - Float::from_int(@types.screen_w) * 0.34,
    0.0,
    @types.maxf(0.0, game.stage_width - Float::from_int(@types.screen_w)),
  )
}

///|
fn draw_background(game : @types.Game, cam_x : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @types.col_bg_top(),
    @types.col_bg_bottom(),
  )

  let glow_x = Float::from_int(@types.screen_w) * 0.72 -
    cam_x * 0.06 +
    @types.sinf(game.run_time_s * 0.3) * 56.0
  let glow_y = Float::from_int(@types.screen_h) * 0.24 +
    @types.cosf(game.run_time_s * 0.24) * 34.0
  @raylib.draw_circle(
    glow_x.to_int(),
    glow_y.to_int(),
    132.0,
    @types.col_sky_glow(),
  )

  for layer in 0..<3 {
    let depth = Float::from_int(layer + 1)
    let parallax : Float = 0.14 + depth * 0.12
    let bw = 80 + layer * 34
    for i in 0..<22 {
      let idx = Float::from_int(i + layer * 13)
      let track = Float::from_int(@types.screen_w) + Float::from_int(bw * 2)
      let x : Float = (
          idx * Float::from_int(bw) * 1.45 -
          cam_x * parallax +
          @types.sinf(idx * 0.51 + Float::from_int(layer)) * 20.0
        ) %
        track -
        Float::from_int(bw)
      let h = 140 +
        (i * 31 + layer * 67) % 190 +
        (@types.sinf(game.run_time_s * 0.35 + idx * 0.4) * 12.0).to_int()
      let y = @types.screen_h - h - 70 + layer * 26
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
fn draw_world_tiles(game : @types.Game, cam_x : Float) -> Unit {
  for i in 0..<game.tile_count {
    let t = game.tiles[i]
    let sx = t.x - cam_x
    if sx > Float::from_int(@types.screen_w) + 100.0 || sx + t.w < -100.0 {
      continue
    }

    match t.kind {
      @types.TileKind::Solid => {
        @raylib.draw_rectangle(
          sx.to_int(),
          t.y.to_int(),
          t.w.to_int(),
          t.h.to_int(),
          @types.col_roof(),
        )
        @raylib.draw_rectangle(
          sx.to_int(),
          t.y.to_int(),
          t.w.to_int(),
          8,
          @types.col_roof_edge(),
        )
        @raylib.draw_rectangle_lines(
          sx.to_int(),
          t.y.to_int(),
          t.w.to_int(),
          t.h.to_int(),
          @raylib.Color::new(22, 26, 34, 210),
        )
      }
      @types.TileKind::Hazard => {
        let pulse : Float = 0.5 +
          0.5 * @types.sinf(game.run_time_s * 7.2 + t.x * 0.02)
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
          @types.clampi((t.h - 4.0).to_int(), 1, 2000),
          @raylib.Color::new(255, 120, 70, @types.clampi(glow, 40, 250)),
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
}

///|
fn draw_checkpoints(game : @types.Game, cam_x : Float) -> Unit {
  for i in 0..<game.checkpoint_count {
    let cp = game.checkpoints[i]
    let sx = cp.x - cam_x
    if sx > Float::from_int(@types.screen_w) + 80.0 || sx + cp.w < -80.0 {
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
      0.5 * @types.sinf(game.run_time_s * 5.0 + Float::from_int(i))
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
      @types.col_checkpoint(),
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
fn draw_goal(game : @types.Game, cam_x : Float) -> Unit {
  let sx = game.goal_x - cam_x
  let pulse : Float = 0.5 + 0.5 * @types.sinf(game.run_time_s * 4.0)

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
    @types.col_goal(),
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
fn draw_player(game : @types.Game, cam_x : Float) -> Unit {
  let hero = game.hero
  let sx = hero.x - cam_x

  let body_col = if not(hero.on_ground) && hero.wall_window_t > 0.0 {
    @types.col_player_wall()
  } else {
    @types.col_player_run()
  }

  @raylib.draw_rectangle(
    sx.to_int(),
    hero.y.to_int(),
    @types.player_w.to_int(),
    @types.player_h.to_int(),
    body_col,
  )
  @raylib.draw_rectangle_lines(
    sx.to_int(),
    hero.y.to_int(),
    @types.player_w.to_int(),
    @types.player_h.to_int(),
    @raylib.Color::new(28, 22, 18, 220),
  )
  @raylib.draw_rectangle(
    (sx + 5.0).to_int(),
    (hero.y + 8.0).to_int(),
    (@types.player_w - 10.0).to_int(),
    10,
    @raylib.Color::new(255, 244, 210, 200),
  )

  let eye_x = if hero.facing > 0 {
    sx + @types.player_w - 9.0
  } else {
    sx + 9.0
  }
  @raylib.draw_circle(
    eye_x.to_int(),
    (hero.y + 21.0).to_int(),
    3.2,
    @raylib.Color::new(20, 20, 26, 240),
  )

  if @types.absf(hero.vx) > 190.0 {
    let trail_w = @types.clampi((@types.absf(hero.vx) * 0.045).to_int(), 8, 24)
    let tx = if hero.facing > 0 {
      sx - Float::from_int(trail_w) - 3.0
    } else {
      sx + @types.player_w + 3.0
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
fn draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(14, 12, 340, 116, @raylib.Color::new(8, 12, 18, 148))
  @raylib.draw_rectangle_lines(
    14,
    12,
    340,
    116,
    @raylib.Color::new(160, 188, 232, 180),
  )

  @raylib.draw_text(
    "TIME \{@types.timer_string(game.timer_s)}",
    26,
    26,
    38,
    @types.col_text_main(),
  )
  @raylib.draw_text(
    "STAGE \{game.stage}/\{@types.stage_count}",
    28,
    74,
    24,
    @types.col_text_dim(),
  )
  @raylib.draw_text(
    "CHECKPOINTS \{game.checkpoints_hit}",
    184,
    76,
    22,
    @raylib.Color::new(132, 232, 255, 235),
  )

  @raylib.draw_rectangle(
    @types.screen_w - 252,
    12,
    238,
    74,
    @raylib.Color::new(8, 12, 18, 136),
  )
  @raylib.draw_rectangle_lines(
    @types.screen_w - 252,
    12,
    238,
    74,
    @raylib.Color::new(160, 188, 232, 170),
  )
  @raylib.draw_text(
    "RUN \{@types.run_string(game.run_time_s)} s",
    @types.screen_w - 238,
    26,
    26,
    @types.col_text_main(),
  )
  @raylib.draw_text(
    "R: restart run",
    @types.screen_w - 236,
    56,
    20,
    @types.col_text_dim(),
  )

  if game.state == @types.GameState::Play {
    @raylib.draw_text(
      "A/D or Arrow: move   SPACE: jump   SHIFT: wall climb",
      22,
      @types.screen_h - 30,
      20,
      @raylib.Color::new(198, 214, 238, 200),
    )
  }

  if game.bonus_popup_t > 0.0 {
    let alpha = @types.clampi((game.bonus_popup_t * 255.0).to_int(), 0, 255)
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
fn draw_play_touch_controls(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let left = @types.touch_left_rect()
  let right = @types.touch_right_rect()
  let jump = @types.touch_jump_rect()
  let climb = @types.touch_climb_rect()
  let restart = @types.touch_play_restart_rect()

  let left_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let right_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let jump_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    jump.0,
    jump.1,
    jump.2,
    jump.3,
  )
  let climb_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    climb.0,
    climb.1,
    climb.2,
    climb.3,
  )
  let restart_on = @types.pointer_on_rect(
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
fn draw_title_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(4, 8, 16, 132),
  )
  draw_center_text("SKYLINE PARKOUR TRIALS", 110, 62, @types.col_text_main())
  draw_center_text(
    "Momentum rooftops. Wall windows. Beat the clock.",
    188,
    28,
    @types.col_text_dim(),
  )

  let start = @types.title_start_rect()
  let start_on = @types.pointer_on_rect(
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

  draw_center_text("Desktop", 560, 26, @types.col_text_main())
  draw_center_text(
    "A / D move   SPACE jump   SHIFT climb",
    596,
    24,
    @types.col_text_dim(),
  )
  draw_center_text("Mobile", 634, 26, @types.col_text_main())
  draw_center_text(
    "Left/Right + Jump/Climb touch buttons",
    668,
    24,
    @types.col_text_dim(),
  )
}

///|
fn draw_panel(title : String, subtitle : String) -> Unit {
  let pw = 760
  let ph = 340
  let px = @types.screen_w / 2 - pw / 2
  let py = @types.screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(10, 14, 24, 228))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(156, 188, 244, 210),
  )
  draw_center_text(title, py + 34, 54, @types.col_text_main())
  draw_center_text(subtitle, py + 108, 28, @types.col_text_dim())
}

///|
fn lose_reason_text(reason : @types.LoseReason) -> String {
  match reason {
    @types.LoseReason::Time => "Out of time"
    @types.LoseReason::Fall => "Missed the skyline"
    @types.LoseReason::HitHazard => "Hit a hazard"
    @types.LoseReason::None => "Run failed"
  }
}

///|
fn draw_stage_clear_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  draw_panel(
    "STAGE \{game.stage} CLEAR",
    "Carry momentum into Stage \{game.pending_next_stage}",
  )

  draw_center_text(
    "Time left: \{@types.timer_string(game.timer_s)} s",
    @types.screen_h / 2 - 8,
    32,
    @raylib.Color::new(146, 255, 172, 255),
  )

  let next_rect = @types.panel_next_rect()
  let restart_rect = @types.panel_restart_rect()
  let next_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let restart_on = @types.pointer_on_rect(
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
fn draw_game_over_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  draw_panel("RUN FAILED", lose_reason_text(game.lose_reason))
  draw_center_text(
    "Reached stage \{game.stage}  |  Run \{@types.run_string(game.run_time_s)} s",
    @types.screen_h / 2 - 8,
    30,
    @raylib.Color::new(255, 186, 166, 255),
  )

  let retry_rect = @types.panel_next_rect()
  let restart_rect = @types.panel_restart_rect()
  let retry_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    retry_rect.0,
    retry_rect.1,
    retry_rect.2,
    retry_rect.3,
  )
  let restart_on = @types.pointer_on_rect(
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
fn draw_victory_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  draw_panel("TRIALS COMPLETE", "Skyline route mastered")
  draw_center_text(
    "Final run: \{@types.run_string(game.run_time_s)} s   |   Time left: \{@types.timer_string(game.timer_s)} s",
    @types.screen_h / 2 - 12,
    30,
    @raylib.Color::new(150, 255, 182, 255),
  )
  draw_center_text(
    "Checkpoints hit: \{game.checkpoints_hit}",
    @types.screen_h / 2 + 28,
    28,
    @raylib.Color::new(190, 232, 255, 255),
  )

  let next_rect = @types.panel_next_rect()
  let restart_rect = @types.panel_restart_rect()
  let next_on = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let restart_on = @types.pointer_on_rect(
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
pub fn draw_frame(game : @types.Game) -> Unit {
  let cam_x = camera_x(game)

  draw_background(game, cam_x)
  draw_world_tiles(game, cam_x)
  draw_checkpoints(game, cam_x)
  draw_goal(game, cam_x)
  draw_player(game, cam_x)
  draw_hud(game)

  match game.state {
    @types.GameState::Title => draw_title_overlay(game)
    @types.GameState::StageClear => draw_stage_clear_overlay(game)
    @types.GameState::GameOver => draw_game_over_overlay(game)
    @types.GameState::Victory => draw_victory_overlay(game)
    @types.GameState::Play => ()
  }

  if game.touch_mode && game.state == @types.GameState::Play {
    draw_play_touch_controls(game)
  }
}
