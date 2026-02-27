// Touch/input state, gesture constants, and all update logic

// ---- Gesture state constants ----

///|
let touch_none : Int = 0

///|
let tap_or_hold : Int = 1

///|
let gesture_pan : Int = 2

///|
let gesture_pinch : Int = 3

// ---- Touch thresholds ----

///|
let long_press_seconds : Float = 0.5

///|
let tap_max_dist : Float = 12.0

///|
let highlight_clear_dist : Float = 15.0

///|
let min_zoom_epsilon : Float = 0.01

// ---- Helpers ----

///|
fn vector2_distance(a : @raylib.Vector2, b : @raylib.Vector2) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  (dx * dx + dy * dy).sqrt()
}

///|
fn point_in_rect(
  px : Float,
  py : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  px >= rx && px <= rx + rw && py >= ry && py <= ry + rh
}

// ---- Touch state ----

///|
priv struct TouchState {
  mut start_x : Float
  mut start_y : Float
  mut timer : Float
  mut long_press_triggered : Bool
  mut gesture_decided : Bool
  mut active_gesture : Int
  mut move_dist : Float
}

///|
fn TouchState::new() -> TouchState {
  {
    start_x: 0.0,
    start_y: 0.0,
    timer: 0.0,
    long_press_triggered: false,
    gesture_decided: false,
    active_gesture: touch_none,
    move_dist: 0.0,
  }
}

// ---- Pinch state ----

///|
priv struct PinchState {
  mut start_dist : Float
  mut start_zoom : Float
}

///|
fn PinchState::new() -> PinchState {
  { start_dist: 0.0, start_zoom: 0.0 }
}

// ---- Pan state ----

///|
priv struct PanState {
  mut start_x : Float
  mut start_y : Float
  mut start_target_x : Float
  mut start_target_y : Float
}

///|
fn PanState::new() -> PanState {
  { start_x: 0.0, start_y: 0.0, start_target_x: 0.0, start_target_y: 0.0 }
}

// ---- Highlight state ----

///|
priv struct HighlightState {
  mut row : Int
  mut col : Int
  mut is_chord : Bool
}

///|
fn HighlightState::new() -> HighlightState {
  { row: -1, col: -1, is_chord: false }
}

// ---- Global instances ----

///|
let touch : TouchState = TouchState::new()

///|
let pinch : PinchState = PinchState::new()

///|
let pan : PanState = PanState::new()

///|
let highlight : HighlightState = HighlightState::new()

// ---- State helpers ----

///|
fn clear_highlight() -> Unit {
  highlight.row = -1
  highlight.col = -1
  highlight.is_chord = false
}

///|
fn clear_touch_state() -> Unit {
  touch.active_gesture = touch_none
  touch.gesture_decided = false
  touch.long_press_triggered = false
  clear_highlight()
}

// ---- Update functions ----

///|
fn update() -> Unit {
  update_screen_resize()
  if game.state == state_menu {
    update_menu()
  } else if game.state == state_about {
    update_about()
  } else if game.state == state_playing {
    update_playing()
  } else {
    update_game_over()
  }
}

///|
fn update_screen_resize() -> Unit {
  let new_w = @raylib.get_screen_width()
  let new_h = @raylib.get_screen_height()
  if new_w != screen.width || new_h != screen.height {
    screen.width = new_w
    screen.height = new_h
    screen.header_height = Float::from_int(new_h) * header_height_ratio
    screen.footer_height = Float::from_int(new_h) * footer_height_ratio
    if game.state == state_playing ||
      game.state == state_won ||
      game.state == state_lost {
      calculate_layout()
      init_camera()
    }
  }
}

///|
fn update_menu() -> Unit {
  @raylib.set_gestures_enabled(@raylib.GestureTap)
  if @raylib.is_gesture_detected(@raylib.GestureTap) {
    let sw = Float::from_int(screen.width)
    let sh = Float::from_int(screen.height)
    let pos = @raylib.get_touch_position(0)
    let btn_w = sw * menu_btn_width_ratio
    let btn_h = sh * menu_btn_height_ratio
    let btn_x = (sw - btn_w) / 2.0
    let start_y = sh * menu_start_y_ratio
    let spacing = btn_h * menu_btn_spacing_mult
    // Easy
    if point_in_rect(pos.x, pos.y, btn_x, start_y, btn_w, btn_h) {
      init_board(easy_rows, easy_cols, easy_mines)
    }
    // Medium
    let med_y = start_y + spacing
    if point_in_rect(pos.x, pos.y, btn_x, med_y, btn_w, btn_h) {
      init_board(medium_rows, medium_cols, medium_mines)
    }
    // Hard
    let hard_y = start_y + spacing * 2.0
    if point_in_rect(pos.x, pos.y, btn_x, hard_y, btn_w, btn_h) {
      init_board(hard_rows, hard_cols, hard_mines)
    }
    // About
    let about_w = sw * menu_about_width_ratio
    let about_h = sh * menu_about_height_ratio
    let about_x = (sw - about_w) / 2.0
    let about_y = start_y + spacing * 3.0 + btn_h * 0.3
    if point_in_rect(pos.x, pos.y, about_x, about_y, about_w, about_h) {
      game.state = state_about
    }
  }
}

