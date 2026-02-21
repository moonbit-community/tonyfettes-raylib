///|
fn main {
  @raylib.init_window(screen_width, screen_height, "Asteroid Salvage 2026")
  @raylib.set_target_fps(60)

  let game = Game::new()
  reset_game(game)

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }
    update_game(game, dt)
    draw_game(game)
  }

  @raylib.close_window()
}
