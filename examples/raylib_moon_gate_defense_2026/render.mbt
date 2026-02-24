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
fn alpha_col(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(alpha, 0, 255),
  )
}

///|
fn meter_col(base : @raylib.Color, ratio : Float) -> @raylib.Color {
  let r = clampf(ratio, 0.0, 1.0)
  alpha_col(base, 100 + (r * 155.0).to_int())
}

///|
fn camera_offset(game : Game) -> (Float, Float) {
  if game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let amp = minf(16.0, game.shake_t * 58.0)
    (randf(-amp, amp), randf(-amp, amp))
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    col_bg_top(),
    col_bg_bottom(),
  )

  let moon_x = Float::from_int(screen_w) * 0.82 +
    sinf(game.time_s * 0.24) * 24.0
  let moon_y : Float = 106.0 + cosf(game.time_s * 0.18) * 14.0
  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    68.0,
    @raylib.Color::new(184, 216, 255, 52),
  )
  @raylib.draw_circle(
    moon_x.to_int(),
    moon_y.to_int(),
    42.0,
    @raylib.Color::new(216, 236, 255, 128),
  )

  for i in 0..<160 {
    let fi = Float::from_int(i)
    let base_x = (i * 119 + i * i * 71) % screen_w
    let base_y = (i * 73 + i * 29) % screen_h
    let x = Float::from_int(base_x) + sinf(game.time_s * 0.3 + fi) * 2.0
    let y = Float::from_int(base_y) + cosf(game.time_s * 0.2 + fi * 1.1) * 2.0
    let tw : Float = 0.5 + 0.5 * sinf(game.time_s * 1.4 + fi * 0.9)
    let alpha = 45 + (tw * 120.0).to_int()

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      0.8 + tw * 1.5,
      @raylib.Color::new(180 + (tw * 60.0).to_int(), 220, 255, alpha),
    )
  }
}

///|
fn draw_grid_and_gate_cell(cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle(
    (board_left() + cam_x).to_int(),
    (board_top() + cam_y).to_int(),
    board_w,
    board_h,
    @raylib.Color::new(22, 40, 70, 164),
  )

  @raylib.draw_rectangle(
    (Float::from_int(board_x + gate_gx * cell_size) + cam_x).to_int(),
    (Float::from_int(board_y + gate_gy * cell_size) + cam_y).to_int(),
    cell_size,
    cell_size,
    @raylib.Color::new(40, 70, 108, 150),
  )

  for gx in 0..<(grid_cols + 1) {
    let x = board_x + gx * cell_size
    @raylib.draw_line(
      (Float::from_int(x) + cam_x).to_int(),
      (board_top() + cam_y).to_int(),
      (Float::from_int(x) + cam_x).to_int(),
      (board_bottom() + cam_y).to_int(),
      col_grid(),
    )
  }

  for gy in 0..<(grid_rows + 1) {
    let y = board_y + gy * cell_size
    @raylib.draw_line(
      (board_left() + cam_x).to_int(),
      (Float::from_int(y) + cam_y).to_int(),
      (board_right() + cam_x).to_int(),
      (Float::from_int(y) + cam_y).to_int(),
      col_grid(),
    )
  }

  @raylib.draw_rectangle_lines(
    (board_left() + cam_x).to_int(),
    (board_top() + cam_y).to_int(),
    board_w,
    board_h,
    @raylib.Color::new(150, 206, 232, 180),
  )
}

///|
fn draw_gate(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let gx = gate_x() + cam_x
  let gy = gate_y() + cam_y
  let gate_ratio = clampf(game.gate_hp / gate_hp_max, 0.0, 1.0)

  let ring_col = @raylib.Color::new(
    90 + (gate_ratio * 120.0).to_int(),
    120 + (gate_ratio * 120.0).to_int(),
    240,
    255,
  )

  let pulse : Float = 3.0 * sinf(game.time_s * 4.0)
  @raylib.draw_circle(
    gx.to_int(),
    gy.to_int(),
    gate_radius + 16.0 + pulse,
    alpha_col(col_gate(), 56),
  )
  @raylib.draw_circle(
    gx.to_int(),
    gy.to_int(),
    gate_radius + pulse,
    alpha_col(col_gate(), 128),
  )
  @raylib.draw_circle_lines(
    gx.to_int(),
    gy.to_int(),
    gate_radius + 24.0 + pulse,
    ring_col,
  )

  if game.barrier_flash > 0.0 {
    let flash_ratio = game.barrier_flash / barrier_flash_time
    @raylib.draw_circle_lines(
      gx.to_int(),
      gy.to_int(),
      barrier_radius * (1.0 - flash_ratio * 0.25),
      alpha_col(col_barrier(), (flash_ratio * 220.0).to_int()),
    )
  }
}

