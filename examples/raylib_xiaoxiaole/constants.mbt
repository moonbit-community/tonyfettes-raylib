///|
let screen_w : Int = 680

///|
let screen_h : Int = 800

///|
let target_fps : Int = 60

///|
let grid_cols : Int = 8

///|
let grid_rows : Int = 8

///|
let cell_count : Int = grid_cols * grid_rows

///|
let num_colors : Int = 6

///|
let cell_px : Int = 64

///|
let cell_gap : Int = 4

///|
let board_left : Int = 36

///|
let board_top : Int = 160

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_swap : Int = 2

///|
let state_remove : Int = 3

///|
let state_fall : Int = 4

///|
let state_over : Int = 5

///|
let state_clear : Int = 6

///|
let swap_speed : Float = 10.0

///|
let fall_speed : Float = 12.0

///|
let flash_duration : Float = 0.25

///|
let base_moves : Int = 30

///|
let base_target : Int = 1000

///|
fn gem_color(kind : Int) -> @raylib.Color {
  match kind {
    0 => @raylib.Color::new(231, 76, 60, 255) // Red
    1 => @raylib.Color::new(46, 204, 113, 255) // Green
    2 => @raylib.Color::new(52, 152, 219, 255) // Blue
    3 => @raylib.Color::new(241, 196, 15, 255) // Yellow
    4 => @raylib.Color::new(155, 89, 182, 255) // Purple
    5 => @raylib.Color::new(230, 126, 34, 255) // Orange
    _ => @raylib.Color::new(200, 200, 200, 255)
  }
}

///|
fn gem_highlight(kind : Int) -> @raylib.Color {
  match kind {
    0 => @raylib.Color::new(255, 120, 100, 255)
    1 => @raylib.Color::new(100, 230, 150, 255)
    2 => @raylib.Color::new(100, 180, 240, 255)
    3 => @raylib.Color::new(255, 220, 80, 255)
    4 => @raylib.Color::new(190, 130, 210, 255)
    5 => @raylib.Color::new(250, 160, 80, 255)
    _ => @raylib.Color::new(230, 230, 230, 255)
  }
}

///|
let bg_color : @raylib.Color = @raylib.Color::new(44, 62, 80, 255)

///|
let board_bg_color : @raylib.Color = @raylib.Color::new(34, 49, 63, 255)

///|
let panel_text_color : @raylib.Color = @raylib.Color::new(236, 240, 241, 255)

///|
let panel_label_color : @raylib.Color = @raylib.Color::new(149, 165, 166, 255)


///|
let select_color : @raylib.Color = @raylib.Color::new(255, 255, 255, 200)
