///|
fn main {
  let screen_width = 800
  let screen_height = 450
  let map_tile_size = 32
  let player_size = 16
  let player_tile_visibility = 2
  let tiles_x = 25
  let tiles_y = 15

  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - fog of war",
  )

  // Allocate tile data
  let tile_ids : Array[Int] = Array::make(tiles_x * tiles_y, 0)
  let tile_fog : Array[Int] = Array::make(tiles_x * tiles_y, 0)

  // Generate random tile ids
  for i = 0; i < tiles_x * tiles_y; i = i + 1 {
    tile_ids[i] = @raylib.get_random_value(0, 1)
  }

  // Player position
  let mut player_x : Float = 180.0
  let mut player_y : Float = 130.0
  let mut player_tile_x = 0
  let mut player_tile_y = 0

  // Render texture for fog of war
  let fog_of_war = @raylib.load_render_texture(tiles_x, tiles_y)
  @raylib.set_render_texture_filter(fog_of_war, @raylib.TextureFilterBilinear)

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    // Move player
    if @raylib.is_key_down(@raylib.KeyRight) {
      player_x += 5.0
    }
    if @raylib.is_key_down(@raylib.KeyLeft) {
      player_x -= 5.0
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      player_y += 5.0
    }
    if @raylib.is_key_down(@raylib.KeyUp) {
      player_y -= 5.0
    }

    // Clamp player position
    if player_x < 0.0 {
      player_x = 0.0
    } else if player_x + Float::from_int(player_size) >
      Float::from_int(tiles_x * map_tile_size) {
      player_x = Float::from_int(tiles_x * map_tile_size - player_size)
    }
    if player_y < 0.0 {
      player_y = 0.0
    } else if player_y + Float::from_int(player_size) >
      Float::from_int(tiles_y * map_tile_size) {
      player_y = Float::from_int(tiles_y * map_tile_size - player_size)
    }

    // Set previously visible tiles to half-fog
    for i = 0; i < tiles_x * tiles_y; i = i + 1 {
      if tile_fog[i] == 1 {
        tile_fog[i] = 2
      }
    }

    // Get current tile from player position
    player_tile_x = ((player_x + Float::from_int(map_tile_size / 2)) /
    Float::from_int(map_tile_size)).to_int()
    player_tile_y = ((player_y + Float::from_int(map_tile_size / 2)) /
    Float::from_int(map_tile_size)).to_int()

    // Update fog visibility
    for y = player_tile_y - player_tile_visibility
        y < player_tile_y + player_tile_visibility
        y = y + 1 {
      for x = player_tile_x - player_tile_visibility
          x < player_tile_x + player_tile_visibility
          x = x + 1 {
        if x >= 0 && x < tiles_x && y >= 0 && y < tiles_y {
          tile_fog[y * tiles_x + x] = 1
        }
      }
    }

    // Draw fog to render texture
    @raylib.begin_texture_mode(fog_of_war)
    @raylib.clear_background(@raylib.blank)
    for y = 0; y < tiles_y; y = y + 1 {
      for x = 0; x < tiles_x; x = x + 1 {
        if tile_fog[y * tiles_x + x] == 0 {
          @raylib.draw_rectangle(x, y, 1, 1, @raylib.black)
        } else if tile_fog[y * tiles_x + x] == 2 {
          @raylib.draw_rectangle(x, y, 1, 1, @raylib.fade(@raylib.black, 0.8))
        }
      }
    }
    @raylib.end_texture_mode()

    // Main drawing
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw tiles
    for y = 0; y < tiles_y; y = y + 1 {
      for x = 0; x < tiles_x; x = x + 1 {
        let color = if tile_ids[y * tiles_x + x] == 0 {
          @raylib.blue
        } else {
          @raylib.fade(@raylib.blue, 0.9)
        }
        @raylib.draw_rectangle(
          x * map_tile_size,
          y * map_tile_size,
          map_tile_size,
          map_tile_size,
          color,
        )
        @raylib.draw_rectangle_lines(
          x * map_tile_size,
          y * map_tile_size,
          map_tile_size,
          map_tile_size,
          @raylib.fade(@raylib.darkblue, 0.5),
        )
      }
    }

    // Draw player
    @raylib.draw_rectangle_v(
      @raylib.Vector2::new(player_x, player_y),
      @raylib.Vector2::new(
        Float::from_int(player_size),
        Float::from_int(player_size),
      ),
      @raylib.red,
    )

    // Draw fog of war (scaled render texture)
    // Use draw_render_texture_pro which takes RenderTexture directly and handles the y-flip internally
    @raylib.draw_render_texture_pro(
      fog_of_war,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(tiles_x),
        Float::from_int(tiles_y),
      ),
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(tiles_x * map_tile_size),
        Float::from_int(tiles_y * map_tile_size),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )

    @raylib.draw_text(
      "Current tile: [\{player_tile_x},\{player_tile_y}]",
      10,
      10,
      20,
      @raylib.raywhite,
    )
    @raylib.draw_text(
      "ARROW KEYS to move",
      10,
      screen_height - 25,
      20,
      @raylib.raywhite,
    )

    @raylib.end_drawing()
  }

  @raylib.unload_render_texture(fog_of_war)
  @raylib.close_window()
}
