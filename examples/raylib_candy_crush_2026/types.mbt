///|
struct Game {
  kinds : Array[Int]
  specials : Array[Int]
  jelly : Array[Int]
  flash : Array[Float]
  marks : Array[Bool]
  spawn_special : Array[Int]
  mut state : Int
  mut level : Int
  mut score : Int
  mut best_score : Int
  mut chain_best : Int
  mut moves_left : Int
  mut jelly_left : Int
  mut selected : Bool
  mut sel_x : Int
  mut sel_y : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut hint_active : Bool
  mut hint_x0 : Int
  mut hint_y0 : Int
  mut hint_x1 : Int
  mut hint_y1 : Int
  mut hint_t : Float
  mut message : String
  mut message_t : Float
  mut touch_mode : Bool
  mut touch_cd : Float
  mut swap_flash_t : Float
  mut swap_x0 : Int
  mut swap_y0 : Int
  mut swap_x1 : Int
  mut swap_y1 : Int
}

///|
fn Game::new() -> Game {
  {
    kinds: Array::make(board_cells, 0),
    specials: Array::make(board_cells, special_none),
    jelly: Array::make(board_cells, 0),
    flash: Array::make(board_cells, 0.0),
    marks: Array::make(board_cells, false),
    spawn_special: Array::make(board_cells, special_none),
    state: state_title,
    level: 1,
    score: 0,
    best_score: 0,
    chain_best: 0,
    moves_left: moves_base,
    jelly_left: 0,
    selected: false,
    sel_x: 0,
    sel_y: 0,
    cursor_x: 0,
    cursor_y: 0,
    hint_active: false,
    hint_x0: 0,
    hint_y0: 0,
    hint_x1: 0,
    hint_y1: 0,
    hint_t: 0.0,
    message: "",
    message_t: 0.0,
    touch_mode: false,
    touch_cd: 0.0,
    swap_flash_t: 0.0,
    swap_x0: 0,
    swap_y0: 0,
    swap_x1: 0,
    swap_y1: 0,
  }
}