///|
fn update_about() -> Unit {
  @raylib.set_gestures_enabled(@raylib.GestureTap)
  if @raylib.is_gesture_detected(@raylib.GestureTap) {
    game.state = state_menu
  }
}

///|
fn update_game_over() -> Unit {
  @raylib.set_gestures_enabled(@raylib.GestureTap)
  if @raylib.is_gesture_detected(@raylib.GestureTap) {
    game.state = state_menu
  }
}

///|
fn update_playing() -> Unit {
  @raylib.set_gestures_enabled(0)
  game.timer = game.timer + @raylib.get_frame_time()
  let touch_count = @raylib.get_touch_point_count()
  // Touch start
  if touch_count > 0 && touch.active_gesture == touch_none {
    handle_touch_start(touch_count)
  }
  // Touch held
  if touch_count > 0 && touch.active_gesture != touch_none {
    handle_touch_held(touch_count)
  }
  // Touch released
  if touch_count == 0 && touch.active_gesture != touch_none {
    handle_touch_release()
  }
}

///|
fn handle_touch_start(touch_count : Int) -> Unit {
  let hh = screen.header_height
  let ts = @raylib.get_touch_position(0)
  touch.start_x = ts.x
  touch.start_y = ts.y
  touch.timer = 0.0
  touch.long_press_triggered = false
  touch.gesture_decided = false
  touch.move_dist = 0.0
  touch.active_gesture = tap_or_hold
  // Set highlight for pressed cell
  if ts.y > hh {
    let (wx, wy) = screen_to_board(ts.x, ts.y)
    let hr = get_cell_row(wy)
    let hc = get_cell_col(wx)
    if is_valid_cell(hr, hc, game.rows, game.cols) {
      highlight.row = hr
      highlight.col = hc
      let hidx = cell_index(hr, hc, game.cols)
      let hcell = game.board[hidx]
      highlight.is_chord = hcell.is_revealed && hcell.neighbor_mines > 0
    }
  }
  if touch_count >= 2 {
    touch.active_gesture = gesture_pinch
    touch.gesture_decided = true
    clear_highlight()
    let t0 = @raylib.get_touch_position(0)
    let t1 = @raylib.get_touch_position(1)
    pinch.start_dist = vector2_distance(t0, t1)
    pinch.start_zoom = camera.zoom
  }
}

///|
fn handle_touch_held(touch_count : Int) -> Unit {
  touch.timer = touch.timer + @raylib.get_frame_time()
  let pos = @raylib.get_touch_position(0)
  let ts = @raylib.Vector2::new(touch.start_x, touch.start_y)
  touch.move_dist = vector2_distance(pos, ts)
  // Clear highlight if moved too far
  if touch.move_dist > highlight_clear_dist {
    clear_highlight()
  }
  // Transition to pinch
  if touch.active_gesture != gesture_pinch && touch_count >= 2 {
    touch.active_gesture = gesture_pinch
    touch.gesture_decided = true
    clear_highlight()
    let t0 = @raylib.get_touch_position(0)
    let t1 = @raylib.get_touch_position(1)
    pinch.start_dist = vector2_distance(t0, t1)
    pinch.start_zoom = camera.zoom
  }
  // Transition to pan
  if not(touch.gesture_decided) &&
    touch_count == 1 &&
    touch.move_dist > tap_max_dist &&
    camera.zoom > camera.min_zoom + min_zoom_epsilon {
    touch.active_gesture = gesture_pan
    touch.gesture_decided = true
    clear_highlight()
    pan.start_x = pos.x
    pan.start_y = pos.y
    pan.start_target_x = camera.target_x
    pan.start_target_y = camera.target_y
  }
  // Handle pinch zoom
  if touch.active_gesture == gesture_pinch {
    if touch_count >= 2 {
      let t0 = @raylib.get_touch_position(0)
      let t1 = @raylib.get_touch_position(1)
      let current_dist = vector2_distance(t0, t1)
      if pinch.start_dist > 1.0 {
        let mid = @raylib.Vector2::new((t0.x + t1.x) / 2.0, (t0.y + t1.y) / 2.0)
        // World position before zoom
        let cam_before = make_camera()
        let world_before = @raylib.get_screen_to_world_2d(mid, cam_before)
        // Apply new zoom
        let new_zoom = pinch.start_zoom * (current_dist / pinch.start_dist)
        camera.zoom = clamp(new_zoom, camera.min_zoom, camera.max_zoom)
        // World position after zoom
        let cam_after = make_camera()
        let world_after = @raylib.get_screen_to_world_2d(mid, cam_after)
        // Stabilize midpoint
        camera.target_x = camera.target_x + world_before.x - world_after.x
        camera.target_y = camera.target_y + world_before.y - world_after.y
      }
    }
    clamp_camera()
  }
  // Handle pan
  if touch.active_gesture == gesture_pan {
    camera.target_x = pan.start_target_x - (pos.x - pan.start_x) / camera.zoom
    camera.target_y = pan.start_target_y - (pos.y - pan.start_y) / camera.zoom
    clamp_camera()
  }
  // Long press detection — only set flag, defer execution to release
  if touch.active_gesture == tap_or_hold &&
    not(touch.long_press_triggered) &&
    touch.timer >= long_press_seconds &&
    touch.move_dist < highlight_clear_dist {
    touch.long_press_triggered = true
    touch.gesture_decided = true
  }
}

