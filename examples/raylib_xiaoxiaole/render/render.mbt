///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.bg_color)
  match game.state {
    Title => draw_title()
    _ => {
      draw_panel(game)
      draw_board(game)
      if game.state == @types.GameState::Over {
        draw_overlay_over(game)
      }
      if game.state == @types.GameState::Clear {
        draw_overlay_clear(game)
      }
    }
  }
}

///|
fn draw_title() -> Unit {
  let cx = @types.screen_w / 2
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
  @raylib.draw_text(sub, cx - sw / 2, 280, ss, @types.panel_text_color)
  let inst = "Click to select and swap adjacent gems"
  let is_ = 18
  let iw = @raylib.measure_text(inst, is_)
  @raylib.draw_text(inst, cx - iw / 2, 320, is_, @types.panel_label_color)
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
fn draw_panel(game : @types.Game) -> Unit {
  // Level
  @raylib.draw_text("Level", 36, 20, 16, @types.panel_label_color)
  @raylib.draw_text(game.level.to_string(), 36, 38, 32, @types.panel_text_color)
  // Score
  @raylib.draw_text("Score", 160, 20, 16, @types.panel_label_color)
  @raylib.draw_text(
    game.score.to_string(),
    160,
    38,
    32,
    @types.panel_text_color,
  )
  // Target
  let target_str = "/ \{game.target_score}"
  @raylib.draw_text(target_str, 280, 46, 16, @types.panel_label_color)
  // Moves
  @raylib.draw_text("Moves", 460, 20, 16, @types.panel_label_color)
  let moves_color = if game.moves_left <= 5 {
    @raylib.Color::new(231, 76, 60, 255)
  } else {
    @types.panel_text_color
  }
  @raylib.draw_text(game.moves_left.to_string(), 460, 38, 32, moves_color)
  // Best
  @raylib.draw_text("Best", 570, 20, 16, @types.panel_label_color)
  @raylib.draw_text(
    game.best_score.to_string(),
    570,
    38,
    24,
    @types.panel_text_color,
  )
  // Combo / message
  if game.msg_t > 0.0 {
    let alpha = @types.clampf(game.msg_t * 3.0, 0.0, 1.0)
    let a = (alpha * 255.0).to_int()
    @raylib.draw_text(
      game.msg,
      36,
      90,
      24,
      @raylib.Color::new(241, 196, 15, a),
    )
  }
  // Progress bar
  let bar_x = 36
  let bar_y = 125
  let bar_w = @types.screen_w - 72
  let bar_h = 16
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.board_bg_color)
  let fill_ratio = if game.target_score > 0 {
    @types.clampf(
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
fn draw_board(game : @types.Game) -> Unit {
  // Board background
  let bw = @types.grid_cols * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  let bh = @types.grid_rows * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  @raylib.draw_rectangle(
    @types.board_left - 8,
    @types.board_top - 8,
    bw,
    bh,
    @types.board_bg_color,
  )
  // Gems
  let cp = Float::from_int(@types.cell_px)
  for i in 0..< @types.cell_count {
    let g = game.board[i]
    if g.kind.is_empty() {
      continue
    }
    let r = i / @types.grid_cols
    let c = i % @types.grid_cols
    let x = g.anim_x
    let y = g.anim_y
    // Draw gem (rounded rectangle with highlight)
    let color = @types.gem_color(g.kind)
    let highlight = @types.gem_highlight(g.kind)
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
      let alpha = (g.flash_t / @types.flash_duration * 255.0).to_int()
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
        @types.select_color,
      )
    }
    ignore(r)
    ignore(c)
  }
  // Hint animation
  if game.state == @types.GameState::Play &&
    game.hint_r1 >= 0 &&
    game.hint_t > 2.0 {
    let pulse = Float::from_double(
        @math.sin((game.hint_t - 2.0).to_double() * 4.0),
      ) *
      0.5 +
      0.5
    let alpha = (pulse * 180.0).to_int()
    let hx1 = @types.cell_x(game.hint_c1)
    let hy1 = @types.cell_y(game.hint_r1)
    let hx2 = @types.cell_x(game.hint_c2)
    let hy2 = @types.cell_y(game.hint_r2)
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
fn draw_overlay_over(game : @types.Game) -> Unit {
  let bw = @types.grid_cols * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  let bh = @types.grid_rows * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  @raylib.draw_rectangle(
    @types.board_left - 8,
    @types.board_top - 8,
    bw,
    bh,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = @types.board_left + bw / 2 - 8
  let cy = @types.board_top + bh / 2 - 8
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
  @raylib.draw_text(score_text, cx - sw / 2, cy, ss, @types.panel_text_color)
  let sub = "Enter: Retry  |  R: Level 1  |  Esc: Title"
  let sub_s = 16
  let sub_w = @raylib.measure_text(sub, sub_s)
  @raylib.draw_text(
    sub,
    cx - sub_w / 2,
    cy + 40,
    sub_s,
    @types.panel_label_color,
  )
}

///|
fn draw_overlay_clear(game : @types.Game) -> Unit {
  let bw = @types.grid_cols * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  let bh = @types.grid_rows * (@types.cell_px + @types.cell_gap) -
    @types.cell_gap +
    16
  @raylib.draw_rectangle(
    @types.board_left - 8,
    @types.board_top - 8,
    bw,
    bh,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let cx = @types.board_left + bw / 2 - 8
  let cy = @types.board_top + bh / 2 - 8
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
  @raylib.draw_text(score_text, cx - sw / 2, cy, ss, @types.panel_text_color)
  let sub = "Enter: Next Level  |  R: Level 1"
  let sub_s = 16
  let sub_w = @raylib.measure_text(sub, sub_s)
  @raylib.draw_text(
    sub,
    cx - sub_w / 2,
    cy + 40,
    sub_s,
    @types.panel_label_color,
  )
  ignore(tw)
  ignore(sw)
}
