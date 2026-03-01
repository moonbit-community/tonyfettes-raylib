///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn cell_index(x : Int, y : Int) -> Int {
  y * grid_w + x
}

///|
pub fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_w && y >= 0 && y < grid_h
}

///|
pub fn tile_at(game : Game, x : Int, y : Int) -> Int {
  if in_bounds(x, y) {
    game.terrain[cell_index(x, y)]
  } else {
    tile_rock
  }
}

///|
pub fn lava_at(game : Game, x : Int, y : Int) -> Bool {
  if in_bounds(x, y) {
    game.lava[cell_index(x, y)]
  } else {
    false
  }
}

///|
pub fn route_dx(dir : Int) -> Int {
  if dir == dir_left {
    -1
  } else if dir == dir_right {
    1
  } else {
    0
  }
}

///|
pub fn route_dy(dir : Int) -> Int {
  if dir == dir_up {
    -1
  } else if dir == dir_down {
    1
  } else {
    0
  }
}

///|
pub fn total_waiting(game : Game) -> Int {
  let mut total : Int = 0
  for i in 0..<game.site_count {
    if game.sites[i].active && game.sites[i].waiting > 0 {
      total = total + game.sites[i].waiting
    }
  }
  total
}

///|
pub fn level_title(index : Int) -> String {
  if index == 0 {
    "North Ridge Lift"
  } else if index == 1 {
    "Molten Corridor"
  } else {
    "Caldera Spiral"
  }
}

///|
pub fn mission_result_label(game : Game) -> String {
  if game.result == result_win {
    "Mission Successful"
  } else {
    "Mission Failed"
  }
}

///|
pub fn current_goal_progress(game : Game) -> String {
  game.rescued.to_string() + " / " + game.goal_rescue.to_string()
}

///|
pub fn has_next_level(game : Game) -> Bool {
  game.level_index + 1 < level_count
}

///|
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_flag : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
pub fn sample_pointer(
  mouse_x : Float,
  mouse_y : Float,
  mouse_flag : Bool,
  touch_count : Int,
) -> (Bool, Float, Float) {
  if mouse_flag {
    return (true, mouse_x, mouse_y)
  }

  if touch_count > 0 {
    let p = @raylib.get_touch_position(0)
    return (true, p.x, p.y)
  }

  (false, 0.0, 0.0)
}

///|
pub fn map_rect() -> (Int, Int, Int, Int) {
  (map_x, map_y, grid_w * tile_size, grid_h * tile_size)
}

///|
pub fn execute_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 238, panel_w - 274, 68)
}

///|
pub fn clear_route_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 158, panel_w - 274, 62)
}

///|
pub fn coolant_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 84, panel_w - 274, 56)
}

///|
pub fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 24, 184, panel_w - 48, 52)
}

///|
pub fn title_start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, screen_h - 182, 480, 98)
}

///|
pub fn result_restart_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 290, screen_h - 198, 250, 94)
}

///|
pub fn result_next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 40, screen_h - 198, 250, 94)
}

///|
pub fn dpad_center_x() -> Int {
  panel_x + 118
}

///|
pub fn dpad_center_y() -> Int {
  screen_h - 142
}

///|
pub fn dpad_size() -> Int {
  78
}

///|
pub fn dpad_left_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s - 24, dpad_center_y() - s / 2, s, s)
}

///|
pub fn dpad_right_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() + 24, dpad_center_y() - s / 2, s, s)
}

///|
pub fn dpad_up_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s / 2, dpad_center_y() - s - 24, s, s)
}

///|
pub fn dpad_down_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s / 2, dpad_center_y() + 24, s, s)
}
