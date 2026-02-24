///|
let gravity : Float = 400.0

///|
let player_jump_spd : Float = 350.0

///|
let player_hor_spd : Float = 200.0

///|
struct EnvItem {
  rect : @raylib.Rectangle
  blocking : Bool
  color : @raylib.Color
}

///|
fn update_player(
  player_x : Float,
  player_y : Float,
  speed : Float,
  can_jump : Bool,
  env_items : Array[EnvItem],
  delta : Float,
) -> (Float, Float, Float, Bool) {
  let mut px = player_x
  let mut py = player_y
  let mut spd = speed
  let mut cj = can_jump
  if @raylib.is_key_down(@raylib.KeyLeft) {
    px -= player_hor_spd * delta
  }
  if @raylib.is_key_down(@raylib.KeyRight) {
    px += player_hor_spd * delta
  }
  if @raylib.is_key_down(@raylib.KeySpace) && cj {
    spd = -player_jump_spd
    cj = false
  }
  let mut hit_obstacle = false
  for i = 0; i < env_items.length(); i = i + 1 {
    let ei = env_items[i]
    if ei.blocking &&
      ei.rect.x <= px &&
      ei.rect.x + ei.rect.width >= px &&
      ei.rect.y >= py &&
      ei.rect.y <= py + spd * delta {
      hit_obstacle = true
      spd = 0.0
      py = ei.rect.y
      break
    }
  }
  if not(hit_obstacle) {
    py += spd * delta
    spd += gravity * delta
    cj = false
  } else {
    cj = true
  }
  (px, py, spd, cj)
}

///|
fn update_camera_center(
  camera : @raylib.Camera2D,
  player_x : Float,
  player_y : Float,
  width : Int,
  height : Int,
) -> @raylib.Camera2D {
  @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(width) / 2.0,
      Float::from_int(height) / 2.0,
    ),
    @raylib.Vector2::new(player_x, player_y),
    camera.rotation,
    camera.zoom,
  )
}

///|
fn update_camera_center_inside_map(
  camera : @raylib.Camera2D,
  player_x : Float,
  player_y : Float,
  env_items : Array[EnvItem],
  width : Int,
  height : Int,
) -> @raylib.Camera2D {
  let w = Float::from_int(width)
  let h = Float::from_int(height)
  let mut cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(w / 2.0, h / 2.0),
    @raylib.Vector2::new(player_x, player_y),
    camera.rotation,
    camera.zoom,
  )
  let mut min_x : Float = 1000.0
  let mut min_y : Float = 1000.0
  let mut max_x : Float = -1000.0
  let mut max_y : Float = -1000.0
  for i = 0; i < env_items.length(); i = i + 1 {
    let ei = env_items[i]
    if ei.rect.x < min_x {
      min_x = ei.rect.x
    }
    if ei.rect.x + ei.rect.width > max_x {
      max_x = ei.rect.x + ei.rect.width
    }
    if ei.rect.y < min_y {
      min_y = ei.rect.y
    }
    if ei.rect.y + ei.rect.height > max_y {
      max_y = ei.rect.y + ei.rect.height
    }
  }
  let max_pt = @raylib.get_world_to_screen_2d(
    @raylib.Vector2::new(max_x, max_y),
    cam,
  )
  let min_pt = @raylib.get_world_to_screen_2d(
    @raylib.Vector2::new(min_x, min_y),
    cam,
  )
  let mut off_x = cam.offset.x
  let mut off_y = cam.offset.y
  if max_pt.x < w {
    off_x = w - (max_pt.x - w / 2.0)
  }
  if max_pt.y < h {
    off_y = h - (max_pt.y - h / 2.0)
  }
  if min_pt.x > 0.0 {
    off_x = w / 2.0 - min_pt.x
  }
  if min_pt.y > 0.0 {
    off_y = h / 2.0 - min_pt.y
  }
  cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(off_x, off_y),
    cam.target,
    cam.rotation,
    cam.zoom,
  )
  cam
}

