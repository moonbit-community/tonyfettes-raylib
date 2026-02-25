///|
struct Line {
  mut start : @raylib.Vector2
  mut end_ : @raylib.Vector2
}

///|
let max_draw_lines : Int = 8192

///|
fn vec2_rotate(v : @raylib.Vector2, angle : Float) -> @raylib.Vector2 {
  let c = @math.cosf(angle)
  let s = @math.sinf(angle)
  @raylib.Vector2::new(v.x * c - v.y * s, v.x * s + v.y * c)
}

///|
fn vec2_multiply(a : @raylib.Vector2, b : @raylib.Vector2) -> @raylib.Vector2 {
  @raylib.Vector2::new(a.x * b.x, a.y * b.y)
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - kaleidoscope",
  )

  // Line drawing properties
  let symmetry = 6
  let deg2rad : Float = Float::from_double(@math.PI) / 180.0
  let angle : Float = 360.0 / Float::from_int(symmetry)
  let thickness : Float = 3.0
  let sw = Float::from_int(screen_width)
  let sh = Float::from_int(screen_height)
  let reset_button_rec = @raylib.Rectangle::new(sw - 55.0, 5.0, 50.0, 25.0)
  let back_button_rec = @raylib.Rectangle::new(sw - 55.0, sh - 30.0, 25.0, 25.0)
  let next_button_rec = @raylib.Rectangle::new(sw - 30.0, sh - 30.0, 25.0, 25.0)
  let scale_vector = @raylib.Vector2::new(1.0, -1.0)
  let offset = @raylib.Vector2::new(sw / 2.0, sh / 2.0)

  let camera = @raylib.Camera2D::new(
    offset,
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )

  // Lines array
  let lines : Array[Line] = Array::make(max_draw_lines, {
    start: @raylib.Vector2::new(0.0, 0.0),
    end_: @raylib.Vector2::new(0.0, 0.0),
  })

  let mut mouse_pos = @raylib.Vector2::new(0.0, 0.0)
  let mut prev_mouse_pos = @raylib.Vector2::new(0.0, 0.0)
  let mut current_line_counter = 0
  let mut total_line_counter = 0
  let mut reset_button_clicked = false
  let mut back_button_clicked = false
  let mut next_button_clicked = false

  @raylib.set_target_fps(20)

  while not(@raylib.window_should_close()) {
    // Update
    prev_mouse_pos = mouse_pos
    mouse_pos = @raylib.get_mouse_position()

    let mut line_start = @raylib.Vector2::new(
      mouse_pos.x - offset.x,
      mouse_pos.y - offset.y,
    )
    let mut line_end = @raylib.Vector2::new(
      prev_mouse_pos.x - offset.x,
      prev_mouse_pos.y - offset.y,
    )

    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) &&
      not(@raylib.check_collision_point_rec(mouse_pos, reset_button_rec)) &&
      not(@raylib.check_collision_point_rec(mouse_pos, back_button_rec)) &&
      not(@raylib.check_collision_point_rec(mouse_pos, next_button_rec)) {
      for s = 0
          s < symmetry && total_line_counter < max_draw_lines - 1
          s = s + 1 {
        line_start = vec2_rotate(line_start, angle * deg2rad)
        line_end = vec2_rotate(line_end, angle * deg2rad)

        // Store mouse line
        lines[total_line_counter].start = line_start
        lines[total_line_counter].end_ = line_end

        // Store reflective line
        lines[total_line_counter + 1].start = vec2_multiply(
          line_start, scale_vector,
        )
        lines[total_line_counter + 1].end_ = vec2_multiply(
          line_end, scale_vector,
        )

        total_line_counter += 2
        current_line_counter = total_line_counter
      }
    }

    if reset_button_clicked {
      for i = 0; i < max_draw_lines; i = i + 1 {
        lines[i].start = @raylib.Vector2::new(0.0, 0.0)
        lines[i].end_ = @raylib.Vector2::new(0.0, 0.0)
      }
      current_line_counter = 0
      total_line_counter = 0
    }

    if back_button_clicked && current_line_counter > 0 {
      current_line_counter -= 1
    }

    if next_button_clicked &&
      current_line_counter < max_draw_lines &&
      current_line_counter + 1 <= total_line_counter {
      current_line_counter += 1
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(camera)

    for s = 0; s < symmetry; s = s + 1 {
      let _ = s
      for i = 0; i < current_line_counter; i = i + 2 {
        @raylib.draw_line_ex(
          lines[i].start,
          lines[i].end_,
          thickness,
          @raylib.black,
        )
        @raylib.draw_line_ex(
          lines[i + 1].start,
          lines[i + 1].end_,
          thickness,
          @raylib.black,
        )
      }
    }

    @raylib.end_mode_2d()

    if current_line_counter - 1 < 0 {
      @raygui.gui_disable()
    }

    back_button_clicked = @raygui.gui_button(
      @raylib.Rectangle::new(
        back_button_rec.x,
        back_button_rec.y,
        back_button_rec.width,
        back_button_rec.height,
      ),
      "<",
    )
    @raygui.gui_enable()

    if current_line_counter + 1 > total_line_counter {
      @raygui.gui_disable()
    }

    next_button_clicked = @raygui.gui_button(
      @raylib.Rectangle::new(
        next_button_rec.x,
        next_button_rec.y,
        next_button_rec.width,
        next_button_rec.height,
      ),
      ">",
    )
    @raygui.gui_enable()

    reset_button_clicked = @raygui.gui_button(
      @raylib.Rectangle::new(
        reset_button_rec.x,
        reset_button_rec.y,
        reset_button_rec.width,
        reset_button_rec.height,
      ),
      "Reset",
    )

    @raylib.draw_text(
      "LINES: " +
      current_line_counter.to_string() +
      "/" +
      max_draw_lines.to_string(),
      10,
      screen_height - 30,
      20,
      @raylib.maroon,
    )
    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
