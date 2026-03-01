///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.bg_color)
  match game.state {
    s if s == @types.state_title => draw_title(game)
    s if s == @types.state_play || s == @types.state_won || s == @types.state_over => {
      draw_header(game)
      draw_board(game)
      if game.state == @types.state_won {
        draw_overlay_won(game)
      }
      if game.state == @types.state_over {
        draw_overlay_over()
      }
    }
    _ => ()
  }
}

///|
fn draw_title(_game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let title = "2048"
  let title_size = 90
  let tw = @raylib.measure_text(title, title_size)
  @raylib.draw_text(
    title,
    cx - tw / 2,
    180,
    title_size,
    @raylib.Color::new(237, 194, 46, 255),
  )
  let sub = "Join the numbers and get to the 2048 tile!"
  let sub_size = 20
  let sw = @raylib.measure_text(sub, sub_size)
  @raylib.draw_text(sub, cx - sw / 2, 290, sub_size, @types.header_text_color)
  let inst = "Arrow keys or WASD to move tiles"
  let inst_size = 18
  let iw = @raylib.measure_text(inst, inst_size)
  @raylib.draw_text(inst, cx - iw / 2, 340, inst_size, @types.header_text_color)
  ignore(iw)
  let bx = cx - 120
  let by = 430
  let bw = 240
  let bh = 60
  @raylib.draw_rectangle_rounded(
    @types.rect(bx, by, bw, bh),
    0.3,
    6,
    @types.btn_color,
  )
  let start_text = "New Game"
  let st_size = 28
  let stw = @raylib.measure_text(start_text, st_size)
  @raylib.draw_text(
    start_text,
    bx + (bw - stw) / 2,
    by + 16,
    st_size,
    @types.btn_text_color,
  )
  let ctrl = "Z: Undo  |  R: Restart"
  let ctrl_size = 16
  let cw = @raylib.measure_text(ctrl, ctrl_size)
  @raylib.draw_text(
    ctrl,
    cx - cw / 2,
    520,
    ctrl_size,
    @raylib.Color::new(160, 150, 140, 255),
  )
  ignore(sw)
}