///|
fn update_camera_center_smooth_follow(
  camera : @raylib.Camera2D,
  player_x : Float,
  player_y : Float,
  delta : Float,
  width : Int,
  height : Int,
) -> @raylib.Camera2D {
  let min_speed : Float = 30.0
  let min_effect_length : Float = 10.0
  let fraction_speed : Float = 0.8
  let w = Float::from_int(width)
  let h = Float::from_int(height)
  let diff_x = player_x - camera.target.x
  let diff_y = player_y - camera.target.y
  let length = (diff_x * diff_x + diff_y * diff_y).sqrt()
  let mut target_x = camera.target.x
  let mut target_y = camera.target.y
  if length > min_effect_length {
    let mut speed = fraction_speed * length
    if speed < min_speed {
      speed = min_speed
    }
    target_x = target_x + diff_x * speed * delta / length
    target_y = target_y + diff_y * speed * delta / length
  }
  @raylib.Camera2D::new(
    @raylib.Vector2::new(w / 2.0, h / 2.0),
    @raylib.Vector2::new(target_x, target_y),
    camera.rotation,
    camera.zoom,
  )
}

///|
fn update_camera_even_out_on_landing(
  camera : @raylib.Camera2D,
  player_x : Float,
  player_y : Float,
  speed : Float,
  can_jump : Bool,
  delta : Float,
  evening_out : Bool,
  even_out_target : Float,
  width : Int,
  height : Int,
) -> (@raylib.Camera2D, Bool, Float) {
  let even_out_speed : Float = 700.0
  let w = Float::from_int(width)
  let h = Float::from_int(height)
  let mut target_y = camera.target.y
  let mut eo = evening_out
  let mut eot = even_out_target
  if eo {
    if eot > target_y {
      target_y += even_out_speed * delta
      if target_y > eot {
        target_y = eot
        eo = false
      }
    } else {
      target_y -= even_out_speed * delta
      if target_y < eot {
        target_y = eot
        eo = false
      }
    }
  } else if can_jump && speed == 0.0 && player_y != target_y {
    eo = true
    eot = player_y
  }
  let cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(w / 2.0, h / 2.0),
    @raylib.Vector2::new(player_x, target_y),
    camera.rotation,
    camera.zoom,
  )
  (cam, eo, eot)
}

