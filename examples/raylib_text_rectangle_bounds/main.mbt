///|
fn draw_text_boxed(
  font : @raylib.Font,
  text : String,
  rec : @raylib.Rectangle,
  font_size : Float,
  spacing : Float,
  word_wrap : Bool,
  tint : @raylib.Color,
) -> Unit {
  draw_text_boxed_selectable(
    font, text, rec, font_size, spacing, word_wrap, tint, 0, 0, @raylib.white, @raylib.white,
  )
}

///|
fn draw_text_boxed_selectable(
  font : @raylib.Font,
  text : String,
  rec : @raylib.Rectangle,
  font_size : Float,
  spacing : Float,
  word_wrap : Bool,
  tint : @raylib.Color,
  select_start : Int,
  select_length : Int,
  select_tint : @raylib.Color,
  select_back_tint : @raylib.Color,
) -> Unit {
  // Convert text to codepoints for proper iteration
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  let base_size_info = @raylib.measure_text_ex(font, "A", font_size, spacing)
  // Approximate base size from font measurement
  let scale_factor = font_size / base_size_info.y
  let base_size = base_size_info.y / scale_factor
  let mut text_offset_y : Float = 0.0
  let mut text_offset_x : Float = 0.0

  // Word/character wrapping mechanism variables
  let measure_state = 0
  let draw_state = 1
  let mut state = if word_wrap { measure_state } else { draw_state }
  let mut start_line = -1
  let mut end_line = -1
  let mut lastk = -1
  let mut select_start_mut = select_start
  let mut i = 0
  let mut k = 0
  while i < length {
    let codepoint = codepoints[i]
    let glyph_info = @raylib.get_glyph_info(font, codepoint)
    let glyph_rec = @raylib.get_glyph_atlas_rec(font, codepoint)
    let mut glyph_width : Float = 0.0
    if codepoint != '\n'.to_int() {
      glyph_width = if glyph_info.advance_x == 0 {
        glyph_rec.width * scale_factor
      } else {
        Float::from_int(glyph_info.advance_x) * scale_factor
      }
      if i + 1 < length {
        glyph_width = glyph_width + spacing
      }
    }

    // Measure state: determine line boundaries for word wrapping
    if state == measure_state {
      if codepoint == ' '.to_int() ||
        codepoint == '\t'.to_int() ||
        codepoint == '\n'.to_int() {
        end_line = i
      }
      if text_offset_x + glyph_width > rec.width {
        end_line = if end_line < 1 { i } else { end_line }
        if i == end_line {
          end_line = end_line - 1
        }
        if start_line + 1 == end_line {
          end_line = i - 1
        }
        state = draw_state
      } else if i + 1 == length {
        end_line = i
        state = draw_state
      } else if codepoint == '\n'.to_int() {
        state = draw_state
      }
      if state == draw_state {
        text_offset_x = 0.0
        i = start_line
        glyph_width = 0.0
        // Save character position when we switch states
        let tmp = lastk
        lastk = k - 1
        k = tmp
      }
    } else {
      // Draw state
      if codepoint == '\n'.to_int() {
        if not(word_wrap) {
          text_offset_y += (base_size + base_size / 2.0) * scale_factor
          text_offset_x = 0.0
        }
      } else {
        if not(word_wrap) && text_offset_x + glyph_width > rec.width {
          text_offset_y += (base_size + base_size / 2.0) * scale_factor
          text_offset_x = 0.0
        }
        // When text overflows rectangle height limit, just stop drawing
        if text_offset_y + base_size * scale_factor > rec.height {
          break
        }
        // Draw selection background
        let mut is_glyph_selected = false
        if select_start_mut >= 0 &&
          k >= select_start_mut &&
          k < select_start_mut + select_length {
          @raylib.draw_rectangle_rec(
            @raylib.Rectangle::new(
              rec.x + text_offset_x - 1.0,
              rec.y + text_offset_y,
              glyph_width,
              base_size * scale_factor,
            ),
            select_back_tint,
          )
          is_glyph_selected = true
        }
        // Draw current character glyph
        if codepoint != ' '.to_int() && codepoint != '\t'.to_int() {
          @raylib.draw_text_codepoint(
            font,
            codepoint,
            @raylib.Vector2::new(rec.x + text_offset_x, rec.y + text_offset_y),
            font_size,
            if is_glyph_selected {
              select_tint
            } else {
              tint
            },
          )
        }
      }
      if word_wrap && i == end_line {
        text_offset_y += (base_size + base_size / 2.0) * scale_factor
        text_offset_x = 0.0
        start_line = end_line
        end_line = -1
        glyph_width = 0.0
        select_start_mut += lastk - k
        k = lastk
        state = measure_state
      }
    }
    if text_offset_x != 0.0 || codepoint != ' '.to_int() {
      text_offset_x += glyph_width
    }
    i += 1
    k += 1
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - draw text inside a rectangle",
  )
  let text = "Text cannot escape\tthis container\t...word wrap also works when active so here's a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."
  let mut resizing = false
  let mut word_wrap = true
  let container_x : Float = 25.0
  let container_y : Float = 25.0
  let mut container_w : Float = Float::from_int(screen_width) - 50.0
  let mut container_h : Float = Float::from_int(screen_height) - 250.0
  let min_width : Float = 60.0
  let min_height : Float = 60.0
  let max_width : Float = Float::from_int(screen_width) - 50.0
  let max_height : Float = Float::from_int(screen_height) - 160.0
  let mut last_mouse_x : Float = 0.0
  let mut last_mouse_y : Float = 0.0
  let mut border_color = @raylib.maroon
  let font = @raylib.get_font_default()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      word_wrap = not(word_wrap)
    }
    let mouse = @raylib.get_mouse_position()
    let container = @raylib.Rectangle::new(
      container_x, container_y, container_w, container_h,
    )

    // Check if the mouse is inside the container and toggle border color
    if @raylib.check_collision_point_rec(mouse, container) {
      border_color = @raylib.fade(@raylib.maroon, 0.4)
    } else if not(resizing) {
      border_color = @raylib.maroon
    }

    // Container resizing logic
    let resizer = @raylib.Rectangle::new(
      container_x + container_w - 17.0,
      container_y + container_h - 17.0,
      14.0,
      14.0,
    )
    if resizing {
      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        resizing = false
      }
      let width = container_w + (mouse.x - last_mouse_x)
      container_w = if width > min_width {
        if width < max_width {
          width
        } else {
          max_width
        }
      } else {
        min_width
      }
      let height = container_h + (mouse.y - last_mouse_y)
      container_h = if height > min_height {
        if height < max_height {
          height
        } else {
          max_height
        }
      } else {
        min_height
      }
    } else if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) &&
      @raylib.check_collision_point_rec(mouse, resizer) {
      resizing = true
    }
    last_mouse_x = mouse.x
    last_mouse_y = mouse.y

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw container border
    let container = @raylib.Rectangle::new(
      container_x, container_y, container_w, container_h,
    )
    @raylib.draw_rectangle_lines_ex(container, 3.0, border_color)

    // Draw text in container (add some padding)
    draw_text_boxed(
      font,
      text,
      @raylib.Rectangle::new(
        container_x + 4.0,
        container_y + 4.0,
        container_w - 4.0,
        container_h - 4.0,
      ),
      20.0,
      2.0,
      word_wrap,
      @raylib.gray,
    )

    // Draw the resize box
    let resizer = @raylib.Rectangle::new(
      container_x + container_w - 17.0,
      container_y + container_h - 17.0,
      14.0,
      14.0,
    )
    @raylib.draw_rectangle_rec(resizer, border_color)

    // Draw bottom info
    @raylib.draw_rectangle(
      0,
      screen_height - 54,
      screen_width,
      54,
      @raylib.gray,
    )
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(
        382.0,
        Float::from_int(screen_height) - 34.0,
        12.0,
        12.0,
      ),
      @raylib.maroon,
    )
    @raylib.draw_text(
      "Word Wrap: ",
      313,
      screen_height - 115,
      20,
      @raylib.black,
    )
    if word_wrap {
      @raylib.draw_text("ON", 447, screen_height - 115, 20, @raylib.red)
    } else {
      @raylib.draw_text("OFF", 447, screen_height - 115, 20, @raylib.black)
    }
    @raylib.draw_text(
      "Press [SPACE] to toggle word wrap",
      218,
      screen_height - 86,
      20,
      @raylib.gray,
    )
    @raylib.draw_text(
      "Click hold & drag the    to resize the container",
      155,
      screen_height - 38,
      20,
      @raylib.raywhite,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
