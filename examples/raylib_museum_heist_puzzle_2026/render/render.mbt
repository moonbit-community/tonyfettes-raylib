///|
fn draw_centered_text(
  text : String,
  center_x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, center_x - tw / 2, y, size, color)
}

///|
fn draw_background(game : @types.Game) -> Unit {
  let pulse = Float::from_double(@math.sin((game.pulse_t * 1.2).to_double()))

  @raylib.clear_background(@raylib.Color::new(10, 12, 18, 255))

  for i in 0..<16 {
    let band_y = i * 56 - 10
    let alpha = 18 + i * 9 % 22
    @raylib.draw_rectangle(
      0,
      band_y,
      @types.screen_w,
      42,
      @raylib.Color::new(
        18 + i * 3 % 18,
        24 + i * 4 % 18,
        34 + i * 5 % 24,
        alpha,
      ),
    )
  }

  @raylib.draw_circle(
    240,
    160,
    170.0 + pulse * 14.0,
    @raylib.Color::new(34, 50, 82, 40),
  )
  @raylib.draw_circle(
    @types.screen_w - 210,
    210,
    190.0 - pulse * 10.0,
    @raylib.Color::new(86, 46, 28, 26),
  )
}

///|
fn draw_board_tiles(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.board_origin_x - 12,
    @types.board_origin_y - 12,
    @types.board_cols * @types.tile_size + 24,
    @types.board_rows * @types.tile_size + 24,
    @raylib.Color::new(8, 10, 15, 230),
  )
  @raylib.draw_rectangle_lines(
    @types.board_origin_x - 12,
    @types.board_origin_y - 12,
    @types.board_cols * @types.tile_size + 24,
    @types.board_rows * @types.tile_size + 24,
    @raylib.Color::new(108, 132, 154, 180),
  )

  for y in 0..<@types.board_rows {
    for x in 0..<@types.board_cols {
      let px = @types.cell_px(x)
      let py = @types.cell_py(y)
      let t = @types.tile_at(game, x, y)

      if t == @types.tile_wall {
        @raylib.draw_rectangle(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(60, 66, 80, 255),
        )
        @raylib.draw_rectangle(
          px + 3,
          py + 3,
          @types.tile_size - 6,
          @types.tile_size - 6,
          @raylib.Color::new(90, 100, 116, 255),
        )
        @raylib.draw_rectangle_lines(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(144, 158, 178, 170),
        )
      } else {
        let c = if (x + y) % 2 == 0 {
          @raylib.Color::new(24, 30, 42, 255)
        } else {
          @raylib.Color::new(20, 26, 38, 255)
        }
        @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, c)
      }
    }
  }
}

///|
fn draw_guard_fov(game : @types.Game) -> Unit {
  for g in game.guards {
    for y in 0..<@types.board_rows {
      for x in 0..<@types.board_cols {
        if @types.tile_at(game, x, y) == @types.tile_wall {
          continue
        }
        if @types.guard_sees_cell(game, g, x, y) {
          @raylib.draw_rectangle(
            @types.cell_px(x) + 2,
            @types.cell_py(y) + 2,
            @types.tile_size - 4,
            @types.tile_size - 4,
            @raylib.Color::new(214, 70, 70, 58),
          )
        }
      }
    }
  }
}

///|
fn draw_exit(game : @types.Game) -> Unit {
  let ex = @types.cell_px(game.exit_x)
  let ey = @types.cell_py(game.exit_y)

  let pulse = Float::from_double(@math.sin((game.pulse_t * 4.8).to_double())) *
    0.5
  let door_c = if @types.exit_unlocked(game) {
    let boost = (pulse * 70.0).to_int()
    @raylib.Color::new(40 + boost, 186 + boost / 2, 128 + boost / 3, 255)
  } else {
    @raylib.Color::new(120, 74, 64, 255)
  }

  @raylib.draw_rectangle(
    ex + 8,
    ey + 8,
    @types.tile_size - 16,
    @types.tile_size - 16,
    door_c,
  )
  @raylib.draw_rectangle_lines(
    ex + 8,
    ey + 8,
    @types.tile_size - 16,
    @types.tile_size - 16,
    @raylib.Color::new(238, 226, 194, 210),
  )
  @raylib.draw_text(
    "E",
    ex + @types.tile_size / 2 - @raylib.measure_text("E", 22) / 2,
    ey + 10,
    22,
    @raylib.Color::new(22, 24, 28, 240),
  )
}

