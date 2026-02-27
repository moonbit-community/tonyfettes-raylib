// Minesweeper — Full-featured port from C++ to MoonBit
// Features: difficulty menu, touch gestures, camera zoom/pan, header bar, game over overlay

///|
fn main {
  @raylib.init_window(0, 0, "Minesweeper")
  @raylib.set_target_fps(60)
  @raylib.set_exit_key(0)
  screen.width = @raylib.get_screen_width()
  screen.height = @raylib.get_screen_height()
  screen.header_height = Float::from_int(screen.height) * header_height_ratio
  screen.footer_height = Float::from_int(screen.height) * footer_height_ratio
  while not(@raylib.window_should_close()) {
    update()
    render()
  }
  @raylib.close_window()
}
