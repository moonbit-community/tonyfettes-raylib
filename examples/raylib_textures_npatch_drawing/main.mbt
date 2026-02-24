///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_npatch_drawing")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - N-patch drawing",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let npatch_texture = @raylib.load_texture("resources/ninepatch_button.png")

  let origin = @raylib.Vector2::new(0.0, 0.0)

  // Position and size of the n-patches
  let dst_rec1_x : Float = 480.0
  let dst_rec1_y : Float = 160.0
  let mut dst_rec1_width : Float = 32.0
  let mut dst_rec1_height : Float = 32.0
  let dst_rec2_x : Float = 160.0
  let dst_rec2_y : Float = 160.0
  let mut dst_rec2_width : Float = 32.0
  let mut dst_rec2_height : Float = 32.0
  let dst_rec_h_x : Float = 160.0
  let dst_rec_h_y : Float = 93.0
  let mut dst_rec_h_width : Float = 32.0
  let dst_rec_h_height : Float = 32.0
  let dst_rec_v_x : Float = 92.0
  let dst_rec_v_y : Float = 160.0
  let dst_rec_v_width : Float = 32.0
  let mut dst_rec_v_height : Float = 32.0

  // A 9-patch (NPATCH_NINE_PATCH) changes its sizes in both axis
  let nine_patch_info1 = @raylib.NPatchInfo::new(
    @raylib.Rectangle::new(0.0, 0.0, 64.0, 64.0),
    12,
    40,
    12,
    12,
    @raylib.NpatchNinePatch,
  )
  let nine_patch_info2 = @raylib.NPatchInfo::new(
    @raylib.Rectangle::new(0.0, 128.0, 64.0, 64.0),
    16,
    16,
    16,
    16,
    @raylib.NpatchNinePatch,
  )

  // A horizontal 3-patch (NPATCH_THREE_PATCH_HORIZONTAL) changes its sizes along the x axis only
  let h3_patch_info = @raylib.NPatchInfo::new(
    @raylib.Rectangle::new(0.0, 64.0, 64.0, 64.0),
    8,
    8,
    8,
    8,
    @raylib.NpatchThreePatchHorizontal,
  )

  // A vertical 3-patch (NPATCH_THREE_PATCH_VERTICAL) changes its sizes along the y axis only
  let v3_patch_info = @raylib.NPatchInfo::new(
    @raylib.Rectangle::new(0.0, 192.0, 64.0, 64.0),
    6,
    6,
    6,
    6,
    @raylib.NpatchThreePatchVertical,
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse_position = @raylib.get_mouse_position()

    // Resize the n-patches based on mouse position
    dst_rec1_width = mouse_position.x - dst_rec1_x
    dst_rec1_height = mouse_position.y - dst_rec1_y
    dst_rec2_width = mouse_position.x - dst_rec2_x
    dst_rec2_height = mouse_position.y - dst_rec2_y
    dst_rec_h_width = mouse_position.x - dst_rec_h_x
    dst_rec_v_height = mouse_position.y - dst_rec_v_y

    // Set a minimum width and/or height
    if dst_rec1_width < 1.0 {
      dst_rec1_width = 1.0
    }
    if dst_rec1_width > 300.0 {
      dst_rec1_width = 300.0
    }
    if dst_rec1_height < 1.0 {
      dst_rec1_height = 1.0
    }
    if dst_rec2_width < 1.0 {
      dst_rec2_width = 1.0
    }
    if dst_rec2_width > 300.0 {
      dst_rec2_width = 300.0
    }
    if dst_rec2_height < 1.0 {
      dst_rec2_height = 1.0
    }
    if dst_rec_h_width < 1.0 {
      dst_rec_h_width = 1.0
    }
    if dst_rec_v_height < 1.0 {
      dst_rec_v_height = 1.0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw the n-patches
    @raylib.draw_texture_npatch(
      npatch_texture,
      nine_patch_info2,
      @raylib.Rectangle::new(
        dst_rec2_x, dst_rec2_y, dst_rec2_width, dst_rec2_height,
      ),
      origin,
      0.0,
      @raylib.white,
    )
    @raylib.draw_texture_npatch(
      npatch_texture,
      nine_patch_info1,
      @raylib.Rectangle::new(
        dst_rec1_x, dst_rec1_y, dst_rec1_width, dst_rec1_height,
      ),
      origin,
      0.0,
      @raylib.white,
    )
    @raylib.draw_texture_npatch(
      npatch_texture,
      h3_patch_info,
      @raylib.Rectangle::new(
        dst_rec_h_x, dst_rec_h_y, dst_rec_h_width, dst_rec_h_height,
      ),
      origin,
      0.0,
      @raylib.white,
    )
    @raylib.draw_texture_npatch(
      npatch_texture,
      v3_patch_info,
      @raylib.Rectangle::new(
        dst_rec_v_x, dst_rec_v_y, dst_rec_v_width, dst_rec_v_height,
      ),
      origin,
      0.0,
      @raylib.white,
    )

    // Draw the source texture
    @raylib.draw_rectangle_lines(5, 88, 74, 266, @raylib.blue)
    @raylib.draw_texture(npatch_texture, 10, 93, @raylib.white)
    @raylib.draw_text("TEXTURE", 15, 360, 10, @raylib.darkgray)
    @raylib.draw_text(
      "Move the mouse to stretch or shrink the n-patches", 10, 20, 20, @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(npatch_texture)
  @raylib.close_window()
}
