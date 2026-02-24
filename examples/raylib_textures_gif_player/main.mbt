///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_frame_delay = 20
  let min_frame_delay = 1
  let _ = @raylib.change_directory("examples/raylib_textures_gif_player")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - gif playing",
  )

  // Load all GIF animation frames into a single Image
  // NOTE: GIF data is always loaded as RGBA (32bit) by default
  // NOTE: Frames are just appended one after another in image.data memory
  let im_scarfy_anim = @raylib.load_image_anim("resources/scarfy_run.gif")
  let anim_frames = @raylib.image_frame_count(im_scarfy_anim)

  // Load texture from image
  // NOTE: We will update this texture when required with next frame data
  // WARNING: It's not recommended to use this technique for sprites animation,
  // use spritesheets instead, like illustrated in textures_sprite_anim example
  let tex_scarfy_anim = @raylib.load_texture_from_image(im_scarfy_anim)

  let mut current_anim_frame = 0 // Current animation frame to load and draw
  let mut frame_delay = 8 // Frame delay to switch between animation frames
  let mut frame_counter = 0 // General frames counter

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    frame_counter = frame_counter + 1
    if frame_counter >= frame_delay {
      // Move to next frame
      // NOTE: If final frame is reached we return to first frame
      current_anim_frame = current_anim_frame + 1
      if current_anim_frame >= anim_frames {
        current_anim_frame = 0
      }

      // Update GPU texture data with next frame image data
      // WARNING: Data size (frame size) and pixel format must match already created texture
      @raylib.update_texture_from_image_frame(
        tex_scarfy_anim, im_scarfy_anim, current_anim_frame,
      )

      frame_counter = 0
    }

    // Control frames delay
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      frame_delay = frame_delay + 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      frame_delay = frame_delay - 1
    }
    if frame_delay > max_frame_delay {
      frame_delay = max_frame_delay
    } else if frame_delay < min_frame_delay {
      frame_delay = min_frame_delay
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "TOTAL GIF FRAMES:  " + anim_frames.to_string(),
      50,
      30,
      20,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "CURRENT FRAME: " + current_anim_frame.to_string(),
      50,
      60,
      20,
      @raylib.gray,
    )
    @raylib.draw_text("FRAMES DELAY: ", 100, 305, 10, @raylib.darkgray)
    @raylib.draw_text(
      frame_delay.to_string() + " frames",
      620,
      305,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 350, 10, @raylib.darkgray,
    )
    for i in 0..<max_frame_delay {
      if i < frame_delay {
        @raylib.draw_rectangle(190 + 21 * i, 300, 20, 20, @raylib.red)
      }
      @raylib.draw_rectangle_lines(190 + 21 * i, 300, 20, 20, @raylib.maroon)
    }
    @raylib.draw_texture(
      tex_scarfy_anim,
      @raylib.get_screen_width() / 2 -
      @raylib.get_texture_width(tex_scarfy_anim) / 2,
      140,
      @raylib.white,
    )
    @raylib.draw_text(
      "(c) Scarfy sprite by Eiden Marsal",
      screen_width - 200,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_scarfy_anim) // Unload texture
  @raylib.unload_image(im_scarfy_anim) // Unload image (contains all frames)
  @raylib.close_window() // Close window and OpenGL context
}
