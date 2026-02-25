///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - clipboard text",
  )

  // Define some sample texts
  let sample_texts : Array[String] = [
    "Hello from raylib!", "The quick brown fox jumps over the lazy dog", "Clipboard operations are useful!",
    "raylib is a simple and easy-to-use library", "Copy and paste me!",
  ]

  let mut clipboard_text : String = ""
  let input_buffer : Ref[String] = { val: "Hello from raylib!" }

  // UI required variables
  let mut text_box_edit_mode = false

  let mut btn_cut_pressed = false
  let mut btn_copy_pressed = false
  let mut btn_paste_pressed = false
  let mut btn_clear_pressed = false
  let mut btn_random_pressed = false

  // Set UI style
  @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, 20)
  @raygui.gui_set_icon_scale(2)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Handle button interactions
    if btn_cut_pressed {
      @raylib.set_clipboard_text(input_buffer.val)
      clipboard_text = @raylib.get_clipboard_text()
      input_buffer.val = ""
    }

    if btn_copy_pressed {
      @raylib.set_clipboard_text(input_buffer.val)
      clipboard_text = @raylib.get_clipboard_text()
    }

    if btn_paste_pressed {
      clipboard_text = @raylib.get_clipboard_text()
      input_buffer.val = clipboard_text
    }

    if btn_clear_pressed {
      input_buffer.val = ""
    }

    if btn_random_pressed {
      input_buffer.val = sample_texts[@raylib.get_random_value(0, 4)]
    }

    // Quick cut/copy/paste with keyboard shortcuts
    if @raylib.is_key_down(@raylib.KeyLeftControl) ||
      @raylib.is_key_down(@raylib.KeyRightControl) {
      if @raylib.is_key_pressed(@raylib.KeyX) {
        @raylib.set_clipboard_text(input_buffer.val)
        input_buffer.val = ""
      }
      if @raylib.is_key_pressed(@raylib.KeyC) {
        @raylib.set_clipboard_text(input_buffer.val)
      }
      if @raylib.is_key_pressed(@raylib.KeyV) {
        clipboard_text = @raylib.get_clipboard_text()
        input_buffer.val = clipboard_text
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw instructions
    @raygui.gui_label(
      @raylib.Rectangle::new(50.0, 20.0, 700.0, 36.0),
      "Use the BUTTONS or KEY SHORTCUTS:",
    )
    @raylib.draw_text(
      "[CTRL+X] - CUT | [CTRL+C] COPY | [CTRL+V] | PASTE", 50, 60, 20, @raylib.maroon,
    )

    // Draw text box
    if @raygui.gui_text_box(
        @raylib.Rectangle::new(50.0, 120.0, 652.0, 40.0),
        input_buffer,
        256,
        text_box_edit_mode,
      ) {
      text_box_edit_mode = not(text_box_edit_mode)
    }

    // Random text button
    btn_random_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(710.0, 120.0, 40.0, 40.0),
      "#77#",
    )

    // Draw buttons
    btn_cut_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(50.0, 180.0, 158.0, 40.0),
      "#17#CUT",
    )
    btn_copy_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(215.0, 180.0, 158.0, 40.0),
      "#16#COPY",
    )
    btn_paste_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(380.0, 180.0, 158.0, 40.0),
      "#18#PASTE",
    )
    btn_clear_pressed = @raygui.gui_button(
      @raylib.Rectangle::new(545.0, 180.0, 158.0, 40.0),
      "#143#CLEAR",
    )

    // Draw clipboard status
    @raygui.gui_disable()
    @raygui.gui_label(
      @raylib.Rectangle::new(50.0, 260.0, 700.0, 40.0),
      "Clipboard current text data:",
    )
    @raygui.gui_set_style(@raygui.ControlTextbox, @raygui.TextReadonly, 1)
    let clipboard_ref : Ref[String] = { val: clipboard_text }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(50.0, 300.0, 700.0, 40.0),
      clipboard_ref,
      256,
      false,
    )
    |> ignore
    @raygui.gui_set_style(@raygui.ControlTextbox, @raygui.TextReadonly, 0)
    @raygui.gui_label(
      @raylib.Rectangle::new(50.0, 360.0, 700.0, 40.0),
      "Try copying text from other applications and pasting here!",
    )
    @raygui.gui_enable()

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
