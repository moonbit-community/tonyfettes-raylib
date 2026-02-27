// Custom Blend Modes (OpenGL constants)

///|
const RlglSrcAlpha : Int = 0x0302

///|
const RlglMin : Int = 0x8007

///|
const RlglMax : Int = 0x8008

///|
const MaxBoxes : Int = 20

///|
const MaxShadows : Int = 60 // MAX_BOXES * 3

///|
const MaxLights : Int = 16

// Shadow geometry type

///|
struct ShadowGeometry {
  vertices : FixedArray[@raylib.Vector2]
}

///|
fn ShadowGeometry::new() -> ShadowGeometry {
  { vertices: FixedArray::make(4, @raylib.Vector2::new(0.0, 0.0)) }
}

// Light info type

///|
struct LightInfo {
  mut active : Bool
  mut dirty : Bool
  mut valid : Bool
  mut position : @raylib.Vector2
  mut mask : @raylib.RenderTexture?
  mut outer_radius : Float
  mut bounds : @raylib.Rectangle
  shadows : FixedArray[ShadowGeometry]
  mut shadow_count : Int
}

///|
fn LightInfo::new() -> LightInfo {
  let shadows = FixedArray::makei(MaxShadows, fn(_i) { ShadowGeometry::new() })
  {
    active: false,
    dirty: false,
    valid: false,
    position: @raylib.Vector2::new(0.0, 0.0),
    mask: None,
    outer_radius: 0.0,
    bounds: @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
    shadows,
    shadow_count: 0,
  }
}

///|
let lights : FixedArray[LightInfo] = FixedArray::makei(MaxLights, fn(_i) {
  LightInfo::new()
})

// Move a light and mark it as dirty so that we update its mask next frame

///|
fn move_light(slot : Int, x : Float, y : Float) -> Unit {
  lights[slot].dirty = true
  lights[slot].position = @raylib.Vector2::new(x, y)
  // update the cached bounds
  lights[slot].bounds = @raylib.Rectangle::new(
    x - lights[slot].outer_radius,
    y - lights[slot].outer_radius,
    lights[slot].bounds.width,
    lights[slot].bounds.height,
  )
}

// Compute a shadow volume for the edge

///|
fn compute_shadow_volume_for_edge(
  slot : Int,
  sp : @raylib.Vector2,
  ep : @raylib.Vector2,
) -> Unit {
  if lights[slot].shadow_count >= MaxShadows {
    return
  }
  let extension = lights[slot].outer_radius * (2.0 : Float)
  let sp_vector = @raylib.Vector2::normalize(
    @raylib.Vector2::subtract(sp, lights[slot].position),
  )
  let sp_projection = @raylib.Vector2::add(
    sp,
    @raylib.Vector2::scale(sp_vector, extension),
  )
  let ep_vector = @raylib.Vector2::normalize(
    @raylib.Vector2::subtract(ep, lights[slot].position),
  )
  let ep_projection = @raylib.Vector2::add(
    ep,
    @raylib.Vector2::scale(ep_vector, extension),
  )
  let idx = lights[slot].shadow_count
  lights[slot].shadows[idx].vertices[0] = sp
  lights[slot].shadows[idx].vertices[1] = ep
  lights[slot].shadows[idx].vertices[2] = ep_projection
  lights[slot].shadows[idx].vertices[3] = sp_projection
  lights[slot].shadow_count = lights[slot].shadow_count + 1
}

// Draw the light and shadows to the mask for a light

///|
fn draw_light_mask(slot : Int) -> Unit {
  // Use the light mask
  match lights[slot].mask {
    Some(mask) => @raylib.begin_texture_mode(mask)
    None => return
  }
  @raylib.clear_background(@raylib.white)
  // Force the blend mode to only set the alpha of the destination
  @rl.set_blend_factors(RlglSrcAlpha, RlglSrcAlpha, RlglMin)
  @rl.set_blend_mode(@raylib.BlendCustom)
  // If we are valid, then draw the light radius to the alpha mask
  if lights[slot].valid {
    @raylib.draw_circle_gradient(
      lights[slot].position.x.to_int(),
      lights[slot].position.y.to_int(),
      lights[slot].outer_radius,
      @raylib.color_alpha(@raylib.white, 0.0),
      @raylib.white,
    )
  }
  @rl.draw_render_batch_active()
  // Cut out the shadows from the light radius by forcing the alpha to maximum
  @rl.set_blend_mode(@raylib.BlendAlpha)
  @rl.set_blend_factors(RlglSrcAlpha, RlglSrcAlpha, RlglMax)
  @rl.set_blend_mode(@raylib.BlendCustom)
  // Draw the shadows to the alpha mask
  for i = 0; i < lights[slot].shadow_count; i = i + 1 {
    let verts = lights[slot].shadows[i].vertices
    @raylib.draw_triangle_fan(
      [verts[0], verts[1], verts[2], verts[3]],
      @raylib.white,
    )
  }
  @rl.draw_render_batch_active()
  // Go back to normal blend mode
  @rl.set_blend_mode(@raylib.BlendAlpha)
  @raylib.end_texture_mode()
}

