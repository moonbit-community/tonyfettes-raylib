///|
fn draw_board_cell(x : Int, y : Int, color_id : Int) -> Unit {
  let px = board_x + x * board_cell
  let py = board_y + y * board_cell
  let color = piece_color(color_id)
  @raylib.draw_rectangle(px + 1, py + 1, board_cell - 2, board_cell - 2, color)
  @raylib.draw_rectangle_lines(
    px,
    py,
    board_cell,
    board_cell,
    @raylib.Color::new(28, 28, 36, 255),
  )
}

///|
fn ghost_y(game : Game) -> Int {
  let mut y = game.piece_y
  while not(
          collides(game, game.piece_kind, game.piece_rot, game.piece_x, y + 1),
        ) {
    y = y + 1
  }
  y
}

///|
fn draw_piece_blocks(
  kind : Int,
  rot : Int,
  px : Int,
  py : Int,
  cell_size : Int,
  offset_x : Int,
  offset_y : Int,
  shade : @raylib.Color,
) -> Unit {
  for i = 0; i < 4; i = i + 1 {
    let c = piece_cell(kind, rot, i)
    let x = px + c.x
    let y = py + c.y
    if y < 0 {
      continue
    }
    let rx = offset_x + x * cell_size
    let ry = offset_y + y * cell_size
    @raylib.draw_rectangle(rx + 1, ry + 1, cell_size - 2, cell_size - 2, shade)
    @raylib.draw_rectangle_lines(
      rx,
      ry,
      cell_size,
      cell_size,
      @raylib.Color::new(35, 35, 40, 255),
    )
  }
}

///|
fn draw_preview(kind : Int, x : Int, y : Int, title : String) -> Unit {
  @raylib.draw_text(title, x, y, 24, @raylib.raywhite)
  @raylib.draw_rectangle_lines(x - 8, y + 30, 120, 120, @raylib.darkgray)
  if kind < 0 {
    return
  }
  let color = piece_color(kind + 1)
  draw_piece_blocks(kind, 0, 2, 2, 20, x - 6, y + 28, color)
}

///|
fn draw_hud(game : Game) -> Unit {
  draw_preview(game.next_kind, side_panel_x, 80, "NEXT")
  draw_preview(game.hold_kind, side_panel_x, 240, "HOLD")

  @raylib.draw_text("SCORE", side_panel_x, 410, 22, @raylib.lightgray)
  @raylib.draw_text("\{game.score}", side_panel_x, 438, 30, @raylib.orange)

  @raylib.draw_text("LINES", side_panel_x, 488, 22, @raylib.lightgray)
  @raylib.draw_text("\{game.lines}", side_panel_x, 516, 28, @raylib.raywhite)

  @raylib.draw_text("LEVEL", side_panel_x, 560, 22, @raylib.lightgray)
  @raylib.draw_text("\{game.level}", side_panel_x, 588, 28, @raylib.raywhite)

  let controls_y = 620
  @raylib.draw_text("L/R Move", 20, controls_y, 18, @raylib.gray)
  @raylib.draw_text("UP/X Rotate", 120, controls_y, 18, @raylib.gray)
  @raylib.draw_text("Z CCW", 270, controls_y, 18, @raylib.gray)
  @raylib.draw_text("C Hold", 350, controls_y, 18, @raylib.gray)
  @raylib.draw_text("DOWN Soft", 20, controls_y + 22, 18, @raylib.gray)
  @raylib.draw_text("SPACE Hard", 140, controls_y + 22, 18, @raylib.gray)
  @raylib.draw_text("R Restart", 290, controls_y + 22, 18, @raylib.gray)
}

///|
fn draw_game(game : Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.Color::new(12, 12, 20, 255))

  @raylib.draw_rectangle(
    board_x - 4,
    board_y - 4,
    board_cols * board_cell + 8,
    board_rows * board_cell + 8,
    @raylib.Color::new(18, 18, 28, 255),
  )

  for y = 0; y < board_rows; y = y + 1 {
    for x = 0; x < board_cols; x = x + 1 {
      let id = game.board[board_index(x, y)]
      if id == 0 {
        @raylib.draw_rectangle_lines(
          board_x + x * board_cell,
          board_y + y * board_cell,
          board_cell,
          board_cell,
          @raylib.Color::new(32, 32, 40, 255),
        )
      } else {
        draw_board_cell(x, y, id)
      }
    }
  }

  if not(game.over) {
    let gy = ghost_y(game)
    let ghost = @raylib.Color::new(80, 80, 95, 160)
    draw_piece_blocks(
      game.piece_kind,
      game.piece_rot,
      game.piece_x,
      gy,
      board_cell,
      board_x,
      board_y,
      ghost,
    )
    let color = piece_color(game.piece_kind + 1)
    draw_piece_blocks(
      game.piece_kind,
      game.piece_rot,
      game.piece_x,
      game.piece_y,
      board_cell,
      board_x,
      board_y,
      color,
    )
  }

  @raylib.draw_text("TETRIS: METEOR FALL", board_x, 2, 22, @raylib.raywhite)
  draw_hud(game)

  if game.over {
    @raylib.draw_rectangle(
      board_x + 25,
      board_y + 220,
      250,
      130,
      @raylib.fade(@raylib.black, 0.75),
    )
    @raylib.draw_text("GAME OVER", board_x + 56, board_y + 248, 38, @raylib.red)
    @raylib.draw_text(
      "Press R to restart",
      board_x + 65,
      board_y + 302,
      24,
      @raylib.raywhite,
    )
  }

  @raylib.end_drawing()
}
