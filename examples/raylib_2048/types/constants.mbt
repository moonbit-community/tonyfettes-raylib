///|
pub let screen_w : Int = 560

///|
pub let screen_h : Int = 740

///|
pub let target_fps : Int = 60

///|
pub let grid_size : Int = 4

///|
pub let cell_count : Int = grid_size * grid_size

///|
pub let board_padding : Int = 16

///|
pub let cell_gap : Int = 12

///|
pub let board_top : Int = 200

///|
pub let board_left : Int = 16

///|
pub let board_size : Int = screen_w - board_left * 2

///|
pub let cell_size : Int = (
    board_size - board_padding * 2 - cell_gap * (grid_size - 1)
  ) /
  grid_size

///|
pub let anim_slide_speed : Float = 12.0

///|
pub let anim_pop_speed : Float = 6.0

///|
pub let anim_pop_scale : Float = 1.15

///|
pub let bg_color : @raylib.Color = @raylib.Color::new(250, 248, 239, 255)

///|
pub let board_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
pub let cell_empty_color : @raylib.Color = @raylib.Color::new(
  205, 193, 180, 255,
)

///|
pub let header_text_color : @raylib.Color = @raylib.Color::new(
  119, 110, 101, 255,
)

///|
pub let score_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
pub let score_label_color : @raylib.Color = @raylib.Color::new(
  238, 228, 218, 255,
)

///|
pub let score_value_color : @raylib.Color = @raylib.Color::new(
  255, 255, 255, 255,
)

///|
pub let btn_color : @raylib.Color = @raylib.Color::new(143, 122, 102, 255)

///|
pub let btn_text_color : @raylib.Color = @raylib.Color::new(249, 246, 242, 255)
