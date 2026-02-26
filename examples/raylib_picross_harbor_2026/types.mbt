///|
struct UndoStep {
  valid : Bool
  x : Int
  y : Int
  prev_state : Int
  prev_mistakes : Int
  prev_filled_correct : Int
  prev_filled_wrong : Int
  prev_hints_left : Int
  prev_hints_used : Int
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
  solution : Array[Bool]
  cells : Array[Int]
  row_clues : Array[Int]
  row_clue_counts : Array[Int]
  col_clues : Array[Int]
  col_clue_counts : Array[Int]
  undo : Array[UndoStep]
  sparks : Array[Spark]
  mut state : Int
  mut level_index : Int
  level_count : Int
  mut level_name : String
  mut level_par_time : Int
  mut level_mistake_limit : Int
  mut grid_w : Int
  mut grid_h : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut tool_mode : Int
  mut level_time : Float
  mut mistakes : Int
  mut hints_left : Int
  mut hints_used : Int
  mut filled_correct : Int
  mut filled_wrong : Int
  mut solution_total : Int
  mut total_time : Float
  mut total_mistakes : Int
  mut total_hints : Int
  mut total_stars : Int
  mut total_completed : Int
  mut last_level_stars : Int
  mut undo_len : Int
  mut message : String
  mut message_t : Float
  mut shake_t : Float
  mut ui_t : Float
  mut hold_dir : Int
  mut move_repeat_t : Float
  mut touch_action_cd : Float
}

///|
fn Game::new() -> Game {
  let undo_arr : Array[UndoStep] = Array::makei(8192, fn(_i) {
    {
      valid: false,
      x: 0,
      y: 0,
      prev_state: cell_unknown,
      prev_mistakes: 0,
      prev_filled_correct: 0,
      prev_filled_wrong: 0,
      prev_hints_left: 0,
      prev_hints_used: 0,
    }
  })

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
    solution: Array::make(max_cells, false),
    cells: Array::make(max_cells, cell_unknown),
    row_clues: Array::make(max_cells, 0),
    row_clue_counts: Array::make(max_board, 0),
    col_clues: Array::make(max_cells, 0),
    col_clue_counts: Array::make(max_board, 0),
    undo: undo_arr,
    sparks: sparks_arr,
    state: state_title,
    level_index: 0,
    level_count: 12,
    level_name: "",
    level_par_time: 90,
    level_mistake_limit: 6,
    grid_w: 0,
    grid_h: 0,
    cursor_x: 0,
    cursor_y: 0,
    tool_mode: tool_fill,
    level_time: 0.0,
    mistakes: 0,
    hints_left: 3,
    hints_used: 0,
    filled_correct: 0,
    filled_wrong: 0,
    solution_total: 0,
    total_time: 0.0,
    total_mistakes: 0,
    total_hints: 0,
    total_stars: 0,
    total_completed: 0,
    last_level_stars: 0,
    undo_len: 0,
    message: "",
    message_t: 0.0,
    shake_t: 0.0,
    ui_t: 0.0,
    hold_dir: dir_none,
    move_repeat_t: 0.0,
    touch_action_cd: 0.0,
  }
}