///|
fn update_camera_player_bounds_push(
  camera : @raylib.Camera2D,
  player_x : Float,
  player_y : Float,
  width : Int,
  height : Int,
) -> @raylib.Camera2D {
  let bbox_x : Float = 0.2
  let bbox_y : Float = 0.2
  let w = Float::from_int(width)
  let h = Float::from_int(height)
  let bbox_world_min = @raylib.get_screen_to_world_2d(
    @raylib.Vector2::new((1.0 - bbox_x) * 0.5 * w, (1.0 - bbox_y) * 0.5 * h),
    camera,
  )
  let bbox_world_max = @raylib.get_screen_to_world_2d(
    @raylib.Vector2::new((1.0 + bbox_x) * 0.5 * w, (1.0 + bbox_y) * 0.5 * h),
    camera,
  )
  let off_x : Float = (1.0 - bbox_x) * 0.5 * w
  let off_y : Float = (1.0 - bbox_y) * 0.5 * h
  let mut target_x = camera.target.x
  let mut target_y = camera.target.y
  if player_x < bbox_world_min.x {
    target_x = player_x
  }
  if player_y < bbox_world_min.y {
    target_y = player_y
  }
  if player_x > bbox_world_max.x {
    target_x = bbox_world_min.x + (player_x - bbox_world_max.x)
  }
  if player_y > bbox_world_max.y {
    target_y = bbox_world_min.y + (player_y - bbox_world_max.y)
  }
  @raylib.Camera2D::new(
    @raylib.Vector2::new(off_x, off_y),
    @raylib.Vector2::new(target_x, target_y),
    camera.rotation,
    camera.zoom,
  )
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 2d camera platformer",
  )

  // Player state
  let mut player_x : Float = 400.0
  let mut player_y : Float = 280.0
  let mut player_speed : Float = 0.0
  let mut can_jump = false

  // Environment items
  let env_items : Array[EnvItem] = [
    {
      rect: @raylib.Rectangle::new(0.0, 0.0, 1000.0, 400.0),
      blocking: false,
      color: @raylib.lightgray,
    },
    {
      rect: @raylib.Rectangle::new(0.0, 400.0, 1000.0, 200.0),
      blocking: true,
      color: @raylib.gray,
    },
    {
      rect: @raylib.Rectangle::new(300.0, 200.0, 400.0, 10.0),
      blocking: true,
      color: @raylib.gray,
    },
    {
      rect: @raylib.Rectangle::new(250.0, 300.0, 100.0, 10.0),
      blocking: true,
      color: @raylib.gray,
    },
    {
      rect: @raylib.Rectangle::new(650.0, 300.0, 100.0, 10.0),
      blocking: true,
      color: @raylib.gray,
    },
  ]

  // Camera setup
  let mut camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(screen_width) / 2.0,
      Float::from_int(screen_height) / 2.0,
    ),
    @raylib.Vector2::new(player_x, player_y),
    0.0,
    1.0,
  )

  let mut camera_option = 0
  let camera_updaters_length = 5
  let camera_descriptions : Array[String] = [
    "Follow player center", "Follow player center, but clamp to map edges", "Follow player center; smoothed",
    "Follow player center horizontally; update player center vertically after landing",
    "Player push camera on getting too close to screen edge",
  ]

  // State for even-out-on-landing camera mode
  let mut evening_out = false
  let mut even_out_target : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let delta_time = @raylib.get_frame_time()

    // Update player
    let (px, py, spd, cj) = update_player(
      player_x, player_y, player_speed, can_jump, env_items, delta_time,
    )
    player_x = px
    player_y = py
    player_speed = spd
    can_jump = cj

    // Camera zoom
    let mut zoom = camera.zoom + @raylib.get_mouse_wheel_move() * 0.05
    if zoom > 3.0 {
      zoom = 3.0
    } else if zoom < 0.25 {
      zoom = 0.25
    }

    // Reset
    if @raylib.is_key_pressed(@raylib.KeyR) {
      zoom = 1.0
      player_x = 400.0
      player_y = 280.0
    }

    // Switch camera mode
    if @raylib.is_key_pressed(@raylib.KeyC) {
      camera_option = (camera_option + 1) % camera_updaters_length
    }

    // Update camera with new zoom first
    camera = @raylib.Camera2D::new(
      camera.offset,
      camera.target,
      camera.rotation,
      zoom,
    )

    // Call the selected camera updater
    if camera_option == 0 {
      camera = update_camera_center(
        camera, player_x, player_y, screen_width, screen_height,
      )
    } else if camera_option == 1 {
      camera = update_camera_center_inside_map(
        camera, player_x, player_y, env_items, screen_width, screen_height,
      )
    } else if camera_option == 2 {
      camera = update_camera_center_smooth_follow(
        camera, player_x, player_y, delta_time, screen_width, screen_height,
      )
    } else if camera_option == 3 {
      let (cam, eo, eot) = update_camera_even_out_on_landing(
        camera, player_x, player_y, player_speed, can_jump, delta_time, evening_out,
        even_out_target, screen_width, screen_height,
      )
      camera = cam
      evening_out = eo
      even_out_target = eot
    } else {
      camera = update_camera_player_bounds_push(
        camera, player_x, player_y, screen_width, screen_height,
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.lightgray)

    @raylib.begin_mode_2d(camera)

    for i = 0; i < env_items.length(); i = i + 1 {
      @raylib.draw_rectangle_rec(env_items[i].rect, env_items[i].color)
    }

    // Draw player
    let player_rect = @raylib.Rectangle::new(
      player_x - 20.0,
      player_y - 40.0,
      40.0,
      40.0,
    )
    @raylib.draw_rectangle_rec(player_rect, @raylib.red)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(player_x, player_y),
      5.0,
      @raylib.gold,
    )

    @raylib.end_mode_2d()

    @raylib.draw_text("Controls:", 20, 20, 10, @raylib.black)
    @raylib.draw_text("- Right/Left to move", 40, 40, 10, @raylib.darkgray)
    @raylib.draw_text("- Space to jump", 40, 60, 10, @raylib.darkgray)
    @raylib.draw_text(
      "- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "- C to change camera mode", 40, 100, 10, @raylib.darkgray,
    )
    @raylib.draw_text("Current camera mode:", 20, 120, 10, @raylib.black)
    @raylib.draw_text(
      camera_descriptions[camera_option],
      40,
      140,
      10,
      @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
