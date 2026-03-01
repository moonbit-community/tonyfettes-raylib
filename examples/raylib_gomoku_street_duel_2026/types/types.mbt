///|
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub(all) enum Player {
  Empty
  Human
  AI
} derive(Eq)

///|
pub(all) enum Dir {
  DirNone
  Left
  Right
  Up
  Down
} derive(Eq)

///|
pub(all) enum SparkKind {
  SparkAI
  SparkHuman
  SparkUndo
  SparkHint
} derive(Eq)

///|
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : SparkKind
}

///|
pub(all) struct Game {
  board : Array[Player]
  hist_x : Array[Int]
  hist_y : Array[Int]
  hist_p : Array[Player]
  mut hist_len : Int
  sparks : Array[Spark]
  mut state : GameState
  mut turn : Player
  mut winner : Player
  mut move_count : Int
  mut human_wins : Int
  mut ai_wins : Int
  mut draws : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut last_hx : Int
  mut last_hy : Int
  mut last_ax : Int
  mut last_ay : Int
  mut hints_left : Int
  mut hint_active : Bool
  mut hint_x : Int
  mut hint_y : Int
  mut hint_ttl : Float
  mut ai_delay : Float
  mut game_time : Float
  mut hold_dir : Dir
  mut repeat_t : Float
  mut touch_action_cd : Float
  mut message : String
  mut message_t : Float
  mut shake_t : Float
  mut ui_t : Float
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut mouse_press : Bool
  mut touch_count : Int
}

///|
pub fn Game::new() -> Game {
  let sparks_arr : Array[Spark] = Array::makei(900, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: SparkAI,
    }
  })

  {
    board: Array::make(max_cells, Empty),
    hist_x: Array::make(max_cells, 0),
    hist_y: Array::make(max_cells, 0),
    hist_p: Array::make(max_cells, Empty),
    hist_len: 0,
    sparks: sparks_arr,
    state: Title,
    turn: Human,
    winner: Empty,
    move_count: 0,
    human_wins: 0,
    ai_wins: 0,
    draws: 0,
    cursor_x: board_n / 2,
    cursor_y: board_n / 2,
    last_hx: -1,
    last_hy: -1,
    last_ax: -1,
    last_ay: -1,
    hints_left: 4,
    hint_active: false,
    hint_x: 0,
    hint_y: 0,
    hint_ttl: 0.0,
    ai_delay: 0.0,
    game_time: 0.0,
    hold_dir: DirNone,
    repeat_t: 0.0,
    touch_action_cd: 0.0,
    message: "",
    message_t: 0.0,
    shake_t: 0.0,
    ui_t: 0.0,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    mouse_press: false,
    touch_count: 0,
  }
}