///|
fn draw_header(game : @types.Game) -> Unit {
  @raylib.draw_text(
    "2048",
    @types.board_left + 4,
    24,
    56,
    @raylib.Color::new(119, 110, 101, 255),
  )
  draw_score_box(
    @types.screen_w - 240,
    24,
    108,
    54,
    "SCORE",
    game.score,
  )
  draw_score_box(
    @types.screen_w - 124,
    24,
    108,
    54,
    "BEST",
    game.best_score,
  )
  let btn_y = 100
  let btn_h = 40
  let btn_w = 110
  let ngx = @types.screen_w - btn_w - @types.board_left
  @raylib.draw_rectangle_rounded(
    @types.rect(ngx, btn_y, btn_w, btn_h),
    0.3,
    6,
    @types.btn_color,
  )
  let ng_text = "New Game"
  let ng_w = @raylib.measure_text(ng_text, 16)
  @raylib.draw_text(
    ng_text,
    ngx + (btn_w - ng_w) / 2,
    btn_y + 12,
    16,
    @types.btn_text_color,
  )
  let ux = @types.screen_w - btn_w * 2 - @types.board_left - 8
  let undo_color = if game.can_undo {
    @types.btn_color
  } else {
    @raylib.Color::new(200, 190, 180, 255)
  }
  @raylib.draw_rectangle_rounded(
    @types.rect(ux, btn_y, btn_w, btn_h),
    0.3,
    6,
    undo_color,
  )
  let undo_text = "Undo (Z)"
  let uw = @raylib.measure_text(undo_text, 16)
  @raylib.draw_text(
    undo_text,
    ux + (btn_w - uw) / 2,
    btn_y + 12,
    16,
    @types.btn_text_color,
  )
  if game.msg_t > 0.0 {
    let alpha = @types.clampf(game.msg_t * 2.0, 0.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let msg_size = 18
    @raylib.draw_text(
      game.msg,
      @types.board_left + 4,
      160,
      msg_size,
      @raylib.Color::new(119, 110, 101, a),
    )
  }
}

///|
fn draw_score_box(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  value : Int,
) -> Unit {
  @raylib.draw_rectangle_rounded(
    @types.rect(x, y, w, h),
    0.25,
    6,
    @types.score_bg_color,
  )
  let label_size = 11
  let lw = @raylib.measure_text(label, label_size)
  @raylib.draw_text(
    label,
    x + (w - lw) / 2,
    y + 6,
    label_size,
    @types.score_label_color,
  )
  let val_str = value.to_string()
  let val_size = 22
  let vw = @raylib.measure_text(val_str, val_size)
  @raylib.draw_text(
    val_str,
    x + (w - vw) / 2,
    y + 22,
    val_size,
    @types.score_value_color,
  )
}

///|
fn draw_board(game : @types.Game) -> Unit {
  let bs = Float::from_int(@types.board_size)
  @raylib.draw_rectangle_rounded(
    @types.rectf(
      Float::from_int(@types.board_left),
      Float::from_int(@types.board_top),
      bs,
      bs,
    ),
    0.03,
    6,
    @types.board_bg_color,
  )
  let cs = Float::from_int(@types.cell_size)
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      let sx = @types.cell_screen_x(c)
      let sy = @types.cell_screen_y(r)
      @raylib.draw_rectangle_rounded(
        @types.rectf(sx, sy, cs, cs),
        0.08,
        6,
        @types.cell_empty_color,
      )
    }
  }
  for i in 0..<@types.cell_count {
    let tile = game.tiles[i]
    if tile.value == 0 {
      continue
    }
    let s = tile.scale
    let w = cs * s
    let h = cs * s
    let x = tile.anim_x + (cs - w) / 2.0
    let y = tile.anim_y + (cs - h) / 2.0
    let color = @types.tile_color(tile.value)
    @raylib.draw_rectangle_rounded(
      @types.rectf(x, y, w, h),
      0.08,
      6,
      color,
    )
    let txt = tile.value.to_string()
    let font_size = @types.tile_font_size(tile.value)
    let tw = @raylib.measure_text(txt, font_size)
    let text_color = @types.tile_text_color(tile.value)
    let tx = tile.anim_x + (cs - Float::from_int(tw)) / 2.0
    let ty = tile.anim_y + (cs - Float::from_int(font_size)) / 2.0
    @raylib.draw_text(txt, tx.to_int(), ty.to_int(), font_size, text_color)
  }
}

///|
fn draw_overlay_won(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.board_left,
    @types.board_top,
    @types.board_size,
    @types.board_size,
    @raylib.Color::new(237, 194, 46, 120),
  )
  let cx = @types.board_left + @types.board_size / 2
  let cy = @types.board_top + @types.board_size / 2
  let txt = "You Win!"
  let ts = 48
  let tw = @raylib.measure_text(txt, ts)
  @raylib.draw_text(
    txt,
    cx - tw / 2,
    cy - 60,
    ts,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let btn_text = "Keep Going"
  let bs = 24
  let bw = @raylib.measure_text(btn_text, bs) + 40
  let bh = 48
  let bx = cx - bw / 2
  let by = cy + 10
  @raylib.draw_rectangle_rounded(
    @types.rect(bx, by, bw, bh),
    0.3,
    6,
    @types.btn_color,
  )
  let btw = @raylib.measure_text(btn_text, bs)
  @raylib.draw_text(
    btn_text,
    bx + (bw - btw) / 2,
    by + 12,
    bs,
    @types.btn_text_color,
  )
  ignore(game)
}

///|
fn draw_overlay_over() -> Unit {
  @raylib.draw_rectangle(
    @types.board_left,
    @types.board_top,
    @types.board_size,
    @types.board_size,
    @raylib.Color::new(238, 228, 218, 160),
  )
  let cx = @types.board_left + @types.board_size / 2
  let cy = @types.board_top + @types.board_size / 2
  let txt = "Game Over!"
  let ts = 48
  let tw = @raylib.measure_text(txt, ts)
  @raylib.draw_text(
    txt,
    cx - tw / 2,
    cy - 40,
    ts,
    @raylib.Color::new(119, 110, 101, 255),
  )
  let sub = "Press R to restart"
  let ss = 20
  let sw = @raylib.measure_text(sub, ss)
  @raylib.draw_text(
    sub,
    cx - sw / 2,
    cy + 20,
    ss,
    @raylib.Color::new(119, 110, 101, 200),
  )
  ignore(tw)
  ignore(sw)
}
