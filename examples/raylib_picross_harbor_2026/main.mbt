///|
fn main {
  @raylib.init_window(
    @types.screen_w,
    @types.screen_h,
    "raylib [game] picross harbor 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)

  let game = @types.Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
