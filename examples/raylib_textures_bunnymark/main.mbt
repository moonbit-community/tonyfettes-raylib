///|
struct Bunny {
  mut position : @raylib.Vector2
  mut speed : @raylib.Vector2
  color : @raylib.Color
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_bunnies = 50000
  let max_batch_elements = 8192
  let _ = @raylib.change_directory("examples/raylib_textures_bunnymark")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - bunnymark",
  )

  // Load bunny texture
  let tex_bunny = @raylib.load_texture("resources/wabbit_alpha.png")
  // wabbit_alpha.png: 32x32
  let tex_bunny_width = 32
  let tex_bunny_height = 32

  // Bunnies array
  let bunnies : Array[Bunny] = Array::make(max_bunnies, {
    position: @raylib.Vector2::new(0.0, 0.0),
    speed: @raylib.Vector2::new(0.0, 0.0),
    color: @raylib.Color::new(255, 255, 255, 255),
  })

  let mut bunnies_count = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      // Create more bunnies
      for _ in 0..<100 {
        if bunnies_count < max_bunnies {
          bunnies[bunnies_count] = {
            position: @raylib.get_mouse_position(),
            speed: @raylib.Vector2::new(
              Float::from_int(@raylib.get_random_value(-250, 250)) / 60.0,
              Float::from_int(@raylib.get_random_value(-250, 250)) / 60.0,
            ),
            color: @raylib.Color::new(
              @raylib.get_random_value(50, 240),
              @raylib.get_random_value(80, 240),
              @raylib.get_random_value(100, 240),
              255,
            ),
          }
          bunnies_count += 1
        }
      }
    }

    // Update bunnies
    for i in 0..<bunnies_count {
      bunnies[i].position = @raylib.Vector2::new(
        bunnies[i].position.x + bunnies[i].speed.x,
        bunnies[i].position.y + bunnies[i].speed.y,
      )
      if bunnies[i].position.x + Float::from_int(tex_bunny_width / 2) >
        Float::from_int(@raylib.get_screen_width()) ||
        bunnies[i].position.x + Float::from_int(tex_bunny_width / 2) < 0.0 {
        bunnies[i].speed = @raylib.Vector2::new(
          -bunnies[i].speed.x,
          bunnies[i].speed.y,
        )
      }
      if bunnies[i].position.y + Float::from_int(tex_bunny_height / 2) >
        Float::from_int(@raylib.get_screen_height()) ||
        bunnies[i].position.y + Float::from_int(tex_bunny_height / 2) - 40.0 <
        0.0 {
        bunnies[i].speed = @raylib.Vector2::new(
          bunnies[i].speed.x,
          -bunnies[i].speed.y,
        )
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    for i in 0..<bunnies_count {
      @raylib.draw_texture(
        tex_bunny,
        bunnies[i].position.x.to_int(),
        bunnies[i].position.y.to_int(),
        bunnies[i].color,
      )
    }

    @raylib.draw_rectangle(0, 0, screen_width, 40, @raylib.black)
    @raylib.draw_text("bunnies: \{bunnies_count}", 120, 10, 20, @raylib.green)
    @raylib.draw_text(
      "batched draw calls: \{1 + bunnies_count / max_batch_elements}",
      320,
      10,
      20,
      @raylib.maroon,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_bunny)
  @raylib.close_window()
}
