///|
let opt_width = 220

///|
let margin_size = 8

///|
let color_size = 16

///|
fn fi(x : Int) -> Float {
  Float::from_int(x)
}

///|
fn draw_texture_tiled(
  texture : @raylib.Texture,
  source : @raylib.Rectangle,
  dest : @raylib.Rectangle,
  origin : @raylib.Vector2,
  rotation : Float,
  scale : Float,
  tint : @raylib.Color,
) -> Unit {
  if scale <= 0.0 {
    return
  }
  if source.width == 0.0 || source.height == 0.0 {
    return
  }
  let tile_width = (source.width * scale).to_int()
  let tile_height = (source.height * scale).to_int()
  let tw = fi(tile_width)
  let th = fi(tile_height)
  if dest.width < tw && dest.height < th {
    @raylib.draw_texture_pro(
      texture,
      @raylib.Rectangle::new(
        source.x,
        source.y,
        dest.width / tw * source.width,
        dest.height / th * source.height,
      ),
      @raylib.Rectangle::new(dest.x, dest.y, dest.width, dest.height),
      origin,
      rotation,
      tint,
    )
  } else if dest.width <= tw {
    // Tiled vertically (one column)
    for dy = 0; dy + tile_height < dest.height.to_int(); dy = dy + tile_height {
      @raylib.draw_texture_pro(
        texture,
        @raylib.Rectangle::new(
          source.x,
          source.y,
          dest.width / tw * source.width,
          source.height,
        ),
        @raylib.Rectangle::new(dest.x, dest.y + fi(dy), dest.width, th),
        origin,
        rotation,
        tint,
      )
    } nobreak {
      if dy < dest.height.to_int() {
        @raylib.draw_texture_pro(
          texture,
          @raylib.Rectangle::new(
            source.x,
            source.y,
            dest.width / tw * source.width,
            (dest.height - fi(dy)) / th * source.height,
          ),
          @raylib.Rectangle::new(
            dest.x,
            dest.y + fi(dy),
            dest.width,
            dest.height - fi(dy),
          ),
          origin,
          rotation,
          tint,
        )
      }
    }
  } else if dest.height <= th {
    // Tiled horizontally (one row)
    for dx = 0; dx + tile_width < dest.width.to_int(); dx = dx + tile_width {
      @raylib.draw_texture_pro(
        texture,
        @raylib.Rectangle::new(
          source.x,
          source.y,
          source.width,
          dest.height / th * source.height,
        ),
        @raylib.Rectangle::new(dest.x + fi(dx), dest.y, tw, dest.height),
        origin,
        rotation,
        tint,
      )
    } nobreak {
      if dx < dest.width.to_int() {
        @raylib.draw_texture_pro(
          texture,
          @raylib.Rectangle::new(
            source.x,
            source.y,
            (dest.width - fi(dx)) / tw * source.width,
            dest.height / th * source.height,
          ),
          @raylib.Rectangle::new(
            dest.x + fi(dx),
            dest.y,
            dest.width - fi(dx),
            dest.height,
          ),
          origin,
          rotation,
          tint,
        )
      }
    }
  } else {
    // Tiled both horizontally and vertically
    for dx = 0; dx + tile_width < dest.width.to_int(); dx = dx + tile_width {
      for dy = 0; dy + tile_height < dest.height.to_int(); dy = dy + tile_height {
        @raylib.draw_texture_pro(
          texture,
          source,
          @raylib.Rectangle::new(dest.x + fi(dx), dest.y + fi(dy), tw, th),
          origin,
          rotation,
          tint,
        )
      } nobreak {
        if dy < dest.height.to_int() {
          @raylib.draw_texture_pro(
            texture,
            @raylib.Rectangle::new(
              source.x,
              source.y,
              source.width,
              (dest.height - fi(dy)) / th * source.height,
            ),
            @raylib.Rectangle::new(
              dest.x + fi(dx),
              dest.y + fi(dy),
              tw,
              dest.height - fi(dy),
            ),
            origin,
            rotation,
            tint,
          )
        }
      }
    } nobreak {
      // Fit last column of tiles
      if dx < dest.width.to_int() {
        for dy = 0
            dy + tile_height < dest.height.to_int()
            dy = dy + tile_height {
          @raylib.draw_texture_pro(
            texture,
            @raylib.Rectangle::new(
              source.x,
              source.y,
              (dest.width - fi(dx)) / tw * source.width,
              source.height,
            ),
            @raylib.Rectangle::new(
              dest.x + fi(dx),
              dest.y + fi(dy),
              dest.width - fi(dx),
              th,
            ),
            origin,
            rotation,
            tint,
          )
        } nobreak {
          if dy < dest.height.to_int() {
            @raylib.draw_texture_pro(
              texture,
              @raylib.Rectangle::new(
                source.x,
                source.y,
                (dest.width - fi(dx)) / tw * source.width,
                (dest.height - fi(dy)) / th * source.height,
              ),
              @raylib.Rectangle::new(
                dest.x + fi(dx),
                dest.y + fi(dy),
                dest.width - fi(dx),
                dest.height - fi(dy),
              ),
              origin,
              rotation,
              tint,
            )
          }
        }
      }
    }
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_draw_tiled")
  @raylib.set_config_flags(@raylib.FlagWindowResizable)
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - Draw part of a texture tiled",
  )

  // Load texture
  let tex_pattern = @raylib.load_texture("resources/patterns.png")
  @raylib.set_texture_filter(tex_pattern, @raylib.TextureFilterTrilinear)

  // Coordinates for all patterns inside the texture
  let rec_pattern = [
    @raylib.Rectangle::new(3.0, 3.0, 66.0, 66.0),
    @raylib.Rectangle::new(75.0, 3.0, 100.0, 100.0),
    @raylib.Rectangle::new(3.0, 75.0, 66.0, 66.0),
    @raylib.Rectangle::new(7.0, 156.0, 50.0, 50.0),
    @raylib.Rectangle::new(85.0, 106.0, 90.0, 45.0),
    @raylib.Rectangle::new(75.0, 154.0, 100.0, 60.0),
  ]

  // Setup colors
  let colors : Array[@raylib.Color] = [
    @raylib.black, @raylib.maroon, @raylib.orange, @raylib.blue, @raylib.purple,
    @raylib.beige, @raylib.lime, @raylib.red, @raylib.darkgray, @raylib.skyblue,
  ]
  let max_colors = colors.length()
  let color_rec : Array[@raylib.Rectangle] = Array::make(
    max_colors,
    @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
  )

  // Calculate rectangle for each color
  let mut cx = 0
  let mut cy = 0
  for i = 0; i < max_colors; i = i + 1 {
    color_rec[i] = @raylib.Rectangle::new(
      fi(2 + margin_size + cx),
      fi(22 + 256 + margin_size + cy),
      fi(color_size * 2),
      fi(color_size),
    )
    if i == max_colors / 2 - 1 {
      cx = 0
      cy = cy + color_size + margin_size
    } else {
      cx = cx + color_size * 2 + margin_size
    }
  }
  let mut active_pattern = 0
  let mut active_col = 0
  let mut scale : Float = 1.0
  let mut rotation : Float = 0.0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      let mouse = @raylib.get_mouse_position()

      // Check which pattern was clicked
      for i = 0; i < rec_pattern.length(); i = i + 1 {
        if @raylib.check_collision_point_rec(
            mouse,
            @raylib.Rectangle::new(
              fi(2 + margin_size) + rec_pattern[i].x,
              fi(40 + margin_size) + rec_pattern[i].y,
              rec_pattern[i].width,
              rec_pattern[i].height,
            ),
          ) {
          active_pattern = i
          break
        }
      }

      // Check which color was clicked
      for i = 0; i < max_colors; i = i + 1 {
        if @raylib.check_collision_point_rec(mouse, color_rec[i]) {
          active_col = i
          break
        }
      }
    }

    // Change scale
    if @raylib.is_key_pressed(@raylib.KeyUp) {
      scale = scale + 0.25
    }
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      scale = scale - 0.25
    }
    if scale > 10.0 {
      scale = 10.0
    } else if scale <= 0.0 {
      scale = 0.25
    }

    // Change rotation
    if @raylib.is_key_pressed(@raylib.KeyLeft) {
      rotation = rotation - 25.0
    }
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      rotation = rotation + 25.0
    }

    // Reset
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      rotation = 0.0
      scale = 1.0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw the tiled area
    draw_texture_tiled(
      tex_pattern,
      rec_pattern[active_pattern],
      @raylib.Rectangle::new(
        fi(opt_width + margin_size),
        fi(margin_size),
        fi(@raylib.get_screen_width() - opt_width - 2 * margin_size),
        fi(@raylib.get_screen_height() - 2 * margin_size),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      rotation,
      scale,
      colors[active_col],
    )

    // Draw options
    @raylib.draw_rectangle(
      margin_size,
      margin_size,
      opt_width - margin_size,
      @raylib.get_screen_height() - 2 * margin_size,
      @raylib.color_alpha(@raylib.lightgray, 0.5),
    )
    @raylib.draw_text(
      "Select Pattern",
      2 + margin_size,
      30 + margin_size,
      10,
      @raylib.black,
    )
    @raylib.draw_texture(
      tex_pattern,
      2 + margin_size,
      40 + margin_size,
      @raylib.black,
    )
    @raylib.draw_rectangle(
      2 + margin_size + rec_pattern[active_pattern].x.to_int(),
      40 + margin_size + rec_pattern[active_pattern].y.to_int(),
      rec_pattern[active_pattern].width.to_int(),
      rec_pattern[active_pattern].height.to_int(),
      @raylib.color_alpha(@raylib.darkblue, 0.3),
    )
    @raylib.draw_text(
      "Select Color",
      2 + margin_size,
      10 + 256 + margin_size,
      10,
      @raylib.black,
    )
    for i = 0; i < max_colors; i = i + 1 {
      @raylib.draw_rectangle_rec(color_rec[i], colors[i])
      if active_col == i {
        @raylib.draw_rectangle_lines_ex(
          color_rec[i],
          3.0,
          @raylib.color_alpha(@raylib.white, 0.5),
        )
      }
    }
    @raylib.draw_text(
      "Scale (UP/DOWN to change)",
      2 + margin_size,
      80 + 256 + margin_size,
      10,
      @raylib.black,
    )
    @raylib.draw_text(
      "\{scale}x",
      2 + margin_size,
      92 + 256 + margin_size,
      20,
      @raylib.black,
    )
    @raylib.draw_text(
      "Rotation (LEFT/RIGHT to change)",
      2 + margin_size,
      122 + 256 + margin_size,
      10,
      @raylib.black,
    )
    @raylib.draw_text(
      "\{rotation} degrees",
      2 + margin_size,
      134 + 256 + margin_size,
      20,
      @raylib.black,
    )
    @raylib.draw_text(
      "Press [SPACE] to reset",
      2 + margin_size,
      164 + 256 + margin_size,
      10,
      @raylib.darkblue,
    )

    // Draw FPS
    @raylib.draw_text(
      "\{@raylib.get_fps()} FPS",
      2 + margin_size,
      2 + margin_size,
      20,
      @raylib.black,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_pattern)
  @raylib.close_window()
}