///|
fn handle_touch_release() -> Unit {
  let sw = Float::from_int(screen.width)
  let hh = screen.header_height
  if touch.long_press_triggered && touch.move_dist < highlight_clear_dist {
    // Long press release: toggle flag at highlight position
    if highlight.row >= 0 && highlight.col >= 0 {
      toggle_flag(
        game.board,
        game.rows,
        game.cols,
        highlight.row,
        highlight.col,
      )
    }
  } else if touch.active_gesture == tap_or_hold &&
    not(touch.long_press_triggered) &&
    touch.move_dist < tap_max_dist {
    // Short tap — check FAB mode toggle at bottom center
    let sh = Float::from_int(screen.height)
    let fab_size = screen.footer_height * 0.75
    let fab_x = (sw - fab_size) / 2.0
    let fab_y = sh -
      screen.footer_height +
      (screen.footer_height - fab_size) / 2.0
    if point_in_rect(
        touch.start_x,
        touch.start_y,
        fab_x,
        fab_y,
        fab_size,
        fab_size,
      ) {
      // Toggle mode
      game.current_mode = if game.current_mode == mode_dig {
        mode_flag
      } else {
        mode_dig
      }
    } else {
      // Check restart button
      let btn_size = hh * restart_btn_ratio
      let btn_x = (sw - btn_size) / 2.0
      let btn_y = (hh - btn_size) / 2.0
      if point_in_rect(
          touch.start_x,
          touch.start_y,
          btn_x,
          btn_y,
          btn_size,
          btn_size,
        ) {
        game.state = state_menu
      } else if touch.start_y > hh && touch.start_y < sh - screen.footer_height {
        // Cell operation (only in board area, between header and footer)
        let (wx, wy) = screen_to_board(touch.start_x, touch.start_y)
        let row = get_cell_row(wy)
        let col = get_cell_col(wx)
        handle_cell_tap(row, col)
      }
    }
  }
  // Clear all state
  clear_touch_state()
}

///|
fn handle_cell_tap(row : Int, col : Int) -> Unit {
  if not(is_valid_cell(row, col, game.rows, game.cols)) {
    return
  }
  let idx = cell_index(row, col, game.cols)
  let cell = game.board[idx]
  if cell.is_revealed && cell.neighbor_mines > 0 {
    // Chord reveal (works in both modes)
    let hit_mine = chord_reveal(game.board, game.rows, game.cols, row, col)
    if hit_mine {
      game.state = state_lost
    } else if check_win() {
      game.state = state_won
    }
  } else if game.first_click {
    // First click: always dig regardless of mode
    game.first_click = false
    place_mines(game.board, game.rows, game.cols, game.total_mines, row, col)
    let hit_mine = reveal_cell(game.board, game.rows, game.cols, row, col)
    if hit_mine {
      game.state = state_lost
    } else if check_win() {
      game.state = state_won
    }
  } else if game.current_mode == mode_flag {
    // Flag mode on unrevealed cell
    toggle_flag(game.board, game.rows, game.cols, row, col)
  } else {
    // Dig mode
    let hit_mine = reveal_cell(game.board, game.rows, game.cols, row, col)
    if hit_mine {
      game.state = state_lost
    } else if check_win() {
      game.state = state_won
    }
  }
}