///|
fn draw_nodes(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i in 0..<game.nodes.length() {
    if not(game.nodes[i].active) {
      continue
    }

    let x = cell_center_x(game.nodes[i].gx) + cam_x
    let y = cell_center_y(game.nodes[i].gy) + cam_y
    let level_f = Float::from_int(game.nodes[i].level)
    let radius : Float = 13.0 + level_f * 3.8 + game.nodes[i].pulse * 2.4
    let node_col = col_node(game.nodes[i].level)

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      radius,
      alpha_col(node_col, 220),
    )
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      radius + 3.0,
      alpha_col(node_col, 190),
    )

    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      node_range(game.nodes[i].level),
      alpha_col(node_col, 36),
    )

    let dx = dir_vec_x(game.nodes[i].facing)
    let dy = dir_vec_y(game.nodes[i].facing)
    let tip_x = x + dx * (20.0 + level_f * 4.0)
    let tip_y = y + dy * (20.0 + level_f * 4.0)

    @raylib.draw_line(
      x.to_int(),
      y.to_int(),
      tip_x.to_int(),
      tip_y.to_int(),
      alpha_col(@raylib.Color::new(250, 254, 255, 255), 230),
    )
    @raylib.draw_circle(
      tip_x.to_int(),
      tip_y.to_int(),
      3.0 + level_f,
      alpha_col(@raylib.Color::new(250, 254, 255, 255), 230),
    )
  }
}

///|
fn draw_enemies(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let x = game.enemies[i].x + cam_x
    let y = game.enemies[i].y + cam_y
    let col = col_enemy(game.enemies[i].kind)

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      game.enemies[i].radius,
      alpha_col(col, 220),
    )

    if game.enemies[i].kind == enemy_kind_wraith {
      let aura = game.enemies[i].radius +
        4.0 +
        sinf(game.time_s * 8.0 + game.enemies[i].phase) * 2.0
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        aura,
        alpha_col(col, 180),
      )
    }

    let hp_ratio = clampf(
      game.enemies[i].hp / maxf(game.enemies[i].max_hp, 1.0),
      0.0,
      1.0,
    )
    let bw = (game.enemies[i].radius * 2.2).to_int()
    let bx = x.to_int() - bw / 2
    let by = y.to_int() - game.enemies[i].radius.to_int() - 9

    @raylib.draw_rectangle(bx, by, bw, 4, @raylib.Color::new(26, 30, 44, 220))
    @raylib.draw_rectangle(
      bx,
      by,
      (Float::from_int(bw) * hp_ratio).to_int(),
      4,
      meter_col(col, hp_ratio),
    )
  }
}

///|
fn draw_bolts(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i in 0..<game.bolts.length() {
    if not(game.bolts[i].active) {
      continue
    }

    let x = game.bolts[i].x + cam_x
    let y = game.bolts[i].y + cam_y
    let tail_x = x - game.bolts[i].vx * 0.018
    let tail_y = y - game.bolts[i].vy * 0.018

    @raylib.draw_line(
      tail_x.to_int(),
      tail_y.to_int(),
      x.to_int(),
      y.to_int(),
      alpha_col(col_gate(), 230),
    )
    @raylib.draw_circle(x.to_int(), y.to_int(), 3.2, alpha_col(col_gate(), 250))
  }
}

///|
fn pulse_col(kind : Int) -> @raylib.Color {
  if kind == 0 {
    col_gate()
  } else if kind == 1 {
    col_energy()
  } else {
    col_barrier()
  }
}

