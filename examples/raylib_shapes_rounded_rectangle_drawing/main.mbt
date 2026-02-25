///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - rounded rectangle drawing",
  )

  let roundness : Ref[Float] = { val: 0.2 }
  let width : Ref[Float] = { val: 200.0 }
  let height : Ref[Float] = { val: 100.0 }
  let segments : Ref[Float] = { val: 0.0 }
  let line_thick : Ref[Float] = { val: 1.0 }

  let draw_rect : Ref[Bool] = { val: false }
  let draw_rounded_rect : Ref[Bool] = { val: true }
  let draw_rounded_lines : Ref[Bool] = { val: false }

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    let sw = Float::from_int(@raylib.get_screen_width())
    let sh = Float::from_int(@raylib.get_screen_height())
    let rec = @raylib.Rectangle::new(
      (sw - width.val - 250.0) / 2.0,
      (sh - height.val) / 2.0,
      width.val,
      height.val,
    )

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_line(
      560,
      0,
      560,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.6),
    )
    @raylib.draw_rectangle(
      560,
      0,
      @raylib.get_screen_width() - 500,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.3),
    )

    if draw_rect.val {
      @raylib.draw_rectangle_rec(rec, @raylib.fade(@raylib.gold, 0.6))
    }
    if draw_rounded_rect.val {
      @raylib.draw_rectangle_rounded(
        rec,
        roundness.val,
        segments.val.to_int(),
        @raylib.fade(@raylib.maroon, 0.2),
      )
    }
    if draw_rounded_lines.val {
      @raylib.draw_rectangle_rounded_lines_ex(
        rec,
        roundness.val,
        segments.val.to_int(),
        line_thick.val,
        @raylib.fade(@raylib.maroon, 0.4),
      )
    }

    // GUI controls
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 40.0, 105.0, 20.0),
      "Width",
      width.val.to_int().to_string(),
      width,
      0.0,
      sw - 300.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 70.0, 105.0, 20.0),
      "Height",
      height.val.to_int().to_string(),
      height,
      0.0,
      sh - 50.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 140.0, 105.0, 20.0),
      "Roundness",
      roundness.val.to_string(),
      roundness,
      0.0,
      1.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 170.0, 105.0, 20.0),
      "Thickness",
      line_thick.val.to_int().to_string(),
      line_thick,
      0.0,
      20.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 240.0, 105.0, 20.0),
      "Segments",
      segments.val.to_int().to_string(),
      segments,
      0.0,
      60.0,
    )
    |> ignore

    @raygui.gui_check_box(
      @raylib.Rectangle::new(640.0, 320.0, 20.0, 20.0),
      "DrawRoundedRect",
      draw_rounded_rect,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(640.0, 350.0, 20.0, 20.0),
      "DrawRoundedLines",
      draw_rounded_lines,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(640.0, 380.0, 20.0, 20.0),
      "DrawRect",
      draw_rect,
    )
    |> ignore

    let mode_text = if segments.val >= 4.0 { "MANUAL" } else { "AUTO" }
    let mode_color = if segments.val >= 4.0 {
      @raylib.maroon
    } else {
      @raylib.darkgray
    }
    @raylib.draw_text("MODE: " + mode_text, 640, 280, 10, mode_color)

    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
