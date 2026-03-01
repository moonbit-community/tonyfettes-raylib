///|
pub let screen_w : Int = 680

///|
pub let screen_h : Int = 800

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 8

///|
pub let cell_count : Int = grid_cols * grid_rows

///|
pub let num_colors : Int = 6

///|
pub let cell_px : Int = 64

///|
pub let cell_gap : Int = 4

///|
pub let board_left : Int = 36

///|
pub let board_top : Int = 160

///|
pub let swap_speed : Float = 10.0

///|
pub let fall_speed : Float = 12.0

///|
pub let flash_duration : Float = 0.25

///|
pub let base_moves : Int = 30

///|
pub let base_target : Int = 1000

///|
pub fn gem_color(kind : GemKind) -> @raylib.Color {
  match kind {
    Red => @raylib.Color::new(231, 76, 60, 255)
    Green => @raylib.Color::new(46, 204, 113, 255)
    Blue => @raylib.Color::new(52, 152, 219, 255)
    Yellow => @raylib.Color::new(241, 196, 15, 255)
    Purple => @raylib.Color::new(155, 89, 182, 255)
    Orange => @raylib.Color::new(230, 126, 34, 255)
    Empty => @raylib.Color::new(200, 200, 200, 255)
  }
}

///|
pub fn gem_highlight(kind : GemKind) -> @raylib.Color {
  match kind {
    Red => @raylib.Color::new(255, 120, 100, 255)
    Green => @raylib.Color::new(100, 230, 150, 255)
    Blue => @raylib.Color::new(100, 180, 240, 255)
    Yellow => @raylib.Color::new(255, 220, 80, 255)
    Purple => @raylib.Color::new(190, 130, 210, 255)
    Orange => @raylib.Color::new(250, 160, 80, 255)
    Empty => @raylib.Color::new(230, 230, 230, 255)
  }
}

///|
pub let bg_color : @raylib.Color = @raylib.Color::new(44, 62, 80, 255)

///|
pub let board_bg_color : @raylib.Color = @raylib.Color::new(34, 49, 63, 255)

///|
pub let panel_text_color : @raylib.Color = @raylib.Color::new(236, 240, 241, 255)

///|
pub let panel_label_color : @raylib.Color = @raylib.Color::new(149, 165, 166, 255)

///|
pub let select_color : @raylib.Color = @raylib.Color::new(255, 255, 255, 200)
