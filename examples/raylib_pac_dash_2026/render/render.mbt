///|
fn draw_maze(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.maze_x - 4,
    @types.maze_y - 4,
    @types.maze_cols * @types.tile_size + 8,
    @types.maze_rows * @types.tile_size + 8,
    @raylib.Color::new(12, 12, 34, 255),
  )

  for y in 0..<@types.maze_rows {
    for x in 0..<@types.maze_cols {
      let i = @types.map_index(x, y)
      let px = @types.maze_x + x * @types.tile_size
      let py = @types.maze_y + y * @types.tile_size
      if game.walls[i] != 0 {
        @raylib.draw_rectangle(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(24, 60, 185, 255),
        )
      } else {
        @raylib.draw_rectangle(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(8, 8, 18, 255),
        )
        match game.pellets[i] {
          1 =>
            @raylib.draw_circle(
              @types.tile_center_x(x),
              @types.tile_center_y(y),
              3.0,
              @raylib.raywhite,
            )
          2 =>
            @raylib.draw_circle(
              @types.tile_center_x(x),
              @types.tile_center_y(y),
              6.0,
              @raylib.orange,
            )
          _ => ()
        }
      }
    }
  }
}

///|
fn draw_player(game : @types.Game) -> Unit {
  let cx = @types.tile_center_x(game.player_x)
  let cy = @types.tile_center_y(game.player_y)
  @raylib.draw_circle(cx, cy, 9.0, @raylib.yellow)
  @raylib.draw_circle(cx + 3, cy - 2, 2.0, @raylib.black)
}

///|
fn draw_ghosts(game : @types.Game) -> Unit {
  for ghost in game.ghosts {
    let cx = @types.tile_center_x(ghost.x)
    let cy = @types.tile_center_y(ghost.y)
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
fn draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_text("PAC DASH 2026", @types.hud_x, 30, 30, @raylib.raywhite)
  @raylib.draw_text("Score", @types.hud_x, 90, 24, @raylib.lightgray)
  @raylib.draw_text("\{game.score}", @types.hud_x, 118, 32, @raylib.yellow)
  @raylib.draw_text("Lives", @types.hud_x, 170, 24, @raylib.lightgray)
  @raylib.draw_text("\{game.lives}", @types.hud_x, 198, 30, @raylib.orange)
  @raylib.draw_text("Pellets", @types.hud_x, 246, 24, @raylib.lightgray)
  @raylib.draw_text(
    "\{game.pellets_left}",
    @types.hud_x,
    274,
    30,
    @raylib.raywhite,
  )

  let mode = if game.frightened_timer > 0.0 {
    "Frightened"
  } else if game.chase_mode {
    "Chase"
  } else {
    "Scatter"
  }
  @raylib.draw_text("Mode", @types.hud_x, 322, 24, @raylib.lightgray)
  @raylib.draw_text(mode, @types.hud_x, 350, 28, @raylib.skyblue)

  @raylib.draw_text("Controls", @types.hud_x, 416, 24, @raylib.lightgray)
  @raylib.draw_text("WASD / Arrows", @types.hud_x, 445, 20, @raylib.gray)
  @raylib.draw_text("R: Restart", @types.hud_x, 468, 20, @raylib.gray)

  if game.game_over {
    let msg = if game.win { "YOU WIN" } else { "GAME OVER" }
    let color = if game.win { @raylib.lime } else { @raylib.red }
    @raylib.draw_text(msg, @types.hud_x, 520, 34, color)
  }
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.Color::new(5, 5, 10, 255))
  draw_maze(game)
  draw_player(game)
  draw_ghosts(game)
  draw_hud(game)
  @raylib.end_drawing()
}
