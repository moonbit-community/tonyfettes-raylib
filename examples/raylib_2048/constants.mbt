///|
let screen_w : Int = 560

///|
let screen_h : Int = 740

///|
let target_fps : Int = 60

///|
let grid_size : Int = 4

///|
let cell_count : Int = grid_size * grid_size

///|
let board_padding : Int = 16

///|
let cell_gap : Int = 12

///|
let board_top : Int = 200

///|
let board_left : Int = 16

///|
let board_size : Int = screen_w - board_left * 2

///|
let cell_size : Int = (
    board_size - board_padding * 2 - cell_gap * (grid_size - 1)
  ) /
  grid_size

///|
let anim_slide_speed : Float = 12.0

///|
let anim_pop_speed : Float = 6.0

///|
let anim_pop_scale : Float = 1.15

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_won : Int = 2

///|
let state_over : Int = 3

///|
fn tile_color(value : Int) -> @raylib.Color {
  match value {
    2 => @raylib.Color::new(238, 228, 218, 255)
    4 => @raylib.Color::new(237, 224, 200, 255)
    8 => @raylib.Color::new(242, 177, 121, 255)
    16 => @raylib.Color::new(245, 149, 99, 255)
    32 => @raylib.Color::new(246, 124, 95, 255)
    64 => @raylib.Color::new(246, 94, 59, 255)
    128 => @raylib.Color::new(237, 207, 114, 255)
    256 => @raylib.Color::new(237, 204, 97, 255)
    512 => @raylib.Color::new(237, 200, 80, 255)
    1024 => @raylib.Color::new(237, 197, 63, 255)
    2048 => @raylib.Color::new(237, 194, 46, 255)
    _ => @raylib.Color::new(60, 58, 50, 255)
  }
}

///|
fn tile_text_color(value : Int) -> @raylib.Color {
  if value <= 4 {
    @raylib.Color::new(119, 110, 101, 255)
  } else {
    @raylib.Color::new(249, 246, 242, 255)
  }
}

///|
fn tile_font_size(value : Int) -> Int {
  if value < 100 {
    40
  } else if value < 1000 {
    32
  } else if value < 10000 {
    26
  } else {
    20
  }
}

///|
let bg_color : @raylib.Color = @raylib.Color::new(250, 248, 239, 255)

///|
let board_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
let cell_empty_color : @raylib.Color = @raylib.Color::new(205, 193, 180, 255)

///|
let header_text_color : @raylib.Color = @raylib.Color::new(119, 110, 101, 255)

///|
let score_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
let score_label_color : @raylib.Color = @raylib.Color::new(238, 228, 218, 255)

///|
let score_value_color : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
let btn_color : @raylib.Color = @raylib.Color::new(143, 122, 102, 255)

///|
let btn_text_color : @raylib.Color = @raylib.Color::new(249, 246, 242, 255)
