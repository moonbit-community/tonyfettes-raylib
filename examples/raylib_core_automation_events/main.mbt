///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - automation events",
  )
  let gravity : Float = 400.0
  let player_jump_spd : Float = 350.0
  let player_hor_spd : Float = 200.0

  // Define player
  let mut player_x : Float = 400.0
  let mut player_y : Float = 280.0
  let mut player_speed : Float = 0.0
  let mut can_jump = false

  // Define environment elements (platforms)
  // Each element: rect_x, rect_y, rect_w, rect_h, blocking, color
  let env_rects : Array[@raylib.Rectangle] = [
    @raylib.Rectangle::new(0.0, 0.0, 1000.0, 400.0),
    @raylib.Rectangle::new(0.0, 400.0, 1000.0, 200.0),
    @raylib.Rectangle::new(300.0, 200.0, 400.0, 10.0),
    @raylib.Rectangle::new(250.0, 300.0, 100.0, 10.0),
    @raylib.Rectangle::new(650.0, 300.0, 100.0, 10.0),
  ]
  let env_blocking : Array[Bool] = [false, true, true, true, true]
  let env_colors : Array[@raylib.Color] = [
    @raylib.lightgray, @raylib.gray, @raylib.gray, @raylib.gray, @raylib.gray,
  ]
  let env_count = 5

  // Define camera
  let mut camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(screen_width) / 2.0,
      Float::from_int(screen_height) / 2.0,
    ),
    @raylib.Vector2::new(player_x, player_y),
    0.0,
    1.0,
  )

  // Automation events
  let mut aelist = @raylib.load_automation_event_list("")
  @raylib.set_automation_event_list(aelist)
  let mut event_recording = false
  let mut event_playing = false
  let mut frame_counter = 0
  let mut play_frame_counter = 0
  let mut current_play_frame = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let delta_time : Float = 0.015

    // Dropped files logic
    if @raylib.is_file_dropped() {
      let dropped_files = @raylib.load_dropped_files()
      let count = @raylib.file_path_list_count(dropped_files)
      if count > 0 {
        let file_path = @raylib.file_path_list_get(dropped_files, 0)
        if @raylib.is_file_extension(file_path, ".txt;.rae") {
          @raylib.unload_automation_event_list(aelist)
          aelist = @raylib.load_automation_event_list(file_path)
          event_recording = false

          // Reset scene state to play
          event_playing = true
          play_frame_counter = 0
          current_play_frame = 0
          player_x = 400.0
          player_y = 280.0
          player_speed = 0.0
          can_jump = false
          camera = @raylib.Camera2D::new(
            @raylib.Vector2::new(
              Float::from_int(screen_width) / 2.0,
              Float::from_int(screen_height) / 2.0,
            ),
            @raylib.Vector2::new(player_x, player_y),
            0.0,
            1.0,
          )
        }
      }
      @raylib.unload_dropped_files(dropped_files)
    }

    // Update player
    if @raylib.is_key_down(@raylib.KeyLeft) {
      player_x -= player_hor_spd * delta_time
    }
    if @raylib.is_key_down(@raylib.KeyRight) {
      player_x += player_hor_spd * delta_time
    }
    if @raylib.is_key_down(@raylib.KeySpace) && can_jump {
      player_speed = -player_jump_spd
      can_jump = false
    }

    let mut hit_obstacle = false
    for i = 0; i < env_count; i = i + 1 {
      let rect = env_rects[i]
      if env_blocking[i] &&
        rect.x <= player_x &&
        rect.x + rect.width >= player_x &&
        rect.y >= player_y &&
        rect.y <= player_y + player_speed * delta_time {
        hit_obstacle = true
        player_speed = 0.0
        player_y = rect.y
      }
    }
    if not(hit_obstacle) {
      player_y += player_speed * delta_time
      player_speed += gravity * delta_time
      can_jump = false
    } else {
      can_jump = true
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      // Reset game state
      player_x = 400.0
      player_y = 280.0
      player_speed = 0.0
      can_jump = false
      camera = @raylib.Camera2D::new(
        @raylib.Vector2::new(
          Float::from_int(screen_width) / 2.0,
          Float::from_int(screen_height) / 2.0,
        ),
        @raylib.Vector2::new(player_x, player_y),
        0.0,
        1.0,
      )
    }

    // Events playing
    if event_playing {
      let ae_count = @raylib.automation_event_list_count(aelist)
      while current_play_frame < ae_count {
        let event = @raylib.automation_event_list_get(
          aelist, current_play_frame,
        )
        if play_frame_counter != event.frame {
          break
        }
        @raylib.play_automation_event(event)
        current_play_frame += 1
        if current_play_frame == ae_count {
          event_playing = false
          current_play_frame = 0
          play_frame_counter = 0
          break
        }
      }
      play_frame_counter += 1
    }

    // Update camera
    let mut offset_x = Float::from_int(screen_width) / 2.0
    let mut offset_y = Float::from_int(screen_height) / 2.0
    let mut zoom = camera.zoom + @raylib.get_mouse_wheel_move() * 0.05
    if zoom > 3.0 {
      zoom = 3.0
    } else if zoom < 0.25 {
      zoom = 0.25
    }

    let mut min_x : Float = 1000.0
    let mut min_y : Float = 1000.0
    let mut max_x : Float = -1000.0
    let mut max_y : Float = -1000.0
    for i = 0; i < env_count; i = i + 1 {
      let rect = env_rects[i]
      if rect.x < min_x {
        min_x = rect.x
      }
      if rect.x + rect.width > max_x {
        max_x = rect.x + rect.width
      }
      if rect.y < min_y {
        min_y = rect.y
      }
      if rect.y + rect.height > max_y {
        max_y = rect.y + rect.height
      }
    }

    camera = @raylib.Camera2D::new(
      @raylib.Vector2::new(offset_x, offset_y),
      @raylib.Vector2::new(player_x, player_y),
      0.0,
      zoom,
    )
    let max_screen = @raylib.get_world_to_screen_2d(
      @raylib.Vector2::new(max_x, max_y),
      camera,
    )
    let min_screen = @raylib.get_world_to_screen_2d(
      @raylib.Vector2::new(min_x, min_y),
      camera,
    )
    if max_screen.x < Float::from_int(screen_width) {
      offset_x = Float::from_int(screen_width) -
        (max_screen.x - Float::from_int(screen_width) / 2.0)
    }
    if max_screen.y < Float::from_int(screen_height) {
      offset_y = Float::from_int(screen_height) -
        (max_screen.y - Float::from_int(screen_height) / 2.0)
    }
    if min_screen.x > 0.0 {
      offset_x = Float::from_int(screen_width) / 2.0 - min_screen.x
    }
    if min_screen.y > 0.0 {
      offset_y = Float::from_int(screen_height) / 2.0 - min_screen.y
    }
    camera = @raylib.Camera2D::new(
      @raylib.Vector2::new(offset_x, offset_y),
      @raylib.Vector2::new(player_x, player_y),
      0.0,
      zoom,
    )

    // Events management
    if @raylib.is_key_pressed(@raylib.KeyS) {
      if not(event_playing) {
        if event_recording {
          @raylib.stop_automation_event_recording()
          event_recording = false
          @raylib.export_automation_event_list(aelist, "automation.rae")
          |> ignore
        } else {
          @raylib.set_automation_event_base_frame(180)
          @raylib.start_automation_event_recording()
          event_recording = true
        }
      }
    } else if @raylib.is_key_pressed(@raylib.KeyA) {
      if not(event_recording) && @raylib.automation_event_list_count(aelist) > 0 {
        // Reset scene state to play
        event_playing = true
        play_frame_counter = 0
        current_play_frame = 0
        player_x = 400.0
        player_y = 280.0
        player_speed = 0.0
        can_jump = false
        camera = @raylib.Camera2D::new(
          @raylib.Vector2::new(
            Float::from_int(screen_width) / 2.0,
            Float::from_int(screen_height) / 2.0,
          ),
          @raylib.Vector2::new(player_x, player_y),
          0.0,
          1.0,
        )
      }
    }
    if event_recording || event_playing {
      frame_counter += 1
    } else {
      frame_counter = 0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.lightgray)
    @raylib.begin_mode_2d(camera)

    // Draw environment elements
    for i = 0; i < env_count; i = i + 1 {
      @raylib.draw_rectangle_rec(env_rects[i], env_colors[i])
    }

    // Draw player rectangle
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(player_x - 20.0, player_y - 40.0, 40.0, 40.0),
      @raylib.red,
    )
    @raylib.end_mode_2d()

    // Draw game controls
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(10.0, 10.0, 290.0, 145.0),
      @raylib.fade(@raylib.skyblue, 0.5),
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(10.0, 10.0, 290.0, 145.0),
      1.0,
      @raylib.fade(@raylib.blue, 0.8),
    )
    @raylib.draw_text("Controls:", 20, 20, 10, @raylib.black)
    @raylib.draw_text(
      "- RIGHT | LEFT: Player movement", 30, 40, 10, @raylib.darkgray,
    )
    @raylib.draw_text("- SPACE: Player jump", 30, 60, 10, @raylib.darkgray)
    @raylib.draw_text("- R: Reset game state", 30, 80, 10, @raylib.darkgray)
    @raylib.draw_text(
      "- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, @raylib.black,
    )
    @raylib.draw_text(
      "- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, @raylib.black,
    )

    // Draw automation events recording/playing indicator
    if event_recording {
      @raylib.draw_rectangle_rec(
        @raylib.Rectangle::new(10.0, 160.0, 290.0, 30.0),
        @raylib.fade(@raylib.red, 0.3),
      )
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(10.0, 160.0, 290.0, 30.0),
        1.0,
        @raylib.fade(@raylib.maroon, 0.8),
      )
      @raylib.draw_circle(30, 175, 10.0, @raylib.maroon)
      if frame_counter / 15 % 2 == 1 {
        let ae_count = @raylib.automation_event_list_count(aelist)
        @raylib.draw_text(
          "RECORDING EVENTS... [\{ae_count}]",
          50,
          170,
          10,
          @raylib.maroon,
        )
      }
    } else if event_playing {
      @raylib.draw_rectangle_rec(
        @raylib.Rectangle::new(10.0, 160.0, 290.0, 30.0),
        @raylib.fade(@raylib.lime, 0.3),
      )
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(10.0, 160.0, 290.0, 30.0),
        1.0,
        @raylib.fade(@raylib.darkgreen, 0.8),
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(20.0, 165.0),
        @raylib.Vector2::new(20.0, 185.0),
        @raylib.Vector2::new(40.0, 175.0),
        @raylib.darkgreen,
      )
      if frame_counter / 15 % 2 == 1 {
        @raylib.draw_text(
          "PLAYING RECORDED EVENTS... [\{current_play_frame}]",
          50,
          170,
          10,
          @raylib.darkgreen,
        )
      }
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
