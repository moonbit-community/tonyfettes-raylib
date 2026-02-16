///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - drop files",
  )
  let file_paths : Array[String] = []
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_file_dropped() {
      let dropped_files = @raylib.load_dropped_files()
      let count = @raylib.file_path_list_count(dropped_files)
      for i = 0; i < count; i = i + 1 {
        file_paths.push(@raylib.file_path_list_get(dropped_files, i))
      }
      @raylib.unload_dropped_files(dropped_files)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    if file_paths.length() == 0 {
      @raylib.draw_text(
        "Drop your files to this window!", 100, 40, 20, @raylib.darkgray,
      )
    } else {
      @raylib.draw_text("Dropped files:", 100, 40, 20, @raylib.darkgray)
      for i = 0; i < file_paths.length(); i = i + 1 {
        if i % 2 == 0 {
          @raylib.draw_rectangle(
            0,
            85 + 40 * i,
            screen_width,
            40,
            @raylib.fade(@raylib.lightgray, 0.5),
          )
        } else {
          @raylib.draw_rectangle(
            0,
            85 + 40 * i,
            screen_width,
            40,
            @raylib.fade(@raylib.lightgray, 0.3),
          )
        }
        @raylib.draw_text(file_paths[i], 120, 100 + 40 * i, 10, @raylib.gray)
      }
      @raylib.draw_text(
        "Drop new files...",
        100,
        110 + 40 * file_paths.length(),
        20,
        @raylib.darkgray,
      )
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