// Setup a light

///|
fn setup_light(slot : Int, x : Float, y : Float, radius : Float) -> Unit {
  lights[slot].active = true
  lights[slot].valid = false
  lights[slot].mask = Some(
    @raylib.load_render_texture(
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
    ),
  )
  lights[slot].outer_radius = radius
  lights[slot].bounds = @raylib.Rectangle::new(
    0.0,
    0.0,
    radius * (2.0 : Float),
    radius * (2.0 : Float),
  )
  move_light(slot, x, y)
  // Force the render texture to have something in it
  draw_light_mask(slot)
}

// See if a light needs to update its mask

///|
fn update_light(
  slot : Int,
  boxes : Array[@raylib.Rectangle],
  count : Int,
) -> Bool {
  if not(lights[slot].active) || not(lights[slot].dirty) {
    return false
  }
  lights[slot].dirty = false
  lights[slot].shadow_count = 0
  lights[slot].valid = false
  for i = 0; i < count; i = i + 1 {
    // Are we in a box? if so we are not valid
    if @raylib.check_collision_point_rec(lights[slot].position, boxes[i]) {
      return false
    }
    // If this box is outside our bounds, we can skip it
    if not(@raylib.check_collision_recs(lights[slot].bounds, boxes[i])) {
      continue i + 1
    }
    // Check the edges that are on the same side we are, and cast shadow volumes out from them

    // Top
    let mut sp = @raylib.Vector2::new(boxes[i].x, boxes[i].y)
    let mut ep = @raylib.Vector2::new(boxes[i].x + boxes[i].width, boxes[i].y)
    if lights[slot].position.y > ep.y {
      compute_shadow_volume_for_edge(slot, sp, ep)
    }
    // Right
    sp = ep
    ep = @raylib.Vector2::new(ep.x, ep.y + boxes[i].height)
    if lights[slot].position.x < ep.x {
      compute_shadow_volume_for_edge(slot, sp, ep)
    }
    // Bottom
    sp = ep
    ep = @raylib.Vector2::new(ep.x - boxes[i].width, ep.y)
    if lights[slot].position.y < ep.y {
      compute_shadow_volume_for_edge(slot, sp, ep)
    }
    // Left
    sp = ep
    ep = @raylib.Vector2::new(ep.x, ep.y - boxes[i].height)
    if lights[slot].position.x > ep.x {
      compute_shadow_volume_for_edge(slot, sp, ep)
    }
    // The box itself
    let idx = lights[slot].shadow_count
    lights[slot].shadows[idx].vertices[0] = @raylib.Vector2::new(
      boxes[i].x,
      boxes[i].y,
    )
    lights[slot].shadows[idx].vertices[1] = @raylib.Vector2::new(
      boxes[i].x,
      boxes[i].y + boxes[i].height,
    )
    lights[slot].shadows[idx].vertices[2] = @raylib.Vector2::new(
      boxes[i].x + boxes[i].width,
      boxes[i].y + boxes[i].height,
    )
    lights[slot].shadows[idx].vertices[3] = @raylib.Vector2::new(
      boxes[i].x + boxes[i].width,
      boxes[i].y,
    )
    lights[slot].shadow_count = lights[slot].shadow_count + 1
  }
  lights[slot].valid = true
  draw_light_mask(slot)
  true
}

// Set up some boxes

