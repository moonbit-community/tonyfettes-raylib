///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_pie_slices = 10
  let deg2rad : Float = Float::from_double(@math.PI) / 180.0
  let rad2deg : Float = 180.0 / Float::from_double(@math.PI)

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - pie chart",
  )

  let slice_count : Ref[Int] = Ref::new(7)
  let donut_inner_radius : Ref[Float] = Ref::new(25.0)
  let values : Array[Ref[Float]] = Array::make(max_pie_slices, Ref::new(0.0))
  // Re-initialize each element to have its own Ref
  values[0] = Ref::new(300.0)
  values[1] = Ref::new(100.0)
  values[2] = Ref::new(450.0)
  values[3] = Ref::new(350.0)
  values[4] = Ref::new(600.0)
  values[5] = Ref::new(380.0)
  values[6] = Ref::new(750.0)
  for i = 7; i < max_pie_slices; i = i + 1 {
    values[i] = Ref::new(0.0)
  }

  let labels : Array[Ref[String]] = Array::make(max_pie_slices, Ref::new(""))
  let editing_label : Array[Bool] = Array::make(max_pie_slices, false)
  for i = 0; i < max_pie_slices; i = i + 1 {
    let num = i + 1
    let padded = if num < 10 { "0" } else { "" }
    labels[i] = Ref::new("Slice " + padded + num.to_string())
  }

  let show_values : Ref[Bool] = Ref::new(true)
  let show_percentages : Ref[Bool] = Ref::new(false)
  let show_donut : Ref[Bool] = Ref::new(false)
  let mut hovered_slice = -1

  // UI layout parameters
  let panel_width = 270
  let panel_margin = 5

  // UI Panel top-left anchor
  let panel_pos_x : Float = Float::from_int(
    screen_width - panel_margin - panel_width,
  )
  let panel_pos_y : Float = Float::from_int(panel_margin)

  // UI Panel rectangle
  let panel_rect_x = panel_pos_x
  let panel_rect_y = panel_pos_y
  let panel_rect_w : Float = Float::from_int(panel_width)
  let panel_rect_h : Float = Float::from_int(screen_height) -
    2.0 * Float::from_int(panel_margin)

  // Pie chart geometry
  let canvas_w : Float = panel_pos_x
  let canvas_h : Float = Float::from_int(screen_height)
  let canvas = @raylib.Rectangle::new(0.0, 0.0, canvas_w, canvas_h)
  let center_x : Float = canvas_w / 2.0
  let center_y : Float = canvas_h / 2.0
  let center = @raylib.Vector2::new(center_x, center_y)
  let radius : Float = 205.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Calculate total value for percentage calculations
    let mut total_value : Float = 0.0
    for i = 0; i < slice_count.val; i = i + 1 {
      total_value = total_value + values[i].val
    }

    // Check for mouse hover over slices
    hovered_slice = -1
    let mouse_pos = @raylib.get_mouse_position()
    if @raylib.check_collision_point_rec(mouse_pos, canvas) {
      let dx = mouse_pos.x - center_x
      let dy = mouse_pos.y - center_y
      let distance = @math.hypotf(dx, dy)

      if distance <= radius {
        let mut angle = @math.atan2f(dy, dx) * rad2deg
        if angle < 0.0 {
          angle = angle + 360.0
        }

        let mut current_angle : Float = 0.0
        for i = 0; i < slice_count.val; i = i + 1 {
          let sweep = if total_value > 0.0 {
            values[i].val / total_value * 360.0
          } else {
            0.0
          }
          if angle >= current_angle && angle < current_angle + sweep {
            hovered_slice = i
            break
          }
          current_angle = current_angle + sweep
        }
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw the pie chart on the canvas
    let mut start_angle : Float = 0.0
    for i = 0; i < slice_count.val; i = i + 1 {
      let sweep_angle = if total_value > 0.0 {
        values[i].val / total_value * 360.0
      } else {
        0.0
      }
      let mid_angle = start_angle + sweep_angle / 2.0

      let color = @raylib.color_from_hsv(
        Float::from_int(i) / Float::from_int(slice_count.val) * 360.0,
        0.75,
        0.9,
      )
      let mut current_radius = radius

      // Make the hovered slice pop out by adding 20 pixels to its radius
      if i == hovered_slice {
        current_radius = current_radius + 20.0
      }

      // Draw the pie slice
      @raylib.draw_circle_sector(
        center,
        current_radius,
        start_angle,
        start_angle + sweep_angle,
        120,
        color,
      )

      // Draw the label for the current slice
      if values[i].val > 0.0 {
        let label_text = if show_values.val && show_percentages.val {
          let pct = values[i].val / total_value * 100.0
          values[i].val.to_string() + " (" + pct.to_int().to_string() + "%)"
        } else if show_values.val {
          values[i].val.to_string()
        } else if show_percentages.val {
          let pct = values[i].val / total_value * 100.0
          pct.to_int().to_string() + "%"
        } else {
          ""
        }

        if label_text.length() > 0 {
          let text_size = @raylib.measure_text_ex(
            @raylib.get_font_default(),
            label_text,
            20.0,
            1.0,
          )
          let label_radius = radius * 0.7
          let label_x = center_x +
            @math.cosf(mid_angle * deg2rad) * label_radius -
            text_size.x / 2.0
          let label_y = center_y +
            @math.sinf(mid_angle * deg2rad) * label_radius -
            text_size.y / 2.0
          @raylib.draw_text(
            label_text,
            label_x.to_int(),
            label_y.to_int(),
            20,
            @raylib.white,
          )
        }
      }

      // Draw inner circle to create donut effect
      if show_donut.val {
        @raylib.draw_circle(
          center_x.to_int(),
          center_y.to_int(),
          donut_inner_radius.val,
          @raylib.raywhite,
        )
      }

      start_angle = start_angle + sweep_angle
    }

    // UI control panel
    let panel_rect = @raylib.Rectangle::new(
      panel_rect_x, panel_rect_y, panel_rect_w, panel_rect_h,
    )
    @raylib.draw_rectangle_rec(panel_rect, @raylib.fade(@raylib.lightgray, 0.5))
    @raylib.draw_rectangle_lines_ex(panel_rect, 1.0, @raylib.gray)

    @raygui.gui_spinner(
      @raylib.Rectangle::new(
        panel_pos_x + 95.0,
        panel_pos_y + 12.0,
        125.0,
        25.0,
      ),
      "Slices ",
      slice_count,
      1,
      max_pie_slices,
      false,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(
        panel_pos_x + 20.0,
        panel_pos_y + 12.0 + 40.0,
        20.0,
        20.0,
      ),
      "Show Values",
      show_values,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(
        panel_pos_x + 20.0,
        panel_pos_y + 12.0 + 70.0,
        20.0,
        20.0,
      ),
      "Show Percentages",
      show_percentages,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(
        panel_pos_x + 20.0,
        panel_pos_y + 12.0 + 100.0,
        20.0,
        20.0,
      ),
      "Make Donut",
      show_donut,
    )
    |> ignore

    if show_donut.val {
      @raygui.gui_disable()
    }
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(
        panel_pos_x + 80.0,
        panel_pos_y + 12.0 + 130.0,
        panel_rect_w - 100.0,
        30.0,
      ),
      "Inner Radius",
      "",
      donut_inner_radius,
      5.0,
      radius - 10.0,
    )
    |> ignore
    @raygui.gui_enable()

    @raygui.gui_line(
      @raylib.Rectangle::new(
        panel_pos_x + 10.0,
        panel_pos_y + 12.0 + 170.0,
        panel_rect_w - 20.0,
        1.0,
      ),
      "",
    )

    // Scrollable area for slice editors
    let scroll_bounds_x = panel_pos_x + Float::from_int(panel_margin)
    let scroll_bounds_y = panel_pos_y + 12.0 + 190.0
    let scroll_bounds_w = panel_rect_w - Float::from_int(panel_margin) * 2.0
    let scroll_bounds_h = panel_rect_y +
      panel_rect_h -
      scroll_bounds_y -
      Float::from_int(panel_margin)
    let content_height = slice_count.val * 35

    let scroll : Ref[@raylib.Vector2] = Ref::new(@raylib.Vector2::new(0.0, 0.0))
    let view : Ref[@raylib.Rectangle] = Ref::new(
      @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
    )

    @raygui.gui_scroll_panel(
      @raylib.Rectangle::new(
        scroll_bounds_x, scroll_bounds_y, scroll_bounds_w, scroll_bounds_h,
      ),
      "",
      @raylib.Rectangle::new(
        0.0,
        0.0,
        panel_rect_w - 25.0,
        Float::from_int(content_height),
      ),
      scroll,
      view,
    )

    let view_x = view.val.x
    let view_y = view.val.y
    let view_w = view.val.width
    let view_h = view.val.height
    let content_x = view_x + scroll.val.x
    let content_y = view_y + scroll.val.y

    @raylib.begin_scissor_mode(
      view_x.to_int(),
      view_y.to_int(),
      view_w.to_int(),
      view_h.to_int(),
    )

    for i = 0; i < slice_count.val; i = i + 1 {
      let row_y = (content_y + 5.0 + Float::from_int(i * 35)).to_int()

      // Color indicator
      let color = @raylib.color_from_hsv(
        Float::from_int(i) / Float::from_int(slice_count.val) * 360.0,
        0.75,
        0.9,
      )
      @raylib.draw_rectangle(
        (content_x + 15.0).to_int(),
        row_y + 5,
        20,
        20,
        color,
      )

      // Label textbox
      if @raygui.gui_text_box(
          @raylib.Rectangle::new(
            content_x + 45.0,
            Float::from_int(row_y),
            75.0,
            30.0,
          ),
          labels[i],
          32,
          editing_label[i],
        ) {
        editing_label[i] = not(editing_label[i])
      }

      // Value slider
      @raygui.gui_slider_bar(
        @raylib.Rectangle::new(
          content_x + 130.0,
          Float::from_int(row_y),
          110.0,
          30.0,
        ),
        "",
        "",
        values[i],
        0.0,
        1000.0,
      )
      |> ignore
    }

    @raylib.end_scissor_mode()

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
