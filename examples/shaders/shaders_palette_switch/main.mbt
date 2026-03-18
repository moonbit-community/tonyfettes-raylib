///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - palette switch",
  )
  let _ = @raylib.change_directory("shaders/shaders_palette_switch")

  // Load shader
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/palette_switch.fs",
  )

  // Get variable (uniform) location on the shader
  let palette_loc = @raylib.get_shader_location(shader, "palette")

  let max_palettes = 3
  let colors_per_palette = 8

  // Palettes: arrays of RGB triplets as ivec3
  // 3-BIT RGB
  let palette0 : @raylib.ShaderUniformDataV = @raylib.ShaderUniformDataV::IVec3([
    (0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255), (0, 255, 255), (255, 0, 255),
    (255, 255, 0), (255, 255, 255),
  ])
  // AMMO-8 (GameBoy-like)
  let palette1 : @raylib.ShaderUniformDataV = @raylib.ShaderUniformDataV::IVec3([
    (4, 12, 6), (17, 35, 24), (30, 58, 41), (48, 93, 66), (77, 128, 97),
    (137, 162, 87), (190, 220, 127), (238, 255, 204),
  ])
  // RKBV (2-strip film)
  let palette2 : @raylib.ShaderUniformDataV = @raylib.ShaderUniformDataV::IVec3([
    (21, 25, 26), (138, 76, 88), (217, 98, 117), (230, 184, 193), (69, 107, 115),
    (75, 151, 166), (165, 189, 194), (255, 245, 247),
  ])

  let palettes = [palette0, palette1, palette2]
  let palette_text : Array[String] = [
    "3-BIT RGB", "AMMO-8 (GameBoy-like)", "RKBV (2-strip film)",
  ]

  let mut current_palette = 0
  let line_height = screen_height / colors_per_palette
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      current_palette += 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      current_palette -= 1
    }
    if current_palette >= max_palettes {
      current_palette = 0
    } else if current_palette < 0 {
      current_palette = max_palettes - 1
    }

    // Send palette data to the shader (RGB triplets as ivec3)
    shader.set_value_v(palette_loc, palettes[current_palette])

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_shader_mode(shader)
    for i in 0..<colors_per_palette {
      // Draw horizontal screen-wide rectangles with increasing "palette index"
      // The used palette index is encoded in the RGB components of the pixel
      @raylib.draw_rectangle(
        0,
        line_height * i,
        @raylib.get_screen_width(),
        line_height,
        @raylib.Color::new(i, i, i, 255),
      )
    }
    @raylib.end_shader_mode()
    @raylib.draw_text("< >", 10, 10, 30, @raylib.darkblue)
    @raylib.draw_text("CURRENT PALETTE:", 60, 15, 20, @raylib.raywhite)
    @raylib.draw_text(palette_text[current_palette], 300, 15, 20, @raylib.red)
    @raylib.draw_fps(700, 15)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
