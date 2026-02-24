///|
fn tile_center_x(x : Int) -> Int {
  maze_x + x * tile_size + tile_size / 2
}

///|
fn tile_center_y(y : Int) -> Int {
  maze_y + y * tile_size + tile_size / 2
}

///|
fn draw_maze(game : Game) -> Unit {
  @raylib.draw_rectangle(
    maze_x - 4,
    maze_y - 4,
    maze_cols * tile_size + 8,
    maze_rows * tile_size + 8,
    @raylib.Color::new(12, 12, 34, 255),
  )

  for y = 0; y < maze_rows; y = y + 1 {
    for x = 0; x < maze_cols; x = x + 1 {
      let i = map_index(x, y)
      let px = maze_x + x * tile_size
      let py = maze_y + y * tile_size
      if game.walls[i] != 0 {
        @raylib.draw_rectangle(px, py, tile_size, tile_size, @raylib.Color::new(24, 60, 185, 255))
      } else {
        @raylib.draw_rectangle(px, py, tile_size, tile_size, @raylib.Color::new(8, 8, 18, 255))
        match game.pellets[i] {
          1 =>
            @raylib.draw_circle(tile_center_x(x), tile_center_y(y), 3.0, @raylib.raywhite)
          2 =>
            @raylib.draw_circle(tile_center_x(x), tile_center_y(y), 6.0, @raylib.orange)
          _ => ()
        }
      }
    }
  }
}

///|
fn draw_player(game : Game) -> Unit {
  let cx = tile_center_x(game.player_x)
  let cy = tile_center_y(game.player_y)
  @raylib.draw_circle(cx, cy, 9.0, @raylib.yellow)
  @raylib.draw_circle(cx + 3, cy - 2, 2.0, @raylib.black)
}

///|
fn draw_ghosts(game : Game) -> Unit {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    let ghost = game.ghosts[i]
    let cx = tile_center_x(ghost.x)
    let cy = tile_center_y(ghost.y)
    let color = if game.frightened_timer > 0.0 {
      @raylib.Color::new(65, 135, 255, 255)
    } else {
      ghost.color
    }
    @raylib.draw_circle(cx, cy - 2, 9.0, color)
    @raylib.draw_rectangle(cx - 9, cy - 2, 18, 11, color)
    @raylib.draw_circle(cx - 3, cy - 2, 2.0, @raylib.white)
    @raylib.draw_circle(cx + 3, cy - 2, 2.0, @raylib.white)
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_text("PAC DASH 2026", hud_x, 30, 30, @raylib.raywhite)
  @raylib.draw_text("Score", hud_x, 90, 24, @raylib.lightgray)
  @raylib.draw_text("\{game.score}", hud_x, 118, 32, @raylib.yellow)
  @raylib.draw_text("Lives", hud_x, 170, 24, @raylib.lightgray)
  @raylib.draw_text("\{game.lives}", hud_x, 198, 30, @raylib.orange)
  @raylib.draw_text("Pellets", hud_x, 246, 24, @raylib.lightgray)
  @raylib.draw_text("\{game.pellets_left}", hud_x, 274, 30, @raylib.raywhite)

  let mode = if game.frightened_timer > 0.0 {
    "Frightened"
  } else if game.chase_mode {
    "Chase"
  } else {
    "Scatter"
  }
  @raylib.draw_text("Mode", hud_x, 322, 24, @raylib.lightgray)
  @raylib.draw_text(mode, hud_x, 350, 28, @raylib.skyblue)

  @raylib.draw_text("Controls", hud_x, 416, 24, @raylib.lightgray)
  @raylib.draw_text("WASD / Arrows", hud_x, 445, 20, @raylib.gray)
  @raylib.draw_text("R: Restart", hud_x, 468, 20, @raylib.gray)

  if game.game_over {
    let msg = if game.win { "YOU WIN" } else { "GAME OVER" }
    let color = if game.win { @raylib.lime } else { @raylib.red }
    @raylib.draw_text(msg, hud_x, 520, 34, color)
  }
}

///|
fn draw_game(game : Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.Color::new(5, 5, 10, 255))
  draw_maze(game)
  draw_player(game)
  draw_ghosts(game)
  draw_hud(game)
  @raylib.end_drawing()
}
