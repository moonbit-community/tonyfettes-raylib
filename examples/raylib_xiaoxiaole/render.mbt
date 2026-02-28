///|
fn draw_frame(game : Game) -> Unit {
  @raylib.clear_background(bg_color)
  match game.state {
    s if s == state_title => draw_title()
    _ => {
      draw_panel(game)
      draw_board(game)
      if game.state == state_over {
        draw_overlay_over(game)
      }
      if game.state == state_clear {
        draw_overlay_clear(game)
      }
    }
  }
}

///|
fn draw_title() -> Unit {
  let cx = screen_w / 2
  let title = "Xiao Xiao Le"
  let ts = 52
  let tw = @raylib.measure_text(title, ts)
  @raylib.draw_text(
    title,
    cx - tw / 2,
    200,
    ts,
    @raylib.Color::new(241, 196, 15, 255),
  )
  let sub = "Match 3 or more gems to score!"
  let ss = 22
  let sw = @raylib.measure_text(sub, ss)
  @raylib.draw_text(sub, cx - sw / 2, 280, ss, panel_text_color)
  let inst = "Click to select and swap adjacent gems"
  let is_ = 18
  let iw = @raylib.measure_text(inst, is_)
  @raylib.draw_text(inst, cx - iw / 2, 320, is_, panel_label_color)
  let start = "Click or press Enter to start"
  let start_s = 20
  let start_w = @raylib.measure_text(start, start_s)
  @raylib.draw_text(
    start,
    cx - start_w / 2,
    420,
    start_s,
    @raylib.Color::new(46, 204, 113, 255),
  )
  ignore(sw)
  ignore(iw)
}

///|
fn draw_panel(game : Game) -> Unit {
  // Level
  @raylib.draw_text("Level", 36, 20, 16, panel_label_color)
  @raylib.draw_text(game.level.to_string(), 36, 38, 32, panel_text_color)
  // Score
  @raylib.draw_text("Score", 160, 20, 16, panel_label_color)
  @raylib.draw_text(game.score.to_string(), 160, 38, 32, panel_text_color)
  // Target
  let target_str = "/ \{game.target_score}"
  @raylib.draw_text(target_str, 280, 46, 16, panel_label_color)
  // Moves
  @raylib.draw_text("Moves", 460, 20, 16, panel_label_color)
  let moves_color = if game.moves_left <= 5 {
    @raylib.Color::new(231, 76, 60, 255)
  } else {
    panel_text_color
  }
  @raylib.draw_text(game.moves_left.to_string(), 460, 38, 32, moves_color)
  // Best
  @raylib.draw_text("Best", 570, 20, 16, panel_label_color)
  @raylib.draw_text(game.best_score.to_string(), 570, 38, 24, panel_text_color)
  // Combo / message
  if game.msg_t > 0.0 {
    let alpha = clampf(game.msg_t * 3.0, 0.0, 1.0)
    let a = (alpha * 255.0).to_int()
    @raylib.draw_text(game.msg, 36, 90, 24, @raylib.Color::new(241, 196, 15, a))
  }
  // Progress bar
  let bar_x = 36
  let bar_y = 125
  let bar_w = screen_w - 72
  let bar_h = 16
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, board_bg_color)
  let fill_ratio = if game.target_score > 0 {
    clampf(
      Float::from_int(game.score) / Float::from_int(game.target_score),
      0.0,
      1.0,
    )
  } else {
    0.0
  }
  let fill_w = (Float::from_int(bar_w) * fill_ratio).to_int()
  if fill_w > 0 {
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      fill_w,
      bar_h,
      @raylib.Color::new(46, 204, 113, 255),
    )
  }
}