///|
fn draw_artifacts(game : @types.Game) -> Unit {
  for i in 0..<game.artifacts.length() {
    if game.artifacts[i].taken {
      continue
    }

    let px = @types.cell_px(game.artifacts[i].x)
    let py = @types.cell_py(game.artifacts[i].y)
    let wobble = Float::from_double(
      @math.sin((game.pulse_t * 5.2 + Float::from_int(i) * 0.9).to_double()),
    )
    let cy = py + @types.tile_size / 2 + (wobble * 3.0).to_int()
    let cx = px + @types.tile_size / 2

    @raylib.draw_circle(
      cx,
      cy,
      Float::from_int(@types.tile_size) * 0.18,
      @raylib.gold,
    )
    @raylib.draw_circle_lines(
      cx,
      cy,
      Float::from_int(@types.tile_size) * 0.23,
      @raylib.Color::new(255, 242, 170, 235),
    )
    @raylib.draw_line(
      cx - 8,
      cy,
      cx + 8,
      cy,
      @raylib.Color::new(255, 250, 216, 255),
    )
    @raylib.draw_line(
      cx,
      cy - 8,
      cx,
      cy + 8,
      @raylib.Color::new(255, 250, 216, 255),
    )
  }
}

///|
fn draw_guards(game : @types.Game) -> Unit {
  for guard_val in game.guards {
    let cx = @types.cell_px(guard_val.x) + @types.tile_size / 2
    let cy = @types.cell_py(guard_val.y) + @types.tile_size / 2
    @raylib.draw_circle(
      cx,
      cy,
      Float::from_int(@types.tile_size) * 0.30,
      @raylib.Color::new(184, 62, 72, 255),
    )
    @raylib.draw_circle(
      cx + guard_val.dir_x * @types.tile_size / 5,
      cy + guard_val.dir_y * @types.tile_size / 5,
      Float::from_int(@types.tile_size) * 0.09,
      @raylib.Color::new(255, 230, 214, 255),
    )
    @raylib.draw_line(
      cx,
      cy,
      cx + guard_val.dir_x * @types.tile_size / 2,
      cy + guard_val.dir_y * @types.tile_size / 2,
      @raylib.Color::new(255, 216, 190, 210),
    )
  }
}

///|
fn draw_player(game : @types.Game) -> Unit {
  let cx = @types.cell_px(game.player_x) + @types.tile_size / 2
  let cy = @types.cell_py(game.player_y) + @types.tile_size / 2
  let pulse = Float::from_double(@math.sin((game.pulse_t * 8.0).to_double())) *
    0.08
  let r = Float::from_int(@types.tile_size) * (0.28 + pulse)

  @raylib.draw_circle(cx, cy, r, @raylib.Color::new(70, 198, 238, 255))
  @raylib.draw_circle(
    cx,
    cy,
    Float::from_int(@types.tile_size) * 0.14,
    @raylib.Color::new(232, 248, 255, 255),
  )
}

///|
fn draw_side_panel(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.panel_x,
    @types.panel_y,
    @types.panel_w,
    @types.panel_h,
    @raylib.Color::new(13, 20, 30, 232),
  )
  @raylib.draw_rectangle_lines(
    @types.panel_x,
    @types.panel_y,
    @types.panel_w,
    @types.panel_h,
    @raylib.Color::new(112, 142, 174, 198),
  )

  @raylib.draw_text(
    "Museum Heist Puzzle 2026",
    @types.panel_x + 20,
    @types.panel_y + 18,
    30,
    @raylib.Color::new(236, 245, 255, 244),
  )
  @raylib.draw_text(
    "Stealth + Patrol Vision",
    @types.panel_x + 20,
    @types.panel_y + 58,
    24,
    @raylib.Color::new(170, 212, 246, 232),
  )

  @raylib.draw_text(
    "Floor \{game.level_index + 1}/\{game.level_count}",
    @types.panel_x + 20,
    @types.panel_y + 106,
    26,
    @raylib.Color::new(244, 232, 204, 235),
  )
  @raylib.draw_text(
    game.level_name,
    @types.panel_x + 20,
    @types.panel_y + 138,
    24,
    @raylib.Color::new(254, 216, 144, 250),
  )

  @raylib.draw_text(
    "Artifacts \{game.artifacts_collected}/\{game.artifacts_total}",
    @types.panel_x + 20,
    @types.panel_y + 190,
    28,
    @raylib.Color::new(242, 245, 219, 240),
  )
  let exit_status = if @types.exit_unlocked(game) {
    "Exit unlocked"
  } else {
    "Find all artifacts"
  }
  @raylib.draw_text(
    exit_status,
    @types.panel_x + 20,
    @types.panel_y + 226,
    24,
    @raylib.Color::new(188, 232, 208, 236),
  )

  let stealth_status = if game.state == @types.state_lose {
    "Status: Caught"
  } else if game.alarm_t > 0.0 {
    "Status: Alert"
  } else {
    "Status: Hidden"
  }
  @raylib.draw_text(
    stealth_status,
    @types.panel_x + 20,
    @types.panel_y + 270,
    26,
    @raylib.Color::new(255, 188, 176, 230),
  )

  @raylib.draw_text(
    "Desktop",
    @types.panel_x + 20,
    @types.panel_y + 328,
    25,
    @raylib.Color::new(214, 232, 252, 236),
  )
  @raylib.draw_text(
    "WASD / Arrow Keys: Move",
    @types.panel_x + 20,
    @types.panel_y + 360,
    22,
    @raylib.Color::new(184, 206, 232, 230),
  )
  @raylib.draw_text(
    "R: Restart floor  |  Enter/Space: Confirm",
    @types.panel_x + 20,
    @types.panel_y + 388,
    20,
    @raylib.Color::new(164, 190, 220, 230),
  )

  @raylib.draw_text(
    "Touch",
    @types.panel_x + 20,
    @types.panel_y + 440,
    25,
    @raylib.Color::new(214, 232, 252, 236),
  )
  @raylib.draw_text(
    "Hold D-pad to sneak",
    @types.panel_x + 20,
    @types.panel_y + 472,
    22,
    @raylib.Color::new(184, 206, 232, 230),
  )
  @raylib.draw_text(
    "Tap action buttons for menu flow",
    @types.panel_x + 20,
    @types.panel_y + 500,
    20,
    @raylib.Color::new(164, 190, 220, 230),
  )
}