///|
fn setup_boxes(boxes : Array[@raylib.Rectangle]) -> Int {
  boxes[0] = @raylib.Rectangle::new(150.0, 80.0, 40.0, 40.0)
  boxes[1] = @raylib.Rectangle::new(1200.0, 700.0, 40.0, 40.0)
  boxes[2] = @raylib.Rectangle::new(200.0, 600.0, 40.0, 40.0)
  boxes[3] = @raylib.Rectangle::new(1000.0, 50.0, 40.0, 40.0)
  boxes[4] = @raylib.Rectangle::new(500.0, 350.0, 40.0, 40.0)
  for i = 5; i < MaxBoxes; i = i + 1 {
    boxes[i] = @raylib.Rectangle::new(
      Float::from_int(@raylib.get_random_value(0, @raylib.get_screen_width())),
      Float::from_int(@raylib.get_random_value(0, @raylib.get_screen_height())),
      Float::from_int(@raylib.get_random_value(10, 100)),
      Float::from_int(@raylib.get_random_value(10, 100)),
    )
  }
  MaxBoxes
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - top down lights",
  )

  // Initialize our 'world' of boxes
  let boxes : Array[@raylib.Rectangle] = Array::make(
    MaxBoxes,
    @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
  )
  let box_count = setup_boxes(boxes)

  // Create a checkerboard ground texture
  let img = @raylib.gen_image_checked(
    64, 64, 32, 32, @raylib.darkbrown, @raylib.darkgray,
  )
  let background_texture = @raylib.load_texture_from_image(img)
  @raylib.unload_image(img)

  // Create a global light mask to hold all the blended lights
  let light_mask = @raylib.load_render_texture(
    @raylib.get_screen_width(),
    @raylib.get_screen_height(),
  )

  // Setup initial light
  setup_light(0, 600.0, 400.0, 300.0)
  let mut next_light = 1

  let mut show_lines = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Drag light 0
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      let mouse_pos = @raylib.get_mouse_position()
      move_light(0, mouse_pos.x, mouse_pos.y)
    }
    // Make a new light
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) &&
      next_light < MaxLights {
      let mouse_pos = @raylib.get_mouse_position()
      setup_light(next_light, mouse_pos.x, mouse_pos.y, 200.0)
      next_light = next_light + 1
    }
    // Toggle debug info
    if @raylib.is_key_pressed(@raylib.KeyF1) {
      show_lines = not(show_lines)
    }
    // Update the lights and keep track if any were dirty
    let mut dirty_lights = false
    for i = 0; i < MaxLights; i = i + 1 {
      if update_light(i, boxes, box_count) {
        dirty_lights = true
      }
    }
    // Update the light mask
    if dirty_lights {
      // Build up the light mask
      @raylib.begin_texture_mode(light_mask)
      @raylib.clear_background(@raylib.black)
      // Force the blend mode to only set the alpha of the destination
      @rl.set_blend_factors(RlglSrcAlpha, RlglSrcAlpha, RlglMin)
      @rl.set_blend_mode(@raylib.BlendCustom)
      // Merge in all the light masks
      for i = 0; i < MaxLights; i = i + 1 {
        if lights[i].active {
          match lights[i].mask {
            Some(mask) =>
              @raylib.draw_render_texture_rec(
                mask,
                @raylib.Rectangle::new(
                  0.0,
                  0.0,
                  Float::from_int(@raylib.get_screen_width()),
                  -Float::from_int(@raylib.get_screen_height()),
                ),
                @raylib.Vector2::new(0.0, 0.0),
                @raylib.white,
              )
            None => ()
          }
        }
      }
      @rl.draw_render_batch_active()
      // Go back to normal blend
      @rl.set_blend_mode(@raylib.BlendAlpha)
      @raylib.end_texture_mode()
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    // Draw the tile background
    @raylib.draw_texture_rec(
      background_texture,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(@raylib.get_screen_width()),
        Float::from_int(@raylib.get_screen_height()),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    // Overlay the shadows from all the lights
    @raylib.draw_render_texture_rec(
      light_mask,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(@raylib.get_screen_width()),
        -Float::from_int(@raylib.get_screen_height()),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.color_alpha(@raylib.white, if show_lines { 0.75 } else { 1.0 }),
    )
    // Draw the lights
    for i = 0; i < MaxLights; i = i + 1 {
      if lights[i].active {
        @raylib.draw_circle(
          lights[i].position.x.to_int(),
          lights[i].position.y.to_int(),
          10.0,
          if i == 0 {
            @raylib.yellow
          } else {
            @raylib.white
          },
        )
      }
    }
    if show_lines {
      for s = 0; s < lights[0].shadow_count; s = s + 1 {
        let verts = lights[0].shadows[s].vertices
        @raylib.draw_triangle_fan(
          [verts[0], verts[1], verts[2], verts[3]],
          @raylib.darkpurple,
        )
      }
      for b = 0; b < box_count; b = b + 1 {
        if @raylib.check_collision_recs(boxes[b], lights[0].bounds) {
          @raylib.draw_rectangle_rec(boxes[b], @raylib.purple)
        }
        @raylib.draw_rectangle_lines(
          boxes[b].x.to_int(),
          boxes[b].y.to_int(),
          boxes[b].width.to_int(),
          boxes[b].height.to_int(),
          @raylib.darkblue,
        )
      }
      @raylib.draw_text("(F1) Hide Shadow Volumes", 10, 50, 10, @raylib.green)
    } else {
      @raylib.draw_text("(F1) Show Shadow Volumes", 10, 50, 10, @raylib.green)
    }
    @raylib.draw_fps(screen_width - 80, 10)
    @raylib.draw_text("Drag to move light #1", 10, 10, 10, @raylib.darkgreen)
    @raylib.draw_text(
      "Right click to add new light", 10, 30, 10, @raylib.darkgreen,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(background_texture)
  @raylib.unload_render_texture(light_mask)
  for i = 0; i < MaxLights; i = i + 1 {
    if lights[i].active {
      match lights[i].mask {
        Some(mask) => @raylib.unload_render_texture(mask)
        None => ()
      }
    }
  }
  @raylib.close_window()
}
