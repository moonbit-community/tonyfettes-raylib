///|
struct UndoStep {
  mut valid : Bool
  player_x : Int
  player_y : Int
  moves_before : Int
  pushes_before : Int
  mut pushed_box : Bool
  mut box_from_x : Int
  mut box_from_y : Int
  mut box_to_x : Int
  mut box_to_y : Int
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
  tiles : Array[Int]
  boxes : Array[Bool]
  undo : Array[UndoStep]
  sparks : Array[Spark]
  mut state : Int
  mut level_index : Int
  mut level_name : String
  mut level_par : Int
  level_count : Int
  mut grid_w : Int
  mut grid_h : Int
  mut player_x : Int
  mut player_y : Int
  mut moves : Int
  mut pushes : Int
  mut elapsed : Float
  mut goals_total : Int
  mut total_moves : Int
  mut total_pushes : Int
  mut total_elapsed : Float
  mut last_level_stars : Int
  mut campaign_stars : Int
  mut undo_len : Int
  mut message : String
  mut message_t : Float
  mut shake_t : Float
  mut pulse_t : Float
  mut hold_dir : Int
  mut repeat_t : Float
  mut touch_action_cd : Float
}

///|
fn Game::new() -> Game {
  let undo_arr : Array[UndoStep] = Array::makei(4096, fn(_i) {
    {
      valid: false,
      player_x: 0,
      player_y: 0,
      moves_before: 0,
      pushes_before: 0,
      pushed_box: false,
      box_from_x: 0,
      box_from_y: 0,
      box_to_x: 0,
      box_to_y: 0,
    }
  })

  let spark_arr : Array[Spark] = Array::makei(700, fn(_i) {
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
    tiles: Array::make(board_cells, tile_void),
    boxes: Array::make(board_cells, false),
    undo: undo_arr,
    sparks: spark_arr,
    state: state_title,
    level_index: 0,
    level_name: "",
    level_par: 0,
    level_count: 12,
    grid_w: 0,
    grid_h: 0,
    player_x: 0,
    player_y: 0,
    moves: 0,
    pushes: 0,
    elapsed: 0.0,
    goals_total: 0,
    total_moves: 0,
    total_pushes: 0,
    total_elapsed: 0.0,
    last_level_stars: 0,
    campaign_stars: 0,
    undo_len: 0,
    message: "",
    message_t: 0.0,
    shake_t: 0.0,
    pulse_t: 0.0,
    hold_dir: touch_none,
    repeat_t: 0.0,
    touch_action_cd: 0.0,
  }
}
