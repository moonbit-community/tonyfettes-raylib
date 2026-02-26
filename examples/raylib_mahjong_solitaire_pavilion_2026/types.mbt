///|
struct UndoPair {
  valid : Bool
  x1 : Int
  y1 : Int
  kind1 : Int
  x2 : Int
  y2 : Int
  kind2 : Int
  prev_score : Int
  prev_combo : Int
  prev_timer : Float
  prev_remaining : Int
}

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
  active : Array[Bool]
  cells : Array[Int]
  undo : Array[UndoPair]
  mut undo_len : Int
  sparks : Array[Spark]
  mut state : Int
  mut level_index : Int
  level_count : Int
  mut level_name : String
  mut board_w : Int
  mut board_h : Int
  mut kind_count : Int
  mut score : Int
  mut combo : Int
  mut timer : Float
  mut time_limit : Float
  mut remaining : Int
  mut hints_left : Int
  mut shuffles_left : Int
  mut undos_left : Int
  mut total_time : Float
  mut total_levels : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut select_active : Bool
  mut select_x : Int
  mut select_y : Int
  mut hint_active : Bool
  mut hint_ttl : Float
  mut hint_x1 : Int
  mut hint_y1 : Int
  mut hint_x2 : Int
  mut hint_y2 : Int
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
  let undo_arr : Array[UndoPair] = Array::makei(max_undos, fn(_i) {
    {
      valid: false,
      x1: 0,
      y1: 0,
      kind1: 0,
      x2: 0,
      y2: 0,
      kind2: 0,
      prev_score: 0,
      prev_combo: 0,
      prev_timer: 0.0,
      prev_remaining: 0,
    }
  })

  let sparks_arr : Array[Spark] = Array::makei(1000, fn(_i) {
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
    active: Array::make(max_cells, false),
    cells: Array::make(max_cells, 0),
    undo: undo_arr,
    undo_len: 0,
    sparks: sparks_arr,
    state: state_title,
    level_index: 0,
    level_count: 10,
    level_name: "",
    board_w: 0,
    board_h: 0,
    kind_count: 0,
    score: 0,
    combo: 0,
    timer: 0.0,
    time_limit: 0.0,
    remaining: 0,
    hints_left: 0,
    shuffles_left: 0,
    undos_left: 0,
    total_time: 0.0,
    total_levels: 0,
    cursor_x: 1,
    cursor_y: 1,
    select_active: false,
    select_x: 1,
    select_y: 1,
    hint_active: false,
    hint_ttl: 0.0,
    hint_x1: 0,
    hint_y1: 0,
    hint_x2: 0,
    hint_y2: 0,
    hold_dir: dir_none,
    repeat_t: 0.0,
    touch_action_cd: 0.0,
    message: "",
    message_t: 0.0,
    shake_t: 0.0,
    ui_t: 0.0,
  }
}