///|
fn draw_pulses(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i in 0..<game.pulses.length() {
    if not(game.pulses[i].active) {
      continue
    }

    let ratio = clampf(
      game.pulses[i].life / maxf(game.pulses[i].max_life, 0.0001),
      0.0,
      1.0,
    )
    @raylib.draw_circle_lines(
      (game.pulses[i].x + cam_x).to_int(),
      (game.pulses[i].y + cam_y).to_int(),
      game.pulses[i].radius,
      alpha_col(pulse_col(game.pulses[i].kind), (ratio * 190.0).to_int()),
    )
  }
}

///|
fn draw_cursor(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = board_x + game.cursor_x * cell_size
  let y = board_y + game.cursor_y * cell_size

  let col = if is_gate_cell(game.cursor_x, game.cursor_y) {
    @raylib.Color::new(255, 126, 126, 255)
  } else {
    @raylib.Color::new(222, 246, 255, 255)
  }

  @raylib.draw_rectangle_lines(
    (Float::from_int(x) + cam_x).to_int(),
    (Float::from_int(y) + cam_y).to_int(),
    cell_size,
    cell_size,
    alpha_col(col, 255),
  )
  @raylib.draw_rectangle_lines(
    (Float::from_int(x + 3) + cam_x).to_int(),
    (Float::from_int(y + 3) + cam_y).to_int(),
    cell_size - 6,
    cell_size - 6,
    alpha_col(col, 180),
  )

  let cx = cell_center_x(game.cursor_x) + cam_x
  let cy = cell_center_y(game.cursor_y) + cam_y
  let dx = dir_vec_x(game.cursor_dir)
  let dy = dir_vec_y(game.cursor_dir)

  @raylib.draw_line(
    cx.to_int(),
    cy.to_int(),
    (cx + dx * 24.0).to_int(),
    (cy + dy * 24.0).to_int(),
    alpha_col(col, 230),
  )
}