///|
fn draw_action_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  hot : Bool,
  danger : Bool,
) -> Unit {
  let fill = if danger {
    if hot {
      @raylib.Color::new(174, 78, 84, 255)
    } else {
      @raylib.Color::new(134, 62, 70, 245)
    }
  } else if hot {
    @raylib.Color::new(96, 132, 182, 255)
  } else {
    @raylib.Color::new(68, 96, 142, 245)
  }

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      Float::from_int(h),
    ),
    0.22,
    20,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(238, 240, 246, 210),
  )
  draw_centered_text(
    label,
    x + w / 2,
    y + h / 2 - 16,
    34,
    @raylib.Color::new(246, 250, 255, 250),
  )
}

///|
fn draw_dpad_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  hot : Bool,
) -> Unit {
  let fill = if hot {
    @raylib.Color::new(66, 120, 176, 238)
  } else {
    @raylib.Color::new(36, 64, 98, 214)
  }

  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      Float::from_int(h),
    ),
    0.22,
    10,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(188, 214, 240, 210),
  )
  draw_centered_text(
    label,
    x + w / 2,
    y + h / 2 - 13,
    34,
    @raylib.Color::new(242, 247, 255, 250),
  )
}

///|
fn draw_play_controls(game : @types.Game) -> Unit {
  let (lx, ly, lw, lh) = @types.dpad_left_rect()
  let (rx, ry, rw, rh) = @types.dpad_right_rect()
  let (ux, uy, uw, uh) = @types.dpad_up_rect()
  let (dx, dy, dw, dh) = @types.dpad_down_rect()
  let (bx, by, bw, bh) = @types.restart_button_rect()

  let left_hot = @raylib.is_key_down(@raylib.KeyLeft) ||
    @raylib.is_key_down(@raylib.KeyA) ||
    @types.pointer_on_rect(
      game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, lx, ly, lw,
      lh,
    )
  let right_hot = @raylib.is_key_down(@raylib.KeyRight) ||
    @raylib.is_key_down(@raylib.KeyD) ||
    @types.pointer_on_rect(
      game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, rx, ry, rw,
      rh,
    )
  let up_hot = @raylib.is_key_down(@raylib.KeyUp) ||
    @raylib.is_key_down(@raylib.KeyW) ||
    @types.pointer_on_rect(
      game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, ux, uy, uw,
      uh,
    )
  let down_hot = @raylib.is_key_down(@raylib.KeyDown) ||
    @raylib.is_key_down(@raylib.KeyS) ||
    @types.pointer_on_rect(
      game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, dx, dy, dw,
      dh,
    )
  let restart_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, bx, by, bw,
    bh,
  )

  draw_dpad_button(lx, ly, lw, lh, "<", left_hot)
  draw_dpad_button(rx, ry, rw, rh, ">", right_hot)
  draw_dpad_button(ux, uy, uw, uh, "^", up_hot)
  draw_dpad_button(dx, dy, dw, dh, "v", down_hot)
  draw_action_button(bx, by, bw, bh, "RESTART", restart_hot, true)
}

///|
fn draw_alarm_flash(game : @types.Game) -> Unit {
  if game.alarm_t <= 0.0 {
    return
  }
  let alpha = (game.alarm_t / @types.alarm_flash_time * 120.0).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(255, 50, 50, alpha),
  )
}