///|
fn draw_board(game : Game) -> Unit {
  // Board background
  let bw = grid_cols * (cell_px + cell_gap) - cell_gap + 16
  let bh = grid_rows * (cell_px + cell_gap) - cell_gap + 16
  @raylib.draw_rectangle(board_left - 8, board_top - 8, bw, bh, board_bg_color)
  // Gems
  let cp = Float::from_int(cell_px)
  for i in 0..<cell_count {
    let g = game.board[i]
    if g.kind < 0 {
      continue
    }
    let r = i / grid_cols
    let c = i % grid_cols
    let x = g.anim_x
    let y = g.anim_y
    // Draw gem (rounded rectangle with highlight)
    let color = gem_color(g.kind)
    let highlight = gem_highlight(g.kind)
    @raylib.draw_rectangle_rounded(
      @raylib.Rectangle::new(x + 2.0, y + 2.0, cp - 4.0, cp - 4.0),
      0.3,
      6,
      color,
    )
    // Highlight circle in upper-left
    @raylib.draw_circle(
      (x + cp * 0.35).to_int(),
      (y + cp * 0.35).to_int(),
      cp * 0.15,
      highlight,
    )
    // Flash effect when removed
    if g.flash_t > 0.0 {
      let alpha = (g.flash_t / flash_duration * 255.0).to_int()
      let a = if alpha > 255 { 255 } else { alpha }
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(x + 2.0, y + 2.0, cp - 4.0, cp - 4.0),
        0.3,
        6,
        @raylib.Color::new(255, 255, 255, a),
      )
    }
    // Selection highlight
    if game.sel_r == r && game.sel_c == c {
      @raylib.draw_rectangle_rounded_lines_ex(
        @raylib.Rectangle::new(x, y, cp, cp),
        0.3,
        6,
        3.0,
        select_color,
      )
    }
    ignore(r)
    ignore(c)
  }
  // Hint animation
  if game.state == state_play && game.hint_r1 >= 0 && game.hint_t > 2.0 {
    let pulse = Float::from_double(
        @math.sin((game.hint_t - 2.0).to_double() * 4.0),
      ) *
      0.5 +
      0.5
    let alpha = (pulse * 180.0).to_int()
    let hx1 = cell_x(game.hint_c1)
    let hy1 = cell_y(game.hint_r1)
    let hx2 = cell_x(game.hint_c2)
    let hy2 = cell_y(game.hint_r2)
    let hint_color = @raylib.Color::new(241, 196, 15, alpha)
    @raylib.draw_rectangle_rounded_lines_ex(
      @raylib.Rectangle::new(hx1, hy1, cp, cp),
      0.3,
      6,
      2.0,
      hint_color,
    )
    @raylib.draw_rectangle_rounded_lines_ex(
      @raylib.Rectangle::new(hx2, hy2, cp, cp),
      0.3,
      6,
      2.0,
      hint_color,
    )
  }
}

///|
fn draw_overlay_over(game : Game) -> Unit {
  let bw = grid_cols * (cell_px + cell_gap) - cell_gap + 16
  let bh = grid_rows * (cell_px + cell_gap) - cell_gap + 16
  @raylib.draw_rectangle(
    board_left - 8,
    board_top - 8,
    bw,
    bh,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = board_left + bw / 2 - 8
  let cy = board_top + bh / 2 - 8
  let txt = "Game Over"
  let ts = 48
  let tw = @raylib.measure_text(txt, ts)
  @raylib.draw_text(
    txt,
    cx - tw / 2,
    cy - 60,
    ts,
    @raylib.Color::new(231, 76, 60, 255),
  )
  let score_text = "Score: \{game.score}"
  let ss = 24
  let sw = @raylib.measure_text(score_text, ss)
  @raylib.draw_text(score_text, cx - sw / 2, cy, ss, panel_text_color)
  let sub = "Enter: Retry  |  R: Level 1  |  Esc: Title"
  let sub_s = 16
  let sub_w = @raylib.measure_text(sub, sub_s)
  @raylib.draw_text(sub, cx - sub_w / 2, cy + 40, sub_s, panel_label_color)
}

///|
fn draw_overlay_clear(game : Game) -> Unit {
  let bw = grid_cols * (cell_px + cell_gap) - cell_gap + 16
  let bh = grid_rows * (cell_px + cell_gap) - cell_gap + 16
  @raylib.draw_rectangle(
    board_left - 8,
    board_top - 8,
    bw,
    bh,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = board_left + bw / 2 - 8
  let cy = board_top + bh / 2 - 8
  let txt = "Level Clear!"
  let ts = 48
  let tw = @raylib.measure_text(txt, ts)
  @raylib.draw_text(
    txt,
    cx - tw / 2,
    cy - 60,
    ts,
    @raylib.Color::new(46, 204, 113, 255),
  )
  let score_text = "Score: \{game.score}"
  let ss = 24
  let sw = @raylib.measure_text(score_text, ss)
  @raylib.draw_text(score_text, cx - sw / 2, cy, ss, panel_text_color)
  let sub = "Enter: Next Level  |  R: Level 1"
  let sub_s = 16
  let sub_w = @raylib.measure_text(sub, sub_s)
  @raylib.draw_text(sub, cx - sub_w / 2, cy + 40, sub_s, panel_label_color)
  ignore(tw)
  ignore(sw)
}