///|
fn draw_meter(
  label : String,
  value_text : String,
  x : Int,
  y : Int,
  w : Int,
  ratio : Float,
  col : @raylib.Color,
) -> Unit {
  @raylib.draw_text(
    label,
    x,
    y - 20,
    18,
    @raylib.Color::new(208, 224, 240, 220),
  )
  @raylib.draw_rectangle(x, y, w, 16, @raylib.Color::new(26, 30, 42, 220))
  @raylib.draw_rectangle(
    x,
    y,
    (Float::from_int(w) * clampf(ratio, 0.0, 1.0)).to_int(),
    16,
    meter_col(col, ratio),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    16,
    @raylib.Color::new(148, 170, 198, 170),
  )
  @raylib.draw_text(
    value_text,
    x + w + 10,
    y - 2,
    18,
    @raylib.Color::new(230, 240, 255, 220),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    146,
    @raylib.Color::new(8, 14, 24, 208),
  )
  @raylib.draw_line(
    0,
    146,
    screen_w,
    146,
    @raylib.Color::new(112, 162, 200, 160),
  )

  let gate_ratio = clampf(game.gate_hp / gate_hp_max, 0.0, 1.0)
  let energy_ratio = clampf(game.energy / energy_max, 0.0, 1.0)
  let barrier_ratio = clampf(
    game.barrier_charge / barrier_charge_goal,
    0.0,
    1.0,
  )

  draw_meter(
    "Gate HP",
    game.gate_hp.to_int().to_string() + "/" + gate_hp_max.to_int().to_string(),
    24,
    30,
    320,
    gate_ratio,
    @raylib.Color::new(255, 114, 114, 255),
  )
  draw_meter(
    "Energy",
    game.energy.to_int().to_string() + "/" + energy_max.to_int().to_string(),
    24,
    76,
    320,
    energy_ratio,
    col_energy(),
  )
  draw_meter(
    "Barrier",
    game.barrier_charge.to_int().to_string() +
    "/" +
    barrier_charge_goal.to_int().to_string(),
    24,
    122,
    320,
    barrier_ratio,
    col_barrier(),
  )

  @raylib.draw_text(
    "Wave " + game.wave.to_string(),
    404,
    28,
    30,
    @raylib.Color::new(232, 242, 255, 240),
  )
  @raylib.draw_text(
    "Score " + game.score.to_string(),
    404,
    68,
    30,
    @raylib.Color::new(250, 220, 132, 240),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    404,
    104,
    24,
    @raylib.Color::new(176, 208, 246, 230),
  )

  @raylib.draw_text(
    "Kills " + game.kills.to_string(),
    650,
    36,
    26,
    @raylib.Color::new(202, 228, 250, 230),
  )
  if game.combo > 1 {
    @raylib.draw_text(
      "Combo x" + game.combo.to_string(),
      650,
      82,
      28,
      @raylib.Color::new(254, 208, 124, 255),
    )
  }

  @raylib.draw_text(
    "WASD/Arrows Move Cursor",
    930,
    24,
    22,
    @raylib.Color::new(220, 232, 246, 220),
  )
  @raylib.draw_text(
    "J Place/Upgrade  K Sell/Cancel",
    930,
    56,
    22,
    @raylib.Color::new(220, 232, 246, 220),
  )
  @raylib.draw_text(
    "Space Barrier Burst  P Pause  R Restart",
    930,
    88,
    22,
    @raylib.Color::new(220, 232, 246, 220),
  )

  if game.status_t > 0.0 {
    draw_center_text(
      game.status_text,
      screen_h - 42,
      26,
      alpha_col(
        @raylib.Color::new(240, 246, 255, 255),
        (game.status_t * 255.0).to_int(),
      ),
    )
  }
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 14, 148),
  )

  draw_center_text(
    "MOON GATE DEFENSE 2026",
    250,
    60,
    @raylib.Color::new(230, 242, 255, 245),
  )
  draw_center_text(
    "Build and rotate guardian nodes around the lunar portal.",
    340,
    30,
    @raylib.Color::new(190, 218, 246, 230),
  )
  draw_center_text(
    "Chain kills to charge the ultimate barrier burst.",
    382,
    30,
    @raylib.Color::new(190, 218, 246, 230),
  )
  draw_center_text(
    "If enemies breach the gate, the defense is lost.",
    424,
    30,
    @raylib.Color::new(190, 218, 246, 230),
  )

  let pulse = 170 + (sinf(game.time_s * 5.0) * 70.0).to_int()
  draw_center_text(
    "Press J to Start",
    560,
    44,
    @raylib.Color::new(252, 220, 128, clampi(pulse, 80, 255)),
  )
  draw_center_text(
    "R also restarts instantly",
    614,
    24,
    @raylib.Color::new(200, 220, 246, 210),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 16, 150),
  )
  draw_center_text("PAUSED", 310, 72, @raylib.Color::new(238, 246, 255, 245))
  draw_center_text(
    "Press P or K to resume",
    404,
    34,
    @raylib.Color::new(198, 220, 245, 230),
  )
  draw_center_text(
    "Press R to restart the run",
    452,
    30,
    @raylib.Color::new(198, 220, 245, 230),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(28, 10, 14, 165),
  )
  draw_center_text("GATE LOST", 278, 74, @raylib.Color::new(255, 184, 184, 248))
  draw_center_text(
    "Final Score " + game.score.to_string(),
    376,
    36,
    @raylib.Color::new(250, 236, 188, 240),
  )
  draw_center_text(
    "Wave Reached " +
    game.wave.to_string() +
    "   Kills " +
    game.kills.to_string(),
    424,
    30,
    @raylib.Color::new(224, 230, 248, 232),
  )
  draw_center_text(
    "Best Score " + game.best_score.to_string(),
    468,
    30,
    @raylib.Color::new(184, 212, 244, 228),
  )
  draw_center_text(
    "Press R or J to restart",
    560,
    34,
    @raylib.Color::new(236, 246, 255, 238),
  )
  draw_center_text(
    "Press K to return to title",
    608,
    28,
    @raylib.Color::new(204, 218, 236, 218),
  )
}

///|
fn draw_state_overlay(game : Game) -> Unit {
  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)

  let (cam_x, cam_y) = camera_offset(game)
  draw_grid_and_gate_cell(cam_x, cam_y)
  draw_gate(game, cam_x, cam_y)
  draw_pulses(game, cam_x, cam_y)
  draw_nodes(game, cam_x, cam_y)
  draw_enemies(game, cam_x, cam_y)
  draw_bolts(game, cam_x, cam_y)
  draw_cursor(game, cam_x, cam_y)

  draw_hud(game)
  draw_state_overlay(game)
}
