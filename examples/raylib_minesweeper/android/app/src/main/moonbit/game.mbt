// Game state, screen state, constants, and lifecycle functions

// ---- Game state constants ----

///|
let state_menu : Int = 0

///|
let state_playing : Int = 1

///|
let state_won : Int = 2

///|
let state_lost : Int = 3

///|
let state_about : Int = 4

// ---- Mode constants ----

///|
let mode_dig : Int = 0

///|
let mode_flag : Int = 1

// ---- Difficulty presets ----

///|
let easy_rows : Int = 12

///|
let easy_cols : Int = 8

///|
let easy_mines : Int = 10

///|
let medium_rows : Int = 14

///|
let medium_cols : Int = 9

///|
let medium_mines : Int = 25

///|
let hard_rows : Int = 16

///|
let hard_cols : Int = 10

///|
let hard_mines : Int = 35

// ---- Layout ratio ----

///|
let header_height_ratio : Float = 0.08

///|
let footer_height_ratio : Float = 0.07

// ---- Screen state ----

///|
priv struct ScreenState {
  mut width : Int
  mut height : Int
  mut header_height : Float
  mut footer_height : Float
}

///|
fn ScreenState::new(w : Int, h : Int) -> ScreenState {
  {
    width: w,
    height: h,
    header_height: Float::from_int(h) * header_height_ratio,
    footer_height: Float::from_int(h) * footer_height_ratio,
  }
}

// ---- Game state ----

///|
priv struct GameState {
  mut state : Int
  mut rows : Int
  mut cols : Int
  mut total_mines : Int
  mut revealed_count : Int
  mut flag_count : Int
  mut first_click : Bool
  mut timer : Float
  mut board : Array[Cell]
  mut current_mode : Int
}

///|
fn GameState::new() -> GameState {
  {
    state: state_menu,
    rows: 0,
    cols: 0,
    total_mines: 0,
    revealed_count: 0,
    flag_count: 0,
    first_click: true,
    timer: 0.0,
    board: [],
    current_mode: mode_dig,
  }
}

// ---- Global instances ----

///|
let screen : ScreenState = ScreenState::new(0, 0)

///|
let game : GameState = GameState::new()

// ---- Lifecycle functions ----

///|
fn init_board(r : Int, c : Int, mines : Int) -> Unit {
  game.rows = r
  game.cols = c
  game.total_mines = mines
  game.revealed_count = 0
  game.flag_count = 0
  game.first_click = true
  game.timer = 0.0
  game.state = state_playing
  game.current_mode = mode_dig
  let total = r * c
  let new_board = Array::make(total, Cell::new())
  for i = 0; i < total; i = i + 1 {
    new_board[i] = Cell::new()
  }
  game.board = new_board
  calculate_layout()
  init_camera()
}

///|
fn check_win() -> Bool {
  game.revealed_count == game.rows * game.cols - game.total_mines
}