///|
fn draw_overlay_card(title : String, line1 : String, line2 : String) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(4, 6, 10, 184),
  )
  let card_w = 780
  let card_h = 330
  let card_x = @types.screen_w / 2 - card_w / 2
  let card_y = 140

  @raylib.draw_rectangle(
    card_x,
    card_y,
    card_w,
    card_h,
    @raylib.Color::new(15, 22, 34, 242),
  )
  @raylib.draw_rectangle_lines(
    card_x,
    card_y,
    card_w,
    card_h,
    @raylib.Color::new(146, 172, 200, 210),
  )

  draw_centered_text(
    title,
    @types.screen_w / 2,
    card_y + 36,
    58,
    @raylib.Color::new(246, 248, 252, 252),
  )
  draw_centered_text(
    line1,
    @types.screen_w / 2,
    card_y + 118,
    30,
    @raylib.Color::new(204, 226, 248, 240),
  )
  draw_centered_text(
    line2,
    @types.screen_w / 2,
    card_y + 162,
    28,
    @raylib.Color::new(174, 198, 226, 236),
  )
}

///|
fn draw_title_overlay(game : @types.Game) -> Unit {
  draw_overlay_card(
    "Museum Heist",
    "Collect all relics, avoid patrol vision, then escape.",
    "Previewed floor: \{game.level_index + 1} - \{game.level_name}",
  )

  let (sx, sy, sw, sh) = @types.start_button_rect()
  let (nx, ny, nw, nh) = @types.next_button_rect()
  let start_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, sx, sy, sw,
    sh,
  )
  let next_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, nx, ny, nw,
    nh,
  )

  draw_action_button(sx, sy, sw, sh, "START HEIST", start_hot, false)
  draw_action_button(nx, ny, nw, nh, "CYCLE FLOOR", next_hot, false)
}

///|
fn draw_win_overlay(game : @types.Game) -> Unit {
  draw_overlay_card(
    "Floor Cleared",
    "You secured the relics and escaped undetected.",
    "Continue to the next wing or replay this floor.",
  )

  let (rx, ry, rw, rh) = @types.retry_button_rect()
  let (nx, ny, nw, nh) = @types.next_button_rect()
  let retry_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, rx, ry, rw,
    rh,
  )
  let next_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, nx, ny, nw,
    nh,
  )

  draw_action_button(rx, ry, rw, rh, "RETRY FLOOR", retry_hot, true)
  draw_action_button(nx, ny, nw, nh, "NEXT FLOOR", next_hot, false)

  @raylib.draw_text(
    "Upcoming: Floor \{game.level_index + 2}",
    @types.screen_w / 2 -
    @raylib.measure_text("Upcoming: Floor \{game.level_index + 2}", 24) / 2,
    495,
    24,
    @raylib.Color::new(240, 216, 160, 232),
  )
}

///|
fn draw_lose_overlay(game : @types.Game) -> Unit {
  draw_overlay_card(
    "Alarm Triggered",
    "A guard spotted you in their cone of vision.",
    "Retry the same floor and adjust your route.",
  )

  let (rx, ry, rw, rh) = @types.retry_button_rect()
  let retry_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, rx, ry, rw,
    rh,
  )
  draw_action_button(rx, ry, rw, rh, "RETRY FLOOR", retry_hot, true)
}

///|
fn draw_campaign_clear_overlay(game : @types.Game) -> Unit {
  draw_overlay_card(
    "Grand Collection Secured",
    "All museum wings cleared without raising a full lockdown.",
    "Return to title to launch another campaign.",
  )

  let (sx, sy, sw, sh) = @types.start_button_rect()
  let start_hot = @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count, sx, sy, sw,
    sh,
  )
  draw_action_button(sx, sy, sw, sh, "BACK TO TITLE", start_hot, false)
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_background(game)
  draw_board_tiles(game)
  draw_guard_fov(game)
  draw_exit(game)
  draw_artifacts(game)
  draw_guards(game)
  draw_player(game)
  draw_side_panel(game)

  @raylib.draw_rectangle_lines(
    @types.board_origin_x,
    @types.board_origin_y,
    @types.board_right() - @types.board_origin_x,
    @types.board_bottom() - @types.board_origin_y,
    @raylib.Color::new(174, 196, 220, 180),
  )

  if game.state == @types.state_play {
    draw_play_controls(game)
  }

  draw_alarm_flash(game)

  if game.state == @types.state_title {
    draw_title_overlay(game)
  } else if game.state == @types.state_win {
    draw_win_overlay(game)
  } else if game.state == @types.state_lose {
    draw_lose_overlay(game)
  } else if game.state == @types.state_campaign_clear {
    draw_campaign_clear_overlay(game)
  }
}
