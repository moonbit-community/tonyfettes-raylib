// Camera/layout state, constants, and functions

// ---- Constants ----

///|
let board_margin_ratio : Float = 0.03

///|
let max_zoom_cell_target : Float = 90.0

// ---- Math helpers ----

///|
fn clamp(value : Float, min : Float, max : Float) -> Float {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
fn float_max(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

// ---- Layout state ----

///|
priv struct LayoutState {
  mut cell_size : Float
  mut offset_x : Float
  mut offset_y : Float
}

///|
fn LayoutState::new() -> LayoutState {
  { cell_size: 0.0, offset_x: 0.0, offset_y: 0.0 }
}

// ---- Camera state ----

///|
priv struct CameraState {
  mut offset_x : Float
  mut offset_y : Float
  mut target_x : Float
  mut target_y : Float
  mut zoom : Float
  mut min_zoom : Float
  mut max_zoom : Float
}

///|
fn CameraState::new() -> CameraState {
  {
    offset_x: 0.0,
    offset_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    zoom: 1.0,
    min_zoom: 1.0,
    max_zoom: 1.0,
  }
}

// ---- Global instances ----

///|
let layout_ : LayoutState = LayoutState::new()

///|
let camera : CameraState = CameraState::new()

// ---- Functions ----

///|
fn calculate_layout() -> Unit {
  let sw = Float::from_int(screen.width)
  let sh = Float::from_int(screen.height)
  let margin = sw * board_margin_ratio
  let avail_w = sw - margin * 2.0
  let avail_h = sh - screen.header_height - screen.footer_height - margin * 2.0
  let cell_w = avail_w / Float::from_int(game.cols)
  let cell_h = avail_h / Float::from_int(game.rows)
  layout_.cell_size = if cell_w < cell_h { cell_w } else { cell_h }
  let board_w = layout_.cell_size * Float::from_int(game.cols)
  let board_h = layout_.cell_size * Float::from_int(game.rows)
  layout_.offset_x = (sw - board_w) / 2.0
  layout_.offset_y = screen.header_height +
    (sh - screen.header_height - screen.footer_height - board_h) / 2.0
}

///|
fn init_camera() -> Unit {
  let avail_h = Float::from_int(screen.height) -
    screen.header_height -
    screen.footer_height
  camera.offset_x = Float::from_int(screen.width) / 2.0
  camera.offset_y = screen.header_height + avail_h / 2.0
  camera.target_x = layout_.offset_x +
    Float::from_int(game.cols) * layout_.cell_size / 2.0
  camera.target_y = layout_.offset_y +
    Float::from_int(game.rows) * layout_.cell_size / 2.0
  camera.zoom = 1.0
  camera.min_zoom = 1.0
  camera.max_zoom = float_max(
    max_zoom_cell_target / layout_.cell_size,
    camera.min_zoom,
  )
  touch.active_gesture = touch_none
  touch.gesture_decided = false
  touch.long_press_triggered = false
  touch.move_dist = 0.0
}

///|
fn clamp_camera() -> Unit {
  let sw = Float::from_int(screen.width)
  let margin = sw * board_margin_ratio
  let board_w = Float::from_int(game.cols) * layout_.cell_size
  let board_h = Float::from_int(game.rows) * layout_.cell_size
  let board_cx = layout_.offset_x + board_w / 2.0
  let board_cy = layout_.offset_y + board_h / 2.0
  let avail_h = Float::from_int(screen.height) -
    screen.header_height -
    screen.footer_height
  let vis_w = sw / camera.zoom
  let vis_h = avail_h / camera.zoom
  if board_w + margin * 2.0 > vis_w {
    let mn = layout_.offset_x - margin + vis_w / 2.0
    let mx = layout_.offset_x + board_w + margin - vis_w / 2.0
    camera.target_x = clamp(camera.target_x, mn, mx)
  } else {
    camera.target_x = board_cx
  }
  if board_h + margin * 2.0 > vis_h {
    let mn = layout_.offset_y - margin + vis_h / 2.0
    let mx = layout_.offset_y + board_h + margin - vis_h / 2.0
    camera.target_y = clamp(camera.target_y, mn, mx)
  } else {
    camera.target_y = board_cy
  }
}

///|
fn make_camera() -> @raylib.Camera2D {
  @raylib.Camera2D::new(
    @raylib.Vector2::new(camera.offset_x, camera.offset_y),
    @raylib.Vector2::new(camera.target_x, camera.target_y),
    0.0,
    camera.zoom,
  )
}

///|
fn screen_to_board(sx : Float, sy : Float) -> (Float, Float) {
  let cam = make_camera()
  let world = @raylib.get_screen_to_world_2d(@raylib.Vector2::new(sx, sy), cam)
  (world.x, world.y)
}

///|
fn get_cell_row(y : Float) -> Int {
  ((y - layout_.offset_y) / layout_.cell_size).to_int()
}

///|
fn get_cell_col(x : Float) -> Int {
  ((x - layout_.offset_x) / layout_.cell_size).to_int()
}
