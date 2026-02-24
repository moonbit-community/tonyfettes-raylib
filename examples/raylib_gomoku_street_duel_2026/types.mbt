///|
struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
struct Game {
  board : Array[Int]
  hist_x : Array[Int]
  hist_y : Array[Int]
  hist_p : Array[Int]
  mut hist_len : Int
  sparks : Array[Spark]
  mut state : Int
  mut turn : Int
  mut winner : Int
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
  mut hold_dir : Int
  mut repeat_t : Float
  mut touch_action_cd : Float
  mut message : String
  mut message_t : Float
  mut shake_t : Float
  mut ui_t : Float
}

///|
fn Game::new() -> Game {
  let sparks_arr : Array[Spark] = Array::makei(900, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  {
    board: Array::make(max_cells, player_empty),
    hist_x: Array::make(max_cells, 0),
    hist_y: Array::make(max_cells, 0),
    hist_p: Array::make(max_cells, 0),
    hist_len: 0,
    sparks: sparks_arr,
    state: state_title,
    turn: player_human,
    winner: player_empty,
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
    hold_dir: dir_none,
    repeat_t: 0.0,
    touch_action_cd: 0.0,
    message: "",
    message_t: 0.0,
    shake_t: 0.0,
    ui_t: 0.0,
  }
}
