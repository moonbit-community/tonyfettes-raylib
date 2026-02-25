///|
struct Branch {
  start : @raylib.Vector2
  end_ : @raylib.Vector2
  angle : Float
  length : Float
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - recursive tree",
  )

  let start = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0 - 125.0,
    Float::from_int(screen_height),
  )
  let angle : Ref[Float] = { val: 40.0 }
  let thick : Ref[Float] = { val: 1.0 }
  let tree_depth : Ref[Float] = { val: 10.0 }
  let branch_decay : Ref[Float] = { val: 0.66 }
  let length : Ref[Float] = { val: 120.0 }
  let bezier : Ref[Bool] = { val: false }
  let pi : Float = Float::from_double(@math.PI)
  let deg2rad : Float = pi / 180.0

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    let theta = angle.val * deg2rad
    let max_branches = @math.powf(
      2.0,
      Float::from_double(@math.floor(tree_depth.val.to_double())),
    ).to_int()
    let branches : Array[Branch] = []
    let initial_end = @raylib.Vector2::new(
      start.x + length.val * @math.sinf(0.0),
      start.y - length.val * @math.cosf(0.0),
    )
    branches.push({ start, end_: initial_end, angle: 0.0, length: length.val })

    let mut i = 0
    while i < branches.length() {
      let branch = branches[i]
      if branch.length >= 2.0 {
        let next_length = branch.length * branch_decay.val
        if branches.length() < max_branches && next_length >= 2.0 {
          let branch_start = branch.end_
          let angle1 = branch.angle + theta
          let branch_end1 = @raylib.Vector2::new(
            branch_start.x + next_length * @math.sinf(angle1),
            branch_start.y - next_length * @math.cosf(angle1),
          )
          branches.push({
            start: branch_start,
            end_: branch_end1,
            angle: angle1,
            length: next_length,
          })
          let angle2 = branch.angle - theta
          let branch_end2 = @raylib.Vector2::new(
            branch_start.x + next_length * @math.sinf(angle2),
            branch_start.y - next_length * @math.cosf(angle2),
          )
          branches.push({
            start: branch_start,
            end_: branch_end2,
            angle: angle2,
            length: next_length,
          })
        }
      }
      i += 1
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    for i = 0; i < branches.length(); i = i + 1 {
      let branch = branches[i]
      if branch.length >= 2.0 {
        if bezier.val {
          @raylib.draw_line_bezier(
            branch.start,
            branch.end_,
            thick.val,
            @raylib.red,
          )
        } else {
          @raylib.draw_line_ex(
            branch.start,
            branch.end_,
            thick.val,
            @raylib.red,
          )
        }
      }
    }

    @raylib.draw_line(
      580,
      0,
      580,
      @raylib.get_screen_height(),
      @raylib.Color::new(218, 218, 218, 255),
    )
    @raylib.draw_rectangle(
      580,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.Color::new(232, 232, 232, 255),
    )

    // GUI controls
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 40.0, 120.0, 20.0),
      "Angle",
      angle.val.to_int().to_string(),
      angle,
      0.0,
      180.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 70.0, 120.0, 20.0),
      "Length",
      length.val.to_int().to_string(),
      length,
      12.0,
      240.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 100.0, 120.0, 20.0),
      "Decay",
      branch_decay.val.to_string(),
      branch_decay,
      0.1,
      0.78,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 130.0, 120.0, 20.0),
      "Depth",
      tree_depth.val.to_int().to_string(),
      tree_depth,
      1.0,
      10.0,
    )
    |> ignore
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 160.0, 120.0, 20.0),
      "Thick",
      thick.val.to_int().to_string(),
      thick,
      1.0,
      8.0,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(640.0, 190.0, 20.0, 20.0),
      "Bezier",
      bezier,
    )
    |> ignore

    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
