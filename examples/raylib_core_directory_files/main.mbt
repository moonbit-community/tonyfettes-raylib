///|
fn file_path_list_to_array(files : @raylib.FilePathList) -> Array[String] {
  let count = @raylib.file_path_list_count(files)
  let arr : Array[String] = []
  for i = 0; i < count; i = i + 1 {
    arr.push(@raylib.file_path_list_get(files, i))
  }
  arr
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - directory files",
  )
  @raygui.gui_load_style_default()
  let mut directory = @raylib.get_working_directory()
  // Load file-paths on current working directory with filter
  let mut files = @raylib.load_directory_files_ex(directory, ".png;.c", false)
  let mut items = file_path_list_to_array(files)
  let mut btn_back_pressed = false
  let list_scroll_index : Ref[Int] = { val: 0 }
  let list_item_active : Ref[Int] = { val: -1 }
  let list_item_focused : Ref[Int] = { val: -1 }
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if btn_back_pressed {
      directory = @raylib.get_prev_directory_path(directory)
      @raylib.unload_directory_files(files)
      files = @raylib.load_directory_files(directory)
      items = file_path_list_to_array(files)
    }
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    // Back button
    btn_back_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(40.0, 10.0, 48.0, 28.0),
      "<",
    )
    // Directory label with larger text
    let base_size = @raygui.gui_get_style(
      @raygui.ControlDefault,
      @raygui.TextSize,
    )
    @raygui.gui_set_style(
      @raygui.ControlDefault,
      @raygui.TextSize,
      base_size * 2,
    )
    @raygui.gui_label(
      @raylib.Rectangle::new(98.0, 10.0, 700.0, 28.0),
      directory,
    )
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, base_size)
    // List view with directory contents
    @raygui.gui_set_style(
      @raygui.ControlListview,
      @raygui.TextAlignment,
      @raygui.TextAlignLeft,
    )
    @raygui.gui_set_style(@raygui.ControlListview, @raygui.TextPadding, 40)
    @raygui.gui_list_view_ex(
      @raylib.Rectangle::new(
        0.0,
        50.0,
        Float::from_int(@raylib.get_screen_width()),
        Float::from_int(@raylib.get_screen_height() - 50),
      ),
      items,
      list_scroll_index,
      list_item_active,
      list_item_focused,
    )
    |> ignore
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_directory_files(files)
  @raylib.close_window()
}
