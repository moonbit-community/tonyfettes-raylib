///|
struct Particle {
  mut position : @raylib.Vector2
  color : @raylib.Color
  mut alpha : Float
  size : Float
  mut rotation : Float
  mut active : Bool
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_particles = 200
  let _ = @raylib.change_directory(
    "examples/raylib_textures_particles_blending",
  )
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - particles blending",
  )

  // Particles pool, reuse them!
  let mouse_tail : Array[Particle] = Array::make(max_particles, {
    position: @raylib.Vector2::new(0.0, 0.0),
    color: @raylib.Color::new(0, 0, 0, 255),
    alpha: 1.0,
    size: 1.0,
    rotation: 0.0,
    active: false,
  })

  // Initialize particles with random colors
  for i in 0..<max_particles {
    mouse_tail[i] = {
      position: @raylib.Vector2::new(0.0, 0.0),
      color: @raylib.Color::new(
        @raylib.get_random_value(0, 255),
        @raylib.get_random_value(0, 255),
        @raylib.get_random_value(0, 255),
        255,
      ),
      alpha: 1.0,
      size: Float::from_int(@raylib.get_random_value(1, 30)) / 20.0,
      rotation: Float::from_int(@raylib.get_random_value(0, 360)),
      active: false,
    }
  }

  let gravity : Float = 3.0

  let smoke = @raylib.load_texture("resources/spark_flame.png")
  // spark_flame.png: 128x128
  let smoke_width : Float = 128.0
  let smoke_height : Float = 128.0

  let mut blending = @raylib.BlendAlpha

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Activate one particle every frame and update active particles
    for i in 0..<max_particles {
      if not(mouse_tail[i].active) {
        mouse_tail[i].active = true
        mouse_tail[i].alpha = 1.0
        mouse_tail[i].position = @raylib.get_mouse_position()
        break
      }
    }

    for i in 0..<max_particles {
      if mouse_tail[i].active {
        mouse_tail[i].position = @raylib.Vector2::new(
          mouse_tail[i].position.x,
          mouse_tail[i].position.y + gravity / 2.0,
        )
        mouse_tail[i].alpha -= 0.005
        if mouse_tail[i].alpha <= 0.0 {
          mouse_tail[i].active = false
        }
        mouse_tail[i].rotation += 2.0
      }
    }

    if @raylib.is_key_pressed(@raylib.KeySpace) {
      if blending == @raylib.BlendAlpha {
        blending = @raylib.BlendAdditive
      } else {
        blending = @raylib.BlendAlpha
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.darkgray)

    @raylib.begin_blend_mode(blending)

    // Draw active particles
    for i in 0..<max_particles {
      if mouse_tail[i].active {
        let size = mouse_tail[i].size
        let source = @raylib.Rectangle::new(0.0, 0.0, smoke_width, smoke_height)
        let dest = @raylib.Rectangle::new(
          mouse_tail[i].position.x,
          mouse_tail[i].position.y,
          smoke_width * size,
          smoke_height * size,
        )
        let origin = @raylib.Vector2::new(
          smoke_width * size / 2.0,
          smoke_height * size / 2.0,
        )
        @raylib.draw_texture_pro(
          smoke,
          source,
          dest,
          origin,
          mouse_tail[i].rotation,
          @raylib.fade(mouse_tail[i].color, mouse_tail[i].alpha),
        )
      }
    }

    @raylib.end_blend_mode()

    @raylib.draw_text(
      "PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, @raylib.black,
    )

    if blending == @raylib.BlendAlpha {
      @raylib.draw_text(
        "ALPHA BLENDING",
        290,
        screen_height - 40,
        20,
        @raylib.black,
      )
    } else {
      @raylib.draw_text(
        "ADDITIVE BLENDING",
        280,
        screen_height - 40,
        20,
        @raylib.raywhite,
      )
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(smoke)
  @raylib.close_window()
}
